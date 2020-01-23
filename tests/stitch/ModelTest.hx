package stitch;

import stitch.formatter.*;
import stitch.types.Markdown;
import stitch.connection.MemoryConnection;

using medic.Assert;

class ModelTest {

  public function new() {}

  function getStore() {
    var connection = new MemoryConnection([
      'tests' => [
        'one' => [
          '_data.json' => '{
            "foo": "foo",
            "bar": "bar",
            "author_id": "fred",
            "sub": {
              "bin": "1",
              "content": "###foo"
            },
            "inlineSubs": [
              { "bin": 2, "content": "..." },
              { "bin": 3, "content": "..." }
            ]
          }'
        ],
        'one/test_subs' => [
          'subone.json' => '{
            "bin": "3",
            "content": "##bar"
          }'
        ],
        'two' => [
          '_data.toml' => '
            foo = "two"
            bar = "bin"
            author_id = "fred"
            sub.bin = "2"
            sub.content = """
Foo
---
- Is a bar
- Not a bin
            """
          '
        ]
      ],
      'users' => [
        'fred.json' => '{
          "name": "Fred",
          "lastName": "Fredson"
        }',
        'ben.toml' => '
          name = "Ben"
          lastName = "Benson"
        ',
        'random.txt' => '
          name: Rando
          ---
          lastName: Randson
        '
      ]
    ]);
    return new Store(connection, [
      'json' => new JsonFormatter(),
      'toml, tml' => new TomlFormatter(),
      'txt' => new TextFormatter()
    ]);
  }

  @test('Info is applied correctly')
  public function testInfo() {
    var store = getStore();
    store.getRepository(TestModel).getOptions().path.equals('tests');
  }

  @test('Finds models by id')
  public function testFind() {
    var store = getStore();
    var one = store.getRepository(TestModel).get('one');
    one.id.equals('one');
  }

  @test('Parses inline models')
  public function testInlineModel() {
    var store = getStore();
    var one = store.getRepository(TestModel).get('one');
    Std.is(one.sub, Sub).isTrue();
    one.sub.bin.equals(1);
  }

  @test('Loads children lazily')
  public function testChildren() {
    var one = getStore().getRepository(TestModel).get('one');
    one.subs.length.equals(1);
  }

  @test('Finds @:belongsTo relations')
  public function testBelongsTo() {
    var one = getStore().getRepository(TestModel).get('one');
    Std.is(one.author, User).isTrue();
    one.author_id.equals(one.author.id);
    one.author.name.equals('Fred');
  }

  @test('Finds @:hasMany relations')
  public function testHasMany() {
    var fred = getStore().getRepository(User).get('fred');
    Std.is(fred.testers, Array).isTrue();
    fred.testers.length.equals(2);
    fred.testers[0].id.equals('one');
    fred.testers[1].id.equals('two');
  }

  @test('Inline arrays of models work')
  public function testInlineArray() {
    var one = getStore().getRepository(TestModel).get('one');
    one.inlineSubs.length.equals(2);
    one.inlineSubs[0].bin.equals(2);
    one.inlineSubs[1].bin.equals(3);
  }

}

@:repository( 
  path = 'tests',
  isDirectory = true,
  defaultExtension = 'json'
)
class TestModel implements Model {
  @:id(info, auto) var id:String;
  @:info var created:Date;
  @:info(modified) var updated:Date;
  @:field var foo:String;
  @:field var bar:String;
  @:field var sub:Sub;
  @:field @:optional var inlineSubs:Array<Sub>;
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
  @:hasMany(on = 'author_id') var testers:Array<TestModel>;
}

