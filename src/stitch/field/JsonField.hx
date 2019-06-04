package stitch.field;

import haxe.Json;
import haxe.DynamicAccess;
import stitch.Field;
import stitch.*;

/**
  As the name suggests, this field handles encoding and decoding
  arbitrary JSON data in a field.
**/
class JsonField 
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

  public function decode(document:Document, value:Dynamic) {
    if (value == null) {
      data = new DynamicAccess();
    } else {
      data = Json.parse(value);
    }
  }

}
