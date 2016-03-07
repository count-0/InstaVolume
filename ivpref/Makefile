include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = IVPref
IVPref_FILES = IVPRootListController.m BetterPSSliderTableCell.mm
IVPref_INSTALL_PATH = /Library/PreferenceBundles
IVPref_FRAMEWORKS = UIKit
IVPref_PRIVATE_FRAMEWORKS = Preferences
IVPref_EXTRA_FRAMEWORKS = CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/IVPref.plist$(ECHO_END)
