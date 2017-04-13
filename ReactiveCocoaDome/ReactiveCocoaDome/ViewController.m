//
//  ViewController.m
//  ReactiveCocoaDome
//
//  Created by yuchen on 2017/4/6.
//  Copyright © 2017年 yuchen. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "SendViewController.h"
#import "MM.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *pushbut;
@property (nonatomic,copy) NSString *value;
@property (nonatomic,copy) NSString *valueA;
@property (nonatomic,copy) NSString *valueB;
@property (nonatomic,strong)RACCommand *command ;
@property (nonatomic,strong)UIImageView *imageView;
@end

@implementation ViewController
// 文章中列举的用例都是集百家之所长 希望能让你对RAC有个初步的认识
- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建信号
    [self creatSingal];
   
    // RACSubject替换代理 回调或传值
    [self creatDelegateSingal];

    // RACSequence和RACTuple  数组和字典
    [self useRACTupleAndRACSequence];
    
    //RACCommand使用
    [self useRACCommand];
    
    // RACMulticastConnection使用步骤(多个订阅者的时候不用多次发送)
    [self useRACMulticastConnection];
    
   //  RACScheduler:RAC中的队列，用GCD封装的
    [self useRACScheduler];
    
    // Reactive 常见用法
    [self useReactive];
   // 常用的模式
    [self CommonMode];
    
   // RAC 简单示例
    [self simpleExample];
    
}






- (void)creatSingal{
    // 1.创建信号
    
    /**
     RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
     RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
     */
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block调用时刻：每当有订阅者订阅信号，就会调用block。
        
        // 2.发送信号
        [subscriber sendNext:@1];
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            
            // 执行完Block后，当前信号就不在被订阅了。
            
            NSLog(@"信号被销毁");
            
        }];
    }];
    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
    
    
    
    
    /*
     RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
     使用场景:通常用来代替代理，有了它，就不必要定义代理了。
     RACReplaySubject:重复提供信号类，RACSubject的子类。
     RACReplaySubject与RACSubject区别:
     RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
     使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类。
     使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
     */
    // RACSubject使用步骤
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 sendNext:(id)value
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];
    
    
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    [replaySubject sendCompleted];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];
    
   
    RACDisposable * dispose = [RACDisposable disposableWithBlock:^{
        NSLog(@"replaySubject 销毁了");
      
    }];
    RACCompoundDisposable * compoundDispose = [RACCompoundDisposable compoundDisposableWithDisposables:@[dispose]];
    [replaySubject didSubscribeWithDisposable:compoundDispose];
    

}
- (void)creatDelegateSingal{
    @weakify(self);
    // button 添加行为
//    [[_pushbut rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
//        @strongify(self);
//        SendViewController *sendV = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SendViewController"];
//        sendV.delegateSingal = [RACSubject subject];
//        [sendV.delegateSingal subscribeNext:^(id x) {
//            NSLog(@"点击了通知按钮 %@",x);
//        }];
//        [self.navigationController pushViewController:sendV animated:YES];
//        
//    }];
//
    
    // 这种方法添加的行为可以在触发的时候的时候发送信号
    _pushbut.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        SendViewController *sendV = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"SendViewController"];
        sendV.delegateSingal = [RACSubject subject];
        [sendV.delegateSingal subscribeNext:^(id x) {
            NSLog(@"点击了通知按钮 %@",x);
        }];
        [self.navigationController pushViewController:sendV animated:YES];
        return [RACSignal empty];
    }];
    
    
}

- (void)useRACTupleAndRACSequence{
    // RACTuple:元组类,类似NSArray,用来包装值.
    // RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        
        NSLog(@"数组元素 %@",x);
    }];
   
    // 2.遍历字典,遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        
        // 相当于以下写法
        //        NSString *key = x[0];
        //        NSString *value = x[1];
        NSLog(@"元组对象 x == %@", x);
        NSLog(@"字典转化为 %@ %@",key,value);
        
    }];
    
    
    // 3.字典转模型
    // 3.1 OC写法
 
    NSArray *dictArr =   @[@{@"name":@"冰冰",@"age":@18},@{@"name":@"圆圆",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18},@{@"name":@"MM",@"age":@18}] ;
    
    for (NSDictionary *dict in dictArr) {
        // 将dict 转换成model
    }
    
    // 3.2 RAC写法
   
   
    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        // 运用RAC遍历字典，x：字典
        // 将dict 转换成model
        
    }];
   
    // 3.3 RAC高级写法:

    // map:映射的意思，目的：把原始值value映射成一个新值
    // array: 把集合转换成数组
    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
    NSArray *MMs = [[dictArr.rac_sequence map:^id(id value) {
        
        return [MM MMwithDic:value];
        
    }] array];
    
    
    NSLog(@"转化后 MMs == %@",MMs);
    
    
    
    
}

