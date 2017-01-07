# react-native-xrpc

## Getting started

`$ npm install react-native-xrpc --save`

### Mostly automatic installation
non-guaranteed, not recommend!

`$ react-native link react-native-xrpc`

### Manual installation

#### iOS
update Podfile
```
pod 'RNXRPC', :path => '../node_modules/react-native-xrpc', :subspecs => [
        'XRPC',
        'Helper', // helpers.
    ]
```

#### Android
1. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-xrpc'
  	project(':react-native-xrpc').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-xrpc/android')
  	```
2. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-xrpc')
  	```
3. Add Package
  Add new RNXRPCPackage() to ReactInstanceManager builder.

##### OR:
not recommend, this release may not be the latest and may not match with javascript version.
```java
compile 'com.github.webee:react-native-utils-android:v<version>'
```

## Usage

### js
#### xrpc
+ import XRPC
  ```javascript
  import XRPC from 'react-native-xrpc';
  ```

+ arguments
  ```javascript
  // input arguments:
  // ([context, ]args, kwargs[, reply])
  // context: method context;       type: Object;   eg: {user: "test"};
  //    args: array arguments;      type: Array;    eg: [1, 2, "c"];
  //  kwargs: dictionary arguments; type: Object;   eg: {sync: true};
  //   reply: async reply API, {.replyNext(...xargs), .reply(...xargs), .error(err, ...xargs)}
  //          .replyNext: reply subscribe call partial result.
  //          .reply:     reply call result or done subscribe call with last result.
  //          .error:     reply call error.
  //      non-async calls is the same as .reply(<ret value>) or .error(<throw exception>.toString())

  // parse xargs
  // parse(xargs) => [args, kwargs], args, kwargs is the same as input arguments.
  // xargs is an Array.
  // if xargs is this pattern: [...args, undefined, kwargs], then => [args, kwargs];
  // else [...args] => [args, {}];

  // output arguments:
  // reply:     (args, kwargs): same as input arguments.
  // replyNext: (args, kwargs): ditto.
  // error:     (err, args, kwargs): err is a error string; ditto.
  ```

+ register procedure
  ```javascript
  // sync procedure
  XRPC.register("test.arithmetic", ([a, b], {op}) => {
    switch (a) {
      case "+":
        return a + b;
        break;
      case "*":
        return a * b;
        break;
      default:
        return 0;
    }
  });

  // sync procedure with context.
  XRPC.register("test.user.add", ({user}, [a, b]) => {
    return `${user}: ${a+b}`;
  }, {withContext: true});

  // async procedure
  XRPC.register("test.async", ([n, m], {d}, reply) => {
    setTimeout(() => {
      reply.reply(n * m);
    }, d);
  }, {isAsync: true});

  // async subscribe procedure
  XRPC.register("test.async.sub", async ([n=1], _, reply) => {
    for (let i = 1; i < n; i++) {
      reply.replyNext(i);
      await new Promise(r => setTimeout(r, 1000));
    }
    reply.reply(n);
  }, {isAsync: true});
  ```

+ subscribe event
  ```javascript
  // subscribe native event.
  XRPC.subscribe("test.event.log", (args, kwargs) => {
    console.log(args, kwargs);
  });

  // subscribe native event with context.
  XRPC.subscribe("test.user.event.log", (context, args, kwargs) => {
    console.log(context.user, args, kwargs);
  }, {withContext:true});
  ```

+ xrpc Module

  register procedures and subscribe events are ways to setup js methods for native to invoke.
  module is a modular way to organize this js methods.
  ```javascript
  import {xMod, register, subscribe, isAsync, withContext, registerXMod} from 'react-native-xrpc';

  @xMod
  class Test {
    constructor(initialCount=0) {
      // here we can init module states.
      this.count = initialCount;
    }

    // sync procedure
    @register("inc")
    inc() {
      // access states.
      return ++this.count;
    }

    // sync procedure
    @register("arithmetic")
    arithmetic([a, b], {op}) {
      switch (a) {
        case "+":
          return a + b;
          break;
        case "*":
          return a * b;
          break;
        default:
          return 0;
      }
    }

    // sync procedure with context.
    @withContext
    @register("user.add")
    userAdd({user}, [a, b]) {
      return `${user}: ${a+b}`;
    }

    // async procedure
    @isAsync
    @register("async")
    asyncMethod([n, m], {d}, reply) {
      setTimeout(() => {
        reply.reply(n * m);
      }, d);
    }

    // async subscribe procedure
    @isAsync
    @register("async.sub")
    async asyncSubMethod([n=1], _, reply) {
      for (let i = 1; i < n; i++) {
        reply.replyNext(i);
        await new Promise(r => setTimeout(r, 1000));
      }
      reply.reply(n);
    }

    // subscribe native event.
    @subscribe("event.log")
    eventLog(args, kwargs) {
      console.log(args, kwargs);
    }

    // subscribe native event with context.
    @withContext
    @subscribe("user.event.log")
    userEventLog({user}, args, kwargs) {
      console.log(user, args, kwargs);
    }
  }

  // register xrpc module
  // register all new Test(1)'s registered and subscribed js methods with prefix "test." path.
  registerXMod("test", Test, 1);
  ```

