package flutter.moum.headset_event;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.os.Build;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * HeadsetEventPlugin
 */
public class HeadsetEventPlugin implements MethodCallHandler {

    public static MethodChannel headsetEventChannel;
    public static Boolean wiredHeadsetConnectedState = false;
    public static Boolean bluetoothHeadsetConnectedState = false;
    private static WiredHeadsetBroadcastReceiver wiredHeadsetReceiver;
    private static BluetoothHeadsetBroadcastReceiver bluetoothHeadsetReceiver;
    private static final String TAG = "HeadsetEventPlugin";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        headsetEventChannel = new MethodChannel(registrar.messenger(), "flutter.moum/headset_event");
        headsetEventChannel.setMethodCallHandler(new HeadsetEventPlugin());

        wiredHeadsetReceiver = new WiredHeadsetBroadcastReceiver(headsetEventListener);
        IntentFilter cordedHeadsetReceiverFilter = new IntentFilter();
        cordedHeadsetReceiverFilter.addAction(Intent.ACTION_HEADSET_PLUG);
        registrar.activeContext().registerReceiver(wiredHeadsetReceiver, cordedHeadsetReceiverFilter);

        bluetoothHeadsetReceiver = new BluetoothHeadsetBroadcastReceiver(headsetEventListener);
        IntentFilter bluetoothHeadsetReceiverFilter = new IntentFilter();
        bluetoothHeadsetReceiverFilter.addAction(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED);
        bluetoothHeadsetReceiverFilter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
        registrar.activeContext().registerReceiver(bluetoothHeadsetReceiver, bluetoothHeadsetReceiverFilter);

        AudioManager mAudioManager = (AudioManager) registrar.activeContext().getSystemService(Context.AUDIO_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioDeviceInfo[] mAudioDeviceInfos = mAudioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS);
            for (AudioDeviceInfo mAudioDeviceInfo : mAudioDeviceInfos) {
                int type = mAudioDeviceInfo.getType();
                if (type == AudioDeviceInfo.TYPE_WIRED_HEADSET) {
                    headsetEventListener.onWiredHeadsetConnect();
                } else if (type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO || type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP) {
                    headsetEventListener.onBluetoothHeadsetConnect();
                }
            }
        }
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("getCurrentState")) {
            result.success(getCurrentState());
        } else {
            result.notImplemented();
        }
    }

    private static int getCurrentState() {
        int currentState = 0;
        if (bluetoothHeadsetConnectedState && wiredHeadsetConnectedState) {
            currentState = 3;
        } else if (bluetoothHeadsetConnectedState) {
            currentState = 2;
        } else if (wiredHeadsetConnectedState) {
            currentState = 1;
        }
        return currentState;
    }

    static HeadsetEventListener headsetEventListener = new HeadsetEventListener() {
        @Override
        public void onWiredHeadsetConnect() {
            wiredHeadsetConnectedState = true;
            headsetEventChannel.invokeMethod("connectWired", "true");
        }

        @Override
        public void onWiredHeadsetDisconnect() {
            wiredHeadsetConnectedState = false;
            headsetEventChannel.invokeMethod("disconnectWired", "true");
        }

        @Override
        public void onBluetoothHeadsetConnect() {
            bluetoothHeadsetConnectedState = true;
            headsetEventChannel.invokeMethod("connectBluetooth", "true");
        }

        @Override
        public void onBluetoothHeadsetDisconnect() {
            bluetoothHeadsetConnectedState = false;
            headsetEventChannel.invokeMethod("disconnectBluetooth", "true");
        }
    };
}
