#import "JAdbidSplashViewController.h"
#import "JAdbidWindowProvider.h"

@interface JAdbidSplashViewController () <JSplashAdDelegate>
@property(nonatomic, strong) JSplashAd *ad;
@property(nonatomic, strong) UIButton *showButton;
@end

@implementation JAdbidSplashViewController
- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
  return [super initWithTitle:@"开屏广告" adUnitID:adUnitID];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.showButton = [self addActionWithTitle:@"展示开屏" selector:@selector(showAd)];
  self.showButton.enabled = NO;
}
- (void)loadAd {
  if (![self canLoad]) return;
  UIWindow *window = JAdbidKeyWindow();
  if (!window) {
    self.statusLabel.text = @"窗口不可用";
    return;
  }
  if (!self.ad) {
    self.ad = [[JSplashAd alloc] initWithAdUnitID:self.adUnitID];
    self.ad.delegate = self;
    self.ad.sceneID = @"sample-splash";
  }
  self.showButton.enabled = NO;
  [self beginLoading];
  [self.ad loadWithWindow:window];
}
- (void)showAd {
  if (![self canShow]) return;
  UIWindow *window = JAdbidKeyWindow();
  if (window && self.ad.ready)
    [self.ad showInWindow:window];
  else
    self.statusLabel.text = @"开屏广告尚未 ready 或窗口不可用";
}
- (void)ad:(JSplashAd *)ad didLoad:(JAdInfo *)info {
  self.showButton.enabled = YES;
  [self recordEvent:@"load" info:info];
  [self finishLoadingWithText:@"开屏加载成功，可点击展示"];
}
- (void)ad:(JSplashAd *)ad didFailToLoad:(JAdError *)error {
  [self recordFailure:error stage:@"load"];
  [self finishLoadingWithText:[self displayTextForError:error]];
}
- (void)ad:(JSplashAd *)ad didShow:(JAdInfo *)info {
  [self recordEvent:@"show" info:info];
}
- (void)ad:(JSplashAd *)ad didClick:(JAdInfo *)info {
  [self recordEvent:@"click" info:info];
}
- (void)ad:(JSplashAd *)ad didClose:(JAdInfo *)info {
  self.showButton.enabled = NO;
  [self recordEvent:@"close" info:info];
  self.statusLabel.text = @"开屏已关闭，可重新加载";
}
- (void)ad:(JSplashAd *)ad didFailToShow:(JAdError *)error {
  [self recordFailure:error stage:@"show"];
  self.statusLabel.text = [self displayTextForError:error];
}
- (void)destroyAd {
  self.ad.delegate = nil;
  [self.ad destroy];
  self.ad = nil;
}
@end
