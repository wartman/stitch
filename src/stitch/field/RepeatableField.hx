package stitch.field;

import stitch.*;
import stitch.Field;

class RepeatableField
  implements ReadOnlyField<Array<Dynamic>>
  implements DecodeableRepeatableField
{
  
  @:prop var field:(model:Model)->Field<Dynamic>;
  final model:Model;
  final fields:Array<Field<Dynamic>> = [];

  public function new(model, options) {
    this.model = model;
    setProperties(options);
  }

  public function get():Array<Dynamic> {
    return [ for (f in fields) if (Std.is(f, ReadOnlyField) || Std.is(f, MutableField)) {
      var m:ReadOnlyField<Dynamic> = cast f; 
      m.get();
    } else null ].filter(v -> v != null);
  }

  public function getJson() {
    return [ for (f in fields) f.getJson() ];
  }

  public function decode(document:Document, values:Array<String>) {
    for (v in values) {
      var f = field(model);
      if (Std.is(f, DecodeableField)) {
        var d:DecodeableField = cast f;
        d.decode(document, v);
      }
      fields.push(f);
    }
  }
  
}
