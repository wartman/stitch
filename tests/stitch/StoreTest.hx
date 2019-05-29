package stitch;

import stitch.connection.MemoryConnection;
import stitch.field.*;

using medic.Assert;

class StoreTest {

  public function new() {}

  var store:Store;

  @before
  public function createStore() {
    var connection = new MemoryConnection([
      'value/foo.txt' => 'value: foo',
      'value/bar.txt' => 'value: bar',
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
    store = new Store(connection);
  }

  @test('Selects models')
  public function testSelect() {
    var models = store.get(StoreTestModel).all();
    models.length.equals(2);
  }

  @test('Selects children')
  public function testSelectChildren() {
    var children = store.get(StoreTestModel)
      .select(m -> m.id == 'foo')
      .children(StoreTestModel);
    children.length.equals(1);
    var models = children.pop().all();
    models.length.equals(2);
  }

  @test('Selects children with custom folder')
  public function testSelectChildrenCustom() {
    var children = store.get(StoreTestModel).children(StoreTestModel, 'custom');
    children.length.equals(2);
    children[0].all().length.equals(2);
    children[1].all().length.equals(1);
  }

  @test('Saves models')
  public function saveModel() {
    store.save(new StoreTestModel({
      id: 'bax',
      value: 'bax'
    }));
    var model = store.get(StoreTestModel).find('bax');
    model.value.equals('bax');
  }

  @test('Removes models')
  public function removeModel() {
    var foo = store.get(StoreTestModel).find('foo');
    store.get(StoreTestModel).has(foo).isTrue();
    store.remove(foo);
    store.get(StoreTestModel).has(foo).isFalse();
  }

}

@Collection( path = 'value' )
class StoreTestModel implements Model {
  @StringField public var value:String;
}
