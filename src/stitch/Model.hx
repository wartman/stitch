package stitch;
#if !macro

@:allow(stitch.Repository)
@:allow(stitch.Selection)
@:autoBuild(stitch.Model.build())
interface Model {
  private var __info:Info;
  private function __getId():String;
  private function __resolveMappings(store:Store):Void;
  private function __saveMappings(store:Store):Void;
}

#else

// TODO:
// DRY this mess up, especially all the relation stuff.

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import stitch.Repository.RepositoryOptions;

using Lambda;
using haxe.io.Path;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

class Model {
  
  public static function build() {
    return new Model(
      Context.getBuildFields(),
      Context.getLocalClass().get()
    ).export();
  }

  var options:RepositoryOptions;
  var idField:String;
  final fields:Array<Field>;
  final cls:ClassType;
  final resolveMappings:Array<Expr> = [];
  final saveMappings:Array<Expr> = [];
  final modelFields:Array<Field> = [];
  final fieldObj:Array<Field> = [];
  final initObj:Array<ObjectField> = [];
  final decode:Array<ObjectField> = [];
  final encode:Array<ObjectField> = [];

  public function new(fields, cls) {
    this.fields = fields;
    this.cls = cls;
  }

  public function export() {
    checkForId();

    for (f in fields) switch f.kind {
      case FVar(t, e) if (isField(f)):
        parseField(f, t, e, getFieldParams(f, ':field'));
      case FVar(t, e) if (isInfo(f)):
        parseInfo(f, t, e, getFieldParams(f, ':info'));
      case FVar(t, e) if (isId(f)):
        parseId(f, t, e, getFieldParams(f, ':id'));
      case FVar(t, e) if (isChildren(f)):
        parseChildren(f, t, getFieldParams(f, ':children'));
      case FVar(t, e) if (isBelongsTo(f)):
        parseBelongsTo(f, t, getFieldParams(f, ':belongsTo'));
      case FVar(t, e) if (isHasOne(f)):
        parseHasOne(f, t, getFieldParams(f, ':hasOne'));
      case FVar(t, e) if (isHasMany(f)):
        parseHasMany(f, t, getFieldParams(f, ':hasMany'));
      default:
    }

    return fields.concat(modelFields).concat(initFields());
  }

  function checkForId() {
    var hasId = false;
    for (f in fields) {
      if (isId(f)) {
        idField = f.name;
        hasId = true;
        break;
      }
    }
    if (hasId == false) {
      idField = 'id';
      fields.push((macro class {
        @:id(auto) var id:String;
      }).fields[0]);
    }
  }

  function initFields() {
    var tp:TypePath = { pack: cls.pack, name: cls.name };
    var props = TAnonymous(fieldObj);
    var options = getRepositoryOptions();
    // there has to be a better way to do this
    var ct = Context
      .getType(tp.pack.concat([ tp.name ]).join('.'))
      .toComplexType();

    return (macro class {

      public static function __createRepository(store:stitch.Store) {
        return new stitch.Repository(store, {
          path: $v{options.path},
          isDirectory: $v{options.isDirectory},
          defaultExtension: $v{options.defaultExtension},
          dataFile: $v{options.dataFile}
        }, __decode, __encode);
      }

      public static function __decode(__i__:stitch.Info, __f__) {
        return new $tp(${ {
          expr: EObjectDecl(decode),
          pos: cls.pos
        } }, __i__);
      }

      public static function __encode(__f__:$ct) {
        return ${ {
          expr: EObjectDecl(encode),
          pos: cls.pos
        } };
      }

      var __fields:$props;
      var __info:stitch.Info;

      public function new(__f__:$props, ?__info) {
        this.__info = __info == null ? {
          name: null,
          path: [],
          extension: null,
          created: Date.now(),
          modified: Date.now(),
          fullPath: ''
        } : __info;
        __fields = __f__;
      }

      function __getId() return this.$idField;

      function __resolveMappings(store:stitch.Store) {
        $b{resolveMappings};
      }

      function __saveMappings(store:stitch.Store) {
        $b{saveMappings};
      }

    }).fields;
  }

