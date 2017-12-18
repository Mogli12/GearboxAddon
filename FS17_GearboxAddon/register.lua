local load_gearboxMogliScreen = true

gearboxMogliRegister = {}
gearboxMogliRegister.isLoaded = true
gearboxMogliRegister.modName  =  g_currentModName
gearboxMogliRegister.g_currentModDirectory = g_currentModDirectory
gearboxMogliRegister.requestConfigurations = false

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
		print("--- "..g_i18n:getText("gearboxMogliVERSION").." ---")
		
		gearboxMogliRegister.add(self)
    gearboxMogliRegister.isLoaded = true
		ConfigurationUtil.registerConfigurationType("GearboxAddon", "Transmission")
		
		if g_server ~= nil or g_modIsLoaded["gearboxAddonConfig"] then
			gearboxMogliRegister.addConfigurations(self)
		else
			gearboxMogliRegister.requestConfigurations = true
		end
		print("--- "..g_i18n:getText("gearboxMogliVERSION").." ---")
  end
		
	if gearboxMogliScreen ~= nil then
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
	if gearboxMogliRegister.requestConfigurations then
		gearboxMogliRegister.requestConfigurations = false
		print("gearboxMogli: client is requesting configuration items from server")
		g_client:getServerConnection():sendEvent(gearboxMogliRegisterNewClient:new())
	elseif gearboxMogliRegister.requestedStoreItemConnections ~= nil then
		local temp = gearboxMogliRegister.requestedStoreItemConnections
		gearboxMogliRegister.requestedStoreItemConnections = nil
		for connection,doit in pairs(temp) do
			connection:sendEvent(gearboxMogliRegisterSendConfigs:new(),true)
		end
	end
end

function gearboxMogliRegister:draw()
end

