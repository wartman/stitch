package stitch;

typedef CollectionParams = { 
  path:String,
  ?formatter:Formatter<Dynamic>,
  ?extensions:Array<String>,
  ?defaultExtension:String,
  ?resource:Resource<Dynamic>
};

class Collection<T:Model> {

  public final path:String;
  public final formatter:Formatter<Dynamic>;
  public final extensions:Array<String>;
  public final defaultExtension:String;
  public final resource:Resource<T>;
  final modelFactory:(data:Document, formatter:Formatter<Dynamic>)->T;

  public function new(params:CollectionParams, modelFactory) {
    path = params.path;
    formatter = params.formatter != null 
      ? params.formatter
      : new stitch.formatter.TextFormatter();
    extensions = (params.extensions != null
      ? params.extensions
      : []).concat(formatter.allowedExtensions);
    defaultExtension = params.defaultExtension != null
      ? params.defaultExtension
      : formatter.defaultExtension;
    resource = params.resource != null
      ? cast params.resource
      : new stitch.resource.SimpleResource();

    this.modelFactory = modelFactory;
  }

  public function factory(data:Document):T {
    return modelFactory(data, formatter);
  }

  public function encode(model:T):String {
    return formatter.encode(model.encode());
  }

  public function withOverrides(params:CollectionParams):Collection<T> {
    return new Collection({
      path: params.path,
      formatter: params.formatter != null ? params.formatter : formatter,
      extensions: params.extensions != null ? params.extensions : extensions,
      defaultExtension: params.defaultExtension != null ? params.defaultExtension : defaultExtension,
      resource: params.resource != null ? params.resource : resource
    }, modelFactory);
  }

}
