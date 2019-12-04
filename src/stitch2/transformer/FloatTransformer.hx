package stitch2.transformer;

class FloatTransformer {

  public static function _stitch_decode(info:Info, data:String):Float {
    return Std.parseFloat(data);
  }

  public static function _stitch_encode(data:Float):String {
    return Std.string(data);
  }

}
