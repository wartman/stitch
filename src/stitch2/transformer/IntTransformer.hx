package stitch2.transformer;

class IntTransformer {

  public static function _stitch_decode(info:Info, data:String):Int {
    return Std.parseInt(data);
  }

  public static function _stitch_encode(data:Int):String {
    return Std.string(data);
  }

}
