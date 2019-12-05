package stitch2.formatter;

import haxe.Json;
import stitch2.Formatter;

class JsonFormatter implements Formatter {

  public function new() {}

  public function parse(data:String):Dynamic {
    return cast Json.parse(data);
  }
  
  public function generate(data:Dynamic):String {
    return Json.stringify(data);
  }

}
