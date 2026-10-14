#import "JAdbidSDKManager.h"

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
  __weak typeof(self) weakSelf = self;
  [JAdManager.sharedInstance initializeWithConfig:config
                                       completion:^(NSError *error) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           [weakSelf completeInitializationWithError:error];
                                         });
                                       }];
}

- (void)completeInitializationWithError:(NSError *)error {
  self.state = error ? JAdbidSDKStateFailed : JAdbidSDKStateInitialized;
  NSArray *callbacks = [self.pendingCompletions copy];
  [self.pendingCompletions removeAllObjects];
  for (void (^callback)(NSError *) in callbacks) callback(error);
}

@end
