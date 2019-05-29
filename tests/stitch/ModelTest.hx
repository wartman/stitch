package stitch;

import stitch.field.*;
import stitch.connection.MemoryConnection;

using medic.Assert;

class ModelTest {

  public function new() {}

  function createTestStore() {
    var connection = new MemoryConnection([
      'children/foo.txt' => "value: foo",
      'children/foo/children' => [
        'foo.txt' => 'value: foo',
        'bar.txt' => 'value: bar'
      ],
      'folder/foo' => [ 
        '_info.txt' => 'value:foo'
      ],
      'folder/foo/children' => [
        'foo.txt' => 'value: foo',
        'bar.txt' => 'value: bar'
      ],
      'folder/foo/stuff' => [
        'foo/_info.txt' => 'value: foo',
        'bar/_info.txt' => 'value: bar',
        'bin/_info.txt' => 'value: bin'
      ]
    ]);
    return new Store(connection);
  }

  @test('Info is applied correctly')
  public function testInfo() {
    TestModel.collection.path.equals('test');
  }

  @test('Id is created automatically')
  public function testAutoId() {
    var model = new TestModel({ 
      id: 'foo',
      foo: 'foo',
      bar: 'bar'
    });
    model.id.equals('foo');
  }

  @test('Model can be created from Content')
  public function testFactory() {
    var time = Date.now();
    var model = TestModel.collection.factory({
      name: 'name',
      path: 'some/path/to/name',
      contents: '
foo: foo
---
bar: bar
      ',
      created: time,
      modified: time
    });
    model.id.equals('name');
    model.foo.equals('foo');
    model.bar.equals('bar');
    model.created.equals(time);
  }

  @test('Children fields?')
  public function testChildren() {
    var store = createTestStore();
    store.get(ChildrenModel).find('foo').children.all().length.equals(2);
  }

  @test('Can be used as folders')
  public function testFolder() {
    var store = createTestStore();
    store.get(FolderModel).find('foo').value.equals('foo');
    store.get(FolderModel).find('foo').children.all().length.equals(2);
    store.get(FolderModel).find('foo').foldered.all().length.equals(3);
  }

  @test('Can be serialized to JSON')
  public function testJson() {
    var model = new TestModel({ 
      id: 'foo',
      foo: 'foo',
      bar: 'bar'
    });
    var json:{ id:String, foo:String, bar:String, created:Date, modified:Date } = model.toJson();
    json.id.equals('foo');
    json.foo.equals('foo');
    json.bar.equals('bar');
  }

  // todo: test using other formatters and stuff?
  //       And fields getting info from the right places?

}

@Collection( path = "test" )
private class TestModel implements Model {
  @StringField public var foo:String;
  @StringField public var bar:String;
  @DocumentField( 
    handler = doc -> doc.created,
    fallback = () -> Date.now()  
  ) public var created:Date;
  @DocumentField( 
    handler = doc -> doc.modified,
    fallback = () -> Date.now()
  ) public var modified:Date;
}

@Collection( path = "children" )
private class ChildrenModel implements Model {
  @StringField public var value:String;
  @DocumentField( handler = doc -> doc.created ) public var created:Date;
  @DocumentField( handler = doc -> doc.modified ) public var modified:Date;
  @ChildrenField( relation = ChildrenModel ) public var children:Selection<ChildrenModel>;
}

@Collection(
  path = "folder",
  resource = new stitch.resource.FolderResource('_info')
)
private class FolderModel implements Model {
  @StringField public var value:String;
  @ChildrenField( relation = ChildrenModel ) public var children:Selection<ChildrenModel>;
  @ChildrenField( relation = FolderModel, path = 'stuff' ) public var foldered:Selection<FolderModel>;
}
