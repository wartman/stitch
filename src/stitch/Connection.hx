package stitch;

using tink.CoreApi;

interface Connection {
  public function getInfo(path:String):Promise<Info>;
  public function list(dir:String):Promise<Array<String>>;
  public function read(path:String):Promise<String>;
  public function write(path:String, data:String):Promise<Bool>;
  public function remove(path:String):Promise<Bool>;
}
