package stitch.formatter;

using medic.Assert;
using StringTools;

class TextFormatterTest {

  public function new() {}

  @test('Decodes strings correctly')
  public function testDecode() {
    var formatter = new TextFormatter();
    var obj:{ foo:String, bar:String, bin:String } = formatter.decode('
foo: foo
---
bar: bar
---
bin: bin
    ');
    obj.foo.equals('foo');
    obj.bar.equals('bar');
    obj.bin.equals('bin');
  }

  @test('Only splits on matching strings')
  public function testSplitter() {
    var formatter = new TextFormatter();
    var obj:{ foo:String, content:String } = formatter.decode('
foo: foo
---
content:

SomeTitle
---------
This is ok!
    ');
    obj.foo.equals('foo');
    obj.content.equals('
SomeTitle
---------
This is ok!'.trim());
  }

  @test('Encodes data correctly')
  public function testEncode() {
    var data = {
      foo: 'foo',
      bar: 'bar',
      bin: 'bin'
    };
    var formatter = new TextFormatter();
    // Note: getting around the dang `\r` in windows here:
    formatter.encode(data).equals([
      'foo: foo',
      'bar: bar',
      'bin: bin'
    ].join('\n---\n'));
  }

  @test('Handles repeatable fields')
  public function testRepeat() {
    var formatter = new TextFormatter();
    var obj:{ foo:Array<String> } = formatter.decode('
foo[]: one
---
foo[]: two
---
foo[]: three
    ');
    obj.foo.length.equals(3);
  }

}
