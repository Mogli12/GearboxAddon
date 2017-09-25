--***************************************************************
-- 
-- load from central config file
-- 
-- version 1.3 by mogli (biedens)
-- 2014/08/06
--
--***************************************************************

local showLogLevel = 1 -- 1 for source external, 2 for source vehicle, 3 for default configs and 4 for all vehicles, 99 for all messages
local function logWrite( level, ... )
	if ( level == nil and showLogLevel >= 99 ) or level <= showLogLevel then
		print(...)
	end
end

--***************************************************************
source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
source(Utils.getFilename("gearboxMogli.lua", g_currentModDirectory))
source(Utils.getFilename("gearboxMogliMotor.lua", g_currentModDirectory))

_G[g_currentModName..".mogliBase"].newClass( "gearboxMogliLoader" )
--***************************************************************

for _,funcName in pairs({ "delete", 
													"mouseEvent", 
													"keyEvent",
													"readStream", 
													"writeStream", 
													"update", 
													"updateTick", 
													"readUpdateStream", 
													"writeUpdateStream", 
													"draw", 
													"getSaveAttributesAndNodes", 
													"loadFromAttributesAndNodes",
													"onLeave",
													"onEnter",
													"addCutterArea",
													"deleteMap",
													"setIsReverseDriving" }) do
	if  gearboxMogli  ~= nil and gearboxMogli[funcName] ~= nil and type(gearboxMogli[funcName])  == "function" then
		gearboxMogliLoader[funcName] = function( self, ... )
			if type(self)=="table" and self.mrGbMLGearbox1 then
				local state, result = nil, nil
				if self.mrGbMLGearbox1 then
					state, result = pcall(gearboxMogli[funcName], self, ...)
					if state then
						return result
					else
						logWrite( 0,"Error 3: "..tostring(result))
					end
				end
			end
				
			if funcName == "loadFromAttributesAndNodes" then
				return BaseMission.VEHICLE_LOAD_OK
			end
		end		
	end	
end

local showMRWarning = false --true

function gearboxMogliLoader:preLoad(savegame) 
	if      savegame ~= nil
			and type( gearboxMogliRegister.modifiedStoreItems ) == "table"
			and type( gearboxMogliRegister.modifiedStoreItems[self.configFileName:lower()] ) == "table" then
		local setDefault = true
		local i = 0;
		while true do
			local key = string.format(savegame.key..".boughtConfiguration(%d)", i);
			if not hasXMLProperty(savegame.xmlFile, key) then
				break;
			end;
			local name = getXMLString(savegame.xmlFile, key.."#name");
			if     name == "gearboxMogli" then
				setDefault = false
				local id = getXMLInt(savegame.xmlFile, key.."#id");
				if id == 1 then
					id = table.getn( gearboxMogliRegister.modifiedStoreItems[self.configFileName:lower()] )
					logWrite( 0, string.format("  self.configurations.gearboxMogli (%d) => self.configurations.GearboxAddon (%d)", 1, id ))
				else
					id = id - 1
					logWrite( 0, string.format("  self.configurations.gearboxMogli (%d) => self.configurations.GearboxAddon (%d)", id+1, id ))
				end
				self.mrGbMLGearboxAddonConfiguration = id
				self:addBoughtConfiguration("GearboxAddon", id)
			elseif name == "GearboxAddon" then
				self.mrGbMLGearboxAddonConfiguration = getXMLInt(savegame.xmlFile, key.."#id")
				setDefault = false
			end
			i = i + 1;
		end;
		if setDefault then
			self.mrGbMLGearboxAddonConfiguration = 1
			self:addBoughtConfiguration("GearboxAddon", 1)
		end
	end
end

