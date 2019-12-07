import stitch2.*;
import stitch2.connection.MemoryConnection;
import stitch2.formatter.JsonFormatter;

class Test2 {
  
  static function main() {
    var store = new Store(new MemoryConnection([
      'testers' => [
        'one' => [
          '_data.json' => '{
            "foo": "foo",
            "bar": "bar",
            "sub": {
              "bin": "1",
              "content": "###foo"
            }
          }'
        ],
        'one/test_subs' => [
          'subone.json' => '{
            "bin": "3",
            "content": "##bar"
          }'
        ]
      ]
    ]), [
      'json' => new JsonFormatter()
    ]);
    var testers = store.getRepository(Tester);
    var test = testers.get('one');
    trace(test);
    trace(test.subs);

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
      }),
      subs: [
        new Sub({
          key: 'three',
          bin: 1,
          content: {
            raw: '##test',
            parsed: ''
          }
        }),
        new Sub({
          key: 'four',
          bin: 4,
          content: {
            raw: '##testear',
            parsed: ''
          }
        })
      ]
    }));
    trace(testers.get('two').subs);
  }

}

@:repository( 
  path = 'testers',
  isDirectory = true,
  defaultExtension = 'json'
)
class Tester implements Model {
  @:id(info, auto) var id:String;
  @:info var created:Date;
  @:info(modified) var updated:Date;
  @:field var foo:String;
  @:field var bar:String;
  @:field var sub:Sub;
  @:children(path = 'test_subs') var subs:Array<Sub>;
}

class Sub implements Model {
  @:id(info, auto) var key:String;
  @:field var bin:Int;
  @:field var content:Markdown;
}