+ invoke native methods
  ```javascript
  // call a native procedure.
  XRPC.call("test.proc.add", 1, 2, 3, 4, 5)
      .then(sum => XRPC.call("test.proc.toast", `sum: ${sum}`, XRPC.C.Toast.SHORT))
      .catch(err => console.log(err));

  // call a native procedure
  // XRPC.C.* is xrpc's constants, see: helper RN && RNX.
  XRPC.call("test.proc.toast", "hello", XRPC.C.Toast.SHORT);

  // send event to native.
  XRPC.emit("test.event.toast", "hello", XRPC.C.Toast.LONG);
  ```
+ helpers
  ```javascript
  import XRPC, {exitApp, EntryComponent} from 'react-native-xrpc'
  // if you use the helper(android, ios) to start a module
  // this.props.appInstID is set for you, it's the unique module id.
  exitApp(appInstID)  // will exit this react app instance.
                      //if appInstID is undefined, will exit all modules(most time, you only have just one);

  // extends from EntryComponent for your entry module.
  // this will handle android back for you.
  class MyModuleEntry extends EntryComponent {
    ...
  }
  ```

### Android
+ helpers
  ```java
  // RN
  //
  // react native setup.
  //
  // initialize RNXRPCModule constants;
  Bundle c = new Bundle();
  c.putInt("SHORT", Toast.LENGTH_SHORT);
  c.putInt("LONG", Toast.LENGTH_LONG);
  Map<String, Bundle> extraConstants = new HashMap<>();
  extraConstants.put("Toast", c);

  // extra packages.
  List<ReactPackage> packages = Arrays.asList(
          new RealmReactPackage(),
          new RNXRPCPackage(extraConstants),
          new MyReactPackage()
  );
  // load index.android.jsbundle
  RN.setup(this, BuildConfig.DEBUG, packages);

  // Now:
  // RN.inst() -> <ReactInstanceManager>
  // RN.xrpc() -> <RNXRPC>
  RN.newXrpc(Bundle context); // create a xrpc with default context.

  // add to mainifest
  <activity
      android:name="com.webee.react.helper.ReactNativeActivity"
      android:theme="@style/Theme.AppCompat.Light.NoActionBar"></activity>

  // then, start a module
  startActivity(ReactNativeActivity.getStartIntent(this, "MyModuleEntry", null));

  // RNX
  //
  // RN is the default RNX
  // load index.android.xxx.jsbundle
  RNX rnx = new RNX(this, ".xxx", BuildConfig.DEBUG, Arrays.asList(
          new RealmReactPackage(),
          new RNXRPCPackage()
  ));
  ```

+ xrpc
  ```java
  // create a xrpc client with a ReactInstanceManager.
  RNXRPCClient xrpc = new RNXRPCClient(instanceManager);
  // or:
  xrpc = RN.xrpc()
  xrpc = RN.newXrpc()
  // or:
  xrpc = rnx.xrpc()
  xrpc = rnx.newXrpc()
  ```

+ call js procedure
  ```java
  // call a procedure
  xrpc.call("test.inc", null, null)
        .then(new Transform<Reply, Integer>() {
            @Override
            public Integer run(Reply reply) {
                ReadableArray args = reply.args;
                return args.getInt(0);
            }
        })
        .handleOn(AndroidExecutors.mainThread())
        .fulfilled(new Action<Integer>() {
            @Override
            public void run(Integer val) {
                Log.i("XRPC.inc", val.toString());
            }
        })
        .rejected(new Action<Throwable>() {
            @Override
            public void run(Throwable e) {
                Log.e("XRPC.inc", e.getMessage());
            }
        })
        .settled(new Runnable() {
            @Override
            public void run() {
                Log.i("XRPC.inc", "completed");
            }
        });

  // call a context procedure
  Bundle context = new Bundle();
  context.putString("user", "test");
  xrpc.call("test.user.add", context, new Object[]{1, 2}, null)
          .then(new Transform<Reply, String>() {
              @Override
              public String run(Reply reply) {
                  ReadableArray args = reply.args;
                  return args.getString(0);
              }
          })
          .handleOn(AndroidExecutors.mainThread())
          .fulfilled(new Action<String>() {
              @Override
              public void run(String sum) {
                  Log.i("XRPC.user.add", sum);
              }
          })
          .rejected(new Action<Throwable>() {
              @Override
              public void run(Throwable e) {
                  Log.e("XRPC.user.add", e.getMessage());
              }
          })
          .settled(new Runnable() {
              @Override
              public void run() {
                  Log.i("XRPC.user.add", "completed");
              }
          });

  // subscribe call a subscribe procedure.
  // if you call a subscribe procedure, you get the last result.
  RN.xrpc().subCall("test.async.sub", new Object[]{7}, null)
        .map(new Func1<Reply, Integer>() {
            @Override
            public Integer call(Reply reply) {
                ReadableArray args = reply.args;
                return args.getInt(0);
            }
        })
        .observeOn(AndroidSchedulers.mainThread())
        .subscribe(new Subscriber<Integer>() {
            @Override
            public void onCompleted() {
                Log.i("XRPC.inc", "completed");
            }

            @Override
            public void onError(Throwable e) {
                Log.e("XRPC.inc", e.getMessage());
            }

            @Override
            public void onNext(Integer v) {
                Log.i("XRPC.inc", v.toString());
            }
        });
  ```

