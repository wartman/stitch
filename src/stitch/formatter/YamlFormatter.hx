package stitch.formatter;

import yaml.Parser;
import yaml.Yaml;
import stitch.Formatter;

class YamlFormatter implements Formatter {
  
  public function new() {}
  
  public function parse(data:String):Dynamic {
    return Yaml.parse(data, Parser.options().useObjects());
  }
  
  public function generate(data:Dynamic):String {
    return Yaml.render(data);
  }

}