function gearboxMogliRegister:add()

	local searchTable  = { "gearboxMogli", "mrGearboxXerion", "mrGearbox2", "gearbox" }	
	local searchTable2 = { "tempomat", "tempomatMogli" }	
	local replObj1     = SpecializationUtil.getSpecialization("gearboxMogli")
	local replObj2     = SpecializationUtil.getSpecialization("tempomatMogli")
	
	local updatedMods  = 0
	local insertedMods = 0
	
	local noSpec2 = false
	if type( FS17_CCAddon ) == "table" and type( FS17_CCAddon.ccaddon_Register ) == "table" then
		noSpec2 = true
		print("  Disabling cruise control modifications")
	end
	
	for k, typeDef in pairs(VehicleTypeUtil.vehicleTypes) do
		local modName            = string.match(k, "([^.]+)")
		local addSpecialization1 = true
		local addSpecialization2 = true
		local correctLocation    = false
		local wasUpdated         = false
		
		if modName ~= nil and modName ~= "" and modName.gearboxMogli ~= nil then
			addSpecialization1 = false
			
		else
			for _, search in pairs(searchTable) do
				if SpecializationUtil.specializations[modName .. "." .. search] ~= nil then
					addSpecialization1 = false
					print(string.format("  %s already has a gearbox (2)", modName))
					
					local obj = SpecializationUtil.getSpecialization( modName .. "." .. search )
					
					if     obj == nil then
						print("  obj is nil")
					elseif obj.version ~= nil and obj.version >= replObj1.version then
						print("  obj.version >= replObj1.version")
					else
						for i,o in pairs(typeDef.specializations) do
							if o == obj then
								typeDef.specializations[i] = replObj1 
								print(string.format("  !!!updating gearbox in %s!!!", modName))					
								wasUpdated = true
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
					print(string.format("  %s already has cruise control", modName))

					local obj = SpecializationUtil.getSpecialization( modName .. "." .. search )
					
					if     obj == nil then
						print("  obj2 is nil")
					elseif obj.version ~= nil and obj.version >= replObj2.version then
						print("  obj2.version >= replObj2.version")
					else
						for i,o in pairs(typeDef.specializations) do
							if o == obj then
								typeDef.specializations[i] = replObj2
								print(string.format("  !!!updating cruise control in %s!!!", modName))
								wasUpdated = true
							end
						end
					end

					break
				end
			end
		end

		if wasUpdated then
			updatedMods = updatedMods + 1
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
	
	print(string.format("  %d vehicle types enhanced / %d vehicle types updated", insertedMods, updatedMods ))
	
	-- make l10n global 
	local prefix = g_i18n.texts.gearboxMogliInputPrefix
	local prelen = 0
	if prefix ~= nil and prefix ~= "" then
		prelen = string.len( prefix )
		g_i18n.globalI18N.texts.gearboxMogliInputPrefix = prefix
	end
	for m,t in pairs( g_i18n.texts ) do
		local n = nil
		if     string.sub( m, 1, 18 ) == "input_gearboxMogli" then
			n = string.sub( m, 7 )
			if prelen > 0 and string.sub( t, 1, prelen ) == prefix then
				t = string.sub( t, prelen+1, -1 )
			end
		elseif string.sub( m, 1, 12 ) == "gearboxMogli"       then
			n = m
		end
		if n ~= nil and g_i18n.globalI18N.texts[n] == nil then
			g_i18n.globalI18N.texts[n] = t
		end
	end
	
	
	local l10nFilenamePrefixFull = Utils.getFilename("modDesc_l10n", gearboxMogliRegister.g_currentModDirectory);
	local l10nXmlFile;
	local l10nFilename
	local langs = {g_languageShort, "en", "de"};
	for _, lang in ipairs(langs) do
		l10nFilename = l10nFilenamePrefixFull.."_"..lang..".xml";
		if fileExists(l10nFilename) then
			l10nXmlFile = loadXMLFile("TempConfig", l10nFilename);
			break;
		end
	end
	if l10nXmlFile ~= nil then
		local textI = 0;
		while true do
			local key = string.format("l10n.longTexts.longText(%d)", textI);
			if not hasXMLProperty(l10nXmlFile, key) then
				break;
			end;
			local name = getXMLString(l10nXmlFile, key.."#name");
			local text = getXMLString(l10nXmlFile, key);
			if name ~= nil and text ~= nil then
				g_i18n.globalI18N.texts[name] = text:gsub("\r\n", "\n")
			end;
			textI = textI+1;
		end;
		delete(l10nXmlFile);
	else
		print("Warning (longTexts): No l10n file found for '"..l10nFilenamePrefix.."' in mod '"..gearboxMogliRegister.modName.."'");
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
			
			local vehXmlName = nil

			local dummySelf = {}
			dummySelf.configFileName = storeItem.xmlFilename
			dummySelf.customEnvironment, dummySelf.baseDirectory = Utils.getModNameAndBaseDirectory(storeItem.xmlFilename)
			dummySelf.xmlFile = loadXMLFile("TempConfig", storeItem.xmlFilename)
			
			print(storeItem.xmlFilename)
			
			if type( Vehicle.mrLoadFinished1 ) == "function" then
				local state, result = pcall( Vehicle.mrLoadFinished1, dummySelf, -1, nil )
			--print("MR hack: "..tostring(state).." / "..tostring(dummySelf.mrIsMrVehicle).." / "..tostring(dummySelf.mrConfigFileName).." ("..tostring(result)..")")
				if state and dummySelf.mrIsMrVehicle then
					vehXmlName = dummySelf.mrConfigFileName
				end
			end
						
			local typeName = getXMLString(dummySelf.xmlFile, "vehicle#type");
			
			local hasVehicleConfig = gearboxMogliRegister.testXML( dummySelf.xmlFile, "vehicle", ".gearboxMogli" )
														or gearboxMogliRegister.testXML( dummySelf.xmlFile, "vehicle.motorConfigurations.motorConfiguration(0)", ".gearboxMogli" )					
		
			delete(dummySelf.xmlFile)
			
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
				modifiedItem.xmlFilename	= storeItem.xmlFilename				
				modifiedItem.configFileName = configFileName				
				modifiedItem.configurations = {}
			
				local entry, configTab
								
				local isDefault = true
				if hasVehicleConfig then
					table.insert( modifiedItem.configurations, { name = "Gearbox (vehicle)", title = "Gearbox (vehicle)", source = 0, isDefault = isDefault } )
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
							local name = ""
							if i == 1 then
								name = "Gearbox (external)"
							else
								name = "Gearbox (addon)"
							end
							table.insert( modifiedItem.configurations, { name = name, title = name, source = i, baseName = entry.xmlName, isDefault = isDefault } )
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
								
								table.insert( modifiedItem.configurations, { name = "Gearbox ("..s..")", title = s, source = i, baseName = entry.xmlName, config = j, isDefault = isDefault } )
								isDefault = false
							end
						end
						
					end
				end

				if storeItem.category == "tractors" then
					table.insert( modifiedItem.configurations, { name = "default manual", title = "Default Transmission", source = 3, def = "defaultTractors", isDefault = isDefault } )
					table.insert( modifiedItem.configurations, { name = "default vario", title = "Default Transmission", source = 3, def = "default", isDefault = false } )
				else
					local defaultConfigName
					
					if     storeItem.category == "harvesters"   then
						defaultConfigName = "defaultCombine"
					elseif storeItem.category == "forageHarvesters" then
						defaultConfigName = "defaultCombine"
					elseif storeItem.category == "trucks"       then
						defaultConfigName = "defaultTrucks"
					elseif storeItem.category == "cars"         then
						defaultConfigName = "defaultCars"
					elseif storeItem.category == "wheelLoaders" then
						defaultConfigName = "defaultTorqueConverter"
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
				
					table.insert( modifiedItem.configurations, { name = "default", title = "Default Transmission", source = 3, def = defaultConfigName, isDefault = isDefault } )
				end
				
				table.insert( modifiedItem.configurations, { name = "off", title = "Standard Transmission", source = -1 } )
				
				if storeItem.configurations == nil then
					storeItem.configurations = {}
				end
				if storeItem.configurations.GearboxAddon == nil then
					storeItem.configurations.GearboxAddon = {}
				end
				
				for j,c in pairs( modifiedItem.configurations ) do
					local item = StoreItemsUtil.addConfigurationItem(storeItem.configurations.GearboxAddon, c.name, c.title, 0, 0, "")
					if c.isDefault then
						item.isDefault = true 
					end
				end
				
			--print(tostring(configFileName)..': '..tostring(table.getn( modifiedItem.configurations ))..' "'..tostring(modifiedItem.configFileName)..'"')
				
				gearboxMogliRegister.modifiedStoreItems[ xmlFileLower ] = modifiedItem
				
			--print(string.format("%3d: %2d, %s", table.getn( gearboxMogliRegister.modifiedStoreItems ), table.getn( modifiedItem.configurations ), xmlFileLower ))
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
	local test = streamReadInt32( streamId )
	if test == 28081988 then
		self:run(connection)
	else
		print("gearboxMogli: Error registering new client")
	end
