package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/openssl-$(version).tar.gz")

    add_versions("1.1.1i", "e8be6a35fe41d10603c3cc635e93289ed00bf34b79671a3a4de64fcee00d5242")

    add_links("ssl", "crypto")

    on_install("linux", "macosx", function (package)
        os.vrun("./config %s --prefix=\"%s\"", package:debug() and "--debug" or "", package:installdir())
        import("package.tools.make").install(package)
    end)

    on_install("cross", function (package)
	import("package.tools.autoconf").install(package, configs, {cxflags = "-Iinclude"})
        local target = "linux-generic32"
        --if package:is_os("linux") then
        --    if package:is_arch("arm64") then
        --        target = "linux-aarch64"
        --    else
        --        target = "linux-armv4"
        --    end
        --end
        local configs = {target, "-DOPENSSL_NO_HEARTBEATS", "no-shared", "no-threads", "--prefix=" .. package:installdir()}
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
        os.vrunv("./Configure", configs, {envs = buildenvs})
        local makeconfigs = {CFLAGS = buildenvs.CFLAGS, ASFLAGS = buildenvs.ASFLAGS}
        import("package.tools.make").install(package, makeconfigs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
