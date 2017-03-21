

#import <Foundation/Foundation.h>

@interface CheckPhoneNum : NSObject
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
+ (BOOL)stringContainsEmoji:(NSString *)string;
@end
