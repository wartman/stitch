package stitch;

interface Modifier<T:Model> {
  public function apply(query:Array<T>):Array<T>;
}
