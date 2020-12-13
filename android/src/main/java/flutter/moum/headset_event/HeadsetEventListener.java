package flutter.moum.headset_event;

public interface HeadsetEventListener {
    void onWiredHeadsetConnect();
    void onWiredHeadsetDisconnect();
    void onBluetoothHeadsetDisconnect();
    void onBluetoothHeadsetConnect();
}