  function getRepositoryOptions():RepositoryOptions {
    if (options != null) return options;

    var meta = cls.meta.get();
    var repo = meta.find(m -> m.name == ':repository');
    options = { 
      path: cls.name.toLowerCase(),
      defaultExtension: 'txt',
      isDirectory: false,
      dataFile: '_data'
    };
    
    if (repo == null) return options;

    return options = parseRepositoryOptions(repo.params);
  }

  function parseRepositoryOptions(params:Array<Expr>):RepositoryOptions {
    var options:RepositoryOptions = {
      path: null,
      defaultExtension: null,
      isDirectory: false,
      dataFile: '_data'
    };

    for (p in params) switch p {
      case macro path = ${e}: switch e.expr {
        case EConst(CString(s, _)): options.path = s;
        default: Context.error('Repository path must be a string', e.pos);
      }
      case macro isDirectory = ${e}: switch e {
        case macro true: options.isDirectory = true;
        case macro false: options.isDirectory = false;
        default: Context.error('Must be bool', e.pos);
      }
      case macro defaultExtension = ${e}: switch e.expr {
        case EConst(CString(s, _)): options.defaultExtension = s;
        default: Context.error('Repository defaultExtension must be a string', e.pos);
      }
      case macro dataFile = ${e}: switch e.expr {
        case EConst(CString(s, _)): options.dataFile = s;
        default: Context.error('Data file must be a string', e.pos);
      }
      default: Context.error('Invalid repository option', p.pos);
    }

    return options;
  }

  function addFieldType(name:String, t:ComplexType, isOptional:Bool = false, pos:Position) {
    fieldObj.push({
      name: name,
      kind: FVar(t, null),
      access: [ APublic ],
      meta: isOptional ? [ { name: ':optional', pos: pos } ] : [],
      pos: pos
    });
  }

  function isId(f:Field) {
    return f.meta.exists(m -> m.name == ':id');
  }

  function parseId(f:Field, t:ComplexType, def:Expr, params:Array<Expr>) {
    f.kind = FProp('get', 'never', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);
    var name = f.name;
    var getterName = 'get_${f.name}';
    var isAuto = false;
    var fromInfo:String = null;

    for (param in params) switch param {
      case macro auto: 
        var prefix = getRepositoryOptions().path;
        isAuto = true;
        if (!fields.exists(f -> f.name == '__generateId')) {
          modelFields.push((macro class {
            static function __generateId() {
              return stitch.IdTools.getUniqueId($v{prefix});
            }
          }).fields[0]);
        }
      case macro info:
        fromInfo = 'name';
      case macro info = ${e}: switch e.expr {
        case EConst(CIdent(s)) | EConst(CString(s, _)):
          fromInfo = s;
        default:
          Context.error('`id.info` must be a string or an identifier', e.pos);
      }
      default:
        Context.error('Invalid `id` option', param.pos);
    }

    addFieldType(name, t, isAuto, f.pos);
    
    if (fromInfo == null) {
      decode.push({
        field: name,
        expr: isAuto 
          ? macro @:pos(f.pos) __f__.$name != null ? __f__.$name : __generateId()
          : macro @:pos(f.pos) __f__.$name
      });
    } else {
      decode.push({
        field: name,
        expr: isAuto
          ? macro @:pos(f.pos) __i__.$fromInfo != null ? __i__.$fromInfo : __generateId()
          : macro @:pos(f.pos) __i__.$fromInfo
      });
    }

    add((macro class {

      function $getterName() {
        return __fields.$name;
      }

    }).fields);
  }

  function isInfo(f:Field) {
    return f.meta.exists(m -> m.name == ':info');
  }

  function parseInfo(f:Field, t:ComplexType, def:Expr, params:Array<Expr>) {
    f.kind = FProp('get', 'never', t, null);
    var getterName = 'get_${f.name}';
    var name = f.name;

    if (params.length > 1) {
      Context.error('Only one param allowed for `@:info`', f.pos);
    }

    for (param in params) switch param.expr {
      case EConst(CIdent(s)) | EConst(CString(s, _)): name = s;
      default: Context.error('Param must be a string or an identifier', param.pos);
    }

    add((macro class {

      function $getterName() {
        return __info.$name;
      }

    }).fields);
  }

