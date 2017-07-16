local load_gearboxMogliScreen = false

gearboxMogliRegister = {}
gearboxMogliRegister.isLoaded = true
gearboxMogliRegister.modName  = "FS17_GearboxAddon"
gearboxMogliRegister.g_currentModDirectory = g_currentModDirectory

if load_gearboxMogliScreen then
	source(Utils.getFilename("gearboxMogliScreen.lua", g_currentModDirectory))
end

if SpecializationUtil.specializations["gearboxMogliLoader"] == nil then
	SpecializationUtil.registerSpecialization("gearboxMogliLoader", "gearboxMogliLoader", g_currentModDirectory.."gearboxMogliLoader.lua")
	SpecializationUtil.registerSpecialization("gearboxMogli", "gearboxMogli", g_currentModDirectory.."gearboxMogli.lua")
	SpecializationUtil.registerSpecialization("tempomatMogli", "tempomatMogli", g_currentModDirectory.."tempomatMogli.lua")
	gearboxMogliRegister.isLoaded = false
end

function gearboxMogliRegister:loadMap(name)	
  if not gearboxMogliRegister.isLoaded then	
		gearboxMogliRegister:add()
    gearboxMogliRegister.isLoaded = true
  end

	if load_gearboxMogliScreen then
		-- GUI Stuff
		g_gearboxMogliScreen = gearboxMogliScreen:new()
		g_gui:loadGui(gearboxMogliRegister.g_currentModDirectory .. "gui/gearboxMogliScreen.xml", "gearboxMogliScreen", g_gearboxMogliScreen)	
		FocusManager:setGui("MPLoadingScreen")
	end
end

function gearboxMogliRegister:deleteMap()
  --gearboxMogliRegister.isLoaded = false
	if load_gearboxMogliScreen then
		g_gearboxMogliScreen:delete()
	end
end

function gearboxMogliRegister:mouseEvent(posX, posY, isDown, isUp, button)
end

function gearboxMogliRegister:keyEvent(unicode, sym, modifier, isDown)
end

function gearboxMogliRegister:update(dt)
end

function gearboxMogliRegister:draw()
end

