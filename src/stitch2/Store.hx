package stitch2;

import haxe.ds.Map;

using haxe.io.Path;

/**
  Api will be something like:

  // For a model like:
  class Post {
    @:field(info = name) var id:String;
    @:field(info = created) var created:Date;
    @:field var title:String;
    @:field var extra:Extra;
    @:field(format = MarkdownFormatter) var content:String;
    @:hasOne(id) var author:User; 
  }

  var store = new Store(FileConnection(Sys.getCwd()));
  var posts = store.getRepository(Post);
  var foo = posts.get('foo');

**/
@:allow(stitch2.Repository)
class Store {
  
  final connection:Connection;
  final repositories:Map<RepositoryFactory<Dynamic>, Repository<Dynamic>> = [];
  final parsers:Map<String, Parser>;

  public function new(connection, ?parsers) {
    this.connection = connection;
    this.parsers = parsers != null ? parsers : [];
  }

  public function addParser(ext:String, parser:Parser) {
    parsers.set(ext, parser);
  }

  public function getParser(ext:String):Parser {
    return parsers.get(ext);
  }

  public function getRepository<T:Model>(factory:RepositoryFactory<T>):Repository<T> {
    if (!repositories.exists(factory)) {
      repositories.set(factory, factory._stitch_createRepository(this));
    }
    return cast repositories.get(factory);
  }

  function __load<T:{}>(path:String):{ info:Info, contents:T } {
    for (ext => parser in parsers) {
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
    var parser = parsers.get(ext);
    if (parser == null) throw 'No parser found';
    connection.write(path.withExtension(ext), parser.generate(content));
  }

}
