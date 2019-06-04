package stitch.field;

import stitch.Field;
import stitch.Model;
import stitch.Document;

class CustomField
  implements ReadOnlyField<Dynamic>
  implements PersistantField
{

  @:prop var decoder:(document:Document, value:String)->Dynamic;
  @:prop var encoder:(value:Dynamic)->Dynamic;
  final model:Model;
  var value:Dynamic;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function get() {
    return value;
  }

  public function getJson() {
    return get();
  }

  public function encode() {
    return encoder(value);
  }

  public function decode(document:Document, value:Dynamic) {
    this.value = decoder(document, value);
  }

}
