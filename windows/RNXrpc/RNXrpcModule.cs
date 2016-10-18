using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.RNXrpc
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNXrpcModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNXrpcModule"/>.
        /// </summary>
        internal RNXrpcModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNXrpc";
            }
        }
    }
}
