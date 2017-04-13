//
//  SendViewController.h
//  ReactiveCocoaDome
//
//  Created by yuchen on 2017/4/6.
//  Copyright © 2017年 yuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"
@interface SendViewController : UIViewController
@property (nonatomic,strong)RACSubject *delegateSingal;
@end
