package stitch.error;

import stitch.core.Error;

class NoStoreError extends Error {

  public function new(?pos) {
    super(NotFound, 'No store exists', pos);
  }

}
