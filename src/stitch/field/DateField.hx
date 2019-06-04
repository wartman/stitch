package stitch.field;

import stitch.Field;
import stitch.Document;

class DateField 
  implements MutableField<Date>
  implements PersistantField
{

  final model:Model;
  var value:Date;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get() {
    return value;
  }
  
  public function getJson():Dynamic {
    return get().toString();
  }

  public function set(value:Date) {
    return this.value = value;
  }

  public function encode() {
    return value.toString();
  }

  public function decode(document:Document, value:Dynamic):Void {
    if (value == null) { 
      set(Date.now());
      return;
    }
    set(Date.fromString(value));
  }

}
