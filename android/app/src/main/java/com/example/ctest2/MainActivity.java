package com.example.ctest2;

import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import io.flutter.embedding.android.FlutterActivity;

import com.clevertap.android.sdk.CleverTapAPI;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        CleverTapAPI.getDefaultInstance(getApplicationContext()).pushNotificationClickedEvent(intent.getExtras());
    }

}
