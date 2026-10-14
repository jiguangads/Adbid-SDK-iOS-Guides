#import "JAdbidInterstitialViewController.h"

@interface JAdbidInterstitialViewController () <JInterstitialAdDelegate>
@property(nonatomic, strong) JInterstitialAd *ad;
@property(nonatomic, strong) UIButton *showButton;
@end

@implementation JAdbidInterstitialViewController
- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
  return [super initWithTitle:@"插屏广告" adUnitID:adUnitID];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.showButton = [self addActionWithTitle:@"展示插屏" selector:@selector(showAd)];
  self.showButton.enabled = NO;
}
- (void)loadAd {
  if (![self canLoad]) return;
  if (!self.ad) {
    self.ad = [[JInterstitialAd alloc] initWithAdUnitID:self.adUnitID];
    self.ad.delegate = self;
    self.ad.sceneID = @"sample-interstitial";
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
    self.statusLabel.text = @"插屏广告尚未 ready";
}
- (void)ad:(JInterstitialAd *)ad didLoad:(JAdInfo *)info {
  self.showButton.enabled = YES;
  [self recordEvent:@"load" info:info];
  [self finishLoadingWithText:@"插屏加载成功，可点击展示"];
}
- (void)ad:(JInterstitialAd *)ad didFailToLoad:(JAdError *)error {
  [self recordFailure:error stage:@"load"];
  [self finishLoadingWithText:[self displayTextForError:error]];
}
- (void)ad:(JInterstitialAd *)ad didShow:(JAdInfo *)info {
  [self recordEvent:@"show" info:info];
  self.statusLabel.text = @"插屏已展示";
}
- (void)ad:(JInterstitialAd *)ad didClick:(JAdInfo *)info {
  [self recordEvent:@"click" info:info];
}
- (void)ad:(JInterstitialAd *)ad didClose:(JAdInfo *)info {
  self.showButton.enabled = NO;
  [self recordEvent:@"close" info:info];
  self.statusLabel.text = @"插屏已关闭，可重新加载";
}
- (void)ad:(JInterstitialAd *)ad didFailToShow:(JAdError *)error {
  [self recordFailure:error stage:@"show"];
  self.statusLabel.text = [self displayTextForError:error];
}
- (void)ad:(JInterstitialAd *)ad didStartVideo:(JAdInfo *)info {
  [self recordEvent:@"videoStart" info:info];
}
- (void)ad:(JInterstitialAd *)ad didEndVideo:(JAdInfo *)info {
  [self recordEvent:@"videoEnd" info:info];
}
- (void)destroyAd {
  self.ad.delegate = nil;
  [self.ad destroy];
  self.ad = nil;
}
@end
