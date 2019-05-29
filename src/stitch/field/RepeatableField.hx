package stitch.field;

import stitch.*;
import stitch.Field;

class RepeatableField
  implements ReadOnlyField<Array<Dynamic>>
  implements DecodeableRepeatableField
{
  
  @:prop var field:Class<ReadOnlyField<Dynamic>>;
  final model:Model;
  var fields:Array<ReadOnlyField<Dynamic>>;

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function get() {
    return [ for (f in fields) f.get() ];
  }

  public function getJson() {
    return [ for (f in fields) f.getJson() ];
  }

  public function decode(document:Document, values:Array<String>) {
    for (v in values) {
      var f = Type.createInstance(field, [ model ]);
      if (Std.is(f, DecodeableField)) {
        var d:DecodeableField = cast f;
        d.decode(document, v);
      }
      fields.push(f);
    }
  }
  
}