function gearboxMogliLoader:load(savegame) 
	
	self.mrGbMLGearbox1       = false
	
	logWrite( 99,"gearboxMogliLoader: "..tostring(self.isServer))
	
	if self.isServer then
		if self.mrIsMrVehicle and showMRWarning then
			showMRWarning = false
			logWrite( 0,' ')
			logWrite( 0,'*******************************************************************************************')
			logWrite( 0,'* Warning: The combination of gearboxAddon and moreRealistic is no longer supported       *')
			logWrite( 0,'* Here are some quotes from dural about gearboxAddon:                                     *')
			logWrite( 0,'*  "So, is it "realistic" ? of course not. Say thanks to the "engine load" returned value *')
			logWrite( 0,'*   which does not reflect the actual avg engine load."                                   *')
			logWrite( 0,'*  "my expectations are too high. I gave it another try. => losing speed, but engine      *')
			logWrite( 0,'*   rpm keeps the same = not a "real" fixed ratio gear box. "funny" fuel consumption      *')
			logWrite( 0,'*   (more fuel consumption at 60% on flat ground than 100% load going up a hill). I can   *')
			logWrite( 0,'*   stop with the highest gear engaged, and then get back to full speed from 0 without    *')
			logWrite( 0,'*   having to gear down (1455XL + joskin 3 axles trailer empty)                           *')
			logWrite( 0,'*   very high max fuel consumption (40L per hour for the 1455XL = boosted engine ?)       *')
			logWrite( 0,'*   We can´t rely on the default "motor" of the game. "everything" is false with it."     *')
			logWrite( 0,'*  "I know you are using your own curves, but I was supposing you are relying on the      *')
			logWrite( 0,'*   "setVehicleProps" and "getMotorRotationSpeed" functions. (I didn´t read your code)    *')
			logWrite( 0,'*   which would explain the wrong engine load  for example. In such case, you are using   *')
			logWrite( 0,'*   the base game "motor". ("the built-in moment of inertia" is part of the base game     *')
			logWrite( 0,'*   motor implementation, and has nothing to do with IRL, does not take into account      *')
			logWrite( 0,'*   actual load or anything real)"                                                        *')
			logWrite( 0,'*                                                                                         *')
			logWrite( 0,'* Based on this feedback I decided to remove moreRealistic from my mods folder. I assume  *')
			logWrite( 0,'* that the combination of gearboxAddon and moreRealistic might lead to errros in log.txt, *')
			logWrite( 0,'* corrupt saveGames and unrealistic vehicle simulation                                    *')
		--logWrite( 0,'* PLEASE DO NOT COMBINE THESE MODS!!!                                                     *')
			logWrite( 0,'*******************************************************************************************')
			logWrite( 0,' ')
		--return
		end
		
		self.mrGbMLConfigFileName = Utils.removeModDirectory(self.configFileName);
		
		if self.mrGbMLConfigFileName == "" then
			logWrite( 0,"Error -1: "..tostring(self.customEnvironment).." "..tostring(self.mrGbMLConfigFileName))
			return
		end
		
		local state, message = pcall( gearboxMogliLoader.loadgearboxMogli, self, self.xmlFile )
		if not state then
			logWrite( 0,"Error 3 loading gearboxMogliLoader: "..tostring(message)) 
			self.mrGbMLGearbox1 = false
		end
	elseif self.mrGbMLGearboxAddonConfiguration ~= nil then
		self:addBoughtConfiguration("GearboxAddon", self.mrGbMLGearboxAddonConfiguration)
	end
end 

function gearboxMogliLoader:readStream(streamId, connection)
	local old = self.mrGbMLGearbox1
	self.mrGbMLGearbox1 = streamReadBool(streamId) 
	if self.mrGbMLGearbox1 then
		if not ( old ) then
			gearboxMogli.initClient( self )
		end
		gearboxMogli.readStream( self, streamId, connection )
	end
end 

function gearboxMogliLoader:writeStream(streamId, connection)
	streamWriteBool(streamId, self.mrGbMLGearbox1) 
	if self.mrGbMLGearbox1 then
		gearboxMogli.writeStream( self, streamId, connection )
	end
end 

