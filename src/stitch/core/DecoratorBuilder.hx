#if macro
package stitch.core;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type.ClassType;

using StringTools;
// using Lambda;
// using haxe.macro.Tools;

typedef DecoratorBuilderOptions = {
  ?allowedPropertyDecorators:Array<String>,
  ?handleProperty:(field:FieldInfo, decorator:DecoratorInfo)->Array<Field>,
  ?allowedMethodDecorators:Array<String>,
  ?handleMethod:(field:FieldInfo, decorator:DecoratorInfo)->Array<Field>,
  ?allowedClassDecorators:Array<String>,
  ?handleClass:(cls:ClassType, decorator:DecoratorInfo)->Array<Field>
};

typedef FieldInfo = {
  name:String,
  field:Field,
  t:ComplexType
}

enum DecoratorKind {
  DecoProperty(?initialValue:Expr);
  DecoReadOnlyProperty;
  DecoAnnotation;
  DecoMethod;
}

typedef DecoratorInfo = {
  name:String,
  fullPath:TypePath,
  localPath:TypePath,
  params:Expr,
  kind:DecoratorKind
};

// Note: the API here is a bit wonky -- think on it and
//       come up with something cleaner. 
class DecoratorBuilder {

  var cls:ClassType;
  var clsPath:TypePath;
  var imports:Array<ImportExpr>;
  var fields:Array<Field>;
  var options:DecoratorBuilderOptions;

  public function new(
    cls,
    imports,
    fields,
    ?options
  ) {
    this.cls = cls;
    clsPath = { name: cls.name, pack: cls.pack };
    this.imports = imports;
    this.fields = fields;
    this.options = options == null ? {} : options;

    if (this.options.handleProperty == null) {
      this.options.handleProperty = defaultPropertyHandler;
    }
    if (this.options.handleMethod == null) {
      this.options.handleMethod = defaultMethodHandler;
    }
    if (this.options.handleClass == null) {
      this.options.handleClass = defaultClassHandler;
    }
  }

  public function export() {
    var toAdd:Array<Field> = [];

    for (m in cls.meta.get()) {
      if (maybeDecorator([ m ])) {
        var name = m.name;
        var fullPath = getDecoratorPath(name);
        if (isClassDecorator(fullPath)) {
          var localPath = getLocalPath(name);
          toAdd = toAdd.concat(
            options.handleClass(cls, {
              name: name,
              localPath: localPath,
              fullPath: fullPath,
              params: paramsToObject(m.params),
              kind: DecoAnnotation
            })
          );
          cls.meta.remove(m.name);
        }
      }
    }

    for (f in fields) switch f.kind {
      case FVar(t, e) if (f.meta != null && maybeDecorator(f.meta)): 
        var fieldMeta = f.meta.copy();
        for (meta in fieldMeta) {
          var name = meta.name;
          var fullPath = getDecoratorPath(name);
          if (isPropertyDecorator(fullPath)) {
            var localPath = getLocalPath(name);
            var decoType = resolveType(fullPath);
            var kind:DecoratorKind = DecoAnnotation;

            if (Context.unify(decoType, Context.getType('stitch.core.PropertyDecorator'))) {
              f.kind = FProp('get', 'set', t, null);
              kind = DecoProperty(e);
            } else if (Context.unify(decoType, Context.getType('stitch.core.ReadOnlyPropertyDecorator'))) {
              f.kind = FProp('get', 'never', t, null);
              kind = DecoReadOnlyProperty;
            } else if (Context.unify(decoType, Context.getType('stitch.core.Annotation'))) {
              kind = DecoAnnotation;
            }

            toAdd = toAdd.concat(
              options.handleProperty({
                name: f.name,
                field: f,
                t: t
              }, {
                name: name,
                localPath: localPath,
                fullPath: fullPath,
                params: paramsToObject(meta.params),
                kind: kind
              })
            );

            f.meta.remove(meta);
          }
        }
      case FFun(func) if (f.meta != null && maybeDecorator(f.meta)):
        var fieldMeta = f.meta.copy();
        for (meta in fieldMeta) {
          var name = meta.name;
          var fullPath = getDecoratorPath(name);
          if (isMethodDecorator(fullPath)) {
            var localPath = getLocalPath(name);

            toAdd = toAdd.concat(
              options.handleMethod({
                name: f.name,
                field: f,
                t: func.ret
              }, {
                name: name,
                localPath: localPath,
                fullPath: fullPath,
                params: paramsToObject(meta.params),
                kind: DecoMethod
              })
            );

            f.meta.remove(meta);
          }
        }
      default:
    }

    return fields.concat(toAdd);
  }

