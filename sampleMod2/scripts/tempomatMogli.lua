--***************************************************************
--
-- tempomatMogli
-- 
-- version 1.92 by mogli (biedens)
-- 2015/03/16
--
--***************************************************************

local tempomatMogliVersion=1.192

-- allow modders to include this source file together with mogliBase.lua in their mods
if tempomatMogli == nil or tempomatMogli.version == nil or tempomatMogli.version < tempomatMogliVersion then
	if mogliBase20 == nil then
		source(Utils.getFilename("mogliBase20.lua", g_currentModDirectory))
	end
	
	--***************************************************************
	mogliBase20.newClass( "tempomatMogli", "tempomatMogli" )
	--***************************************************************
	
	tempomatMogli.version = tempomatMogliVersion
	
	--**********************************************************************************************************	
	-- tempomatMogli:load
	--**********************************************************************************************************	
	function tempomatMogli:load(xmlFile) 
		-- state
		self.tempomatMogli = {}
		tempomatMogli.registerState( self, "SpeedLimit2",   10 )
	
		self.tempomatMogliSetSpeedLimit  = tempomatMogli.tempomatMogliSetSpeedLimit 
		self.tempomatMogliGetSpeedLimit  = tempomatMogli.tempomatMogliGetSpeedLimit 
		self.tempomatMogliGetSpeedLimit2 = tempomatMogli.tempomatMogliGetSpeedLimit2
		self.tempomatMogliSwapSpeedLimit = tempomatMogli.tempomatMogliSwapSpeedLimit 
	end	
		
	--**********************************************************************************************************	
	-- tempomatMogli:update
	--**********************************************************************************************************	
	function tempomatMogli:update(dt)
		
	-- inputs	
		if self:getIsActiveForInput(false) then		
			if     tempomatMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_1" )
					or tempomatMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_2" )
					or tempomatMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_3" )
					or tempomatMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_4" ) then
				-- ignore
			elseif tempomatMogli.mbHasInputEvent( "mrGearboxMogliSETSPEED" ) then -- speed limiter
				self:tempomatMogliSetSpeedLimit()
			elseif tempomatMogli.mbHasInputEvent( "mrGearboxMogliSWAPSPEED" ) then -- speed limiter
				self:tempomatMogliSwapSpeedLimit()
			end
		end
	end
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSetSpeedLimit
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliSetSpeedLimit( noEventSend )
		self:setCruiseControlMaxSpeed(self.lastSpeedReal*3600)
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSetSpeedLimit
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliGetSpeedLimit( )
		return self.cruiseControl.speed
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSetSpeedLimit2
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliGetSpeedLimit2( )
		return self.tempomatMogli.SpeedLimit2
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSwapSpeedLimit
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliSwapSpeedLimit( noEventSend )
		local speed1 = self.tempomatMogli.SpeedLimit2
		local speed2 = self.cruiseControl.speed
		self:setCruiseControlMaxSpeed(speed1)
		tempomatMogli.mbSetState( self, "SpeedLimit2", speed2, noEventSend ) 		
	end 
	
	--**********************************************************************************************************	
	-- mrGearboxMogli:getSaveAttributesAndNodes
	--**********************************************************************************************************	
	function mrGearboxMogli:getSaveAttributesAndNodes(nodeIdent)
	
		local attributes = ""
	
		if self.tempomatMogli ~= nil then
			if self.tempomatMogli.SpeedLimit2 <= 9 or self.tempomatMogli.SpeedLimit2 >= 11 then
				attributes = attributes.." mrGbMSpeed2=\"" .. tostring( self.tempomatMogli.SpeedLimit2 ) .. "\""     
			end
		end 
		
		return attributes
	end 
	
	--**********************************************************************************************************	
	-- mrGearboxMogli:loadFromAttributesAndNodes
	--**********************************************************************************************************	
	function mrGearboxMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
		local i
		
		if self.tempomatMogli ~= nil then
			i = getXMLInt(xmlFile, key .. "#mrGbMSpeed2" )
			if i ~= nil then
				self.tempomatMogli.SpeedLimit2 = i
			end
		end
		
		return BaseMission.VEHICLE_LOAD_OK
	end 

end