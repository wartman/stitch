package stitch.field;

import stitch.Collection;
import stitch.Model;
import stitch.Field;
import stitch.error.NoStoreError;

using haxe.io.Path;
using stitch.ModelTools;

class ChildrenField implements ReadOnlyField<Selection<Dynamic>> {

  @:prop var relation:Class<Model>;
  @:prop @:optional var path:String;
  @:prop @:optional var overrides:CollectionParams;
  final model:Model;
  var value:Selection<Dynamic>;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }
  
  public function get():Selection<Dynamic> {
    if (value == null) fetch();
    return value;
  }
  
  public function getJson():Dynamic {
    return get().all().map(m -> m.toJson());
  }

  function fetch() {
    var store = model.store;
    if (store == null) throw new NoStoreError();
    if (overrides == null) {
      var collection = model.getModelCollection();
      var relCollection = relation.getCollection(); 
      var path = this.path != null ? this.path : relCollection.path;
      overrides = {
        path: Path.join([ collection.path, model.id, path ])
      };
    }
    value = store.get(relation, overrides);
  }

}