  function isChildren(f:Field) {
    return f.meta.exists(m -> m.name == ':children');
  }

  function parseChildren(f:Field, t:ComplexType, params:Array<Expr>) {
    if (t == null) {
      Context.error('`@:children` properties require a type', f.pos);
    }
    if (!isModelArray(t)) {
      Context.error('@:children fields must unify with Array<stitch.Model>', f.pos);
    }
    f.kind = FProp('get', 'never', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);

    var options = getRepositoryOptions();
    if (!options.isDirectory) {
      var meta = f.meta.find(m -> m.name == ':children');
      Context.error('`:children` is only allowed on models that map to directories', meta.pos);
    }
    var overrides = parseRepositoryOptions(params);
    var name = f.name;
    var getterName = 'get_${f.name}';
    var clsPath = getModelType(t, f.pos).toString().split('.');
    var mapping = '__mapping_${name}';
    var path = overrides.path != null ? overrides.path : name;
    var ext = overrides.defaultExtension != null ? overrides.defaultExtension : options.defaultExtension;

    addFieldType(name, t, true, f.pos);

    resolveMappings.push(macro @:pos(f.pos) this.$mapping = () -> this.__fields.$name = store.getRepository($p{clsPath}).withOverrides({
      path: haxe.io.Path.join([ $v{options.path}, __getId(), $v{path} ]),
      defaultExtension: $v{ext}
    }).all());

    saveMappings.push(macro @:pos(f.pos) for (m in this.$name) store.getRepository($p{clsPath}).withOverrides({
      path: haxe.io.Path.join([ $v{options.path}, __getId(), $v{path} ]),
      defaultExtension: $v{ext}
    }).save(m));

    add((macro class {

      function $getterName() {
        if (__fields.$name == null && this.$mapping != null) {
          __fields.$name = this.$mapping();
        }
        return __fields.$name;
      }

      var $mapping:()->$t;

    }).fields);
  }

  function isBelongsTo(f:Field) {
    return f.meta.exists(m -> m.name == ':belongsTo');
  }

  function parseBelongsTo(f:Field, t:ComplexType, params:Array<Expr>) {
    if (t == null) {
      Context.error('`@:belongsTo` properties require a type', f.pos);
    }
    if (!isModel(t)) {
      Context.error('@:belongsTo must be a stitch.Model', f.pos);
    }
    f.kind = FProp('get', 'never', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);

    var name = f.name;
    var relationName = '${name}_id';
    var getterName = 'get_${f.name}';
    var clsPath = t.toString().split('.');
    var overrides = macro {};

    for (param in params) switch param {
      case macro path = ${e}: switch e.expr {
        case EConst(CString(s, _)):
          overrides = macro { path: $v{s} };
        default:
          Context.error('`path` must be a string', e.pos);
      }
      case macro on = ${e}: switch e.expr {
        case EConst(CIdent(s)) | EConst(CString(s, _)):
          relationName = s;
        default:
          Context.error('`on` must be a string or an identifier', e.pos);
      }
      default:
        Context.error('Invalid @:belongsTo option', param.pos);
    }

    // todo: check if optional
    addFieldType(relationName, macro:String, true, f.pos);
    addFieldType(name, t, true, f.pos);

    decode.push({
      field: relationName,
      expr: macro @:pos(f.pos) stitch.transformer.StringTransformer.__decode(__i__, __f__.$relationName)
    });
    encode.push({
      field: relationName,
      expr: macro @:pos(f.pos) __f__.$name != null ? @:privateAccess __f__.$name.__getId() : @:privateAccess __f__.__fields.$relationName
    });
    
    var relationGetter = 'get_${relationName}';
    var relationSetter = 'set_${relationName}';
    var mapping = '__mapping_${name}';

    resolveMappings.push(
      macro @:pos(f.pos) this.$mapping = () -> store.getRepository($p{clsPath})
        .withOverrides(${overrides})
        .get(__fields.$relationName)
    );

    add((macro class {

      function $getterName() {
        if (__fields.$name == null && this.$mapping != null) {
          __fields.$name = this.$mapping();
        }
        return __fields.$name;
      }

      var $mapping:()->$t;
      
      public var $relationName(get, set):String;

      function $relationGetter() {
        return __fields.$relationName;
      }

      function $relationSetter(value) {
        return __fields.$relationName = value;
      }

    }).fields);
  }

