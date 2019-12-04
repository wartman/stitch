package stitch2;

/**
  A formatter is responsible for transforming values, as you might
  expect. A simple example is transforming a markdown field into html.

  Note that all Models are Transformers.
**/
typedef Transformer<From, To> = {
  public function _stitch_decode(info:Info, data:From):To;
  public function _stitch_encode(data:To):From;
}
