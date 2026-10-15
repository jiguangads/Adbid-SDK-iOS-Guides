#import "JAdbidSDKManager.h"

/**
 * 输出Demo白名单日志；可从任意线程调用，不访问UI或改变SDK状态。
 * @param stage 有限首方阶段，未识别值记录unknown。
 * @param format sdk或五种广告类型，未识别值记录unknown。
 * @param code 0表示普通事件；其他值只保留已知首方错误码。
 * @param reason 已归一化的首方原因；不允许原始错误或标识，未识别值记录unknown。
 * @param debugEnabled 既有运行时开关；Demo Debug构型始终可见，Release普通事件依该值。
 */
void JAdbidSampleLog(NSString *stage, NSString *format, NSInteger code, NSString *reason, BOOL debugEnabled) {
#if DEBUG
  debugEnabled = YES;
#endif
  if (!debugEnabled && code == 0) return;
  NSArray *stages = @[@"initialize.begin", @"initialize.success", @"initialize.failure", @"load.begin",
                      @"load.success", @"load.failure", @"show.success", @"show.failure", @"click", @"close",
                      @"video.start", @"video.end", @"reward", @"banner.size"];
  NSArray *formats = @[@"sdk", @"banner", @"interstitial", @"rewarded", @"native", @"splash"];
  NSArray *codes = @[@1001, @1002, @1003, @1004, @1005, @1006, @1007, @1008, @1009, @9999];
  NSArray *reasons = @[@"noFill", @"networkUnavailable", @"requestTimeout", @"notInitialized", @"notPrepared",
                       @"invalidAppID", @"invalidLoadParameters", @"invalidRenderSize", @"alreadyLoading",
                       @"requestInProgress", @"adNotReady", @"notReady", @"destroyed", @"adSourceUnavailable",
                       @"adapterMissing", @"unknown", @"renderFailed"];
  NSString *safeStage = [stages containsObject:stage ?: @""] ? stage : @"unknown";
  NSString *safeFormat = [formats containsObject:format ?: @""] ? format : @"unknown";
  NSString *level = code ? @"error" : ([safeStage hasSuffix:@".begin"] ? @"debug" : @"info");
  NSMutableArray *parts = [NSMutableArray arrayWithArray:@[@"[JAdbidDemo]",
      [NSString stringWithFormat:@"level=%@", level], [NSString stringWithFormat:@"stage=%@", safeStage],
      [NSString stringWithFormat:@"format=%@", safeFormat]]];
  if (code) {
    NSInteger safeCode = [codes containsObject:@(code)] ? code : 9999;
    NSString *safeReason = [codes containsObject:@(code)] && [reasons containsObject:reason ?: @""]
                               ? reason : @"unknown";
    [parts addObject:[NSString stringWithFormat:@"code=%ld", (long)safeCode]];
    [parts addObject:[NSString stringWithFormat:@"reason=%@", safeReason]];
  }
  NSLog(@"%@", [parts componentsJoinedByString:@" "]);
}


@interface JAdbidSDKManager ()
@property(nonatomic) JAdbidSDKState state;
@property(nonatomic, strong) id<JAdbidSampleConfiguring> configuration;
@property(nonatomic, strong) id<JAdbidPrivacyManaging> privacyManager;
@property(nonatomic, strong) NSMutableArray<void (^)(NSError *)> *pendingCompletions;
@end

@implementation JAdbidSDKManager

+ (JAdbidSDKManager *)sharedManager {
  static JAdbidSDKManager *manager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [JAdbidSDKManager new];
  });
  return manager;
}

- (instancetype)init {
  if ((self = [super init])) _pendingCompletions = [NSMutableArray array];
  return self;
}

- (void)configureWithConfiguration:(id<JAdbidSampleConfiguring>)configuration
                    privacyManager:(id<JAdbidPrivacyManaging>)privacyManager {
  NSAssert(self.state != JAdbidSDKStateInitializing, @"不能在SDK初始化过程中替换Demo配置");
  self.configuration = configuration;
  self.privacyManager = privacyManager;
}

- (void)initializeSDKWithCompletion:(void (^)(NSError *error))completion {
  NSAssert(NSThread.isMainThread, @"Demo SDK初始化入口必须在主线程调用");
  if (self.state == JAdbidSDKStateInitialized || JAdManager.sharedInstance.initialized) {
    self.state = JAdbidSDKStateInitialized;
    if (completion) completion(nil);
    return;
  }
  if (completion) [self.pendingCompletions addObject:[completion copy]];
  if (self.state == JAdbidSDKStateInitializing) return;

  NSString *appID = self.configuration.appID;
  if (!appID.length) {
    [self completeInitializationWithError:[NSError errorWithDomain:@"JAdbidSample"
                                                              code:1
                                                          userInfo:@{
                                                            NSLocalizedDescriptionKey :
                                                                @"请填写 SampleConfig.plist，并先完成宿主隐私流程"
                                                          }]];
    return;
  }
  self.state = JAdbidSDKStateInitializing;
  JAdConfig *config = [[JAdConfig alloc] initWithAppID:appID];
  [self.configuration configureSDKConfig:config];
  JAdbidSampleLog(@"initialize.begin", @"sdk", 0, nil, config.debugMode);
  __weak typeof(self) weakSelf = self;
  [JAdManager.sharedInstance initializeWithConfig:config
                                       completion:^(NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           [weakSelf completeInitializationWithError:error];
                                         });
                                       }];
}

- (void)completeInitializationWithError:(NSError *)error {
  JAdbidSampleLog(error ? @"initialize.failure" : @"initialize.success", @"sdk",
                  error ? error.code : 0, @"unknown", JAdManager.sharedInstance.debugMode);
  self.state = error ? JAdbidSDKStateFailed : JAdbidSDKStateInitialized;
  NSArray *callbacks = [self.pendingCompletions copy];
  [self.pendingCompletions removeAllObjects];
  for (void (^callback)(NSError *) in callbacks) callback(error);
}

@end
