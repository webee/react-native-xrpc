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
import rx.functions.Func1;
import rx.subjects.AsyncSubject;

/**
 * Created by webee on 16/10/19.
 */

public class RNXRPCClient {
    private final ReactInstanceManager instanceManager;
    public static final Map<String, AsyncSubject<Reply>> requests = new ConcurrentHashMap<>();

    public RNXRPCClient(ReactInstanceManager instanceManager) {
        this.instanceManager = instanceManager;
    }

    /**
     * emit a event to js.
     * @param event event event.
     * @param args
     * @param kwargs
     */
    public void emit(final String event, final Object[] args, final Bundle kwargs) {
        WritableArray data = Arguments.createArray();
        data.pushString(event);
        data.pushArray(args != null ? Arguments.fromJavaArgs(args) : null);
        data.pushMap(kwargs != null ? Arguments.fromBundle(kwargs) : null);

        instanceManager.getCurrentReactContext().getJSModule(RCTNativeAppEventEmitter.class)
                .emit(RNXRPC.XRPC_EVENT_EVENT, data);
    }

    /**
     * call js procedure.
     * @param proc procedure event
     * @param args
     * @param kwargs
     * @return
     */
    public Observable<Reply> call(final String proc, final Object[] args, final Bundle kwargs) {
        final AsyncSubject<Reply> replySubject = AsyncSubject.create();
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

    /**
     * subscribe js event.
     * @param event event event.
     * @return
     */
    public Observable<Event> sub(final String event) {
        return RNXRPC.event().filter(new Func1<Event, Boolean>() {
            @Override
            public Boolean call(Event e) {
                return e.event.equals(event);
            }
        });
    }
}
