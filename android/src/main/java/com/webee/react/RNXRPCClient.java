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
import rx.Subscriber;
import rx.functions.Func1;
import rx.subjects.AsyncSubject;
import rx.Observable.OnSubscribe;

/**
 * Created by webee on 16/10/19.
 */

public class RNXRPCClient {
    private final ReactInstanceManager instanceManager;
    private final Bundle defaultContext;
    public static final Map<String, AsyncSubject<Reply>> requests = new ConcurrentHashMap<>();
    public static final Map<String, Subscriber<? super Request>> procedures = new ConcurrentHashMap<>();

    public RNXRPCClient(ReactInstanceManager instanceManager) {
        this(instanceManager, null);
    }

    public RNXRPCClient(ReactInstanceManager instanceManager, Bundle context) {
        this.instanceManager = instanceManager;
        this.defaultContext = context;
    }

    public void emit(final String event, final Object[] args, final Bundle kwargs) {
        emit(event, defaultContext, args, kwargs);
    }

    /**
     * emit a event to js.
     * @param event
     * @param context
     * @param args
     * @param kwargs
     */
    public void emit(final String event, final Bundle context, final Object[] args, final Bundle kwargs) {
        WritableArray data = Arguments.createArray();
        data.pushInt(RNXRPCModule.XRPC_EVENT_EVENT);
        data.pushString(event);
        data.pushMap(context != null ? Arguments.fromBundle(context) : null);
        data.pushArray(args != null ? Arguments.fromJavaArgs(args) : null);
        data.pushMap(kwargs != null ? Arguments.fromBundle(kwargs) : null);

        instanceManager.getCurrentReactContext().getJSModule(RCTNativeAppEventEmitter.class)
                .emit(RNXRPCModule.XRPC_EVENT, data);
    }

    /**
     * subscribe js event.
     * @param event event event.
     * @return
     */
    public Observable<Event> sub(final String event) {
        return RNXRPCModule.event().filter(new Func1<Event, Boolean>() {
            @Override
            public Boolean call(Event e) {
                return e.event.equals(event);
            }
        });
    }

    public Observable<Reply> call(final String proc, final Object[] args, final Bundle kwargs) {
        return call(proc, null, args, kwargs);
    }

    /**
     * call a js procedure.
     * @param proc
     * @param context
     * @param args
     * @param kwargs
     * @return
     */
    public Observable<Reply> call(final String proc, final Bundle context, final Object[] args, final Bundle kwargs) {
        // TODO: add a call builder to build the context, args and kwargs.
        final AsyncSubject<Reply> replySubject = AsyncSubject.create();
        String rid = UUID.randomUUID().toString();

        requests.put(rid, replySubject);

        WritableArray data = Arguments.createArray();
        data.pushInt(RNXRPCModule.XRPC_EVENT_CALL);
        data.pushString(rid);
        data.pushString(proc);
        data.pushMap(context != null ? Arguments.fromBundle(context) : null);
        data.pushArray(args != null ? Arguments.fromJavaArgs(args) : null);
        data.pushMap(kwargs != null ? Arguments.fromBundle(kwargs) : null);

        instanceManager.getCurrentReactContext().getJSModule(RCTNativeAppEventEmitter.class)
                .emit(RNXRPCModule.XRPC_EVENT, data);

        return replySubject;
    }

    /**
     * register a procedure for js to call.
     * @param proc
     * @return
     */
    public Observable<Request> register(final String proc) {
        return Observable.create(new OnSubscribe<Request>() {
            @Override
            public void call(Subscriber<? super Request> subscriber) {
                if (subscriber.isUnsubscribed()) return;
                procedures.put(proc, subscriber);
            }
        });
    }
}
