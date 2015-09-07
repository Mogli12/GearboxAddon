--***************************************************************
-- 
-- load from central config file
-- 
-- version 1.3 by mogli (biedens)
-- 2014/08/06
--
--***************************************************************

--***************************************************************
source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
source(Utils.getFilename("mrGearboxMogli.lua", g_currentModDirectory))
_G[g_currentModName..".mogliBase"].newClass( "mrGearboxMogliLoader" )
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
													"deleteMap" }) do
	if  mrGearboxMogli  ~= nil and mrGearboxMogli[funcName] ~= nil and type(mrGearboxMogli[funcName])  == "function" then
		mrGearboxMogliLoader[funcName] = function( self, ... )
			if type(self)=="table" and self.mrGbMLGearbox1 then
				local state, result = nil, nil
				if self.mrGbMLGearbox1 then
					state, result = pcall(mrGearboxMogli[funcName], self, ...)
					if state then
						return result
					else
						print("Error 3: "..tostring(result))
					end
				end
			end
				
			if funcName == "loadFromAttributesAndNodes" then
				return BaseMission.VEHICLE_LOAD_OK
			end
		end		
	end	
end

function mrGearboxMogliLoader:load(xmlFile) 
	
	self.mrGbMLGearbox1       = false
	
	--print("mrGearboxMogliLoader: "..tostring(self.isServer))
	
	if self.isServer then
		self.mrGbMLConfigFileName = Utils.removeModDirectory(self.configFileName);
		
		if self.mrGbMLConfigFileName == "" then
			print("Error -1: "..tostring(self.customEnvironment).." "..tostring(self.mrGbMLConfigFileName))
			return
		end
			
		local state, message = pcall( mrGearboxMogliLoader.loadGearboxMogli, self, xmlFile )
		if not state then
			print("Error 3 loading mrGearboxMogliLoader: "..tostring(message)) 
			self.mrGbMLGearbox1 = false
		end
	end
end 

function mrGearboxMogliLoader:readStream(streamId, connection)
	local old = self.mrGbMLGearbox1
	self.mrGbMLGearbox1 = streamReadBool(streamId) 
	if self.mrGbMLGearbox1 then
		if not ( old ) then
			mrGearboxMogli.initClient( self )
		end
		mrGearboxMogli.readStream( self, streamId, connection )
	end
end 

function mrGearboxMogliLoader:writeStream(streamId, connection)
	streamWriteBool(streamId, self.mrGbMLGearbox1) 
	if self.mrGbMLGearbox1 then
		mrGearboxMogli.writeStream( self, streamId, connection )
	end
end 

