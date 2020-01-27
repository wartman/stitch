package stitch;

using haxe.io.Path;

#if !macro
  import stitch.error.*;
  using tink.CoreApi;
#end

typedef RepositoryOptions = {
  ?path:String,
  ?defaultExtension:String,
  ?isDirectory:Bool,
  ?dataFile:String,
  ?skipMappings:Bool
}; 

#if !macro

class Repository<T:Model> {

  final store:Store;
  final options:RepositoryOptions;
  final decoder:(info:Info, data:Dynamic)->T;
  final encoder:(data:T)->Dynamic;
  var cache:Array<T>;

  public function new(store, options, decoder, encoder) {
    this.store = store;
    this.options = options;
    this.decoder = decoder;
    this.encoder = encoder;
  }

  public function getOptions():RepositoryOptions {
    return options;
  }

  public function withOverrides(overrides:RepositoryOptions) {
    return new Repository(store, {
      path: overrides.path != null ? overrides.path : options.path,
      defaultExtension: overrides.defaultExtension != null ? overrides.defaultExtension : options.defaultExtension,
      isDirectory: overrides.isDirectory != null ? overrides.isDirectory : options.isDirectory,
      dataFile: overrides.dataFile != null ? overrides.dataFile : options.dataFile,
      skipMappings: overrides.skipMappings != null ? overrides.skipMappings : options.skipMappings
    }, decoder, encoder);
  }

  public function get(id:String):Promise<T> {
    return store.__load(getPath(id)).next(data -> {
      var model = decoder(prepareInfo(data.info), data.contents);
      if (options.skipMappings) return model;
      return model.__resolveMappings(store, options).next(_ -> model);
    });
  }

  public function select():Promise<Selection<T>> {
    return all().next(models -> new Selection(models));
  }

  public function all():Promise<Array<T>> {
    if (cache == null) {
      return store.__listIds(options.path).next(ids -> Promise.inParallel([
        for (id in ids) {
          if (!options.isDirectory && id.extension() == '') continue;
          get(id);
        }
      ])).next(models -> cache = models);
    }
    return cache;
  }

  public function has(model:T) {
    return get(model.__getId()) != null;
  }

  public function save(model:T):Promise<Bool> {
    invalidateCache();
    var path = getPath(model.__getId());
    return store.__save(
      path,
      resolveExtension(model),
      encoder(model)
    ).next(_ -> {
      // return model.__saveMappings(store, options);
      return true;
    });
  }

  public function remove(model:T):Promise<Bool> {
    invalidateCache();
    // Note: even if this is a directory-based model, we want to remove
    //       the entire dir, not just the dataFile.
    var path = Path
      .join([ options.path, model.__getId() ])
      .withExtension(resolveExtension(model));
    return store.__remove(path);
  }
  
  function prepareInfo(info:Info):Info {
    if (!options.isDirectory) return info;
    return {
      name: info.path[ info.path.length - 1 ],
      path: info.path.slice(0, info.path.length - 1),
      created: info.created,
      modified: info.modified,
      extension: info.extension,
      fullPath: info.fullPath.directory()
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
      return if (options.defaultExtension == null) {
        'txt';
      } else {
        options.defaultExtension;
      }
    }
    return model.__info.extension;
  }

  function invalidateCache() {
    cache = null;
  }

}

#else 

class Repository {}

#end
