package stitch2.formatter;

import Toml;
import stitch2.Formatter;

class TomlFormatter implements Formatter {
  
  public function new() {}
  
  public function parse(data:String):Dynamic {
    return Toml.parse(data);
  }
  
  public function generate(data:Dynamic):String {
    return Toml.generate(data);
  }

}
