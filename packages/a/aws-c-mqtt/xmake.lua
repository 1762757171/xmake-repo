package("aws-c-mqtt")
    set_homepage("https://github.com/awslabs/aws-c-mqtt")
    set_description("C99 implementation of the MQTT 3.1.1 specification.")
    set_license("Apache-2.0")

    add_urls("https://github.com/awslabs/aws-c-mqtt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/awslabs/aws-c-mqtt.git")

    add_versions("v0.9.5", "987289535d3c988fe949f49d81268736c96fe27b27c98c899f0a148577f6627b")

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    add_configs("assert_lock_help", {description = "Enable ASSERT_SYNCED_DATA_LOCK_HELD for checking thread issue", default = false, type = "boolean"})

    add_deps("cmake", "aws-c-http", "aws-c-io", "aws-c-cal", "aws-c-common")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "msys", "cross", function (package)
        local cmakedir = package:dep("aws-c-common"):installdir("lib", "cmake")
        if package:is_plat("windows") then
            cmakedir = cmakedir:gsub("\\", "/")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_MODULE_PATH=" .. cmakedir}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SANITIZERS=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DASSERT_LOCK_HELD=" .. (package:config("assert_lock_help") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DAWS_STATIC_MSVC_RUNTIME_LIBRARY=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aws_mqtt_library_init", {includes = "aws/mqtt/mqtt.h"}))
    end)