function gearboxMogliLoader.initXmlFiles()

	if gearboxMogliLoader.initXmlFilesDone then 
		return 
	end
	
	gearboxMogliLoader.initXmlFilesDone = true
		
	gearboxMogliLoader.configInt = {}
	gearboxMogliLoader.configExt = {}
	gearboxMogliLoader.defaultConfigI = {} 
	gearboxMogliLoader.defaultConfigE = {} 
	
	for f=1,2 do 	
		local file1
		local logLevel
		local successMsg = ""

		if     f == 1 then
			file1 = gearboxMogliLoader.baseDirectory.."gearboxAddonConfig.xml"
			logLevel = 4
			successMsg = "FS17_GearboxAddon/gearboxAddonConfig.xml"
		elseif g_modIsLoaded["gearboxAddonConfig"] then		
			file1 = gearboxMogliLoader.modsDirectory.."/gearboxAddonConfig/gearboxAddonConfig.xml"
			logLevel = 1
			successMsg = "Found external config in separate mod gearboxAddonConfig.zip"
		else
			file1 = gearboxMogliLoader.modsDirectory.."gearboxAddonConfig.xml"
			logLevel = 2
			successMsg = "Found external config in gearboxAddonConfig.xml"
		end
		
		logWrite( logLevel, file1)
		if fileExists(file1) then	
			local xmlFile = loadXMLFile( "vehicles", file1, "vehicles" )
			
			if f == 1 then
				gearboxMogliLoader.xmlFileInt = xmlFile
			else
				gearboxMogliLoader.xmlFileExt = xmlFile				
				logWrite( 1,successMsg)
			end
			
			local i = 0
			while true do
				local baseName       = string.format("vehicles.vehicle(%d)", i)
				
				local hasGearboxMogliTag  = hasXMLProperty( xmlFile, baseName..".gearboxMogli" )
				local hasTransmissionsTag = hasXMLProperty( xmlFile, baseName..".transmissions" )
				
				if not ( hasGearboxMogliTag or hasTransmissionsTag ) then
					logWrite( logLevel, string.format("FS17_GearboxAddon: Found %d configurations",i))								
					break
				end
				
				local configFileName = getXMLString(xmlFile, baseName .. "#configFileName")
				
				local j = 0
				local k = 0		
				local l = 0
				while true do
					local entry = { xmlName = baseName, hasGearboxMogliTag = hasGearboxMogliTag, hasTransmissionsTag = hasTransmissionsTag }
					local eTag  = nil
					
					if configFileName ~= nil then
						entry.configFileName = configFileName
					else
						local modName
						local xmlName = getXMLString(xmlFile, string.format( "%s.configFile(%d)#xmlName", entry.xmlName, j ))						
						
						if xmlName ~= nil then						
							eTag                 = string.format( "%s.configFile(%d)#engines", entry.xmlName, j )	
							modName              = getXMLString(xmlFile, string.format( "%s.configFile(%d)#modName", entry.xmlName, j ))
							entry.configIsPrefix = getXMLBool(xmlFile, string.format( "%s.configFile(%d)#isPrefix", entry.xmlName, j ))
							j = j + 1
						else						
							xmlName = getXMLString(xmlFile, string.format( "%s.mod(%d).xmlFile(%d)#name", entry.xmlName, l, k ))
							if xmlName == nil then
								if k == 0 then
									break
								end
								l = l + 1
								xmlName = getXMLString(xmlFile, string.format( "%s.mod(%d).xmlFile(0)#name", entry.xmlName, l ))
								if xmlName == nil then
									break
								end
								k = 1
							else
								k = k + 1
							end
							
							eTag                 = string.format( "%s.mod(%d).xmlFile(%d)#engines", entry.xmlName, l, k-1 )
							modName              = getXMLString(xmlFile, string.format( "%s.mod(%d)#name", entry.xmlName, l ))
							entry.configIsPrefix = getXMLBool(xmlFile, string.format( "%s.mod(%d)#isPrefix", entry.xmlName, l ))								
						end

						if modName ~= nil then
							entry.configFileName = modName .. "/" .. xmlName
							entry.configModName  = string.lower( modName )
						else
							entry.configFileName = xmlName
						end
						
						entry.configXmlName  = string.lower( xmlName )
						
						if eTag ~= nil then
							local sList = getXMLString(xmlFile, eTag)
							if sList ~= nil then
								if hasTransmissionsTag then
									logWrite( 0, 'Error: <transmissions> tag cannot be combined with <xmlFile engine="..."/>' )
								end
								local vList = Utils.splitString(" ", sList)
								for l = 1, table.getn(vList) do
									local j = tonumber( vList[l] )
									if j > 0 then
										if entry.motorConfig == nil then
											entry.motorConfig = {}
										end
										entry.motorConfig[j] = l
									end
								end
							end
						end
					end
					
					nothingFound = false
					
					if      string.len( entry.configFileName ) >= 7 
							and string.sub( entry.configFileName, 1, 7 ) == "default" then
							
						if f == 1 then
							logWrite( logLevel, string.format( gearboxMogliRegister.modName..": found internal default configuration (%s)", entry.configFileName ))				
							gearboxMogliLoader.defaultConfigI[entry.configFileName] = entry
						else
							logWrite( logLevel, string.format( gearboxMogliRegister.modName..": found external default configuration (%s)", entry.configFileName ))				
							gearboxMogliLoader.defaultConfigE[entry.configFileName] = entry
						end
					elseif entry.configFileName ~= nil then
						entry.configFileName = string.lower( entry.configFileName )
						if f == 1 then
							logWrite( logLevel, string.format( gearboxMogliRegister.modName..": found internal configuration for %s", entry.configFileName ))				
							table.insert( gearboxMogliLoader.configInt, entry )
						else
							logWrite( logLevel, string.format( gearboxMogliRegister.modName..": found external configuration for %s", entry.configFileName ))				
							table.insert( gearboxMogliLoader.configExt, entry )
						end
					end
					if configFileName ~= nil then
						break
					end
				end
								
				i = i + 1
			end
		end
	end	
