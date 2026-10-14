#import <Foundation/Foundation.h>
@import JAdbidCore;

@protocol JAdbidSampleConfiguring <NSObject>
- (NSString *)appID;
- (NSString *)adUnitIDForKey:(NSString *)key;
- (void)configureSDKConfig:(JAdConfig *)config;
- (NSString *)diagnosticTextForError:(JAdError *)error;
@end

@interface JAdbidSampleConfiguration : NSObject <JAdbidSampleConfiguring>
@end