//  RACCommand:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程
- (void)useRACCommand{

    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
    // 1.signalBlock必须要返回一个信号，不能传nil.
    // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    // 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
    // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求
    
    
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        
        
        NSLog(@"执行命令");
        // 创建空信号,必须返回信号
        //        return [RACSignal empty];
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
           
          
            [subscriber sendNext:@"发送数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
        
    }];
    
    // 强引用命令，不要被销毁，否则接收不到数据
    _command = command;
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
        
        [x subscribeNext:^(id x) {
            
            NSLog(@"x1= %@",x);
        }];
        
    }];
    
    // RAC高级用法
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"x2= %@",x);
    }];
    
    // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
            
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
        
    }];
    // 5.执行命令
    [self.command execute:@1];
    
    
}
//RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
- (void)useRACMulticastConnection{
    // RACMulticastConnection使用步骤:
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.创建连接 RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
    // 4.连接 [connect connect]
    
    // RACMulticastConnection底层原理:
    // 1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
    // 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
    // 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
    // 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
    // 3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
    // 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
    // 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
    
    
    // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
    // 解决：使用RACMulticastConnection就能解决.
    
    // 1.创建请求信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        NSLog(@"发送请求1");
        [subscriber sendNext:@"aaa"];
        [subscriber sendCompleted];
        return nil;
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        
        NSLog(@"接收数据1");
        
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id x) {
        
        NSLog(@"接收数据2");
        
    }];
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    
    // RACMulticastConnection:解决重复请求问题
    
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@"bbb"];
        [subscriber sendCompleted];
        NSLog(@"发送请求2");
        
        return nil;
    }];
    // 2.创建连接
    RACMulticastConnection *connect = [signal1 publish];
    
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者一信号");
        
    }];
    
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者二信号");
        
    }];
    
    // 4.连接,激活信号
    [connect connect];
    
}
- (void)useRACScheduler{
    [[RACScheduler immediateScheduler]schedule:^{
        NSLog(@"2 %@",[RACScheduler currentScheduler]);
    }];
    [[RACScheduler immediateScheduler]scheduleRecursiveBlock:^(void (^reschedule)(void)) {
        NSLog(@"3%@",[RACScheduler currentScheduler]);
    }];
    
    [[RACScheduler mainThreadScheduler]schedule:^{
        NSLog(@"4%@",[RACScheduler currentScheduler]);
        
    }];
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]schedule:^{
        NSLog(@"5%@",[RACScheduler currentScheduler]);
    }];
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityLow]schedule:^{
        NSLog(@"6%@",[RACScheduler currentScheduler]);
    }];
    [[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground name:@"ceshi"]schedule:^{
        NSLog(@"7%@",[RACScheduler currentScheduler]);
    }];
    [[RACScheduler scheduler]schedule:^{
        NSLog(@"8%@",[RACScheduler currentScheduler]);
    }];
    
    [[RACScheduler immediateScheduler]afterDelay:13 schedule:^{
        NSLog(@"1%@",[RACScheduler currentScheduler]);
    }];
    

}