end

function gearboxMogliLoader.testXMLProperty( xmlFile, name )
	if name == nil then
		return true
	end
--local s = getXMLString( xmlFile, name )
--if s == nil or s == "" then
--	return false
--end
--return true
	return hasXMLProperty( xmlFile, name )
end

function gearboxMogliLoader.testXmlFile( xmlFile, xmlName, propName1, propName2, propName3 )
	if propName3 == nil then
		if     ( propName1 ==nil
				 and propName2 ==nil )
				or ( propName1 ~=nil and propName2 ==nil 
				 and gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName1 ) )
				or ( propName1 ==nil and propName2 ~=nil 
				 and gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName2 ) )
				or ( propName1 ~=nil and propName2 ~=nil
				 and ( gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName1 ) 
						or gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName2 ) ) ) then
			return true
		end
	elseif gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName1 )
			or gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName2 )
			or gearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName3 ) then
		return true
	end
	return false
end

function gearboxMogliLoader.getConfigEntry( configTable, configFileName, motorConfig )
	if configTable[configFileName] ~= nil then
		return configTable[configFileName]
	end
	
	for i,e in pairs( configTable ) do
		if     motorConfig   == nil
				or e.motorConfig == nil
				or ( e.motorConfig[motorConfig] and e.motorConfig[motorConfig] > 0 ) then
			if     e.configFileName == configFileName then
				return e
			elseif e.configIsPrefix and e.configModName ~= nil then
				local l1 = string.len( e.configModName )
				local l2 = string.len( e.configXmlName )
				local l3 = string.len( configFileName  )
				
				if      l1 < l3 
						and l2 < l3 
						and string.sub( configFileName, 1, l1 ) == e.configModName 
						and string.sub( configFileName, 1 + l3 - l2 ) == e.configXmlName					
						then
					return e
				end
			end
		end
	end
	
	return 
end

