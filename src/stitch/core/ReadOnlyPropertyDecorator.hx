package stitch.core;

interface ReadOnlyPropertyDecorator<T> {
  public function get():T;
}
