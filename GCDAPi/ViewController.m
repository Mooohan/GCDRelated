//
//  ViewController.m
//  GCDAPi
//
//  Created by 刘洋 on 2020/12/17.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) NSInteger ticketSurplusCount;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end


@implementation ViewController

{
    dispatch_semaphore_t semaphoreLock;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTableview];
    
}

- (void)addTableview {
    _dataArr = @[
        @"0.死锁",
        @"1.自定义串行队列嵌套并行队列",
        @"2.异步并发嵌套同步主队列",
        @"3.dispatch_apply",
        @"4.dispatch_after",
        @"5.dispatch_barrier _ (a)sync",
        
        @"6.dispatch_group_async",
        @"7.dispatch_group_wait",
        @"8.dispatch_group_enter、dispatch_group_leave",
        
        @"9.定时器的gcd应用",
        @"10.stopTimer",
        @"11.多个串行队列队列，多个线程",
        @"12.防止多个串行队列的并发执行",
        
        @"13.Dispatch Semaphore 实现线程同步",
        @"14.Semaphore 加锁",
        @"15.常见问题部分1",
        @"16.常见问题部分2",
        
        @"17.dispatch_suspend挂起队列",
        @"18.进度条例子",
        @"19.防止多个串行/并发队列的并发执行",
    ].mutableCopy;
    UITableView *myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:myTableView];
    myTableView.backgroundColor = [UIColor grayColor];
    myTableView.delegate = self;
    myTableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mycell"];
    cell.textLabel.text = _dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"demo%ld", (long)indexPath.row])];
}










/** 死锁 */
- (void)demo0 {
    
//    NSLog(@"Before");
//
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSLog(@"In");
//    });
//    NSLog(@"After");
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"before");
        dispatch_sync(queue, ^{
            NSLog(@"in");
        });
        NSLog(@"after");
    });

}















/*
 demo1
 */

- (void)demo1 {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t serialQueue = dispatch_queue_create("mySerialQueue", DISPATCH_QUEUE_SERIAL);

    dispatch_sync(serialQueue, ^{
        
        dispatch_async(concurrentQueue, ^{
            for (int i = 0; i < 5; i++)
            {
                NSLog(@"Task1 %@ %d", [NSThread currentThread], i);
            }
        });
        
        dispatch_async(concurrentQueue, ^{
            for (int i = 0; i < 5; i++)
            {
                NSLog(@"Task2 %@ %d", [NSThread currentThread], i);
            }
        });
        
        
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Complete.");
        }
    });
}














/*
 demo2
 
 */

- (void)demo2 {
    NSLog(@"1");
//    dispatch_queue_t que = dispatch_queue_create("thread", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t que = dispatch_queue_create("thread", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t que = dispatch_get_main_queue();
    dispatch_async(que, ^{
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"2");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3");
            dispatch_sync(que, ^{
                NSLog(@"4");
            });
        });
        NSLog(@"5");
    });
    NSLog(@"6");
    dispatch_async(que, ^{
        NSLog(@"7");
    });
    NSLog(@"8");
    
}















/*
 dispatch_apply
 */
//该函数按指定的次数将指定的Block追加到指定的Dispatch Queue中，并等待全部处理执行结束。
- (void)demo3 {
    
    dispatch_queue_t que = dispatch_queue_create("thread", DISPATCH_QUEUE_SERIAL);
    dispatch_apply(10,que, ^(size_t t) {
        NSLog(@"Task %@ %ld", [NSThread currentThread], t);
    });
    NSLog(@"---%@",[NSThread currentThread]);
}























/*
 dispatch_after
 延迟提交，而不是延迟执行
 队列什么时候安排线程去执行是未知的，所以不要用这个方法去实现定时器这样的功能。
 */
- (void)demo4 {
    NSLog(@"Before");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"In %@", [NSThread currentThread]);
    });
    NSLog(@"After");
}

















/*
 dispatch_barrier _ (a)sync
 */

- (void)demo5 {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Task0 %@ %d", [NSThread currentThread], i);
        }
    });
    
    dispatch_barrier_async(concurrentQueue, ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"T2 %@ %d", [NSThread currentThread], i);
        }
    });
    
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Task3Task3Task3Task3 %@ %d", [NSThread currentThread], i);
        }
    });
    
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Task4Task4Task4Task4 %@ %d", [NSThread currentThread], i);
        }
    });
}













/*
 dispatch_ group_ t
 */
- (void)demo6 {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, concurrentQueue, ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Task1 %@ %d", [NSThread currentThread], i);
        }
    });
    
    dispatch_group_async(group, dispatch_get_main_queue(), ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Task2 %@ %d", [NSThread currentThread], i);
        }
    });
    
    dispatch_group_async(group, concurrentQueue, ^{
        for (int i = 0; i < 5; i++)
        {
            NSLog(@"Task3 %@ %d", [NSThread currentThread], i);
        }
    });
    
    dispatch_group_notify(group, concurrentQueue, ^{
        NSLog(@"All Task Complete");
    });
}

















