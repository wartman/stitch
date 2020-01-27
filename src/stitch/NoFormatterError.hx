package stitch;

using tink.CoreApi;

class NoFormatterError extends Error {
  
  public function new(formatter:String) {
    super(NotFound, 'No formater was found for the extension [${formatter}].');
  }

}