- (void)useReactive{
    UIButton *redV = [UIButton buttonWithType:UIButtonTypeCustom];
    // 1.代替代理
    // 需求：自定义redView,监听红色view中按钮点击
    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
    [[redV rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"点击红色按钮");
    }];
    
    // 2.KVO
    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
    // observer:可以传入nil
    [[redV rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    // 3.监听事件
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    [[redV rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        NSLog(@"按钮被点击了");
    }];
    
    // 4.代替通知
    // 把监听到的通知转换信号
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
    UITextField *textF;
    // 5.监听文本框的文字改变
    [textF.rac_textSignal subscribeNext:^(id x) {
        
        NSLog(@"文字改变了%@",x);
    }];
    
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
    
    // 把多个信号合并 全部发送信号 才触发
    [[RACSignal combineLatest:@[request1,request2]]subscribeNext:^(RACTuple *x) {
        NSLog(@"%@ %@",[x objectAtIndexedSubscript:0],[x objectAtIndexedSubscript:1]);
        
    }];
    
    
    // 定时器
    RACSignal *singal = [[[[[RACSignal interval:1 onScheduler:[RACScheduler scheduler]]take:10]startWith:@(1)]map:^id(id value) {
        NSLog(@"%@",value);
        return @"发送出去的信号";
    }]takeUntil:self.rac_willDeallocSignal];
    [singal subscribeNext:^(id x) {
        NSLog(@"x == %@",x);
    }];
    
//    // 图片加载完成之后才能显示button
//    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    RACSignal *imageAvailableSignal = [RACObserve(self, imageView.image) map:id^(id x){return x ? @YES : @NO}];
//    shareButton.rac_command = [[RACCommand alloc] initWithEnabled:imageAvailableSignal signalBlock:^RACSignal *(id input) {
//        // do share logic
//    }];
    
    


}

- (void)simpleExample{
    // 1.观察值的变化
    @weakify(self);
    [RACObserve(self, value)subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"value 发生了变化%@",self.value);
    }];
    //2.单边相应
    //创建一个信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"跳舞"];
        [subscriber sendCompleted];
        return [RACScopedDisposable disposableWithBlock:^{
            
        }];
    }];
    //对信号进行改进
    RAC(self,value) = [signalA map:^id(id value) {
        if ([value isEqualToString:@"跳舞"]) {
            return @"唱歌";
        }
        return @"";
    }];
    // 双边响应
    
    //创建2个通道，一个从A流出的通道A和一个从B流出的通道B
    RACChannelTerminal *channelA = RACChannelTo(self, valueA);
    RACChannelTerminal *channelB = RACChannelTo(self, valueB);
    //改造通道A，使通过通道A的值，如果等于"西"，就改为"东"传出去
    [[channelA map:^id(NSString *value) {
        if ([value isEqualToString:@"西"]) {
            return @"东";
        }
        return value;
    }] subscribe:channelB];//通道A流向B
    //改造通道B，使通过通道B的值，如果等于"左"，就改为"右"传出去
    [[channelB map:^id(NSString *value) {
        if ([value isEqualToString:@"左"]) {
            return @"右";
        }
        return value;
    }] subscribe:channelA];//通道B流向A
    //KVO监听valueA的值得改变，过滤valueA的值，返回YES表示通过
    
    [[RACObserve(self, valueA) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"你向%@", x);
    }];
    //KVO监听valueB的值得改变，过滤valueB的值，返回YES表示通过
    [[RACObserve(self, valueB) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"他向%@", x);
    }];
    //下面使valueA的值和valueB的值发生改变
    self.valueA = @"西";
    self.valueB = @"左";
    
    
    // 4.代理
    //代理定义
