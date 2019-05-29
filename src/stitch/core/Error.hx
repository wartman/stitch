package stitch.core;

typedef Pos = 
  #if macro
    haxe.macro.Expr.Position;
  #elseif stitch_no_error_code
    {};
  #else
    haxe.PosInfos;
  #end

enum abstract ErrorCode(Int) from Int to Int {
  var BadRequest = 400;
  var Unauthorized = 401;
  var PaymentRequired = 402;
  var Forbidden = 403;
  var NotFound = 404;
  var MethodNotAllowed = 405;
  var Gone = 410;
  var NotAcceptable = 406;
  var Timeout = 408;
  var Conflict = 409;
  var UnsupportedMediaType = 415;
  var OutOfRange = 416;
  var ExpectationFailed = 417;
  var I_am_a_Teapot = 418;
  var AuthenticationTimeout = 419;
  var UnprocessableEntity = 422;

  var InternalError = 500;
  var NotImplemented = 501;
  var ServiceUnavailable = 503;
  var InsufficientStorage = 507;
  var BandwidthLimitExceeded = 509;
}

// Taken from tink_core with minimal changes.
class Error {

  final code:ErrorCode;
  final message:String;
  final pos:Pos;

  public function new(code, message, ?pos) {
    this.code = code;
    this.message = message;
    this.pos = pos;
  }

  public function toString() {
    var ret = 'Error#$code: $message';
    #if !stitch_no_error_code
    if (pos != null)
      ret += " @ "+printPos();
    #end
    return ret;
  }

  function printPos() {
    return
      #if macro
        Std.string(pos);
      #elseif tink_core_no_error_pos
        ;
      #else
        pos.className+'.'+pos.methodName+':'+pos.lineNumber;
      #end
  }

}
