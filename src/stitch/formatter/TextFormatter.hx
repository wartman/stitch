package stitch.formatter;

import haxe.DynamicAccess;
import stitch.Formatter;

using StringTools;

class TextFormatter implements Formatter {

  
  final splitter:String = '---';
  final matcher:EReg;

  public function new(?splitter:String) {
    if (splitter != null) this.splitter = splitter;
    matcher = new EReg("\\s*(?<![\\w\\d-])" + this.splitter + "\\s*(?<![\\w\\d-])\\n*", 'g');
  }

  public function parse(data:String):Dynamic {
    var out:DynamicAccess<Dynamic> = new DynamicAccess();
    var parts = matcher.split(data);
    
    for (part in parts) {
      // Todo: check for errors here.
      var sep = part.indexOf(':');
      var key = part.substr(0, sep).trim();
      var value:Dynamic = part.substr(sep + 1).trim();
      setValue(key, value, out);
    }

    return cast out;
  }

  function setValue(name:String, value:Dynamic, target:DynamicAccess<Dynamic>) {
    name = name.trim();
    if (name.contains('.')) {
      var key = name.substr(0, name.indexOf('.'));
      name = name.substr(name.indexOf('.') + 1);
      if (key.contains('[')) {
        var index = Std.parseInt(key.substr(key.indexOf('[') + 1, key.indexOf(']')).trim());
        key = key.substr(0, key.indexOf('['));
        if (!target.exists(key)) {
          target.set(key, []);
        }
        var out:Array<DynamicAccess<Dynamic>> = target.get(key);
        if (out.length - 1 < index) {
          out.push(new DynamicAccess());
        }
        setValue(name, value, out[index]);
      } else {
        if (!target.exists(key)) {
          target.set(key, new DynamicAccess());
        }
        setValue(name, value, target.get(key));
      }
    } else if (name.endsWith('[]')) {
      name = name.substr(0, name.indexOf('[]')).trim();
      if (!target.exists(name)) {
        target.set(name, []);
      }
      (target.get(name):Array<Dynamic>).push(value);
    } else {
      target.set(name, value);
    }
  }
  
  public function generate(data:Dynamic):String {
    var out:Array<String> = [];
    var obj:DynamicAccess<Dynamic> = data;
    for (name => value in obj) {
      out.push(writeField(name, value));
    }
    return out.join('\n' + splitter + '\n');
  }

  function writeField(name:String, value:Dynamic, ?index:Int) {
    if (Std.is(value, Array)) {
      var items:Array<Dynamic> = value;
      return [ for (index in 0...items.length) 
        writeField(name, items[index], index)
      ].join('\n${splitter}\n');
    }
    // a little iffy:
    if (!Std.is(value, String) && !Std.is(value, Int) && !Std.is(value, Float)) {
      if (index != null) name = '${name}[${index}]';
      return [ for (field => item in (value:DynamicAccess<Dynamic>)) 
        writeField('${name}.${field}', item) 
      ].join('\n${splitter}\n');  
    }
    return if (index != null) '${name}[]: ${value}' else '${name}: ${value}';
  }

}
