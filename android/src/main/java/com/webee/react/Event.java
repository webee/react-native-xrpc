package com.webee.react;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by webee on 16/10/19.
 */

public class Event {
    public final ReactApplicationContext context;
    public final String event;
    public final ReadableArray args;
    public final ReadableMap kwargs;

    public Event(ReactApplicationContext context, String name, ReadableArray args, ReadableMap kwargs) {
        this.context = context;
        this.event =name;
        this.args = args;
        this.kwargs = kwargs;
    }
}
