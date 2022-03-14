//
//  ExtSdkClientWrapper.m
//  
//
//  Created by 杜洁鹏 on 2019/10/8.
//

#import "ExtSdkClientWrapper.h"
#import "ExtSdkMethodTypeObjc.h"
#import "ExtSdkChatManagerWrapper.h"
#import "ExtSdkContactManagerWrapper.h"
#import "ExtSdkConversationWrapper.h"
#import "ExtSdkGroupManagerWrapper.h"
#import "ExtSdkChatroomManagerWrapper.h"
#import "ExtSdkPushManagerWrapper.h"
#import "ExtSdkToJson.h"
#import "ExtSdkUserInfoManagerWrapper.h"

@interface ExtSdkClientWrapper () <EMClientDelegate, EMMultiDevicesDelegate, FlutterPlugin>
@end

@implementation ExtSdkClientWrapper

static ExtSdkClientWrapper *wrapper = nil;


+ (ExtSdkClientWrapper *)sharedWrapper {
    return wrapper;
}

- (void)sendDataToFlutter:(NSDictionary *)aData {
    if (aData == nil) {
        return;
    }
    [self.channel invokeMethod:ExtSdkMethodKeySendDataToFlutter
                     arguments:aData];
}

+ (ExtSdkClientWrapper *)channelName:(NSString *)aChannelName
                       registrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[ExtSdkClientWrapper alloc] initWithChannelName:aChannelName registrar:registrar];
    });
    return wrapper;
}

- (instancetype)initWithChannelName:(NSString *)aChannelName
                          registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if(self = [super initWithChannelName:aChannelName
                               registrar:registrar]) {
        [registrar addApplicationDelegate:self];
    }
    return self;
}

#pragma mark - FlutterPlugin

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([ExtSdkMethodKeyInit isEqualToString:call.method])
    {
        [self initSDKWithDict:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyCreateAccount isEqualToString:call.method])
    {
        [self createAccount:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyLogin isEqualToString:call.method])
    {
        [self login:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyLogout isEqualToString:call.method])
    {
        [self logout:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyChangeAppKey isEqualToString:call.method])
    {
        [self changeAppKey:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyUploadLog isEqualToString:call.method])
    {
        [self uploadLog:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyCompressLogs isEqualToString:call.method])
    {
        [self compressLogs:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyGetLoggedInDevicesFromServer isEqualToString:call.method])
    {
        [self getLoggedInDevicesFromServer:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyKickDevice isEqualToString:call.method])
    {
        [self kickDevice:call.arguments result:result];
    }
    else if ([ExtSdkMethodKeyKickAllDevices isEqualToString:call.method])
    {
        [self kickAllDevices:call.arguments result:result];
    }
    else if([ExtSdkMethodKeyIsLoggedInBefore isEqualToString:call.method])
    {
        [self isLoggedInBefore:call.arguments result:result];
    }
    else if([ExtSdkMethodKeyCurrentUser isEqualToString:call.method])
    {
        [self getCurrentUser:call.arguments result:result];
    }
    else {
        [super handleMethodCall:call result:result];
    }
}

#pragma mark - Actions
- (void)initSDKWithDict:(NSDictionary *)param result:(FlutterResult)result {
    
    __weak typeof(self) weakSelf = self;
    
    EMOptions *options = [EMOptions fromJson:param];
//    options.enableConsoleLog = YES;
    [EMClient.sharedClient initializeSDKWithOptions:options];
    [EMClient.sharedClient addDelegate:self delegateQueue:nil];
    [EMClient.sharedClient addMultiDevicesDelegate:self delegateQueue:nil];
    [self registerManagers];
    // 如果有证书名，说明要使用Apns
    if (options.apnsCertName.length > 0) {
        [self _registerAPNs];
    }
    [weakSelf wrapperCallBack:result
                  channelName:ExtSdkMethodKeyInit
                        error:nil
                       object:@{
                           @"currentUsername": EMClient.sharedClient.currentUsername ?: @"",
                           @"isLoginBefore": @(EMClient.sharedClient.isLoggedIn)
                       }];
}


