package stitch2.transformer;

class BoolTransformer {

  public static function __decode(info:Info, data:String):Bool {
    return switch data {
      case 'true': true;
      default: false;
    }
  }

  public static function __encode(data:Bool):String {
    return if (data) 'true' else 'false';
  }

}
