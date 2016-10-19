
package com.webee.react;

import android.os.Bundle;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import rx.Observable;
import rx.subjects.AsyncSubject;
import rx.subjects.PublishSubject;

import static com.webee.react.RNXRPCClient.requests;

@ReactModule(name = "XRPC")
public class RNXRPC extends ReactContextBaseJavaModule {
    public static final String XRPC_EVENT_CALL = "__XRPC.E.CALL";
    public static final String XRPC_EVENT_REPLY = "__XRPC.E.REPLY";
    public static final String XRPC_EVENT_REPLY_ERROR = "__XRPC.E.REPLY_ERROR";
    public static final String XRPC_EVENT_EVENT = "__XRPC.E.EVENT";
    private static final Map<String, Object> constants;
    private static final Map<String, Procedure> procedures = new ConcurrentHashMap<>();
    private static final PublishSubject<Event> eventSubject = PublishSubject.create();

    static {
        constants = new HashMap<>();
        constants.put("EVENT_CALL", XRPC_EVENT_CALL);
        constants.put("EVENT_REPLY", XRPC_EVENT_REPLY);
        constants.put("EVENT_REPLY_ERROR", XRPC_EVENT_REPLY_ERROR);
        constants.put("EVENT_EVENT", XRPC_EVENT_EVENT);
    }

    public RNXRPC(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "XRPC";
    }

    @Override
    public Map<String, Object> getConstants() {
        return constants;
    }

    @ReactMethod
    public void emit(final String event, final ReadableArray args) {
        switch (event) {
            case XRPC_EVENT_REPLY:
                handleCallReply(args);
                break;
            case XRPC_EVENT_REPLY_ERROR:
                handleCallReplyError(args);
                break;
            case XRPC_EVENT_CALL:
                handleCall(args);
                break;
            case XRPC_EVENT_EVENT:
                handleEvent(args);
            default:
                break;
        }
    }

    private void handleEvent(ReadableArray xargs) {
        String event = xargs.getString(0);
        ReadableArray args = xargs.getArray(1);
        ReadableMap kwargs = xargs.getMap(2);
        eventSubject.onNext(new Event(event, args, kwargs));
    }

    private void handleCall(ReadableArray xargs) {
        String rid = xargs.getString(0);
        String proc = xargs.getString(1);
        ReadableArray args = xargs.getArray(2);
        ReadableMap kwargs = xargs.getMap(3);
        Procedure f = procedures.remove(proc);
        if (f == null) {
            return;
        }
        // TODO:
    }

    private void handleCallReply(ReadableArray xargs) {
        String rid = xargs.getString(0);
        AsyncSubject<Reply> replySubject = RNXRPCClient.requests.remove(rid);
        if (replySubject == null) {
            return;
        }

        ReadableArray args = xargs.getArray(1);
        ReadableMap kwargs = xargs.getMap(2);

        replySubject.onNext(new Reply(args, kwargs));
        replySubject.onCompleted();
    }

    private void handleCallReplyError(ReadableArray xargs) {
        String rid = xargs.getString(0);
        AsyncSubject<Reply> replySubject = requests.remove(rid);
        if (replySubject == null) {
            return;
        }

        String error = xargs.getString(1);

        int s = xargs.size();
        ReadableArray args = null;
        ReadableMap kwargs = null;
        if (s > 2) {
            args = xargs.getArray(2);
        }
        if (s > 3) {
            kwargs = xargs.getMap(3);
        }

        replySubject.onError(new XRPCError(error, args, kwargs));
    }

    public static Observable<Event> event() {
        return eventSubject.asObservable();
    }

    public static void register() {
        // TODO: register procedure
    }

    public interface Procedure {
        void run(ReadableArray args, ReadableMap kwargs, ReplyAPI reply);
    }

    public interface ReplyAPI {
        void onReply(final Object[] args, final Bundle kwargs);
        void onError(String err, final Object[] args, final Bundle kwargs);
    }
}