- (void)registerManagers {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    ExtSdkChatManagerWrapper * chatManagerWrapper = [[ExtSdkChatManagerWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_chat_manager")registrar:self.flutterPluginRegister];
    
    ExtSdkContactManagerWrapper * contactManagerWrapper = [[ExtSdkContactManagerWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_contact_manager") registrar:self.flutterPluginRegister];
    
    ExtSdkConversationWrapper *conversationWrapper = [[ExtSdkConversationWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_conversation") registrar:self.flutterPluginRegister];
    
    ExtSdkGroupManagerWrapper * groupManagerWrapper = [[ExtSdkGroupManagerWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_group_manager") registrar:self.flutterPluginRegister];
    
    ExtSdkChatroomManagerWrapper * chatroomManagerWrapper =[[ExtSdkChatroomManagerWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_chat_room_manager") registrar:self.flutterPluginRegister];
    
    ExtSdkPushManagerWrapper * pushManagerWrapper =[[ExtSdkPushManagerWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_push_manager") registrar:self.flutterPluginRegister];
    
    ExtSdkUserInfoManagerWrapper *userInfoManagerWrapper = [[ExtSdkUserInfoManagerWrapper alloc] initWithChannelName:ExtSdkChannelName(@"em_userInfo_manager") registrar:self.flutterPluginRegister];
    
#pragma clang diagnostic pop
    
}

- (void)createAccount:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient registerWithUsername:username
                                         password:password
                                       completion:^(NSString *aUsername, EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyCreateAccount
                            error:aError
                           object:aUsername];
    }];
}

- (void)login:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *pwdOrToken = param[@"pwdOrToken"];
    BOOL isPwd = [param[@"isPassword"] boolValue];
    
    if (isPwd) {
        [EMClient.sharedClient loginWithUsername:username
                                        password:pwdOrToken
                                      completion:^(NSString *aUsername, EMError *aError)
        {
            
            [weakSelf wrapperCallBack:result
                          channelName:ExtSdkMethodKeyLogin
                                error:aError
                               object:@{
                                   @"username": aUsername,
                                   @"token": EMClient.sharedClient.accessUserToken
            }];
        }];
    }else {
        [EMClient.sharedClient loginWithUsername:username
                                           token:pwdOrToken
                                      completion:^(NSString *aUsername, EMError *aError)
        {
            [weakSelf wrapperCallBack:result
                          channelName:ExtSdkMethodKeyLogin
                                error:aError
                               object:@{
                                   @"username": aUsername,
                                   @"token": EMClient.sharedClient.accessUserToken
                               }];
        }];
    }
}

- (void)logout:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    BOOL unbindToken = [param[@"unbindToken"] boolValue];
    [EMClient.sharedClient logout:unbindToken completion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyLogout
                            error:aError
                           object:@(!aError)];
    }];
}

- (void)changeAppKey:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *appKey = param[@"appKey"];
    EMError *aError = [EMClient.sharedClient changeAppkey:appKey];
    [weakSelf wrapperCallBack:result
                  channelName:ExtSdkMethodKeyChangeAppKey
                        error:aError
                       object:@(!aError)];
}


- (void)getCurrentUser:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    NSString* username = EMClient.sharedClient.currentUsername;
    [weakSelf wrapperCallBack:result
                  channelName:ExtSdkMethodKeyCurrentUser
                        error:nil
                       object:username];

}

- (void)uploadLog:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient uploadDebugLogToServerWithCompletion:^(EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyUploadLog
                            error:aError
                           object:nil];
    }];
}

- (void)compressLogs:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    [EMClient.sharedClient getLogFilesPathWithCompletion:^(NSString *aPath, EMError *aError) {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyCompressLogs
                            error:aError
                           object:aPath];
    }];
}

- (void)kickDevice:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    NSString *resource = param[@"resource"];
    
    [EMClient.sharedClient kickDeviceWithUsername:username
                                         password:password
                                         resource:resource
                                       completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyKickDevice
                            error:aError
                           object:nil];
    }];
}

- (void)kickAllDevices:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient kickAllDevicesWithUsername:username
                                             password:password
                                           completion:^(EMError *aError)
    {
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyKickAllDevices
                            error:aError
                           object:nil];
    }];
}

- (void)isLoggedInBefore:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self) weakSelf = self;
    [weakSelf wrapperCallBack:result
                  channelName:ExtSdkMethodKeyIsLoggedInBefore
                        error:nil
                       object:@(EMClient.sharedClient.isLoggedIn)];

}

- (void)onMultiDeviceEvent:(NSDictionary *)param result:(FlutterResult)result {
    
}


- (void)getLoggedInDevicesFromServer:(NSDictionary *)param result:(FlutterResult)result {
    __weak typeof(self)weakSelf = self;
    NSString *username = param[@"username"];
    NSString *password = param[@"password"];
    [EMClient.sharedClient getLoggedInDevicesFromServerWithUsername:username
                                                           password:password
                                                         completion:^(NSArray *aList, EMError *aError)
    {
        
        NSMutableArray *list = [NSMutableArray array];
        for (EMDeviceConfig *deviceInfo in aList) {
            [list addObject:[deviceInfo toJson]];
        }
        
        
        [weakSelf wrapperCallBack:result
                      channelName:ExtSdkMethodKeyGetLoggedInDevicesFromServer
                            error:aError
                           object:nil];
    }];
}

#pragma - mark ExtSdkClientDelegate

- (void)connectionStateDidChange:(EMConnectionState)aConnectionState {
    BOOL isConnected = aConnectionState == EMConnectionConnected;
    if (isConnected) {
        [self onConnected];
    }else {
        [self onDisconnected:2]; // 需要明确具体的code
    }
}

- (void)autoLoginDidCompleteWithError:(EMError *)aError {
    if (aError) {
        [self onDisconnected:1];  // 需要明确具体的code
    }else {
        [self onConnected];
    }
}

- (void)userAccountDidLoginFromOtherDevice {
    [self onDisconnected:206];
}

- (void)userAccountDidRemoveFromServer {
    [self onDisconnected:207];
}

- (void)userDidForbidByServer {
    [self onDisconnected:305];
}

- (void)userAccountDidForcedToLogout:(EMError *)aError {
    [self onDisconnected:1]; // 需要明确具体的code
}

#pragma mark - ExtSdkMultiDevicesDelegate

- (void)multiDevicesContactEventDidReceive:(EMMultiDevicesEvent)aEvent
                                  username:(NSString *)aUsername
                                       ext:(NSString *)aExt {
        
}

- (void)multiDevicesGroupEventDidReceive:(EMMultiDevicesEvent)aEvent
                                 groupId:(NSString *)aGroupId
                                     ext:(id)aExt {
    
}

#pragma mark - Merge Android and iOS Method
- (void)onConnected {
    [self.channel invokeMethod:ExtSdkMethodKeyOnConnected
                     arguments:@{@"connected" : @(YES)}];
}

- (void)onDisconnected:(int)errorCode {
    [self.channel invokeMethod:ExtSdkMethodKeyOnDisconnected
                     arguments:@{@"errorCode" : @(errorCode)}];
}


#pragma mark - register APNs
- (void)_registerAPNs {
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
//        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}

#pragma mark - AppDelegate

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    
//    return YES;
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    
//}


@end
