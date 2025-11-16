
ifneq ($(TARGET_BUILD_VARIANT),eng)
# Disable extra StrictMode features on all non-engineering builds
PRODUCT_SYSTEM_PROPERTIES += persist.sys.strictmode.disable=true
endif

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Convert GC type to non-generational
PRODUCT_PROPERTY_OVERRIDES += \
	dalvik.vm.gctype=nogenerational_cc

# Convert GC type to non-generational
PRODUCT_ART_USE_READ_BARRIER := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# The set of packages we want to force 'speed' compilation on.
PRODUCT_DEXPREOPT_SPEED_APPS += \
    TrebuchetQuickStep \
    Settings \
    SystemUI

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    dalvik.vm.systemuicompilerfilter=speed


