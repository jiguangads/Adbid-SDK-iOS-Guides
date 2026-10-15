#import "JAdbidFormatViewController.h"
#import "JAdbidSDKManager.h"

extern void JAdbidSampleLog(NSString *stage, NSString *format, NSInteger code, NSString *reason, BOOL debugEnabled);

// BEGIN JADBID_DEMO_INFO_FIELDS
// 当前公开字段优先；仅兼容根工程已核验的旧SDK快照，不搜索其它别名。
static NSDictionary<NSString *, NSString *> *JAdbidDemoInfoFields(NSObject *info) {
  id networkValue = nil;
  id sourceValue = nil;
  if ([info respondsToSelector:NSSelectorFromString(@"networkName")]) {
    networkValue = [info valueForKey:@"networkName"];
  } else if ([info respondsToSelector:NSSelectorFromString(@"adSourceName")]) {
    networkValue = [info valueForKey:@"adSourceName"];
  }
  if ([info respondsToSelector:NSSelectorFromString(@"sourceIdentifier")]) {
    sourceValue = [info valueForKey:@"sourceIdentifier"];
  } else if ([info respondsToSelector:NSSelectorFromString(@"adSourceId")]) {
    sourceValue = [info valueForKey:@"adSourceId"];
  }
  return @{@"network": [networkValue isKindOfClass:NSString.class] && [networkValue length] ? networkValue : @"未知",
           @"source": [sourceValue isKindOfClass:NSString.class] && [sourceValue length] ? sourceValue : @"未知"};
}
// END JADBID_DEMO_INFO_FIELDS

@interface JAdbidFormatViewController ()
@property(nonatomic, strong) UITextView *eventView;
@property(nonatomic, strong) NSMutableArray<NSString *> *events;
@end

@implementation JAdbidFormatViewController

- (instancetype)initWithTitle:(NSString *)title adUnitID:(NSString *)adUnitID {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.title = title;
    _adUnitID = [adUnitID copy] ?: @"";
    _events = [NSMutableArray array];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.systemBackgroundColor;
  _statusLabel = [UILabel new];
  _statusLabel.numberOfLines = 0;
  _statusLabel.text = @"进入页面后点击加载";
  _contentStack = [[UIStackView alloc] initWithArrangedSubviews:@[ _statusLabel ]];
  _contentStack.axis = UILayoutConstraintAxisVertical;
  _contentStack.spacing = 16;
  _contentStack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_contentStack];
  UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
  [NSLayoutConstraint activateConstraints:@[
    [_contentStack.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:20],
    [_contentStack.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-20],
    [_contentStack.topAnchor constraintEqualToAnchor:guide.topAnchor constant:24]
  ]];
  _loadButton = [self addActionWithTitle:@"加载广告" selector:@selector(loadAd)];
  _eventView = [UITextView new];
  _eventView.editable = NO;
  _eventView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
  _eventView.text = @"尚无广告事件";
  [self.contentStack addArrangedSubview:_eventView];
  [_eventView.heightAnchor constraintEqualToConstant:180].active = YES;
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationDidBecomeActive:)
                                             name:UIApplicationDidBecomeActiveNotification
                                           object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refreshSDKAvailability];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
  if (self.isViewLoaded && self.view.window) [self refreshSDKAvailability];
}

- (void)refreshSDKAvailability {
  if (!JAdManager.sharedInstance.initialized) {
    self.statusLabel.text = @"SDK 尚未初始化；请返回首页完成隐私流程并手动初始化";
  }
}

- (UIButton *)addActionWithTitle:(NSString *)title selector:(SEL)selector {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:title forState:UIControlStateNormal];
  [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
  if (self.eventView) {
    [self.contentStack insertArrangedSubview:button
                                   atIndex:self.contentStack.arrangedSubviews.count - 1];
  } else {
    [self.contentStack addArrangedSubview:button];
  }
  return button;
}

