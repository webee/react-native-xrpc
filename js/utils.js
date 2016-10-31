import XRPC from './rnxrpc';

export function register(name) {
  return function(target, key, descriptor) {
    let v = descriptor.value;
    v.xrpc = v.xrpc || {};
    v.xrpc.isProcedure = true;
    v.xrpc.procName = name;
    v.xrpc.procedure = key;
  };
}

export function subscribe(name) {
  return function(target, key, descriptor) {
    let v = descriptor.value;
    v.xrpc = v.xrpc || {};
    v.xrpc.isSubscriber = true;
    v.xrpc.eventName = name;
    v.xrpc.subscriber = key;
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

export function registerXMod(Mod, name, ...args) {
  if (Mod.xrpcs) {
    let inst = new Mod(...args);
    name = name || Mod.name;
    for (let i in Mod.xrpcs) {
      let xrpc = Mod.xrpcs[i];
      if (xrpc.isProcedure) {
        let procedure = inst[xrpc.procedure].bind(inst);
        XRPC.register(name + '.' + xrpc.procName, procedure, xrpc.options);
      }
      if (xrpc.isSubscriber) {
        let subscriber = inst[xrpc.subscriber];
        XRPC.subscribe(name + '.' + xrpc.eventName, subscriber, xrpc.options);
      }
    }
  }
}