+ emit event to js subscriber
  ```java
  // emit event to js.
  Bundle kwargs = new Bundle();
  kwargs.putInt("a", 123);
  xrpc.emit("test.event.log", new Object[]{"hello", 123}, null);

  // emit event to js with context.
  Bundle context = new Bundle();
  context.putString("user", "test");
  xrpc.emit("test.user.event.log", context, new Object[]{"hello", 123}, null);
  ```

+ register a procedure
  ```java
  // register a native procedure.
  Client.xrpc.register("test.proc.add")
    .subscribeOn(Schedulers.io())
    .observeOn(Schedulers.computation())
    .subscribe(new Subscriber<Request>() {
        @Override
        public void onCompleted() {
            Log.i("XRPC.proc.add", "completed");
        }

        @Override
        public void onError(Throwable e) {
            Log.e("XRPC.proc.add", e.getMessage());
        }

        @Override
        public void onNext(Request request) {
            int sum = 0;
            ReadableArray args = request.args;
            for (int i = 0; i < args.size(); i++) {
                sum += args.getInt(i);
            }
            request.promise.resolve(sum);
        }
    });

  // register native procedure.
  Client.xrpc.register("test.proc.toast")
    .subscribeOn(Schedulers.io())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(new Subscriber<Request>() {
        @Override
        public void onCompleted() {
            Log.i("XRPC.proc.toast", "completed");
        }

        @Override
        public void onError(Throwable e) {
            Log.e("XRPC.proc.toast", e.getMessage());
        }

        @Override
        public void onNext(Request request) {
            ReadableArray args = request.args;
            String s = args.getString(0);
            int duration = args.getInt(1);
            Toast.makeText(request.context, s, duration).show();
        }
    });
  ```

+ subscribe js event.
  ```java
  xrpc.sub("test.event.toast")
    .subscribeOn(Schedulers.io())
    .observeOn(AndroidSchedulers.mainThread())
    .subscribe(new Subscriber<String>() {
        @Override
        public void onCompleted() {
            Log.i("XRPC.event.toast", "completed");
        }

        @Override
        public void onError(Throwable e) {
            Log.e("XRPC.event.toast", e.getMessage());
        }

        @Override
        public void onNext(Event e) {
            ReadableArray args = event.args;
            String s = args.getString(0);
            int duration = args.getInt(1);
            Log.i("XRPC.event.toast", s);
            Toast.makeText(e.context, s, duration).show();
        }
    });
  ```

### IOS
+ helper
  ```c
  #ifdef DEBUG
      _env = @"dev";
  #else
      _env = @"prod";
  #endif

  // RN
  //
  // setup react native bridge.
  //
  // load index.ios.jsbundle
  [RN setupWithEnv: _env
   andExtraModules: @[[[RNXRPC alloc] initWithExtraConstants:@{@"Toast": @{@"SHORT":@0, @"LONG":@1}}]]
     launchOptions: nil];

  // Now
  // [RN xrpc] -> <RNXRPC>
  // [RN bridge] -> <RCTBridge>
  [RN newXrpc:defaultContext] // create a xrpc with default context.

  // then, start a module
  UIViewController* vc = [[RNViewController alloc] initWithModule:@"MyModuleEntry" initialProperties:nil];
  [self presentViewController:vc animated:YES completion:nil];

  // RNX
  //
  // RN is the default RNX
  // load index.ios.xxx.jsbundle
  RNX *rnx = [[RNX alloc] initWithEnv:env andName:@"xxx" andExtraModules:extraModules launchOptions:launchOptions];
  ```

+ xrpc etc
  ```c
  // interface is the same as java.
  // Promise4j -> PromiseKit
  // rxJava -> ReactiveObjC
  // details: refer RNXRPCClient.{h,m}
  ```
