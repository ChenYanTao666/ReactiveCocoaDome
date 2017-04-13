//
//  SendViewController.m
//  ReactiveCocoaDome
//
//  Created by yuchen on 2017/4/6.
//  Copyright © 2017年 yuchen. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textF;
@property (weak, nonatomic) IBOutlet UIButton *sendBut;

@end

@implementation SendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [[_sendBut rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        @strongify(self);
        if (self.delegateSingal) {
            [self.delegateSingal sendNext:self.textF.text];
        }
        
    }];
    
    
    
    // 常见的宏
    // RAC 用于给某个对象的属性绑定
    RAC(self.sendBut.titleLabel,text) = self.textF.rac_textSignal;
    
    //RACObserve(self, name):监听某个对象的某个属性,返回的是信号。
    [RACObserve(self.view, center)subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // @weakify(self); @strongify(self);
    // RACTuplePack：把数据包装成RACTuple（元组类）
    // 把参数中的数据包装成元组
    RACTuple *tuple1 = RACTuplePack(@10,@20);
   //RACTupleUnpack：把RACTuple（元组类）解包成对应的数据。
   // 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@"xmg",@20);
    // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
    // name = @"xmg" age = @20
    RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
    NSLog(@"%@ %@",name,age);
   
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