  function defaultPropertyHandler(field:FieldInfo, decorator:DecoratorInfo):Array<Field> {
    // var getterName = 'get_${field.name}';
    // var setterName = 'set_${field.name}';
    // var safeName = decorator.name.replace('.', '_');
    // var fieldName = '__${field.name}_$safeName';
    // var initName = '__initialize_${field.name}_$safeName';
    // var localPath = decorator.localPath;
    // var init = macro new $localPath(${decorator.params});
    // var e = decorator.initialValue;
    
    // return (macro class {
    //   var $fieldName:Dynamic; // todo: type it
    //   inline function $initName() {
    //     if (this.$fieldName == null) {
    //       this.$fieldName = ${init}; 
    //       ${if (e != null) macro this.$fieldName.set(${e}) else macro null};
    //     }
    //   }
    //   public function $setterName(value) {
    //     this.$initName();
    //     return this.$fieldName.set(value);
    //   }
    //   public function $getterName() {
    //     this.$initName();
    //     return this.$fieldName.get();
    //   }
    // }).fields;
    return [];
  }

  function defaultMethodHandler(field:FieldInfo, decorator:DecoratorInfo):Array<Field> {
    return [];
  }
    

  function defaultClassHandler(cls:ClassType, decorator:DecoratorInfo):Array<Field> {
    return [];
  }

  function maybeDecorator(meta:Metadata) {
    for (m in meta) {
      var name = m.name;
      if (name.charAt(0) == ':') return false;
      if (name.indexOf('.') >= 0) return true;
      if (isUpperCase(name.charAt(0))) return true;
    }
    return false;
  }

  function isUpperCase(str:String) {
    return str == str.toUpperCase();
  }

  function isPropertyDecorator(path:TypePath):Bool {
    return isDecorator(path, options.allowedPropertyDecorators);
  }

  function isClassDecorator(path:TypePath):Bool {
    return isDecorator(path, options.allowedClassDecorators);
  }

  function isMethodDecorator(path:TypePath):Bool {
    return isDecorator(path, options.allowedMethodDecorators);
  }

  function isDecorator(path:TypePath, allowed:Array<String>):Bool {
    if (allowed == null) return true;
    try {
      var t = resolveType(path);
      for (decoType in allowed) {
        if (Context.unify(t, Context.getType(decoType))) {
          return true;
        }
      }
      return false;
    } catch (e:String) {
      return false;
    }
  }
  
  function resolveType(path:TypePath) {
    var name = path.pack.concat([ path.name ]).join('.');
    return Context.getType(name);
  }

  function getDecoratorPath(name:String):TypePath {
    // check imports
    for (i in imports) switch i.mode {
      case IAsName(n):
        if (n == name) {
          var name = i.path[i.path.length - 1].name; 
          var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
          return { name: name, pack: pack };
        }
      default:
        var n = i.path[i.path.length - 1].name;
        if (n == name) {
          var pack = [ for (index in 0...i.path.length-1) i.path[index].name ];
          return { name: name, pack: pack };
        }
    }

    // If not found, assume local or full type path.
    return getLocalPath(name);
  }

  function getLocalPath(name:String):TypePath {
    if (name.indexOf('.') >= 0) {
      var parts = name.split('.');
      var name = parts.pop();
      return { name: name, pack: parts }; 
    }
    return { name: name, pack: [] };
  }

  function paramsToObject(params:Array<Expr>):Expr {
    return {
      expr: EObjectDecl([
        for (e in params) switch (e.expr) {
          case EBinop(OpAssign, { expr: EConst(CIdent(s)), pos: _ }, e):
            { field: s, expr: e };
          default:
            Context.error('Invalid param', e.pos);
        }
      ]),
      pos: Context.currentPos()
    };
  }

}
#end
