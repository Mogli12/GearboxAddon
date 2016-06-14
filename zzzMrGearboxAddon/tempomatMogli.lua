--***************************************************************
--
-- tempomatMogli
-- 
-- version 1.92 by mogli (biedens)
-- 2015/03/16
--
--***************************************************************

local tempomatMogliVersion=1.400

-- allow modders to include this source file together with mogliBase.lua in their mods
if tempomatMogli == nil or tempomatMogli.version == nil or tempomatMogli.version < tempomatMogliVersion then
--***************************************************************
	--mogliBase20.newClass( "tempomatMogli", "tempomatMogli" )
	if _G[g_currentModName..".mogliBase"] == nil then
		source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
	end
	_G[g_currentModName..".mogliBase"].newClass( "tempomatMogli", "tempomatMogliV14" )
--***************************************************************
	
	tempomatMogli.version = tempomatMogliVersion
	local l_currentModName = g_currentModName
	
	--**********************************************************************************************************	
	-- tempomatMogli:load
	--**********************************************************************************************************	
	function tempomatMogli:load(xmlFile) 
		-- state
		self.tempomatMogliV14 = {}
		tempomatMogli.registerState( self, "SpeedLimit2",    10 )
		tempomatMogli.registerState( self, "KeepSpeed",   false )
		self.tempomatMogliV14.modName = l_currentModName
		
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
			tempomatMogli.mbSetState( self, "KeepSpeed", tempomatMogli.mbIsInputPressed( "mrGearboxMogliKEEPSPEED" ) )		
		else
			tempomatMogli.mbSetState( self, "KeepSpeed", false )		
		end
		
		if self.isServer then
			if     self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE 
					or ( self.movingDirection   <= 0 
					 and ( self.mrGbMS == nil or not ( self.mrGbMS.IsOn ) ) ) then
				self.tempomatMogliV14.keepSpeedLimit = nil		
			elseif self.tempomatMogliV14.KeepSpeed then
				if     self.tempomatMogliV14.keepSpeedLimit == nil then
					self.tempomatMogliV14.lastAxisFoward = 0
					self.tempomatMogliV14.keepSpeedLimit = math.max( self.lastSpeedReal*3600, tempomatMogli.getMinSpeed( self, true ) )
				end
			elseif self.tempomatMogliV14.keepSpeedLimit ~= nil then
				self.tempomatMogliV14.keepSpeedLimit = nil		
			end
		end
	end
	
	--**********************************************************************************************************	
	-- tempomatMogli:getMinSpeed
	--**********************************************************************************************************	
	function tempomatMogli:getMinSpeed( inKmH )
		local minSpeed = 2
		
		if      self.mrGbMS          ~= nil
				and self.mrGbMD          ~= nil
				and not ( self.mrGbMS.Hydrostatic ) 
				and self.mrGbMD.Speed    ~= nil
				and self.mrGbMD.Speed     > 0
				and self.mrGbMS.IdleRpm	 ~= nil
				and self.mrGbMS.RatedRpm ~= nil then
			minSpeed = math.max( minSpeed, self.mrGbMD.Speed ) * self.mrGbMS.IdleRpm	/ self.mrGbMS.RatedRpm
		end
		
		if not ( inKmH ) then
			minSpeed = minSpeed / 3.6
		end
		
		return minSpeed 
	end
	
	--**********************************************************************************************************	
	-- tempomatMogli:getMaxSpeed
	--**********************************************************************************************************	
	function tempomatMogli:getMaxSpeed( inKmH )
		if self.motor == nil then
			return math.huge
		end
	
		local isRev    = false
		
		if      self.mrGbMS ~= nil
				and self.mrGbMS.IsOn then
			isRev = self.mrGbMS.ReverseActive
			if self.isReverseDriving then isRev = not ( isRev ) end
		elseif  g_currentMission.driveControl ~= nil
				and g_currentMission.driveControl.useModules ~= nil
				and g_currentMission.driveControl.useModules.shuttle 
				and self.driveControl ~= nil 
				and self.driveControl.shuttle ~= nil 
				and self.driveControl.shuttle.direction ~= nil 
				and self.driveControl.shuttle.isActive then
			if self.driveControl.shuttle.direction < 0 then
				isRev = true
			end
		else
			if self.movingDirection < 0 then
				isRev = true
			end
		end
		
		local maxSpeed = self.motor.maxForwardSpeed
		if iRev then
			maxSpeed = self.motor.maxBackwardSpeed 
		end		
		maxSpeed = maxSpeed + 0.0833333333333333333333333333333
		if inKmH then
			maxSpeed = maxSpeed * 3.6
		end
		
		return maxSpeed 
	end
	
	--**********************************************************************************************************	
	-- tempomatMogli:newUpdateVehiclePhysics
	--**********************************************************************************************************	
	function tempomatMogli:newUpdateVehiclePhysics( superFunc, axisForward, axisForwardIsAnalog, axisSide, axisSideIsAnalog, dt, ... )
		if     self.tempomatMogliV14                == nil 
				or self.tempomatMogliV14.keepSpeedLimit == nil
				or self.tempomatMogliV14.modName        == nil
				or self.tempomatMogliV14.modName        ~= l_currentModName then
			return superFunc( self, axisForward, axisForwardIsAnalog, axisSide, axisSideIsAnalog, dt, ... )
		end
		
		if type( self.mrGbMSetNeutralActive ) == "function" then
			self:mrGbMSetNeutralActive( false )
		end
		
		local currentSpeed  = self.lastSpeedReal*3600
		local inAxisForward = axisForward
		if     axisForward <= -0.2 then
		-- accelerate by 1 m/s^2
			if self.tempomatMogliV14.keepSpeedLimit < currentSpeed + 2 then
				self.tempomatMogliV14.keepSpeedLimit = math.min( math.max( currentSpeed, self.tempomatMogliV14.keepSpeedLimit ) - axisForward * dt * 0.0036, tempomatMogli.getMaxSpeed( self, true ) )
			end
		elseif axisForward >= 0.2 then	
		-- decelerate by 2 m/s^2 
			if self.tempomatMogliV14.keepSpeedLimit > currentSpeed - 2 then
				self.tempomatMogliV14.keepSpeedLimit = math.max( math.min( currentSpeed, self.tempomatMogliV14.keepSpeedLimit ) - axisForward * dt * 0.0072, 1 )
			end
		end

		local temp = self.motor.speedLimit 
		self.motor.speedLimit = math.min( temp, self.tempomatMogliV14.keepSpeedLimit )
		superFunc( self, -1, false, axisSide, axisSideIsAnalog, dt, ... )
		self.motor.speedLimit = temp
	end
	
	function tempomatMogli:newDrivableOnLeave( superFunc )
		local oldFunc
		
		if not ( self.deactivateOnLeave ) and self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_OFF then
			oldFunc = self.setCruiseControlState
			self.setCruiseControlState = function (self, state, noEventSend) end
		end
		
		superFunc( self )
		
		if oldFunc ~= nil then
			self.setCruiseControlState = oldFunc
		end
	end
	
	Drivable.updateVehiclePhysics = Utils.overwrittenFunction( Drivable.updateVehiclePhysics, tempomatMogli.newUpdateVehiclePhysics )
	Drivable.onLeave              = Utils.overwrittenFunction( Drivable.onLeave,              tempomatMogli.newDrivableOnLeave )  
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
		return self.tempomatMogliV14.SpeedLimit2
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSwapSpeedLimit
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliSwapSpeedLimit( noEventSend )
		local speed1 = self.tempomatMogliV14.SpeedLimit2
		local speed2 = self.cruiseControl.speed
		self:setCruiseControlMaxSpeed(speed1)
		tempomatMogli.mbSetState( self, "SpeedLimit2", speed2, noEventSend ) 		
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:getSaveAttributesAndNodes
	--**********************************************************************************************************	
	function tempomatMogli:getSaveAttributesAndNodes(nodeIdent)
	
		local attributes = ""
	
		if self.tempomatMogliV14 ~= nil then
			if self.tempomatMogliV14.SpeedLimit2 <= 9 or self.tempomatMogliV14.SpeedLimit2 >= 11 then
				attributes = attributes.." mrGbMSpeed2=\"" .. tostring( self.tempomatMogliV14.SpeedLimit2 ) .. "\""     
			end
		end 
		
		return attributes
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:loadFromAttributesAndNodes
	--**********************************************************************************************************	
	function tempomatMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
		local i
		
		if self.tempomatMogliV14 ~= nil then
			i = getXMLInt(xmlFile, key .. "#mrGbMSpeed2" )
			if i ~= nil then
				self.tempomatMogliV14.SpeedLimit2 = i
			end
		end
		
		return BaseMission.VEHICLE_LOAD_OK
	end 

end