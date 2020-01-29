package stitch;

using haxe.io.Path;

#if !macro
  using tink.CoreApi;
  using Lambda;
#end

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
  var locked:Bool = false;
  var later:Signal<Noise>;
  var cache:Array<T>;
  var modified:Date;

  public function new(store, options, decoder, encoder, ?cache) {
    this.store = store;
    this.options = options;
    this.decoder = decoder;
    this.encoder = encoder;
    this.cache = cache;
  }

  public function getOptions():RepositoryOptions {
    return options;
  }

  public function withOverrides(overrides:RepositoryOptions):Repository<T> {
    return new Repository(
      store, 
      {
        path: overrides.path != null ? overrides.path : options.path,
        defaultExtension: overrides.defaultExtension != null ? overrides.defaultExtension : options.defaultExtension,
        isDirectory: overrides.isDirectory != null ? overrides.isDirectory : options.isDirectory,
        dataFile: overrides.dataFile != null ? overrides.dataFile : options.dataFile,
      },
      decoder, 
      encoder,
      // This ensures that relations don't cause endless loops, as parent models that
      // have already been found will be cached. This may cause other issues though --
      // consider if there are better options.
      (overrides.path == null || overrides.path == options.path) ? cache : null
    );
  }

  public function get(id:String):Promise<T> {
    return all().next(models -> return models.find(m -> m.__getId() == id));
  }

  public function select():Selection<T> {
    return new Selection(all());
  }

  public function all():Promise<Array<T>> {
    if (locked) {
      var promise = Promise.trigger();
      later.handle(_ -> all().handle(o -> promise.trigger(o)));
      return promise;
    }

    if (cache == null) {
      locked = true;
      var trigger = Signal.trigger();
      later = trigger.asSignal();
      cache = [];
      return store.__listIds(options.path).next(ids -> Promise.inParallel([
        for (id in ids) {
          if (!options.isDirectory && id.extension() == '') continue;
          loadModel(id);
        }
      ])).next(models -> {
        trigger.trigger(Noise);
        trigger.clear();
        later = null;
        locked = false;
        models;
      });
    }

    // return cache;

    return wasModified().next(modified -> {
      if (modified) {
        invalidateCache();
        return all();
      }
      return cache;
    });
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

  // not sure about this tbh
  function wasModified() {
    return store.connection.getInfo(options.path).next(info -> {
      if (modified == null) {
        modified = info.modified;
        return false;
      }
      return modified.getTime() != info.modified.getTime(); 
    });
  }

  function loadModel(id:String):Promise<T> {
    return store.__load(getPath(id)).next(data -> {
      var model = decoder(prepareInfo(data.info), data.contents);
      cache.push(model);
      return model.__resolveMappings(store, options).next(_ -> model);
    });
  }


}

#else 

class Repository {}

#end
