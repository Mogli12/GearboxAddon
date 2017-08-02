--***************************************************************
--
-- tempomatMogli
-- 
-- version 1.92 by mogli (biedens)
-- 2015/03/16
--
--***************************************************************

local tempomatMogliVersion=1.701

-- allow modders to include this source file together with mogliBase.lua in their mods
if tempomatMogli == nil or tempomatMogli.version == nil or tempomatMogli.version < tempomatMogliVersion then
--***************************************************************
	--mogliBase20.newClass( "tempomatMogli", "tempomatMogli" )
	if _G[g_currentModName..".mogliBase"] == nil then
		source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
	end
	_G[g_currentModName..".mogliBase"].newClass( "tempomatMogli", "tempomatMogliV17" )
--***************************************************************
	
	tempomatMogli.version = tempomatMogliVersion
	local l_currentModName = g_currentModName
	
	--**********************************************************************************************************	
	-- tempomatMogli:load
	--**********************************************************************************************************	
	function tempomatMogli:load(xmlFile) 
		-- state
		self.tempomatMogliV17 = {}
		
		self.tempomatMogliV17.baseSpeed1 = 50
		self.tempomatMogliV17.baseSpeed2 = 10
		self.tempomatMogliV17.baseSpeed3 = 30
		
		if self.motor ~= nil and self.motor.maxForwardSpeed ~= nil then
			self.tempomatMogliV17.baseSpeed1 = math.floor( self.motor.maxForwardSpeed * 3.6 + 0.5 )
			if     self.tempomatMogliV17.baseSpeed1 < 20 then
				self.tempomatMogliV17.baseSpeed2 = math.floor( self.motor.maxForwardSpeed * 1.25 + 0.5 )
				self.tempomatMogliV17.baseSpeed3 = math.floor( self.motor.maxForwardSpeed * 1.80 + 0.5 )
			elseif self.tempomatMogliV17.baseSpeed1 < 30 then
				self.tempomatMogliV17.baseSpeed3 = 20
			end
		end
		
		tempomatMogli.registerState( self, "SpeedLimit2", self.tempomatMogliV17.baseSpeed2 )
		tempomatMogli.registerState( self, "SpeedLimit3", self.tempomatMogliV17.baseSpeed3 )
		tempomatMogli.registerState( self, "KeepSpeed",   false )
		tempomatMogli.registerState( self, "KeepSpeedToggle", false )
		tempomatMogli.registerState( self, "SpeedLimit",  -1 )
		self.tempomatMogliV17.modName = l_currentModName
		
		self.tempomatMogliSetSpeedLimit  = tempomatMogli.tempomatMogliSetSpeedLimit 
		self.tempomatMogliGetSpeedLimit  = tempomatMogli.tempomatMogliGetSpeedLimit 
		self.tempomatMogliGetSpeedLimit2 = tempomatMogli.tempomatMogliGetSpeedLimit2
		self.tempomatMogliGetSpeedLimit3 = tempomatMogli.tempomatMogliGetSpeedLimit3
		self.tempomatMogliSwapSpeedLimit = tempomatMogli.tempomatMogliSwapSpeedLimit 
		
		if tempomatMogli.cruiseControlHud == nil then
			local x = g_currentMission.cruiseControlOverlay.x + 0.2 * g_currentMission.vehicleHudBg.width
			local y = g_currentMission.cruiseControlOverlay.y
			local w = g_currentMission.cruiseControlOverlay.width
			local h = g_currentMission.cruiseControlOverlay.height
			tempomatMogli.cruiseControlOverlay = Overlay:new("hudCruiseControlOverlay", g_baseUIFilename, x, y, w, h)
			tempomatMogli.cruiseControlOverlay:setUVs(getNormalizedUVs({793, 958, 26, 23}))
			tempomatMogli.cruiseControlOverlay:setColor(0.2122, 0.5271, 0.0307, 1)
		end		
	end	
	
	--**********************************************************************************************************	
	-- tempomatMogli:update
	--**********************************************************************************************************	
	function tempomatMogli:update(dt)
		
	-- inputs	
		if self:getIsActiveForInput(false) then		
			if     tempomatMogli.mbHasInputEvent( "gearboxMogliCONFLICT_1" )
					or tempomatMogli.mbHasInputEvent( "gearboxMogliCONFLICT_2" )
					or tempomatMogli.mbHasInputEvent( "gearboxMogliCONFLICT_3" )
					or tempomatMogli.mbHasInputEvent( "gearboxMogliCONFLICT_4" ) then
				-- ignore
			elseif tempomatMogli.mbHasInputEvent( "gearboxMogliSETSPEED" ) then -- speed limiter
				self:tempomatMogliSetSpeedLimit()
			elseif tempomatMogli.mbHasInputEvent( "gearboxMogliSWAPSPEED" ) then -- speed limiter
				self:tempomatMogliSwapSpeedLimit()
			elseif tempomatMogli.mbHasInputEvent( "gearboxMogliSWAPSPEEDR" ) then -- speed limiter
				self:tempomatMogliSwapSpeedLimit( true )
			elseif tempomatMogli.mbHasInputEvent( "gearboxMogliKEEPSPEEDTOGGLE" ) then
				tempomatMogli.mbSetState( self, "KeepSpeedToggle", not self.tempomatMogliV17.KeepSpeedToggle )	
			end
			local k = self.tempomatMogliV17.KeepSpeedToggle 
			if tempomatMogli.mbIsInputPressed( "gearboxMogliKEEPSPEED" ) then
				k = not k
			end
			if      self.tempomatMogliV17.KeepSpeedToggle
					and self.axisForwardIsAnalog 
					and math.abs( self.axisForward ) > 0.95 then
				k = false
			end
			tempomatMogli.mbSetState( self, "KeepSpeed", k )
		elseif self.steeringEnabled  then
			tempomatMogli.mbSetState( self, "KeepSpeed", self.tempomatMogliV17.KeepSpeedToggle )		
		else
			tempomatMogli.mbSetState( self, "KeepSpeed", false )		
		end
		
		if self.isServer and self.cruiseControl ~= nil then
			if self.movingDirection <= 0 and ( self.mrGbMS == nil or not ( self.mrGbMS.IsOn ) ) then
				self.tempomatMogliV17.keepSpeedLimit = nil		
			elseif self.tempomatMogliV17.KeepSpeed
					and ( math.abs( self.lastSpeedReal*3600 ) > 2 
						 or self.axisForward <= -0.2
					   or not self.tempomatMogliV17.KeepSpeedToggle ) then
				if      self.tempomatMogliV17.keepSpeedLimit == nil then
					self.tempomatMogliV17.lastAxisFoward = 0
					self.tempomatMogliV17.keepSpeedLimit = math.max( self.lastSpeedReal*3600, tempomatMogli.getMinSpeed( self, true ) )
				elseif  self.tempomatMogliV17.KeepSpeedToggle
						and self.tempomatMogliV17.SpeedLimit ~= nil 
						and self.tempomatMogliV17.SpeedLimit ~= self.cruiseControl.speed then
					self.tempomatMogliV17.keepSpeedLimit = self.cruiseControl.speed
					if self.tempomatMogliV17.cruiseControlSpeed ~= nil then
						tempomatMogli.mbSetState( self, "cruiseControlSpeed", self.cruiseControl.speed )
					end					
				end
			elseif self.tempomatMogliV17.keepSpeedLimit ~= nil then
				self.tempomatMogliV17.keepSpeedLimit = nil		
			end
			
			if self.tempomatMogliV17.keepSpeedLimit ~= nil then
				local s = math.floor( self.tempomatMogliV17.keepSpeedLimit + 0.5 )
				tempomatMogli.mbSetState( self, "SpeedLimit", s )		
			elseif  self.tempomatMogliV17.KeepSpeedToggle
					and self.tempomatMogliV17.KeepSpeed then
				tempomatMogli.mbSetState( self, "SpeedLimit", 0 )		
			else
				tempomatMogli.mbSetState( self, "SpeedLimit", -1 )		
			end
		else
			self.tempomatMogliV17.keepSpeedLimit = nil		
			tempomatMogli.mbSetState( self, "SpeedLimit", -1 )		
		end
		
		if self.tempomatMogliV17.SpeedLimit >= 0 then
			if self.tempomatMogliV17.cruiseControlState == nil then
				self.tempomatMogliV17.cruiseControlState = self.cruiseControl.state
			end			
			self.cruiseControl.state = Drivable.CRUISECONTROL_STATE_OFF 
		elseif self.tempomatMogliV17.cruiseControlState ~= nil then
			self.cruiseControl.state = self.tempomatMogliV17.cruiseControlState
			self.tempomatMogliV17.cruiseControlState = nil
		end
	end
	
	--**********************************************************************************************************	
	-- tempomatMogli:draw
	--**********************************************************************************************************	
	function tempomatMogli:draw()
		local x = g_currentMission.cruiseControlOverlay.x + g_currentMission.cruiseControlOverlay.width + g_currentMission.cruiseControlTextOffsetX
		local y = g_currentMission.cruiseControlOverlay.y + g_currentMission.cruiseControlTextOffsetY
		
		setTextBold(false)
		setTextAlignment(RenderText.ALIGN_LEFT)
		
		if self.tempomatMogliV17.SpeedLimit >= 0 then
			if g_currentMission.activeHudIconName == "" then
				tempomatMogli.cruiseControlOverlay:render()
				setTextColor(0.2122, 0.5271, 0.0307, 1)
				x = x + 0.2 * g_currentMission.vehicleHudBg.width
				renderText(x, y, g_currentMission.cruiseControlTextSize, string.format(g_i18n:getText("ui_cruiseControlSpeed"), g_i18n:getSpeed(self.tempomatMogliV17.SpeedLimit)))
			end
		else
			local o = 0.08 * g_currentMission.vehicleHudBg.width
		
			setTextColor(0.3, 0.3, 0.3, 1)
			if g_currentMission.activeHudIconName == "" then
				x = x + o
				renderText(x, y, g_currentMission.cruiseControlTextSize, string.format(g_i18n:getText("ui_cruiseControlSpeed"), g_i18n:getSpeed(self:tempomatMogliGetSpeedLimit2())))
			end
			
			if not ( ( self.mrGbMG ~= nil and self.mrGbMG.onlyTwoSpeeds )
						or ( self.mrGbMG == nil and gearboxMogliGlobals ~= nil and gearboxMogliGlobals.onlyTwoSpeeds ) ) then			
				x = g_currentMission.cruiseControlOverlay.x - o + g_currentMission.cruiseControlTextOffsetX 
				renderText(x, y, g_currentMission.cruiseControlTextSize, string.format(g_i18n:getText("ui_cruiseControlSpeed"), g_i18n:getSpeed(self:tempomatMogliGetSpeedLimit3())))
			end
		end
		
    setTextBold(false)
    setTextColor(1, 1, 1, 1)
    setTextAlignment(RenderText.ALIGN_LEFT)
	end
	
	--**********************************************************************************************************	
	-- tempomatMogli:getMinSpeed
	--**********************************************************************************************************	
	function tempomatMogli:getMinSpeed( inKmH )
		local minSpeed = 2
		
		if self.tempomatMogliV17.KeepSpeedToggle then
			minSpeed = 1
		end
		if      type( self.mrGbMS )            == "table"
				and type( self.mrGbMGetGearSpeed ) == "function"
				and type( self.mrGbMGetAutomatic ) == "function"
				and not ( self.mrGbMS.Hydrostatic ) 
				and not ( self:mrGbMGetAutomatic( ) )
				and self.mrGbMS.IdleRpm	 ~= nil
				and self.mrGbMS.RatedRpm ~= nil then
			minSpeed = math.max( minSpeed, self:mrGbMGetGearSpeed() ) * self.mrGbMS.IdleRpm	/ self.mrGbMS.RatedRpm
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
	function tempomatMogli:newUpdateVehiclePhysics( superFunc, axisForward, axisForwardIsAnalog, axisSide, axisSideIsAnalog, doHandbrake, dt, ... )
		if     self.tempomatMogliV17                == nil 
				or self.tempomatMogliV17.keepSpeedLimit == nil
				or self.tempomatMogliV17.modName        == nil
				or self.tempomatMogliV17.modName        ~= l_currentModName then
			return superFunc( self, axisForward, axisForwardIsAnalog, axisSide, axisSideIsAnalog, doHandbrake, dt, ... )
		end

		if type( self.mrGbMSetNeutralActive ) == "function" then
			self:mrGbMSetNeutralActive( false )
		end
		
		local currentSpeed  = self.lastSpeedReal*3600
		local inAxisForward = axisForward
		if     axisForward <= -0.05 then
		-- accelerate by 0.5..2 m/s^2
			local acc = 2 - math.min( 1.5, currentSpeed * 0.05 )
		
			if self.tempomatMogliV17.keepSpeedLimit < currentSpeed + 2 then
			--self.tempomatMogliV17.keepSpeedLimit = math.min( math.max( currentSpeed, self.tempomatMogliV17.keepSpeedLimit ) - axisForward * dt * 0.0036, tempomatMogli.getMaxSpeed( self, true ) )
				self.tempomatMogliV17.keepSpeedLimit = math.max( currentSpeed, self.tempomatMogliV17.keepSpeedLimit ) - axisForward * dt * 0.0036 * acc 
			end
		elseif axisForward >= 0.05 then	
		-- decelerate by 2..4 m/s^2 
			local acc = Utils.clamp( currentSpeed * 0.05, 2, 4 )
			
			if self.tempomatMogliV17.keepSpeedLimit > currentSpeed - 2 then
				self.tempomatMogliV17.keepSpeedLimit = math.max( math.min( currentSpeed, self.tempomatMogliV17.keepSpeedLimit ) - axisForward * dt * 0.0072 * acc, 1 )
			end
		end

		local temp1 = self.motor.speedLimit 
		
		self.motor.speedLimit = math.min( temp1, self.tempomatMogliV17.keepSpeedLimit )
		superFunc( self, -1, false, axisSide, axisSideIsAnalog, doHandbrake, dt, ... )
		self.motor.speedLimit    = temp1
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
		self:setCruiseControlMaxSpeed(math.floor( self.lastSpeedReal*3600 + 0.5 ))
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSetSpeedLimit
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliGetSpeedLimit( )
		if self.tempomatMogliV17.cruiseControlSpeed ~= nil then
			return self.tempomatMogliV17.cruiseControlSpeed
		end
		return self.cruiseControl.speed
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSetSpeedLimit2
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliGetSpeedLimit2( )
		return self.tempomatMogliV17.SpeedLimit2
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSetSpeedLimit2
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliGetSpeedLimit3( )
		return self.tempomatMogliV17.SpeedLimit3
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:tempomatMogliSwapSpeedLimit
	--**********************************************************************************************************	
	function tempomatMogli:tempomatMogliSwapSpeedLimit( rev, noEventSend )
		local speed1 = self:tempomatMogliGetSpeedLimit()
		local speed2 = self:tempomatMogliGetSpeedLimit2()
		local speed3 = self:tempomatMogliGetSpeedLimit3()
		
		if     ( self.mrGbMG ~= nil and self.mrGbMG.onlyTwoSpeeds )
				or ( self.mrGbMG == nil and gearboxMogliGlobals ~= nil and gearboxMogliGlobals.onlyTwoSpeeds ) then
			self:setCruiseControlMaxSpeed(speed2)
			tempomatMogli.mbSetState( self, "SpeedLimit2", speed1, noEventSend ) 		
		elseif rev then
			self:setCruiseControlMaxSpeed(speed3)
			tempomatMogli.mbSetState( self, "SpeedLimit2", speed1, noEventSend ) 		
			tempomatMogli.mbSetState( self, "SpeedLimit3", speed2, noEventSend ) 		
		else
			self:setCruiseControlMaxSpeed(speed2)
			tempomatMogli.mbSetState( self, "SpeedLimit2", speed3, noEventSend ) 		
			tempomatMogli.mbSetState( self, "SpeedLimit3", speed1, noEventSend ) 		
		end 
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:getSaveAttributesAndNodes
	--**********************************************************************************************************	
	function tempomatMogli:getSaveAttributesAndNodes(nodeIdent)
	
		local attributes = ""
	
		if self.tempomatMogliV17 ~= nil then
			if math.abs( self.tempomatMogliV17.SpeedLimit2 - self.tempomatMogliV17.baseSpeed2 ) > 0.5 then
				attributes = attributes.." mrGbMSpeed2=\"" .. tostring( self.tempomatMogliV17.SpeedLimit2 ) .. "\""     
			end
			if math.abs( self.tempomatMogliV17.SpeedLimit3 - self.tempomatMogliV17.baseSpeed3 ) > 0.5 then
				attributes = attributes.." mrGbMSpeed3=\"" .. tostring( self.tempomatMogliV17.SpeedLimit3 ) .. "\""     
			end
			if self.tempomatMogliV17.KeepSpeedToggle then
				attributes = attributes.." mrGbMKeep=\"true\""     
			end
		end 
		
		return attributes
	end 
	
	--**********************************************************************************************************	
	-- tempomatMogli:loadFromAttributesAndNodes
	--**********************************************************************************************************	
	function tempomatMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
		local i
		
		if self.tempomatMogliV17 ~= nil then
			i = getXMLInt(xmlFile, key .. "#mrGbMSpeed2" )
			if i ~= nil then
				self.tempomatMogliV17.SpeedLimit2 = i
			end
			i = getXMLInt(xmlFile, key .. "#mrGbMSpeed3" )
			if i ~= nil then
				self.tempomatMogliV17.SpeedLimit3 = i
			end
			if getXMLBool(xmlFile, key .. "#mrGbMKeep" ) then
				self.tempomatMogliV17.KeepSpeedToggle = true
			end
		end
		
		if self.tempomatMogliV17.baseSpeed1 ~= nil then
			if     math.abs( self.cruiseControl.speed - self.tempomatMogliV17.baseSpeed2 ) < 1 then
				self.tempomatMogliV17.SpeedLimit2 = self.tempomatMogliV17.SpeedLimit3
				self.tempomatMogliV17.SpeedLimit3 = self.tempomatMogliV17.baseSpeed1
			elseif math.abs( self.cruiseControl.speed - self.tempomatMogliV17.baseSpeed3 ) < 1 then
				self.tempomatMogliV17.SpeedLimit3 = self.tempomatMogliV17.SpeedLimit2
				self.tempomatMogliV17.SpeedLimit2 = self.tempomatMogliV17.baseSpeed1
			end
		end
		
		return BaseMission.VEHICLE_LOAD_OK
	end 

end