end
function gearboxMogliRegisterNewClient:writeStream(streamId, connection)
	streamWriteInt32(streamId, 28081988 )
end
function gearboxMogliRegisterNewClient:run(connection)
	print("gearboxMogli: received configuration request")
 	if gearboxMogliRegister.requestedStoreItemConnections == nil then
		gearboxMogliRegister.requestedStoreItemConnections = {}
	end
	gearboxMogliRegister.requestedStoreItemConnections[connection] = true
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
  local numStoreItems = streamReadInt32(streamId)
	print(string.format("gearboxMogli: received configurations for %d vehicles", numStoreItems))
  
	local evData = {}
	
	for i=1,numStoreItems do
		local numConfigItems = streamReadInt32(streamId)
				
		if numConfigItems ~= nil and numConfigItems > 0 then
			local configFileName = streamReadString(streamId)
		
			if configFileName ~= nil then
				evData[configFileName] = {}
				for j=1,numConfigItems do
					local n = streamReadString(streamId)
					local t = streamReadString(streamId)
					table.insert( evData[configFileName], {name=n, title=t})
				end
			end
		end
	end
	
	for xmlFileLower,storeItem in pairs( StoreItemsUtil.storeItemsByXMLFilename ) do
		local configFileName = nil
		if storeItem.xmlFilename ~= nil then
			configFileName = string.lower( Utils.removeModDirectory( storeItem.xmlFilename ) )
		end
		
		if configFileName ~= nil and evData[configFileName] ~= nil then
			if storeItem.configurations == nil then
				storeItem.configurations = {}
			end
			storeItem.configurations.GearboxAddon = {}
			for j,configItem in pairs( evData[configFileName] ) do
				StoreItemsUtil.addConfigurationItem(storeItem.configurations.GearboxAddon, configItem.name, configItem.title, 0, 0, "")			
			end
		end
	end
end
function gearboxMogliRegisterSendConfigs:writeStream(streamId, connection)
	
	if type( gearboxMogliRegister.modifiedStoreItems ) ~= "table" then
		print("gearboxMogli: Sending nil configuration items to the client")
		streamWriteInt32(streamId, 0)
	else
		local numStoreItems, sumConfigItems = 0, 0
		for xmlFileLower,item in pairs( gearboxMogliRegister.modifiedStoreItems ) do
			numStoreItems = numStoreItems + 1
		end
		
		streamWriteInt32(streamId, numStoreItems)
		
		for xmlFileLower,item in pairs( gearboxMogliRegister.modifiedStoreItems ) do
			local numConfigItems = 0
			if type( item.configFileName ) == "string" and type( item.configurations ) == "table" then
				for j,c in pairs( item.configurations ) do
					numConfigItems = numConfigItems + 1
					sumConfigItems = sumConfigItems + 1
				end
			end
			
			streamWriteInt32(streamId,  numConfigItems)
			if numConfigItems > 0 then
				streamWriteString(streamId, item.configFileName )
				
				for j,c in pairs( item.configurations ) do
					streamWriteString(streamId, Utils.getNoNil( c.name, "!!!empty!!!" ) )
					streamWriteString(streamId, Utils.getNoNil( c.title,"!!!empty!!!" ) )
				end
			end
		end
		
		print(string.format("gearboxMogli: Sending %d (%d) configuration items to the client",numStoreItems,sumConfigItems))
	end
end
function gearboxMogliRegisterSendConfigs:run(connection)
	if type( gearboxMogliRegister.modifiedStoreItems ) ~= "table" then
		print("gearboxMogli: Sending nil configuration items to the client (local)")
	else
		local numStoreItems, sumConfigItems = 0, 0
		for xmlFileLower,item in pairs( gearboxMogliRegister.modifiedStoreItems ) do
			numStoreItems = numStoreItems + 1
		end
		
		for xmlFileLower,item in pairs( gearboxMogliRegister.modifiedStoreItems ) do
			local numConfigItems = 0
			if type( item.configFileName ) == "string" and type( item.configurations ) == "table" then
				for j,c in pairs( item.configurations ) do
					numConfigItems = numConfigItems + 1
					sumConfigItems = sumConfigItems + 1
				end
			end
		end
		
		print(string.format("gearboxMogli: Sending %d (%d) configuration items to the client (local)",numStoreItems,sumConfigItems))
	end
end
