package stitch;

interface Connection {
  public function list(dir:String):Array<String>;
  public function exists(path:String):Bool;
  public function read(path:String):Document;
  public function write(path:String, content:String):Bool;
  public function remove(path:String):Bool;
}
