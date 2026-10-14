#import "JAdbidRewardedViewController.h"

@interface JAdbidRewardedViewController () <JRewardedVideoAdDelegate>
@property(nonatomic, strong) JRewardedVideoAd *ad;
@property(nonatomic, strong) UIButton *showButton;
@end

@implementation JAdbidRewardedViewController
- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
  return [super initWithTitle:@"激励视频" adUnitID:adUnitID];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.showButton = [self addActionWithTitle:@"展示激励视频" selector:@selector(showAd)];
  self.showButton.enabled = NO;
}
- (void)loadAd {
  if (![self canLoad]) return;
  if (!self.ad) {
    self.ad = [[JRewardedVideoAd alloc] initWithAdUnitID:self.adUnitID];
    self.ad.delegate = self;
    self.ad.sceneID = @"sample-rewarded";
  }
  self.showButton.enabled = NO;
  [self beginLoading];
  [self.ad loadWithViewController:self];
}
- (void)showAd {
  if (![self canShow]) return;
  if (self.ad.ready)
    [self.ad showFromViewController:self];
  else
    self.statusLabel.text = @"激励视频尚未 ready";
}
- (void)ad:(JRewardedVideoAd *)ad didLoad:(JAdInfo *)info {
  self.showButton.enabled = YES;
  [self recordEvent:@"load" info:info];
  [self finishLoadingWithText:@"激励视频加载成功，可点击展示"];
}
- (void)ad:(JRewardedVideoAd *)ad didFailToLoad:(JAdError *)error {
  [self recordFailure:error stage:@"load"];
  [self finishLoadingWithText:[self displayTextForError:error]];
}
- (void)ad:(JRewardedVideoAd *)ad didShow:(JAdInfo *)info {
  [self recordEvent:@"show" info:info];
}
- (void)ad:(JRewardedVideoAd *)ad didClick:(JAdInfo *)info {
  [self recordEvent:@"click" info:info];
}
- (void)ad:(JRewardedVideoAd *)ad didReward:(JAdInfo *)info {
  [self recordEvent:@"reward" info:info];
  self.statusLabel.text = @"收到奖励回调";
}
- (void)ad:(JRewardedVideoAd *)ad didClose:(JAdInfo *)info {
  self.showButton.enabled = NO;
  [self recordEvent:@"close" info:info];
  self.statusLabel.text = @"激励视频已关闭，可重新加载";
}
- (void)ad:(JRewardedVideoAd *)ad didFailToShow:(JAdError *)error {
  [self recordFailure:error stage:@"show"];
  self.statusLabel.text = [self displayTextForError:error];
}
- (void)ad:(JRewardedVideoAd *)ad didStartVideo:(JAdInfo *)info {
  [self recordEvent:@"videoStart" info:info];
}
- (void)ad:(JRewardedVideoAd *)ad didEndVideo:(JAdInfo *)info {
  [self recordEvent:@"videoEnd" info:info];
}
- (void)destroyAd {
  self.ad.delegate = nil;
  [self.ad destroy];
  self.ad = nil;
}
@end
