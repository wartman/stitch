package stitch2;

using haxe.io.Path;

typedef RepositoryOptions = {
  path:String,
  ?isDirectory:Bool,
  ?dataFile:String
}; 

// Todo: massively simplify
class Repository<T:Model> {

  final store:Store;
  final options:RepositoryOptions;
  final decoder:(info:Info, data:Dynamic)->T;
  final encoder:(data:T)->Dynamic;

  public function new(store, options, decoder, encoder) {
    this.store = store;
    this.options = options;
    this.decoder = decoder;
    this.encoder = encoder;
  }

  public function get(id:String):T {
    var data = store.__load(if (options.isDirectory) {
      Path.join([ options.path, id, options.dataFile ]);
    } else {
      Path.join([ options.path, id ]);
    });
    if (data != null) {
      return decoder(data.info, data.contents);
    }
    throw 'No model found with the id ${id}'; // or something
  }

  public function all():Selection<T> {
    return null;
  }

  public function save(model:T):Void {
    var filePath = getPath(model._stitch_info);
    store.__save(filePath, model._stitch_info.extension, encoder(model));
    // todo: update info?
  }

  function getPath(info:Info) {
    return if (options.isDirectory) {
      Path.join(
        [ options.path ]
          .concat(info.path)
          .concat([ info.name, options.dataFile ])
      );
    } else {
       Path.join(
        [ options.path ]
          .concat(info.path)
          .concat([ info.name ])
      );
    }
  }

  public function remove(model:T):Bool {
    return false;
  }

}
