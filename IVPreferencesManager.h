#import <Cephei/HBPreferences.h>

@interface IVPreferencesManager : NSObject

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) CGFloat heightScale;
@property (nonatomic, readonly) CGFloat heightSlider;


+ (instancetype)sharedInstance;
@end