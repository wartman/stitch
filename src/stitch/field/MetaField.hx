package stitch.field;

import haxe.Json;
import haxe.DynamicAccess;
import stitch.Field;
import stitch.*;

class MetaField 
  implements ReadOnlyField<DynamicAccess<String>>
  implements PersistantField 
{

  final model:Model;
  var data:DynamicAccess<String>;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function get() {
    return data;
  }

  public function getJson() {
    return get();
  }

  public function encode() {
    return Json.stringify(data);
  }

  public function decode(document:Document, value:String) {
    if (value == null) {
      data = new DynamicAccess();
    } else {
      data = Json.parse(value);
    }
  }

}