function mrGearboxMogliLoader.initXmlFiles()

	if mrGearboxMogliLoader.initXmlFilesDone then 
		return 
	end
	
	mrGearboxMogliLoader.initXmlFilesDone = true
		
	mrGearboxMogliLoader.configInt = {}
	mrGearboxMogliLoader.configExt = {}
	mrGearboxMogliLoader.defaultConfigI = {} 
	mrGearboxMogliLoader.defaultConfigE = {} 
	
	local file1 = mrGearboxMogliLoader.baseDirectory.."zzzMrGearboxAddonConfig.xml"
	print(file1)
	if fileExists(file1) then	
		local xmlFile = loadXMLFile( "vehicles", file1, "vehicles" )
		mrGearboxMogliLoader.xmlFileInt = xmlFile
		
		i=0
		while true do
			local baseName       = string.format("vehicles.vehicle(%d)", i)
			local j=0
			local configFileName = getXMLString(xmlFile, baseName .. "#configFileName")
			while true do
				local entry = { xmlName = baseName }

				if configFileName ~= nil then
					entry.configFileName = configFileName
				else
					local modName = getXMLString(xmlFile, string.format( "%s.configFile(%d)#modName", entry.xmlName, j ))
					local xmlName = getXMLString(xmlFile, string.format( "%s.configFile(%d)#xmlName", entry.xmlName, j ))
					if xmlName == nil then
						break
					elseif modName ~= nil then
						entry.configFileName = modName .. "/" .. xmlName
						entry.configModName  = string.lower( modName )
					else
						entry.configFileName = xmlName
					end
					
					entry.configXmlName  = string.lower( xmlName )
					entry.configIsPrefix = getXMLBool(xmlFile, string.format( "%s.configFile(%d)#isPrefix", entry.xmlName, j ))
				end
				
				if      ( string.len( entry.configFileName )     == 7 
							 or string.len( entry.configFileName )     == 9 )
						and string.sub( entry.configFileName, 1, 7 ) == "default" then
					mrGearboxMogliLoader.defaultConfigI[entry.configFileName] = entry
				elseif entry.configFileName ~= nil then
					--print(string.format( "zzzMrGearboxAddon: found configuration for %s", entry.configFileName ))				
					entry.configFileName = string.lower( entry.configFileName )
					mrGearboxMogliLoader.configInt[entry.configFileName] = entry
				end
				j = j + 1
				if configFileName ~= nil then
					break
				end
			end
			if j<=0 then
				break
			end
			i = i + 1
		end
	end

	local file2 = mrGearboxMogliLoader.modsDirectory.."zzzMrGearboxAddonConfig.xml"
	print(file2)
	if fileExists(file2) then	
		local xmlFile = loadXMLFile( "vehicles", file2, "vehicles" )
		mrGearboxMogliLoader.xmlFileExt = xmlFile
		
		i=0
		while true do
			local baseName       = string.format("vehicles.vehicle(%d)", i)
			local configFileName = getXMLString(xmlFile, baseName .. "#configFileName")
			local j              = 0
			while true do
				local entry = { xmlName = baseName }

				if configFileName ~= nil then
					entry.configFileName = configFileName
				else
					local modName = getXMLString(xmlFile, string.format( "%s.configFile(%d)#modName", entry.xmlName, j ))
					local xmlName = getXMLString(xmlFile, string.format( "%s.configFile(%d)#xmlName", entry.xmlName, j ))
					if xmlName == nil then
						break
					elseif modName ~= nil then
						entry.configFileName = modName .. "/" .. xmlName
						entry.configModName  = string.lower( modName )
					else
						entry.configFileName = xmlName
					end
					
					entry.configXmlName  = string.lower( xmlName )
					entry.configIsPrefix = getXMLBool(xmlFile, string.format( "%s.configFile(%d)#isPrefix", entry.xmlName, j ))
				end
				if      string.len( entry.configFileName )       == 9
						and string.sub( entry.configFileName, 1, 7 ) == "default" then
					mrGearboxMogliLoader.defaultConfigE[entry.configFileName] = entry
				elseif entry.configFileName ~= nil then
					print(string.format( "zzzMrGearboxAddon: found external configuration for %s", entry.configFileName ))				
					entry.configFileName = string.lower( entry.configFileName )
					mrGearboxMogliLoader.configExt[entry.configFileName] = entry
				end
				j = j + 1
				if configFileName ~= nil then
					break
				end
			end
			if j<=0 then
				break
			end
			i = i + 1
		end
	end
end

function mrGearboxMogliLoader.testXMLProperty( xmlFile, name )
	if name == nil then
		return true
	end
	local s = getXMLString( xmlFile, name )
	if s == nil or s == "" then
		return false
  end
	return true
end

function mrGearboxMogliLoader.testXmlFile( xmlFile, xmlName, propName1, propName2, propName3 )
	if propName3 == nil then
		if     ( propName1 ==nil
				 and propName2 ==nil )
				or ( propName1 ~=nil and propName2 ==nil 
				 and mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName1 ) )
				or ( propName1 ==nil and propName2 ~=nil 
				 and mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName2 ) )
				or ( propName1 ~=nil and propName2 ~=nil
				 and ( mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName1 ) 
						or mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName2 ) ) ) then
			return true
		end
	elseif mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName1 )
			or mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName2 )
			or mrGearboxMogliLoader.testXMLProperty( xmlFile, xmlName..propName3 ) then
		return true
	end
	return false
end

function mrGearboxMogliLoader.getConfigEntry( configTable, configFileName )
	if configTable[configFileName] ~= nil then
		return configTable[configFileName]
	end
	
	for n,e in pairs( configTable ) do
		if e.configIsPrefix and e.configModName ~= nil then
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
	
	return 
end

