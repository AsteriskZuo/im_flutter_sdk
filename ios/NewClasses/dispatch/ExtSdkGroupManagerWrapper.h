//
//  ExtSdkGroupManagerWrapper.h
//  FlutterTest
//
//  Created by 杜洁鹏 on 2019/10/17.
//  Copyright © 2019 Easemob. All rights reserved.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtSdkGroupManagerWrapper : ExtSdkWrapper

+ (nonnull instancetype)getInstance;

- (void)getGroupWithId:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getJoinedGroups:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupsWithoutPushNotification:(NSDictionary *)param
                                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getJoinedGroupsFromServer:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getPublicGroupsFromServer:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)createGroup:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupSpecificationFromServer:(NSDictionary *)param
                                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupMemberListFromServer:(NSDictionary *)param
                              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupBlockListFromServer:(NSDictionary *)param
                             result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupMuteListFromServer:(NSDictionary *)param
                            result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupWhiteListFromServer:(NSDictionary *)param
                             result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)isMemberInWhiteListFromServer:(NSDictionary *)param
                               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getGroupFileListFromServer:(NSDictionary *)param
                            result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)getGroupAnnouncementFromServer:(NSDictionary *)param
                                result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)addMembers:(NSDictionary *)param
            result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)inviterUser:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)removeMembers:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)blockMembers:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)unblockMembers:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateGroupSubject:(NSDictionary *)param
                    result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateDescription:(NSDictionary *)param
                   result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)leaveGroup:(NSDictionary *)param
            result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)destroyGroup:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)blockGroup:(NSDictionary *)param
            result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)unblockGroup:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateGroupOwner:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)addAdmin:(NSDictionary *)param
          result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)removeAdmin:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)muteMembers:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)unMuteMembers:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)muteAllMembers:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)unMuteAllMembers:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)addWhiteList:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)removeWhiteList:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

// TODO: dujiepeng.
- (void)uploadGroupSharedFile:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)downloadGroupSharedFile:(NSDictionary *)param
                         result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)removeGroupSharedFile:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateGroupAnnouncement:(NSDictionary *)param
                         result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateGroupExt:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)joinPublicGroup:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)requestToJoinPublicGroup:(NSDictionary *)param
                          result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)acceptJoinApplication:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)declineJoinApplication:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)acceptInvitationFromGroup:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)declineInvitationFromGroup:(NSDictionary *)param
                            result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)ignoreGroupPush:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

@end

NS_ASSUME_NONNULL_END
