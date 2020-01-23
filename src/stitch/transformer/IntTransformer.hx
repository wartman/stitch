package stitch.transformer;

class IntTransformer {

  public static function __decode(info:Info, data:Dynamic):Int {
    if (Std.is(data, Int)) return data;
    return Std.parseInt(data);
  }

  public static function __encode(data:Int):String {
    return Std.string(data);
  }

}
