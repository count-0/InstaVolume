@interface UIApplication (VolumeSlider)
- (UIInterfaceOrientation)_frontMostAppOrientation;
@end

@interface UIImage (VolumeSlider)
- (UIImage *)_flatImageWithColor:(UIColor *)color;
@end

@interface VolumeUISlider : UISlider
@end

@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (float)volume;
- (void)setVolume:(float)volume;
- (BOOL)isRingerMuted;
@end

@interface SBHUDView : UIView
- (NSString *)title;
@end

@interface SBHUDController : UIViewController
+ (SBHUDController *)sharedHUDController;
- (void)presentHUDView:(SBHUDView *)arg1 autoDismissWithDelay:(double)arg2;
- (void)volSlideShouldShow:(id)sender;
- (void)volSliderShouldHide:(id)sender;
- (void)showVolSlide:(CGRect)frame;
- (void)hideVolSlide:(CGRect)frame;
@end