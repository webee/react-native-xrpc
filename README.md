# react-native-xrpc

!!Now, only android is finished.

## Getting started

`$ npm install react-native-xrpc --save`

### Mostly automatic installation

`$ react-native link react-native-xrpc`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-xrpc` and add `RNXrpc.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNXrpc.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
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

// subscribe native event.
XRPC.subscribe("test.event.log", (args, kwargs) => {
  console.log(args, kwargs);
});

// send event to native.
XRPC.emit("test.event.toast", "hello");

```

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

// subscribe js event.
xrpc.sub("test.event.toast")
  .map(new Func1<Event, String>() {
      @Override
      public String call(Event event) {
          ReadableArray args = event.args;
          return args.getString(0);
      }
  })
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
      public void onNext(String s) {
          Log.i("XRPC.event.toast", s);
          Toast.makeText(getCurrentActivity(), s, Toast.LENGTH_SHORT).show();
      }
  });

// emit event to js.
xrpc.emit("test.event.log", new Object[]{"hello", 123}, null);
```
