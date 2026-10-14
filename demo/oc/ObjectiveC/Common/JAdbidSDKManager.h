#import <Foundation/Foundation.h>
#import "JAdbidPrivacyManaging.h"
#import "JAdbidSampleConfiguration.h"

typedef NS_ENUM(NSUInteger, JAdbidSDKState) {
  JAdbidSDKStateIdle,
  JAdbidSDKStateInitializing,
  JAdbidSDKStateInitialized,
  JAdbidSDKStateFailed,
};

@interface JAdbidSDKManager : NSObject
@property(class, nonatomic, readonly) JAdbidSDKManager *sharedManager;
@property(nonatomic, readonly) JAdbidSDKState state;
@property(nonatomic, strong, readonly) id<JAdbidSampleConfiguring> configuration;
@property(nonatomic, strong, readonly) id<JAdbidPrivacyManaging> privacyManager;
- (void)configureWithConfiguration:(id<JAdbidSampleConfiguring>)configuration
                    privacyManager:(id<JAdbidPrivacyManaging>)privacyManager;
- (void)initializeSDKWithCompletion:(void (^)(NSError *error))completion;
@end
