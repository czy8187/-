//
//  ViewController.m
//  多线程用法总结
//  详见:https://www.jianshu.com/p/0b0d9b1f1f19
//  Created by hhsofta on 2018/6/7.
//  Copyright © 2018年 hhsofta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self onGCDusage];
}
#pragma mark - 1.NSThread
- (void)onNSThreadUsage {
    //创建
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:nil];
    //启动
    [thread start];
    
    //创建并自动启动
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:nil];
    
    //使用NSObject的方法创建并自动启动
    [self performSelector:@selector(run:) withObject:nil];
    
    //其他常见的方法
    /*
     //取消线程
     - (void)cancel;
     
     //启动线程
     - (void)start;
     
     //判断某个线程的状态的属性
     @property (readonly, getter=isExecuting) BOOL executing;
     @property (readonly, getter=isFinished) BOOL finished;
     @property (readonly, getter=isCancelled) BOOL cancelled;
     
     //设置和获取线程名字
     -(void)setName:(NSString *)n;
     -(NSString *)name;
     
     //获取当前线程信息
     + (NSThread *)currentThread;
     
     //获取主线程信息
     + (NSThread *)mainThread;
     
     //使当前线程暂停一段时间，或者暂停到某个时刻
     + (void)sleepForTimeInterval:(NSTimeInterval)time;
     + (void)sleepUntilDate:(NSDate *)date;
     */
}
#pragma mark - 2.GCD
- (void)onGCDusage {
    //GCD会自动管理线程的生命周期（创建线程、调度任务、销毁线程），完全不需要我们管理，我们只需要告诉干什么就行。同时它使用的也是 c语言，不过由于使用了 Block（Swift 里叫做闭包），使得使用起来更加方便，而且灵活,所以基本上大家都使用 GCD 这套方案
    
    ///创建队列
    dispatch_queue_t queue1 = dispatch_get_main_queue();
    
    //自己创建队列
    //第一个参数是标识符，用于 DEBUG 的时候标识唯一的队列，可以为空;
    //第二个才是最重要的。第二个参数用来表示创建的队列是串行的还是并行的，传入 DISPATCH_QUEUE_SERIAL 或 NULL 表示创建串行队列。传入 DISPATCH_QUEUE_CONCURRENT 表示创建并行队列。
    //1.串行队列
    dispatch_queue_t queue2 = dispatch_queue_create("czy.bourne.testQueue", NULL);
    dispatch_queue_t queue3 = dispatch_queue_create("czy.bourne.testQueue", DISPATCH_QUEUE_SERIAL);
    //2.并行队列
    dispatch_queue_t queue4 = dispatch_queue_create("czy.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
    
    //3.全局并行队列:只要是并行任务一般都加入到这个队列。这是系统提供的一个并发队列。
    dispatch_queue_t queue5 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    ///创建任务
    //1.同步任务-会阻塞当前线程 (SYNC)
    dispatch_sync(queue2, ^{
        NSLog(@"%@",[NSThread currentThread]);
    });
    //2.异步任务-不会阻塞当前线程（ASYNC）
    dispatch_async(queue3, ^{
        NSLog(@"%@",[NSThread currentThread]);
    });
    ///### 队列组

    //队列组可以将很多队列添加到一个组里，这样做的好处是，当这个组里所有的任务都执行完了，队列组会通过一个方法通知我们。下面是使用方法，这是一个很实用的功能。
    //1.创建队列组
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    //3.多次使用队列组的方法执行任务, 只有异步方法
    //3.1.执行3次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 3; i++) {
            NSLog(@"group-01 - %@", [NSThread currentThread]);
        }
    });
    
    //3.2.主队列执行8次循环
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (NSInteger i = 0; i < 8; i++) {
            NSLog(@"group-02 - %@", [NSThread currentThread]);
        }
    });
    
    //3.3.执行5次循环
    dispatch_group_async(group, queue, ^{
        for (NSInteger i = 0; i < 5; i++) {
            NSLog(@"group-03 - %@", [NSThread currentThread]);
        }
    });
    
    //4.都完成后会自动通知
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"完成 - %@", [NSThread currentThread]);
    });
}
#pragma mark - 3.NSOperation 和 NSOperationQueue
- (void)onNSOperationUsage {
    ///NSOperation 是苹果公司对 GCD 的封装，完全面向对象，所以使用起来更好理解。 大家可以看到 NSOperation 和 NSOperationQueue 分别对应 GCD 的 任务 和 队列
    ///添加任务
    
    //-NSOperation 只是一个抽象类，所以不能封装任务。但它有 2 个子类用于封装任务。分别是：NSInvocationOperation 和 NSBlockOperation
    //1.创建NSInvocationOperation对象
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(run:) object:nil];
    //2.开始执行
    [invocationOperation start];
    
    //创建NSBlockOperation对象
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    //这样的任务，默认会在当前线程执行。但是 NSBlockOperation 还有一个方法：addExecutionBlock: ，通过这个方法可以给 Operation 添加多个执行 Block。这样 Operation 中的任务 会并发执行，它会 在主线程和其它的多个线程 执行这些任务
    //添加多个block
    for (NSInteger i = 0; i < 5; i++) {
        [blockOperation addExecutionBlock:^{
            NSLog(@"第%ld次,%@",i,[NSThread currentThread]);
        }];
    }
    [blockOperation start];
    ///创建队列
    
    //主队列
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    //其他队列
    //1.创建一个其他队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //2.创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
    }];
    //3.添加多个block
    for (NSInteger i = 0; i < 5; i++) {
        [operation addExecutionBlock:^{
            NSLog(@"第%ld次:%@",i, [NSThread currentThread]);
        }];
    }
    
    //4.队列添加任务
    [queue addOperation:operation];
    
    ///NSOperation 添加依赖
    //1.任务一:下载图片
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片 - %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    //2.任务二:打水印
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"打水印 - %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    //3.任务三:上传图片
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"上传图片 - %@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }];
    //4.设置依赖
    [operation2 addDependency:operation1];//任务二依赖任务一
    [operation3 addDependency:operation2];//任务三依赖任务二
    //创建队列并加入任务
    NSOperationQueue *queueT = [[NSOperationQueue alloc] init];
    [queueT addOperations:@[operation1, operation2, operation3] waitUntilFinished:NO];
    
    
    ///线程同步
    //1.互斥锁:给需要同步的代码块加一个互斥锁，就可以保证每次只有一个线程访问此代码块。
    @synchronized(self){
        ///需要执行的代码块
    }
    
}
- (void)run:(id)sender {
    NSLog(@"Running!!");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