function mrGearboxMogliLoader:loadGeneric( vehicleXmlFile, func, tagName, propName1, propName2, propName3 )
	mrGearboxMogliLoader.initXmlFiles()
	
	local xmlFile
	local configFileName = string.lower( self.mrGbMLConfigFileName )
	local entry
	
	-- external configuration
	xmlFile = mrGearboxMogliLoader.xmlFileExt	
	entry   = mrGearboxMogliLoader.getConfigEntry( mrGearboxMogliLoader.configExt, configFileName )
	
	if      entry ~= nil
			and mrGearboxMogliLoader.testXmlFile( xmlFile, entry.xmlName, propName1, propName2, propName3 ) then
		local state, message = pcall( func, self, xmlFile, entry.xmlName, "external" )	
		if state and message then
			print(string.format( "zzzMrGearboxAddon: %s inserted into %s (e)", tagName, self.mrGbMLConfigFileName ))
			return true
		elseif not state then
			print("Error 4 loading mrGearboxMogliLoader: "..tostring(message)) 
		end
	end
	
	-- configuration innside the vehicle.xml
	xmlFile = vehicleXmlFile
	if mrGearboxMogliLoader.testXmlFile( xmlFile, "vehicle", propName1, propName2, propName3 ) then
		local state, message = pcall( func, self, xmlFile, "vehicle", "vehicle" )	
		if state and message then
			print(string.format( "zzzMrGearboxAddon: %s inserted into %s (v)", tagName, self.mrGbMLConfigFileName ))
			return true
		elseif not state then
			print("Error 6 loading mrGearboxMogliLoader: "..tostring(message)) 
		end
	end
	
	-- internal configuration
	xmlFile = mrGearboxMogliLoader.xmlFileInt
	entry   = mrGearboxMogliLoader.getConfigEntry( mrGearboxMogliLoader.configInt, configFileName )

	if      entry ~= nil
			and mrGearboxMogliLoader.testXmlFile( xmlFile, entry.xmlName, propName1, propName2, propName3 ) then
		local state, message = pcall( func, self, xmlFile, entry.xmlName, "internal" )	
		if state and message then
			print(string.format( "zzzMrGearboxAddon: %s inserted into %s (i)", tagName, self.mrGbMLConfigFileName ))
			return true
		elseif not state then
			print("Error 5 loading mrGearboxMogliLoader: "..tostring(message)) 
		end
	end
	
	-- default config 
	if SpecializationUtil.hasSpecialization(AITractor, self.specializations) then
	--local speed = 5 * math.floor( self.motor.maxForwardSpeed * 0.72 )
	--local defaultConfigName = string.format( "default%2d", speed )
		local defaultConfigName = "default"
		
		xmlFile = mrGearboxMogliLoader.xmlFileExt
		entry   = mrGearboxMogliLoader.defaultConfigE[defaultConfigName]		
		if      entry ~= nil
				and mrGearboxMogliLoader.testXmlFile( xmlFile, entry.xmlName, propName1, propName2, propName3 ) then
			local state, message = pcall( func, self, xmlFile, entry.xmlName, "internal" )	
			if state and message then
				print(string.format( "zzzMrGearboxAddon: %s inserted into %s (e)", defaultConfigName, self.mrGbMLConfigFileName ))
				return true
			elseif not state then
				print("Error 7 loading mrGearboxMogliLoader: "..tostring(message)) 
			end
		end

		xmlFile = mrGearboxMogliLoader.xmlFileInt
		entry   = mrGearboxMogliLoader.defaultConfigI[defaultConfigName]
		if      entry ~= nil
				and mrGearboxMogliLoader.testXmlFile( xmlFile, entry.xmlName, propName1, propName2, propName3 ) then
			local state, message = pcall( func, self, xmlFile, entry.xmlName, "internal" )	
			if state and message then
				print(string.format( "zzzMrGearboxAddon: %s inserted into %s (i)", defaultConfigName, self.mrGbMLConfigFileName ))
				return true
			elseif not state then
				print("Error 7 loading mrGearboxMogliLoader: "..tostring(message)) 
			end
		end
	end
	
	print(string.format( "zzzMrGearboxAddon: no configuration found for inserting %s into %s", tagName, self.mrGbMLConfigFileName ))
	return false
end


function mrGearboxMogliLoader:loadGearboxMogli( xmlFile )
	self.mrGbMLGearbox1 = mrGearboxMogliLoader.loadGeneric( self, xmlFile, mrGearboxMogliLoader.loadGearboxMogli2, "gearboxMogli", ".gearboxMogli.gears.gear(0)#speed", ".gearboxMogli.gears.gear(0)#inverseRatio" )
end

function mrGearboxMogliLoader:loadGearboxMogli2( xmlFile, baseName, xmlSource )	
	mrGearboxMogli.initFromXml( self, xmlFile, baseName .. ".gearboxMogli", xmlSource, false )
	return true
end

