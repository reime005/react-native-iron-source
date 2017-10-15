package co.squaretwo.ironsource;

import android.app.Activity;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.ironsource.mediationsdk.IronSource;
import com.ironsource.mediationsdk.logger.IronSourceError;
import com.ironsource.mediationsdk.sdk.OfferwallListener;

/**
 * Created by benyee on 11/08/2016.
 */
public class RNIronSourceOfferwall extends ReactContextBaseJavaModule {
    public static final String E_LAYOUT_ERROR = "error";
    private static final String TAG = "RNIronSourceOfferwall";
    private static final int OFFER_WALL_REQUEST = 1;

    private ReactApplicationContext mContext;
    private Intent mOfferWallIntent;

    public RNIronSourceOfferwall(ReactApplicationContext reactContext) {
        super(reactContext);
        mContext = reactContext;
    }

    @Override
    public String getName() {
        return TAG;
    }

    @ReactMethod
    public void initializeOfferwall(final String appId, final String userId) {
        IronSource.setUserId(userId);
        IronSource.init(mContext.getCurrentActivity(), appId);
        IronSource.setOfferwallListener(new OfferwallListener() {
            @Override
            public void onOfferwallAvailable(boolean available) {
                Log.d(TAG, "onOfferwallAvailable() called!");
                sendEvent("offerwallHasChangedAvailability", null);
            }

            @Override
            public void onOfferwallOpened() {
                Log.d(TAG, "onOfferwallOpened() called!");
                sendEvent("offerwallDidShow", null);
            }

            @Override
            public void onOfferwallShowFailed(IronSourceError ironSourceError) {
                Log.d(TAG, "onOfferwallShowFailed() called!");
                WritableMap map = Arguments.createMap();
                map.putString(E_LAYOUT_ERROR, ironSourceError.toString());
                sendEvent("offerwallDidFailToShowWithError", map);
            }

            @Override
            public boolean onOfferwallAdCredited(int credits, int totalCredits, boolean totalCreditsFlag) {
                Log.d(TAG, "onOfferwallAdCredited() called!");
                WritableMap map = Arguments.createMap();
                map.putInt("credits", credits);
                map.putInt("totalCredits", totalCredits);
                map.putBoolean("totalCreditsFlag", totalCreditsFlag);
                sendEvent("didReceiveOfferwallCredits", map);
                return false;
            }

            @Override
            public void onGetOfferwallCreditsFailed(IronSourceError ironSourceError) {
                Log.d(TAG, "onGetOfferwallCreditsFailed() called!");
                WritableMap map = Arguments.createMap();
                map.putString(E_LAYOUT_ERROR, ironSourceError.toString());
                sendEvent("didFailToReceiveOfferwallCreditsWithError", map);
            }

            @Override
            public void onOfferwallClosed() {
                Log.d(TAG, "onOfferwallClosed() called!");
                sendEvent("offerwallDidClose", null);
            }
        });
    }

    @ReactMethod
    public void showOfferwall(final Promise promise) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                Log.d(TAG, "showOfferWall started");
                boolean available = IronSource.isOfferwallAvailable();
                if (available) {
                    Log.d(TAG, "isOfferwallAvailable() = true");
                    promiseResolve(promise, null);
                    IronSource.showOfferwall();
                } else {
                    Log.d(TAG, "isOfferwallAvailable() = false");
                    promiseReject(promise, E_LAYOUT_ERROR, null);
                }
            }
        });
    }

    private static void promiseReject(final Promise promise, String code, String message) {
        try {
            promise.reject(code, message);
        } catch (RuntimeException e) {
            e.printStackTrace();
        }
    }

    private static void promiseResolve(final Promise promise, final Object value) {
        try {
            promise.resolve(value);
        } catch (RuntimeException e) {
            e.printStackTrace();
        }
    }

    private void sendEvent(String eventName, @Nullable WritableMap params) {
        getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
    }
}
