#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSliderTableCell.h>
#import <Preferences/PSRootController.h>
#import <UIKit/UIKit.h>

@interface BetterPSSliderTableCell : PSSliderTableCell <UIAlertViewDelegate, UITextFieldDelegate> {
    UIAlertView * alert;
}
-(void) presentPopup;
-(void) typeMinus;
-(void) typePoint;
@end