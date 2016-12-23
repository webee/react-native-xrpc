/**
* @flow
*/

const {
  NativeEventEmitter,
  NativeModules
} = require('react-native');

class XRPCEventEmitter extends NativeEventEmitter {
  constructor() {
    super(NativeModules.XRPCEventEmitter);
  }
}

export default new XRPCEventEmitter();
