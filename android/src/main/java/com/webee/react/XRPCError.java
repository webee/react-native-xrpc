package com.webee.react;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by webee on 16/10/18.
 */

public class XRPCError extends Exception {
    public final String error;
    public final ReadableArray args;
    public final ReadableMap kwargs;

    public XRPCError(String error, ReadableArray args, ReadableMap kwargs) {
        super(error);
        this.error = error;
        this.args = args;
        this.kwargs = kwargs;
    }
}
