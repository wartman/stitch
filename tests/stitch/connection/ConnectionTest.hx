package stitch.connection;

using medic.Assert;

class ConnectionTest {

  final factory:()->Connection;
  var cnx:Connection;

  public function new(factory) {
    this.factory = factory;
  }

  @before
  public function connect() {
    cnx = factory();
  }

  @test('Lists documents correctly')
  public function testList() {
    cnx.list('flat').length.equals(2);
    cnx.list('pages').length.equals(2);
    cnx.list('flat').join(',').equals('a.json,b.json');
    cnx.list('pages').join(',').equals('a,b');
  }

  @test('Loads document correctly')
  public function testLoad() {
    cnx.read('flat/a.json').equals('{"title":"a","value":"a"}');
  }

  @test('writes and removes files correctly')
  public function testWriteFile() {
    cnx.write('flat/c.json', '{"title":"c","value":"c"}').isTrue();
    cnx.exists('flat/c.json').isTrue();
    cnx.remove('flat/c.json').isTrue();
    cnx.exists('flat/c.json').isFalse();
  }

  @test('removing a non-existant file returns false')
  public function testRemoveNonExistant() {
    cnx.exists('flat/r.json').isFalse();
  }

  @test('creates dirs if needed, and removing works on dirs')
  public function testWriteAndRemoveDir() {
    cnx.write('pages/c/_info.txt', 'stuff').isTrue();
    cnx.exists('pages/c').isTrue();
    cnx.exists('pages/c/_info.txt').isTrue();
    cnx.remove('pages/c').isTrue();
    cnx.exists('pages/c').isFalse();
  }

}
