package stitch2;

using Lambda;
using haxe.ds.Option;

enum SortDir {
  Asc;
  Desc;
}

class Selection<T:Model> {

  final repository:Repository<T>;
  final models:Array<T>;

  public function new(repository, ?models) {
    this.repository = repository;
    this.models = models != null ? models : [];
  }

  public function find(id:String):Option<T> {
    var model = models.find(m -> m.__getId() == id);
    return if (model == null) {
      None;
    } else {
      Some(model);
    }
  }

  public function result():Option<Array<T>> {
    return if (models.length == 0) {
      None;
    } else {
      Some(models);
    }
  }

  public function where(query:(model:T)->Bool) {
    return new Selection(repository, models.filter(query));
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
    return new Selection(repository, models.slice(pos, end));
  }

}
