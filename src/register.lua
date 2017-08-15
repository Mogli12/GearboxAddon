local load_gearboxMogliScreen = true

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
		gearboxMogliRegister.add(self)
    gearboxMogliRegister.isLoaded = true
		ConfigurationUtil.registerConfigurationType("gearboxMogli", "Transmission")
		
		if g_server ~= nil then
			gearboxMogliRegister.addConfigurations(self)
		else
			g_client:getServerConnection():sendEvent(gearboxMogliRegisterNewClient:new())
		end
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
	if g_gearboxMogliScreen ~= nil then
		g_gearboxMogliScreen:delete()
		g_gearboxMogliScreen = nil
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
	
	local noSpec2 = false
	if type( FS17_CCAddon ) == "table" and type( FS17_CCAddon.ccaddon_Register ) == "table" then
		noSpec2 = true
		print("Disabling cruise control modifications")
	end
	
	for k, typeDef in pairs(VehicleTypeUtil.vehicleTypes) do
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
						for i,o in pairs(typeDef.specializations) do
							if o == obj then
								typeDef.specializations[i] = replObj1 
								print(string.format(gearboxMogliRegister.modName..": !!!updating gearbox in %s!!!", modName))
								
								updatedMods = updatedMods + 1
							end
						end
					end
					
					break
				end
			end
		end
		
		if noSpec2 then
			addSpecialization2 = false
		elseif addSpecialization1 then
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
						for i,o in pairs(typeDef.specializations) do
							if o == obj then
								typeDef.specializations[i] = replObj2
								print(string.format(gearboxMogliRegister.modName..": !!!updating cruise control in %s!!!", modName))
								
							--updatedMods2 = updatedMods2 + 1
							end
						end
					end

					break
				end
			end
		end
		
		for i,vs in pairs(typeDef.specializations) do
			if vs == SpecializationUtil.getSpecialization("steerable") then
				correctLocation = true
				break
			end
		end
		if correctLocation then
			correctLocation = false
			for i,vs in pairs(typeDef.specializations) do
				if vs == SpecializationUtil.getSpecialization("motorized") then
					correctLocation = true
					break
				end
			end
		end
		
		if addSpecialization1 and correctLocation then
			typeDef.addMogliGearbox = true
		--print("adding: "..tostring(modName))
			
			table.insert(typeDef.specializations, SpecializationUtil.getSpecialization("gearboxMogliLoader"))			

			if addSpecialization2 and correctLocation then
				table.insert(typeDef.specializations, SpecializationUtil.getSpecialization("tempomatMogli"))			
			end
			
			insertedMods = insertedMods + 1
		end
	end
	
	print(string.format("--- "..gearboxMogliRegister.modName..": inserted into %d vehicle types / %d vehicle types updated ---", insertedMods, updatedMods ))
	
	-- make l10n global 
	for m,t in pairs( g_i18n.texts ) do
		local n = nil
		if     string.sub( m, 1, 18 ) == "input_gearboxMogli" then
			n = string.sub( m, 7 )
		elseif string.sub( m, 1, 12 ) == "gearboxMogli"       then
			n = m
		end
		if n ~= nil and g_i18n.globalI18N.texts[n] == nil then
		--print('"$l10n_'..tostring(n)..'" = "'..tostring(t)..'"')
			g_i18n.globalI18N.texts[n] = t
		end
	end
	
end

function gearboxMogliRegister.testXML( xmlFile, baseName, transName )
	return gearboxMogliLoader.testXmlFile( xmlFile, baseName, transName..".gears.gear(0)#speed", transName..".gears.gear(0)#inverseRatio", transName..".hydrostatic.efficiency#ratio" )
end

