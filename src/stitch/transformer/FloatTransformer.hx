package stitch.transformer;

class FloatTransformer {

  public static function __decode(info:Info, data:Dynamic):Float {
    if (Std.is(data, Float)) return data;
    return Std.parseFloat(data);
  }

  public static function __encode(data:Float):String {
    return Std.string(data);
  }

}
