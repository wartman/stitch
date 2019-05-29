package stitch.error;

import haxe.PosInfos;
import stitch.core.Error;

class NoStoreError extends Error {

  public function new(?pos:PosInfos) {
    super(NotFound, 'No store exists', pos);
  }

}
