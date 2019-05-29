package stitch.formatter;

import haxe.Json;
import stitch.Formatter;

class JsonFormatter<T> implements Formatter<T> {
  
  public final defaultExtension:String = 'json';
  public final allowedExtensions:Array<String> = [ 'json' ];

  public function new() {}

  public function encode(data:T):String {
    return Json.stringify(data);
  }
  
  public function decode(data:String):T {
    return cast Json.parse(data);
  }

}