V8 = {
	basepath = PathDir(ModuleFilename()),

	OptFind = function (name, required)
		local check = function(option, settings)
			option.value = false
			option.use_winlib = 0
			option.lib_path = nil

			if platform == "win32" then
				option.value = true
				option.use_winlib = 32
			elseif platform == "win64" then
				option.value = true
				option.use_winlib = 64
			end
		end

		local apply = function(option, settings)
			if option.use_winlib > 0 then
				settings.cc.includes:Add(V8.basepath .. "/include")
				if option.use_winlib == 32 then
					settings.link.libpath:Add(V8.basepath .. "/windows/lib32")
				else
					settings.link.libpath:Add(V8.basepath .. "/windows/lib64")
				end
				settings.link.libs:Add("v8")
				settings.link.libs:Add("v8_libbase")
				settings.link.libs:Add("icui18n")
				settings.link.libs:Add("v8_libplatform")

			end
		end

		local save = function(option, output)
			output:option(option, "value")
			output:option(option, "use_winlib")
		end

		local display = function(option)
			if option.value == true then
				if option.use_winlib == 32 then return "using supplied win32 libraries" end
				if option.use_winlib == 64 then return "using supplied win64 libraries" end
				return "using unknown method (black magic)"
			else
				if option.required then
					return "not found (required)"
				else
					return "not found (optional)"
				end
			end
		end

		local o = MakeOption(name, 0, check, save, display)
		o.Apply = apply
		o.include_path = nil
		o.lib_path = nil
		o.required = required
		return o
	end
}
