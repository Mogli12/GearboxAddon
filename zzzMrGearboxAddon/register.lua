
mrGearboxMogliRegister = {};
mrGearboxMogliRegister.isLoaded = true;
mrGearboxMogliRegister.g_currentModDirectory = g_currentModDirectory;

if SpecializationUtil.specializations["mrGearboxMogliLoader"] == nil then
	SpecializationUtil.registerSpecialization("mrGearboxMogliLoader", "mrGearboxMogliLoader", g_currentModDirectory.."mrGearboxMogliLoader.lua")
	SpecializationUtil.registerSpecialization("mrGearboxMogli", "mrGearboxMogli", g_currentModDirectory.."mrGearboxMogli.lua")
	SpecializationUtil.registerSpecialization("tempomatMogli", "tempomatMogli", g_currentModDirectory.."tempomatMogli.lua")
	mrGearboxMogliRegister.isLoaded = false;
end;

function mrGearboxMogliRegister:loadMap(name)	
  if not mrGearboxMogliRegister.isLoaded then	
		mrGearboxMogliRegister:add();
    mrGearboxMogliRegister.isLoaded = true;
  end;
end;

function mrGearboxMogliRegister:deleteMap()
  --mrGearboxMogliRegister.isLoaded = false;
end;

function mrGearboxMogliRegister:mouseEvent(posX, posY, isDown, isUp, button)
end;

function mrGearboxMogliRegister:keyEvent(unicode, sym, modifier, isDown)
end;

function mrGearboxMogliRegister:update(dt)
end;

function mrGearboxMogliRegister:draw()
end;

function mrGearboxMogliRegister:add()
	print("--- loading "..g_i18n:getText("mrGearboxMogliVERSION").." ---")

	local searchTable  = { "mrGearboxMogli", "mrGearboxXerion", "mrGearbox2", "gearbox", "gearboxMogli" };	
	local searchTable2 = { "tempomat", "tempomatMogli" };	
	local replObj1     = SpecializationUtil.getSpecialization("mrGearboxMogli")
	local replObj2     = SpecializationUtil.getSpecialization("tempomatMogli")
	
	local updatedMods  = 0
	local insertedMods = 0
	
	--for n,s in pairs(SpecializationUtil.specializations) do
	--	print(tostring(n).." "..tostring(s.className))
	--end
	
	for k, v in pairs(VehicleTypeUtil.vehicleTypes) do
		local modName            = string.match(k, "([^.]+)");
		local addSpecialization1 = true;
		local addSpecialization2 = true;
		local correctLocation    = false;
		
		if modName ~= nil and modName ~= "" and modName.mrGearboxMogli ~= nil then
			addSpecialization1 = false;
			
		else
			for _, search in pairs(searchTable) do
				if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
					addSpecialization1 = false;
					print(string.format("zzzMrGearboxAddon: %s already has a gearbox (2)", modName))
					
					local obj = SpecializationUtil.getSpecialization( modName .. "." .. search )
					
					if     obj == nil then
						print("zzzMrGearboxAddon: obj is nil")
					elseif obj.version ~= nil and obj.version >= replObj1.version then
						print("zzzMrGearboxAddon: obj.version >= replObj1.version")
					else
				--if obj ~= nil and obj.version ~= nil and obj.version < replObj1.version then
						for i,o in pairs(v.specializations) do
							if o == obj then
								v.specializations[i] = replObj1 
								print(string.format("zzzMrGearboxAddon: !!!updating gearbox in %s!!!", modName))
								
								updatedMods = updatedMods + 1
							end
						end
					end
					
					break;
				end;
			end;
		end;
		
		if addSpecialization1 then
			for _, search in pairs(searchTable2) do
				if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
					addSpecialization2 = false;
					print(string.format("zzzMrGearboxAddon: %s already has cruise control", modName))

					local obj = SpecializationUtil.getSpecialization( modName .. "." .. search )
					
					if     obj == nil then
						print("zzzMrGearboxAddon: obj2 is nil")
					elseif obj.version ~= nil and obj.version >= replObj2.version then
						print("zzzMrGearboxAddon: obj2.version >= replObj2.version")
					else
				--if obj ~= nil and obj.version ~= nil and obj.version < replObj1.version then
						for i,o in pairs(v.specializations) do
							if o == obj then
								v.specializations[i] = replObj2
								print(string.format("zzzMrGearboxAddon: !!!updating cruise control in %s!!!", modName))
								
							--updatedMods2 = updatedMods2 + 1
							end
						end
					end

					break;
				end;
			end;
		end;
		
		for i = 1, table.maxn(v.specializations) do
			local vs = v.specializations[i];
			if      vs ~= nil 
					and vs == SpecializationUtil.getSpecialization("steerable") then
				correctLocation = true;
				break;
			end;
		end;
		
		if addSpecialization1 and correctLocation then
		--print("adding: "..tostring(modName))
			
			table.insert(v.specializations, SpecializationUtil.getSpecialization("mrGearboxMogliLoader"));			

			if addSpecialization2 and correctLocation then
				table.insert(v.specializations, SpecializationUtil.getSpecialization("tempomatMogli"));			
			end;
			
			insertedMods = insertedMods + 1
		end;
	end;
	
	print(string.format("--- zzzMrGearboxAddon: inserted into %d vehicle types / %d vehicle types updated ---", insertedMods, updatedMods ))
	
	g_i18n.globalI18N.texts["mrGearboxMogliVERSION"]      = g_i18n:getText("mrGearboxMogliVERSION"     )
	g_i18n.globalI18N.texts["mrGearboxMogliON"]           = g_i18n:getText("mrGearboxMogliON"          )
	g_i18n.globalI18N.texts["mrGearboxMogliOFF"]          = g_i18n:getText("mrGearboxMogliOFF"         )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_OFF"]	    = g_i18n:getText("mrGearboxMogliTEXT_OFF"	   )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_AI"]      = g_i18n:getText("mrGearboxMogliTEXT_AI"     )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_BRAKE"]   = g_i18n:getText("mrGearboxMogliTEXT_BRAKE"  )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_DC"]      = g_i18n:getText("mrGearboxMogliTEXT_DC"     )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_NEUTRAL"] = g_i18n:getText("mrGearboxMogliTEXT_NEUTRAL")
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_AUTO"]    = g_i18n:getText("mrGearboxMogliTEXT_AUTO"   )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_MANUAL"]  = g_i18n:getText("mrGearboxMogliTEXT_MANUAL" )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_NOGEAR"]  = g_i18n:getText("mrGearboxMogliTEXT_NOGEAR" )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_VARIO"]   = g_i18n:getText("mrGearboxMogliTEXT_VARIO"  )
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_ALLAUTO"] = g_i18n:getText("mrGearboxMogliTEXT_ALLAUTO")
	g_i18n.globalI18N.texts["mrGearboxMogliTEXT_ECO"]     = g_i18n:getText("mrGearboxMogliTEXT_ECO")
	g_i18n.globalI18N.texts["mrGearboxMogliAllAutoON"]    = g_i18n:getText("mrGearboxMogliAllAutoON"   )
	g_i18n.globalI18N.texts["mrGearboxMogliAllAutoOFF"]   = g_i18n:getText("mrGearboxMogliAllAutoOFF"  )
end;

addModEventListener(mrGearboxMogliRegister);
