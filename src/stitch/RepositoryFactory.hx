package stitch;

typedef RepositoryFactory<T:Model> = {
  public function __createRepository(store:Store):Repository<T>;
}
