package stitch.core;

interface PropertyDecorator<T> {
  public function get():T;
  public function set(value:T):T;
}
