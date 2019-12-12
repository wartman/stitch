package stitch;

import haxe.ds.Map;

using StringTools;
using haxe.io.Path;

@:allow(stitch.Repository)
class Store {
  
  final connection:Connection;
  final repositories:Map<RepositoryFactory<Dynamic>, Repository<Dynamic>> = [];
  final formatters:Map<String, Formatter> = [];

  public function new(connection, ?formatters:Map<String, Formatter>) {
    this.connection = connection;
    if (formatters != null) {
      for (ext => formatter in formatters) addFormatter(ext, formatter);
    }
  }

  /**
    Add a formatter to handle the given extension. Handle multiple extensions by
    with a comma-delimited list.
  **/
  public function addFormatter(ext:String, formatter:Formatter) {
    if (ext.contains(',')) {
      for (e in ext.split(',')) {
        addFormatter(e, formatter);
      }
      return;
    }
    formatters.set(ext.trim(), formatter);
  }

  public function getFormatter(ext:String):Formatter {
    return formatters.get(ext);
  }

  public function getRepository<T:Model>(factory:RepositoryFactory<T>):Repository<T> {
    if (!repositories.exists(factory)) {
      repositories.set(factory, factory.__createRepository(this));
    }
    return cast repositories.get(factory);
  }

  function __listIds(path:String):Array<String> {
    return connection.list(path);
  }

  function __loadAll(path:String):Array<{ info:Info, contents:Dynamic }> {
    var paths = __listIds(path);
    return [ for (p in paths) __load(p) ];
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
    var formatter = formatters.get(ext);
    if (formatter == null) throw new NoFormatterError(ext);
    connection.write(path.withExtension(ext), formatter.generate(content));
  }

  function __remove(path:String) {
    if (connection.exists(path)) connection.remove(path);
  }

}
