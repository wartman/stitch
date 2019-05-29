package stitch;

import stitch.core.PropertyDecorator;
import stitch.core.ReadOnlyPropertyDecorator;
import stitch.core.PropertyBuilder;

interface Field<T> extends PropertyBuilder {
  private final model:Model;
  public function getJson():Dynamic;
}

interface MutableField<T> 
  extends Field<T> 
  extends PropertyDecorator<T> {}

interface ReadOnlyField<T> 
  extends Field<T> 
  extends ReadOnlyPropertyDecorator<T> {}

interface EncodeableField {
  public function encode():String;
}

interface DecodeableField {
  public function decode(document:Document, value:String):Void;
}

interface DecodeableRepeatableField {
  public function decode(document:Document, values:Array<String>):Void;
}

interface PersistantField
  extends EncodeableField
  extends DecodeableField {}
