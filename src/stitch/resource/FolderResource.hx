package stitch.resource;

import haxe.ds.Option;
import stitch.*;

using haxe.io.Path;

class FolderResource<T:Model> extends SimpleResource<T> {

  final dataName:String;

  public function new(dataName:String) {
    super();
    this.dataName = dataName;
  }

  override function locate(cnx:Connection, collection:Collection<T>, id:String):Option<String> {
    id = Path.join([id, dataName]);
    return super.locate(cnx, collection, id);
  }

  override function list(cnx:Connection, collection:Collection<T>):Array<String> {
    return cnx.list(collection.path)
      .filter(name -> name.extension() == ''); // a dumb way to check for dirs
  }

  override function load(cnx:Connection, collection:Collection<T>, id:String):Option<T> {
    return switch locate(cnx, collection, id) {
      case Some(path):
        var res = cnx.read(path);
        res.name = path.directory().withoutDirectory();
        Some(collection.factory(res));
      case None: None;
    }
  }

  override function save(cnx:Connection, collection:Collection<T>, model:T):Bool {
    return cnx.write(Path.join([
      collection.path,
      model.id,
      dataName
    ]).withExtension(collection.defaultExtension), collection.encode(model));
  }

  override function remove(cnx:Connection, collection:Collection<T>, model:T):Bool {
    return switch locate(cnx, collection, model.id) {
      case Some(path): cnx.remove(path.directory());
      case None: false;
    }
  }

}
