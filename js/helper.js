import React, { Component } from 'react';
import { BackAndroid } from 'react-native';
import XRPC from './rnxrpc';

export const exitApp = (appInstID) => {
  XRPC.emit("native.app.exit", appInstID);
};

export class EntryComponent extends Component {
  constructor(props) {
    super(props);
    let {appInstID} = props;
    let self = this;
    self.appInstID = appInstID;
    self.backSub = BackAndroid.addEventListener('hardwareBackPress', function() {
      exitApp(appInstID);
      return false;
    });
  }

  componentWillUnmount() {
    let self = this;
    if (self.backSub) {
      self.backSub.remove();
      self.backSub = undefined;
    }
  }
}
