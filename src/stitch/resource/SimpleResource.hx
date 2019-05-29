package stitch.resource;

import haxe.ds.Option;
import stitch.*;

using Lambda;
using haxe.io.Path;

class SimpleResource<T:Model> implements Resource<T> {

  public function new() {}

  public function locate(cnx:Connection, collection:Collection<T>, id:String):Option<String> {
    if (id == null) return None;
    var path = Path.join([ collection.path, id ]).normalize();
    if (path.extension() != null && path.extension().length > 0) {
      if (!collection.extensions.has(path.extension())) return None;
      return cnx.exists(path) ? Some(path) : None;
    }
    for (ext in collection.extensions) {
      var withExt = path.withExtension(ext);
      if (cnx.exists(withExt)) return Some(withExt);
    }
    return None;
  }

  public function list(cnx:Connection, collection:Collection<T>):Array<String> {
    var names = cnx.list(collection.path);
    return names
      .filter(name -> collection.extensions.has(name.extension()))
      .map(name -> name.withoutExtension().withoutDirectory());
  }

  public function load(cnx:Connection, collection:Collection<T>, id:String):Option<T> {
    return switch locate(cnx, collection, id) {
      case Some(path): Some(collection.factory(cnx.read(path)));
      case None: None;
    }
  }

  public function save(cnx:Connection, collection:Collection<T>, model:T):Bool {
    return cnx.write(Path.join([
      collection.path,
      model.id
    ]).withExtension(collection.defaultExtension), collection.encode(model));
  }

  public function remove(cnx:Connection, collection:Collection<T>, model:T):Bool {
    return switch locate(cnx, collection, model.id) {
      case Some(path): cnx.remove(path);
      case None: false;
    }
  }

}
