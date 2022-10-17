package com.example.ctest2.application;

import android.util.Log;

import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.sdk.pushnotification.PushConstants;
import com.example.ctest2.R;
import com.xiaomi.channel.commonutils.android.Region;
import com.xiaomi.mipush.sdk.MiPushClient;

import io.flutter.app.FlutterApplication;

public class MyApplication extends FlutterApplication {

    public static CleverTapAPI cleverTapAPI = null;

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
            cleverTapAPI.pushXiaomiRegistrationId(xiaomiToken, xiaomiRegion, true);
        }else{
            Log.e("TAG","CleverTap is NULL");
        }
    }
}
