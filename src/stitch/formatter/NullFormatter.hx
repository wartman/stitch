package stitch.formatter;

import stitch.Formatter;

/**
  This formatter is handy in situations where you don't want
  to parse a file (for example, if you're looking for images).
**/
class NullFormatter<T> implements Formatter<T> {
  
  public final defaultExtension:String = 'txt';
  public final allowedExtensions:Array<String> = [ 'txt' ];

  public function new() {}

  public function encode(data:T):String {
    return '';
  }
  
  public function decode(data:String):T {
    return cast {};
  }

}
