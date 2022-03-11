//
//  ExtSdkMethodType.m
//  im_flutter_sdk
//
//  Created by asterisk on 2022/3/11.
//

#import "ExtSdkMethodType.h"

@implementation ExtSdkMethodType

+ (int)getEnumValue:(nonnull NSString*)key {
    static NSDictionary * methodMap;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        methodMap =  @{
//            ExtSDkMethodKeyGetJoinedGroups:ExtSDkMethodKeyGetJoinedGroupsValue
        };
    });
    if (nil != key) {
        NSNumber* value = [methodMap valueForKey:key];
        if (nil != value) {
            return [value intValue];
        }
    }
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"invoke method type is not exist: %@", key]
                                 userInfo:nil];
    
    
}

//- (int)getValue {
//    return 0;
//}
//
//- (void)test {
//    switch ([self getValue:(ExtSDkMethodKeyGetJoinedGroups)]) {
//        case 1:
//
//            break;
//        case 2:
//
//            break;
//        case ExtSDkMethodKeyGetJoinedGroupsValue:
//
//            break;
//        default:
//            break;
//    }
//}

@end
