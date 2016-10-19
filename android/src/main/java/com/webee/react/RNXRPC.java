
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

import rx.subjects.PublishSubject;

import static com.webee.react.RNXRPCClient.requests;

@ReactModule(name = "XRPC")
public class RNXRPC extends ReactContextBaseJavaModule {
    public static final String XRPC_EVENT_CALL = "__XRPC.E.CALL";
    public static final String XRPC_EVENT_REPLY = "__XRPC.E.REPLY";
    public static final String XRPC_EVENT_REPLY_DONE = "__XRPC.E.REPLY_DONE";
    public static final String XRPC_EVENT_REPLY_ERROR = "__XRPC.E.REPLY_ERROR";
    public static final String XRPC_EVENT_EVENT = "__XRPC.E.EVENT";
    private static final Map<String, Object> constants;
    private static Map<String, Procedure> procedures = new ConcurrentHashMap<>();

    static {
        constants = new HashMap<>();
        constants.put("EVENT_CALL", XRPC_EVENT_CALL);
        constants.put("EVENT_REPLY", XRPC_EVENT_REPLY);
        constants.put("EVENT_REPLY_DONE", XRPC_EVENT_REPLY_DONE);
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
    public void emit(final String event, final ReadableArray args, final ReadableMap kwargs) {
        switch (event) {
            case XRPC_EVENT_REPLY:
                handleCallReply(args);
                break;
            case XRPC_EVENT_REPLY_DONE:
                handleCallReplyDone(args);
                break;
            case XRPC_EVENT_REPLY_ERROR:
                handleCallReplyError(args);
                break;
            case XRPC_EVENT_CALL:
                handleCall(args);
                break;
            case XRPC_EVENT_EVENT:
                handleEvent(args, kwargs);
            default:
                break;
        }
    }

    private void handleEvent(ReadableArray xargs, ReadableMap xkwargs) {
        // TODO: call event subscribers.
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
        PublishSubject<Reply> replySubject;
        boolean done = xargs.getBoolean(3);
        if (done) {
            replySubject = RNXRPCClient.requests.remove(rid);
        } else {
            replySubject = RNXRPCClient.requests.get(rid);
        }

        if (replySubject == null) {
            return;
        }

        ReadableArray args = xargs.getArray(1);
        ReadableMap kwargs = xargs.getMap(2);

        replySubject.onNext(new Reply(args, kwargs));
        if (done) {
            replySubject.onCompleted();
        }
    }

    private void handleCallReplyDone(ReadableArray xargs) {
        String rid = xargs.getString(0);
        PublishSubject<Reply> replySubject = requests.remove(rid);
        if (replySubject != null) {
            replySubject.onCompleted();
        }
    }

    private void handleCallReplyError(ReadableArray xargs) {
        String rid = xargs.getString(0);
        PublishSubject<Reply> replySubject = requests.remove(rid);
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