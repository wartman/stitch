package stitch;

import stitch.error.ModelNotFoundError;

using Lambda;
using tink.CoreApi;

// // enum SortDir {
// //   Asc;
// //   Desc;
// // }

abstract Selection<T:Model>(Promise<Array<T>>) {

  public function new(pending) {
    this = pending;
  }
  
  public function where(query:(model:T)->Bool) { 
    return new Selection(this.next(ms -> ms.filter(query)));
  }

  public function all():Promise<Array<T>> {
    return this;
  }

  public function find(id:String) {
    return this.next(models -> switch models.find(m -> m.__getId() == id) {
      case null: new ModelNotFoundError('model', id);
      case model: model;
    });
  }

  public function first() {
    return this.next(m -> m[m.length - 1]);
  }

  public function limit(len:Int) {
    return slice(0, len + 1);
  }

  public function slice(pos:Int, ?end:Int) {
    return new Selection(this.next(m -> m.slice(pos, end)));
  }


}
