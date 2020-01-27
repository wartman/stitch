package stitch;

import stitch.formatter.*;
import stitch.types.Markdown;
import stitch.connection.MemoryConnection;

using Medic;

class ModelTest implements TestCase {

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
  @async
  public function testFind(done) {
    var store = getStore();
    store.getRepository(TestModel).get('one').handle(o -> switch o {
      case Success(one):
        one.id.equals('one');
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
  }

  @test('Parses inline models')
  @async
  public function testInlineModel(done) {
    var store = getStore();
    store.getRepository(TestModel).get('one').handle(o -> switch o {
      case Success(one):
        Std.is(one.sub, Sub).isTrue();
        one.sub.bin.equals(1);
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
  }

  @test('Loads children')
  @async
  public function testChildren(done) {
    getStore().getRepository(TestModel).get('one').handle(o -> switch o {
      case Success(one):
        one.subs.length.equals(1);
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
  }

  @test('Finds @:belongsTo relations')
  @async
  public function testBelongsTo(done) {
    getStore().getRepository(TestModel).get('one').handle(o -> switch o {
      case Success(one):
        Std.is(one.author, User).isTrue();
        one.author_id.equals(one.author.id);
        one.author.name.equals('Fred');
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
  }

  @test('Finds @:hasMany relations')
  @async
  public function testHasMany(done) {
    getStore().getRepository(User).get('fred').handle(o -> switch o {
      case Success(fred):
        Std.is(fred.testers, Array).isTrue();
        fred.testers.length.equals(2);
        fred.testers[0].id.equals('one');
        fred.testers[1].id.equals('two');
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
  }

  @test('Inline arrays of models work')
  @async
  public function testInlineArray(done) {
    getStore().getRepository(TestModel).get('one').handle(o -> switch o {
      case Success(one):
        one.inlineSubs.length.equals(2);
        one.inlineSubs[0].bin.equals(2);
        one.inlineSubs[1].bin.equals(3);
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
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

