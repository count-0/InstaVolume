#import "Tweak.h"

UIWindow *volSlidWindow;

VolumeUISlider *volSlid;

UIViewController *viewctrl;

NSTimer *timer;

static CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
static CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
static float delayDuration = 1.25;
static float animationDuration = 0.25;
static NSString *const kIVBackgroundColorKey = @"backgroundColor";
static NSString *const kIVForegroundColorKey = @"foregroundColor";

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;

	volSlidWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0 - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight)];
	volSlidWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	volSlidWindow.hidden = YES;
	volSlidWindow.backgroundColor = [UIColor clearColor];
	volSlidWindow.alpha = 1.0;

	viewctrl = [[UIViewController alloc] init];
	volSlid = [[VolumeUISlider alloc] initWithFrame:CGRectMake(10, 10, screenWidth-20, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight)];
	volSlid.backgroundColor = [UIColor clearColor];
	volSlid.value = [[%c(SBMediaController) sharedInstance] volume];
	volSlid.continuous = YES;
	volSlid.minimumValue = 0.0;
	volSlid.maximumValue = 1.0;
	volSlid.maximumTrackTintColor = [[IVPreferencesManager sharedInstance] colorForPreference:kIVBackgroundColorKey fallback:@"#808080"];
	volSlid.minimumTrackTintColor = [[IVPreferencesManager sharedInstance] colorForPreference:kIVForegroundColorKey fallback:@"#FFFFFF"];
	[volSlid setThumbImage:[[[UIImage alloc] init] autorelease] forState:UIControlStateNormal];\
	viewctrl.view = volSlid;

	volSlidWindow.rootViewController = viewctrl;

	[volSlid addTarget:self action:@selector(volSlidMoved:) forControlEvents:UIControlEventValueChanged];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upVolSlid:) name:@"SBMediaVolumeChangedNotification" object:[%c(SBMediaController) sharedInstance]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

}

%new
- (void)volSlidMoved:(id)sender {
	[[%c(SBMediaController) sharedInstance] setVolume:volSlid.value];
}

%new
- (void)upVolSlid:(NSNotification *)notification {
	volSlid.value = [[%c(SBMediaController) sharedInstance] volume];
}

%new
- (void)orientationChanged:(NSNotification *)notification {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			volSlidWindow.transform = CGAffineTransformIdentity;

			volSlidWindow.frame = CGRectMake(0, 0 - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight);

			volSlid.frame = CGRectMake(10, 10, screenWidth-20, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight);

			break;
		case UIInterfaceOrientationLandscapeLeft:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);

			volSlidWindow.frame = CGRectMake(0 - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, 0, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight);

			volSlid.frame = CGRectMake(10, 0, screenHeight-20, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight);

			break;
		case UIInterfaceOrientationLandscapeRight:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI_2);

			volSlidWindow.frame = CGRectMake(screenWidth, 0, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight);

			volSlid.frame = CGRectMake(([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, 0, screenHeight - (([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight * 2), ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight);

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI);

			volSlidWindow.frame = CGRectMake(0, screenHeight + ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight);

			break;
	}
}
%end

%hook SBHUDController
- (void)presentHUDView:(SBHUDView *)hud autoDismissWithDelay:(double)arg2 {
		if([[IVPreferencesManager sharedInstance] enabled]){
			volSlid.value = [hud progress];
			volSlid.maximumTrackTintColor = [[IVPreferencesManager sharedInstance] colorForPreference:kIVBackgroundColorKey fallback:@"#808080"];
			volSlid.minimumTrackTintColor = [[IVPreferencesManager sharedInstance] colorForPreference:kIVForegroundColorKey fallback:@"#FFFFFF"];
			[self volSlideShouldShow:nil];
		}
		else
			%orig;
}

%new
- (void)volSlideShouldShow:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self showVolSlide:CGRectMake(0, 0, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight)];
			//[[UIApplication sharedApplication] setStatusBarHidden:YES];
			//[[%c(SBAppStatusBarManager) sharedInstance] hideStatusBar]; 
			break;
		case UIInterfaceOrientationLandscapeLeft:
			[self showVolSlide:CGRectMake(0, 0, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight)];

			break;
		case UIInterfaceOrientationLandscapeRight:
			[self showVolSlide:CGRectMake(screenWidth - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, 0, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight)];

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[self showVolSlide:CGRectMake(screenHeight - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, 0, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight)];

			break;
	}
}

%new
- (void)volSlideShouldHide:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self hideVolSlide:CGRectMake(0, 0 - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight)];
			//[[UIApplication sharedApplication] setStatusBarHidden:NO];
			//[[%c(SBAppStatusBarManager) sharedInstance] showStatusBar]; 

			break;
		case UIInterfaceOrientationLandscapeLeft:
			[self hideVolSlide:CGRectMake(0 - ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, 0, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight)];

			break;
		case UIInterfaceOrientationLandscapeRight:
			[self hideVolSlide:CGRectMake(screenWidth, 0, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight)];

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[self hideVolSlide:CGRectMake(0, screenHeight + ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenWidth, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight)];

			break;
	}
}
%new
- (void)hideVolSlide:(CGRect)frame {
	[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{

		CGRect newWindowFrame = frame;
		volSlidWindow.frame = newWindowFrame;
	}
	completion:^(BOOL finished) {
		volSlidWindow.hidden = YES;
	}];
}

%new
- (void)showVolSlide:(CGRect)frame {
	[UIView animateWithDuration:animationDuration delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
					
		volSlidWindow.hidden = NO;
		CGRect newWindowFrame = frame;
		volSlidWindow.frame = newWindowFrame;
	}
	completion:^(BOOL finished) {
		[timer invalidate];
		timer = nil;
		timer = [[NSTimer scheduledTimerWithTimeInterval:delayDuration target:self selector:@selector(volSlideShouldHide:) userInfo:nil repeats:NO] retain];
	}];
}


%end


@implementation VolumeUISlider

- (instancetype)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	[self setTranslatesAutoresizingMaskIntoConstraints:YES];
	return self;
}
- (CGRect)trackRectForBounds:(CGRect)bounds{

    CGRect customBounds = bounds;
    customBounds.size.height = [[IVPreferencesManager sharedInstance] heightSlider];
    return customBounds;

}

- (void)layoutSubviews
{
	[super layoutSubviews];
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			self.transform = CGAffineTransformIdentity;
			self.frame = CGRectMake(10, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenWidth-20, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			self.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);
			self.frame = CGRectMake(([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, 10, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight-20);
			break;
		case UIInterfaceOrientationLandscapeRight:
			self.transform = CGAffineTransformMakeRotation(M_PI_2);
			self.frame = CGRectMake(-10, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight, screenHeight-20);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			self.transform = CGAffineTransformMakeRotation(M_PI);
			self.frame = CGRectMake(10, 10, screenWidth-20, ([[IVPreferencesManager sharedInstance] heightScale]/100)*screenHeight); // Investigate.
			break;
	}
}

@end