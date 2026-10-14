#import "JAdbidMenuViewController.h"
#import "JAdbidBannerViewController.h"
#import "JAdbidInterstitialViewController.h"
#import "JAdbidNativeViewController.h"
#import "JAdbidRewardedViewController.h"
#import "JAdbidSDKManager.h"
#import "JAdbidSplashViewController.h"

@interface JAdbidMenuViewController ()
@property(nonatomic, strong) UILabel *statusLabel;
@end

@implementation JAdbidMenuViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"JAdbid 广告测试";
  self.view.backgroundColor = UIColor.systemBackgroundColor;
  self.statusLabel = [UILabel new];
  self.statusLabel.numberOfLines = 0;
  UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[ self.statusLabel ]];
  stack.axis = UILayoutConstraintAxisVertical;
  stack.spacing = 12;
  stack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:stack];
  UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
  [NSLayoutConstraint activateConstraints:@[
    [stack.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:20],
    [stack.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-20],
    [stack.topAnchor constraintEqualToAnchor:guide.topAnchor constant:24]
  ]];
  NSString *privacyTitle = JAdbidSDKManager.sharedManager.privacyManager.actionTitle;
  if (privacyTitle.length) [self addButton:privacyTitle action:@selector(openPrivacy) toStack:stack];
  [self addButton:@"完成隐私流程后初始化 SDK" action:@selector(initializeSDK) toStack:stack];
  [self addButton:@"横幅广告" action:@selector(openBanner) toStack:stack];
  [self addButton:@"插屏广告" action:@selector(openInterstitial) toStack:stack];
  [self addButton:@"激励视频" action:@selector(openRewarded) toStack:stack];
  [self addButton:@"原生广告" action:@selector(openNative) toStack:stack];
  [self addButton:@"开屏广告" action:@selector(openSplash) toStack:stack];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(applicationDidBecomeActive:)
                                             name:UIApplicationDidBecomeActiveNotification
                                           object:nil];
  [self refreshStatus];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refreshStatus];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
  if (self.isViewLoaded && self.view.window) [self refreshStatus];
}

- (void)refreshStatus {
  JAdbidSDKManager *manager = JAdbidSDKManager.sharedManager;
  NSString *state = @"尚未初始化";
  if (JAdManager.sharedInstance.initialized) {
    state = @"SDK 已初始化";
  } else if (manager.state == JAdbidSDKStateInitializing) {
    state = @"SDK 初始化中…";
  } else if (manager.state == JAdbidSDKStateFailed) {
    state = @"SDK 初始化失败，可重试";
  }
  self.statusLabel.text = [NSString stringWithFormat:@"SDK %@\n%@\n%@",
                                                     JAdManager.sharedInstance.SDKVersion,
                                                     manager.privacyManager.privacySummary,
                                                     state];
}

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)addButton:(NSString *)title action:(SEL)action toStack:(UIStackView *)stack {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:title forState:UIControlStateNormal];
  [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
  [stack addArrangedSubview:button];
}

- (void)openPrivacy {
  UIViewController *controller = [JAdbidSDKManager.sharedManager.privacyManager privacyViewController];
  if (controller) [self.navigationController pushViewController:controller animated:YES];
}

- (void)initializeSDK {
  self.statusLabel.text = @"SDK 初始化中…";
  __weak typeof(self) weakSelf = self;
  [JAdbidSDKManager.sharedManager initializeSDKWithCompletion:^(NSError *error) {
    weakSelf.statusLabel.text = error ? error.localizedDescription : @"SDK 初始化成功，可进入对应样式页面";
  }];
}

- (NSString *)adUnitID:(NSString *)key {
  return [JAdbidSDKManager.sharedManager.configuration adUnitIDForKey:key];
}
- (void)push:(UIViewController *)controller {
  [self.navigationController pushViewController:controller animated:YES];
}
- (void)openBanner {
  [self push:[[JAdbidBannerViewController alloc] initWithAdUnitID:[self adUnitID:@"Banner"]]];
}
- (void)openInterstitial {
  [self push:[[JAdbidInterstitialViewController alloc] initWithAdUnitID:[self adUnitID:@"Interstitial"]]];
}
- (void)openRewarded {
  [self push:[[JAdbidRewardedViewController alloc] initWithAdUnitID:[self adUnitID:@"Rewarded"]]];
}
- (void)openNative {
  [self push:[[JAdbidNativeViewController alloc] initWithAdUnitID:[self adUnitID:@"Native"]]];
}
- (void)openSplash {
  [self push:[[JAdbidSplashViewController alloc] initWithAdUnitID:[self adUnitID:@"Splash"]]];
}

@end
