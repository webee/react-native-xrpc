/**
*
* @providesModule RNXRPC
* @flow
*/

const {
  NativeAppEventEmitter,
  NativeModules: {
    XRPC
  }
} = require('react-native');

function parseArgs(args) {
  // [...] => [[...]]
  // [..., undefined, Object] => [[...], Object]
  if (args.length >= 2) {
    let [s, rkwargs] = args.slice(-2);
    if (s === undefined && (!(rkwargs instanceof Array) && (rkwargs instanceof Object))) {
      return [args.slice(0, -2), rkwargs];
    }
  }
  return [args, {}];
}

function chooseArgs(options, context, args, kwargs) {
  args = args ? args : [];
  kwargs = kwargs ? kwargs : {};
  var xargs = [args, kwargs];
  if (options.withContext) {
    xargs = [context, args, kwargs];
  }
  return xargs;
}

class RNXRPC {
  _procedures: Object;
  _subscribers: Object;
  _xrpcSub: Object;

  constructor() {
    this.C = XRPC.C;
    this._procedures = {};
    this._subscribers = {};
    this._xrpcSub = NativeAppEventEmitter.addListener(
      XRPC._XRPC_EVENT,
      this._handleXRPCEvent.bind(this)
    );
  }

  _handleXRPCEvent([e, ...args]) {
    console.debug('xrpc event:', e, ...args);
    switch (e) {
      case XRPC._EVENT_CALL:
      this._handleCall(args);
      break;
      case XRPC._EVENT_EVENT:
      this._handleEvent(args);
      break;
      default:
    }
  }

  _handleEvent([event, ...xargs]) {
    let f = this._subscribers[event];
    if (!(f instanceof Function)) {
      return;
    }
    try {
      f(...chooseArgs(f.options, ...xargs));
    }catch(err) {
      console.error("event:", err);
    }
  }

  _handleCall([rid, proc, ...xargs]) {
    let f = this._procedures[proc];
    if (!(f instanceof Function)) {
      return;
    }
    let replyAPI = {
      reply: (...args) => {
        let [rargs, rkwargs] = parseArgs(args);
        XRPC.emit(XRPC._EVENT_REPLY, [rid, rargs, rkwargs])
      },
      error: (err, ...args) => {
        let [rargs, rkwargs] = parseArgs(args);
        XRPC.emit(XRPC._EVENT_REPLY_ERROR, [rid, err, rargs, rkwargs])
      }
    };

    try {
      if (f.options.isAsync) {
        f(...chooseArgs(f.options, ...xargs), replyAPI);
      } else {
        let res = f(...chooseArgs(f.options, ...xargs));
        replyAPI.reply(res);
      }
    }catch (err) {
      console.error(err);
      replyAPI.error(err.toString());
    }
  }

  destroy() {
    this._xrpcSub.remove();
  }

  // emit sent event to native.
  emit(event, ...args) {
    let [rargs, rkwargs] = parseArgs(args);
    XRPC.emit(XRPC._EVENT_EVENT, [event, rargs, rkwargs]);
  }

  // subscribe to native event.
  // NOTE:
  // one event one subscriber, to support other subscribers, do it in sub.
  subscribe(event, sub, options={withContext:false}) {
    console.debug('xrpc subscribe:', event, options);
    sub.options = options;
    this._subscribers[event] = sub;
  }

  unsubscribe(event) {
    delete this._subscribers[event];
    console.debug('xrpc unsubscribe:', event);
  }

  // call native procedure.
  call(proc, ...args) {
    let [rargs, rkwargs] = parseArgs(args);
    return XRPC.call(proc, rargs, rkwargs);
  }

  register(name, proc, options={isAsync:false, withContext:false}) {
    console.debug('xrpc register:', name, options);
    proc.options = options;
    this._procedures[name] = proc;
  }

  // @deprecated since v0.2.0, use register instead.
  registerAsync(name, proc) {
    this.register(name, proc, {isAsync:true});
  }

  unregister(name) {
    delete this._procedures[name];
    console.debug('xrpc unregister:', name);
  }
}

export default new RNXRPC();
