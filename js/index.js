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

function parseArgs(res) {
  // [undefined | null | Array, undefined | null | (Object - Array)]
  if (res instanceof Array && res.length >= 1 && res.length <= 2) {
    let [rargs, rkwargs] = res;
    if ((rargs instanceof Array === null || rargs === undefined)
    && (rkwargs === null || rkwargs === undefined || (! rkwargs instanceof Array && rkwargs instanceof Object))) {
      return [rargs, rkwargs];
    }
  }
  return [[res]]
}

class RNXRPC {
  _procedures: Object;
  _subscribers: Object;
  _callSub: Object;
  _eventSub: Object;

  constructor() {
    this._procedures = {};
    this._subscribers = {};
    this._callSub = NativeAppEventEmitter.addListener(
      XRPC.EVENT_CALL,
      this._handleCall.bind(this)
    );
    this._eventSub = NativeAppEventEmitter.addListener(
      XRPC.EVENT_EVENT,
      this._handleEvent.bind(this)
    );
  }

  // emit sent event to native.
  emit(event, arg) {
    let [rargs, rkwargs] = parseArgs(arg);
    XRPC.emit(XRPC.EVENT_EVENT, [event, rargs, rkwargs]);
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
      reply: (arg) => {
        let [rargs, rkwargs] = parseArgs(arg);
        XRPC.emit(XRPC.EVENT_REPLY, [rid, rargs, rkwargs])
      },
      error: (err, arg) => {
        let [rargs, rkwargs] = parseArgs(arg);
        XRPC.emit(XRPC.EVENT_REPLY_ERROR, [rid, err, rargs, rkwargs])
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
    this._callSub.remove();
    this._eventSub.remove();
  }

  // subscribe to native event.
  subscribe(event, sub) {
    this._subscribers[event] = sub;
  }

  unsubscribe(event) {
    delete this._subscribers[event];
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