  function isHasOne(f:Field) {
    return f.meta.exists(m -> m.name == ':hasOne');
  }

  function parseHasOne(f:Field, t:ComplexType, params:Array<Expr>) {
    if (t == null) {
      Context.error('`@:hasOne` properties require a type', f.pos);
    }
    if (!isModel(t)) {
      Context.error('@:hasOne must be a stitch.Model', f.pos);
    }
    f.kind = FProp('get', 'never', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);
    
    var name = f.name;
    var relationName = '${cls.name.toLowerCase()}_id';
    var getterName = 'get_${f.name}';
    var clsPath = t.toString().split('.');
    var overrides = macro {};
    
    for (param in params) switch param {
      case macro path = ${e}: switch e.expr {
        case EConst(CString(s, _)):
          overrides = macro { path: $v{s} };
        default:
          Context.error('`path` must be a string', e.pos);
      }
      case macro on = ${e}: switch e.expr {
        case EConst(CIdent(s)) | EConst(CString(s, _)):
          relationName = s;
        default:
          Context.error('`on` must be a string or an identifier', e.pos);
      }
      default:
        Context.error('Invalid @:hasOne option', param.pos);
    }

    // todo: check if optional
    addFieldType(name, t, true, f.pos);

    var mapping = '__mapping_${name}';
    
    resolveMappings.push(
      macro @:pos(f.pos) this.$mapping = () -> store.getRepository($p{clsPath})
        .withOverrides(${overrides})
        .select()
        .where(m -> m.$relationName == this.__getId())
        .first()
    );

    saveMappings.push(
      macro @:pos(f.pos) if (this.$name != null && this.$name.$relationName != this.__getId()) {
        this.$name.$relationName = this.__getId();
        store.getRepository($p{clsPath}).withOverrides(${overrides}).save(this.$name);
      }
    );

    add((macro class {

      function $getterName() {
        if (__fields.$name == null && this.$mapping != null) {
          __fields.$name = this.$mapping();
        }
        return __fields.$name;
      }

      var $mapping:()->$t;

    }).fields);
  }

  function isHasMany(f:Field) {
    return f.meta.exists(m -> m.name == ':hasMany');
  }

  function parseHasMany(f:Field, t:ComplexType, params:Array<Expr>) {
    if (t == null) {
      Context.error('`@:hasMany` properties require a type', f.pos);
    }
    if (!isModelArray(t)) {
      Context.error('@:hasMany must be an array of stitch.Model', f.pos);
    }
    f.kind = FProp('get', 'never', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);
    
    var name = f.name;
    var relationName = '${cls.name.toLowerCase()}_id';
    var getterName = 'get_${f.name}';
    var clsPath = getModelType(t, f.pos).toString().split('.');
    var overrides = macro {};
    
    for (param in params) switch param {
      case macro path = ${e}: switch e.expr {
        case EConst(CString(s, _)):
          overrides = macro { path: $v{s} };
        default:
          Context.error('`path` must be a string', e.pos);
      }
      case macro on = ${e}: switch e.expr {
        case EConst(CIdent(s)) | EConst(CString(s, _)):
          relationName = s;
        default:
          Context.error('`on` must be a string or an identifier', e.pos);
      }
      default:
        Context.error('Invalid @:hasOne option', param.pos);
    }

    // todo: check if optional
    addFieldType(name, t, true, f.pos);

    var mapping = '__mapping_${name}';
    
    resolveMappings.push(
      macro @:pos(f.pos) this.$mapping = () -> store.getRepository($p{clsPath})
        .withOverrides(${overrides})
        .select()
        .where(m -> m.$relationName == this.__getId())
        .all()
    );

    saveMappings.push(
      macro @:pos(f.pos) if (this.$name != null) {
        var __r = store.getRepository($p{clsPath}).withOverrides(${overrides});
        for (m in this.$name) if (m.$relationName != this.__getId()) {
          m.$relationName = this.__getId();
          __r.save(m);
        }
      }
    );
  
    add((macro class {

      function $getterName() {
        if (__fields.$name == null && this.$mapping != null) {
          __fields.$name = this.$mapping();
        }
        return __fields.$name;
      }

      var $mapping:()->$t;

    }).fields);
  }