- (NSString *)consoleFormat {
  NSDictionary *formats = @{@"横幅广告" : @"banner", @"插屏广告" : @"interstitial", @"激励视频" : @"rewarded",
                             @"原生广告" : @"native", @"开屏广告" : @"splash"};
  return formats[self.title] ?: @"unknown";
}

- (BOOL)canLoad {
  if (!JAdManager.sharedInstance.initialized) {
    self.statusLabel.text = @"请返回首页，在完成隐私流程后初始化 SDK";
    JAdbidSampleLog(@"load.failure", self.consoleFormat, JAdErrorNotInitialized, @"notInitialized",
                    JAdManager.sharedInstance.debugMode);
    return NO;
  }
  if (!self.adUnitID.length) {
    self.statusLabel.text = @"请在 SampleConfig.plist 填写当前样式广告位";
    JAdbidSampleLog(@"load.failure", self.consoleFormat, JAdErrorInvalidParameters, @"invalidLoadParameters",
                    JAdManager.sharedInstance.debugMode);
    return NO;
  }
  if (self.isLoading) {
    self.statusLabel.text = @"广告正在加载，请等待回调";
    JAdbidSampleLog(@"load.failure", self.consoleFormat, JAdErrorLoading, @"alreadyLoading",
                    JAdManager.sharedInstance.debugMode);
    return NO;
  }
  return YES;
}

- (BOOL)canShow {
  if (!JAdManager.sharedInstance.initialized) {
    self.statusLabel.text = @"SDK 尚未初始化；请返回首页手动初始化";
    return NO;
  }
  return YES;
}

- (void)beginLoading {
  JAdbidSampleLog(@"load.begin", self.consoleFormat, 0, nil, JAdManager.sharedInstance.debugMode);
  self.loading = YES;
  self.loadButton.enabled = NO;
  self.statusLabel.text = @"加载中…";
}
- (void)finishLoadingWithText:(NSString *)text {
  self.loading = NO;
  self.loadButton.enabled = YES;
  self.statusLabel.text = text;
}
- (NSString *)displayTextForError:(JAdError *)error {
  return [JAdbidSDKManager.sharedManager.configuration diagnosticTextForError:error];
}

- (void)recordEvent:(NSString *)event info:(JAdInfo *)info {
  NSDictionary *stages = @{@"load" : @"load.success", @"show" : @"show.success", @"click" : @"click",
                            @"close" : @"close", @"videoStart" : @"video.start", @"videoEnd" : @"video.end",
                            @"reward" : @"reward", @"sizeChanged" : @"banner.size"};
  JAdbidSampleLog(stages[event], self.consoleFormat, 0, nil, JAdManager.sharedInstance.debugMode);
  NSDictionary<NSString *, NSString *> *fields = JAdbidDemoInfoFields(info);
  NSString *network = fields[@"network"];
  NSString *source = fields[@"source"];
  [self.events addObject:[NSString stringWithFormat:@"%@ | network=%@ | source=%@",
                                                    event, network, source]];
  if (self.events.count > 40) [self.events removeObjectAtIndex:0];
  self.eventView.text = [self.events componentsJoinedByString:@"\n"];
}

- (void)recordFailure:(JAdError *)error stage:(NSString *)stage {
  NSString *logStage = [stage isEqualToString:@"load"] ? @"load.failure" : @"show.failure";
  JAdbidSampleLog(logStage, self.consoleFormat, error ? error.code : JAdErrorUnknown,
                  error.reason, JAdManager.sharedInstance.debugMode);
  NSString *detail = [self displayTextForError:error];
  [self.events addObject:[NSString stringWithFormat:@"%@ failed | %@", stage,
                                                    detail.length ? detail : @"未知错误"]];
  if (self.events.count > 40) [self.events removeObjectAtIndex:0];
  self.eventView.text = [self.events componentsJoinedByString:@"\n"];
}
- (void)loadAd {
  NSAssert(NO, @"subclass must implement");
}
- (void)destroyAd {
}
- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  if (self.isMovingFromParentViewController) [self destroyAd];
}
- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
  [self destroyAd];
}

@end
