
package com.webee.react;

import android.os.Bundle;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class RNXRPCPackage implements ReactPackage {
    private Map<String, Bundle> extraConstants;

    public RNXRPCPackage() {
    }

    public RNXRPCPackage(final Map<String, Bundle> extraConstants) {
        this.extraConstants = extraConstants;
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
      return Arrays.<NativeModule>asList(new RNXRPCModule(reactContext, extraConstants));
    }

    @Override
    public List<Class<? extends JavaScriptModule>> createJSModules() {
      return Collections.emptyList();
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
      return Collections.emptyList();
    }
}