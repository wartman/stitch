package stitch.formatter;

import stitch.Formatter;

using Reflect;

/**
  Simply passes the contents of a file through as `{content}`.
  Useful when you just want the raw contents of a file.
**/
class RawFormatter implements Formatter {

  public function new() {}

  public function parse(data:String):Dynamic {
    return { content: data };
  }

  public function generate(data:Dynamic):String {
    return data.field('content');
  }

}
