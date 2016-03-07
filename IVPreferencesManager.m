#import "IVPreferencesManager.h"
#import <Cephei/HBPreferences.h>

static NSString *const kIVEnabledKey = @"enabled";
static NSString *const kIVPercentageKey = @"percentage";
static NSString *const kIVHeightKey = @"height";

@implementation IVPreferencesManager {
	HBPreferences *_preferences;
}

+ (instancetype)sharedInstance {
	static IVPreferencesManager *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_preferences = [[HBPreferences alloc] initWithIdentifier:@"com.dopeteam.ivpref"];

		[_preferences registerBool:&_enabled default:YES forKey:kIVEnabledKey];
        [_preferences registerFloat:&_heightScale default:2.0f forKey:kIVPercentageKey];
        [_preferences registerFloat:&_heightSlider default:5.0f forKey:kIVHeightKey];
	}

	return self;
}

#pragma mark - Memory management

- (void)dealloc {
	[_preferences release];

	[super dealloc];
}

@end