  function isField(f:Field) {
    return f.meta.exists(m -> m.name == ':field');
  }

  function parseField(f:Field, t:ComplexType, def:Expr, params:Array<Expr>) {
    if (t == null) {
      Context.error('`@:field` properties require a type', f.pos);
    }
    f.kind = FProp('get', 'set', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);

    var name = f.name;
    var getterName = 'get_${f.name}';
    var setterName = 'set_${f.name}';
    var transformer = switch t.toString() {
      case 'String': macro @:pos(f.pos) stitch.transformer.StringTransformer;
      case 'Int': macro @:pos(f.pos) stitch.transformer.IntTransformer;
      case 'Float': macro @:pos(f.pos) stitch.transformer.FloatTransformer;
      case 'Bool': macro @:pos(f.pos) stitch.transformer.BoolTransformer;
      default: null;
    }

    for (param in params) switch param {
      case macro transformer = ${e}: 
        // Check expression here?
        transformer = e;
      default:
        Context.error('Invalid `field` option', param.pos);
    }

    if (transformer == null) {
      if (Context.unify(t.toType(), Context.getType('stitch.types.Markdown'))) {
        // todo: this feels off.
        transformer = macro @:pos(f.pos) stitch.transformer.MarkdownTransformer;
      } else if (isModel(t)) {
        // todo: how should sub-model ids be set?
        // todo: is there a less daft way to get the type here?
        transformer = macro @:pos(f.pos) $p{t.toString().split('.')};
      } else if (isModelArray(t)) {
        // todo: is there a less daft way to get the type here?
        var parts = getModelType(t, f.pos).toString().split('.');
        transformer = macro @:pos(f.pos) ({
          __decode: (info, data) -> data != null 
            ? data.map(d -> $p{parts}.__decode(info, d))
            : [],
          __encode: (data) -> data != null 
            ? data.map($p{parts}.__encode)
            : []
        });
      }
    }

    if (transformer == null) {
      Context.error(
        'No transformer found for field ${f.name}. Provide one with '
        + '`@:field(transformer = ...)`, or ensure it is a String, Int, '
        + 'Float, Bool or a stitch.Model',
        f.pos
      );
    }

    // transformer = macro @:pos(f.pos) (${transformer}:stitch.Transformer<String, $t>);

    // todo: check if optional
    addFieldType(f.name, t, false, f.pos);

    decode.push({
      field: f.name,
      expr: macro @:pos(f.pos) ${transformer}.__decode(__i__, __f__.$name)
    });

    encode.push({
      field: f.name,
      expr: macro @:pos(f.pos) ${transformer}.__encode(__f__.$name)
    });

    add((macro class {
      
      function $getterName() {
        return __fields.$name;
      }

      function $setterName(value) {
        __fields.$name = value;
        return value;
      }

    }).fields);
  }

  function getFieldParams(f:Field, name:String) {
    if (f.meta.filter(m -> m.name == name).length > 1) {
      Context.error('Only one `@${name}` metadata is allowed per property', f.pos);
    }
    return f.meta.find(m -> m.name == name).params;
  }

  function getModelType(t:ComplexType, pos:Position) {
    return switch Context.parse('(null:${t.toString()})', pos) {
      case macro (null:Array<$mt>): mt;
      default: t;
    }
  }

  function isModel(t:ComplexType) {
    return Context.unify(t.toType(), Context.getType('stitch.Model'));
  }

  function isModelArray(t:ComplexType) {
    return 
      Context.unify(t.toType(), Context.getType('Array'))
      && isModel(getModelType(t, Context.currentPos()));
  }

  function add(fields:Array<Field>) {
    for (f in fields) modelFields.push(f);
  }

}

#end
