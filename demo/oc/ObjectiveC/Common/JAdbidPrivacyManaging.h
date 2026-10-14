#import <UIKit/UIKit.h>

@protocol JAdbidPrivacyManaging <NSObject>
@property(nonatomic, copy, readonly) NSString *privacySummary;
@property(nonatomic, copy, readonly) NSString *actionTitle;
- (UIViewController *)privacyViewController;
@end

@interface JAdbidHostManagedPrivacyManager : NSObject <JAdbidPrivacyManaging>
@end
