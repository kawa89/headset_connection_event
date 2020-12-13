package flutter.moum.headset_event;

import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BluetoothHeadsetBroadcastReceiver extends BroadcastReceiver {

    HeadsetEventListener headsetEventListener;

    public BluetoothHeadsetBroadcastReceiver(HeadsetEventListener listener) {
        this.headsetEventListener = listener;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED)) {
            int connectionState = intent.getExtras().getInt(BluetoothAdapter.EXTRA_CONNECTION_STATE);
            switch (connectionState) {
                case BluetoothAdapter.STATE_CONNECTED:
                    headsetEventListener.onBluetoothHeadsetConnect();
                    break;
                case BluetoothAdapter.STATE_DISCONNECTED:
                    headsetEventListener.onBluetoothHeadsetDisconnect();
                    break;
                default:
                    break;
            }
        }
    }
}
