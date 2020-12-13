package flutter.moum.headset_event;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class WiredHeadsetBroadcastReceiver extends BroadcastReceiver {
    private static final String TAG = "WiredHeadsetBR";

    HeadsetEventListener headsetEventListener;

    public WiredHeadsetBroadcastReceiver(HeadsetEventListener listener) {
        this.headsetEventListener = listener;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (intent.getAction().equals(Intent.ACTION_HEADSET_PLUG)) {
            int state = intent.getIntExtra("state", -1);
            switch (state) {
                case 0:
                    headsetEventListener.onWiredHeadsetDisconnect();
                    break;
                case 1:
                    headsetEventListener.onWiredHeadsetConnect();
                    break;
            }
        }
    }
}
