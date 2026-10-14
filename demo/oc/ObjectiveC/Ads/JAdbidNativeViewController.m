#import "JAdbidNativeViewController.h"

@interface JAdbidSampleNativeView : UIView <JAdNativeRendering>
@property(nonatomic, strong) UILabel *titleLabel;
@end
@implementation JAdbidSampleNativeView
- (instancetype)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_titleLabel];
  }
  return self;
}
- (UILabel *)nativeTitleTextLabel {
  return self.titleLabel;
}
@end

@interface JAdbidNativeViewController () <JNativeAdDelegate>
@property(nonatomic, strong) JNativeAd *ad;
@property(nonatomic, strong) UIButton *renderButton;
@property(nonatomic, strong) UIView *container;
@end

@implementation JAdbidNativeViewController
- (instancetype)initWithAdUnitID:(NSString *)adUnitID {
  return [super initWithTitle:@"原生广告" adUnitID:adUnitID];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.renderButton = [self addActionWithTitle:@"渲染原生广告" selector:@selector(renderAd)];
  self.renderButton.enabled = NO;
  self.container = [UIView new];
  self.container.backgroundColor = UIColor.secondarySystemBackgroundColor;
  [self.contentStack addArrangedSubview:self.container];
  [self.container.heightAnchor constraintEqualToConstant:250].active = YES;
}
- (void)loadAd {
  if (![self canLoad]) return;
  if (!self.ad) {
    self.ad = [[JNativeAd alloc] initWithAdUnitID:self.adUnitID];
    self.ad.delegate = self;
    self.ad.templateRenderSize = CGSizeMake(320, 250);
  }
  self.renderButton.enabled = NO;
  [self beginLoading];
  [self.ad loadWithViewController:self];
}
- (void)renderAd {
  if (![self canShow]) return;
  if (!self.ad.ready) {
    self.statusLabel.text = @"原生广告尚未 ready";
    return;
  }
  for (UIView *view in self.container.subviews) {
    [view removeFromSuperview];
  }
  JAdbidSampleNativeView *material = [[JAdbidSampleNativeView alloc] initWithFrame:self.container.bounds];
  NSError *error = nil;
  if (![self.ad renderAssetView:material inContainer:self.container viewController:self error:&error]) {
    self.statusLabel.text = error ? [NSString stringWithFormat:@"原生渲染未提交：%ld", (long)error.code]
                                  : @"原生渲染未提交：未知错误";
  } else {
    self.renderButton.enabled = NO;
    self.statusLabel.text = @"原生广告已提交渲染";
  }
}
- (void)ad:(JNativeAd *)ad didLoad:(JAdInfo *)info {
  self.renderButton.enabled = YES;
  [self recordEvent:@"load" info:info];
  [self finishLoadingWithText:@"原生广告加载成功，可点击渲染"];
}
- (void)ad:(JNativeAd *)ad didFailToLoad:(JAdError *)error {
  [self recordFailure:error stage:@"load"];
  [self finishLoadingWithText:[self displayTextForError:error]];
}
- (void)ad:(JNativeAd *)ad didShow:(JAdInfo *)info {
  [self recordEvent:@"show" info:info];
}
- (void)ad:(JNativeAd *)ad didClick:(JAdInfo *)info {
  [self recordEvent:@"click" info:info];
}
- (void)ad:(JNativeAd *)ad didClose:(JAdInfo *)info {
  [self recordEvent:@"close" info:info];
}
- (void)ad:(JNativeAd *)ad didFailToShow:(JAdError *)error {
  [self recordFailure:error stage:@"show"];
  self.statusLabel.text = [self displayTextForError:error];
}
- (void)destroyAd {
  self.ad.delegate = nil;
  [self.ad destroy];
  self.ad = nil;
}
@end
