package stitch.field;

import stitch.*;
import stitch.Field;

using stitch.ModelTools;

/**
  This is similar to other relation fields, like the `HasOneField`,
  however it parses data already present in the current Document
  rather than loading an external Document.
**/
class SubModelField
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
    if (submodel == null) return null;
    return submodel.toJson();
  }

  public function encode() {
    return submodel.encode();
  }

  public function decode(document:Document, value:Dynamic) {
    if (value == null) return;

    var collection = relation.getCollection();
    var doc = new Document({
      name: document.name + '[${collection.path}]',
      path: document.path,

      // Potentially, the contents of this field is using
      // a different Formatter than the parent type and
      // will need to be parsed. In this case, `value`
      // is a string.
      contents: Std.is(value, String) ? value : '',
      
      // Otherwise, we can just use the pased value.
      // If `Document.parsedContents` is not null, it will
      // always be prefered to `contents`.
      parsedContents: Std.is(value, String) ? null : value,
      
      created: document.created,
      modified: document.modified
    });

    submodel = collection.factory(doc);
  }
  
}
