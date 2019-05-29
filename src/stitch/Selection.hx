package stitch;

import stitch.error.*;

using Lambda;
using Reflect;
using haxe.io.Path;

enum SortDir {
  Asc;
  Desc;
}

class Selection<T:Model> {

  final store:Store;
  final collection:Collection<T>;
  final models:Array<T>;

  public function new(store, collection, ?models) {
    this.store = store;
    this.collection = collection;
    this.models = models != null ? models : [];
  }

  public function find(id:String) {
    var model = models.find(m -> m.id == id);
    if (model == null) throw new NotFoundError(collection, id);
    return model;
  }

  public function select(cb:(model:T)->Bool) {
    return new Selection(store, collection, models.filter(cb));
  }

  public function all() {
    return models;
  }

  public function first() {
    return models[models.length - 1];
  }

  public function limit(len:Int) {
    return slice(0, len + 1);
  }

  public function slice(pos:Int, ?end:Int) {
    return new Selection(store, collection, models.slice(pos, end));
  }

  public function modify(modifiers:Array<Modifier<T>>) {
    var modified = models.copy();
    for (m in modifiers) {
      modified = m.apply(modified);
    }
    return new Selection(store, collection, modified);
  }

  // Hmm
  public function orderBy(field:String, dir:SortDir = Asc) {
    models.sort((a, b) -> {
      var af = a.getProperty(field);
      var bf = b.getProperty(field);
      return if (af == bf) 0
        else if (af > bf) 1
        else -1;
    });
    if (dir == Desc) models.reverse();
    return this;
  }

  public function has(model:T) {
    return models.has(model);
  }

  public function add(model:T, persist:Bool = false) {
    if (models.has(model)) return false;
    models.push(model);
    if (persist) store.save(model, collection);
    return true;
  }

  public function save(model:T) {
    if (!has(model)) return add(model, true);
    return store.save(model, collection);
  }

  public function remove(model:T, persist:Bool = false) {
    if (!models.has(model)) return false;
    models.remove(model);
    if (persist) store.remove(model, collection);
    return true;
  }

  public function copy() {
    return new Selection(store, collection, models.copy());
  }

  public function children<R:Model>(model:Class<R>, ?path:String):Array<Selection<R>> {
    var targetCollection:Collection<R> = model.getProperty('collection');
    return [ for (m in models) {
      store.get(model, {
        path: Path.join([ collection.path, m.id, path != null ? path : targetCollection.path ]) 
      });
    } ];
  }

}
