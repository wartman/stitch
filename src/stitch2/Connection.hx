package stitch2;

interface Connection {
  public function getInfo(path:String):Info;
  public function listInfo(dir:String):Array<Info>;
  public function exists(path:String):Bool;
  public function read(path:String):String;
  public function write(path:String, data:String):Bool;
  public function remove(path:String):Bool;
}
