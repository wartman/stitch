package stitch.field;

import stitch.Field;
import stitch.Document;

class StringField 
  implements MutableField<String>
  implements PersistantField  
{

  final model:Model;
  @:prop @:optional var formatter:(value:String)->String;
  @:prop @:optional var validate:(value:String)->Bool;
  var value:String = '';

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get() {
    return value;
  }

  public function getJson():Dynamic {
    return get();
  }

  public function set(value) {
    if (validate != null) {
      if (!validate(value)) {
        // do a thing??
      }
    }
    if (formatter != null) value = formatter(value);
    return this.value = value;
  }

  public function encode() {
    return this.value;
  }

  public function decode(document:Document, value:String) {
    this.set(value);
  }

}
