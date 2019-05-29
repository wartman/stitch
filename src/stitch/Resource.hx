package stitch;

import haxe.ds.Option;

interface Resource<T:Model> {
  public function locate(cnx:Connection, collection:Collection<T>, id:String):Option<String>;
  public function list(cnx:Connection, collection:Collection<T>):Array<String>;
  public function load(cnx:Connection, collection:Collection<T>, id:String):Option<T>;
  public function save(cnx:Connection, collection:Collection<T>, model:T):Bool;
  public function remove(cnx:Connection, collection:Collection<T>, model:T):Bool;
}
