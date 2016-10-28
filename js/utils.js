import XRPC from './rnxrpc';

export function register(name) {
  return function(target, key, descriptor) {
    let v = descriptor.value;
    v.xrpc = v.xrpc || {};
    v.xrpc.isProcedure = true;
    v.xrpc.procName = name;
    v.xrpc.procedure = v;
  };
}

export function subscribe(name) {
  return function(target, key, descriptor) {
    let v = descriptor.value;
    v.xrpc = v.xrpc || {};
    v.xrpc.isSubscriber = true;
    v.xrpc.eventName = name;
    v.xrpc.subscriber = v;
  };
}

export function isAsync(target, key, descriptor) {
  let v = descriptor.value;
  v.xrpc = v.xrpc || {};
  v.xrpc.options = v.xrpc.options || {};
  v.xrpc.options.isAsync = true;
}

export function withContext(target, key, descriptor) {
  let v = descriptor.value;
  v.xrpc = v.xrpc || {};
  v.xrpc.options = v.xrpc.options || {};
  v.xrpc.options.withContext = true;
}

export function xMod(target) {
  if (typeof target === 'string') {
    let name = target;
    return function(target) {
      xMod(target);
      registerXMod(target, name);
    };
  }
  let xrpcs = [];
  let names = Object.getOwnPropertyNames(target.prototype);
  for (let i in names) {
    let n = names[i]
    let m = target.prototype[n];
    if (m instanceof Function && m.xrpc) {
      xrpcs = [...xrpcs, m.xrpc];
    }
  }
  target.xrpcs = xrpcs;
}

export function registerXMod(mod, name) {
  if (mod.xrpcs) {
    name = name || mod.name;
    for (let i in mod.xrpcs) {
      let xrpc = mod.xrpcs[i];
      if (xrpc.isProcedure) {
        XRPC.register(name + '.' + xrpc.procName, xrpc.procedure, xrpc.options);
      }
      if (xrpc.isSubscriber) {
        XRPC.subscribe(name + '.' + xrpc.eventName, xrpc.subscriber, xrpc.options);
      }
    }
  }
}
