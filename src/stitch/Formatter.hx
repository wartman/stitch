package stitch;

interface Formatter<T> {
  public final defaultExtension:String;
  public final allowedExtensions:Array<String>; 
  public function encode(data:T):String;
  public function decode(data:String):T;
}
