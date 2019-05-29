package stitch.formatter;

import haxe.DynamicAccess;
import stitch.Formatter;

using Reflect;
using StringTools;

/**
  A simple key/value format.
  ```
  key: some value
  ---
  repeatable-key[]: a
  ---
  repeatable-key[]: b
  ```
**/
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
    var out:DynamicAccess<Dynamic> = new DynamicAccess();
    var parts = matcher.split(data);
    for (part in parts) {
      // Todo: check for errors here.
      var sep = part.indexOf(':');
      var key = part.substr(0, sep).trim();
      var value = part.substr(sep + 1).trim();
      
      if (key.endsWith('[]')) {
        key = key.substr(0, key.indexOf('[]'));
        if (!out.exists(key)) {
          out.set(key, []);
        }
        var data:Array<Dynamic> = out.get(key);
        // todo: ensure that data is an array
        data.push(value);
      } else {
        out.set(key, value);
      }
    }
    return cast out;
  }

}
