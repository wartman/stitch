package stitch.field;

import stitch.Collection;
import stitch.Field;
import stitch.Model;
import stitch.Modifier;
import stitch.error.NoStoreError;

using Reflect;

class HasManyField implements ReadOnlyField<Array<Model>> {

  final model:Model;
  @:prop var relation:Class<Model>;
  @:prop var field:String;
  @:prop @:optional var modifiers:Array<Modifier<Model>>;
  @:prop @:optional var overrides:CollectionParams;
  var value:Array<Model>;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get():Array<Model> {
    if (value == null) fetch();
    return value;
  }
  
  public function getJson():Dynamic {
    return get().map(m -> m.toJson());
  }

  function fetch() {
    if (model.store == null) throw new NoStoreError();
    var selection = model.store
      .get(relation, overrides)
      .select(m -> m.getProperty(field) == model.id);
    if (modifiers != null) {
      selection = selection.modify(modifiers);
    }
    value = selection.all();
  }

}