//dispatch_group_wait
//指定的超时时间为DISPATCH_TIME_NOW的时候相当于dispatch_group_notify函数的使用：判断group内的任务是否都完成。
//然而dispatch_group_notify函数是作者推荐的，因为通过这个函数可以直接设置最后任务所被追加的队列，使用起来相对比较方便。
- (void)demo7
{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_group_async(group, queue, ^{
            for (NSInteger i = 0; i< 1000000000; i ++) {
                
            }
            NSLog(@"任务%ld",index);
        });
    }
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
    
    long result = dispatch_group_wait(group, time);
    if (result == 0) {
        
        NSLog(@"group内部的任务全部结束");
        
    }else{
        
        NSLog(@"虽然过了超时时间，group还有任务没有完成");
    }
    
}











//dispatch_group_enter、dispatch_group_leave
//dispatch_group_enter 标志着一个任务追加到 group，执行一次，相当于 group 中未执行完毕任务数 +1
//dispatch_group_leave 标志着一个任务离开了 group，执行一次，相当于 group 中未执行完毕任务数 -1。
- (void)demo8 {
  
       NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
       NSLog(@"group---begin");
       
       dispatch_group_t group = dispatch_group_create();
       dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

       dispatch_group_enter(group);
       dispatch_async(queue, ^{
           // 追加任务 1
           [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
           NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程

           dispatch_group_leave(group);
       });
       
       dispatch_group_enter(group);
       dispatch_async(queue, ^{
           // 追加任务 2
           [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
           NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
           
           dispatch_group_leave(group);
       });
       
       dispatch_group_notify(group, dispatch_get_main_queue(), ^{
           // 等前面的异步操作都执行完毕后，回到主线程.
           [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
           NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
       
           NSLog(@"group---end");
       });
}













/*定时器
 
dispatch_source_set_timer(dispatch_source_t source, dispatch_time_t start, uint64_t interval, uint64_t leeway)
 
source 分派源
start 数控制计时器第一次触发的时刻。参数类型是 dispatch_time_t，这是一个opaque类型，我们不能直接操作它。我们得需要 dispatch_time 和 dispatch_walltime 函数来创建它们。另外，常量 DISPATCH_TIME_NOW 和 DISPATCH_TIME_FOREVER 通常很有用。
interval 间隔时间
leeway 计时器触发的精准程度
 
 更为准确
 */

- (void)demo9 {
    __block NSInteger count = 0;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        
        NSLog(@"-----%ld-----",count++);
    });
    dispatch_resume(self.timer);
    
}

- (void)demo10
{
    dispatch_suspend(_timer);
    _timer = nil; // EXC_BAD_INSTRUCTION 崩溃
    
//    dispatch_source_cancel(_timer);
//    _timer = nil; // OK
}














//多个串行队列，多个线程
//新建了一个串行队列，系统一定会开启一个子线程，所以在使用串行队列的时候，按需创建的串行队列，避免资源浪费。
- (void)demo11
{

    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger index = 0; index < 5; index ++) {
        
        dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
        [array addObject:serial_queue];
    }
    
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_async(queue, ^{
            NSLog(@"任务%ld",idx);
        });
    }];
    
}












//不能并发执行的处理追加到多个Serial Dispatch Queue中时，可以使用dispatch_set_target_queue函数将目标函数定为某个Serial Dispatch Queue，就可以防止这些处理的并发执行。
//另外一个作用是改变队列的优先级。
- (void)demo12
{
    //多个串行队列，设置了target queue
    NSMutableArray *array = [NSMutableArray array];
    dispatch_queue_t serial_queue_target = dispatch_queue_create("queue_target", NULL);

    for (NSInteger index = 0; index < 5; index ++) {
        
        dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
        dispatch_set_target_queue(serial_queue, serial_queue_target);
        [array addObject:serial_queue];
    }
    
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_async(queue, ^{
            NSLog(@"任务%ld",idx);
        });
    }];
    
}



























//Dispatch Semaphore 实现线程同步
//dispatch_semaphore_create：创建一个 Semaphore 并初始化信号的总量
//dispatch_semaphore_signal：发送一个信号，让信号总量加 1
//dispatch_semaphore_wait：可以使总信号量减 1，信号总量小于 0 时就会一直等待（阻塞所在线程），否则就可以正常执行。
- (void)demo13 {
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务 1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"semaphore---end,number = %d",number);
}













/**
 * 线程安全：使用 semaphore 加锁
 * 初始化火车票数量、卖票窗口（线程安全）、并开始卖票
 */
- (void)demo14 {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 10;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafe];
    });
}

/**
 * 售卖火车票（线程安全）
 */
- (void)saleTicketSafe {
    while (1) {
        // 相当于加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        
        if (self.ticketSurplusCount > 0) {  // 如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { // 如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            
            // 相当于解锁
            dispatch_semaphore_signal(semaphoreLock);
            break;
        }
        
        // 相当于解锁
        dispatch_semaphore_signal(semaphoreLock);
    }
}


















- (void)demo15 {
    int i = 5;
    NSThread *thread = [[NSThread alloc]initWithBlock:^{
        NSLog(@"1");
        
//        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSRunLoopCommonModes];
//        [[NSRunLoop currentRunLoop] run];
        while (1) {
            NSLog(@"1111%d", i);
            sleep(1);
        }
    }];
    [thread start];
//    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
}

