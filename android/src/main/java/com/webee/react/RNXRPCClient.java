package com.webee.react;

import android.os.Bundle;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import rx.Observable;
import rx.subjects.PublishSubject;

/**
 * Created by webee on 16/10/19.
 */

public class RNXRPCClient {
    private final ReactInstanceManager instanceManager;
    public static final Map<String, PublishSubject<Reply>> requests = new ConcurrentHashMap<>();

    public RNXRPCClient(ReactInstanceManager instanceManager) {
        this.instanceManager = instanceManager;
    }

    public void emit(final String event, Object data) {
        instanceManager.getCurrentReactContext().getJSModule(RCTNativeAppEventEmitter.class)
                .emit(event, data);
    }

    public Observable<Reply> call(final String proc, final Object[] args, final Bundle kwargs) {
        final PublishSubject<Reply> replySubject = PublishSubject.create();
        String rid = UUID.randomUUID().toString();

        requests.put(rid, replySubject);

        WritableArray data = Arguments.createArray();
        data.pushString(rid);
        data.pushString(proc);
        data.pushArray(args != null ? Arguments.fromJavaArgs(args) : null);
        data.pushMap(kwargs != null ? Arguments.fromBundle(kwargs) : null);

        instanceManager.getCurrentReactContext().getJSModule(RCTNativeAppEventEmitter.class)
                .emit(RNXRPC.XRPC_EVENT_CALL, data);

        return replySubject;
    }
}
