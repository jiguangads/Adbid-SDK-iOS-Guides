#import "JAdbidPrivacyManaging.h"

@implementation JAdbidHostManagedPrivacyManager
- (NSString *)privacySummary {
  return @"公开Demo不主动申请权限；请由宿主先完成CMP/ATT及隐私配置。";
}
- (NSString *)actionTitle {
  return @"";
}
- (UIViewController *)privacyViewController {
  return nil;
}
@end
