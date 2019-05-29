package stitch;

import haxe.ds.Map;
import stitch.Collection;
import stitch.error.*;

using Type;
using Reflect;

@:allow(stitch)
class Store {

  final connection:Connection;
  final cache:Map<String, Array<Dynamic>> = [];

  public function new(connection) {
    this.connection = connection;
  }

  public function flushCache() {
    for (key in cache.keys()) cache.remove(key);
  }

  public function get<T:Model>(model:Class<T>, ?overrides:CollectionParams) {
    var collection:Collection<T> = model.getProperty('collection');
    if (overrides != null) collection = collection.withOverrides(overrides);
    var name = getCacheName(collection);
    if (!cache.exists(name)) {
      // Todo: there is probably a more effiecent way to do this,
      //       but it isn't a problem -- yet.
      //       How will it function with hundreds of pages though?
      var models = loadCollection(collection);
      cache.set(name, models);
    }
    return new Selection(this, collection, cast cache.get(name));
  }

  public function save<T:Model>(model:T, ?collection:Collection<T>) {
    if (collection == null) collection = model.getClass().getProperty('collection');
    if (!model.exists()) throw new CannotSaveError(collection);
    var name = getCacheName(collection);
    cache.remove(name);
    return collection.resource.save(connection, collection, model);
  }

  public function remove<T:Model>(model:T, ?collection:Collection<T>) {
    if (!model.exists()) return false;
    if (collection == null) collection = model.getClass().getProperty('collection');
    var name = getCacheName(collection);
    cache.remove(name);
    return collection.resource.remove(connection, collection, model);
  }

  function getCacheName<T:Model>(collection:Collection<T>) {
    var name = collection.getClass().getClassName();
    return '${name}_${collection.path}';
  }

  function loadCollection<T:Model>(collection:Collection<T>):Array<T> {
    return collection.resource.list(connection, collection)
      .map(id -> loadModel(collection, id))
      .filter(m -> m != null);
  }

  function loadModel<T:Model>(collection:Collection<T>, id:String):T {
    return switch collection.resource.load(connection, collection, id)  {
      case Some(model): 
        model.connect(this);
        model;
      case None: 
        throw new NotFoundError(collection, id);
        null; 
    }
  }

}
