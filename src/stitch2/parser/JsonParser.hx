package stitch2.parser;

import haxe.Json;
import stitch2.Parser;

class JsonParser implements Parser {

  public function new() {}

  public function parse(data:String):Dynamic {
    return cast Json.parse(data);
  }
  
  public function generate(data:Dynamic):String {
    return Json.stringify(data);
  }

}
