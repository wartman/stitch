package stitch.field;

using medic.Assert;
import stitch.field.support.*;

using stitch.support.DocumentTools;

class RepeatableFieldTest {
  
  public function new() {}

  @test('Is repeatable')
  public function testDecode() {
    var data = [ 'a', 'b' ];
    var field = new RepeatableField(FieldModel.getModel(), {
      field: StringField
    });
    field.decode(''.createDocument(), data);
    var values:Array<String> = cast field.get();
    values.length.equals(2);
    values[0].equals('a');
    values[1].equals('b');
  }

}
