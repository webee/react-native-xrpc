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

  emit(topic, arg) {
    let [rargs, rkwargs] = parseArgs(arg);
    XRPC.emit(topic, rargs, rkwargs);
  }

  _handleEvent(data) {
    const f = this._subscribers[proc];
    if (f instanceof Function) {
      return;
    }
    try {
      f(data);
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
        XRPC.emit(XRPC.EVENT_REPLY, [rid, rargs, rkwargs, false], null)
      },
      replyDone: (arg) => {
        let [rargs, rkwargs] = parseArgs(arg);
        XRPC.emit(XRPC.EVENT_REPLY, [rid, rargs, rkwargs, true], null)
      },
      done: () => {
        XRPC.emit(XRPC.EVENT_REPLY_DONE, [rid], null)
      },
      error: (err, arg) => {
        let [rargs, rkwargs] = parseArgs(arg);
        XRPC.emit(XRPC.EVENT_REPLY_ERROR, [rid, err, rargs, rkwargs], null)
      }
    };

    try {
      if (f.is_async) {
        f(args, kwargs, replyAPI);
      } else {
        let res = f(args, kwargs);
        replyAPI.replyDone(res);
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

  subscribe(event, sub) {
    this._subscribers[event] = sub;
  }

  unsubscribe(name) {
    delete this._subscribers[name];
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
