package stitch2;

abstract Selection<T:Model>(Array<T>) {

  public function iterator():Array<T> {
    return this;
  }

}
