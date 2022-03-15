//
//  ExtSdkChatroomManagerWrapper.h
//  im_flutter_sdk
//
//  Created by easemob-DN0164 on 2019/10/18.
//

#import "ExtSdkWrapper.h"

NS_ASSUME_NONNULL_BEGIN
@interface ExtSdkChatroomManagerWrapper : ExtSdkWrapper

+ (nonnull instancetype)getInstance;

- (void)getChatroomsFromServer:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)createChatRoom:(NSDictionary *)param
                result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)joinChatRoom:(NSDictionary *)param
              result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)leaveChatRoom:(NSDictionary *)param
               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)destroyChatRoom:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)fetchChatroomFromServer:(NSDictionary *)param
                         result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getChatRoom:(NSDictionary *)param
             result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getAllChatRooms:(NSDictionary *)param
                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getChatroomMemberListFromServer:(NSDictionary *)param
                                 result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)fetchChatroomBlockListFromServer:(NSDictionary *)param
                                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)getChatroomMuteListFromServer:(NSDictionary *)param
                               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)fetchChatroomAnnouncement:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomUpdateSubject:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomUpdateDescription:(NSDictionary *)param
                           result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomRemoveMembers:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomBlockMembers:(NSDictionary *)param
                      result:(nonnull id<ExtSdkCallbackObjc>)result;
- (void)chatRoomUnblockMembers:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)changeChatRoomOwner:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomAddAdmin:(NSDictionary *)param
                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomRemoveAdmin:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomMuteMembers:(NSDictionary *)param
                     result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)chatRoomUnmuteMembers:(NSDictionary *)param
                       result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)updateChatRoomAnnouncement:(NSDictionary *)param
                            result:(nonnull id<ExtSdkCallbackObjc>)result;

// TODO: chatroom white list.
- (void)addMembersToChatRoomWhiteList:(NSDictionary *)param
                               result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)removeMembersFromChatRoomWhiteList:(NSDictionary *)param
                                    result:
                                        (nonnull id<ExtSdkCallbackObjc>)result;

- (void)isMemberInChatRoomWhiteListFromServer:(NSDictionary *)param
                                       result:(nonnull id<ExtSdkCallbackObjc>)
                                                  result;

- (void)fetchChatRoomWhiteListFromServer:(NSDictionary *)param
                                  result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)muteAllChatRoomMembers:(NSDictionary *)param
                        result:(nonnull id<ExtSdkCallbackObjc>)result;

- (void)unMuteAllChatRoomMembers:(NSDictionary *)param
                          result:(nonnull id<ExtSdkCallbackObjc>)result;

@end

NS_ASSUME_NONNULL_END
