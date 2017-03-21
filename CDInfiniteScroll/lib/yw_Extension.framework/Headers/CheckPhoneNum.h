//
//  CheckPhoneNum.h
//  JuMiHang
//
//  Created by 楼顶 on 15/5/15.
//  Copyright (c) 2015年 Louding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckPhoneNum : NSObject
+ (BOOL)isMobileNumber:(NSString *)mobileNum;
+ (BOOL)stringContainsEmoji:(NSString *)string;
@end
