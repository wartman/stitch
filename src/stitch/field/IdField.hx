package stitch.field;

import stitch.Field;
import stitch.Document;

class IdField 
  implements MutableField<String> 
  implements DecodeableField  
{

  final model:Model;
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

  public function set(value:String) {
    value = format(value);
    return this.value = value;
  }

  public function decode(document:Document, value:Dynamic) {
    set(document.name);
  }

  function format(value:String) {
    if (value == null) return null;
    return value;
  }

}
