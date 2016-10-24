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
    ]
```
Or: good luck!
1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-xrpc` and add `RNXrpc.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNXRPC.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

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

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNXrpc.sln` in `node_modules/react-native-xrpc/windows/RNXrpc.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Cl.Json.RNXrpc;` to the usings at the top of the file
  - Add `new RNXrpcPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
Android:
```java
// create a xrpc client with a ReactInstanceManager.
RNXRPCClient xrpc = new RNXRPCClient(instanceManager);

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

IOS:
```object-c
// TODO:
```

js:
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
    .then(sum => XRPC.emit("test.event.toast", `sum: ${sum}`))
    .catch(err => console.log(err));

// subscribe native event.
XRPC.subscribe("test.event.log", (args, kwargs) => {
  console.log(args, kwargs);
});

// send event to native.
XRPC.emit("test.event.toast", "hello");

```
