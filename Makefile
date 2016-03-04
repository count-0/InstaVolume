include $(THEOS)/makefiles/common.mk

TWEAK_NAME = InstaVolume
InstaVolume_FILES = Tweak.xm
InstaVolume_FRAMEWORKS = Foundation UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
include $(THEOS_MAKE_PATH)/aggregate.mk
