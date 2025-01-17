package("lua")

    set_homepage("http://lua.org")
    set_description("A powerful, efficient, lightweight, embeddable scripting language.")

    add_urls("http://117.143.63.254:9012/www/rt-smart/packages/lua-$(version).tar.gz")

    add_versions("5.1.4", "b038e225eaf2a5b57c9bcc35cd13aa8c6c8288ef493d52970c9545074098af3a")

    add_includedirs("include/lua")
    if not is_plat("windows") then
        add_syslinks("dl", "m")
    end

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("cross", "linux", "macosx", "windows", "android", "bsd", function (package)
	--import("core.base.option")
	--print(option.get("includes"))
        local sourcedir = os.isdir("src") and "src/" or "" -- for tar.gz or git source
        io.writefile("xmake.lua", format([[
            local sourcedir = "%s"
            target("lualib")
                set_kind("static")
                set_basename("lua")
                add_headerfiles(sourcedir .. "*.h", {prefixdir = "lua"})
                add_files(sourcedir .. "*.c|lua.c|luac.c|onelua.c")
                add_defines("LUA_COMPAT_5_2", "LUA_COMPAT_5_1")
                if is_plat("linux", "bsd") then
                    add_defines("LUA_USE_LINUX")
                    add_defines("LUA_DL_DLOPEN")
                elseif is_plat("macosx") then
                    add_defines("LUA_USE_MACOSX")
                    add_defines("LUA_DL_DYLD")
                elseif is_plat("windows") then
                    -- Lua already detects Windows and sets according defines
                    if is_kind("shared") then
                        add_defines("LUA_BUILD_AS_DLL", {public = true})
                    end
                end

            target("lua")
                set_kind("binary")
                add_files(sourcedir .. "lua.c")
                add_deps("lualib")
                if not is_plat("windows") then
                    add_syslinks("dl")
                end

            --##can not exec success
            --target("luac")
            --    set_kind("binary")
            --    add_files(sourcedir .. "luac.c")
            --    add_deps("lualib")
            --    if not is_plat("windows") then
            --        add_syslinks("dl")
            --    end
        ]], sourcedir))

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if is_plat(os.host()) then
            os.vrun("lua -e \"print('hello xmake!')\"")
        end
        assert(package:has_cfuncs("lua_getinfo", {includes = "lua.h"}))
    end)
