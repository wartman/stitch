package stitch.field;

import stitch.*;
import stitch.Field;

using Type;

class RepeatableField
  implements ReadOnlyField<Array<Dynamic>>
  implements DecodeableRepeatableField
{
  
  @:prop var field:Class<Field<Dynamic>>;
  @:prop @:optional var options:Dynamic = {};
  final model:Model;
  final fields:Array<Field<Dynamic>> = [];

  public function new(model, ?options) {
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

  public function decode(document:Document, values:Array<Dynamic>) {
    if (values == null) {
      return;
    }
    for (v in values) {
      var f = field.createInstance([ model, options ]);
      if (Std.is(f, DecodeableField)) {
        var d:DecodeableField = cast f;
        d.decode(document, v);
      }
      fields.push(f);
    }
  }
  
}
