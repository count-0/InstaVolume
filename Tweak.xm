#import "Tweak.h"

UIWindow *volSlidWindow;

VolumeUISlider *volSlid;

NSTimer *timer;

static CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
static CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

static CGFloat screenHeightScale = 40;
static float delayDuration = 1.25;
static float animationDuration = 0.25;


%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upVolSlid:) name:@"SBMediaVolumeChangedNotification" object:[%c(SBMediaController) sharedInstance]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

	volSlidWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0 - screenHeightScale, screenWidth, screenHeightScale)];
	volSlidWindow.windowLevel = UIWindowLevelStatusBar + 100.0;
	volSlidWindow.hidden = YES;
	volSlidWindow.backgroundColor = [UIColor clearColor];
	//volSlidWindow.alpha = 1.0;

	volSlid = [[VolumeUISlider alloc] initWithFrame:CGRectMake(10, 0, screenWidth-20, screenHeightScale)];
	volSlid.backgroundColor = [UIColor clearColor];
	volSlid.value = [[%c(SBMediaController) sharedInstance] volume];
	volSlid.continuous = YES;
	volSlid.minimumValue = 0.0;
	volSlid.maximumValue = 1.0;
	volSlid.maximumTrackTintColor = [UIColor grayColor];
	[volSlid setThumbImage:[[[UIImage alloc] init] autorelease] forState:UIControlStateNormal];
	volSlid.minimumTrackTintColor = [UIColor whiteColor];
	[volSlidWindow addSubview:volSlid];

	[volSlid addTarget:self action:@selector(volSlidMoved:) forControlEvents:UIControlEventValueChanged];
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

			volSlid.frame = CGRectMake(10, 0, screenWidth-20, screenHeightScale);

			break;
		case UIInterfaceOrientationLandscapeLeft:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);

			volSlidWindow.frame = CGRectMake(0 - screenHeightScale, 0, screenHeightScale, screenHeight);

			volSlid.frame = CGRectMake(screenHeightScale, 0, screenHeight - (screenHeightScale * 2), screenHeightScale);

			break;
		case UIInterfaceOrientationLandscapeRight:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI_2);

			volSlidWindow.frame = CGRectMake(screenWidth, 0, screenHeightScale, screenHeight);

			volSlid.frame = CGRectMake(screenHeightScale, 0, screenHeight - (screenHeightScale * 2), screenHeightScale);

			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			volSlidWindow.transform = CGAffineTransformMakeRotation(M_PI);

			volSlidWindow.frame = CGRectMake(0, screenHeight + screenHeightScale, screenWidth, screenHeightScale);

			volSlid.frame = CGRectMake(10, 0, screenWidth-20, screenHeightScale);

			break;
	}
}
%end

%hook SBHUDController
- (void)presentHUDView:(SBHUDView *)hud autoDismissWithDelay:(double)arg2 {
		if ([hud.title isEqual:@"Ringer"]) {
			if ([[%c(SBMediaController) sharedInstance] isRingerMuted]) {
				volSlid.value = 0.0;
			}
			else {
				volSlid.value = 1.0;
			}
		}

		else {
			volSlid.value = [[%c(SBMediaController) sharedInstance] volume];
		}

		[self volSlideShouldShow:nil];
}

%new
- (void)volSlideShouldShow:(id)sender {
	switch ([[UIApplication sharedApplication] _frontMostAppOrientation]) {
		case UIInterfaceOrientationPortrait:
			[self showVolSlide:CGRectMake(0, 0, screenWidth, screenHeightScale)];

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
- (CGRect)trackRectForBounds:(CGRect)bounds{
    CGRect customBounds = CGRectMake(bounds.origin.x, bounds.size.height/2, bounds.size.width, 5);
    return customBounds;
}

@end