//    @protocol ProgrammerDelegate
//    - (void)makeAnApp;
//    @end
//    /****************************************/
//    //为self添加一个信号，表示代理ProgrammerDelegate的makeAnApp方法信号
//    RACSignal *programmerSignal = [self rac_signalForSelector:@selector(makeAnApp)
//                                                 fromProtocol:@protocol(ProgrammerDelegate)];
//    //设置代理方法makeAnApp的实现
//    [programmerSignal subscribeNext:^(RACTuple* x) {
//        //这里可以理解为makeAnApp的方法要的执行代码
//        NSLog(@"花了一个月，app写好了");
//    }];
//    //调用代理方法
//    [self makeAnApp];
    
    
    //5. 广播
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //注册广播通知
    RACSignal *signal = [center rac_addObserverForName:@"代码之道频道" object:nil];
    //设置接收到通知的回调处理
    [signal subscribeNext:^(NSNotification* x) {
        NSLog(@"技巧：%@", x.userInfo[@"技巧"]);
    }];
    //发送广播通知
    [center postNotificationName:@"代码之道频道"
                          object:nil
                        userInfo:@{@"技巧":@"用心写"}];
    
    
    //6.串联
    //创建一个信号管A
    {
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            //发送一个Next玻璃球和一个Complete玻璃球
            [subscriber sendNext:@"我恋爱啦"];
            [subscriber sendCompleted];
            return nil;
        }];
        //创建一个信号管B
        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            //发送一个Next玻璃球和一个Complete玻璃球
            [subscriber sendNext:@"我结婚啦"];
            [subscriber sendCompleted];
            return nil;
        }];
        //串联管A和管B
        RACSignal *concatSignal = [signalA concat:signalB];
        //串联后的接收端处理
        [concatSignal subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
        //打印：我恋爱啦 我结婚啦
   
    }
    
    //7. 并联
    {
        //创建信号A
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            [subscriber sendNext:@"纸厂污水"];
            return nil;
        }];
        //创建信号B
        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            [subscriber sendNext:@"电镀厂污水"];
            return nil;
        }];
        //并联2个信号
        RACSignal *mergeSignal = [RACSignal merge:@[signalA, signalB]];
        [mergeSignal subscribeNext:^(id x) {
            NSLog(@"处理%@",x);
        }];
    }
    
