package("quickjs")

    set_homepage("https://bellard.org/quickjs/")
    set_description("A small and embeddable Javascript engine.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/quickjs-$(version).tar.xz")

    add_versions("2020-11-08", "2e9d63dab390a95ed365238f21d8e9069187f7ed195782027f0ab311bb64187b")

    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "1-quickjs-makefile-for-xmake.patch"), "b5982dad3ac3412dcac7f71c23baa199ca74dd090359d9c17cb024c1ef70fc0e")
    add_patches("2020-11-08", path.join(os.scriptdir(), "patches", "2020-11-08", "2-quickjs-for-xmake.patch"), "30b6acb7563c50936fb76e278eacdb1d0ba9c66f914e2cfeac051b4633af95c1")

    add_includedirs("include/quickjs")
    if not is_plat("windows") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("cross", function (package)
        local buildenvs = import("package.tools.autoconf").buildenvs(package)
	buildenvs.CFLAGS = (string.gsub(buildenvs.CFLAGS, "-O0", ""))
	buildenvs.LDFLAGS = (string.gsub(buildenvs.LDFLAGS, "-O0", ""))
        buildenvs.LINKFLAGS = ("-g -flto " .. buildenvs.LDFLAGS)
	buildenvs.CPPFLAGS = (buildenvs.CFLAGS .. " -I.")
	io.gsub("Makefile", "\nprefix=\n", "\nprefix=" .. package:installdir())
	local makeconfigs = {V=1, CPPFLAGS = buildenvs.CPPFLAGS, LINKFLAGS = buildenvs.LINKFLAGS, CXX=buildenvs.CXX}
	import("package.tools.make").install(package, makeconfigs)
    end)

    on_test(function (package)
	assert(os.isfile(path.join(package:installdir("bin"), "qjs")))
    end)
