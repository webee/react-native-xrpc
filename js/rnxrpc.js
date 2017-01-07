/**
* @providesModule RNXRPC
* @flow
*/

const {
  NativeModules: {
    XRPC
  }
} = require('react-native');
import XRPCEventEmitter from './XRPCEventEmitter';

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
    console.log('xrpc start listen');
    this._xrpcSub = XRPCEventEmitter.addListener(
      XRPC._XRPC_EVENT,
      this._handleXRPCEvent.bind(this)
    );
  }

  _handleXRPCEvent([e, ...args]) {
    console.log('xrpc event:', e, ...args);
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

  async _handleEvent([event, ...xargs]) {
    let f = this._subscribers[event];
    if (!(f instanceof Function)) {
      return;
    }
    try {
      let res = f(...chooseArgs(f.options, ...xargs));
      if (res instanceof Promise) {
        await res;
      }
    }catch(err) {
      console.error(`event:${err}`);
    }
  }

  async _handleCall([rid, proc, ...xargs]) {
    let replyAPI = {
      replyNext: (...args) => {
        let [rargs, rkwargs] = parseArgs(args);
        // rid, args, kwargs, hasNext
        XRPC.emit(XRPC._EVENT_REPLY, [rid, rargs, rkwargs, true])
      },
      reply: (...args) => {
        let [rargs, rkwargs] = parseArgs(args);
        XRPC.emit(XRPC._EVENT_REPLY, [rid, rargs, rkwargs])
      },
      error: (err, ...args) => {
        let [rargs, rkwargs] = parseArgs(args);
        XRPC.emit(XRPC._EVENT_REPLY_ERROR, [rid, err, rargs, rkwargs])
      }
    };
    let f = this._procedures[proc];
    if (!(f instanceof Function)) {
      replyAPI.error("procedure not registered");
      return;
    }

    try {
      if (f.options.isAsync) {
        let res = f(...chooseArgs(f.options, ...xargs), replyAPI);
        if (res instanceof Promise) {
          await res;
        }
      } else {
        let res = f(...chooseArgs(f.options, ...xargs));
        if (res instanceof Promise) {
          res = await res;
        }
        replyAPI.reply(res);
      }
    }catch (err) {
      console.error(`call:${err}`);
      replyAPI.error(err.toString());
    }
  }

  destroy() {
    this._xrpcSub.remove();
  }

  // emit sent event to native.
  emit(event, ...args) {
    let [rargs, rkwargs] = parseArgs(args);
    console.log('xrpc emit:', event, rargs, rkwargs);
    XRPC.emit(XRPC._EVENT_EVENT, [event, rargs, rkwargs]);
  }

  // subscribe to native event.
  // NOTE:
  // one event one subscriber, to support other subscribers, do it in sub.
  subscribe(event, sub, options={withContext:false}) {
    console.log('xrpc subscribe:', event, options);
    sub.options = options;
    this._subscribers[event] = sub;
  }

  unsubscribe(event) {
    delete this._subscribers[event];
    console.log('xrpc unsubscribe:', event);
  }

  // call native procedure.
  call(proc, ...args) {
    let [rargs, rkwargs] = parseArgs(args);
    console.log('xrpc call:', proc, rargs, rkwargs);
    return XRPC.call(proc, rargs, rkwargs);
  }

  register(name, proc, options={isAsync:false, withContext:false}) {
    console.log('xrpc register:', name, options);
    proc.options = options;
    this._procedures[name] = proc;
  }

  // @deprecated since v0.2.0, use register instead.
  registerAsync(name, proc) {
    this.register(name, proc, {isAsync:true});
  }

  unregister(name) {
    delete this._procedures[name];
    console.log('xrpc unregister:', name);
  }
}

export default new RNXRPC();
