package stitch.formatter;

using medic.Assert;
using StringTools;

class TextFormatterTest {

  public function new() {}

  @test('Decodes strings correctly')
  public function testDecode() {
    var formatter = new TextFormatter();
    var obj:{ foo:String, bar:String, bin:String } = formatter.parse('
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
    var obj:{ foo:String, content:String } = formatter.parse('
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
      This is ok!
    '.trim());
  }

  @test('Encodes data correctly')
  public function testEncode() {
    var data = {
      foo: 'foo',
      bar: 'bar',
      bin: 'bin',
      bax: [
        'a',
        'b'
      ],
      bif: {
        bar: [ 'yay' ]
      },
      baf: [
        { value: 'one' },
        { value: 'two' }
      ]
    };
    var formatter = new TextFormatter();
    formatter.generate(data).equals('foo: foo\n---\nbar: bar\n---\nbin: bin\n---\nbax[]: a\n---\nbax[]: b\n---\nbif.bar[]: yay\n---\nbaf[0].value: one\n---\nbaf[1].value: two'.trim());
  }

  @test('Handles dotted fields')
  public function testDotted() {
    var formatter = new TextFormatter();
    var obj:{ foo:{ bar:String, bin:String } } = formatter.parse('
foo.bar: one
---
foo.bin: two
    ');
    obj.foo.bar.equals('one');
    obj.foo.bin.equals('two');
  }

  @test('Handles repeatable fields')
  public function testRepeat() {
    var formatter = new TextFormatter();
    var obj:{ foo:Array<String> } = formatter.parse('
foo[]: one
---
foo[]: two
---
foo[]: three
    ');
    obj.foo.length.equals(3);
  }

  @test('Handles dotted repeatable fields')
  public function testDottedRepeat() {
    var formatter = new TextFormatter();
    var obj:{ foo:{ bar:Array<String> } } = formatter.parse('
foo.bar[]: one
---
foo.bar[]: two
---
foo.bar[]: three
    ');
    obj.foo.bar.length.equals(3);
  }

  @test('Handles repeatable dotted fields')
  public function testRepeatDotted() {
    var formatter = new TextFormatter();
    var obj:{ foo:Array<{ bar:String }> } = formatter.parse('
foo[0].bar: one
---
foo[1].bar: two
---
foo[2].bar: three
    ');
    obj.foo.length.equals(3);
    obj.foo[0].bar.equals('one');
    obj.foo[1].bar.equals('two');
    obj.foo[2].bar.equals('three');
  }

}
