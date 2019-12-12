package stitch;

interface Formatter {
  public function parse(data:String):Dynamic;
  public function generate(data:Dynamic):String;
}