//   8. 组合
    {
        //定义2个自定义信号
        RACSubject *letters = [RACSubject subject];
        RACSubject *numbers = [RACSubject subject];
        //组合信号
        [[RACSignal combineLatest:@[letters, numbers]
                           reduce:^(NSString *letter, NSString *number){
                               //把2个信号的信号值进行字符串拼接
                               return [letter stringByAppendingString:number];
                           }] subscribeNext:^(NSString * x) {
                               NSLog(@"%@", x);
                           }];
        //自己控制发送信号值
        [letters sendNext:@"A"];
        [letters sendNext:@"B"];
        [numbers sendNext:@"1"];//打印B1
        [letters sendNext:@"C"];//打印C1
        [numbers sendNext:@"2"];//打印C2
    }
    
    // 9.合流压缩
    {
        //创建信号A
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            [subscriber sendNext:@"红"];
            [subscriber sendNext:@"黄"];
            return nil;
        }];
        //创建信号B
        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            [subscriber sendNext:@"白"];
            [subscriber sendNext:@"黑"];
            return nil;
        }];
        //合流后出来的是压缩包，需要解压才能取到里面的值
        [[signalA zipWith:signalB] subscribeNext:^(RACTuple* x) {
            //解压缩
            RACTupleUnpack(NSString *stringA, NSString *stringB) = x;
            NSLog(@"我们是%@%@的", stringA, stringB);
        }];
        //打印：我们是红白的
    }
    
    // 10. 映射
    {
        //创建信号，发送"石"玻璃球
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            [subscriber sendNext:@"石"];
            return nil;
        }];
        //对信号进行改造，改造"石"为"金"
        signal = [signal map:^id(NSString *value) {
            if ([value isEqualToString:@"石"]) {
                return @"金";
            }
            return value;
        }];
        //打印
        [signal subscribeNext:^(id x) {
            NSLog(@"%@", x);//金
        }];
    }
    
    // 过滤
    {
        //创建信号
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            [subscriber sendNext:@(15)];
            [subscriber sendNext:@(17)];
            [subscriber sendNext:@(21)];
            [subscriber sendNext:@(14)];
            [subscriber sendNext:@(30)];
            return nil;
        }];
        //过滤信号，并打印
        [[signal filter:^BOOL(NSNumber* value) {
            //值大于等于18的才能通过过滤网
            return value.integerValue >= 18;
        }] subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
        //打印：21 30
    }
    
    // 秩序
    
    {
        //创建一个信号
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            NSLog(@"打蛋液");
            [subscriber sendNext:@"蛋液"];
            [subscriber sendCompleted];
            return nil;
        }];
        //对信号进行秩序执行第一步
        signal = [signal flattenMap:^RACStream *(NSString* value) {
            //处理上一步的RACSignal的信号值value，这里value = @"蛋液"
            NSLog(@"把%@倒进锅里面煎",value);
            //返回下一步的RACSignal信号
            return [RACSignal createSignal:^RACDisposable *(id subscriber) {
                [subscriber sendNext:@"煎蛋"];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
        //对信号进行秩序执行第二步
        signal = [signal flattenMap:^RACStream *(NSString* value) {
            //处理上一步的RACSignal的信号值value，这里value = @"煎蛋"
            NSLog(@"把%@装到盘里", value);
            //返回下一步的RACSignal信号
            return [RACSignal createSignal:^RACDisposable *(id subscriber) {
                [subscriber sendNext:@"上菜"];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
        //最后打印
        [signal subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
        /* 
         打印：
         打蛋液  
         把蛋液倒进锅里面煎  
         把煎蛋装到盘里  
         上菜
         */
    }
    
    
    
    // 命令
    {
        //创建命令
        RACCommand *aCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *input) {
            //命令执行代码
            NSLog(@"%@我投降了",input);
            //返回一个RACSignal信号
            return [RACSignal createSignal:^RACDisposable *(id subscriber) {
                [subscriber sendCompleted];
                return nil;
            }];
        }];
        //执行命令
        [aCommand execute:@"今天"];
        //打印：今天我投降了
    }
    
    
    // 延迟
    
    {
        //创建一个信号
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            NSLog(@"等等我，我还有10秒钟就到了");
            [subscriber sendNext:@"车陂南"];
            [subscriber sendCompleted];
            return nil;
        }];
        //延时10秒接受Next玻璃球
        [[signal delay:10] subscribeNext:^(NSString *x) {
            NSLog(@"我到了%@",x);
        }];
        /*
         [2016-04-21 13:20:10]等等我，我还有10秒钟就到了
         [2016-04-21 13:20:20]我到了车陂南
         */
    }
    
    // 重放
    
    {
    
        //创建一个普通信号
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            NSLog(@"大导演拍了一部电影《我的男票是程序员》");
            [subscriber sendNext:@"《我的男票是程序员》"];
            return nil;
        }];
        //创建该普通信号的重复信号
        RACSignal *replaySignal = [signal replay];
        //重复接受信号
        [replaySignal subscribeNext:^(NSString *x) {
            NSLog(@"小明看了%@", x);
        }];
        [replaySignal subscribeNext:^(NSString *x) {
            NSLog(@"小红也看了%@", x);
        }];
        /*
         大导演拍了一部电影《我的男票是程序员》
         小明看了《我的男票是程序员》
         小红也看了《我的男票是程序员》
         */
    }
    
    //  定时
    
    {
        //创建定时器信号，定时8个小时
        RACSignal *signal = [RACSignal interval:60*60*8
                                    onScheduler:[RACScheduler mainThreadScheduler]];
        //定时执行代码
        [signal subscribeNext:^(id x) {
            NSLog(@"吃药");
        }];
    }
    
    // 超时
    
    {
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            //创建发送信息信号
            NSLog(@"我快到了");
            RACSignal *sendSignal = [RACSignal createSignal:^RACDisposable *(id sendSubscriber) {
                [sendSubscriber sendNext:nil];
                [sendSubscriber sendCompleted];
                return nil;
            }];
            //发送信息要1个小时10分钟才到
            [[sendSignal delay:60*70] subscribeNext:^(id x) {
                //这里才发送Next玻璃球到signal
                [subscriber sendNext:@"我到了"];
                [subscriber sendCompleted];
            }];
            return nil;
        }];
        //这里对signal进行超时接受处理，如果1个小时都没收到玻璃球，超时错误
        [[signal timeout:60*60
             onScheduler:[RACScheduler mainThreadScheduler] ]
         subscribeError:^(NSError *error)
        {
            //超时错误处理
            NSLog(@"等了你一个小时了，你还没来，我走了");
        }];
    }
    
    // 重试
    
    {
        __block int failedCount = 0;
        //创建信号
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            if (failedCount < 100) {
                failedCount++;
                NSLog(@"我失败了");
                //发送错误，才会要重试
                [subscriber sendError:nil];
            } else {
                NSLog(@"经历了数百次失败后");
                [subscriber sendNext:nil];
            }
            return nil;
        }];
        //重试
        RACSignal *retrySignal = [signal retry];
        //直到发送了Next玻璃球
        [retrySignal subscribeNext:^(id x) {
            NSLog(@"终于成功了");
        }];
    }
    
    // 节流
    
    {
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            //即时发送一个Next玻璃球
            [subscriber sendNext:@"旅客A"];
            //下面是GCD延时发送Next玻璃球
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1 * NSEC_PER_SEC)),mainQueue, ^{
                [subscriber sendNext:@"旅客B"];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2 * NSEC_PER_SEC)),mainQueue, ^{
                //发送多个Next，如果节流了，接收最新发送的
                [subscriber sendNext:@"旅客C"];
                [subscriber sendNext:@"旅客D"];
                [subscriber sendNext:@"旅客E"];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(3 * NSEC_PER_SEC)),mainQueue, ^{
                [subscriber sendNext:@"旅客F"];
            });
            return nil;
        }];
        //对信号进行节流，限制短时间内一次只能接收一个Next玻璃球
        [[signal throttle:1] subscribeNext:^(id x) {
            NSLog(@"%@通过了",x);
        }];
        /*
         [2015-08-16 22:08:45.677]旅客A  
         [2015-08-16 22:08:46.737]旅客B  
         [2015-08-16 22:08:47.822]旅客E  
         [2015-08-16 22:08:48.920]旅客F
         */
    }
    
    // 条件
    
    {
        //创建取值信号
        RACSignal *takeSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            //创建一个定时器信号，每隔1秒触发一次
            RACSignal *signal = [RACSignal interval:1
                                        onScheduler:[RACScheduler mainThreadScheduler]];
            //定时接收
            [signal subscribeNext:^(id x) {
                //在这里定时发送Next玻璃球
                [subscriber sendNext:@"直到世界的尽头才能把我们分开"];
            }];
            return nil;
        }];
        //创建条件信号
        RACSignal *conditionSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
            //设置5秒后发生Complete玻璃球
        
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"世界的尽头到了");
                [subscriber sendCompleted];
            });
            return nil;
        }];
        //设置条件，takeSignal信号在conditionSignal信号接收完成前，不断地取值
        [[takeSignal takeUntil:conditionSignal] subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
        /*
         [2015-08-16 22:17:22.648]直到世界的尽头才能把我们分开
         [2015-08-16 22:17:23.648]直到世界的尽头才能把我们分开  
         [2015-08-16 22:17:24.645]直到世界的尽头才能把我们分开  
         [2015-08-16 22:17:25.648]直到世界的尽头才能把我们分开  
         [2015-08-16 22:17:26.644]直到世界的尽头才能把我们分开  
         [2015-08-16 22:17:26.645]世界的尽头到了
         */
    }
}














