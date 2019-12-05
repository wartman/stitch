package stitch2;

#if !macro

@:allow(stitch2.Repository)
@:autoBuild(stitch2.Model.build())
interface Model {
  private var _stitch_info:Info;
}

#else

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import stitch2.Repository.RepositoryOptions;

using Lambda;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

// TODO: Id's should be built in and used to determine file names
//       (or folder names, if needed).
class Model {
  
  public static function build() {
    return new Model(
      Context.getBuildFields(),
      Context.getLocalClass().get()
    ).export();
  }

  final fields:Array<Field>;
  final cls:ClassType;
  var options:RepositoryOptions;
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
      default:
    }

    return fields.concat(modelFields).concat(initFields());
  }

  function checkForId() {
    var hasId = false;
    for (f in fields) {
      if (isId(f)) {
        hasId = true;
        break;
      }
    }
    if (hasId == false) {
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

      public static function _stitch_createRepository(store:stitch2.Store) {
        return new stitch2.Repository(store, {
          path: $v{options.path},
          isDirectory: $v{options.isDirectory},
          dataFile: $v{options.dataFile}
        }, _stitch_decode, _stitch_encode);
      }

      public static function _stitch_decode(__i__:stitch2.Info, __f__) {
        return new $tp(${ {
          expr: EObjectDecl(decode),
          pos: cls.pos
        } }, __i__);
      }

      public static function _stitch_encode(__f__:$ct) {
        return ${ {
          expr: EObjectDecl(encode),
          pos: cls.pos
        } };
      }

      var _stitch_fields:$props;
      var _stitch_info:stitch2.Info;

      public function new(__f__:$props, ?_stitch_info) {
        // todo: better handle info: what should the behavior be for 
        //       `new` models? how do we figure out the name of the model?
        //       set the id?
        this._stitch_info = _stitch_info == null ? {
          name: null,
          path: [],
          extension: '',
          created: Date.now(),
          modified: Date.now()
        } : _stitch_info;
        _stitch_fields = __f__;
      }

    }).fields;
  }

  function getRepositoryOptions():RepositoryOptions {
    if (options != null) return options;

    var meta = cls.meta.get();
    var repo = meta.find(m -> m.name == ':repository');
    options = { 
      path: cls.name.toLowerCase(),
      isDirectory: false,
      dataFile: '_data'
    };
    
    if (repo == null) return options;

    for (p in repo.params) switch p {
      case macro path = ${e}: switch e.expr {
        case EConst(CString(s, _)): options.path = s;
        default: Context.error('Repository path must be a string', e.pos);
      }
      case macro isDirectory = ${e}: switch e {
        case macro true: options.isDirectory = true;
        case macro false: options.isDirectory = false;
        default: Context.error('Must be bool', e.pos);
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
    var name = f.name;
    var getterName = 'get_${f.name}';
    var isAuto = false;
    var fromInfo:String = null;

    for (param in params) switch param {
      case macro auto: 
        var prefix = getRepositoryOptions().path;
        isAuto = true; 
        modelFields.push((macro class {
          static function _stitch_generateId() {
            return stitch2.IdTools.getUniqueId($v{prefix});
          }
        }).fields[0]);
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
          ? macro @:pos(f.pos) __f__.$name != null ? __f__.$name : _stitch_generateId()
          : macro @:pos(f.pos) __f__.$name
      });
    } else {
      decode.push({
        field: name,
        expr: isAuto
          ? macro @:pos(f.pos) __i__.$fromInfo != null ? __i__.$fromInfo : _stitch_generateId()
          : macro @:pos(f.pos) __i__.$fromInfo
      });
    }

    modelFields.push((macro class {
      function $getterName() {
        return _stitch_fields.$name;
      }
    }).fields[0]);
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

    modelFields.push((macro class {

      function $getterName() {
        return _stitch_info.$name;
      }

    }).fields[0]);
  }

  function isChildren(f:Field) {
    return f.meta.exists(m -> m.name == ':children');
  }

  function parseChildren(f:Field, t:ComplexType, params:Array<Expr>) {
    var options = getRepositoryOptions();
    if (!options.isDirectory) {
      var meta = f.meta.find(m -> m.name == ':children');
      Context.error('`:children` is only allowed on models that map to directories', meta.pos);
    }
  }

  function isField(f:Field) {
    return f.meta.exists(m -> m.name == ':field');
  }

  function parseField(f:Field, t:ComplexType, def:Expr, params:Array<Expr>) {
    if (t == null) {
      Context.error('`@:field` properties require a type', f.pos);
    }
    f.kind = FProp('get', 'never', t, null);
    if (!f.access.has(APublic)) f.access.push(APublic);

    var name = f.name;
    var getterName = 'get_${f.name}';
    var transformer = switch t.toString() {
      case 'String': macro @:pos(f.pos) stitch2.transformer.StringTransformer;
      case 'Int': macro @:pos(f.pos) stitch2.transformer.IntTransformer;
      case 'Float': macro @:pos(f.pos) stitch2.transformer.FloatTransformer;
      case 'Bool': macro @:pos(f.pos) stitch2.transformer.BoolTransformer;
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
      if (Context.unify(t.toType(), Context.getType('stitch2.Markdown'))) {
        transformer = macro @:pos(f.pos) stitch2.transformer.MarkdownTransformer;
      } else if (Context.unify(t.toType(), Context.getType('stitch2.Model'))) {
        // todo: how should sub-model ids be set?
        // todo: is there a less daft way to get the type here?
        transformer = macro @:pos(f.pos) $p{t.toString().split('.')};
      } else if (Context.unify(t.toType(), Context.getType('Array<stitch2.Model>'))) {
        // todo
      }
    }

    if (transformer == null) {
      Context.error(
        'No transformer found for field ${f.name}. Provide one with '
        + '`@:field(transformer = ...)`, or ensure it is a String, Int, '
        + 'Float or Bool',
        f.pos
      );
    }

    // transformer = macro @:pos(f.pos) (${transformer}:stitch2.Transformer<String, $t>);

    // todo: check if optional
    addFieldType(f.name, t, false, f.pos);

    decode.push({
      field: f.name,
      expr: macro @:pos(f.pos) ${transformer}._stitch_decode(__i__, __f__.$name)
    });
    encode.push({
      field: f.name,
      expr: macro @:pos(f.pos) ${transformer}._stitch_encode(__f__.$name)
    });
    modelFields.push((macro class {
      function $getterName() {
        return _stitch_fields.$name;
      }
    }).fields[0]);
  }

  function getFieldParams(f:Field, name:String) {
    if (f.meta.filter(m -> m.name == name).length > 1) {
      Context.error('Only one `@${name}` metadata is allowed per property', f.pos);
    }
    return f.meta.find(m -> m.name == name).params;
  }

  // static function parseRepository(cls:ClassType):Field {
  //   return {
  //     name: '_stitch_createRepository',
  //     access: [ APublic, AStatic ],
  //     kind: FFun({
  //       expr: macro null,
  //       ret: macro:stitch2.Repository<$tp>
  //     })
  //   };
  // }
  
}

#end
