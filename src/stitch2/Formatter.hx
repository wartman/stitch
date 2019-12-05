package stitch2;

interface Formatter {
  public function parse(data:String):Dynamic;
  public function generate(data:Dynamic):String;
}
