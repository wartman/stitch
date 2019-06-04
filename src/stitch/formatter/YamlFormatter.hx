package stitch.formatter;

import yaml.Parser;
import yaml.Yaml;
import stitch.Formatter;

class YamlFormatter<T> implements Formatter<T> {
  
  public final defaultExtension:String = 'yml';
  public final allowedExtensions:Array<String> = [ 'yml', 'yaml' ];

  public function new() {}

  public function encode(data:T):String {
    return Yaml.render(data);
  }
  
  public function decode(data:String):T {
    return cast Yaml.parse(data, Parser.options().useObjects());
  }

}