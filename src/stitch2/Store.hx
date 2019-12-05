package stitch2;

import haxe.ds.Map;

using haxe.io.Path;

@:allow(stitch2.Repository)
class Store {
  
  final connection:Connection;
  final repositories:Map<RepositoryFactory<Dynamic>, Repository<Dynamic>> = [];
  final formatters:Map<String, Formatter>;

  public function new(connection, ?formatters) {
    this.connection = connection;
    this.formatters = formatters != null ? formatters : [];
  }

  public function addFormatter(ext:String, parser:Formatter) {
    formatters.set(ext, parser);
  }

  public function getFormatter(ext:String):Formatter {
    return formatters.get(ext);
  }

  public function getRepository<T:Model>(factory:RepositoryFactory<T>):Repository<T> {
    if (!repositories.exists(factory)) {
      repositories.set(factory, factory._stitch_createRepository(this));
    }
    return cast repositories.get(factory);
  }

  function __load<T:{}>(path:String):{ info:Info, contents:T } {
    for (ext => parser in formatters) {
      var resolved = path.withExtension(ext);
      if (connection.exists(resolved)) {
        var raw = connection.read(resolved);
        return {
          info: connection.getInfo(resolved),
          contents: parser.parse(raw)
        };
      }
    }
    return null;
  }

  function __save<T:{}>(path:String, ext:String, content:T) {
    var parser = formatters.get(ext);
    if (parser == null) throw 'No parser found';
    connection.write(path.withExtension(ext), parser.generate(content));
  }

}
