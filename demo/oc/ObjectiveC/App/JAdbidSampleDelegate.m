#import "JAdbidSampleDelegate.h"
#import "JAdbidMenuViewController.h"
#import "JAdbidPrivacyManaging.h"
#import "JAdbidSDKManager.h"
#import "JAdbidSampleConfiguration.h"

@implementation JAdbidSampleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
  [JAdbidSDKManager.sharedManager configureWithConfiguration:[self sampleConfiguration]
                                              privacyManager:[self samplePrivacyManager]];

  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  self.window.rootViewController =
      [[UINavigationController alloc] initWithRootViewController:[JAdbidMenuViewController new]];
  [self.window makeKeyAndVisible];

  // 默认启动只核验 JAdbid 接入，不申请隐私权限、不初始化 SDK、不请求广告。
  NSDictionary *result = @{@"version" : JAdManager.sharedInstance.SDKVersion, @"language" : @"Objective-C"};
  NSURL *url = [[NSFileManager.defaultManager
                    URLsForDirectory:NSDocumentDirectory
                           inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"integration.json"];
  [[NSJSONSerialization dataWithJSONObject:result options:0 error:NULL] writeToURL:url atomically:YES];
  return YES;
}

- (id<JAdbidSampleConfiguring>)sampleConfiguration {
  return [JAdbidSampleConfiguration new];
}
- (id<JAdbidPrivacyManaging>)samplePrivacyManager {
  return [JAdbidHostManagedPrivacyManager new];
}

@end