//、、常用的模式
- (void)CommonMode{
    
//    map + switchToLatest
   
//switchToLatest:的作用是自动切换signal of signals到最后一个，比如之前的command.executionSignals就可以使用switchToLatest:。
//map:的作用很简单，对sendNext的value做一下处理，返回一个新的值。
//    如果把这两个结合起来就有意思了，想象这么个场景，当用户在搜索框输入文字时，需要通过网络请求返回相应的hints，每当文字有变动时，需要取消上一次的请求，就可以使用这个配搭。这里用另一个Demo，简单演示一下
    
   // NSArray *pins = @[@172230988, @172230947, @172230899, @172230777, @172230707];
//__block NSInteger index = 0;
//     RACSignal *signal = [[[[RACSignal interval:0.1 onScheduler:[RACScheduler scheduler]]
//                           take:pins.count]
//                          map:^id(id value) {
//                            NSLog(@"这里只会执行一次");
//                              if (value) {
//                               return @1;
//                              }
//                              return @0;
//                          }]
//                         switchToLatest];
    
  
    
//    [signal subscribeNext:^( id x) {
//        NSLog(@"pinID:%@", x);
//    } completed:^{
//        NSLog(@"completed");
//    }];
    // output
    // 2014-06-05 17:40:49.851 这里只会执行一次
    // 2014-06-05 17:40:49.851 pinID:172230707
    // 2014-06-05 17:40:49.851 completed
    
    
    
    
//    常见场景的处理
//    检查本地缓存，如果失效则去请求网络数据并缓存到本地
    
    
    
    
//    
//    来源
//    
//    - (RACSignal *)loadData {
//        return [[RACSignal
//                 createSignal:^(id<RACSubscriber> subscriber) {
//
//                     if (self.cacheValid) {
//                         [subscriber sendNext:self.cachedData];
//                         [subscriber sendCompleted];
//                     } else {
//                         [subscriber sendError:self.staleCacheError];
//                     }
//                 }]
//
//                subscribeOn:[RACScheduler scheduler]];
//    }
//    
//    - (void)update {
//        [[[[self
//            loadData]
//
//           catch:^(NSError *error) {
//               return [[self updateCachedData] doNext:^(id data) {
//                   [self cacheData:data];
//               }];
//           }]
//
    
//             [[RACSignal interval:updateInterval] take:1] subscribeNext:^(id _) {
//                 [self update];
//             }];
//         }]; 
//    }
//    
    
//
    
    
    
//    检测用户名是否可用  //throttle表示interval时间内如果有sendNext，则放弃该nextValue
    
    
    

//   - (void)setupUsernameAvailabilityChecking {
//        RAC(self, availabilityStatus) = [[[RACObserve(self.userTemplate, username)
//                                           throttle:kUsernameCheckThrottleInterval] //throttle表示interval时间内如果有sendNext，则放弃该nextValue
//                                          map:^(NSString *username) {
//                                              if (username.length == 0) return [RACSignal return:@(UsernameAvailabilityCheckStatusEmpty)];
//                                              return [[[[[FIBAPIClient sharedInstance]
//                                                         getUsernameAvailabilityFor:username ignoreCache:NO]
//                                                        map:^(NSDictionary *result) {
//                                                            NSNumber *existsNumber = result[@"exists"];
//                                                            if (!existsNumber) return @(UsernameAvailabilityCheckStatusFailed);
//                                                            UsernameAvailabilityCheckStatus status = [existsNumber boolValue] ? UsernameAvailabilityCheckStatusUnavailable : UsernameAvailabilityCheckStatusAvailable;
//                                                            return @(status);
//                                                        }]
//                                                       catch:^(NSError *error) {
//                                                           return [RACSignal return:@(UsernameAvailabilityCheckStatusFailed)];
//                                                       }] startWith:@(UsernameAvailabilityCheckStatusChecking)];
//                                          }]
//                                         switchToLatest];
//    }
//    
//    可以看到这里也使用了map+switchToLatest模式，这样就可以自动取消上一次的网络请求。
//    
//    startWith的内部实现是concat，这里表示先将状态置为checking，然后再根据网络请求的结果设置状态。
    
//
    
    
    
    
//    token过期后自动获取新的
    
    
    
//    
//    开发APIClient时，会用到AccessToken，这个Token过一段时间会过期，需要去请求新的Token。比较好的用户体验是当token过期后，自动去获取新的Token，拿到后继续上一次的请求，这样对用户是透明的。
//    
//    RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

//        static BOOL isFirstTime = 0;
//        NSString *url = @"http://httpbin.org/ip";
//        if (!isFirstTime) {
//            url = @"http://nonexists.com/error";
//            isFirstTime = 1;
//        }
//        NSLog(@"url:%@", url);
//        [[AFHTTPRequestOperationManager manager] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [subscriber sendNext:responseObject];
//            [subscriber sendCompleted];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [subscriber sendError:error];
//        }];
//        return nil;
//    }];
//    
//    self.statusLabel.text = @"sending request...";
//    [[requestSignal catch:^RACSignal *(NSError *error) {
//        self.statusLabel.text = @"oops, invalid access token";
//
//        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            double delayInSeconds = 1.0;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                [subscriber sendNext:@YES];
//                [subscriber sendCompleted];
//            });
//            return nil;
//        }] concat:requestSignal];
//    }] subscribeNext:^(id x) {
//        if ([x isKindOfClass:[NSDictionary class]]) {
//            self.statusLabel.text = [NSString stringWithFormat:@"result:%@", x[@"origin"]];
//        }
//    } completed:^{
//        NSLog(@"completed");
//    }];
    
}




// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
