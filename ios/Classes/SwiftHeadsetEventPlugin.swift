import Flutter
import UIKit
import AVFoundation


public class SwiftHeadsetEventPlugin: NSObject, FlutterPlugin {
    
    var channel : FlutterMethodChannel?
    var bluetoothHeadsetConnectedState = false;
    var wiredHeadsetConnectedState = false;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter.moum/headset_event", binaryMessenger: registrar.messenger())
        let instance = SwiftHeadsetEventPlugin()

        instance.channel = channel
        instance.setup()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getCurrentState"){
            result(getCurrentState())
        }
    }

    func setup() {
        initHeadsetListener()
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            let portType = output.portType
            if (portType == AVAudioSession.Port.headphones) {
                self.channel!.invokeMethod("connectWired",arguments: "true")
                wiredHeadsetConnectedState = true
            }else if (portType == AVAudioSession.Port.bluetoothA2DP || portType == AVAudioSession.Port.bluetoothHFP) {
                self.channel!.invokeMethod("connectBluetooth",arguments: "true")
                bluetoothHeadsetConnectedState = true
            }
        }
    }
    
    func initHeadsetListener(){
        NotificationCenter.default.addObserver( forName:AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance(), queue: nil) { notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
            }
            print(reason);
            switch reason {
            case .newDeviceAvailable:
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setActive(true)
                }
                catch {
                    print("Unexpected error: \(error).")
                }
                for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    self.channel!.invokeMethod("connectWired",arguments: "true")
                    self.wiredHeadsetConnectedState = true
                    break
                }
                for output in session.currentRoute.outputs where (output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP) {
                    self.channel!.invokeMethod("connectBluetooth",arguments: "true")
                    self.bluetoothHeadsetConnectedState = true
                    break
                }
            case .oldDeviceUnavailable:
                if let previousRoute =
                    userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                        self.channel!.invokeMethod("disconnectWired",arguments: "true")
                        self.wiredHeadsetConnectedState = false
                        break
                    }
                    for output in previousRoute.outputs where (output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP) {
                        self.channel!.invokeMethod("disconnectBluetooth",arguments: "true")
                        self.bluetoothHeadsetConnectedState = false
                        break
                    }
                }
            default: ()
            }
        }
    }
    
    func getCurrentState() -> Int  {
        var currentState = 0
        if (bluetoothHeadsetConnectedState && wiredHeadsetConnectedState) {
            currentState = 3
        } else if (bluetoothHeadsetConnectedState) {
            currentState = 2
        } else if (wiredHeadsetConnectedState) {
            currentState = 1
        }
        return currentState;
    }
}
