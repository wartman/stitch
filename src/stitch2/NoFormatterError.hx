package stitch2;

class NoFormatterError {
  
  final formatter:String;

  public function new(formatter) {
    this.formatter = formatter;
  }

  public function toString() {
    return 'No formater was found for the extension [${formatter}].';
  }

}