- (void)test{
    NSLog(@"2");
}



















- (void)demo16 {
    __block NSInteger a = 0;
    while (a < 100) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            a++;
            NSLog(@"%ld======%@", a, [NSThread currentThread]);
        });
    }
    NSLog(@"卧槽无情%ld", a);
}



















//dispatch_suspend挂起队列
- (void)demo17 {
        //创建DISPATCH_QUEUE_SERIAL队列
        dispatch_queue_t queue1 = dispatch_queue_create("com.iOSChengXuYuan.queue1", 0);
        dispatch_queue_t queue2 = dispatch_queue_create("com.iOSChengXuYuan.queue2", 0);
        
        //创建group
        dispatch_group_t group = dispatch_group_create();
        
        //异步执行任务
        dispatch_async(queue1, ^{
            NSLog(@"任务 1 ： queue 1...");
            sleep(1);
            NSLog(@":white_check_mark:完成任务 1");
        });
        
        dispatch_async(queue2, ^{
            NSLog(@"任务 1 ： queue 2...");
            sleep(1);
            NSLog(@":white_check_mark:完成任务 2");
        });
        
        //将队列加入到group
        dispatch_group_async(group, queue1, ^{
            NSLog(@":no_entry_sign:正在暂停 1");
            dispatch_suspend(queue1);
        });
        
        dispatch_group_async(group, queue2, ^{
            NSLog(@":no_entry_sign:正在暂停 2");
            dispatch_suspend(queue2);
        });
        
        //等待两个queue执行完毕后再执行
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        NSLog(@"＝＝＝＝＝＝＝等待两个queue完成, 再往下进行...");
        
        //异步执行任务
        dispatch_async(queue1, ^{
            NSLog(@"任务 2 ： queue 1");
        });
        dispatch_async(queue2, ^{
            NSLog(@"任务 2 ： queue 2");
        });

        //在这里将这两个队列重新恢复
        dispatch_resume(queue1);
        dispatch_resume(queue2);
//
        
        //当将dispatch_group_wait(group, DISPATCH_TIME_FOREVER);注释后，会产生崩溃，因为所有的任务都是异步执行的，在执行恢复queue1和queue2队列的时候，可能这个时候还没有执行queue1和queue2的挂起队列
}






























//进度条例子
- (void)demo18 {
    //1、指定DISPATCH_SOURCE_TYPE_DATA_ADD，做成Dispatch Source(分派源)。设定Main Dispatch Queue 为追加处理的Dispatch Queue
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, dispatch_get_main_queue());
        
        __block NSUInteger totalComplete = 0;
        
        dispatch_source_set_event_handler(source, ^{
            
            //当处理事件被最终执行时，计算后的数据可以通过dispatch_source_get_data来获取。这个数据的值在每次响应事件执行后会被重置，所以totalComplete的值是最终累积的值。
            NSUInteger value = dispatch_source_get_data(source);
            
            totalComplete += value;
            
            NSLog(@"进度：%@", @((CGFloat)totalComplete/100));
            
            NSLog(@":large_blue_circle:线程号：%@", [NSThread currentThread]);
        });
        
        //分派源创建时默认处于暂停状态，在分派源分派处理程序之前必须先恢复。
        dispatch_resume(source);
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        //2、恢复源后，就可以通过dispatch_source_merge_data向Dispatch Source(分派源)发送事件:
//        for (NSUInteger index = 0; index < 100; index++) {
//            
//            dispatch_async(queue, ^{
//                
//                dispatch_source_merge_data(source, 1);
//                
//                NSLog(@":recycle:线程号：%@~~~~~~~~~~~~i = %ld", [NSThread currentThread], index);
//                
//                usleep(20000);//0.02秒
//                
//            });
//        }
        
        //3、比较上面的for循环代码，将dispatch_async放在外面for循环的外面，打印结果不一样
        dispatch_async(queue, ^{
        
            for (NSUInteger index = 0; index < 100; index++) {
        
                dispatch_source_merge_data(source, 1);
        
                NSLog(@":recycle:线程号：%@~~~~~~~~~~~~i = %ld", [NSThread currentThread], index);
        
                usleep(20000);//0.02秒
            }
        });
        
        
        //2是将100个任务添加到queue里面，而3是在queue里面添加一个任务，而这一个任务做了100次循环
}


- (void)demo19 {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t firstQueue = dispatch_queue_create("com.starming.gcddemo.firstqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t secondQueue = dispatch_queue_create("com.starming.gcddemo.secondqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_set_target_queue(firstQueue, serialQueue);
    dispatch_set_target_queue(secondQueue, serialQueue);
    dispatch_async(firstQueue, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:1.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"2");
//        [NSThread sleepForTimeInterval:1.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"3");
//        [NSThread sleepForTimeInterval:1.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"4");
//        [NSThread sleepForTimeInterval:1.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"5");
//        [NSThread sleepForTimeInterval:1.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"6");
//        [NSThread sleepForTimeInterval:1.f];
    });
}

@end
