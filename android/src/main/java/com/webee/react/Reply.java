package com.webee.react;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by webee on 16/10/18.
 */

public class Reply {
    public final ReadableArray args;
    public final ReadableMap kwargs;

    public Reply(ReadableArray args, ReadableMap kwargs) {
        this.args = args;
        this.kwargs = kwargs;
    }
}
