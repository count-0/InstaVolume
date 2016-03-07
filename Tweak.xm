#import "Tweak.h"

UIWindow *volSlidWindow;

VolumeUISlider *volSlid;

UIViewController *viewctrl;

NSTimer *timer;

static CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
static CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

static CGFloat screenHeightScale = 10;
static float delayDuration = 1.25;
static float animationDuration = 0.25;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;

	volSlidWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale)];
	volSlidWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	volSlidWindow.hidden = YES;
	volSlidWindow.backgroundColor = [UIColor clearColor];
	volSlidWindow.alpha = 1.0;

	viewctrl = [[UIViewController alloc] init];
	volSlid = [[VolumeUISlider alloc] initWithFrame:CGRectMake(10, 10, screenWidth-20, screenHeightScale)];
	volSlid.backgroundColor = [UIColor clearColor];
	volSlid.value = [[%c(SBMediaController) sharedInstance] volume];
	volSlid.continuous = YES;
	volSlid.minimumValue = 0.0;
	volSlid.maximumValue = 1.0;
	volSlid.maximumTrackTintColor = [UIColor grayColor];
	[volSlid setThumbImage:[[[UIImage alloc] init] autorelease] forState:UIControlStateNormal];
	volSlid.minimumTrackTintColor = [UIColor whiteColor];
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

			volSlidWindow.frame = CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale);

			volSlid.frame = CGRectMake(10, 10, screenWidth-20, screenHeightScale);

			break;
		case UIInterfaceOrientationLandscapeLeft:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);

			volSlidWindow.frame = CGRectMake(0 - screenHeightScale, 0, screenHeightScale, screenHeight);

			volSlid.frame = CGRectMake(10, 0, screenHeight-20, screenHeightScale);

			break;
		case UIInterfaceOrientationLandscapeRight:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI_2);

			volSlidWindow.frame = CGRectMake(screenWidth, 0, screenHeightScale, screenHeight);

			volSlid.frame = CGRectMake(screenHeightScale, 0, screenHeight - (screenHeightScale * 2), screenHeightScale);

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI);

			volSlidWindow.frame = CGRectMake(0, screenHeight + screenHeightScale, screenWidth, screenHeightScale);

			break;
	}
}
%end

%hook SBHUDController
- (void)presentHUDView:(SBHUDView *)hud autoDismissWithDelay:(double)arg2 {

		volSlid.value = [hud progress];

		[self volSlideShouldShow:nil];
		//%orig;
}

%new
- (void)volSlideShouldShow:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self showVolSlide:CGRectMake(0, 0, screenWidth, screenHeightScale)];
			//[[UIApplication sharedApplication] setStatusBarHidden:YES];
			//[[%c(SBAppStatusBarManager) sharedInstance] hideStatusBar]; 
			break;
		case UIInterfaceOrientationLandscapeLeft:
			[self showVolSlide:CGRectMake(0, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationLandscapeRight:
			[self showVolSlide:CGRectMake(screenWidth - screenHeightScale, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[self showVolSlide:CGRectMake(screenHeight - screenHeightScale, 0, screenWidth, screenHeightScale)];

			break;
	}
}

%new
- (void)volSlideShouldHide:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self hideVolSlide:CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale)];
			//[[UIApplication sharedApplication] setStatusBarHidden:NO];
			//[[%c(SBAppStatusBarManager) sharedInstance] showStatusBar]; 

			break;
		case UIInterfaceOrientationLandscapeLeft:
			[self hideVolSlide:CGRectMake(0 - screenHeightScale, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationLandscapeRight:
			[self hideVolSlide:CGRectMake(screenWidth, 0, screenHeightScale, screenHeight)];

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[self hideVolSlide:CGRectMake(0, screenHeight + screenHeightScale, screenWidth, screenHeightScale)];

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
    customBounds.size.height = 5;
    return customBounds;

}

- (void)layoutSubviews
{
	[super layoutSubviews];
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			self.transform = CGAffineTransformIdentity;
			self.frame = CGRectMake(10, 10, screenWidth-20, screenHeightScale);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			self.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);
			self.frame = CGRectMake(10, 10, screenHeightScale, screenHeight-20);
			break;
		case UIInterfaceOrientationLandscapeRight:
			self.transform = CGAffineTransformMakeRotation(M_PI_2);
			self.frame = CGRectMake(-10, 10, screenHeightScale, screenHeight-20);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			self.transform = CGAffineTransformMakeRotation(M_PI);
			self.frame = CGRectMake(10, 10, screenWidth-20, screenHeightScale);
			break;
	}
}

@end