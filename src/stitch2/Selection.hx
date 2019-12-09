package stitch2;

using Lambda;
using haxe.ds.Option;

// enum SortDir {
//   Asc;
//   Desc;
// }

abstract Selection<T:Model>(Array<T>) {

  public inline function new(models) {
    this = models;
  }

  public function find(id:String):Option<T> {
    var model = this.find(m -> m.__getId() == id);
    return if (model == null) {
      None;
    } else {
      Some(model);
    }
  }

  public function result():Option<Array<T>> {
    return if (this.length == 0) {
      None;
    } else {
      Some(this);
    }
  }

  public function where(query:(model:T)->Bool) {
    return new Selection(this.filter(query));
  }

  public inline function all():Array<T> {
    return this;
  }

  public function first() {
    return this[this.length - 1];
  }

  public function limit(len:Int) {
    return slice(0, len + 1);
  }

  public function slice(pos:Int, ?end:Int) {
    return new Selection(this.slice(pos, end));
  }

}
