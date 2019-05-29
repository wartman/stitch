package stitch.field;

import stitch.*;
import stitch.Field;

using stitch.ModelTools;

/**
  This is similar to other relation fields, like the `HasOneField`,
  however it parses data already present in the current Document
  rather than loading an external Document.
**/
class InlineModelField
  implements ReadOnlyField<Model>
  implements PersistantField
{

  @:prop var relation:Class<Model>;
  final model:Model;
  var submodel:Model;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function get() {
    return submodel;
  }

  public function getJson():Dynamic {
    return submodel.toJson();
  }

  public function encode() {
    return submodel.encode();
  }

  public function decode(document:Document, value:String) {
    var collection = relation.getCollection();
    var doc = new Document({
      name: document.name + '[child]',
      path: document.path,
      contents: value,
      created: document.created,
      modified: document.modified
    });
    submodel = collection.factory(doc);
  }
  
}
