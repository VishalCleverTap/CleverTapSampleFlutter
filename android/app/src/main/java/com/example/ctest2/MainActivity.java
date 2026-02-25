package com.example.ctest2;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;

import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler;
import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.sdk.interfaces.NotificationHandler;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //CleverTapAPI clevertapDefaultInstance = CleverTapAPI.getDefaultInstance(getApplicationContext());
        //clevertapDefaultInstance.enableDeviceNetworkInfoReporting(true);
        CleverTapAPI.setNotificationHandler((NotificationHandler)new PushTemplateNotificationHandler());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        /**
         * On Android 12, Raise notification clicked event when Activity is already running in activity backstack
         */
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            CleverTapAPI.getDefaultInstance(getApplicationContext()).pushNotificationClickedEvent(intent.getExtras());
        }
    }

}
