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

function gearboxMogliLoader:load(savegame) 
	
	self.mrGbMLGearbox1       = false
	
	logWrite( 99,"gearboxMogliLoader: "..tostring(self.isServer))
	
	if self.isServer then
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

		if f == 1 then
			file1 = gearboxMogliLoader.baseDirectory.."gearboxAddonConfig.xml"
			logLevel = 4
		else
			file1 = gearboxMogliLoader.modsDirectory.."gearboxAddonConfig.xml"
			logLevel = 2
		end
		
		logWrite( logLevel, file1)
		if fileExists(file1) then	
			local xmlFile = loadXMLFile( "vehicles", file1, "vehicles" )
			
			if f == 1 then
				gearboxMogliLoader.xmlFileInt = xmlFile
			else
				gearboxMogliLoader.xmlFileExt = xmlFile
			end
			
			local i = 0
			while true do
				local baseName       = string.format("vehicles.vehicle(%d)", i)
				
				if not hasXMLProperty( xmlFile, baseName..".gearboxMogli" ) then
					logWrite( logLevel, string.format("FS17_GearboxAddon: Found %d configurations",i))								
					break
				end
				
				local configFileName = getXMLString(xmlFile, baseName .. "#configFileName")
				
				local j = 0
				local k = 0		
				local l = 0
				while true do
					local entry = { xmlName = baseName }
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
								local vList = Utils.splitString(" ", sList)
								for i = 1, table.getn(vList) do
									local j = tonumber( vList[i] )
									if j > 0 then
										if entry.motorConfig == nil then
											entry.motorConfig = {}
										end
										entry.motorConfig[j] = i
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

function gearboxMogliLoader:loadGeneric( savegame, func, tagName, propName1, propName2, propName3 )
	gearboxMogliLoader.initXmlFiles()
	
	local xmlFile
	local configFileName = string.lower( self.mrGbMLConfigFileName )
	local entry
	local motorConfig
	
	if      self.configurations       ~= nil
			and self.configurations.motor ~= nil then
		motorConfig = self.configurations.motor
	end
	
	-- external configuration
	xmlFile = gearboxMogliLoader.xmlFileExt	
	entry   = gearboxMogliLoader.getConfigEntry( gearboxMogliLoader.configExt, configFileName, motorConfig )
	
	if      entry ~= nil
			and gearboxMogliLoader.testXmlFile( xmlFile, entry.xmlName, propName1, propName2, propName3 ) then
		local state, message = pcall( func, self, xmlFile, entry.xmlName, "external", entry.motorConfig )	
		if state and message then
			logWrite( 1, string.format( gearboxMogliRegister.modName..": %s inserted into %s (e)", tagName, self.mrGbMLConfigFileName ))
			return true
		elseif not state then
			logWrite( 0, "Error 4 loading gearboxMogliLoader: "..tostring(message)) 
		end
	end 
	
	-- configuration inside the vehicle.xml
	xmlFile = self.xmlFile
	if gearboxMogliLoader.testXmlFile( xmlFile, "vehicle", propName1, propName2, propName3 ) then
		local state, message = pcall( func, self, xmlFile, "vehicle", "vehicle" )	
		if state and message then
			logWrite( 2, string.format( gearboxMogliRegister.modName..": %s inserted into %s (v)", tagName, self.mrGbMLConfigFileName ))
			return true
		elseif not state then
			logWrite( 0, "Error 6 loading gearboxMogliLoader: "..tostring(message)) 
		end
	end
	
	-- internal configuration
	xmlFile = gearboxMogliLoader.xmlFileInt
	entry   = gearboxMogliLoader.getConfigEntry( gearboxMogliLoader.configInt, configFileName, motorConfig )

	if      entry ~= nil
			and gearboxMogliLoader.testXmlFile( xmlFile, entry.xmlName, propName1, propName2, propName3 ) then
		local state, message = pcall( func, self, xmlFile, entry.xmlName, "internal", entry.motorConfig )	
		if state and message then
			logWrite( 4, string.format( gearboxMogliRegister.modName..": %s inserted into %s (i)", tagName, self.mrGbMLConfigFileName ))
			return true
		elseif not state then
			logWrite( 0, "Error 5 loading gearboxMogliLoader: "..tostring(message)) 
		end
	end
	
	-- default config 
	if SpecializationUtil.hasSpecialization(Steerable, self.specializations) then
	--local speed = 5 * math.floor( self.motor.maxForwardSpeed * 0.72 )
	--local defaultConfigName = string.format( "default%2d", speed )
	
		local defaultConfigName = "default"
		if SpecializationUtil.hasSpecialization(Combine, self.specializations) then
			defaultConfigName = "defaultCombine"
		else
			local storeItem = StoreItemsUtil.storeItemsByXMLFilename[self.configFileName:lower()];
			
			if storeItem == nil then
			elseif storeItem.category == "tractors"     then
				defaultConfigName = "defaultTractors"
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
			end
		end
		
		logWrite( 0,gearboxMogliRegister.modName..": looking for default configuration ("..defaultConfigName..")")
		
		xmlFile = gearboxMogliLoader.xmlFileExt
		entry   = gearboxMogliLoader.defaultConfigE[defaultConfigName]		
		if entry ~= nil then
			local state, message = pcall( func, self, xmlFile, entry.xmlName, "external", entry.motorConfig )	
			if state and message then
				logWrite( 3, string.format( gearboxMogliRegister.modName..": %s inserted into %s (e)", defaultConfigName, self.mrGbMLConfigFileName ))
				return true
			elseif not state then
				logWrite( 0, "Error 7 loading gearboxMogliLoader: "..tostring(message)) 
			end
		end

		xmlFile = gearboxMogliLoader.xmlFileInt
		entry   = gearboxMogliLoader.defaultConfigI[defaultConfigName]
		if entry ~= nil then
			local state, message = pcall( func, self, xmlFile, entry.xmlName, "internal", entry.motorConfig )	
			if state and message then
				logWrite( 3, string.format( gearboxMogliRegister.modName..": %s inserted into %s (i)", defaultConfigName, self.mrGbMLConfigFileName ))
				return true
			elseif not state then
				logWrite( 0, "Error 7 loading gearboxMogliLoader: "..tostring(message)) 
			end
		end
	end
	
	logWrite( 99, string.format( gearboxMogliRegister.modName..": no configuration found for inserting %s into %s", tagName, self.mrGbMLConfigFileName ))
	return false
end


function gearboxMogliLoader:loadgearboxMogli( savegame )
	self.mrGbMLGearbox1 = gearboxMogliLoader.loadGeneric( self, savegame, gearboxMogliLoader.loadgearboxMogli2, "gearboxMogli", ".gearboxMogli.gears.gear(0)#speed", ".gearboxMogli.gears.gear(0)#inverseRatio", ".gearboxMogli.hydrostatic.efficiency#ratio" )
end

function gearboxMogliLoader:loadgearboxMogli2( xmlFile, baseName, xmlSource, motorConfig )	
	gearboxMogli.initFromXml( self, xmlFile, baseName .. ".gearboxMogli", xmlSource, false, motorConfig )
	return true
end

