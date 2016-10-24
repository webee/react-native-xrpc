package com.webee.react.helper;

import android.app.Application;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactPackage;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.shell.MainReactPackage;
import com.webee.react.RNXRPCClient;

import java.util.List;

/**
 * Created by webee on 16/10/24.
 */

public class RN {
    private static ReactInstanceManager instanceManager;
    private static RNXRPCClient xrpc;

    public static void setup(Application application, boolean isDev, List<ReactPackage> extraPackages) {
        ReactInstanceManager.Builder builder = ReactInstanceManager.builder()
                .setApplication(application)
                .setUseDeveloperSupport(isDev)
                .setBundleAssetName("index.android.bundle")
                .setJSMainModuleName("index.android")
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .addPackage(new MainReactPackage());
                //.setUseOldBridge(true) // uncomment this line if your app crashes
        for (ReactPackage pk : extraPackages) {
            builder = builder.addPackage(pk);
        }

        instanceManager = builder.build();
        instanceManager.createReactContextInBackground();
        xrpc = new RNXRPCClient(instanceManager);
    }

    public static ReactInstanceManager inst() {
        return instanceManager;
    }

    public static RNXRPCClient xrpc() {
        return xrpc;
    }
}
