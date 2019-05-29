package stitch.field;

import stitch.Collection;
import stitch.Field;
import stitch.Model;
import stitch.error.NoStoreError;

using Reflect;

class HasOneField implements ReadOnlyField<Model> {

  final model:Model;
  @:prop var relation:Class<Model>;
  @:prop var field:String;
  @:prop @:optional var overrides:CollectionParams;
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

  function fetch() {
    if (model.store == null) throw new NoStoreError();
    value = model.store
      .get(relation, overrides)
      .select(m -> m.getProperty(field) == model.id)
      .first();
  }

}
