#import "ZsPermissonPlugin.h"

@implementation ZsPermissonPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"zs_permisson"
            binaryMessenger:[registrar messenger]];
  ZsPermissonPlugin* instance = [[ZsPermissonPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

    if ([call.method isEqualToString:@"openBluetoothPmission"]) {
        [self openBluetoothPmission:call result:result];
        return;
    }
    
    if ([call.method isEqualToString:@"openBluetooth"]) {
        [self openBluetooth:call result:result];
        return;
    }
}

// 跳转蓝牙权限
- (void)openBluetoothPmission:(FlutterMethodCall *)call result:(FlutterResult)result  {
    [self openSetting];
 }

// 打开蓝牙
- (void)openBluetooth:(FlutterMethodCall *)call result:(FlutterResult)result  {
    
    // 9以下的
    NSData *data1 = [[NSData alloc] initWithBytes:(unsigned char []){0x50,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x42,0x6c,0x75,0x65,0x74,0x6f,0x6f,0x74,0x68} length:20];
    
    // 10上的
    NSData *data2 = [[NSData alloc] initWithBytes:(unsigned char []){0x41,0x70,0x70,0x2d,0x50,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x42,0x6c,0x75,0x65,0x74,0x6f,0x6f,0x74,0x68} length:24];
    
    
    for (NSData *data in @[data2, data1]) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"结果:%@", str);
        
        NSURL *url = [NSURL URLWithString: str];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            return;
        }
    }
    
    
}

- (void)openSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
