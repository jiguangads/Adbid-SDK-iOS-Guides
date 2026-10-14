#import <UIKit/UIKit.h>
#import "JAdbidPrivacyManaging.h"
#import "JAdbidSampleConfiguration.h"

@interface JAdbidSampleDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
- (id<JAdbidSampleConfiguring>)sampleConfiguration;
- (id<JAdbidPrivacyManaging>)samplePrivacyManager;
@end
