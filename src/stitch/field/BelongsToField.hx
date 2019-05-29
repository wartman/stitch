package stitch.field;

import stitch.Collection;
import stitch.Field;
import stitch.Model;
import stitch.error.NoStoreError;

class BelongsToField 
  implements MutableField<Model> 
  implements PersistantField
{

  final model:Model;
  @:prop var relation:Class<Model>;
  @:prop @:optional var overrides:CollectionParams;
  var id:String;
  var value:Model;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get():Model {
    if (value == null) fetch();
    return value;
  }

  public function getJson():Dynamic {
    return get().toJson();
  }

  public function set(value:Model):Model {
    return this.value = value;
  }

  public function encode() {
    return value.id;
  }

  public function decode(document:Document, value:String) {
    // Managers are not available while decoding, and 
    // lazy loading is better for this anyway.
    id = value;
  }

  function fetch() {
    if (model.store == null) throw new NoStoreError();
    var model = model.store
      .get(relation, overrides)
      .find(id);
    set(model);
  }

}
