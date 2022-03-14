//
//  ExtSdkClientWrapper.h
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkClientWrapper : ExtSdkWrapper
+ (ExtSdkClientWrapper *)channelName:(NSString *)aChannelName
                       registrar:(NSObject<FlutterPluginRegistrar>*)registrar;

+ (ExtSdkClientWrapper *)sharedWrapper;
- (void)sendDataToFlutter:(NSDictionary *)aData;
@end

NS_ASSUME_NONNULL_END
