package com.zsxj.zs_permisson;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ZsPermissonPlugin */
public class ZsPermissonPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private final static int REQUEST_ENABLE_BT = 10001;

  private MethodChannel channel;
  private Activity activity;
  private Result permossion_result;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "zs_permisson");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "checkLocationPermission":
        boolean bol = PermissionPlugin.checkLocationPermission(call, result, activity);
        if (bol == false) {
          permossion_result = result;
        }
        break;
      case "checkLocationState":
        PermissionPlugin.checkLocationState(call, result, activity);
        break;
      case "checkBLuetoothState":
        PermissionPlugin.checkBLuetoothState(call, result);
        break;
      case "openLocationPermission":
        PermissionPlugin.openLocationPermission(call, result, activity);
        break;
      case "openLocationState":
        PermissionPlugin.openLocationState(call, result, activity);
        break;
      case "openBluetooth":
        PermissionPlugin.openBluetooth(call, result, activity);
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

    if (requestCode == REQUEST_ENABLE_BT) {

      if (permossion_result == null) {
        return true;
      }

      if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        //蓝牙权限开启成功
        permossion_result.success(0);
        Log.d("--->", "蓝牙权限开启成功");
      } else {
        permossion_result.success(-1);
        Log.d("--->", "蓝牙权限开启失败");
      }

      permossion_result = null;
    }

    return true;
  }
}