function gearboxMogliRegister:addConfigurations()

	gearboxMogliRegister.modifiedStoreItems = {}
	gearboxMogliLoader.initXmlFiles()
	for xmlFileLower,storeItem in pairs( StoreItemsUtil.storeItemsByXMLFilename ) do
		local configFileName = nil
		if storeItem.xmlFilename ~= nil then
			configFileName = string.lower( Utils.removeModDirectory( storeItem.xmlFilename ) )
			
			local vehXmlFile = loadXMLFile("TempConfig", storeItem.xmlFilename);
			local typeName = getXMLString(vehXmlFile, "vehicle#type");
			
			local hasVehicleConfig = gearboxMogliRegister.testXML( vehXmlFile, "vehicle", ".gearboxMogli" )
														or gearboxMogliRegister.testXML( vehXmlFile, "vehicle.motorConfigurations.motorConfiguration(0)", ".gearboxMogli" )					
			
			delete(vehXmlFile)
			
			local addMogliGearbox = false
			
			if typeName ~= nil then
				local typeDef = VehicleTypeUtil.vehicleTypes[typeName];
				local modName, _ = Utils.getModNameAndBaseDirectory(storeItem.xmlFilename);
				if modName ~= nil and typeDef == nil then
					typeName = modName.."."..typeName;
					typeDef = VehicleTypeUtil.vehicleTypes[typeName];
				end;
				
				if typeDef ~= nil then
					addMogliGearbox = typeDef.addMogliGearbox
				end
			end
			
			if addMogliGearbox then
				local modifiedItem = {}
				modifiedItem.xmlFilename = storeItem.xmlFilename				
				modifiedItem.configurations = {}
			
				local entry, configTab, defaultConfigName
				
				if     storeItem.category == "harvesters"   then
					defaultConfigName = "defaultCombine"
				elseif storeItem.category == "forageHarvesters" then
					defaultConfigName = "defaultCombine"
				elseif storeItem.category == "tractors"     then
					defaultConfigName = "defaultTractors"
				elseif storeItem.category == "trucks"       then
					defaultConfigName = "defaultTrucks"
				elseif storeItem.category == "cars"         then
					defaultConfigName = "defaultCars"
				elseif storeItem.category == "wheelLoaders" then
				--defaultConfigName = "defaultTorqueConverter"
					defaultConfigName = "defaultHydrostatic2"
				elseif storeItem.category == "teleLoaders"  then
					defaultConfigName = "defaultHydrostatic2"
				elseif storeItem.category == "skidSteers"   then
					defaultConfigName = "defaultHydrostatic1"
				elseif storeItem.category == "wood"         then
					defaultConfigName = "defaultHydrostatic1"
				elseif storeItem.category == "animals"      then
					defaultConfigName = "defaultHydrostatic1"
				elseif storeItem.category == "sprayers"     then
					defaultConfigName = "defaultHydrostatic2"
				else
					defaultConfigName = "default"
				end
				
				table.insert( modifiedItem.configurations, { name = "off", title = "Standard Transmission", source = -1 } )
				
				local isDefault = true
				if hasVehicleConfig then
					table.insert( modifiedItem.configurations, { name = "standard", title = "Standard Transmission", source = 0, isDefault = isDefault } )
				end
					
				for i=1,2 do
					if i == 1 then
						xmlFile   = gearboxMogliLoader.xmlFileExt	
						configTab = gearboxMogliLoader.configExt
					else
						xmlFile   = gearboxMogliLoader.xmlFileInt
						configTab = gearboxMogliLoader.configInt
					end
					entry = gearboxMogliLoader.getConfigEntry( configTab, configFileName )
					if entry ~= nil then
						if entry.hasGearboxMogliTag then
							table.insert( modifiedItem.configurations, { name = "gearbox addon", title = "Gearbox Addon", source = i, baseName = entry.xmlName, isDefault = isDefault } )
							isDefault = false
						elseif entry.motorConfig == nil then
							local j = 0
							while true do
								local t = string.format("%s.transmissions.transmission(%d)#name", entry.xmlName, j)
								local s = getXMLString( xmlFile, t )
								if s == nil then
									break
								end
								j = j + 1
								
								table.insert( modifiedItem.configurations, { name = s, title = s, source = i, baseName = entry.xmlName, config = j, isDefault = isDefault } )
								isDefault = false
							end
						end
						
					end
				end

				if storeItem.category == "tractors" then
					table.insert( modifiedItem.configurations, { name = "default manual", title = "Default Transmission", source = 3, def = "defaultTractors", isDefault = isDefault } )
					table.insert( modifiedItem.configurations, { name = "default vario", title = "Default Transmission", source = 3, def = "default", isDefault = false } )
				else
					table.insert( modifiedItem.configurations, { name = "default", title = "Default Transmission", source = 3, def = defaultConfigName, isDefault = isDefault } )
				end
				
				gearboxMogliRegister.modifiedStoreItems[xmlFileLower] = modifiedItem

				if storeItem.configurations == nil then
					storeItem.configurations = {}
				end
				if storeItem.configurations.gearboxMogli == nil then
					storeItem.configurations.gearboxMogli = {}
				end
				
				for j,c in pairs( modifiedItem.configurations ) do
					local item = StoreItemsUtil.addConfigurationItem(storeItem.configurations.gearboxMogli, c.name, c.title, 0, 0, "")
					if c.isDefault then
						item.isDefault = true 
					end
				end
			end
		end		
	end
