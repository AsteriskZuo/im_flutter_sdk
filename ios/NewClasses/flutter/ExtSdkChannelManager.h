#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

const NSString* _Nonnull const SEND_CHANNEL = @"com.easemob.im.ext.dart_to_native";
const NSString* _Nonnull const RECV_CHANNEL = @"com.easemob.im.ext.native_to_dart";

@interface ExtSdkChannelManager : NSObject

+ (nonnull instancetype)getInstance;

- (void)setRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar;

- (BOOL)add:(nonnull NSString *)name;

- (void)del:(nonnull NSString *)name;

- (nullable FlutterMethodChannel *)get:(nonnull NSString *)name;

@end
