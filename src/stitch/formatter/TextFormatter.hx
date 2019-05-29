package stitch.formatter;

import haxe.DynamicAccess;
import stitch.Formatter;

using Reflect;
using StringTools;

class TextFormatter<T> implements Formatter<T> {

  public final defaultExtension:String = 'txt';
  public final allowedExtensions:Array<String> = [ 'txt' ];

  final splitter:String = '---';
  final matcher:EReg;

  public function new(?splitter:String) {
    if (splitter != null) this.splitter = splitter;
    matcher = new EReg("\\n" + this.splitter + "\\s\\n*", 'g');
  }

  public function encode(data:T):String {
    var out:Array<String> = [];
    for (field in Reflect.fields(data)) {
      out.push('${field}: ${Reflect.getProperty(data, field)}');
    }
    return out.join('\n' + splitter + '\n');
  }

  public function decode(data:String):T {
    var out = new DynamicAccess();
    var parts = matcher.split(data);
    for (part in parts) {
      // Todo: check for errors here.
      var sep = part.indexOf(':');
      var key = part.substr(0, sep).trim();
      var value = part.substr(sep + 1).trim();
      out.set(key, value);
    }
    return cast out;
  }

}
