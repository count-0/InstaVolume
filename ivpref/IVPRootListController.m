#include "IVPRootListController.h"
#import <CepheiPrefs/HBSupportController.h>
#include "Generic.h"
@implementation IVPRootListController

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

+ (NSString *)hb_shareText {
    return @"Make your volume hud minimal.";
}

+(NSString *)hb_shareURL {
    return @"";
}

- (void)showSupportEmailController {
	UIViewController *viewController = (UIViewController *)[HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.dopeteam.tails"];
	[self.navigationController pushViewController:viewController animated:YES];
}

-(void) viewWillAppear:(BOOL) animated{
	[super viewWillAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        self.table.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);
    }
	[self setupHeader];
}


-(void)setupHeader{
	UIView *header = nil;
    header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0,30,self.view.bounds.size.width,45)];
    name.text = @"InstaVolume";
    name.textAlignment = NSTextAlignmentCenter;
    name.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:55];
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0,70,self.view.bounds.size.width,45)];
    desc.text = @"Minimal Volume Hud";
    desc.textAlignment = NSTextAlignmentCenter;
    desc.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    desc.textColor = [UIColor blueColor];
    [header addSubview:name];
    [header addSubview:desc];
    [self.table setTableHeaderView:header];
}

@end