function gearboxMogliLoader:loadgearboxMogli( savegame )

	self.mrGbMLGearbox1 = false
	
	if self.configurations == nil then
		logWrite( 5, "No configurations" )
		return 
	end
	
	if self.configurations.GearboxAddon == nil then		
		logWrite( 5, "No gearbox" )
		return 
	end
	
	self.mrGbMLStoreItem = gearboxMogliRegister.modifiedStoreItems[self.configFileName:lower()]
	
	if     self.mrGbMLStoreItem == nil
			or self.mrGbMLStoreItem.configurations == nil
			or self.mrGbMLStoreItem.configurations[self.configurations.GearboxAddon] == nil then
		logWrite( 5, "No gearbox configuration" )
		return 
	end
	
	local configuration = self.mrGbMLStoreItem.configurations[self.configurations.GearboxAddon]

	if     configuration.source < 0 then
		logWrite( 5, "Gearbox is off" )
	elseif configuration.source == 0 then
		local key
		local xmlFile = self.xmlFile 
		if self.configurations ~= nil and self.configurations.motor ~= nil then
			key = string.format("vehicle.motorConfigurations.motorConfiguration(%d).gearboxMogli", self.configurations.motor-1)
			if gearboxMogliLoader.testXmlFile( self.xmlFile, key, ".gears.gear(0)#speed", ".gears.gear(0)#inverseRatio", ".hydrostatic.efficiency#ratio" ) then
				gearboxMogli.initFromXml( self, self.xmlFile, key, nil, "vehicle", false )
				self.mrGbMLGearbox1 = true
				return 
			end
		end
		
		key = "vehicle.motorConfigurations.motorConfiguration(0).gearboxMogli"
		if gearboxMogliLoader.testXmlFile( self.xmlFile, key, ".gears.gear(0)#speed", ".gears.gear(0)#inverseRatio", ".hydrostatic.efficiency#ratio" ) then
			gearboxMogli.initFromXml( self, self.xmlFile, key, nil, "vehicle", false )
			self.mrGbMLGearbox1 = true
			return 
		end
		
		key = "vehicle.gearboxMogli"
		if gearboxMogliLoader.testXmlFile( self.xmlFile, key, ".gears.gear(0)#speed", ".gears.gear(0)#inverseRatio", ".hydrostatic.efficiency#ratio" ) then
			gearboxMogli.initFromXml( self, self.xmlFile, key, nil, "vehicle", false )
			self.mrGbMLGearbox1 = true
			return 
		end
		
		logWrite( 0, "Invalid vehicle XML" )
		
	elseif configuration.def ~= nil then
		logWrite( 5, "Default gearbox" )
		local xmlFile = gearboxMogliLoader.xmlFileExt
		local entry   = gearboxMogliLoader.defaultConfigE[configuration.def]
		local source  = "external"
		if entry == nil then
			xmlFile = gearboxMogliLoader.xmlFileInt
		  entry   = gearboxMogliLoader.defaultConfigI[configuration.def]
			source  = "internal"
		end
		if entry ~= nil then
			gearboxMogli.initFromXml( self, xmlFile, entry.xmlName..".gearboxMogli", nil, source, false )
			self.mrGbMLGearbox1 = true
		else
			logWrite( 0, "Wrong default" )
		end
	elseif configuration.baseName ~= nil then
		local xmlFile = gearboxMogliLoader.xmlFileExt
		local source  = "external"
		if configuration.source > 1 then
			xmlFile = gearboxMogliLoader.xmlFileInt
			source  = "internal"
		end
		
		local transName, motorName, motorConfig
		
		if configuration.config == nil then
			local entry
			if configuration.source > 1 then
				entry = gearboxMogliLoader.getConfigEntry( gearboxMogliLoader.configInt, string.lower( self.mrGbMLConfigFileName ), self.configurations.motor )
			else
				entry = gearboxMogliLoader.getConfigEntry( gearboxMogliLoader.configExt, string.lower( self.mrGbMLConfigFileName ), self.configurations.motor )
				motorConfig = entry.motorConfig
			end
			
			if entry == nil then
				logWrite( 0, "Invalid configuration I" )
				return 
			end
			
			transName   = entry.xmlName ..".gearboxMogli"
			motorName   = transName 
			motorConfig = entry.motorConfig
		else
			transName   = configuration.baseName ..string.format(".transmissions.transmission(%d)", configuration.config - 1 )
			motorName   = configuration.baseName
		end
		
		logWrite( 5, string.format("Config file %s, transmission tag %s, motor tag %s", source, transName, motorName ) )

		gearboxMogli.initFromXml( self, xmlFile, transName, motorName, source, false, motorConfig )
		self.mrGbMLGearbox1 = true
	else
		logWrite( 0, "Invalid configuration II" )
	end
end

