#import <UIKit/UIKit.h>
@import JAdbidCore;

@interface JAdbidFormatViewController : UIViewController
@property(nonatomic, copy, readonly) NSString *adUnitID;
@property(nonatomic, strong, readonly) UILabel *statusLabel;
@property(nonatomic, strong, readonly) UIStackView *contentStack;
@property(nonatomic, strong, readonly) UIButton *loadButton;
@property(nonatomic, assign, getter=isLoading) BOOL loading;
- (instancetype)initWithTitle:(NSString *)title adUnitID:(NSString *)adUnitID;
- (UIButton *)addActionWithTitle:(NSString *)title selector:(SEL)selector;
- (BOOL)canLoad;
- (BOOL)canShow;
- (void)beginLoading;
- (void)finishLoadingWithText:(NSString *)text;
- (NSString *)displayTextForError:(JAdError *)error;
- (void)recordEvent:(NSString *)event info:(JAdInfo *)info;
- (void)recordFailure:(JAdError *)error stage:(NSString *)stage;
- (void)loadAd;
- (void)destroyAd;
@end
