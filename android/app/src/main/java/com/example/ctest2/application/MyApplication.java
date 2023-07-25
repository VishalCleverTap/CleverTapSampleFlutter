package com.example.ctest2.application;

import android.content.Context;
import android.util.Log;

import androidx.multidex.MultiDex;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.clevertap.android.pushtemplates.PushTemplateNotificationHandler;
import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.sdk.interfaces.NotificationHandler;
import com.clevertap.android.sdk.pushnotification.PushConstants;
import com.example.ctest2.R;
import com.xiaomi.channel.commonutils.android.Region;
import com.xiaomi.mipush.sdk.MiPushClient;

import io.flutter.app.FlutterApplication;

import com.clevertap.android.sdk.pushnotification.CTPushNotificationListener;

import java.util.HashMap;
import java.util.Map;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterMain;

public class MyApplication extends FlutterApplication {

    public static CleverTapAPI cleverTapAPI = null;

    @Override
    public void onCreate() {
        ActivityLifecycleCallback.register(this);
        super.onCreate();

        FlutterEngine flutterEngine = new FlutterEngine(this);
        flutterEngine.getDartExecutor().executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault());

        String APP_ID = getString(R.string.xiaomi_app_id);
        String APP_KEY = getString(R.string.xiaomi_app_key);

        CleverTapAPI.changeXiaomiCredentials(APP_ID, APP_KEY);
        CleverTapAPI.enableXiaomiPushOn(PushConstants.ALL_DEVICES);

        if (cleverTapAPI == null) {
            cleverTapAPI = CleverTapAPI.getDefaultInstance(getApplicationContext());
        }

        MiPushClient.setRegion(Region.India);
        MiPushClient.registerPush(this, APP_ID, APP_KEY);
        String xiaomiToken = MiPushClient.getRegId(this);
        String xiaomiRegion = MiPushClient.getAppRegion(this);

        if(cleverTapAPI != null){
            cleverTapAPI.pushXiaomiRegistrationId(xiaomiToken, xiaomiRegion, true);
        }else{
            Log.e("TAG","CleverTap is NULL");
        }
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }

}
