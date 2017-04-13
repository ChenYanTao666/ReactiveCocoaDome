//
//  MM.m
//  ReactiveCocoaDome
//
//  Created by yuchen on 2017/4/6.
//  Copyright © 2017年 yuchen. All rights reserved.
//

#import "MM.h"

@implementation MM
+ (MM *)MMwithDic:(NSDictionary *)dic{
    MM *aMM = [[MM alloc]init];
    aMM.name = dic[@"name"];
    aMM.age = dic[@"age"];
    return aMM;
}
@end
