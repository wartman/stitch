package stitch.field;

import haxe.Json;
import stitch.field.support.*;

using stitch.support.DocumentTools;
using medic.Assert;

class MetaFieldTest {

  public function new() {}

  @test('Decodes json')
  public function testDecode() {
    var data = Json.stringify({ foo: 'foo', bar: 'bar' });
    var field = new MetaField(FieldModel.getModel(), {});
    field.decode(DocumentTools.createDocument(''), data);
    field.get().get('foo').equals('foo');
    field.get().get('bar').equals('bar');
  }
  
  @test('Encodes json')
  public function testEncode() {
    var field = new MetaField(FieldModel.getModel(), {});
    field.decode(DocumentTools.createDocument(''), null);
    field.get().set('foo', 'foo');
    field.get().set('bar', 'bar');
    field.encode().equals('{"foo":"foo","bar":"bar"}');
  }

}
