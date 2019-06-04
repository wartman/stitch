package stitch.field;

import stitch.Field;
import stitch.Document;

class IntField 
  implements MutableField<Int>
  implements PersistantField  
{

  final model:Model;
  var value:Int = null;

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
    return this.value = value;
  }

  public function encode():String {
    return cast this.value;
  }

  public function decode(document:Document, value:Dynamic) {
    this.set(value);
  }

}
