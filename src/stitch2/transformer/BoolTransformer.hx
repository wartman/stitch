package stitch2.transformer;

class BoolTransformer {

  public static function _stitch_decode(info:Info, data:String):Bool {
    return switch data {
      case 'true': true;
      default: false;
    }
  }

  public static function _stitch_encode(data:Bool):String {
    return if (data) 'true' else 'false';
  }

}
