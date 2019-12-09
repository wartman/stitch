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
            "author_id": "fred",
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
      ],
      'users' => [
        'fred.json' => '{
          "name": "fred",
          "lastName": "fredson"
        }'
      ]
    ]), [
      'json' => new JsonFormatter()
    ]);
    var testers = store.getRepository(Tester);
    var test = testers.get('one');
    trace(test.subs);
    trace(test);
    trace(test.sub.content);
    trace(test.author);
    trace(test.author.testers);

    testers.save(new Tester({
      id: 'two',
      foo: 'bar',
      bar: 'bar',
      author_id: 'fred',
      // author: store.getRepository(User).get('fred'),
      sub: new Sub({
        bin: 1,
        content: '##test'
      }),
      subs: [
        new Sub({
          key: 'three',
          bin: 1,
          content: '##test'
        }),
        new Sub({
          key: 'four',
          bin: 4,
          content:'##testear'
        })
      ]
    }));
    trace(testers.get('two'));
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
  @:belongsTo var author:User;
}

class Sub implements Model {
  @:id(info, auto) var key:String;
  @:field var bin:Int;
  @:field var content:Markdown;
}

@:repository(
  path = 'users',
  defaultExtension = 'json'
)
class User implements Model {
  @:id(info, auto) var id:String;
  @:info var created:Date;
  @:info(modified) var updated:Date;
  @:field var name:String;
  @:field var lastName:String;
  @:hasMany(on = 'author_id') var testers:Array<Tester>;
}
