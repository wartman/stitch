package stitch.transformer;

class IntTransformer {

  public static function __decode(info:Info, data:String):Int {
    return Std.parseInt(data);
  }

  public static function __encode(data:Int):String {
    return Std.string(data);
  }

}