function gearboxMogliRegister:add()
	print("--- loading "..g_i18n:getText("gearboxMogliVERSION").." ---")

	local searchTable  = { "gearboxMogli", "mrGearboxXerion", "mrGearbox2", "gearbox" }	
	local searchTable2 = { "tempomat", "tempomatMogli" }	
	local replObj1     = SpecializationUtil.getSpecialization("gearboxMogli")
	local replObj2     = SpecializationUtil.getSpecialization("tempomatMogli")
	
	local updatedMods  = 0
	local insertedMods = 0
	
	--for n,s in pairs(SpecializationUtil.specializations) do
	--	print(tostring(n).." "..tostring(s.className))
	--end
	
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		local modName            = string.match(k, "([^.]+)")
		local addSpecialization1 = true
		local addSpecialization2 = true
		local correctLocation    = false
		
		if modName ~= nil and modName ~= "" and modName.gearboxMogli ~= nil then
			addSpecialization1 = false
			
		else
			for _, search in pairs(searchTable) do
				if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
					addSpecialization1 = false
					print(string.format(gearboxMogliRegister.modName..": %s already has a gearbox (2)", modName))
					
					local obj = SpecializationUtil.getSpecialization( modName .. "." .. search )
					
					if     obj == nil then
						print(gearboxMogliRegister.modName..": obj is nil")
					elseif obj.version ~= nil and obj.version >= replObj1.version then
						print(gearboxMogliRegister.modName..": obj.version >= replObj1.version")
					else
				--if obj ~= nil and obj.version ~= nil and obj.version < replObj1.version then
						for i,o in pairs(v.specializations) do
							if o == obj then
								v.specializations[i] = replObj1 
								print(string.format(gearboxMogliRegister.modName..": !!!updating gearbox in %s!!!", modName))
								
								updatedMods = updatedMods + 1
							end
						end
					end
					
					break
				end
			end
		end
		
		if addSpecialization1 then
			for _, search in pairs(searchTable2) do
				if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
					addSpecialization2 = false
					print(string.format(gearboxMogliRegister.modName..": %s already has cruise control", modName))

					local obj = SpecializationUtil.getSpecialization( modName .. "." .. search )
					
					if     obj == nil then
						print(gearboxMogliRegister.modName..": obj2 is nil")
					elseif obj.version ~= nil and obj.version >= replObj2.version then
						print(gearboxMogliRegister.modName..": obj2.version >= replObj2.version")
					else
				--if obj ~= nil and obj.version ~= nil and obj.version < replObj1.version then
						for i,o in pairs(v.specializations) do
							if o == obj then
								v.specializations[i] = replObj2
								print(string.format(gearboxMogliRegister.modName..": !!!updating cruise control in %s!!!", modName))
								
							--updatedMods2 = updatedMods2 + 1
							end
						end
					end

					break
				end
			end
		end
		
		for i = 1, table.maxn(v.specializations) do
			local vs = v.specializations[i]
			if      vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("steerable") then
				correctLocation = true
				break
			end
		end
		if correctLocation then
			correctLocation = false
			for i = 1, table.maxn(v.specializations) do
				local vs = v.specializations[i]
				if      vs ~= nil 
						and vs == SpecializationUtil.getSpecialization("motorized") then
					correctLocation = true
					break
				end
			end
		end
		
		if addSpecialization1 and correctLocation then
		--print("adding: "..tostring(modName))
			
			table.insert(v.specializations, SpecializationUtil.getSpecialization("gearboxMogliLoader"))			

			if addSpecialization2 and correctLocation then
				table.insert(v.specializations, SpecializationUtil.getSpecialization("tempomatMogli"))			
			end
			
			insertedMods = insertedMods + 1
		end
	end
	
	print(string.format("--- "..gearboxMogliRegister.modName..": inserted into %d vehicle types / %d vehicle types updated ---", insertedMods, updatedMods ))
	
	g_i18n.globalI18N.texts["gearboxMogliVERSION"]      = g_i18n:getText("input_gearboxMogliVERSION"     )
	g_i18n.globalI18N.texts["gearboxMogliON"]           = g_i18n:getText("input_gearboxMogliON"          )
	g_i18n.globalI18N.texts["gearboxMogliOFF"]          = g_i18n:getText("input_gearboxMogliOFF"         )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_OFF"]	    = g_i18n:getText("gearboxMogliTEXT_OFF"	   )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_AI"]      = g_i18n:getText("gearboxMogliTEXT_AI"     )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_BRAKE"]   = g_i18n:getText("gearboxMogliTEXT_BRAKE"  )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_DC"]      = g_i18n:getText("gearboxMogliTEXT_DC"     )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_NEUTRAL"] = g_i18n:getText("gearboxMogliTEXT_NEUTRAL")
	g_i18n.globalI18N.texts["gearboxMogliTEXT_AUTO"]    = g_i18n:getText("gearboxMogliTEXT_AUTO"   )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_MANUAL"]  = g_i18n:getText("gearboxMogliTEXT_MANUAL" )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_NOGEAR"]  = g_i18n:getText("gearboxMogliTEXT_NOGEAR" )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_VARIO"]   = g_i18n:getText("gearboxMogliTEXT_VARIO"  )
	g_i18n.globalI18N.texts["gearboxMogliTEXT_ALLAUTO"] = g_i18n:getText("gearboxMogliTEXT_ALLAUTO")
	g_i18n.globalI18N.texts["gearboxMogliTEXT_ECO"]     = g_i18n:getText("gearboxMogliTEXT_ECO")
	g_i18n.globalI18N.texts["gearboxMogliAllAutoON"]    = g_i18n:getText("input_gearboxMogliAllAutoON"   )
	g_i18n.globalI18N.texts["gearboxMogliAllAutoOFF"]   = g_i18n:getText("input_gearboxMogliAllAutoOFF"  )
end

addModEventListener(gearboxMogliRegister)
