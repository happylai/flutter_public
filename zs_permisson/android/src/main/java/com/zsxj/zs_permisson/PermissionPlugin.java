package com.zsxj.zs_permisson;
import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;
import android.net.Uri;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


/**
 * @author wangyangjun
 * @time 2020/11/19
 */

public class PermissionPlugin {
    private final static int REQUEST_ENABLE_BT = 10001;


    /*
    * 检查蓝牙需要 定位权限是否授权
    * */
    public static boolean checkLocationPermission(MethodCall call, MethodChannel.Result result, Activity activity) {
        Log.d("-->","---?");
        if (Build.VERSION.SDK_INT >= 23) {
            //校验是否已具有模糊定位权限
            if (ContextCompat.checkSelfPermission(activity,
                    Manifest.permission.ACCESS_FINE_LOCATION)
                    != PackageManager.PERMISSION_GRANTED) {
                //请求权限
                ActivityCompat.requestPermissions(activity,
                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                        REQUEST_ENABLE_BT);
                return false;
            } else {
                //有权限了
                result.success(0);
                return true;
            }
        } else {
            //有权限了
            result.success(0);
            return true;
        }
    }
    /*
     * 检查蓝牙需要 定位是否打开
     * */
    public static void checkLocationState(MethodCall call, MethodChannel.Result result, Activity activity) {
        LocationManager locationManager = (LocationManager) activity.getSystemService(Context.LOCATION_SERVICE);
        boolean gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
        boolean network = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
        if (gps || network) {
            // 开了
            result.success(0);
        }else{
            // 没开
            result.success(-1);
        }


    }

    /*
    * 检查蓝牙是否开启
    * */
    public static void checkBLuetoothState(MethodCall call, MethodChannel.Result result) {
        if (BluetoothAdapter.getDefaultAdapter().isEnabled()) {
            result.success(0);
        } else {
            result.success(-1);
        }
    }


    /*
    * 跳转定位权限
    * */
    public static void openLocationPermission(MethodCall call, MethodChannel.Result result, Activity activity) {
        gotoPermissionSetting(activity);
    }

    /*
    * 跳转到gps设置页
    * */
    public static void openLocationState(MethodCall call, MethodChannel.Result result, Activity activity) {
        Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
        activity.startActivityForResult(intent, 10010);
    }

    /*
    * 打开蓝牙
    * */
    public static void openBluetooth(MethodCall call, MethodChannel.Result result, Activity activity) {
        Intent enableIntent = new Intent(
                BluetoothAdapter.ACTION_REQUEST_ENABLE);
        activity.startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        result.success(0);
    }


    public static boolean gotoPermissionSetting(Context context) {
        boolean success = true;
        Intent intent = new Intent();
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        String packageName =context.getPackageName();


        switch (Build.MANUFACTURER) {
            case "HUAWEI": // 华为
                intent.putExtra("packageName", packageName);
                intent.setComponent(new ComponentName("com.huawei.systemmanager", "com.huawei.permissionmanager.ui.MainActivity"));
                break;
            case "Meizu": // 魅族
                intent.setAction("com.meizu.safe.security.SHOW_APPSEC");
                intent.addCategory(Intent.CATEGORY_DEFAULT);
                intent.putExtra("packageName", packageName);
                break;
            case "Xiaomi": // 小米
                String rom = getMiuiVersion();
                if ("V6".equals(rom) || "V7".equals(rom)) {
                    intent.setAction("miui.intent.action.APP_PERM_EDITOR");
                    intent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity");
                    intent.putExtra("extra_pkgname", packageName);
                } else if ("V8".equals(rom) || "V9".equals(rom)) {
                    intent.setAction("miui.intent.action.APP_PERM_EDITOR");
                    intent.setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity");
                    intent.putExtra("extra_pkgname", packageName);
                } else {
//                    intent = getAppDetailsSettingsIntent(packageName);
                }
                break;
            case "Sony": // 索尼
                intent.putExtra("packageName", packageName);
                intent.setComponent(new ComponentName("com.sonymobile.cta", "com.sonymobile.cta.SomcCTAMainActivity"));
                break;
            case "OPPO": // OPPO
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.putExtra("packageName", BuildConfig.APPLICATION_ID);
                ComponentName comp = new ComponentName("com.color.safecenter", "com.color.safecenter.permission.PermissionManagerActivity");
                intent.setComponent(comp);
                break;
            case "Letv": // 乐视
                intent.putExtra("packageName", packageName);
                intent.setComponent(new ComponentName("com.letv.android.letvsafe", "com.letv.android.letvsafe.PermissionAndApps"));
                break;
            case "LG": // LG
                intent.setAction("android.intent.action.MAIN");
                intent.putExtra("packageName", packageName);
                intent.setComponent(new ComponentName("com.android.settings", "com.android.settings.Settings$AccessLockSummaryActivity"));
                break;
            default:
                intent.setAction(Settings.ACTION_SETTINGS);
                success = false;
                break;
        }
        try {
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
            // 跳转失败, 前往普通设置界面
            Uri packageURI = Uri.parse("package:" +packageName);
            intent =  new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,packageURI);
            context.  startActivity(intent);
            success = false;
        }
        return success;
    }

    private static String getMiuiVersion() {
        String propName = "ro.miui.ui.version.name";
        String line;
        BufferedReader input = null;
        try {
            Process p = Runtime.getRuntime().exec("getprop " + propName);
            input = new BufferedReader(
                    new InputStreamReader(p.getInputStream()), 1024);
            line = input.readLine();
            input.close();
        } catch (IOException ex) {
            ex.printStackTrace();
            return null;
        }

        return line;
    }
}
