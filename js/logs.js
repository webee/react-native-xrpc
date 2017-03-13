export function setLog(enable) {
  console.info(`${enable ? "enable" : "disable"} log`);
  if (!enable) {
    console.__log__ = console.log;
    console.log = () => {};
  } else {
    if (console.__log__)  {
      console.log = console.__log__;
      console.__log__ = undefined;
    }
  }
}

import XRPC, {xMod, register, subscribe, isAsync, withContext} from './index';

@xMod
export class Log {
  @subscribe('set')
  setEnableLog([enable]) {
    setLog(enable);
  }
}
