package stitch;

class IdTools {

  static var ids:Int = 0;

  public static function getUniqueId(prefix:String) {
    return prefix + '_' + ids++;
  }

}
