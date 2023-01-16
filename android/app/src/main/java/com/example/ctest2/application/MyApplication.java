package com.example.ctest2.application;

import android.content.Context;
import android.util.Log;

import androidx.multidex.MultiDex;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;
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

public class MyApplication extends FlutterApplication implements CTPushNotificationListener {

    public static CleverTapAPI cleverTapAPI = null;

    public MethodChannel methodChannel = null;
    public static String CHANNEL = "myChannel";

    @Override
    public void onCreate() {
        ActivityLifecycleCallback.register(this);
        super.onCreate();

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
            cleverTapAPI.setCTPushNotificationListener(this);
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

    public void getChannelMethod(Context context, Map<String, Object> r){
        FlutterMain.startInitialization(context);
        FlutterMain.ensureInitializationComplete(context, new String[]{});
        FlutterEngine flutterEngine = new FlutterEngine(getApplicationContext());
        DartExecutor.DartEntrypoint dartEntrypoint = new DartExecutor.DartEntrypoint("lib/main.dart", "main");
        flutterEngine.getDartExecutor().executeDartEntrypoint(dartEntrypoint);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL).invokeMethod("onPushNotificationClicked", r, new MethodChannel.Result() {
            @Override
            public void success(@Nullable Object result) {
                Log.d("Results", result.toString());
            }

            @Override
            public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                Log.d("No result as error", errorDetails.toString());
            }

            @Override
            public void notImplemented() {
                Log.d("No result as error", "cant find ");
            }
        });
    }


    @Override
    public void onNotificationClickedPayloadReceived(HashMap<String, Object> payload) {
            getChannelMethod(this,payload);
    }
}
