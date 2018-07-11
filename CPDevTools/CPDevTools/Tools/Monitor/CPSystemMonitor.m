//
//  CPSystemMonitor.m
//  CPDevTools
//
//  Created by mac on 2017/7/10.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CPSystemMonitor.h"
#import <mach/mach.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "CPDeveToolsDefine.h"
#import "NSObject+CPSwizzle.h"

@interface CPSystemMonitorView : UIView {
    
    NSInteger _fpsCount;
    CFTimeInterval _fpsLastTime;
    
    CADisplayLink *_link;
    
    CGPoint _beginPoint;
}

@property (nonatomic,strong) UILabel *contentLabel;


@property (nonatomic,assign) NSInteger FPS;
@property (nonatomic,assign) CGFloat CPU;
@property (nonatomic,assign) CGFloat Mem;

@property (nonatomic,weak) UINavigationController *pushVC;

@end

@implementation CPSystemMonitorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
        
        [self addTimer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentLabel.frame = CGRectMake(2.0, 0, self.frame.size.width - 2.0, self.frame.size.height);
}

- (void)initView {
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.500];
    self.contentLabel.font = [UIFont systemFontOfSize:8];
    self.contentLabel.textColor = [UIColor whiteColor];
    self.contentLabel.numberOfLines = 3;
    
    [self addSubview:self.contentLabel];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleViewTap:)];
    [self addGestureRecognizer:viewTap];
}

- (void)handleViewTap:(UITapGestureRecognizer *)sender {
    
    if (!self.pushVC) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CPMonitor" bundle:CPBundle];
        UINavigationController *nv = [sb instantiateViewControllerWithIdentifier:@"CPNavigationController"];
        self.pushVC = nv;
        
        [[self topViewController] presentViewController:nv animated:YES completion:nil];
    }
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

#pragma mark - tiemr
- (void)addTimer {
    
    if (_link == nil) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerHandle:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    
    [_link invalidate];
    _link = nil;
}

- (void)timerHandle:(CADisplayLink *)link {
    
    _fpsCount += link.frameInterval;
    CFTimeInterval interval= link.timestamp - _fpsLastTime;
    if (interval < 1) {
        return;
    }
    
    _fpsLastTime = link.timestamp;
    double fps = _fpsCount / interval;
    _fpsCount = 0;
    
    self.FPS = (long)round(fps);
    self.CPU = [self getCpuUsed];
    self.Mem = [self getMemUsed];
    
    [self setContentLabelText];
}

- (void)setContentLabelText {
    
    NSString *str = [NSString stringWithFormat:@"FPS:%@ \nCPU:%0.1f%% \nMem:%0.1fM",
                     @(self.FPS),self.CPU,self.Mem];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:str];
    
    CGFloat fpsProgress = self.FPS /60.0;
    UIColor *fpsColor = [UIColor colorWithHue:0.27 * (fpsProgress - 0.2) saturation:1 brightness:0.9 alpha:1];
    [content addAttribute:NSForegroundColorAttributeName value:fpsColor
                    range:[str rangeOfString:[NSString stringWithFormat:@"%@",@(self.FPS)]]];
    
    UIColor *cpuColor = self.CPU < 30 ? [UIColor whiteColor] : [UIColor redColor];
    [content addAttribute:NSForegroundColorAttributeName value:cpuColor
                    range:[str rangeOfString:[NSString stringWithFormat:@"%0.1f%%",self.CPU]]];
    
    UIColor *memColor = self.Mem < 50 ? [UIColor whiteColor] : (self.Mem < 100 ? [UIColor greenColor] : [UIColor redColor]);
    [content addAttribute:NSForegroundColorAttributeName value:memColor
                    range:[str rangeOfString:[NSString stringWithFormat:@"%0.1fM",self.Mem]]];
    
    
    self.contentLabel.attributedText = content;
}

#pragma mark - TouchEvent
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    _beginPoint = [touch locationInView:touch.view];
    
    [[self superview] bringSubviewToFront:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:touch.view];
    CGRect frame = self.frame;
    
    frame.origin.x += currentLocation.x-_beginPoint.x;
    frame.origin.y += currentLocation.y-_beginPoint.y;
    self.frame = frame;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGRect frame = self.frame;
    CGFloat maxWidth = self.superview.bounds.size.width;
    
    if (frame.origin.x > maxWidth/2.0) {
        frame.origin.x = maxWidth-frame.size.width - 2.0;
    }else{
        frame.origin.x = 2.0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = frame;
    }];
}

#pragma mark - CPU/Mem
- (float)getCpuUsed {
    
    float cpu = cpu_usage();
    return cpu;
}

- (double)getMemUsed {
    
    double mem = report_memory();
    return mem;
}

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

double report_memory(void)
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if (kerr != KERN_SUCCESS) {
        return -1;
    }
    
    double memSize = info.resident_size /1024.0/1024.0;
    
    return memSize;
}

@end


@implementation UIViewController (CP_Swizzle)

- (void)CP_ViewDidAppear:(BOOL)animated {
    
    [self CP_ViewDidAppear:animated];
    
    for (UIView *systemView in [[UIApplication sharedApplication].delegate.window subviews]) {
        if ([systemView isMemberOfClass:[CPSystemMonitorView class]]) {
            [[UIApplication sharedApplication].delegate.window bringSubviewToFront:systemView];
        }
    }
}

@end

@implementation CPSystemMonitor

+ (void)start {
    
    [self mothodSwizzle];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    CPSystemMonitorView *monitorView = [[CPSystemMonitorView alloc]
                                        initWithFrame:CGRectMake((frame.size.width-50)/2.0, 20, 60, 60)];
    
    [[UIApplication sharedApplication].delegate.window addSubview:monitorView];
}

+ (void)mothodSwizzle {
    
    [self mothodSwizzleClass:@"UIViewController"
                         Old:@"viewDidAppear:"
                         new:@"CP_ViewDidAppear:"];
}

@end
