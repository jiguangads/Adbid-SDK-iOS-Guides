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
- (void)configureSDKConfig:(JAdConfig *)config { /* 公开Demo由宿主决定配置，不开启内部测试能力。 */
}
- (NSString *)diagnosticTextForError:(JAdError *)error {
  return error.message ?: @"广告请求失败";
}

@end
