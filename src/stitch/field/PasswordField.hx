package stitch.field;

import stitch.Model;
import stitch.Field;
import stitch.error.NoStoreError;

class PasswordField 
  implements MutableField<String>
  implements PersistantField
{

  final model:Model;
  @:prop @:optional var salt:String;
  var value:String;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function set(value) {
    return this.value = value;
  }

  public function get() {
    return value;
  }

  public function encode() {
    return get();
  }

  public function getJson() {
    return null;
  }

  public function decode(document:Document, value:String) {
    this.set(value);
  }

  @:deprecated('Bad hashing -- revise!')
  public function check(password:String) {
    if (value == password) {
      // The password isn't hashed! lets do that and overwrite the
      // value in the folder.
      value = haxe.crypto.Sha256.encode(value);
      if (model.store == null) throw new NoStoreError();
      model.store.save(model); // This feels dirty.
    }
    return value == haxe.crypto.Sha256.encode(password);
  }

}
