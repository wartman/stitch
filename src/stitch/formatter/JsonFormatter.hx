package stitch.formatter;

import haxe.Json;
import stitch.Formatter;

class JsonFormatter implements Formatter {

  public function new() {}

  public function parse(data:String):Dynamic {
    return cast Json.parse(data);
  }
  
  public function generate(data:Dynamic):String {
    return Json.stringify(data);
  }

}
