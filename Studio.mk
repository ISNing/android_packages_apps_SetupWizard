LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := SetupWizardStudio
LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_SUFFIX := -timestamp
setupwizard_system_libs_deps := $(call java-lib-deps,core-oj) \
                           $(call java-lib-deps,core-libart) \
                           $(call java-lib-deps,telephony-common) \
                           $(call java-lib-deps,org.lineageos.platform.internal) \
                           $(call java-lib-deps,setup-wizard-lib-gingerbread-compat) \
                           $(call java-lib-deps,setup-wizard-navbar)
setupwizard_system_libs_path := $(abspath $(LOCAL_PATH))/system_libs

setupwizard_system_res_deps := $(abspath $(TOPDIR)frameworks/opt/setupwizard/library/main/res):library_gingerbread/main_res \
                           $(abspath $(TOPDIR)frameworks/opt/setupwizard/library/gingerbread/res):library_gingerbread/gingerbread_res \
                           $(abspath $(TOPDIR)frameworks/opt/setupwizard/library/recyclerview/res):library_gingerbread/recyclerview_res \
                           $(abspath $(TOPDIR)frameworks/opt/setupwizard/navigationbar/res):nav/res \
                           $(abspath $(LOCAL_PATH)/androidLibraryTemplate):library_gingerbread \
                           $(abspath $(LOCAL_PATH)/androidLibraryTemplate):nav

setupwizard_system_res_path := $(abspath $(LOCAL_PATH))/system_res

setupwizard_library_replaces := $(abspath $(setupwizard_system_res_path))/library_gingerbread:com.android.setupwizardlib:\"main_res\",\"gingerbread_res\",\"recyclerview_res\" \
                           $(abspath $(setupwizard_system_res_path))/nav:com.android.setupwizard.navigationbar:\"res\"

include $(BUILD_SYSTEM)/base_rules.mk

.PHONY: copy_setupwizard_system_deps
copy_setupwizard_system_deps: $(setupwizard_system_libs_deps) $(shell echo -n $(setupwizard_system_res_deps) | xargs -d" " -I{target} sh -c "echo {target} | awk -F \":\" '{print \$$(NF-1)}'")
	$(hide) mkdir -p $(setupwizard_system_libs_path)
	$(hide) rm -rf $(setupwizard_system_libs_path)/*.jar
	# Copy jars
	$(hide) echo -n $(setupwizard_system_libs_deps) | xargs -d" " -n1 -I{target} sh -c "cp {target} $(setupwizard_system_libs_path)/\`echo {target} | awk -F \"/\" '{gsub(/\_intermediates/,\"\"); print \$$(NF-1)}'\`.jar"
	
	$(hide) mkdir -p $(setupwizard_system_res_path)
	$(hide) rm -rf $(setupwizard_system_res_path)/*
	# Makedirs of library modules
	$(hide) echo -n $(setupwizard_system_res_deps) | xargs -d" " -n1 -I{target} sh -c "mkdir -p \`echo {target} | awk -F \":\" '{print \$$(NF)}'\`"
	# Copy resources of library modules
	$(hide) echo -n $(setupwizard_system_res_deps) | xargs -d" " -n1 -I{target} sh -c "cp \`echo {target} | awk -F \":\" '{print \$$(NF-1)}'\`/* $(setupwizard_system_res_path)/\`echo {target} | awk -F \":\" '{print \$$(NF)}'\`"
	# Replace packagename and resources_dirs
	$(hide) echo -n $(setupwizard_system_res_deps) | xargs -d" " -n1 -I{target} sh -c "sed  -i -e \"s/{resources_dirs}/\`echo {target} | awk -F \":\" '{print \$$(NF)}'\`/g\" \`echo {target} | awk -F \":\" '{print \$$(NF-2)}'\`/build.gradle && sed  -i -e \"s/{resources_dirs}/\`echo {target} | awk -F \":\" '{print \$$(NF-1)}'\`/g\" \`echo {target} | awk -F \":\" '{print \$$(NF-2)}'\`/AndroidManifest.xml"

$(LOCAL_BUILT_MODULE): copy_setupwizard_system_deps
	$(hide) echo "Fake: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) touch $@
