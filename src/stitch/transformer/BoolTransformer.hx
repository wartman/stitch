package stitch.transformer;

class BoolTransformer {

  public static function __decode(info:Info, data:Dynamic):Bool {
    if (Std.is(data, Bool)) return data;
    return switch data {
      case 'true': true;
      default: false;
    }
  }

  public static function __encode(data:Bool):String {
    return if (data) 'true' else 'false';
  }

}
