package com.webee.react;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by webee on 16/10/19.
 */

public class Request {
    public final ReadableArray args;
    public final ReadableMap kwargs;
    public final Promise promise;

    public Request(ReadableArray args, ReadableMap kwargs, Promise promise) {
        this.args = args;
        this.kwargs = kwargs;
        this.promise = promise;
    }
}
