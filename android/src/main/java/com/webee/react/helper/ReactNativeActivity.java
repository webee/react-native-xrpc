package com.webee.react.helper;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.webee.react.Event;

import java.util.UUID;

import rx.Subscriber;
import rx.Subscription;
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

public class ReactNativeActivity extends AppCompatActivity implements DefaultHardwareBackBtnHandler {
    public static final String APP_INST_ID_PROP = "appInstID";
    public static final String APP_EXIT_EVENT = "native.app.exit";
    public static final String EXTRA_MODULE_NAME = ReactNativeActivity.class.getName() + ".MODULE_NAME";
    public static final String EXTRA_LAUNCH_OPTIONS = ReactNativeActivity.class.getName() + ".LAUNCH_OPTIONS";
    private String appInstID;
    private Subscription appExitSub;
    private ReactRootView mReactRootView;
    private ReactInstanceManager instanceManager;


    public static Intent getStartIntent(Context context, String moduleName, Bundle launchOptions) {
        Intent intent = new Intent(context, ReactNativeActivity.class);
        intent.putExtra(EXTRA_MODULE_NAME, moduleName);
        intent.putExtra(EXTRA_LAUNCH_OPTIONS, launchOptions);
        return intent;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        appInstID = UUID.randomUUID().toString();
        // subscribe exit app event.
        appExitSub = RN.xrpc().sub(APP_EXIT_EVENT)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(new Subscriber<Event>() {
                    @Override
                    public void onCompleted() {
                    }

                    @Override
                    public void onError(Throwable e) {
                        Log.e("ReactNativeActivity", e.getMessage());
                    }

                    @Override
                    public void onNext(Event event) {
                        if (event.args.isNull(0)) {
                            ReactNativeActivity.this.invokeDefaultOnBackPressed();
                        } else {
                            String aid = event.args.getString(0);
                            if (appInstID.equals(aid)) {
                                ReactNativeActivity.this.invokeDefaultOnBackPressed();
                            }
                        }
                    }
                });
        instanceManager = RN.inst();

        final Intent intent = getIntent();
        String moduleName = intent.getStringExtra(EXTRA_MODULE_NAME);
        Bundle launchOptions = intent.getBundleExtra(EXTRA_LAUNCH_OPTIONS);
        if (launchOptions == null) {
            launchOptions = new Bundle();
        }
        launchOptions.putString(APP_INST_ID_PROP, appInstID);
        mReactRootView = new ReactRootView(this);
        mReactRootView.startReactApplication(instanceManager, moduleName, launchOptions);

        setContentView(mReactRootView);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        appExitSub.unsubscribe();
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        super.onBackPressed();
    }

    @Override
    public void onBackPressed() {
        if (instanceManager != null) {
            instanceManager.onBackPressed();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_MENU && instanceManager != null) {
            instanceManager.showDevOptionsDialog();
            return true;
        }
        return super.onKeyUp(keyCode, event);
    }
}
