package stitch.field;

import stitch.Field;
import stitch.Document;

class DocumentField 
  implements ReadOnlyField<Dynamic>
  implements DecodeableField  
{

  final model:Model;
  @:prop var handler:(document:Document)->Dynamic;
  @:prop @:optional var fallback:()->Dynamic;
  var value:Dynamic;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get() {
    if (value == null && fallback != null) return fallback();
    return value;
  }
  
  public function getJson():Dynamic {
    return get();
  }

  public function decode(document:Document, value:String) {
    this.value = handler(document);
  }

}
