package stitch;

#if !macro

@:autoBuild(stitch.Model.build())
@:allow(stitch.Field)
interface Model {
  public var id(get, set):String;
  private var store:Store;
  public function connect(store:Store):Void;
  public function exists():Bool;
  public function encode():Dynamic;
  public function toJson():Dynamic; // I wish there was a way to type this
}

#else

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import stitch.core.DecoratorBuilder;

using Lambda;
using haxe.macro.Tools;

class Model {

  public static function build() {
    var props:Array<Field> = [];
    var internalFields:Array<Field> = [];
    var inits:Array<Expr> = [];
    var decode:Array<Expr> = [];
    var encode:Array<Expr> = [];
    var toJson:Array<ObjectField> = [];
    var fields = Context.getBuildFields();
    var cls = Context.getLocalClass().get();

    var hasId = fields.exists(f -> f.name == 'id');
    if (!hasId) {
      fields = fields.concat((macro class {
        @stitch.field.IdField public var id:String;
      }).fields);
    }

    function propertyHandler(f:FieldInfo, deco:DecoratorInfo) {
      var name = f.name;
      var getterName = 'get_${f.name}';
      var setterName = 'set_${f.name}';
      var localPath = deco.localPath;
      // Is there a better way to get this type :P
      var decoType = Context.getType(deco.fullPath.pack.concat([ deco.fullPath.name ]).join('.'));
      
      internalFields.push({
        name: name,
        kind: FVar(TPath(localPath)),
        access: [ APublic ],
        pos: f.field.pos
      });

      inits.push(macro @:pos(f.field.pos) fields.$name = new $localPath(this, ${deco.params}));
      toJson.push({ field: name, expr: macro fields.$name.getJson() });

      if (Context.unify(decoType, Context.getType('stitch.Field.DecodeableField'))) {
        decode.push(macro model.fields.$name.decode(data, raw.get($v{name})));
      } else if (Context.unify(decoType, Context.getType('stitch.Field.DecodeableRepeatableField'))) {
        decode.push(macro model.fields.$name.decode(data, raw.get($v{name})));
      }
      
      if (Context.unify(decoType, Context.getType('stitch.Field.EncodeableField'))) {
        encode.push(macro obj.$name = fields.$name.encode());
      }

      var fields = (macro class {
        public function $getterName() {
          return cast fields.$name.get();
        }
      }).fields;

      switch deco.kind {
        case DecoProperty(initialValue):
          fields = fields.concat((macro class {
            public function $setterName(value) {
              return cast fields.$name.set(value);
            }
          }).fields);
          props.push({
            name: name,
            kind: FVar(f.t, null),
            access: [ APublic ],
            meta: initialValue != null
              ? [ { name: ':optional', params: [], pos: Context.currentPos() } ]
              : [], 
            pos: Context.currentPos()
          });
          if (initialValue != null) {
            inits.push(
              macro this.$name = __props.$name != null
                ? __props.$name
                : ${initialValue}
            );
          } else {
            inits.push(macro this.$name = __props.$name);
          }
        // case DecoReadOnlyProperty:
        default:
      }
      return fields;
    }

    function classHandler(cls:ClassType, decorator:DecoratorInfo) {
      var t = TPath({ name: cls.name, pack: cls.pack });
      var localPath = decorator.localPath;
      return (macro class {
        public static final collection:stitch.Collection<$t>
          = new $localPath(${decorator.params}, factory);
      }).fields;
    }

    var deco = new DecoratorBuilder(
      cls,
      Context.getLocalImports(),
      fields,
      {
        allowedPropertyDecorators: [ 'stitch.Field' ], 
        handleProperty: propertyHandler,
        allowedClassDecorators: [ 'stitch.Collection' ],
        handleClass: classHandler
        // todo: what about methods?
      }
    );

    var p:TypePath = { name: cls.name, pack: cls.pack };
    var t = TPath(p);
    var initProps = TAnonymous(props);
    var fieldProps = TAnonymous(internalFields);
    var export = deco.export().concat((macro class {

      public static function factory(data:stitch.Document, formatter:stitch.Formatter<Dynamic>):$t {
        var model = new $p();
        var raw:haxe.DynamicAccess<String> = cast formatter.decode(data.contents);
        $b{decode}
        return model;
      }

      public final fields:$fieldProps;
      var store:Store;

      public function new(?__props:$initProps) {
        fields = cast {};
        if (__props == null) __props = cast {};
        $b{inits};
      }

      public function connect(store:Store) {
        this.store = store;
      }

      public function encode():Dynamic {
        var obj:Dynamic = {};
        $b{encode}
        return obj;
      }

      public function toJson() {
        return ${ { expr: EObjectDecl(toJson), pos: Context.currentPos() } };
      }

      public function exists() {
        return id != null;
      }

    }).fields);

    // Build model info from conventions
    if (!export.exists(f -> f.name == 'collection')) {
      var name = cls.name.toLowerCase();
      export = export.concat(classHandler(cls, {
        name: 'Collection',
        localPath: { name: 'Collection', pack: [ 'corvid', 'core', 'data' ] },
        fullPath: { name: 'Collection', pack: [ 'corvid', 'core', 'data' ] },
        params: macro { path: $v{name} },
        kind: DecoAnnotation
      }));
    }

    return export;
  }

}

#end
