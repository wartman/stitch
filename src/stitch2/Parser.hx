package stitch2;

/**
  Parsers take non-haxe data and transform them into simple objects.
**/
interface Parser {
  public function parse(data:String):Dynamic;
  public function generate(data:Dynamic):String;
}
