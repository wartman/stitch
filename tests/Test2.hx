import stitch2.*;
import stitch2.connection.MemoryConnection;
import stitch2.formatter.JsonFormatter;

class Test2 {
  
  static function main() {
    var store = new Store(new MemoryConnection([
      'testers' => [
        'one.json' => '{
          "foo": "foo",
          "bar": "bar",
          "sub": {
            "bin": "1",
            "content": "###foo"
          }
        }'
      ]
    ]), [
      'json' => new JsonFormatter()
    ]);
    var testers = store.getRepository(Tester);
    var test = testers.get('one');
    trace(test);
    testers.save(new Tester({
      id: 'two',
      foo: 'bar',
      bar: 'bar',
      sub: new Sub({
        bin: 1,
        content: {
          raw: '##test',
          parsed: ''
        }
      })
    }));
    trace(testers.get('two'));
  }

}

@:repository( path = 'testers' )
class Tester implements Model {
  @:id(info = name, auto) var id:String;
  @:info var created:Date;
  @:info(modified) var updated:Date;
  @:field var foo:String;
  @:field var bar:String;
  @:field var sub:Sub;
  // @:children(path = 'test_subs') var subs:Array<Sub>;
}

class Sub implements Model {
  @:field var bin:Int;
  @:field var content:Markdown;
}
