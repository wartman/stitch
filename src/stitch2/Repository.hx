package stitch2;

using haxe.io.Path;

typedef RepositoryOptions = {
  ?path:String,
  ?defaultExtension:String,
  ?isDirectory:Bool,
  ?dataFile:String
}; 

#if !macro

class Repository<T:Model> {

  final store:Store;
  final options:RepositoryOptions;
  final decoder:(info:Info, data:Dynamic)->T;
  final encoder:(data:T)->Dynamic;

  public function new(store, options, decoder, encoder) {
    this.store = store;
    this.options = options;
    this.decoder = decoder;
    this.encoder = encoder;
  }

  public function withOverrides(overrides:RepositoryOptions) {
    return new Repository(store, {
      path: overrides.path != null ? overrides.path : options.path,
      defaultExtension: overrides.defaultExtension != null ? overrides.defaultExtension : options.defaultExtension,
      isDirectory: overrides.isDirectory != null ? overrides.isDirectory : options.isDirectory,
      dataFile: overrides.dataFile != null ? overrides.dataFile : options.dataFile
    }, decoder, encoder);
  }

  public function get(id:String):T {
    var data = store.__load(getPath(id));
    if (data != null) {
      var model = decoder(prepareInfo(data.info), data.contents);
      model.__resolveMappings(store);
      return model;
    }
    return null;
  }

  public function all():Array<T> {
    return [ for (id in store.__listIds(options.path)) get(id) ];
  }

  public function save(model:T):Void {
    var path = getPath(model.__getId());
    store.__save(
      path,
      resolveExtension(model),
      encoder(model)
    );
    model.__saveMappings(store);
    model.__info = prepareInfo(store.connection.getInfo(path));
  }

  public function remove(model:T):Bool {
    return false;
  }
  
  function prepareInfo(info:Info):Info {
    if (!options.isDirectory) return info;
    return {
      name: info.path[ info.path.length - 1 ],
      path: info.path.slice(0, info.path.length - 1),
      created: info.created,
      modified: info.modified,
      extension: info.extension
    };
  }

  function getPath(id:String) {
    return if (options.isDirectory) {
      Path.join([ options.path, id, options.dataFile ]);
    } else {
      Path.join([ options.path, id ]);
    }
  }

  function resolveExtension(model:Model) {
    if (model.__info.extension == null) {
      return options.defaultExtension;
    }
    return model.__info.extension;
  }

}

#else 

class Repository {}

#end
