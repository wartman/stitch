package stitch.connection;

using Medic;
using tink.CoreApi;

class ConnectionTest implements TestCase {

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
  @async
  public function testList(done) {
    Promise.inParallel([
      cnx.list('flat').next(items -> {
        items.length.equals(2);
        items.join(',').equals('a.json,b.json');
        items;
      }),
      cnx.list('pages').next(pages -> {
        pages.length.equals(2);
        pages.join(',').equals('a,b');
        pages;
      })
    ]).handle(o -> switch o {
      case Success(_): 
        done();
      case Failure(err): 
        Assert.fail(err.message);
        done();
    });
  }

  @test('Loads document correctly')
  @async
  public function testLoad(done) {
    cnx.read('flat/a.json').handle(o -> switch o {
      case Success(data):
        data.equals('{"title":"a","value":"a"}');
        done();
      case Failure(err): 
        Assert.fail(err.message);
        done();
    });
  }

  // @test('writes and removes files correctly')
  // public function testWriteFile() {
  //   cnx.write('flat/c.json', '{"title":"c","value":"c"}').isTrue();
  //   cnx.exists('flat/c.json').isTrue();
  //   cnx.remove('flat/c.json').isTrue();
  //   cnx.exists('flat/c.json').isFalse();
  // }

  // @test('removing a non-existant file returns false')
  // public function testRemoveNonExistant() {
  //   cnx.exists('flat/r.json').isFalse();
  // }

  // @test('creates dirs if needed, and removing works on dirs')
  // public function testWriteAndRemoveDir() {
  //   cnx.write('pages/c/_info.txt', 'stuff').isTrue();
  //   cnx.exists('pages/c').isTrue();
  //   cnx.exists('pages/c/_info.txt').isTrue();
  //   cnx.remove('pages/c').isTrue();
  //   cnx.exists('pages/c').isFalse();
  // }

}
