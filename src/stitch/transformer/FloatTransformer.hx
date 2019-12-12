package stitch.transformer;

class FloatTransformer {

  public static function __decode(info:Info, data:String):Float {
    return Std.parseFloat(data);
  }

  public static function __encode(data:Float):String {
    return Std.string(data);
  }

}
