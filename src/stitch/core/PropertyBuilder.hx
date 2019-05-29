package stitch.core;

#if !macro

@:autoBuild(stitch.core.PropertyBuilder.build({
  propNames: [ ':prop', ':property' ],
  createConstructor: false
}))
@:remove
interface PropertyBuilder {}

#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type.ClassType;

using Lambda;

typedef ValueClassOptions = {
  propNames:Array<String>,
  ?argName:String,
  ?setterMethodName:String,
  ?handleProps:(props:Array<Field>, inits:Array<Expr>)->Array<Field>,
  ?createConstructor:Bool
}

class PropertyBuilder {

  public static function build(options:ValueClassOptions) {
    return new PropertyBuilder(
      Context.getLocalClass().get(),
      Context.getBuildFields(),
      options
    ).export();
  }

  final cls:ClassType;
  final options:ValueClassOptions;
  var fields:Array<Field>;
  var ran:Bool = false;

  public function new(
    cls:ClassType,
    fields:Array<Field>,
    options:ValueClassOptions
  ) {
    this.cls = cls;
    this.fields = fields;
    this.options = options;
    if (this.options.argName == null) {
      this.options.argName = '__props';
    }
    if (this.options.setterMethodName == null) {
      this.options.setterMethodName = 'setProperties';
    }
    if (this.options.propNames == null) {
      this.options.propNames = [];
    }
  }

  public function export() {
    if (ran) return fields;
    ran = true;

    if (cls.isInterface) {
      return Context.getBuildFields();
    }
    if (cls.superClass != null) {
      Context.error('Classes implementing PropertyBuilder cannot be extended.', cls.pos);
    }

    var props:Array<Field> = [];
    var inits:Array<Expr> = [];
    var argName = options.argName;
    for (f in fields) switch (f.kind) {
      case FVar(t, _) | FProp(_, _, t, _):
        if (shouldMakeProp(f)) {
          var name = f.name;
          var isOptional = f.meta.exists(m -> m.name == ':optional');
          props.push(makeField(f.name, t, f.pos, isOptional));
          if (isOptional)
            inits.push(
              macro if ($i{argName}.$name != null) 
                this.$name = $i{argName}.$name
            );
          else
            inits.push(macro this.$name = $i{argName}.$name);
        }
      default:
    }

    if (options.handleProps != null) {
      fields = fields.concat(options.handleProps(props, inits));
    } else {
      var propsArg = TAnonymous(props);
      var setterName = options.setterMethodName;

      fields = fields.concat((macro class {
        public function $setterName($argName:$propsArg) {
          $b{inits}
        }
      }).fields);

      if (options.createConstructor == true) {
        fields = fields.concat((macro class {
          public function new($argName:$propsArg) {
            this.$setterName($i{argName});
          }
        }).fields);
      }
    }

    return fields;
  }

  function shouldMakeProp(f:Field):Bool {
    if (options.propNames.length == 0) { 
      return f.access.has(APublic);
    }
    
    if (f.meta.exists(m -> m.name == ':skip')) {
      return false;
    }

    return f.meta.exists(m -> options.propNames.has(m.name));
  }

  static function makeField(
    name:String,
    type:ComplexType,
    pos:Position,
    isOptional:Bool
  ):Field {
    return {
      name: name,
      kind: FVar(type, null),
      access: [ APublic ],
      meta: isOptional ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    };
  }

}

#end
