//
//  MM.h
//  ReactiveCocoaDome
//
//  Created by yuchen on 2017/4/6.
//  Copyright © 2017年 yuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MM : NSObject
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *age;
+ (MM *)MMwithDic:(NSDictionary *)dic;
@end
