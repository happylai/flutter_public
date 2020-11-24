#import "ZsFlutterDataPlugin.h"

@implementation ZsFlutterDataPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"zs_flutter_data"
            binaryMessenger:[registrar messenger]];
  ZsFlutterDataPlugin* instance = [[ZsFlutterDataPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
   if ([call.method isEqualToString:@"GB2312"]) {
       [self GB2312:call result:result];
       return;
   }
   result(FlutterMethodNotImplemented);
}

- (void)GB2312:(FlutterMethodCall *)call result:(FlutterResult)result   {
    NSString *str = call.arguments;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *newData = [self GB2312WithUTF8Data:data];

    result([FlutterStandardTypedData typedDataWithBytes:newData]);
}
- (NSData *)GB2312WithUTF8Data:(NSData *)UTF8Data
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *str = [[NSString alloc] initWithData:UTF8Data  encoding:NSUTF8StringEncoding];
    NSData *gb2312Data = [str dataUsingEncoding:enc ];
    return gb2312Data;
}

@end
