#import "JAdbidBannerViewController.h"

@interface JAdbidBannerViewController () <JBannerAdDelegate>
@property(nonatomic, strong) JBannerAd *ad;
@property(nonatomic, strong) NSLayoutConstraint *bannerHeight;
@end

@implementation JAdbidBannerViewController
- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
  return [super initWithTitle:@"横幅广告" adUnitID:adUnitID];
}
- (void)loadAd {
  if (![self canLoad]) return;
  if (!self.ad) {
    self.ad = [[JBannerAd alloc] initWithAdUnitID:self.adUnitID];
    self.ad.delegate = self;
    self.ad.adSize = CGSizeMake(320, 50);
    [self.contentStack addArrangedSubview:self.ad.bannerView];
    self.bannerHeight = [self.ad.bannerView.heightAnchor constraintEqualToConstant:50];
    self.bannerHeight.active = YES;
  }
  [self beginLoading];
  [self.ad loadWithViewController:self];
}
- (void)ad:(JBannerAd *)ad didLoad:(JAdInfo *)info {
  [self recordEvent:@"load" info:info];
  [self finishLoadingWithText:@"横幅加载成功，页面内自动展示"];
}
- (void)ad:(JBannerAd *)ad didFailToLoad:(JAdError *)error {
  [self recordFailure:error stage:@"load"];
  [self finishLoadingWithText:[self displayTextForError:error]];
}
- (void)ad:(JBannerAd *)ad didShow:(JAdInfo *)info {
  [self recordEvent:@"show" info:info];
}
- (void)ad:(JBannerAd *)ad didClick:(JAdInfo *)info {
  [self recordEvent:@"click" info:info];
}
- (void)ad:(JBannerAd *)ad didClose:(JAdInfo *)info {
  [self recordEvent:@"close" info:info];
}
- (void)ad:(JBannerAd *)ad didFailToShow:(JAdError *)error {
  [self recordFailure:error stage:@"show"];
  self.statusLabel.text = [self displayTextForError:error];
}
- (void)ad:(JBannerAd *)ad didChangeSize:(CGSize)size {
  self.bannerHeight.constant = size.height;
  [self recordEvent:@"sizeChanged" info:nil];
}
- (void)destroyAd {
  self.ad.delegate = nil;
  [self.ad destroy];
  self.ad = nil;
  self.bannerHeight = nil;
}
@end
