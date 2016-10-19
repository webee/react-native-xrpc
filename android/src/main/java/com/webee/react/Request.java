package com.webee.react;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by webee on 16/10/19.
 */

public class Request {
    final String rid;
    final ReadableArray args;
    final ReadableMap kwargs;

    public Request(String rid, ReadableArray args, ReadableMap kwargs) {
        this.rid = rid;
        this.args = args;
        this.kwargs = kwargs;
    }
}
