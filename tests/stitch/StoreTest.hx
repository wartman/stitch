package stitch;

import stitch.formatter.TextFormatter;
import stitch.connection.MemoryConnection;

using Medic;

// Note: this is more of a Repository test. It's a holdover
//       from the old Store.
class StoreTest implements TestCase {

  public function new() {}

  var store:Store;

  @before
  public function createStore() {
    var connection = new MemoryConnection([
      'value/foo.txt' => 'value: foo',
      'value/bar.txt' => 'value: bar',
      // Note: these folders are here to trip up the store.
      //       Hopefully, the Repository won't load them by mistake.
      'value/foo/value' => [
        'foo.txt' => 'value: foo',
        'bar.txt' => 'value: bar'
      ],
      'value/foo/custom' => [
        'foo.txt' => 'value: foo',
        'bar.txt' => 'value: bar'
      ],
      'value/bar/custom' => [
        'foo.txt' => 'value: foo'
      ]
    ]);
    store = new Store(connection, [
      'txt' => new TextFormatter()
    ]);
  }

  @test('Selects models')
  @async
  public function testSelect(done) {
    store.getRepository(StoreTestModel).all().handle(o -> switch o {
      case Success(models):
        models.length.equals(2);
        done();
      case Failure(err):
        Assert.fail(err.message);
        done();
    });
  }

  // @test('Saves models')
  // public function saveModel() {
  //   store.getRepository(StoreTestModel).save(new StoreTestModel({
  //     id: 'bax',
  //     value: 'bax'
  //   }));
  //   var model = store.getRepository(StoreTestModel).get('bax');
  //   model.value.equals('bax');
  // }

  // @test('Removes models')
  // public function removeModel() {
  //   var foo = store.getRepository(StoreTestModel).get('foo');
  //   store.getRepository(StoreTestModel).has(foo).isTrue();
  //   store.getRepository(StoreTestModel).remove(foo);
  //   store.getRepository(StoreTestModel).has(foo).isFalse();
  // }

}

@:repository( path = 'value' )
class StoreTestModel implements Model {
  @:id(info) var id:String;
  @:field public var value:String;
}
