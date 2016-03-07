include $(THEOS)/makefiles/common.mk

TWEAK_NAME = InstaVolume
InstaVolume_FILES = Tweak.xm IVPreferencesManager.m
InstaVolume_FRAMEWORKS = Foundation UIKit CoreGraphics
InstaVolume_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ivpref
include $(THEOS_MAKE_PATH)/aggregate.mk
