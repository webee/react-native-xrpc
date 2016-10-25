# react-native-xrpc

## Getting started

`$ npm install react-native-xrpc --save`

### Mostly automatic installation

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

## Usage
### Android
helpers
```java
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
RN.setup(this, BuildConfig.DEBUG, packages);

// Now:
// RN.inst() -> <ReactInstanceManager>
// RN.xrpc() -> <RNXRPC>

// add to mainifest
<activity
    android:name="com.webee.react.helper.ReactNativeActivity"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"></activity>

// then, start a module
startActivity(ReactNativeActivity.getStartIntent(this, "HelloWorld", null));
```

xrpc
```java
// create a xrpc client with a ReactInstanceManager.
RNXRPCClient xrpc = new RNXRPCClient(instanceManager);
// or:
RN.xrpc()...

// call a js procedure.
xrpc.call("test.add", new Object[]{1, 2, 3, 4}, null)
  .map(new Func1<Reply, Integer>() {
      @Override
      public Integer call(Reply reply) {
          ReadableArray args = reply.args;
          return args.getInt(0);
      }
  })
  .subscribeOn(Schedulers.io())
  .observeOn(AndroidSchedulers.mainThread())
  .subscribe(new Subscriber<Integer>() {
      @Override
      public void onCompleted() {
          Log.i("XRPC.add", "completed");
      }

      @Override
      public void onError(Throwable e) {
          Log.e("XRPC.add", e.getMessage());
      }

      @Override
      public void onNext(Integer sum) {
          Log.i("XRPC.add", sum.toString());
      }
  });

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

// subscribe js event.
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

// emit event to js.
xrpc.emit("test.event.log", new Object[]{"hello", 123}, null);
```

### IOS
helper
```object-c
// setup react native bridge.
//
[RN setupWithEnv: env
         andPort: 8081
 andExtraModules: @[[[RNXRPC alloc] initWithExtraConstants:@{@"Toast": @{@"SHORT":@0, @"LONG":@1}}]]
   launchOptions: nil];

// Now
// [RN xrpc] -> <RNXRPC>
// [RN bridge] -> <RCTBridge>

// then, start a module
UIViewController* vc = [[RNViewController alloc] initWithModule:@"HelloWorld" initialProperties:nil];
[self presentViewController:vc animated:YES completion:nil];
```
xrpc
```c
// refer RNXRPCClient.{h,m}
```

### js
helper
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

xrpc
```javascript
import XRPC from 'react-native-xrpc';

// sync procedure
XRPC.register("test.add", (args, kwargs) => {
  return args.reduce((a, b)=>a+b);
});

// async procedure
XRPC.registerAsync("test.async", (args, kwargs, reply) => {
  let [n, m, d] = args;
  setTimeout(() => {
    reply.reply(n * m);
  }, d);
});

// call a native procedure.
XRPC.call("test.proc.add", 1, 2, 3, 4, 5)
    .then(sum => XRPC.call("test.proc.toast", `sum: ${sum}`, XRPC.C.Toast.SHORT))
    .catch(err => console.log(err));

// subscribe native event.
XRPC.subscribe("test.event.log", (args, kwargs) => {
  console.log(args, kwargs);
});

// send event to native.
XRPC.emit("test.event.toast", "hello");

```