end

addModEventListener(gearboxMogliRegister)

gearboxMogliRegisterNewClient = {}
gearboxMogliRegisterNewClient_mt = Class(gearboxMogliRegisterNewClient, Event)
InitEventClass(gearboxMogliRegisterNewClient, "gearboxMogliRegisterNewClient")
function gearboxMogliRegisterNewClient:emptyNew()
  local self = Event:new(gearboxMogliRegisterNewClient_mt)
  return self
end
function gearboxMogliRegisterNewClient:new()
  local self = gearboxMogliRegisterNewClient:emptyNew()
  return self
end
function gearboxMogliRegisterNewClient:readStream(streamId, connection)
	if not connection:getIsServer() then
		connection:sendEvent(gearboxMogliRegisterSendConfigs:new(),true)
	end
end
function gearboxMogliRegisterNewClient:writeStream(streamId, connection)
end

gearboxMogliRegisterSendConfigs = {}
gearboxMogliRegisterSendConfigs_mt = Class(gearboxMogliRegisterSendConfigs, Event)
InitEventClass(gearboxMogliRegisterSendConfigs, "gearboxMogliRegisterSendConfigs")
function gearboxMogliRegisterSendConfigs:emptyNew()
  local self = Event:new(gearboxMogliRegisterSendConfigs_mt)
  return self
end
function gearboxMogliRegisterSendConfigs:new()
  local self = gearboxMogliRegisterSendConfigs:emptyNew()
  return self
end
function gearboxMogliRegisterSendConfigs:readStream(streamId, connection)
  numStoreItems = streamReadInt32(streamId)
  
	local evData = {}
	
	for i=1,numStoreItems do
		local evItem = {}
	
		evItem.xmlFilename = streamReadString(streamId)
		evItem.configItems = {}
		local m = streamReadInt32(streamId)
		for j=1,m do
			local n = streamReadString(streamId)
			local t = streamReadString(streamId)
			table.insert( evItem.configItems, {name=n, title=t})
		end
		
		table.insert( evData, evItem )
	end
		
	for i,evItem in pairs( evData ) do
		local storeItem = StoreItemsUtil.storeItemsByXMLFilename[evItem.xmlFilename]
			
		if storeItem ~= nil then
			if storeItem.configurations == nil then
				storeItem.configurations = {}
			end
			if storeItem.configurations.gearboxMogli == nil then
				storeItem.configurations.gearboxMogli = {}
			end
			
			for j,configItem in pairs( evItem.configItems ) do
				StoreItemsUtil.addConfigurationItem(storeItem.configurations.gearboxMogli, configItem.name, configItem.title, 0, 0, "")			
			end
		end
	end
end
function gearboxMogliRegisterSendConfigs:writeStream(streamId, connection)
	if type( gearboxMogliRegister.modifiedStoreItems ) ~= "table" then
		streamWriteInt32(streamId, 0)
	else
		streamWriteInt32(streamId, table.getn( gearboxMogliRegister.modifiedStoreItems ))
		
		for file,item in pairs( gearboxMogliRegister.modifiedStoreItems ) do
			streamWriteString(streamId, file )
			
			if type( item.configurations ) ~= "table" then
				streamWriteInt32(streamId, 0)
			else
				streamWriteInt32(streamId, table.getn( item.configurations ))
				
				for j,c in pairs( item.configurations ) do
					streamWriteString(streamId, Utils.getNoNil( c.name, "" ) )
					streamWriteString(streamId, Utils.getNoNil( c.title,"" ) )
				end
			end
		end
	end
end
