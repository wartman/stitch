package stitch2;

typedef RepositoryFactory<T:Model> = {
  public function _stitch_createRepository(store:Store):Repository<T>;
}
