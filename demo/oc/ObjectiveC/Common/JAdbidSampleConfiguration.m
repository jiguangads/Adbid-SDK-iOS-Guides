#import "JAdbidSampleConfiguration.h"

@interface JAdbidSampleConfiguration ()
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *values;
@end

@implementation JAdbidSampleConfiguration

- (instancetype)init {
  if ((self = [super init])) {
    NSURL *url = [NSBundle.mainBundle URLForResource:@"SampleConfig" withExtension:@"plist"];
    _values = url ? [NSDictionary dictionaryWithContentsOfURL:url] ?: @{} : @{};
  }
  return self;
}

- (NSString *)appID {
  return self.values[@"AppID"] ?: @"";
}
- (NSString *)adUnitIDForKey:(NSString *)key {
  return self.values[key] ?: @"";
}
- (void)configureSDKConfig:(JAdConfig *)config {
#if DEBUG
  // 宿主Debug也可能链接Release SDK，需显式启用联调日志。
  config.debugMode = YES;
#endif
}
- (NSString *)diagnosticTextForError:(JAdError *)error {
  return error.message ?: @"广告请求失败";
}

@end
