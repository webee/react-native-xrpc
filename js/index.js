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
    let s, rkwargs = args.slice(-2);
    if (s === undefined && (! rkwargs instanceof Array && rkwargs instanceof Object)) {
      return [args.slice(0, -2), rkwargs];
    }
  }
  return [args];
}

class RNXRPC {
  _procedures: Object;
  _subscribers: Object;
  _xrpcSub: Object;

  constructor() {
    this.c = XRPC;
    this._procedures = {};
    this._subscribers = {};
    this._xrpcSub = NativeAppEventEmitter.addListener(
      XRPC._XRPC_EVENT,
      this._handleXRPCEvent.bind(this)
    );
  }

  _handleXRPCEvent([e, ...args]) {
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

  _handleEvent([event, args, kwargs]) {
    const f = this._subscribers[event];
    if (!f instanceof Function) {
      return;
    }
    try {
      f(args, kwargs);
    }catch(err) {
      console.error("event:", err);
    }
  }

  _handleCall([rid, proc, args, kwargs]) {
    const f = this._procedures[proc];
    if (! f instanceof Function) {
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
      if (f.is_async) {
        f(args, kwargs, replyAPI);
      } else {
        let res = f(args, kwargs);
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
  subscribe(event, sub) {
    this._subscribers[event] = sub;
  }

  unsubscribe(event) {
    delete this._subscribers[event];
  }

  // call native procedure.
  call(proc, ...args) {
    let [rargs, rkwargs] = parseArgs(args);
    return XRPC.call(proc, rargs, rkwargs);
  }

  register(name, proc) {
    proc.is_async = false;
    this._procedures[name] = proc;
  }

  registerAsync(name, proc) {
    proc.is_async = true;
    this._procedures[name] = proc;
  }

  unregister(name) {
    delete this._procedures[name];
  }
}

export default new RNXRPC();
