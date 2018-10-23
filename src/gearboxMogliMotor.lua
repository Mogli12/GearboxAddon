--***************************************************************
--
-- gearboxMogliMotor
-- 
-- version 2.200 by mogli (biedens)
--
--***************************************************************

local gearboxMogliVersion=2.200

-- allow modders to include this source file together with mogliBase.lua in their mods
if gearboxMogliMotor == nil or gearboxMogliMotor.version == nil or gearboxMogliMotor.version < gearboxMogliVersion then

--**********************************************************************************************************	
-- gearboxMogliMotor
--**********************************************************************************************************	

gearboxMogliMotor = {}
gearboxMogliMotor_mt = Class(gearboxMogliMotor)

setmetatable( gearboxMogliMotor, { __index = function (table, key) return VehicleMotor[key] end } )

local function rpm2String( r )
	if type( r ) == "number" then 
		return string.format( "%4d", r )
	end 
	return "NaN"
end

local function per2String( p )
	if type( p ) == "number" then 
		return string.format( "%3d%%", p * 100 )
	end 
	return "NaN"
end


--**********************************************************************************************************	
-- gearboxMogliMotor:new
--**********************************************************************************************************	
function gearboxMogliMotor:new( vehicle, motor )

--if Vehicle.mrLoadFinished ~= nil then
--	print("gearboxMogli: init of motor with moreRealistic. self.mrIsMrVehicle = "..tostring(vehicle.mrIsMrVehicle))
--end

	local interpolFunction = linearInterpolator1
	local interpolDegree   = 2
	
	local self = {}

	setmetatable(self, gearboxMogliMotor_mt)

	self.vehicle          = vehicle
	self.original         = motor 	
	self.torqueCurve      = AnimCurve:new( interpolFunction, interpolDegree )
	self.boostMinSpeed    = gearboxMogli.huge 

	if gearboxMogli.powerFuelCurve == nil then
		gearboxMogli.powerFuelCurve = AnimCurve:new( interpolFunction, interpolDegree )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.001, time=0.0} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.060, time=0.01} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.160, time=0.04} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.360, time=0.12} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.500, time=0.2} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.800, time=0.4} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.952, time=0.6} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.986, time=0.7} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=1.000, time=0.8} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.978, time=0.9} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.909, time=1.0} )
	end
	
	if vehicle.mrGbMS.Engine.maxTorque > 0 then
		self.torqueCurve:addKeyframe( {v=0, time=0} )
	
		for _,k in pairs(vehicle.mrGbMS.Engine.torqueValues) do
			self.torqueCurve:addKeyframe( k )	
		end
		self.torqueCurve:addKeyframe( {v=0, time = self.vehicle.mrGbMS.CurMaxRpm + 0.01 } )
		
		if vehicle.mrGbMS.Engine.ecoTorqueValues ~= nil then
			self.ecoTorqueCurve = AnimCurve:new( interpolFunction, interpolDegree )
			self.boostMinSpeed  = vehicle.mrGbMS.BoostMinSpeed
			self.ecoTorqueCurve:addKeyframe( {v=0, time=0} )
			for _,k in pairs(vehicle.mrGbMS.Engine.ecoTorqueValues) do
				self.ecoTorqueCurve:addKeyframe( k )	
			end
			self.ecoTorqueCurve:addKeyframe( {v=0, time = self.vehicle.mrGbMS.CurMaxRpm + 0.01 } )
		end
	
		self.maxTorqueRpm   = vehicle.mrGbMS.Engine.maxTorqueRpm
		self.maxMotorTorque = vehicle.mrGbMS.Engine.maxTorque
	else
		local vMax  = 0
		local tMax  = vehicle.mrGbMS.OrigMaxRpm
		local tvMax = 0
		local vvMax = 0
		local tMin  = motor.torqueCurve.keyframes[1].time
		local vMin  = motor.torqueCurve.keyframes[1].v
		
		if tMin > 0 and vMin > 0 then 
			self.torqueCurve:addKeyframe( {v=0, time=0} )	
			self.torqueCurve:addKeyframe( {v=0.6*vMin, time=0.4*tMin} )	
		end 
		
		for _,k in pairs(motor.torqueCurve.keyframes) do
			if k.time < tMin then 
				tMin = k.time 
				vMin = k.v 
			end 
			if ( k.v > 0.000001 or k.time < 0.999999 ) then 
				local kv = k.v
				local kt = math.min( k.time, vehicle.mrGbMS.CurMaxRpm - 1 )
				
				if vvMax < k.v then
					vvMax = kv
					tvMax = k.time
				end
				
				vMax = kv
				tMax = kt
				
				self.torqueCurve:addKeyframe( {v=kv, time=kt} )	
			end
		end		
		
		if vMax > 0 and tMax <= vehicle.mrGbMS.CurMaxRpm - 1 then
			local r = Utils.clamp( vehicle.mrGbMS.CurMaxRpm - tMax, 1, gearboxMogli.rpmRatedMinus )
			self.torqueCurve:addKeyframe( {v=0.9*vMax, time=tMax + 0.25*r} )
			self.torqueCurve:addKeyframe( {v=0.5*vMax, time=tMax + 0.50*r} )
			self.torqueCurve:addKeyframe( {v=0.1*vMax, time=tMax + 0.75*r} )
			self.torqueCurve:addKeyframe( {v=0, time=tMax + r} )
			tMax = tMax + r
		end
		self.torqueCurve:addKeyframe( {v=0, time = self.vehicle.mrGbMS.CurMaxRpm + 0.01 } )
		
		self.maxTorqueRpm   = tvMax	
		self.maxMotorTorque = self.torqueCurve:getMaximum()
		
		if      vehicle.mrIsMrVehicle
				and vehicle.mrBoost               ~= nil
				and vehicle.mrBoost.maxBoostRatio ~= nil
				and vehicle.mrBoost.maxBoostRatio > 1 then 
			self.ecoTorqueCurve  = self.torqueCurve
			self.torqueCurve     = AnimCurve:new( interpolFunction, interpolDegree )
			self.maxMotorTorque  = self.maxMotorTorque * vehicle.mrBoost.maxBoostRatio
			if vehicle.mrBoost.speedBoostStartMps ~= nil then 
				self.boostMinSpeed = vehicle.mrBoost.speedBoostStartMps
			end
			for _,k in pairs(self.ecoTorqueCurve.keyframes) do
				local kv = k.v * vehicle.mrBoost.maxBoostRatio
				local kt = k.time
				self.torqueCurve:addKeyframe( {v=kv, time=kt} )	
			end
		end
	end

	self.fuelCurve = AnimCurve:new( interpolFunction, interpolDegree )
	if vehicle.mrGbMS.Engine.fuelUsageValues == nil then		
		self.fuelCurve:addKeyframe( { v = 1.25 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.CurMinRpm } )
		self.fuelCurve:addKeyframe( { v = 1.10 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.IdleRpm } )
		self.fuelCurve:addKeyframe( { v = 0.94 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.80*self.vehicle.mrGbMS.IdleRpm+0.20*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 0.90 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.65*self.vehicle.mrGbMS.IdleRpm+0.35*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 0.90 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.55*self.vehicle.mrGbMS.IdleRpm+0.45*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 0.92 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.30*self.vehicle.mrGbMS.IdleRpm+0.70*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 1.00 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 1.25 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.50*self.vehicle.mrGbMS.RatedRpm+0.50*self.vehicle.mrGbMS.CurMaxRpm } )		
		self.fuelCurve:addKeyframe( { v = 2.00 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.CurMaxRpm } )		
		self.fuelCurve:addKeyframe( { v = 10 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = vehicle.mrGbMS.CurMaxRpm + 1 } )		
	else
		for _,k in pairs(vehicle.mrGbMS.Engine.fuelUsageValues) do
			if k.time < self.vehicle.mrGbMS.CurMaxRpm + 1 then
				self.fuelCurve:addKeyframe( k )	
			end
		end
		self.fuelCurve:addKeyframe( { v = 2100, time = vehicle.mrGbMS.CurMaxRpm + 1 } )		
	end
	
	local minTargetRpm = self.vehicle.mrGbMS.IdleRpm+1
	
	self.rpmPowerCurve  = AnimCurve:new( interpolFunction, interpolDegree )	
	self.maxPower       = minTargetRpm * self.torqueCurve:get( minTargetRpm ) 	
	self.maxPowerRpm    = self.vehicle.mrGbMS.RatedRpm 
	self.maxMaxPowerRpm = self.vehicle.mrGbMS.RatedRpm
	self.minMaxPowerRpm = self.vehicle.mrGbMS.IdleRpm
	self.rpmPowerCurve:addKeyframe( {v=minTargetRpm-1, time=0} )				
	self.rpmPowerCurve:addKeyframe( {v=minTargetRpm,   time=self.maxPower} )		

	local lastP = self.maxPower 
	local lastR = self.maxPowerRpm

	for _,k in pairs(self.torqueCurve.keyframes) do			
		local p = k.v*k.time
		if     p      >  self.maxPower then
			self.maxPower       = p
			self.maxPowerRpm    = k.time
			self.maxMaxPowerRpm = k.time
		elseif  p     >= gearboxMogli.maxPowerLimit * self.maxPower then
			self.maxMaxPowerRpm = k.time
		elseif  lastP >= gearboxMogli.maxPowerLimit * self.maxPower 
		    and lastP >  p + gearboxMogli.eps then
			self.maxMaxPowerRpm = lastR + ( k.time - lastR ) * ( lastP - gearboxMogli.maxPowerLimit * self.maxPower ) / ( lastP - p )
		end
		lastP = p
		lastR = k.time
	end
	if self.maxMaxPowerRpm > self.vehicle.mrGbMS.MaxTargetRpm then
		self.maxMaxPowerRpm = self.vehicle.mrGbMS.MaxTargetRpm
	end
	if self.maxMaxPowerRpm <= self.maxPowerRpm then
		self.maxMaxPowerRpm = self.maxPowerRpm + 1
	end
		
	lastP = minTargetRpm * self.torqueCurve:get( minTargetRpm )
	for _,k in pairs(self.torqueCurve.keyframes) do			
		local p = k.v*k.time
		if k.time >= self.maxPowerRpm then
			break
		elseif p <= gearboxMogli.maxPowerLimit * self.maxPower then
			self.minMaxPowerRpm = k.time
			if p <= gearboxMogli.maxMaxPowerRatio * self.maxPower and lastP < p then
				lastP = p
				self.rpmPowerCurve:addKeyframe( {v=k.time, time=p} )	
			end
		end
	end
	
	if gearboxMogli.maxMaxPowerRatio < 1 then
		self.rpmPowerCurve:addKeyframe( {v=self.maxMaxPowerRpm, time=0.5 * ( 1 + gearboxMogli.maxMaxPowerRatio ) * self.maxPower} )	
		self.rpmPowerCurve:addKeyframe( {v=self.minMaxPowerRpm, time=self.maxPower} )	
		self.rpmPowerCurve:addKeyframe( {v=self.minMaxPowerRpm, time=gearboxMogli.huge} )	
	else
		self.rpmPowerCurve:addKeyframe( {v=self.maxMaxPowerRpm, time=self.maxPower} )	
	end
	
	if self.ecoTorqueCurve ~= nil then
		self.maxEcoPower   = minTargetRpm * self.ecoTorqueCurve:get( minTargetRpm ) 		
		self.ecoPowerCurve = AnimCurve:new( interpolFunction, interpolDegree )
		self.ecoPowerCurve:addKeyframe( {v=minTargetRpm-1, time=0} )				
		self.ecoPowerCurve:addKeyframe( {v=minTargetRpm,   time=self.maxEcoPower} )		
		for _,k in pairs(self.ecoTorqueCurve.keyframes) do			
			local p = k.v*k.time
			if self.maxEcoPower < p then
				self.maxEcoPower  = p
				self.ecoPowerCurve:addKeyframe( {v=k.time, time=p} )		
			end
		end
	end
	
	if vehicle.mrGbMS.HydrostaticEfficiency ~= nil then
		self.hydroEff = AnimCurve:new( linearInterpolator1 )
		local ktime, kv
		for _,k in pairs(vehicle.mrGbMS.HydrostaticEfficiency) do
			if ktime == nil then
				self.hydroEff:addKeyframe( { time = k.time-2*gearboxMogli.eps, v = 0 } )
				self.hydroEff:addKeyframe( { time = k.time-gearboxMogli.eps, v = k.v } )
			end
			ktime = k.time
			kv    = k.v
			self.hydroEff:addKeyframe( k )
		end
		self.hydroEff:addKeyframe( { time = ktime+gearboxMogli.eps, v = kv } )
		self.hydroEff:addKeyframe( { time = ktime+2*gearboxMogli.eps, v = 0 } )
	end
	
	gearboxMogliMotor.copyRuntimeValues( motor, self )
	
	self.nonClampedMotorRpm      = 0
	self.clutchRpm               = 0
	self.clutchRpmR              = 0
	self.lastMotorRpm            = 0
	self.lastRealMotorRpm        = 0
	self.equalizedMotorRpm       = 0
	
	self.minRpm                  = vehicle.mrGbMS.OrigMinRpm
	self.maxRpm                  = vehicle.mrGbMS.OrigMaxRpm	
	self.minRequiredRpm          = self.vehicle.mrGbMS.IdleRpm
	self.maxClutchTorque         = motor.maxClutchTorque
	self.brakeForce              = motor.brakeForce
	self.gear                    = 0
	self.gearRatio               = gearboxMogli.maxManualGearRatio
	self.forwardGearRatios       = motor.forwardGearRatio
	self.backwardGearRatios      = motor.backwardGearRatio
	self.minForwardGearRatio     = motor.minForwardGearRatio
	self.maxForwardGearRatio     = motor.maxForwardGearRatio
	self.minBackwardGearRatio    = motor.minBackwardGearRatio
	self.maxBackwardGearRatio    = motor.maxBackwardGearRatio
	self.maxHydroGearRatio       = gearboxMogli.maxHydroGearRatio
	self.rpmFadeOutRange         = motor.rpmFadeOutRange
	self.targetRpm               = self.vehicle.mrGbMS.IdleRpm
	self.maxTargetRpm            = self.vehicle.mrGbMS.MaxTargetRpm
	self.minTargetRpm            = self.vehicle.mrGbMS.MinTargetRpm
	self.requiredWheelTorque     = 0
	self.wheelSlipFactor         = 1

	self.maxForwardSpeed         = motor.maxForwardSpeed 
	self.maxBackwardSpeed        = motor.maxBackwardSpeed 
	if vehicle.mrGbMS.MaxForwardSpeed  ~= nil then
		self.maxForwardSpeed       = vehicle.mrGbMS.MaxForwardSpeed / 3.6 
	end
	if vehicle.mrGbMS.MaxBackwardSpeed ~= nil then
		self.maxBackwardSpeed      = vehicle.mrGbMS.MaxBackwardSpeed / 3.6
	end
	self.ptoMotorRpmRatio        = motor.ptoMotorRpmRatio

	self.maxTorque               = motor.maxTorque
	self.lowBrakeForceScale      = motor.lowBrakeForceScale
	self.lowBrakeForceSpeedLimit = 0.01 -- motor.lowBrakeForceSpeedLimit
		
	self.maxPossibleRpm          = self.vehicle.mrGbMS.RatedRpm
	self.wheelSpeedRpm           = 0
	self.noTransmission          = true
	self.noTorque                = true
	self.clutchPercent           = 0
	self.minThrottle             = 0.3
	self.idleThrottle            = self.vehicle.mrGbMS.IdleEnrichment
	self.throttleRpm             = 0
	self.prevMotorRpm            = 0 --motor.lastMotorRpm
	self.prevNonClampedMotorRpm  = 0 --motor.nonClampedMotorRpm
	self.nonClampedMotorRpmS     = 0 --motor.nonClampedMotorRpm
	self.deltaRpm                = 0
	self.transmissionInputRpm    = 0
	self.motorLoad               = 0
	self.usedMotorTorque         = 0
	self.usedMotorTorqueP        = 0
	self.usedMotorTorqueS        = 0
	self.fuelMotorTorque         = 0
	self.lastMotorTorque         = 0
	self.lastTransTorque         = 0
	self.usedTransTorque         = 0
	self.usedTransTorqueS        = 0
	self.noTransTorque           = 0
	self.motorLoadP              = 0
	self.ptoToolTorque           = 0
	self.ptoMotorRpm             = self.vehicle.mrGbMS.IdleRpm
	self.ptoToolRpm              = 0
	self.ptoMotorTorque          = 0
	self.lastMissingTorque       = 0
	self.lastCurMaxRpm           = self.vehicle.mrGbMS.CurMaxRpm
	self.lastAbsDeltaRpm         = 0
	self.limitMaxRpm             = true
	self.motorLoadS              = 0
	self.requestedPower          = 0
	self.maxRpmIncrease          = 0
	self.tickDt                  = 0
	self.absWheelSpeedRpm        = 0
	self.absWheelSpeedRpmS       = 0
	self.autoClutchPercent       = 0
	self.lastThrottle            = 0
	self.lastClutchClosedTime    = 0
	self.brakeNeutralTimer       = 0
	self.hydrostaticFactor       = 1
	self.lastHydrostaticFactor   = 1
	self.rpmIncFactor            = self.vehicle.mrGbMS.RpmIncFactor	
	self.rpmIncFactorS           = self.vehicle.mrGbMS.RpmIncFactorFull
	self.lastBrakeForce          = 0
	self.ratedFuelRatio          = self.fuelCurve:get( self.vehicle.mrGbMS.RatedRpm )
	self.moiFactor               = 1
	self.ratioFactorG            = 1
	self.ratioFactorR            = nil
	
	self.currentSpeed            = 0
	self.currentSpeedVector      = nil
	
	self.boostP                  = 0
	self.boostS                  = 0
	
	self.brakeForceRatio         = 0
	if vehicle.mrGbMS.BrakeForceRatio > 0 then
		local r0 = math.max( self.maxMaxPowerRpm, vehicle.mrGbMS.RatedRpm )
		if r0 > vehicle.mrGbMS.IdleRpm + gearboxMogli.eps then
			self.brakeForceRatio     = vehicle.mrGbMS.BrakeForceRatio / ( r0 - vehicle.mrGbMS.IdleRpm )
		end
	end
	
	self.boost                   = nil
	self:chooseTorqueCurve( true )
	
	if vehicle.mrIsMrVehicle then
		for n,v in pairs( motor ) do
			if      type( n ) == "string" 
					and string.sub( n, 1, 2 ) == "mr" 
					and ( type( v ) == "number" or type( v ) == "boolean" or type( v ) == "string" ) then
				self[n] = v
			end
		end
		self.rotInertiaFx             = motor.rotInertiaFx
		self.mrLastAxleTorque         = 0
		self.mrLastEngineOutputTorque = 0
		self.mrLastDummyGearRatio     = 0
		self.mrMaxTorque              = 0
	end
	
	return self
end

--**********************************************************************************************************	
-- gearboxMogliMotor.chooseTorqueCurve
--**********************************************************************************************************	
function gearboxMogliMotor:chooseTorqueCurve( eco )
	local lastBoost = self.boost
	if eco and self.ecoTorqueCurve ~= nil then
		self.boost              = false
		self.currentTorqueCurve = self.ecoTorqueCurve
		self.currentPowerCurve  = self.ecoPowerCurve
		self.currentMaxPower    = self.maxEcoPower 
	else
		self.boost              = ( self.ecoTorqueCurve ~= nil )
		self.currentTorqueCurve = self.torqueCurve
		self.currentPowerCurve  = self.rpmPowerCurve
		self.currentMaxPower    = self.maxPower 
	end
	
	self.maxMotorTorque = self.currentTorqueCurve:getMaximum()
	self.maxRatedTorque = self.currentTorqueCurve:get( self.vehicle.mrGbMS.RatedRpm )
	
	if lastBoost == nil or self.boost ~= lastBoost then
		self.debugTorqueGraph             = nil
		self.debugPowerGraph              = nil
		self.debugEffectiveTorqueGraph    = nil
		self.debugEffectivePowerGraph     = nil
		self.debugEffectiveGearRatioGraph = nil
		self.debugEffectiveRpmGraph       = nil
	end
end

--**********************************************************************************************************	
-- gearboxMogliMotor.getTorqueCurve
--**********************************************************************************************************	
function gearboxMogliMotor:getTorqueCurve()
	return self.currentTorqueCurve
end

--**********************************************************************************************************	
-- gearboxMogliMotor.copyRuntimeValues
--**********************************************************************************************************	
function gearboxMogliMotor.copyRuntimeValues( motorFrom, motorTo )

	if motorFrom.vehicle ~= nil and not ( motorTo.vehicle.isMotorStarted ) then
		motorTo.nonClampedMotorRpm    = 0
		motorTo.clutchRpm             = 0
		motorTo.lastMotorRpm          = 0
		motorTo.lastRealMotorRpm      = 0
		motorTo.equalizedMotorRpm     = 0
	else
		motorTo.nonClampedMotorRpm    = Utils.getNoNil( motorFrom.nonClampedMotorRpm, 0 )
		motorTo.clutchRpm             = Utils.getNoNil( motorFrom.clutchRpm        , motorTo.nonClampedMotorRpm )   
		motorTo.lastMotorRpm          = Utils.getNoNil( motorFrom.lastMotorRpm     , motorTo.nonClampedMotorRpm )  
		motorTo.lastRealMotorRpm      = Utils.getNoNil( motorFrom.lastRealMotorRpm , motorTo.nonClampedMotorRpm )      
		motorTo.equalizedMotorRpm     = Utils.getNoNil( motorFrom.equalizedMotorRpm, motorTo.nonClampedMotorRpm )
	end
	motorTo.lastPtoRpm              = motorFrom.lastPtoRpm
	motorTo.gear                    = motorFrom.gear               
	motorTo.gearRatio               = motorFrom.gearRatio          
	motorTo.rpmLimit                = motorFrom.rpmLimit 
	motorTo.speedLimit              = motorFrom.speedLimit
	motorTo.minSpeed                = motorFrom.minSpeed

	motorTo.rotInertia              = motorFrom.rotInertia 
	motorTo.dampingRate             = motorFrom.dampingRate
	
	motorTo.usedTransTorqueS        = 0
	motorTo.currentSpeed            = 0
	motorTo.currentSpeedVector      = nil
	motorTo.accS                    = 0
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getHydroEff
--**********************************************************************************************************	
function gearboxMogliMotor:getHydroEff( h )
	if self.hydroEff == nil then
		return 1
	elseif  self.vehicle.mrGbMS.ReverseActive
			and self.vehicle.mrGbMS.HydrostaticMin < 0 then
		h = -h
	end
	if self.vehicle.mrGbMS.HydrostaticMin <= h and h <= self.vehicle.mrGbMS.HydrostaticMax then
		return self.hydroEff:get( h )
	end
	print("FS17_GearboxAddon: Error! hydrostaticFactor out of range: "..tostring(h))
	return 0
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getLimitedGearRatio
--**********************************************************************************************************	
function gearboxMogliMotor:getLimitedGearRatio( r, withSign, noWarning )
	if type( r ) ~= "number" then
		print("FS17_GearboxAddon: Error! gearRatio is not a number: "..tostring(r))
		gearboxMogli.printCallStack( self.vehicle )
		if self.vehicle.mrGbMS.ReverseActive then
			return -gearboxMogli.maxGearRatio
		else
			return  gearboxMogli.maxGearRatio
		end
	end
	
	local a = r
	if withSign and r < 0 then
		a = -r
	end		
	
	if a < gearboxMogli.minGearRatio then
		if not ( noWarning ) then
			print("FS17_GearboxAddon: Error! gearRatio is too small: "..tostring(r))
			gearboxMogli.printCallStack( self.vehicle )
		end
		if withSign and r < 0 then
			return -gearboxMogli.minGearRatio
		else
			return  gearboxMogli.minGearRatio
		end
	end
	
	if a > gearboxMogli.maxGearRatio then
		if not ( noWarning ) then
			print("FS17_GearboxAddon: Error! gearRatio is too big: "..tostring(r))
			gearboxMogli.printCallStack( self.vehicle )
		end
		if withSign and r < 0 then
			return -gearboxMogli.maxGearRatio
		else
			return  gearboxMogli.maxGearRatio
		end
	end

	return r
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getGearRatio
--**********************************************************************************************************	
function gearboxMogliMotor:getGearRatio( withWarning )
	return self:getLimitedGearRatio( self.gearRatio, true, not ( withWarning ) )
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getMogliGearRatio
--**********************************************************************************************************	
function gearboxMogliMotor:getMogliGearRatio()
	return gearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbMS.CurrentGearSpeed )
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getGearRatioFactor
--**********************************************************************************************************	
function gearboxMogliMotor:getGearRatioFactor()
	return self.clutchRpm / self:getMotorRpm()
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getSpeedLimit
--**********************************************************************************************************	
function gearboxMogliMotor:getSpeedLimit( )
	return self.currentSpeedLimit
end

--**********************************************************************************************************	
-- gearboxMogliMotor:updateSpeedLimit
--**********************************************************************************************************	
function gearboxMogliMotor:updateSpeedLimit( dt, acceleration )
	self.currentSpeedLimit = math.huge
	
	local speedLimit = self.vehicle:getSpeedLimit(true)
	
	if      self.vehicle:mrGbMGetModifyDifferentials()
			and self.vehicle.mrGbMS.LockedDiffSpeedLimit ~= nil
			and ( self.vehicle:mrGbMGetDiffLockMiddle()
				 or self.vehicle:mrGbMGetDiffLockFront() 
				 or self.vehicle:mrGbMGetDiffLockBack() ) then   
		speedLimit = math.min( speedLimit, self.vehicle.mrGbMS.LockedDiffSpeedLimit ) 
	end
	
	if not ( self.vehicle.steeringEnabled ) then
		speedLimit = math.min( speedLimit, self.speedLimit )
	end
	
	if      self.vehicle.tempomatMogliV22 ~= nil 
			and self.vehicle.tempomatMogliV22.keepSpeedLimit ~= nil then
		speedLimit = math.min( speedLimit, self.vehicle.tempomatMogliV22.keepSpeedLimit )
	end
	
	speedLimit = speedLimit * gearboxMogli.kmhTOms

	if     self.vehicle.mrGbMS.SpeedLimiter 
			or self.vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE then

		local cruiseSpeed = math.min( speedLimit, self.vehicle.cruiseControl.speed * gearboxMogli.kmhTOms )
		if dt == nil then
			dt = self.tickDt
		end
		
		if self.speedLimitS == nil then 
			self.speedLimitS = math.abs( self.currentSpeed )
		end
		-- limit speed limiter change to given km/h per second
		local limitMax   =  0.001 * gearboxMogli.kmhTOms * self.vehicle:mrGbMGetAccelerateToLimit() * dt
		local decToLimit = self.vehicle:mrGbMGetDecelerateToLimit()
		---- avoid to much brake force => limit to 7 km/h/s if difference below 2.77778 km/h difference
		if self.speedLimitS - 1 < cruiseSpeed and cruiseSpeed < self.speedLimitS and decToLimit > 7 then
			decToLimit     = 7
		end
		local limitMin   = -0.001 * gearboxMogli.kmhTOms * decToLimit * dt
		self.speedLimitS = self.speedLimitS + Utils.clamp( math.min( cruiseSpeed, self.maxForwardSpeed ) - self.speedLimitS, limitMin, limitMax )
		if cruiseSpeed < self.maxForwardSpeed or self.speedLimitS < 0.97 * self.maxForwardSpeed then
			cruiseSpeed = self.speedLimitS
		end
		
		if speedLimit > cruiseSpeed then
			speedLimit = cruiseSpeed
		end
	else
		self.speedLimitS = math.min( speedLimit, math.abs( self.currentSpeed ) )
	end

--if self.vehicle.mrGbML.hydroTargetSpeed ~= nil and speedLimit > self.vehicle.mrGbML.hydroTargetSpeed then
--	speedLimit = self.vehicle.mrGbML.hydroTargetSpeed
--end
	
	if self.vehicle.mrGbMS.MaxSpeedLimiter then
		local maxSpeed = self.maxForwardSpeed
		
		if self.vehicle.mrGbMS.ReverseActive then
			maxSpeed = self.maxBackwardSpeed
		end		
		if speedLimit > maxSpeed then
			speedLimit = maxSpeed
		end
	end
	
	local lastAccSpeedLimit = self.maxAccSpeedLimit
	self.maxAccSpeedLimit   = nil
	if 0.01 < acceleration and acceleration < self.vehicle.mrGbMS.MaxRpmThrottle then
		local _,_,gMax = self.vehicle:mrGbMGetGearSpeed()
		gMax = gMax / 3.6
		local gMin
		if self.vehicle.mrGbMS.Hydrostatic then
			gMin = 0
		else
			gMin = gMax * self.vehicle.mrGbMS.IdleRpm / self.vehicle.mrGbMS.RatedRpm
		end
		if gMin < speedLimit then 			
			-- no further acceleration 
			local sMax = self.currentSpeed
			if lastAccSpeedLimit ~= nil and lastAccSpeedLimit < sMax then
				sMax = lastAccSpeedLimit
			end
			self.maxAccSpeedLimit = math.max( 0.278,
																				sMax - 0.0001 * dt,
																				gMin + ( math.min( speedLimit, gMax ) - gMin ) * acceleration / self.vehicle.mrGbMS.MaxRpmThrottle )
			if speedLimit > self.maxAccSpeedLimit then
				speedLimit = self.maxAccSpeedLimit
			end
		end
	end
						
	self.currentSpeedLimit = speedLimit 
	
	return speedLimit
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getCurMaxRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getCurMaxRpm( forGetTorque )

	if forGetTorque and self.ratioFactorR == nil then 
	-- exit here because there is not connection between wheels and motor 
		return self.maxPossibleRpm 
	end 
	
	curMaxRpm = gearboxMogli.huge
						
	if self.ratioFactorR ~= nil and self.ratioFactorR > 1e-6 then 	
		if     not ( forGetTorque ) then
			curMaxRpm = ( self.maxPossibleRpm + gearboxMogli.speedLimitRpmDiff ) / self.ratioFactorR
		elseif not ( self.vehicle.mrGbMS.Hydrostatic ) then
			curMaxRpm = self.maxPossibleRpm / self.ratioFactorR
		end
	end
	
	local speedLimit   = gearboxMogli.huge
	
	if self.ptoSpeedLimit ~= nil then
		speedLimit = self.ptoSpeedLimit
	end
	
	local limitRpmNow = false
	if forGetTorque then
		limitRpmNow = not ( self.limitMaxRpm )
	else
		limitRpmNow = self.limitMaxRpm
	end
	
	if limitRpmNow then
		speedLimit = math.min( speedLimit, self:getSpeedLimit() )
	elseif self.vehicle.mrGbMS.ConstantRpm then
		speedLimit = math.min( speedLimit, self:getSpeedLimit() + gearboxMogli.speedLimitBrake )
	end
	if forGetTorque and self.vehicle.mrGbML.hydroTargetSpeed ~= nil then
		speedLimit = math.min( speedLimit, self.vehicle.mrGbML.hydroTargetSpeed )
	end

	if speedLimit < gearboxMogli.huge then
		speedLimit = speedLimit + gearboxMogli.extraSpeedLimitMs
		curMaxRpm  = Utils.clamp( speedLimit * gearboxMogli.factor30pi * self:getMogliGearRatio() * self.ratioFactorG / self.wheelSlipFactor, 1, curMaxRpm )
	--print(string.format("%5s; %5.1fkm/h; %4d; %4d; %4d; (%6g, %6g)",
	--                    tostring(forGetTorque),
	--										speedLimit*3.6,
	--										curMaxRpm,
	--										self.clutchRpm,
	--										self.clutchRpm / Utils.getNoNil( self.ratioFactorR, -1 ),
	--										Utils.getNoNil( self.ratioFactorG, -1 ),
	--										Utils.getNoNil( self.ratioFactorR, -1 )
	--										))
	end
	
	if self.rpmLimit ~= nil and self.rpmLimit < curMaxRpm then
		curMaxRpm  = self.rpmLimit
	end
	
	if curMaxRpm < self.vehicle.mrGbMS.CurMinRpm then
		curMaxRpm  = self.vehicle.mrGbMS.CurMinRpm 
	end
	
	if limitRpmNow then
		speedLimit = self.vehicle:getSpeedLimit(true)
		if speedLimit < gearboxMogli.huge then
			speedLimit = speedLimit * gearboxMogli.kmhTOms
			speedLimit = speedLimit + gearboxMogli.extraSpeedLimitMs
			curMaxRpm  = Utils.clamp( speedLimit * gearboxMogli.factor30pi * self:getMogliGearRatio() * self.ratioFactorG / self.wheelSlipFactor, 1, curMaxRpm )
		end
	end
	
	if forGetTorque then
		curMaxRpm = curMaxRpm * self.ratioFactorR
	else
		-- smooth braking if we are too fast 
		curMaxRpm = math.max( curMaxRpm, self.clutchRpmR - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor )
		self.lastCurMaxRpm = curMaxRpm
	end
	
	return curMaxRpm
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getBestGear
--**********************************************************************************************************	
function gearboxMogliMotor:getBestGear( acceleration, wheelSpeedRpm, accSafeMotorRpm, requiredWheelTorque, requiredMotorRpm )

	local direction = 1
	local gearRatio = self:getMogliGearRatio() * self.ratioFactorG
	
	if self.vehicle.mrGbMS.ReverseActive then
		direction = -1
		gearRatio = -gearRatio
	end
	
	if self.lastDebugGearRatio == nil or math.abs( self.lastDebugGearRatio - gearRatio ) > 1 then
		-- Vehicle.drawDebugRendering !!!
		self.debugEffectiveTorqueGraph    = nil
		self.debugEffectivePowerGraph     = nil
		self.debugEffectiveGearRatioGraph = nil
		self.debugEffectiveRpmGraph       = nil
		self.lastDebugGearRatio           = gearRatio
	end
	
	return direction, gearRatio
end

--**********************************************************************************************************	
-- gearboxMogliMotor:motorStall
--**********************************************************************************************************	
function gearboxMogliMotor:motorStall( warningText1, warningText2 )
	if self.vehicle:mrGbMGetAutoClutch() or g_currentMission.missionInfo.automaticMotorStartEnabled then
		self.vehicle:mrGbMSetNeutralActive(true, false, true)
	else
		self.vehicle:stopMotor()
	end
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getTorque
--**********************************************************************************************************	
function gearboxMogliMotor:getTorque( acceleration, limitRpm )

	local prevTransTorque = self.lastTransTorque

	self.lastTransTorque         = 0
	self.noTransTorque           = 0
	self.ptoMotorTorque          = 0
	self.lastMissingTorque       = 0
	self.torqueMultiplication    = nil
	self.transmissionEfficiency  = nil
	
	local ptoMotorTorque  = self.ptoMotorTorque	
	local acc             = self.lastThrottle
	local brakePedal      = 0
	local rpm             = math.min( self.lastRealMotorRpm, self.lastMotorRpm )
	
	local pt = 0	
	if self.ptoToolTorque > 0 then
	  pt = self.ptoToolTorque / self.ptoMotorRpmRatio
	end
	
	local eco = false
	if      self.ecoTorqueCurve ~= nil
			and ( self.vehicle.mrGbMS.EcoMode
				 or not ( self.ptoToolTorque > 0
							 or ( self.vehicle.mrGbMS.IsCombine and self.vehicle:getIsTurnedOn() )
							 or self.currentSpeed  > self.boostMinSpeed ) ) then
		eco = true
	end
	self:chooseTorqueCurve( eco )
	
	local torque = 0
	if self.vehicle.isMotorStarted then 
		torque = self.currentTorqueCurve:get( rpm )
	end 
	
	local mt = torque 
	
	if torque > gearboxMogli.eps and self.vehicle.mrGbMG.debugInfo then
		self.vehicle.mrGbML.ptoInfo = string.format("%4d, %4d / %4d, %4d (%4d) => %3d, %3d (%3d) / %3d%% (%3d%%)", 
																								self.ptoToolRpm, rpm, self.ptoToolTorque*1000, pt*1000, torque*1000,
																								self.ptoToolRpm * self.ptoToolTorque * gearboxMogli.powerFactor0,
																								rpm * pt * gearboxMogli.powerFactor0,
																								rpm * torque * gearboxMogli.powerFactor0, 
																								100 * rpm * pt / self.currentMaxPower,
																								100 * pt / torque )
	end

	self.lastMotorTorque	= torque
	
	if pt > 0 then
		if     self.noTransmission 
				or self.noTorque 
				or self.minRequiredRpm < self.ptoMotorRpmRatio * self.ptoToolRpm - 50
			--or self.vehicle.mrGbMS.Hydrostatic
			--or ( self.vehicle.mrGbMS.TorqueConverter and self.vehicle.mrGbMS.OpenRpm > self.maxPowerRpm - 1 )
				then
		--print(string.format("%4d < %4d (%3.0f * %4d)",self.minRequiredRpm, self.ptoMotorRpmRatio * self.ptoToolRpm, self.ptoMotorRpmRatio, self.ptoToolRpm ))
			self.ptoWarningTimer = nil
		else
			if mt < pt then
			--print(string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ).." @RPM: "..tostring(self.lastRealMotorRpm))
				if self.ptoWarningTimer == nil then
					self.ptoWarningTimer = g_currentMission.time
				end
				local w1 = gearboxMogli.getText( "gearboxMogliTEXT_Stall3", "too much PTO power requested" )
				local w2 = gearboxMogli.getText( "gearboxMogliTEXT_Stall4", "motor stopped because too much PTO power was requested" )
				if      g_currentMission.time > self.ptoWarningTimer + 10000 then
					self.ptoWarningTimer = nil
					gearboxMogliMotor.motorStall( self, string.format("%s (%4.0f Nm < %4.0f Nm)", w2, mt*1000, pt*1000 ), 
																							string.format("%s (%4.0f Nm < %4.0f Nm)", w1, mt*1000, pt*1000 ) )
				elseif  g_currentMission.time > self.ptoWarningTimer + 2000 then
					self.vehicle:mrGbMSetState( "WarningText", string.format("%s (%4.0f Nm < %4.0f Nm)", w1, mt*1000, pt*1000 ))
				end			
			elseif self.ptoWarningTimer ~= nil then
				self.ptoWarningTimer = nil
			end
		end
		
		local maxPtoTorqueRatio = math.min( 1, self.vehicle.mrGbMS.MaxPtoTorqueRatio + math.abs( self.currentSpeed*3.6 ) * self.vehicle.mrGbMS.MaxPtoTorqueRatioInc )
		
		if     torque < 1e-4 then
			self.ptoMotorTorque = 0
			self.ptoSpeedLimit  = nil
		elseif self.noTransmission 
				or self.noTorque then
			self.ptoMotorTorque = math.min( torque, pt )
			self.ptoSpeedLimit  = nil
		elseif maxPtoTorqueRatio <= 0 then
			self.ptoMotorTorque = 0
		else
			self.ptoMotorTorque = math.min( pt, torque )
		end
		
		if self.ptoMotorTorque < pt then
			self.lastMissingTorque = self.lastMissingTorque + pt - self.ptoMotorTorque
		end
		
		if self.ptoMotorTorque > 0 and maxPtoTorqueRatio <  1 then
			local m = maxPtoTorqueRatio 
			if self.nonClampedMotorRpm > self.vehicle.mrGbMS.IdleRpm and math.abs( self.currentSpeed ) > 0.278 then
				m = math.max( m, 1 - self.usedTransTorque / torque )
			end
			self.ptoMotorTorque = math.min( pt, m * torque )
		end
		
		torque             = torque - self.ptoMotorTorque
		
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.ptoTorqueInfo = string.format("%3d %4d %4d %4d %4d",maxPtoTorqueRatio*100,torque*1000,pt*1000,self.ptoMotorTorque*1000,self.lastMissingTorque*1000)
		end
	else
		if self.ptoWarningTimer ~= nil then
			self.ptoWarningTimer = nil
		end
		if self.ptoSpeedLimit   ~= nil then
			self.ptoSpeedLimit   = nil
		end
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.ptoTorqueInfo = ""
		end
	end

-- limit RPM
	local limitA = self.vehicle.mrGbMS.CurMaxRpm
	local limitC = self.vehicle.mrGbMS.CurMaxRpm
	
	if self.vehicle.mrGbML.hydroTargetSpeed ~= nil then
		limitA = self.targetRpm * ( 1 + self.vehicle.mrGbMS.HydrostaticLossFxRpmRatio ) + gearboxMogli.ptoRpmThrottleDiff 
	elseif  not self.noTransmission 
			and not self.noTorque
			and self.vehicle.steeringEnabled then
		if self.vehicle.mrGbMS.EcoMode and limitA > self.vehicle.mrGbMS.MaxTargetRpm then
			limitA = self.vehicle.mrGbMS.MaxTargetRpm 
		end
		if limitA < self.minRequiredRpm then
			limitA = self.minRequiredRpm
		end
	end
	
	limitC = math.min( self:getCurMaxRpm( true ), limitA )
	
	self.vehicle.mrGbML.rpmLimitInfo = ""
	
	if torque < 0 then
		self.lastMissingTorque = self.lastMissingTorque - torque
		torque                 = 0
	elseif self.noTorque then
		torque                 = 0
	elseif acc <= 0 then
		torque                 = 0
	elseif self.noTransmission then
		torque                 = torque * acc
	else
		local applyLimit = ( self.currentSpeed > 0.278 )
	
		nonClampedRpm = math.min( self.nonClampedMotorRpm, self.nonClampedMotorRpmS, self.lastMotorRpm + 10 )
		
		if applyLimit then
			if not self.limitMaxRpm and nonClampedRpm > limitC then
				if self.vehicle.mrGbMG.debugInfo then
					self.vehicle.mrGbML.rpmLimitInfo = string.format( "maxRPM: %4d > %4d => 0 Nm", nonClampedRpm, limitC )
				end
				torque = 0
			elseif nonClampedRpm > limitA + gearboxMogli.ptoRpmThrottleDiff then
				if self.vehicle.mrGbMG.debugInfo then
					self.vehicle.mrGbML.rpmLimitInfo = string.format( "acc: %4d > %4d => 0 Nm", nonClampedRpm, limitA )
				end
				torque = 0
			elseif nonClampedRpm > limitA then
				torque = torque * ( limitA + gearboxMogli.ptoRpmThrottleDiff - nonClampedRpm ) / gearboxMogli.ptoRpmThrottleDiff		
				if self.vehicle.mrGbMG.debugInfo then
					self.vehicle.mrGbML.rpmLimitInfo = string.format( "acc: %4d > %4d => %4d Nm", nonClampedRpm, limitA, torque * 1000 )
				end
			end
			if      self.lastMaxPossibleRpm ~= nil
					and nonClampedRpm >= self.minRequiredRpm
					and nonClampedRpm >  self.lastMaxPossibleRpm then
			--print(string.format("%4d, %4d, %4d => %4d, %4d, %4d",nonClampedRpm,limitA,limitC,self.lastMotorTorque*1000,old*1000,torque*1000))
				if nonClampedRpm > self.lastMaxPossibleRpm + gearboxMogli.speedLimitRpmDiff then
					self.lastMotorTorque = self.lastMotorTorque - torque 
					torque               = 0
					if self.vehicle.mrGbMG.debugInfo then
						self.vehicle.mrGbML.rpmLimitInfo = string.format( "possible: %4d > %4d => 0 Nm", nonClampedRpm, self.lastMaxPossibleRpm )
					end
				else
					local old = torque
					torque = torque * ( self.lastMaxPossibleRpm + gearboxMogli.speedLimitRpmDiff - nonClampedRpm ) / gearboxMogli.speedLimitRpmDiff
					self.lastMotorTorque = self.lastMotorTorque - old + torque
					if self.vehicle.mrGbMG.debugInfo then
						self.vehicle.mrGbML.rpmLimitInfo = string.format( "possible: %4d > %4d => %4d Nm", nonClampedRpm, self.lastMaxPossibleRpm, torque * 1000 )
					end
				end
			end
		end	
		
		torque = self:getTransTorqueAcc( rpm, acc, torque )		
	end
	
	if     self.noTransmission 
			or self.noTorque then
		self.ptoSpeedLimit = nil
		self.ptoSpeedLimitTimer = nil
	elseif  self.lastMissingTorque > gearboxMogli.ptoSpeedLimitRatio * self.lastMotorTorque 
			and self.vehicle.mrGbMS.PtoSpeedLimit 
			and ( not ( self.vehicle.steeringEnabled ) 
				or  self.vehicle.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE
				or  self.vehicle.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_FULL )
			and self.currentSpeed > gearboxMogli.ptoSpeedLimitMin then
		if self.ptoSpeedLimit ~= nil then
			self.ptoSpeedLimit = math.max( self.ptoSpeedLimit - self.tickDt * gearboxMogli.ptoSpeedLimitDec, gearboxMogli.ptoSpeedLimitMin )
		elseif self.ptoSpeedLimitTimer == nil then
			self.ptoSpeedLimitTimer = g_currentMission.time + gearboxMogli.ptoSpeedLimitTime
		elseif self.ptoSpeedLimitTimer < g_currentMission.time then
			self.ptoSpeedLimit = math.max( self.currentSpeed - gearboxMogli.ptoSpeedLimitIni, gearboxMogli.ptoSpeedLimitMin )
		end
	elseif self.ptoSpeedLimit ~= nil then
		if gearboxMogli.ptoSpeedLimitInc > 0 then
			self.ptoSpeedLimit = self.ptoSpeedLimit + self.tickDt * gearboxMogli.ptoSpeedLimitInc
			if self.ptoSpeedLimit > self.currentSpeed + gearboxMogli.ptoSpeedLimitOff then
				self.ptoSpeedLimit = nil
			end
		else
			self.ptoSpeedLimit = nil
		end
		self.ptoSpeedLimitTimer = nil
	end
	
	self.vehicle.mrGbML.limitRpmInfo = ""
	if limitRpm then
		local maxRpm = self.vehicle.mrGbMS.CurMaxRpm
		local rpmFadeOutRange = self.rpmFadeOutRange * gearboxMogliMotor.getMogliGearRatio( self )
		local fadeStartRpm = maxRpm - rpmFadeOutRange

		if fadeStartRpm < self.nonClampedMotorRpm then
			if maxRpm < self.nonClampedMotorRpm then
				brakePedal = math.min((self.nonClampedMotorRpm - maxRpm)/rpmFadeOutRange, 1)
				torque = 0
			else
				torque = torque*math.max((fadeStartRpm - self.nonClampedMotorRpm)/rpmFadeOutRange, 0)
			end
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.limitRpmInfo = string.format( "%4d .. %4d .. %4d => %4d Nm", fadeStartRpm, self.nonClampedMotorRpm, maxRpm, torque * 1000 )
			end
		end
	end
	
	if self.boostTorque == nil or self.boostTorque < self.ptoMotorTorque then 
		self.boostTorque = self.ptoMotorTorque
	end
	
	-- 4 seconds at idle RPM for full torque 
	-- 0 seconds at rated RPM 
	if     self.vehicle.mrGbML.gearShiftingEffect then 
		self.boostTime = 0
	elseif self.usedTransTorque ~= nil and prevTransTorque > self.usedTransTorque + gearboxMogli.eps then 
		self.boostTime = math.max( self.vehicle.mrGbMG.timeUntilFullBoostLmt, self.vehicle.mrGbMS.TimeUntilFullBoost )
	elseif rpm >= self.vehicle.mrGbMS.RatedRpm then 
		self.boostTime = 0
	elseif rpm <= self.vehicle.mrGbMS.IdleRpm  then 
		self.boostTime = self.vehicle.mrGbMS.TimeUntilFullBoost
	else 
		self.boostTime = self.vehicle.mrGbMS.TimeUntilFullBoost * math.sqrt( ( self.vehicle.mrGbMS.RatedRpm - rpm ) / ( self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm ) )
	end 
	
	self.fullTransInputTorque = torque 
	
	if self.boostTime > self.tickDt then 
		-- take 200Nm as base, if the motor has less torque it can accelerate faster		
		-- if we use boostTorque for the delta => we have to double it (quadratic!)
		torque = math.min( torque, self.boostTorque - self.ptoMotorTorque + math.max( 0.2, self.lastMotorTorque ) * self.tickDt / self.boostTime )
	end
	
	self.lastTransInputTorque = torque
	
	self.noTransTorque = math.max( 0, self.lastMotorTorque * self.idleThrottle - self.ptoMotorTorque )

	self.ratioFactorG = 1
	self.ratioFactorR = 1
	local lastHydroRatio = self.hydrostaticOutputRatio
	self.hydrostaticOutputRatio = nil
	local transTorqueFactor = 1
	
	if     torque < 0 then
		self.lastMissingTorque      = self.lastMissingTorque - torque
		transTorqueFactor = 0
		
		if self.hydrostatPressureI ~= nil then
			self.hydrostatPressureI = math.min( self.vehicle.mrGbMS.HydrostaticPressure, self.hydrostatPressureI + self.vehicle.mrGbMS.HydrostaticPressDelta * self.tickDt )
			self.hydrostatPressureO = self.hydrostatPressureI
		end
		
	elseif self.noTransmission then
		self.noTransTorque          = math.max( self.noTransTorque, torque ) * self.vehicle.mrGbMG.idleFuelTorqueRatio
		transTorqueFactor = 0

		if self.hydrostatPressureI ~= nil then
			self.hydrostatPressureI = math.min( self.vehicle.mrGbMS.HydrostaticPressure, self.hydrostatPressureI + self.vehicle.mrGbMS.HydrostaticPressDelta * self.tickDt )
			self.hydrostatPressureO = self.hydrostatPressureI
		end
		
	elseif self.vehicle.mrGbMS.HydrostaticCoupling ~= nil then
		local Mm = torque 		
		local Pi, Po, Mi, Mo, Mf, Mw = 0, 0, 0, 0, 0, 0
		local h  = self.hydrostaticFactor
		
		local hc = self.vehicle.mrGbMS.HydrostaticCoupling
		if self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].hydrostaticCoupling ~= nil then
			hc = self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].hydrostaticCoupling
		end
		
		lastVolP = self.hydrostatVolumePump
		lastVolM = self.hydrostatVolumeMotor
		self.hydrostatVolumePump  = self.vehicle.mrGbMS.HydrostaticVolumePump  * self.vehicle.mrGbMS.HydroInputRPMRatio
		self.hydrostatVolumeMotor = self.vehicle.mrGbMS.HydrostaticVolumeMotor * self.vehicle.mrGbMS.HydroOutputRPMRatio
		
		if self.hydrostatPressureI == nil then
			self.hydrostatPressureI = self.vehicle.mrGbMS.HydrostaticPressure
			lastVolP = self.hydrostatVolumePump
			lastVolM = self.hydrostatVolumeMotor
		end
		
		self.hydrostaticOutputRatio = 1
				
		local loss      = self.vehicle.mrGbMS.HydroPumpMotorEff
		local effFactor = loss^(-2)
		
		if     self.rawTransTorque == nil 
				or lastHydroRatio      == nil
				or lastVolM            <= gearboxMogli.eps then
			self.hydrostatPressureO = 0
		elseif hc == "InputA" or hc == "InputB" then
		elseif prevTransTorque > self.rawTransTorque then
			self.hydrostatPressureO = lastHydroRatio * ( prevTransTorque - self.rawTransTorque ) * loss * 20000 * math.pi / lastVolM
		else
			self.hydrostatPressureO = 0
		end
		
		local Ni, No = rpm, rpm
			
		if     hc == "Output" then	
			if ( self.hydrostatVolumePump + effFactor * self.hydrostatVolumeMotor ) * h < self.hydrostatVolumePump then
				self.hydrostatVolumePump  = math.max( 0, self.hydrostatVolumeMotor * effFactor * h / ( 1 - h ) )
			else
				self.hydrostatVolumeMotor = self.hydrostatVolumePump  * ( 1 - h ) / ( h * effFactor )
			end
			
			Mi = Mm
			Mf = Mm
			Po = self.vehicle.mrGbMS.HydrostaticPressure
			
			Ni = No * self.hydrostatVolumeMotor / self.hydrostatVolumePump
		elseif hc == "InputA" or hc == "InputB" then
		
			local fr = 1	
			if hc == "InputB" and self.vehicle.mrGbMS.CurrentGear ~= 1 then
				fr = self.vehicle.mrGbMS.Gears[1].speed / self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].speed
			end
			
			if self.hydrostaticFactor < 1 then
				loss = 1 / loss			
				h = math.max( (self.hydrostaticFactor-1) * fr / effFactor, -1 )
			else
				h = math.min( (self.hydrostaticFactor-1) * fr * effFactor, 1 )
			end
		
			self.hydrostatVolumePump  = self.hydrostatVolumePump * h
			self.hydrostatVolumeMotor = self.hydrostatVolumeMotor * fr
			Mi = Mm
				
			local Vp = self.hydrostatVolumePump + self.hydrostatVolumeMotor * loss * loss / self.vehicle.mrGbMS.TransmissionEfficiency
			if Vp > gearboxMogli.eps then
				Po = Utils.clamp( Mm * 20000 * math.pi / Vp, 0, self.vehicle.mrGbMS.HydrostaticPressure )
			else
				Po = self.vehicle.mrGbMS.HydrostaticPressure
			end
			No = Ni * ( 1 + self.hydrostatVolumePump / self.hydrostatVolumeMotor )
			
		else
			h = h * effFactor
			if h < 1 then
				self.hydrostatVolumePump  = math.max( 0, self.hydrostatVolumePump  * h )
			else
				self.hydrostatVolumeMotor = self.hydrostatVolumeMotor / h
			end
			Mi = Mm	
			Po = self.vehicle.mrGbMS.HydrostaticPressure
			No = Ni * self.hydrostatVolumePump / self.hydrostatVolumeMotor
		end
		
		if math.abs( self.hydrostatVolumePump ) > gearboxMogli.eps then
			Pi = Utils.clamp( Mi * loss * 20000 * math.pi / math.abs( self.hydrostatVolumePump ), self.hydrostatPressureO, self.vehicle.mrGbMS.HydrostaticPressure )
		else
			Pi = self.vehicle.mrGbMS.HydrostaticPressure
		end
				
		self.hydrostatPressureI = self.hydrostatPressureI + Utils.clamp( self.vehicle.mrGbML.smoothFast * ( Pi - self.hydrostatPressureI ),
																																		-self.vehicle.mrGbMS.HydrostaticPressDelta * self.tickDt,
																																		self.vehicle.mrGbMS.HydrostaticPressDelta * self.tickDt )
	--Pi = self.hydrostatPressureI
		if Po > Pi then
			Po = Pi
		end
		self.hydrostatPressureO = Pi-Po
		Mo = loss * Po * self.hydrostatVolumeMotor / ( 20000 * math.pi )
	
		if hc == "Output" then
			Mw = self.vehicle.mrGbMS.TransmissionEfficiency * ( Mo + Mf )
			if     Mf < gearboxMogli.eps then
				self.hydrostaticOutputRatio = 1
			elseif Mw > gearboxMogli.eps then
				self.hydrostaticOutputRatio = Mo / Mw
			end
			if self.hydrostatVolumePump < 0 then
				self.hydrostaticOutputRatio = -self.hydrostaticOutputRatio
			end
		elseif hc == "InputA" or hc == "InputB" then
			Mi = Po * self.hydrostatVolumePump / ( 20000 * math.pi )
			Mf = Mm - Mi
			--Mw, Mo and t * Mf are identical Mm = Mf + Mi => Mf = Mm - Mi and Mw = t * Mf => Mw = t * ( Mm - Mi )
			if     h < gearboxMogli.eps then
			-- force is going backwards
				Mw = self.vehicle.mrGbMS.TransmissionEfficiency * Mf
			elseif h > gearboxMogli.eps then
			-- the smaller force wins
				Mw = math.min( self.vehicle.mrGbMS.TransmissionEfficiency * Mf, Mo )
			else
			-- hydrostatic drive is locked
				Mw = self.vehicle.mrGbMS.TransmissionEfficiency * Mm
			end
		else 
			Mw = Mo
		end		
	
		if     self.noTransmission 
				or self.noTorque 
				or torque <= 0  then
			transTorqueFactor = 1 / math.max( gearboxMogli.minHydrostaticFactor, self.hydrostaticFactor )
			torque = 0
		elseif Mw < 0 then
			brakeForce = brakeForce - Mw
			transTorqueFactor = 0
		elseif torque > gearboxMogli.eps then
			transTorqueFactor = Mw / torque 
		else
			transTorqueFactor = 1 / math.max( gearboxMogli.minHydrostaticFactor, self.hydrostaticFactor )
			torque = Mw / transTorqueFactor
		end
		
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.hydroPumpInfo = string.format("Torque: Mi: %4.0f Mf: %4.0f (%4.0f, %3.0f%%)\nVi: %4.0f Pi: %4.0f Ni: %4.0f\nMo: %4.0f Vo: %4.0f Po: %4.0f No: %4.0f h: %5.3f\n=> %4.0f (%4.0f) => %5.1f%%, %5.1f%%", 
														Mi*1000,
														Mf*1000,
														Mm*1000,
														acc*100,
														self.hydrostatVolumePump,
														Pi,
														Ni,
														Mo*1000,
														self.hydrostatVolumeMotor,
														Po,
														No,
														self.hydrostaticFactor,
														Mw*1000,
														Mw-self.hydrostaticFactor*Mm,
														transTorqueFactor*100,
														self.hydrostaticFactor*transTorqueFactor*100)
		end
	elseif torque > 0 then
					
		local e = self.vehicle.mrGbMG.transmissionEfficiency
		
		if self.vehicle.mrGbMS.Hydrostatic then
			e = self:getHydroEff( self.hydrostaticFactor )
		else
			e = self.vehicle.mrGbMS.TransmissionEfficiency
		end

		if self.noTransmission then
			transTorqueFactor = 0
		elseif self.clutchPercent < gearboxMogli.eps then
			transTorqueFactor = 0
		elseif self.clutchPercent > 1 - gearboxMogli.eps then
			transTorqueFactor = e
		elseif self.vehicle.mrGbMS.ClutchEfficiencyInc < gearboxMogli.eps then
			transTorqueFactor = self.vehicle.mrGbMS.ClutchEfficiency
		elseif self.clutchPercent < self.vehicle.mrGbMS.MinClutchPercent + gearboxMogli.eps then
			transTorqueFactor = self.vehicle.mrGbMS.ClutchEfficiency
		elseif self.clutchPercent > self.vehicle.mrGbMS.MaxClutchPercent - gearboxMogli.eps then
			transTorqueFactor = math.min( self.vehicle.mrGbMS.ClutchEfficiency + self.vehicle.mrGbMS.ClutchEfficiencyInc, e )
		else
			local f = ( self.clutchPercent - self.vehicle.mrGbMS.MinClutchPercent ) / ( self.vehicle.mrGbMS.MaxClutchPercent - self.vehicle.mrGbMS.MinClutchPercent )
			transTorqueFactor = math.min( self.vehicle.mrGbMS.ClutchEfficiency + f * self.vehicle.mrGbMS.ClutchEfficiencyInc, e )
		end
	end
	
	local dLMiddle = false
	local dLFront  = false 
	local dLBack   = false 
	if self.vehicle.mrGbMS.ModifyDifferentials > 0 then
		dLMiddle = self.vehicle:mrGbMGetDiffLockMiddle()
		dLFront  = self.vehicle:mrGbMGetDiffLockFront()
		dLBack   = self.vehicle:mrGbMGetDiffLockBack()
	elseif  self.vehicle.driveControl                        ~= nil
			and self.vehicle.driveControl.fourWDandDifferentials ~= nil
			and not ( self.vehicle.driveControl.fourWDandDifferentials.isSurpressed ) then
		dLMiddle = self.vehicle.driveControl.fourWDandDifferentials.fourWheelSet
		dLFront  = self.vehicle.driveControl.fourWDandDifferentials.diffLockFrontSet
		dLBack   = self.vehicle.driveControl.fourWDandDifferentials.diffLockBackSet
	end
	
	if dLMiddle then transTorqueFactor = transTorqueFactor * 0.98 end
	if dLFront  then transTorqueFactor = transTorqueFactor * 0.96 end
	if dLBack   then transTorqueFactor = transTorqueFactor * 0.94 end
		
	torque = torque * math.min( transTorqueFactor, self.vehicle.mrGbMS.TransmissionEfficiency )
	
	local lastWithTrans = self.lastWithTrans
	self.lastWithTrans  = nil
	
	if     self.noTransmission
			or not ( self.vehicle.isMotorStarted ) then
		self.ratioFactorR  = nil
		
		if lastWithTrans == nil then
			self.lastWithTrans = g_currentMission.time
		elseif g_currentMission.time > lastWithTrans + 2000 then
			self.lastGearRatio = nil
			self.lastHydroInvF = nil
		end
		
	elseif self.vehicle.mrGbMS.Hydrostatic then

		local r = self:getMogliGearRatio()
	
		if      self.hydrostaticFactor < gearboxMogli.minHydrostaticFactor then
			if self.vehicle.mrGbMS.ReverseActive then 
				self.lastGearRatio = -self.maxHydroGearRatio
			else
				self.lastGearRatio =  self.maxHydroGearRatio
			end
		end

		if self.vehicle.mrGbMS.HydrostaticCoupling ~= nil then
			if transTorqueFactor > self.vehicle.mrGbMS.TransmissionEfficiency then
				self.ratioFactorG = math.min( transTorqueFactor / self.vehicle.mrGbMS.TransmissionEfficiency, self.maxHydroGearRatio / r )
				transTorqueFactor = self.vehicle.mrGbMS.TransmissionEfficiency 
			else
				self.ratioFactorG = 1
			end
		elseif self.maxHydroGearRatio * self.hydrostaticFactor < r then
			self.ratioFactorG = math.min( self.vehicle.mrGbMS.HydrostaticMaxTorqueFactor, self.maxHydroGearRatio / r )
		else
			self.ratioFactorG = math.min( self.vehicle.mrGbMS.HydrostaticMaxTorqueFactor, 1 / self.hydrostaticFactor )
		end
		
		local g = self:getLimitedGearRatio( r * self.ratioFactorG, false )
		if self.vehicle.mrGbMG.smoothGearRatio and self.lastGearRatio ~= nil then
			local l = self:getLimitedGearRatio( math.abs( self.lastGearRatio ), false )
			if self.lastGearRatio >= gearboxMogli.minGearRatio then
				if g > l + 1 or g < l - 1 then
					local i1 = 1 / g
					local i2 = 1 / l
					g = self:getLimitedGearRatio( 1 / ( i2 + self.vehicle.mrGbML.smoothFast * ( i1 - i2 ) ), false )
				end
			--self.ratioFactorG = g / r
			end
		end
		self.ratioFactorG = g / r
		
		if self.vehicle.mrGbMS.ReverseActive then 
			self.gearRatio = -g
		else
			self.gearRatio =  g
		end
		self.lastGearRatio = self.gearRatio
		
		if self.ratioFactorG * self.hydrostaticFactor * gearboxMogli.maxRatioFactorR < 1 then
			self.ratioFactorR = gearboxMogli.maxRatioFactorR
		else
			self.ratioFactorR = 1 / ( self.ratioFactorG * self.hydrostaticFactor )
		end
		
		local f = 1
		
		if      torque < gearboxMogli.eps then
		elseif  self.vehicle.mrGbML.DirectionChangeTime <= g_currentMission.time and g_currentMission.time < self.vehicle.mrGbML.DirectionChangeTime + 1000 then
			f = 1 + ( g_currentMission.time - self.vehicle.mrGbML.DirectionChangeTime ) * 0.002
			if self.ratioFactorR ~= nil then
				f = math.min( f, self.ratioFactorR )
			end
		elseif  self.ratioFactorR == nil  then
			f = gearboxMogli.maxRatioFactorR
		elseif  self.ratioFactorR < 0.999 or self.ratioFactorR > 1.001 then
			f = self.ratioFactorR
		end
		
		if self.lastHydroInvF == nil then
			self.lastHydroInvF = 1
		end
		self.lastHydroInvF = self.lastHydroInvF + self.vehicle.mrGbML.smoothSlow * ( 1 / f - self.lastHydroInvF )
		f = 1 / self.lastHydroInvF
		if self.ratioFactorR ~= nil then
			f = math.min( f, self.ratioFactorR )
		end
		
		torque = math.min( torque * f, torque * self.vehicle.mrGbMS.HydrostaticMaxTorqueFactor / self.ratioFactorG )
		
	elseif  self.vehicle.mrGbMS.TorqueConverter 
			and ( self.vehicle.mrGbMG.smoothGearRatioTC or self.autoClutchPercent < 1 ) then
		local t = math.min( 1 / Utils.clamp( self.clutchRpm / self:getMotorRpm( self.autoClutchPercent ), gearboxMogli.eps, 1 ), self.vehicle.mrGbMS.TorqueConverterFactor )
		local r = self:getMogliGearRatio()
		
		if self.vehicle.mrGbMG.smoothGearRatioTC then
			if r < gearboxMogli.eps then
				self.lastGearRatio = r * math.max( 1, t )
				self.ratioFactorG  = math.max( 1, t )
			elseif self.lastGearRatio == nil then
				self.lastGearRatio = r
				self.ratioFactorG  = 1
			else
				local g = r * math.max( 1, t )
				local i1 = 1 / g
				local i2 = 1 / self.lastGearRatio
				self.lastGearRatio = self:getLimitedGearRatio( 1 / ( i2 + self.vehicle.mrGbML.smoothMedium * ( i1 - i2 ) ), false )
				self.ratioFactorG  = self.lastGearRatio / r
				if self.ratioFactorG < 1 then
					self.lastGearRatio = r
					self.ratioFactorG  = 1
				end
			end
		else
			self.ratioFactorG = math.max( 1, t )
		end		
		-- clutch percentage will be applied additionally => undo ratioFactorG in updateMotorRpm 		
		self.ratioFactorR = 1 / self.ratioFactorG
		torque            = torque * t / self.ratioFactorG
	end
	
	if self.lastTransInputTorque <= gearboxMogli.eps then
		self.torqueMultiplication = 1 / self.vehicle.mrGbMS.TransmissionEfficiency
	elseif torque > gearboxMogli.eps then
		self.torqueMultiplication = self.lastTransInputTorque / torque
	end
	
	if self.lastTransInputTorque < gearboxMogli.eps then
		self.transmissionEfficiency = self.vehicle.mrGbMS.TransmissionEfficiency
	elseif torque       < gearboxMogli.eps then
		self.transmissionEfficiency = 0
	else
		local h = nil
		
		if not ( self.vehicle.mrGbMS.Hydrostatic ) then
			h = 1
		else
			h = self.hydrostaticFactor * self.ratioFactorG
		end

		self.transmissionEfficiency = h * torque / self.lastTransInputTorque
	end
	
	--**********************************************************************************************************		
	-- adjust speed of front wheels
	--**********************************************************************************************************		
	if      self.vehicle:mrGbMGetModifyDifferentials() 
			and self.vehicle.mrGbMS.TorqueRatioMiddle       > -0.01
			and self.vehicle:mrGbMGetDiffLockMiddle()
			and self.vehicle.lastSpeedReal * self.wheelSlipFactor > 0.000544
			and self.vehicle.mrGbMS.SpeedRatioMiddleLocked ~= nil
			and self.vehicle.mrGbMS.SpeedRatioMiddleLocked ~= 1 then 
		local f = math.min( self.vehicle.mrGbMS.SpeedRatioMiddleLocked, 1 / self.vehicle.mrGbMS.SpeedRatioMiddleLocked )
		self.ratioFactorG = self.ratioFactorG * f 
	end 
	
--local smoothFactor = self.vehicle.mrGbML.smoothLittle
--if     self.noTransmission
--		or self.noTorque 
--		or self.vehicle.mrGbMS.Hydrostatic then 
--	smoothFactor = 1 
--elseif  self.clutchPercent < 0.999
--		and not ( self.noTransmission
--					or self.noTorque 
--					or self.vehicle.mrGbMS.Hydrostatic
--					or self.vehicle.mrGbMS.TorqueConverter ) then 
--	smoothFactor = smoothFactor * self.clutchPercent + ( 1 - self.clutchPercent ) * self.vehicle.mrGbML.smoothSlow
--end 
--if smoothFactor < 1 and prevTransTorque < torque then 
--	torque = torque, prevTransTorque + smoothFactor * ( torque - prevTransTorque )
--end 

	self.lastTransTorque        = torque
	
	--**********************************************************************************************************		
	-- motor brake force
	--**********************************************************************************************************		
	if self.noTransmission then
		self.lastBrakeForce = 0
		brakeForce          = 0
		if self.vehicle.mrGbMG.reduceMOINeutral or not ( self.vehicle.mrGbMS.HydrostaticLaunch ) then
			self.moiFactor    = 0
		else
			self.moiFactor    = 1
		end
	else
		local t0 = self.lastMotorTorque
		local r0 = math.max( self.maxMaxPowerRpm, self.vehicle.mrGbMS.RatedRpm )
		local r1 = self.nonClampedMotorRpm
		if     type( self.nonClampedMotorRpm ) ~= "number" then
			r1 = self.vehicle.mrGbMS.IdleRpm
		elseif self.nonClampedMotorRpm > self.vehicle.mrGbMS.CurMaxRpm then
			r1 = self.vehicle.mrGbMS.CurMaxRpm
		end
		if r1 > r0 then
			t0 = math.max( t0, self.torqueCurve:get( r0 ) )
		end
		local a0 = acc
		if r1 > limitC + gearboxMogli.eps then
			a0 = math.min( a0, ( limitC + gearboxMogli.brakeForceLimitRpm - r1 ) / gearboxMogli.brakeForceLimitRpm )
		end
		
		if     r1 <= self.vehicle.mrGbMS.IdleRpm
				or self.vehicle.mrGbMS.BrakeForceRatio <= 0 then
			brakeForce = 0
		else
			if self.brakeForceRatio > 0 then
				brakeForce = self.brakeForceRatio * ( r1 - self.vehicle.mrGbMS.IdleRpm ) 
			else
				brakeForce = self.vehicle.mrGbMS.BrakeForceRatio
			end
			
			if     self.noTorque 
					or acc <= 0
					or r1  >= limitC + gearboxMogli.brakeForceLimitRpm then
				brakeForce = brakeForce * t0
			elseif a0 <= 0 then
				brakeForce = brakeForce * t0
		--elseif a0 >= 0.8 then
		--	brakeForce = 0
			else
				brakeForce = brakeForce * ( t0 - 1.25 * a0 * self.lastMotorTorque )
			end
		end
		self.lastBrakeForce = math.max( 0, self.lastBrakeForce + self.vehicle.mrGbML.smoothFast * ( brakeForce - self.lastBrakeForce ) )
		brakeForce          = self.lastBrakeForce
		
	--**********************************************************************************************************		
		self.moiFactor = 1
		
		self.vehicle.mrGbML.moiFactorInfo = "default"
		
		if      self.vehicle.mrGbMG.reduceMOILowRatio 
				and self.ratioFactorR ~= nil 
				and self.ratioFactorR  > 1 then
			self.moiFactor = math.min( self.moiFactor, 1 / self.ratioFactorR )
		end
		if      self.vehicle.mrGbMG.reduceMOIClutchLimit ~= nil 
				and self.vehicle.mrGbMG.reduceMOIClutchLimit > 0.01
				and not ( self.vehicle.mrGbMS.HydrostaticLaunch ) 
				and self.clutchPercent < self.vehicle.mrGbMG.reduceMOIClutchLimit - gearboxMogli.eps then
			if self.vehicle.mrGbMG.reduceMOIClutchLimit >= 1 then
				self.moiFactor = math.min( self.moiFactor, self.clutchPercent )
			else
				self.moiFactor = math.min( self.moiFactor, self.clutchPercent / self.vehicle.mrGbMG.reduceMOIClutchLimit )
			end
		end
		if      self.vehicle.mrGbMG.reduceMOILowSpeed 
				and -1.5 < self.currentSpeed and self.currentSpeed < 1.5 then
			self.moiFactor = math.min( self.moiFactor, 0.250 + 0.5 * math.abs( self.vehicle.lastSpeedReal ) )
		end
	end
	
	return torque, brakePedal, brakeForce
end

--**********************************************************************************************************	
-- gearboxMogliMotor:updateMotorRpm
--**********************************************************************************************************	
function gearboxMogliMotor:updateMotorRpm( dt )
-- do nothing
end
function gearboxMogliMotor:mrGbMUpdateMotorRpm( dt )
	local vehicle = self.vehicle
	
	
-- currentSpeed	
	local lastSpeed              = self.currentSpeed
	
	if     vehicle.components[1]      == nil 
			or vehicle.components[1].node == nil then 
		self.currentSpeedVector = nil
		if     self.vehicle.lastSpeedReal == nil 
				or self.vehicle.movingDirection == nil then
			self.currentSpeed          = 0
		elseif self.vehicle.movingDirection < 0 then	
			self.currentSpeed          = -self.vehicle.lastSpeedReal
		else 
			self.currentSpeed          =  self.vehicle.lastSpeedReal
		end
	else 
		local vx, vy, vz = worldDirectionToLocal(vehicle.components[1].node, getLinearVelocity(vehicle.components[1].node))
		if self.currentSpeedVector == nil then
			self.currentSpeedVector    = { x=vx, y=vy, z=vz }
		else
			self.currentSpeedVector.x  = self.currentSpeedVector.x + self.vehicle.mrGbML.smoothMedium * ( vx - self.currentSpeedVector.x )
			self.currentSpeedVector.y  = self.currentSpeedVector.y + self.vehicle.mrGbML.smoothMedium * ( vy - self.currentSpeedVector.y )
			self.currentSpeedVector.z  = vz
		end
		if      math.abs( self.currentSpeedVector.z ) < math.max( self.currentSpeedVector.x )
				and math.abs( self.currentSpeedVector.z ) < math.max( self.currentSpeedVector.y ) then
			self.currentSpeed          = 0
		else
			self.currentSpeed          = Utils.vector3Length( self.currentSpeedVector.x, self.currentSpeedVector.y, self.currentSpeedVector.z )
			if self.currentSpeedVector.z < 0 then
				self.currentSpeed        = - self.currentSpeed 
			end
		end
	end
	
	self.tickDt                  = dt
	self.prevNonClampedMotorRpm  = math.min( self.vehicle.mrGbMS.CurMaxRpm, self.nonClampedMotorRpm )
	self.prevMotorRpm            = self.lastRealMotorRpm
	self.prevClutchRpm           = self.clutchRpm
	
	self.nonClampedMotorRpm, self.clutchRpm, self.usedTransTorque = getMotorRotationSpeed(vehicle.motorizedNode)		
	self.nonClampedMotorRpm  = self.nonClampedMotorRpm * gearboxMogli.factor30pi
	self.clutchRpm           = self.clutchRpm          * gearboxMogli.factor30pi
	self.clutchRpmR          = self.clutchRpm
	self.requiredWheelTorque = self.maxMotorTorque*math.abs(self.gearRatio)	
	self.wheelSpeedRpm       = self.currentSpeed * gearboxMogli.factor30pi
	self.wheelSpeedRpmReal   = self.wheelSpeedRpm
	self.rawTransTorque      = self.usedTransTorque
	
	local f = 1
	if      not self.noTransmission 
			and self.ratioFactorR    ~= nil
			and ( self.clutchPercent >= gearboxMogli.minClutchPercent
				 or ( self.vehicle.mrGbMS.TorqueConverter and self.vehicle.mrGbMS.ManualClutch >= gearboxMogli.minClutchPercent ) ) then
		local w = self.clutchRpm
		local s = self.wheelSpeedRpmReal * self.gearRatio
		
		if 2 * w * self.ratioFactorR <= self.vehicle.mrGbMS.CurMinRpm then
			f = 1
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.wheelSlipInfo = string.format( "A: %4d / %4d = %8.4f%%", s, w, f*100 )
			end
		elseif w <= s then
			f = math.max( s / w, gearboxMogli.eps )
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.wheelSlipInfo = string.format( "B: %4d / %4d = %8.4f%%", s, w, f*100 )
			end
		elseif s <= 0 then
			f = gearboxMogli.eps
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.wheelSlipInfo = string.format( "C: %4d / %4d = %8.4f%%", s, w, f*100 )
			end
		else
			f = math.max( s / w, gearboxMogli.eps )
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.wheelSlipInfo = string.format( "D: %4d / %4d = %8.4f%%", s, w, f*100 )
			end
		end
		
	elseif self.vehicle.mrGbMG.debugInfo then
		self.vehicle.mrGbML.wheelSlipInfo = ""
	end		
	self.wheelSlipFactor = Utils.clamp( self.wheelSlipFactor + self.vehicle.mrGbML.smoothFast * ( f - self.wheelSlipFactor ), 0, 1 )
	
	if self.vehicle.mrGbMS.ReverseActive then
		self.currentSpeed          = - self.currentSpeed 
	end
	self.currentAcceleration     = ( self.currentSpeed - lastSpeed ) / dt
	
	local lastTrustClutchRpmTimer = self.trustClutchRpmTimer
	self.trustClutchRpmTimer      = nil
	
	if not ( self.noTransmission ) and math.abs( self.gearRatio ) > gearboxMogli.eps then
		if self.vehicle.mrGbMS.HydrostaticLaunch or gearboxMogli.trustClutchRpmTimer > dt  then
			self.wheelSpeedRpm = self.clutchRpm / self.gearRatio
		else
			local w = self.clutchRpm / self.gearRatio
			if     lastTrustClutchRpmTimer == nil 
					or lastTrustClutchRpmTimer > g_currentMission.time + 1000 then
				self.wheelSpeedRpm = self.wheelSpeedRpmReal / self.wheelSlipFactor 
				self.clutchRpm     = self.wheelSpeedRpm * self.gearRatio
				self.trustClutchRpmTimer = g_currentMission.time + 1000
			else
				self.trustClutchRpmTimer = lastTrustClutchRpmTimer
				if self.trustClutchRpmTimer < g_currentMission.time then	
					self.wheelSpeedRpm = w
				else
					self.wheelSpeedRpm = self.wheelSpeedRpmReal / self.wheelSlipFactor 
					self.wheelSpeedRpm = self.wheelSpeedRpm + 0.001 * ( self.trustClutchRpmTimer - g_currentMission.time ) * ( w - self.wheelSpeedRpm )
					self.clutchRpm     = self.wheelSpeedRpm * self.gearRatio
				end
			end
		end
	else
		self.wheelSpeedRpm = self.wheelSpeedRpmReal / self.wheelSlipFactor 
	end
	
	if self.ratioFactorR ~= nil then	
		self.clutchRpm = self.ratioFactorR * self.clutchRpm          
	else
		self.clutchRpm = self.wheelSpeedRpm * self.gearRatio
	end
	
	if self.vehicle.isMotorStarted and gearboxMogli.debugGearShift then
		if not ( self.noTransmission ) and self.ratioFactorR ~= nil and self.hydrostaticFactor > gearboxMogli.eps then
			print(string.format("A: %4.2f km/h s: %6.3f w: %6.0f n: %4.0f c: %4.0f g: %6.3f fr: %6.3f fg: %6.3f rc: %6.3f rt: %6.3f h: %6.3f r: %6.3f g: %d", 
													self.currentSpeed*3.6,
													self.wheelSpeedRpm,
													self.wheelSpeedRpm * self:getMogliGearRatio() / self.hydrostaticFactor,
													self.nonClampedMotorRpm,
													self.clutchRpm,
													self.gearRatio,
													self.ratioFactorR,
													self.ratioFactorG,
													self.gearRatio*self.ratioFactorR,
													self:getMogliGearRatio() / self.hydrostaticFactor,
													self.hydrostaticFactor,
													self.ratioFactorR*self.ratioFactorG*self.hydrostaticFactor,
													self.vehicle.mrGbMS.CurrentGear ))
		else
			print(string.format("B: %4.2f km/h s: %6.3f t: %4d c: %4d (%4d) n: %4d (%4d)",
													self.currentSpeed*3.6,
													self.wheelSpeedRpm,
													self.throttleRpm,
													self.clutchRpm, self.prevClutchRpm,
													self.nonClampedMotorRpm, self.prevNonClampedMotorRpm))
		end
	end
	
	local lastSmoothRpm = self.smoothRpm 
	self.smoothRpm = nil 
	
	if not ( self.vehicle.isMotorStarted ) then
		if self.prevNonClampedMotorRpm == nil then
			self.nonClampedMotorRpm  = 0
		else
			self.nonClampedMotorRpm  = math.max( 0, self.prevNonClampedMotorRpm -dt * self.vehicle.mrGbMS.RpmDecFactor )
		end
		self.lastRealMotorRpm  = self.nonClampedMotorRpm
		self.lastMotorRpm      = self.nonClampedMotorRpm
		self.prevVariableRpm   = nil
		self.motorLoadOverflow = 0
		self.usedTransTorque   = 0
		self.transmissionEfficiency = nil
	elseif self.vehicle.motorStartDuration > 0 and g_currentMission.time < self.vehicle.motorStartTime then
		self.nonClampedMotorRpm= self.vehicle.mrGbMS.IdleRpm * ( 1 - ( self.vehicle.motorStartTime - g_currentMission.time ) / self.vehicle.motorStartDuration )
		self.lastRealMotorRpm  = self.nonClampedMotorRpm
		self.lastMotorRpm      = self.nonClampedMotorRpm
		self.prevVariableRpm   = nil
		self.motorLoadOverflow = 0
		self.usedTransTorque   = 0
		self.transmissionEfficiency = nil
	else
		self.nonClampedMotorRpm = self:getMotorRpm()
		self.lastRealMotorRpm   = math.max( self.vehicle.mrGbMS.CurMinRpm, math.min( self.nonClampedMotorRpm, self.vehicle.mrGbMS.CurMaxRpm ) )
		
		if     self.nonClampedMotorRpm < gearboxMogli.eps
				or self.torqueMultiplication == nil then
			self.transmissionEfficiency = nil
		else
			self.transmissionEfficiency = self.torqueMultiplication * self.clutchRpm / self.nonClampedMotorRpm
		end
		
		if self.motorLoadOverflow == nil or self.noTransmission or self.ratioFactorR == nil then
			self.motorLoadOverflow   = 0
		end
		
		self.usedTransTorque = self.usedTransTorque + self.motorLoadOverflow
		if self.usedTransTorque > self.lastTransTorque then
			self.motorLoadOverflow = self.usedTransTorque - self.lastTransTorque
			self.usedTransTorque   = self.lastTransTorque
		else
			self.motorLoadOverflow = 0
		end
		
		if self.noTransmission then
			self.usedTransTorque   = self.noTransTorque
		else
			if self.torqueMultiplication ~= nil then
				self.usedTransTorque = self.usedTransTorque * self.torqueMultiplication
			else
				self.usedTransTorque = self.noTransTorque
			end
		
			local kmh = math.abs( self.currentSpeed ) * 3.6
			if     kmh < 1 then
				self.usedTransTorque = math.max( self.usedTransTorque, self.noTransTorque )
			elseif kmh < 2 then
				self.usedTransTorque = math.max( self.usedTransTorque, self.noTransTorque * ( kmh - 1 ) )
			end
			
			
			local m = gearboxMogli.maxManualGearRatio 
			if self.vehicle.mrGbMS.Hydrostatic then	
				m = self.maxHydroGearRatio 
			end		
			if math.abs( self.gearRatio ) >= m - gearboxMogli.eps then
				local minRpmReduced   = Utils.clamp( self.minRequiredRpm * gearboxMogli.rpmReduction, self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.RatedRpm * gearboxMogli.rpmReduction )		
				self.lastRealMotorRpm = math.max( self.lastRealMotorRpm, minRpmReduced )
			end
		end 
		
	--self.lastMotorRpm = Utils.clamp( self.lastMotorRpm + ( self.lastRealMotorRpm - self.lastMotorRpm ) * self.vehicle.mrGbML.smoothMedium,
	--																 self.lastRealMotorRpm - gearboxMogli.motorSmoothRpmDiff,
	--																 self.lastRealMotorRpm + gearboxMogli.motorSmoothRpmDiff )
		local s 
		if     self.noTransmission then 
			s = 1
		elseif self.vehicle.mrGbMS.Hydrostatic then
			s = self.vehicle.mrGbML.smoothMedium
		elseif self.vehicle.mrGbML.gearShiftingEffect and self.clutchPercent > 0.999 then 
			self.smoothRpm = 1
			s = self.smoothRpm
		elseif lastSmoothRpm == nil then 
			self.smoothRpm = self.vehicle.mrGbML.smoothMedium
			s = self.smoothRpm
		else
			if self.clutchPercent > 0.999 then 
				s = math.max( 0.5, self.vehicle.mrGbML.smoothLittle )
			else 
				s = self.vehicle.mrGbML.smoothLittle
			end 
			self.smoothRpm = lastSmoothRpm + ( s - lastSmoothRpm ) * self.vehicle.mrGbML.smoothFast 
			s = self.smoothRpm
		end 
		
		self.lastMotorRpm = self.lastMotorRpm + ( self.lastRealMotorRpm - self.lastMotorRpm ) * s
	end
	
	self.lastAbsDeltaRpm = self.lastAbsDeltaRpm + self.vehicle.mrGbML.smoothMedium * ( math.abs( self.prevNonClampedMotorRpm - self.nonClampedMotorRpm ) - self.lastAbsDeltaRpm )	
	self.deltaMotorRpm   = math.floor( self.lastRealMotorRpm - self.nonClampedMotorRpm + 0.5 )
	
	local c = 0
	if     self.vehicle.mrGbMS.Hydrostatic 
			or self.vehicle:mrGbMGetAutoClutch() then
		c = self.clutchPercent
	else
		c = self.vehicle.mrGbMS.ManualClutch
	end
	local tir = math.max( 0, self.transmissionInputRpm - dt * self.vehicle.mrGbMS.RatedRpm * 0.0001 )
	
	if     c < 0.1 then
		self.transmissionInputRpm = tir
	elseif c > 0.9 then
		self.transmissionInputRpm = self.lastRealMotorRpm
	else
		self.transmissionInputRpm = math.max( self.lastRealMotorRpm, tir )
	end
	
	self.nonClampedMotorRpmS = self.nonClampedMotorRpmS + self.vehicle.mrGbML.smoothFast * ( self.nonClampedMotorRpm - self.nonClampedMotorRpmS )	
	self.lastPtoRpm          = self.lastRealMotorRpm
	self.equalizedMotorRpm   = self.vehicle:mrGbMGetEqualizedRpm( self.lastMotorRpm )
	self.usedTransTorqueS    = self.usedTransTorqueS + self.vehicle.mrGbML.smoothFast * ( self.usedTransTorque - self.usedTransTorqueS )
	
	-- reduce by torque not used; e.g. speed limiter 
	local uttS = math.max( self.usedTransTorque, self.usedTransTorqueS )
	if self.lastTransInputTorque ~= nil and uttS > self.lastTransInputTorque then 
		uttS = self.lastTransInputTorque
	end
	local bt = uttS + self.ptoMotorTorque
	if self.boostTorque == nil or self.boostTorque <= bt or self.vehicle.mrGbMS.TimeUntilNoBoost < self.tickDt then 
		self.boostTorque = bt
	else 
		self.boostTorque = math.max( bt, self.boostTorque - self.lastMotorTorque * self.tickDt / self.vehicle.mrGbMS.TimeUntilNoBoost )
	end 
		
	if self.vehicle.mrGbMS.TimeUntilFullBoost <= 0 then 
		self.boostP = 1
		self.boostS = 1
	else 
		local t2 = self.lastMotorTorque
		if self.prevMotorRpm > self.maxMaxPowerRpm then 
			t2 = math.max( t2, self.currentTorqueCurve:get( self.maxMaxPowerRpm ) )
		end
		if     self.boostTorque > t2 - gearboxMogli.eps then 
			self.boostP = 1
		elseif t2 < gearboxMogli.eps then 
			self.boostP = 0
		else
			self.boostP = self.boostTorque / t2 
		end 
		self.boostS   = self.boostS + self.vehicle.mrGbML.smoothFast * ( self.boostP - self.boostS ) 
	end 
		
	self.usedMotorTorque  = math.min( self.usedTransTorque  + self.ptoMotorTorque, self.lastMotorTorque ) + self.lastMissingTorque
	self.usedMotorTorqueP = math.min( uttS                  + self.ptoMotorTorque, self.lastMotorTorque ) + self.lastMissingTorque
	self.usedMotorTorqueS = math.min( self.usedTransTorqueS + self.ptoMotorTorque, self.lastMotorTorque ) + self.lastMissingTorque
	self.fuelMotorTorque  = math.min( self.usedTransTorque  + self.ptoMotorTorque + self.lastMissingTorque, self.lastMotorTorque )	
	
--if      self.vehicle.mrGbMG.debugInfo 
--		and not self.vehicle.mrGbMS.NeutralActive 
--		and not self.vehicle.mrGbMS.Handbrake 
--		and ( self.vehicle.mrGbML.beforeShiftRpm     ~= nil
--			 or self.vehicle.mrGbML.afterShiftRpm      ~= nil
--			 or g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime + 150
--			 or self.vehicle.mrGbML.gearShiftingEffect
--			 or self.vehicle.mrGbML.gearShiftingNeeded ~= 0 ) then
--	print(string.format("%10s: %4d, %4d, %4d, %4d, %4d, %4d (%4d -> %4d), %4.2f, %s %s %s",
--											self.vehicle:mrGbMGetGearText(),
--											self.nonClampedMotorRpm,
--											math.min( self.maxPossibleRpm, 9999 ),
--											self.clutchRpm,
--											self.tickDt*self.vehicle.mrGbMS.RpmDecFactor,
--											self.lastRealMotorRpm, self.lastMotorRpm,
--											Utils.getNoNil(self.vehicle.mrGbML.beforeShiftRpm,9999), 
--											Utils.getNoNil(self.vehicle.mrGbML.afterShiftRpm,9999), 
--											self.clutchPercent, 
--											tostring(self.vehicle.mrGbML.gearShiftingNeeded),
--											tostring(self.vehicle.mrGbML.gearShiftingEffect),
--											tostring(self.noTransmission)))
--	self.drawDebugLine = true 
--elseif self.drawDebugLine then 
--	print("==============================================================")
--	self.drawDebugLine = false 
--end
end

--**********************************************************************************************************	
-- gearboxMogliMotor:updateGear
--**********************************************************************************************************	
function gearboxMogliMotor:updateGear( acc )
	-- this method is not used here, it is just for convenience 
	if self.vehicle.mrGbMS.ReverseActive then
		acceleration = -acc
	else
		acceleration = acc
	end

	return self:mrGbMUpdateGear( acceleration )
end

--**********************************************************************************************************	
-- gearboxMogliMotor:mrGbMUpdateGear
--**********************************************************************************************************	
function gearboxMogliMotor:mrGbMUpdateGear( accelerationPedalRaw, doHandbrake )

	local accelerationPedal = accelerationPedalRaw
	if     accelerationPedalRaw > 1 then
		accelerationPedal = 1
	elseif accelerationPedalRaw > 0 then
		accelerationPedal = accelerationPedalRaw^self.vehicle.mrGbMG.accThrottleExp
	end
	
	local acceleration = math.max( accelerationPedal, 0 )
	
	self.accP = acceleration
	self.accS = self.accS + Utils.clamp( self.accP - self.accS, -0.000333 * self.tickDt, 0.000333 * self.tickDt )

	if self == nil or self.vehicle == nil then
		local i = 1
		local info 
		print("------------------------------------------------------------------------") 
		while i <= 10 do
			info = debug.getinfo(i) 
			if info == nil then break end
			print(string.format("%i: %s (%i): %s", i, info.short_src, Utils.getNoNil(info.currentline,0), Utils.getNoNil(info.name,"<???>"))) 
			i = i + 1 
		end
		if info ~= nil and info.name ~= nil and info.currentline ~= nil then
			print("...") 
		end
		print("------------------------------------------------------------------------") 
	end
	
	if self.vehicle.mrGbMS.ReverseActive then
		acceleration = -acceleration
	end
	
--**********************************************************************************************************	
-- VehicleMotor.updateGear I
	local requiredWheelTorque = math.huge

	if (0 < acceleration) == (0 < self.gearRatio) then
		requiredWheelTorque = self.requiredWheelTorque
	end

	--local requiredMotorRpm = PowerConsumer.getMaxPtoRpm(self.vehicle)*self.ptoMotorRpmRatio
	local gearRatio          = self:getMogliGearRatio()
	self.lastMaxPossibleRpm  = Utils.getNoNil( self.maxPossibleRpm, self.vehicle.mrGbMS.CurMaxRpm )
	local lastNoTransmission = self.noTransmission
	local lastNoTorque       = self.noTorque 
	self.noTransmission      = false
	self.noTorque            = not ( self.vehicle.isMotorStarted )
	self.maxPossibleRpm      = self.vehicle.mrGbMS.CurMaxRpm
	
--**********************************************************************************************************	

	local currentAbsSpeed    = 3.6 * self.currentSpeed
	
--**********************************************************************************************************	

	self.maxHydroGearRatio   = gearboxMogli.maxHydroGearRatio
	if self.vehicle.mrGbMS.Hydrostatic then
		local r = self:getMogliGearRatio()
		local h = math.max( 0, self.vehicle.mrGbMS.HydrostaticMin, self.vehicle.mrGbMS.HydrostaticStart )
		self.maxHydroGearRatio = math.max( r / self.vehicle.mrGbMS.HydrostaticMax, math.min( r / h, gearboxMogli.maxHydroGearRatio ) )
	end
	
--**********************************************************************************************************	
	-- current RPM and power

	local targetRequiredRpm = self.vehicle.mrGbMS.IdleRpm
	if self.minRequiredRpm == nil or self.minRequiredRpm < self.vehicle.mrGbMS.IdleRpm then
		self.minRequiredRpm   = self.vehicle.mrGbMS.IdleRpm
	end
	
	local constantRpm = false
	
	self.maxTargetRpm = self.vehicle.mrGbMS.MaxTargetRpm
	if self.vehicle.mrGbMS.MaxTarget > 0 then
		self.maxTargetRpm   = self:getThrottleMaxRpm( self.vehicle.mrGbMS.MaxTarget, true )
	end
	self.minTargetRpm = self.vehicle.mrGbMS.MinTargetRpm
	if self.vehicle.mrGbMS.MinTarget > 0 then
		self.minTargetRpm   = math.min( self:getThrottleMaxRpm( self.vehicle.mrGbMS.MinTarget, true ), self.maxTargetRpm )
		if self.minTargetRpm > self.vehicle.mrGbMS.IdleRpm and currentAbsSpeed < 2 then
			targetRequiredRpm = self.vehicle.mrGbMS.IdleRpm + 0.5 * currentAbsSpeed * ( self.minTargetRpm - self.vehicle.mrGbMS.IdleRpm )
		else
			targetRequiredRpm = self.minTargetRpm
		end
	end
	
	local handThrottle = -1
	
	if     self.vehicle:mrGbMGetOnlyHandThrottle()
			or self.vehicle.mrGbMS.HandThrottle > 0.01 then
		handThrottle = self.vehicle.mrGbMS.HandThrottle
	end
	
	local handThrottleRpm = self.vehicle.mrGbMS.IdleRpm 
	if handThrottle >= 0 then
		constantRpm         = true
		handThrottleRpm     = self:getThrottleMaxRpm( handThrottle, true )
		targetRequiredRpm   = math.max( targetRequiredRpm, handThrottleRpm )
	end
	if self.vehicle.mrGbMS.AllAuto then
		handThrottle = -1
	end
	
	local targetRequiredRpm0 = targetRequiredRpm
	
	-- acceleration pedal and speed limit
	local currentSpeedLimit = self.currentSpeedLimit + gearboxMogli.extraSpeedLimitMs
	if self.vehicle.mrGbML.hydroTargetSpeed ~= nil and currentSpeedLimit > self.vehicle.mrGbML.hydroTargetSpeed then
		currentSpeedLimit = self.vehicle.mrGbML.hydroTargetSpeed
	end
	
	if self.ptoSpeedLimit ~= nil and currentSpeedLimit > self.ptoSpeedLimit then
		currentSpeedLimit = self.ptoSpeedLimit
	end
	currentSpeedLimitR  = math.min( self.currentSpeedLimit, currentSpeedLimit-0.001, math.max( currentSpeedLimit - gearboxMogli.kmhTOms, currentSpeedLimit * 0.975 ) )
	currentSpeedLimitD1 = 1 / ( currentSpeedLimit - currentSpeedLimitR )
	
	local prevWheelSpeedRpm = self.absWheelSpeedRpm
	self.absWheelSpeedRpm = self.wheelSpeedRpm
	if self.vehicle.mrGbMS.ReverseActive then 
		self.absWheelSpeedRpm = -self.absWheelSpeedRpm
	end
	
	self.absWheelSpeedRpm   = math.max( self.absWheelSpeedRpm, 0 )	
	self.absWheelSpeedRpmS  = self.absWheelSpeedRpmS + self.vehicle.mrGbML.smoothFast * ( self.absWheelSpeedRpm - self.absWheelSpeedRpmS )
	local deltaRpm          = ( self.absWheelSpeedRpm - prevWheelSpeedRpm ) / self.tickDt         
	self.deltaRpm           = self.deltaRpm + self.vehicle.mrGbML.smoothSlow * ( deltaRpm - self.deltaRpm )
	local currentPower      = self.usedMotorTorque * math.max( self.prevNonClampedMotorRpm, self.vehicle.mrGbMS.IdleRpm )
	local getMaxPower       = ( self.lastMissingTorque > 0 or self.torqueRpmReduxMode ~= nil )
	
	if self.vehicle.mrGbML.gearShiftingNeeded ~= 0 then
		getMaxPower = false
	end
	
	if      not ( getMaxPower or lastNoTransmission or lastNoTorque )
			and self.currentSpeed     < currentSpeedLimitR
			and ( self.vehicle.mrGbMS.TimeUntilFullBoost <= 0 or self.boostP > 0.95 )
		--and g_currentMission.time > self.lastClutchClosedTime + 1000 
			then
		if      self.deltaRpm       < gearboxMogli.autoShiftMaxDeltaRpm 
				and accelerationPedal   > 0.9 
				and self.rawTransTorque > self.lastTransTorque*0.99 then
			getMaxPower = true
		end
		
		if      self.vehicle.steeringEnabled
				and self.vehicle.axisForwardIsAnalog
				and accelerationPedal > 0.97 then
			getMaxPower = true
		end
	end
	
	if self.vehicle.mrGbMG.debugInfo then
		self.vehicle.mrGbML.getMaxPowerInfo = string.format("%s, %4.2f\n%s: %5.2f < %5.2f (%5.2f)\n%s: %6g < %6g\n%s: %4.0f >= %4.0f",
																												tostring(getMaxPower),accelerationPedal,
																												tostring(self.currentSpeed < currentSpeedLimitR), self.currentSpeed*3.6, currentSpeedLimitR*3.6, currentSpeedLimit*3.6,
																												tostring(self.deltaRpm < gearboxMogli.autoShiftMaxDeltaRpm), self.deltaRpm, gearboxMogli.autoShiftMaxDeltaRpm,
																												tostring(self.rawTransTorque > self.lastTransTorque*0.99), self.rawTransTorque*1000, self.lastTransTorque*1000 )
	end
	
	self.ptoMotorRpm    = self.vehicle.mrGbMS.IdleRpm
	self.ptoToolRpm     = PowerConsumer.getMaxPtoRpm( self.vehicle )
	if self.ptoToolRpm == nil or self.ptoToolRpm <= gearboxMogli.eps then
		self.ptoToolRpm = 540
	end	
		
	local pt            = Utils.getNoNil( PowerConsumer.getTotalConsumedPtoTorque( self.vehicle ), 0 )
	local pt0           = pt
	
	if not ( self.vehicle.mrIsMrVehicle ) and self.vehicle.mrGbMS.IsCombine and self.vehicle:getIsTurnedOn() and self.vehicle.mrGbMG.calculateCombinePower then
		local combinePower    = 0
		local combinePowerInc = 0
	
		if self.vehicle.pipeIsUnloading then
			combinePower = combinePower + self.vehicle.mrGbMS.UnloadingPowerConsumption
		end
		
		local sqm = 0
		if self.vehicle:getIsTurnedOn() then
			combinePower  = combinePower    + self.vehicle.mrGbMS.ThreshingPowerConsumption		
			if not ( self.vehicle.isStrawEnabled ) then
				combinePower  = combinePower    + self.vehicle.mrGbMS.ChopperPowerConsumption
			end
		end

		combinePowerInc = combinePowerInc + self.vehicle.mrGbMS.ThreshingPowerConsumptionInc
		if not ( self.vehicle.isStrawEnabled ) then
			combinePowerInc = combinePowerInc + self.vehicle.mrGbMS.ChopperPowerConsumptionInc
		end
		
		if combinePowerInc > 0 then
			combinePower = combinePower + combinePowerInc * gearboxMogli.mrGbMGetCombineLS( self.vehicle )
		end
		
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.combinePowerInfo = string.format("R: %4d, T: %4d, M: %4d, R:%5.3f, P:%4d\n%7.3g, %7.4g, %7.4g (%7.4g) %7.4g",
		                    self.nonClampedMotorRpm,
												self.ptoToolRpm,
												self.minRequiredRpm,
												self.ptoMotorRpmRatio,
												self.ptoToolRpm * self.ptoMotorRpmRatio,
												combinePower,
												combinePower / self.ptoToolRpm,
												combinePower / (self.ptoToolRpm * self.ptoMotorRpmRatio),
												pt0,
												self.ptoToolTorque / self.ptoMotorRpmRatio )
		end 

		pt = combinePower / self.ptoToolRpm
	end
	
	local ptoToolOn = false
	if pt > gearboxMogli.eps then
		ptoToolOn  = true
		self.ptoMotorRpm   = Utils.clamp( self.original.ptoMotorRpmRatio * self.ptoToolRpm, self.vehicle.mrGbMS.MinTargetRpm, self.vehicle.mrGbMS.MaxTargetRpm )
		self.ptoToolTorque = self.ptoToolTorque + self.vehicle.mrGbML.smoothMedium * ( pt - self.ptoToolTorque )
	else
		self.ptoToolTorque = 0
	end
	
	if self.vehicle.mrGbMS.IsCombine and self.vehicle:getIsTurnedOn() then
		ptoToolOn  = true
		
		targetRequiredRpm = self.vehicle.mrGbMS.ThreshingMinRpm
		
		if      not ( self.lastPtoToolOn ) 
				and self.vehicle:mrGbMGetOnlyHandThrottle() 
				and self.vehicle.mrGbMS.MaxTargetRpm > self.vehicle.mrGbMS.IdleRpm then
			local t = ( self.vehicle.mrGbMS.ThreshingMaxRpm - self.vehicle.mrGbMS.IdleRpm ) / ( self.vehicle.mrGbMS.MaxTargetRpm - self.vehicle.mrGbMS.IdleRpm )
			if self.vehicle.mrGbMS.HandThrottle < t then
				self.vehicle:mrGbMSetHandThrottle( t )
				handThrottle    = t
				handThrottleRpm = self.vehicle.mrGbMS.ThreshingMaxRpm
			end
		end
		
		local maxTarget = self.vehicle.mrGbMS.ThreshingMaxRpm
		if handThrottle >= 0 then
			maxTarget = Utils.clamp( handThrottleRpm, self.vehicle.mrGbMS.ThreshingMinRpm, self.vehicle.mrGbMS.ThreshingMaxRpm )
		end

		if     self.vehicle.mrGbML.realAreaPerSecond <= 0 then
			self.ptoMotorRpm = maxTarget 
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.combineInfo = string.format("idle: %4d",self.ptoMotorRpm)
			end
		elseif self.torqueRpmReduxMode ~= nil and self.torqueRpmReduxMode == 2 then
			self.ptoMotorRpm = Utils.clamp( self.maxMaxPowerRpm, self.vehicle.mrGbMS.ThreshingMinRpm, maxTarget ) 
		--self.ptoMotorRpm = Utils.clamp( self.torqueRpmReference-self.torqueRpmReduction, self.vehicle.mrGbMS.ThreshingMinRpm, maxTarget ) 
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.combineInfo = string.format("reduction on: %4d / %4d",self.ptoMotorRpm, self.torqueRpmReference-self.torqueRpmReduction)
			end
		elseif self.vehicle.mrGbMS.ThreshingFullRpm ~= nil and self.vehicle.mrGbMS.ThreshingFullRpm < maxTarget then
			if getMaxPower then				
				self.ptoMotorRpm = self.vehicle.mrGbMS.ThreshingFullRpm
				if self.vehicle.mrGbMG.debugInfo then
					self.vehicle.mrGbML.combineInfo = string.format("full power: %4d",self.ptoMotorRpm)
				end
			else
				local p = self.usedMotorTorque * self.lastMotorRpm
				local q = self.currentMaxPower
				if     p >= q then				
					self.ptoMotorRpm    = math.max( self.ptoMotorRpm, self.vehicle.mrGbMS.ThreshingFullRpm )
				else
				--p = p - 0.5 * self.currentMaxPower
				--q = 0.5 * self.currentMaxPower
					
					local f = 1
					if p < q and q > gearboxMogli.eps then
						f = Utils.clamp( p / q, 0, 1 )
					end
					
					self.ptoMotorRpm = maxTarget + ( self.vehicle.mrGbMS.ThreshingFullRpm - maxTarget ) * f
					
					if self.vehicle.mrGbMG.debugInfo then
						self.vehicle.mrGbML.combineInfo = string.format("adjusted 2: %4d, %3d%% (%6g, %6g)",self.ptoMotorRpm, f*100, p, q)
					end
				end
			end
		elseif getMaxPower then				
			self.ptoMotorRpm = Utils.clamp( self.maxMaxPowerRpm, self.vehicle.mrGbMS.ThreshingMinRpm, maxTarget )
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.combineInfo = string.format("max power: %4d",self.ptoMotorRpm)
			end
		else
			local p = self.usedMotorTorque * self.lastMotorRpm
			self.ptoMotorRpm = Utils.clamp( self.currentPowerCurve:get( p ), self.vehicle.mrGbMS.ThreshingMinRpm, maxTarget )
		end			
	elseif ptoToolOn then
		self.ptoMotorRpm = self.vehicle.mrGbMS.PtoRpm
		if self.vehicle.mrGbMS.EcoMode then
			self.ptoMotorRpm = self.vehicle.mrGbMS.PtoRpmEco
		end
		-- increase PTO RPM for hydrostatic => less torque needed
		if self.vehicle.mrGbMS.Hydrostatic and self.ptoMotorRpm < targetRequiredRpm then
			self.ptoMotorRpm = targetRequiredRpm
		end
		-- reduce PTO RPM in case of hand throttle => more torque needed
		if handThrottle >= 0 and self.ptoMotorRpm > targetRequiredRpm then
			self.ptoMotorRpm = targetRequiredRpm
		end
	end

	if ptoToolOn then
		self.lastPtoToolOn    = true
		targetRequiredRpm     = math.max( targetRequiredRpm, self.ptoMotorRpm )
		if self.vehicle.mrGbMG.increaseRpmForPTO then
			constantRpm         = true
		end
	else
		self.lastPtoToolOn    = nil
	end
	
	self.vehicle:mrGbMSetState( "ConstantRpm", constantRpm )
	
	if self.vehicle.mrIsMrVehicle and type( self.vehicle.mrGetNeededPtoRpmWhenControlled ) == "function" then
		local state, result = pcall( self.vehicle.mrGetNeededPtoRpmWhenControlled, self.vehicle )
		if state and result ~= nil and result > 0 then
			targetRequiredRpm = math.max( targetRequiredRpm, result * self.original.ptoMotorRpmRatio )
		end
	end	
	if      self.vehicle.mrGbMS.ToolIsDirty 
			and lastNoTransmission
			and not ( g_modIsLoaded["FS17_RpmDependentControls"] ) then
		targetRequiredRpm = math.max( targetRequiredRpm, self.vehicle.mrGbMS.HydraulicRpm )
	end
	
	if targetRequiredRpm > self.maxTargetRpm then
		targetRequiredRpm = self.maxTargetRpm
	end
	
	if self.vehicle.mrGbMG.increaseRpmForPTO then
		targetRequiredRpm0 = targetRequiredRpm
	end
	
	local minRpmReduced
	
	if accelerationPedal < 0.1 then
		minRpmReduced = math.max( self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.IdleRpm * gearboxMogli.rpmReduction )
	else
		minRpmReduced = Utils.clamp( targetRequiredRpm0 * gearboxMogli.rpmReduction, 
																 self.vehicle.mrGbMS.CurMinRpm, 
																 self.vehicle.mrGbMS.RatedRpm * gearboxMogli.rpmReduction )		
	end
	if handThrottle >= 0 then
		minRpmReduced = math.max( minRpmReduced, handThrottleRpm - gearboxMogli.ptoRpmThrottleDiff )
	end
	
	self.minRequiredRpm = self.minRequiredRpm + Utils.clamp( targetRequiredRpm0 - self.minRequiredRpm, 
																													-self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, 
																													 self.tickDt * self.vehicle.mrGbMS.RpmIncFactor )
	minRpmReduced       = math.min( minRpmReduced, self.minRequiredRpm )
	
	if ptoToolOn then
		self.ptoMotorRpmRatio = targetRequiredRpm / self.ptoToolRpm
	else
		self.ptoMotorRpmRatio = self.original.ptoMotorRpmRatio
	end
	
	local rp = ( self.ptoMotorTorque + self.lastMissingTorque ) * math.max( self.prevNonClampedMotorRpm, self.vehicle.mrGbMS.IdleRpm )
	if rp < self.currentMaxPower and accelerationPedal > 0 and self.currentSpeed < currentSpeedLimit then
		local f = 0
		if self.currentSpeed < currentSpeedLimitR then
			f = accelerationPedal
		elseif self.currentSpeed < currentSpeedLimit then
			f = math.min( currentSpeedLimitD1 * ( currentSpeedLimit - self.currentSpeed ), accelerationPedal )
		end
		
		rp = rp + f * ( self.currentMaxPower - rp )
	end
	
	if     getMaxPower then
		requestedPower = self.currentMaxPower
	--print(string.format( "max power: %5.2f <-> %5.2f", requestedPower * gearboxMogli.powerFactor0, currentPower * gearboxMogli.powerFactor0)
	elseif self.rawTransTorque < self.lastTransTorque*0.99 then
		requestedPower = math.min( rp, currentPower )
	elseif rp > currentPower then
		if     self.nonClampedMotorRpm > self.lastCurMaxRpm then
			requestedPower = currentPower
		elseif self.nonClampedMotorRpm + 10 > self.lastCurMaxRpm then
			requestedPower = currentPower + Utils.clamp( 0.1 * ( self.lastCurMaxRpm - self.nonClampedMotorRpm ), 0, 1 ) * ( rp - currentPower )
		elseif self.vehicle.mrGbMS.EcoMode then
			requestedPower = math.min( 0.9*rp, 1.11 * currentPower )
		else
			requestedPower = rp
		end
	else
		requestedPower = currentPower
	end

	self.motorLoadP = 0
	
	local motorTorque = self.lastMotorTorque
	if self.lastTransInputTorque ~= nil then 
		motorTorque = 0.5 * ( motorTorque + self.lastTransInputTorque + self.ptoMotorTorque )
	end 


	for i=1,2 do
		if i == 1 then
			ta = "motorLoadP"
			sa = "usedMotorTorqueP"
		else
			ta = "motorLoadS"
			sa = "usedMotorTorqueS"
		end
		
		if     not ( self.vehicle.isMotorStarted ) then
			self[ta] = 0
		elseif self.lastRealMotorRpm >= self.vehicle.mrGbMS.CurMaxRpm or motorTorque < gearboxMogli.eps then
			self[ta] = 0
		else
			self[ta] = self[sa] / motorTorque
		end

		if     self.prevMotorRpm > self.vehicle.mrGbMS.RatedRpm and motorTorque * self.prevMotorRpm  < self.maxRatedTorque * self.vehicle.mrGbMS.RatedRpm then
			self[ta] = 0.2 * self[ta] + 0.8 * self[sa] * self.prevMotorRpm / ( self.maxRatedTorque * self.vehicle.mrGbMS.RatedRpm )
		elseif self.lastMissingTorque > 0 and self[ta] < 1 then
			self[ta] = 1
		elseif lastNoTorque then
			self[ta] = 0
		end
	end

	local mlf
	if     self.motorLoadP < 0.001 then 
		mlf = 0
	elseif self.motorLoadP > 0.999 then 
		mlf = 1
	elseif 0.999 < gearboxMogli.motorLoadExp and gearboxMogli.motorLoadExp < 1.001 then 
		mlf = Utils.clamp( self.motorLoadP, 0, 1 ) 
	else 
		mlf = Utils.clamp( 1 - ( 1 - self.motorLoadP )^gearboxMogli.motorLoadExp, 0, 1 ) 
	end
	
	if     self.vehicle.mrGbML.gearShiftingEffect then 
		mlf = math.max( mlf, accelerationPedal )
		if self.motorLoadFactor ~= nil and self.motorLoadFactor > mlf then 
			mlf = self.motorLoadFactor
		end
	elseif self.vehicle.mrGbML.gearShiftingNeeded == 2 then
		mlf = math.max( mlf, accelerationPedal )
	elseif self.vehicle.mrGbML.gearShiftingNeeded == 1 then 
		mlf = 0
	elseif ( self.vehicle.mrGbML.gearShiftingNeeded > 0 and self.vehicle.mrGbML.doubleClutch == 2 )
			or self.vehicle.mrGbML.gearShiftingNeeded   < 0 
			or ( self.vehicle.mrGbML.NeutralActive and not self.vehicle:mrGbMGetAutoClutch() ) then
		mlf = math.max( mlf, accelerationPedal )
	elseif lastNoTorque then
		mlf = 0
	elseif not getMaxPower then
		mlf = 0.87 * mlf
	end
	
	if      self.lastMotorRpm > self.vehicle.mrGbMS.CurMaxRpm-1 then 
		mlf = 0
	elseif  self.lastMotorRpm > self.maxMaxPowerRpm
			and self.currentTorqueCurve:get( self.lastMotorRpm ) < gearboxMogli.eps then 
		mlf = 0
	end 
	
	local mlfRate = 0.02
	if     lastNoTransmission or lastNoTorque then 
		mlfRate = 0.05
	elseif self.currentSpeed   > currentSpeedLimitR then
		mlfRate = 0.001
	elseif self.lastMotorRpm   > self.vehicle.mrGbMS.MaxTargetRpm then 
		mlfRate = 0.002
	elseif self.lastMotorRpm   > self.maxPowerRpm then 
		mlfRate = 0.01
	elseif self.rawTransTorque < self.lastTransTorque - gearboxMogli.eps then 
		mlfRage = 0.005
	end 
	
	if     self.motorLoadFactor == nil then 
		self.motorLoadFactor = mlf 
	elseif mlf < self.motorLoadFactor then 
		self.motorLoadFactor = math.max( mlf, self.motorLoadFactor - mlfRate * self.tickDt )
	elseif mlf > self.motorLoadFactor then 
		self.motorLoadFactor = math.min( mlf, self.motorLoadFactor + mlfRate * self.tickDt )
	end
	
	self.motorLoad = math.max( 0, self.maxMotorTorque * self.motorLoadFactor - pt0 / self.ptoMotorRpmRatio )
	
	local wheelLoad    = 0
--local acceleration = 0
	if not ( lastNoTransmission ) then
		wheelLoad        = math.abs( self.usedTransTorque * self.gearRatio	)
	end
	if self.wheelLoadS == nil then
		self.wheelLoadS  = wheelLoad
	else
		self.wheelLoadS  = self.wheelLoadS + self.vehicle.mrGbML.smoothFast * ( wheelLoad - self.wheelLoadS )		
  end		
	
	local targetRpm = self.minRequiredRpm
	local minTarget = minRpmReduced	
	local lowFactor = 0
	
	if self.motorLoadS > 0.95 then
		if self.lastHighLoadTime == nil then
			self.lastHighLoadTime = g_currentMission.time
		elseif g_currentMission.time >= self.lastHighLoadTime + 4000 then
			lowFactor = 1
		else
			lowFactor = 0.00025 * ( g_currentMission.time - self.lastHighLoadTime )
		end
	else
		self.lastHighLoadTime = nil
	end
	
	if self.vehicle.mrGbMS.ConstantRpm or ptoToolOn then
		if     self.vehicle.mrGbMS.IsCombine   then
			targetRpm = targetRequiredRpm
		elseif self.vehicle.mrGbMS.Hydrostatic then
			-- PTO or hand throttle 
			targetRpm = targetRequiredRpm
			minTarget = Utils.clamp( self.maxPowerRpm, minRpmReduced, self.minRequiredRpm )
			if minTarget < targetRpm and lowFactor > 0 then
				targetRpm = targetRpm + lowFactor * ( minTarget - targetRpm )
			end
		else
		-- reduce target RPM to accelerate and increase to brake 
			targetRpm = Utils.clamp( targetRequiredRpm - accelerationPedal * gearboxMogli.ptoRpmThrottleDiff, minRpmReduced, self.maxTargetRpm )
		end			
	else
		if     lastNoTransmission or lastNoTorque then
		-- no transmission 
			targetRpm = math.max( self.minRequiredRpm, self.lastMotorRpm )
		elseif accelerationPedal <= -0.5 -gearboxMogli.accDeadZone then
		-- motor brake
			targetRpm = self.vehicle.mrGbMS.RatedRpm
		elseif accelerationPedal < -gearboxMogli.accDeadZone then
		-- motor brake
			targetRpm = self.vehicle.mrGbMS.IdleRpm - 2 * ( accelerationPedal + gearboxMogli.accDeadZone ) * ( self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm )
		else
			if getMaxPower then
			-- full power
				if gearboxMogli.maxMaxPowerRatio < 1 then
					targetRpm = self.maxPowerRpm
				else
					targetRpm = self.maxMaxPowerRpm 
				end
			elseif gearboxMogli.maxMaxPowerRatio < 1 and requestedPower < gearboxMogli.maxMaxPowerRatio * self.currentMaxPower then
			-- increase RPM => target motor load < 90 %
				targetRpm = self.currentPowerCurve:get( requestedPower / gearboxMogli.maxMaxPowerRatio )	
			else
				targetRpm = self.currentPowerCurve:get( requestedPower )	
			end
			targetRpm = Utils.clamp( targetRpm, self.minRequiredRpm, self.maxTargetRpm )
		end
		
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.targetRpmInfo = string.format("a: %5.3f, %s, %6g (%6g) => %4d",
																					accelerationPedal,
																					tostring(getMaxPower),
																					requestedPower,
																					self.currentMaxPower,
																					targetRpm )
		end	

		if minRpmReduced < self.minTargetRpm then
			if     lastNoTransmission or lastNoTorque then
				minTarget = minRpmReduced
			elseif accelerationPedal > gearboxMogli.accDeadZone then
				minTarget = self.minTargetRpm
			elseif currentAbsSpeed < gearboxMogli.eps then
				minTarget = minRpmReduced
			elseif currentAbsSpeed < 2 then
				minTarget = minRpmReduced + ( self.minTargetRpm - minRpmReduced ) * currentAbsSpeed * 0.5 
			else
				minTarget = self.minTargetRpm
			end
		end
		if targetRpm < minTarget then
			targetRpm = minTarget	
		elseif targetRpm > self.maxTargetRpm then
			targetRpm = self.maxTargetRpm
		elseif self.vehicle.cruiseControl.state ~= 0 
				or not self.vehicle.steeringEnabled then
		-- nothing
		elseif gearboxMogli.eps < accelerationPedal and accelerationPedal < self.vehicle.mrGbMS.MaxRpmThrottle then
			local tr = self:getThrottleMaxRpm( accelerationPedal / self.vehicle.mrGbMS.MaxRpmThrottle )
			if     tr < minTarget then
				targetRpm = minTarget 
			elseif tr > targetRpm then
				targetRpm = tr
			end
		end
	end

--**********************************************************************************************************		
-- reduce RPM if more power than available is requested 
	local reductionMinRpm = self.vehicle.mrGbMS.CurMinRpm 
	local maxPowerReduced = math.min( self.vehicle.mrGbMS.RatedRpm * gearboxMogli.rpmReduction, math.max( self.minMaxPowerRpm, self.maxPowerRpm * gearboxMogli.rpmReduction ) )

	if     self.currentSpeed >= currentSpeedLimit then
		maxPowerReduced = self.maxMaxPowerRpm
	elseif self.currentSpeed > currentSpeedLimitR then
		maxPowerReduced = maxPowerReduced + currentSpeedLimitD1 * ( currentSpeedLimit - self.currentSpeed ) * ( self.maxMaxPowerRpm - maxPowerReduced )
	end
	
	if     self.noTransmission then
	-- keep it
	elseif currentAbsSpeed < 1 then
		reductionMinRpm = maxPowerReduced
	elseif currentAbsSpeed < 2 then
		reductionMinRpm = maxPowerReduced + ( currentAbsSpeed - 1 ) * ( self.vehicle.mrGbMS.CurMinRpm - maxPowerReduced)
	end
	if self.vehicle.mrGbMS.IsCombine then
		reductionMinRpm = math.max( reductionMinRpm, self.vehicle.mrGbMS.ThreshingMinRpm * gearboxMogli.rpmReduction )
	elseif self.lastMissingTorque <= 0 then
		reductionMinRpm = math.max( reductionMinRpm, minRpmReduced, maxPowerReduced )
	end
	
	local reduceIt = -2
	local utt      = self.usedMotorTorqueS
	if      self.lastMotorTorque    > gearboxMogli.eps
			and self.nonClampedMotorRpm > reductionMinRpm 
			and utt                     > 0.8 * self.lastMotorTorque
			and ( utt                   > self.lastMotorTorque
				 or self.noTransmission
				 or self.deltaRpm         < gearboxMogli.autoShiftMaxDeltaRpm ) then
		if     utt > self.lastMotorTorque then
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.reductionInfo = string.format("Missing torque: %4d", 
															self.lastMissingTorque*1000)
			end
			reduceIt = 1
		elseif self.noTransmission then
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.reductionInfo = string.format("No transmission: %4d (%4d), %4d", 
														utt*1000,
														self.lastMotorTorque*1000,
														self.lastMissingTorque*1000)
			end
			reduceIt = 2
		elseif self.vehicle.mrGbMS.ConstantRpm then
			reduceIt = -2
		elseif self.vehicle.mrGbMS.Hydrostatic or self.clutchPercent < 0.95 then
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.reductionInfo = string.format("No fixed connection to wheels: %4d, %4d, %4d", 
														utt*1000,
														self.lastMotorTorque*1000,
														self.lastMissingTorque*1000)
			end
			reduceIt = 3
		else
			reduceIt = -1
		end
	end
	
	if reduceIt > 0 then
		getMaxPower = true
		local m = self.vehicle.mrGbMS.CurMinRpm
		local f
		if self.torqueRpmReduction == nil then
			self.torqueRpmReference = self.nonClampedMotorRpm
			self.torqueRpmReduction = 0
		end
		if utt > self.lastMotorTorque then
			f = math.min( 0.25, 0.05 + ( utt - self.lastMotorTorque ) / self.lastMotorTorque )
		else
		  -- usedMotorTorque / lastMotorTorque is between 0.8 and 1 => max is between 0 and 0.2 
			-- 0..0.05
			f = 0.25 * math.max( utt / self.lastMotorTorque - 0.8, 0 ) 
		end
		self.torqueRpmReduction   = math.min( self.torqueRpmReference - reductionMinRpm, self.torqueRpmReduction + f * self.tickDt * self.vehicle.mrGbMS.RpmDecFactor )
	elseif  self.torqueRpmReduxMode ~= nil
			and self.torqueRpmReduxMode  < 2 then
		self.torqueRpmReference = nil
		self.torqueRpmReduction = nil
	elseif  self.torqueRpmReduction ~= nil
			and self.nonClampedMotorRpm <= self.torqueRpmReference - self.torqueRpmReduction then
		self.torqueRpmReference = nil
		self.torqueRpmReduction = nil
	elseif  self.torqueRpmReduction ~= nil then
		if self.torqueRpmReduxMode == 2 then
			self.torqueRpmReduction = self.torqueRpmReduction - self.tickDt * self.vehicle.mrGbMS.RpmIncFactor
		else
			self.torqueRpmReduction = self.torqueRpmReduction - self.tickDt * self.vehicle.mrGbMS.RpmIncFactorNeutral
		end
		if self.torqueRpmReduction < 0 then
			self.torqueRpmReference = nil
			self.torqueRpmReduction = nil
		end
	end
	
	if self.vehicle.mrGbMG.debugInfo then
		local r = 9999
		if self.torqueRpmReduction ~= nil then
			r = self.torqueRpmReference - self.torqueRpmReduction
		end
		self.vehicle.mrGbML.reductionInfo = string.format("TRR %2d: %4d (%4d), %4d / %4d (%4d, %3d), %4d => %4d", 
												reduceIt,
												self.nonClampedMotorRpm,
												reductionMinRpm,
												self.usedMotorTorqueS*1000,
												self.usedMotorTorque*1000,
												self.lastMotorTorque*800,
												self.motorLoadS*100,
												self.lastMissingTorque*1000,
												r)
	end
	
	if self.torqueRpmReduction ~= nil then
		if utt > self.lastMotorTorque then			
			self.torqueRpmReduxMode = 2
		elseif self.torqueRpmReduxMode == nil then
			self.torqueRpmReduxMode = 1
		end
	elseif self.torqueRpmReduxMode ~= nil then
		self.torqueRpmReduxMode = nil
	end
	
	if self.torqueRpmReduxMode ~= nil then
		minRpmReduced  = math.min( minRpmReduced,  self.torqueRpmReference - self.torqueRpmReduction )
	end

--**********************************************************************************************************		
-- smooth
	local delayedDown = self.motorLoadS * 5000
	if     ptoToolOn
			or getMaxPower
			or self.torqueRpmReduxMode ~= nil
			or self.currentSpeed > currentSpeedLimitR
			or self.currentSpeed < 0.278 then
		delayedDown = 0
	end

	if lastNoTransmission or lastNoTorque then
		self.targetRpm       = targetRpm
		self.requestedPower  = requestedPower
		self.timeShiftTab    = {}
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.targetRpmTInfo = string.format("no trans.: %4d",self.targetRpm)
		end
	elseif self.timeShiftTab == nil then 
		self.targetRpm       = targetRpm
		self.requestedPower  = requestedPower
		
		if delayedDown > 0 then
			self.timeShiftTab = { { t=g_currentMission.time, r=targetRpm, p=requestedPower } }
		else
			self.timeShiftTab = {}
		end
				
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.targetRpmTInfo = string.format("initial: %4d",self.targetRpm)
		end
	else
		r = targetRpm     
		p = requestedPower
		
		if delayedDown > 0 then
			local tab = self.timeShiftTab
			self.timeShiftTab = { { t=g_currentMission.time, r=targetRpm, p=requestedPower } }
		
			for _,tvs in pairs(tab) do
				deltaT = g_currentMission.time - tvs.t
				if deltaT < delayedDown then
					table.insert( self.timeShiftTab, tvs )
					local tr = math.min( self.maxPowerRpm, tvs.r )
					if r < tr then
						r = tr
					end
					if p < tvs.p then
						p = tvs.p
					end
				end
			end
		elseif self.timeShiftTab == nil then
			self.timeShiftTab = {}
		end
		
		local s
		if r < self.targetRpm then s = self.vehicle.mrGbML.smoothSlow else s = self.vehicle.mrGbML.smoothMedium end
		self.targetRpm      = self.targetRpm      + s * ( r - self.targetRpm      )
		if p < self.requestedPower then s = self.vehicle.mrGbML.smoothSlow else s = self.vehicle.mrGbML.smoothMedium end
		self.requestedPower = self.requestedPower + s * ( p - self.requestedPower )
		
		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.targetRpmTInfo = string.format("filled: %4d %s, %3d, %4d, %4d, %4d",delayedDown,tostring(getMaxPower),table.getn(self.timeShiftTab),self.targetRpm,r,targetRpm)
		end
  end		
		
	-- clutch calculations...
	local clutchMode = 0 -- no clutch calculation

	if self.lastClutchClosedTime < self.vehicle.mrGbML.autoShiftTime then
		self.lastClutchClosedTime = self.vehicle.mrGbML.autoShiftTime
	end
	
	if self.vehicle.mrGbMS.NeutralActive or self.vehicle.mrGbMS.ManualClutch < 0.1 then
		-- double clutch
		self.rpmIncFactor  = self.vehicle.mrGbMS.RpmIncFactorNeutral
		self.rpmIncFactorS = self.rpmIncFactorS + self.vehicle.mrGbML.smoothSlow * ( self.vehicle.mrGbMS.RpmIncFactorFull - self.rpmIncFactorS )
	elseif self.lastMissingTorque > 0
			or self.torqueRpmReduction ~= nil then -- too much load
		self.rpmIncFactor  = self.vehicle.mrGbMS.RpmIncFactorFull
		self.rpmIncFactorS = self.vehicle.mrGbMS.RpmIncFactorFull
	elseif lastNoTransmission
			or lastNoTorque then                   -- no gear => turbo lag
		self.rpmIncFactor  = self.vehicle.mrGbMS.RpmIncFactorFull
		self.rpmIncFactorS = self.rpmIncFactorS + self.vehicle.mrGbML.smoothSlow * ( self.vehicle.mrGbMS.RpmIncFactorFull - self.rpmIncFactorS )
	else
		local f = self.motorLoadP ^ 2
		if     self.nonClampedMotorRpm < self.vehicle.mrGbMS.MinTargetRpm then -- RPM too low => let it go up
			f = 0
		elseif self.nonClampedMotorRpm > self.vehicle.mrGbMS.MaxTargetRpm -- RPM too high
				or accelerationPedal      <= 0                                -- not accelerating
				or self.currentSpeed      >= currentSpeedLimit then           -- not accelerating
			f = 1
		elseif accelerationPedal <= 0.5 and self.motorLoadP <= 0.1 then   -- turbo lag
			f = 1
		end
		local r = self.vehicle.mrGbMS.RpmIncFactor + f * ( self.vehicle.mrGbMS.RpmIncFactorFull - self.vehicle.mrGbMS.RpmIncFactor )
		self.rpmIncFactorS = self.rpmIncFactorS + self.vehicle.mrGbML.smoothMedium * ( r - self.rpmIncFactorS )
		self.rpmIncFactor  = self.rpmIncFactorS
	end
	self.maxRpmIncrease  = self.tickDt * self.rpmIncFactor

--**********************************************************************************************************		
	self.lastHydrostaticFactor = self.hydrostaticFactor
	
	local maxDeltaThrottle = self.vehicle.mrGbMG.maxDeltaAccPerMs * self.tickDt 

--**********************************************************************************************************		
	local autoCloseClutch = false
	local autoClutchTimer = self.vehicle.mrGbMS.AutoCloseTimer
	local autoClutchSpeed = self.vehicle.mrGbMS.ClutchTimeManual
	
	if not ( self.vehicle.mrGbMS.ManualClutchReverse or self.vehicle.mrGbML.ReverserNeutral ) and self.vehicle.mrGbML.DirectionChangeTime > autoClutchTimer then
		autoClutchTimer = self.vehicle.mrGbML.DirectionChangeTime
		autoClutchSpeed = autoClutchSpeed * 2 * ( 1 - self.vehicle.mrGbMS.ShuttleFactor )
	end

	if      autoClutchSpeed > 10
			and not ( self.vehicle.mrGbMS.Hydrostatic and self.vehicle.mrGbMS.HydrostaticLaunch )
			and g_currentMission.time >= autoClutchTimer
			and g_currentMission.time <  autoClutchTimer + autoClutchSpeed then
		autoCloseClutch = true
	end
	
	if self.vehicle.mrGbMS.NeutralActive then	
		autoCloseClutch = false 
	end
	
	if self.vehicle.mrGbMG.debugInfo then
		self.vehicle.mrGbML.autoCloseClutch0 = string.format( "%5s, %5s, %8d, %8d, %8d, %8d, %5s",
																								tostring(autoCloseClutch),
																								tostring(self.vehicle.mrGbML.ReverserNeutral),
																								Utils.getNoNil( self.vehicle.mrGbMS.AutoCloseTimer, -1 ),
																								Utils.getNoNil( self.vehicle.mrGbML.DirectionChangeTime, -1 ),
																								g_currentMission.time - autoClutchTimer,
																								autoClutchSpeed,
																								tostring(self.vehicle.mrGbMS.ManualClutchReverse))
	end
	
--**********************************************************************************************************		
-- trying to turn off neutral and double clutch
--**********************************************************************************************************		
	if self.vehicle.mrGbMS.NeutralNoSync and not self.vehicle.mrGbMS.NeutralActive then				
		gearboxMogli.checkTransmissionInOutRpm( self.vehicle, self.clutchRpm )
	end
	
--**********************************************************************************************************		
-- no transmission / neutral 
--**********************************************************************************************************		
	local brakeNeutral   = 0
	local autoOpenClutch = ( self.vehicle.mrGbMS.Hydrostatic and self.vehicle.mrGbMS.HydrostaticLaunch ) or self.vehicle:mrGbMGetAutoClutch()
	
	if      self.vehicle.mrGbMS.Hydrostatic
			and self.vehicle.mrGbMS.ConstantRpm 
			and not ( self.vehicle.mrGbML.ReverserNeutral )
			and accelerationPedal < -0.5
			and currentAbsSpeed >= self.vehicle.mrGbMG.minAbsSpeed then
		autoOpenClutch = false
	end
	
	if     self.vehicle.mrGbMS.G27Mode > 0 
			or not self.vehicle.mrGbMS.NeutralActive 
			or self.vehicle:getIsHired() then
		if     accelerationPedal >= -gearboxMogli.accDeadZone
				or currentAbsSpeed   >= self.vehicle.mrGbMG.minAbsSpeed then
			self.brakeNeutralTimer = g_currentMission.time + self.vehicle.mrGbMG.brakeNeutralTimeout
		end
	else
		if accelerationPedal > gearboxMogli.accDeadZone then
			self.brakeNeutralTimer = g_currentMission.time + self.vehicle.mrGbMG.brakeNeutralTimeout
		end
	end
	
	if     self.vehicle.mrGbMS.NeutralActive
			or self.vehicle.mrGbMS.G27Mode == 1
			or not ( self.vehicle.isMotorStarted ) 
			or g_currentMission.time < self.vehicle.motorStartTime then
	-- off or neutral
		brakeNeutral = 1
	elseif  self.vehicle.mrGbML.ReverserNeutral
			and ( autoOpenClutch or not self.vehicle.mrGbMS.ManualClutchReverse )
			and currentAbsSpeed < -1.8 then
	-- reverser and did not stop yet
		brakeNeutral = 2
--elseif  self.vehicle.mrGbML.ReverserNeutral
--		and autoOpenClutch
--		and accelerationPedal    < gearboxMogli.accDeadZone then
---- reverser and auto clutch 
--	brakeNeutral = 3
	elseif  doHandbrake
			and autoOpenClutch then
	-- hand brake but not in neutral
		brakeNeutral = 4
	elseif  self.vehicle.mrGbMS.Hydrostatic
			and self.vehicle.mrGbMS.HydrostaticMin < gearboxMogli.eps
			and accelerationPedal >= -gearboxMogli.accDeadZone then
		brakeNeutral = -1
	elseif self.vehicle.cruiseControl.state ~= 0 then
	-- cruise control is on 
		brakeNeutral = -2
	elseif not autoOpenClutch then
	-- no automatic stop
		brakeNeutral = -3
	elseif  accelerationPedal    >= gearboxMogli.accDeadZone then
	-- accelerating
		brakeNeutral = -4
	elseif  autoCloseClutch then 
	-- we want to close the clutch now 
		brakeNeutral = -5
	elseif  accelerationPedal    >= -gearboxMogli.accDeadZone
			and currentAbsSpeed       > self.vehicle.mrGbMG.minAbsSpeed then
	-- roling  
		brakeNeutral = -6 
	elseif  accelerationPedal < -gearboxMogli.accDeadZone
			and self.lastMotorRpm < minRpmReduced then 
	-- braking I 
		brakeNeutral = 5
	elseif  accelerationPedal < -gearboxMogli.accDeadZone
			and currentAbsSpeed   < self.vehicle.mrGbMG.minAbsSpeed + self.vehicle.mrGbMG.minAbsSpeed then
	-- braking II 
		brakeNeutral = 6
	elseif  self.stallWarningTimer ~= nil 
			and g_currentMission.time > self.stallWarningTimer + self.vehicle.mrGbMG.stallWarningTime then
	-- motor stall
		brakeNeutral = 7
	else
		brakeNeutral = -9
	end
	
	if self.vehicle.mrGbMG.debugInfo then
		self.vehicle.mrGbML.brakeNeutralInfo = 
			string.format("%2d: %1.3f %4d %5s %5s %5s %2.1f %4d %4d %4d %5s", 
										brakeNeutral,
										accelerationPedal,
										self.brakeNeutralTimer - g_currentMission.time,
										tostring(autoOpenClutch),
										tostring(doHandbrake),
										tostring(brakeNeutral),
										currentAbsSpeed,
										self.lastMotorRpm,
										self.minRequiredRpm,
										minRpmReduced,
										tostring(self.vehicle:mrGbMGetAutoHold()))
	end
		
	if brakeNeutral > 0 then
	-- neutral	
	
	--print("neutral: "..tostring(self.clutchRpm).." "..tostring(currentAbsSpeed))
	
		if  not ( self.vehicle.mrGbMS.NeutralActive ) 
				and self.vehicle:mrGbMGetAutoStartStop()
				and self.vehicle.mrGbMS.G27Mode <= 0
				and self.brakeNeutralTimer  < g_currentMission.time
				and ( currentAbsSpeed       < self.vehicle.mrGbMG.minAbsSpeed
					 or ( self.lastMotorRpm   < minRpmReduced and not self.vehicle:mrGbMGetAutomatic() ) ) then
			self.vehicle:mrGbMSetNeutralActive( true ) 
		end
	-- handbrake 
		if      self.vehicle.mrGbMS.NeutralActive 
				and self.vehicle:mrGbMGetAutoHold()
				and self.brakeNeutralTimer  < g_currentMission.time
				and ( accelerationPedal     < -0.5 
					 or currentAbsSpeed       < self.vehicle.mrGbMG.minAbsSpeed ) then
			self.vehicle:mrGbMSetState( "AutoHold", true )
		elseif  self.vehicle.mrGbMS.NeutralActive
				and self.brakeNeutralTimer  < g_currentMission.time
				and currentAbsSpeed         < self.vehicle.mrGbMG.minAbsSpeed then 
			self.vehicle:mrGbMSetState( "AutoHold", accelerationPedal < -0.5 )
		end
				
		if self.vehicle.mrGbMS.Hydrostatic and self.vehicle.mrGbMS.HydrostaticLaunch then
		elseif self.vehicle:mrGbMGetAutoClutch() then
			self.autoClutchPercent  = math.max( 0, self.autoClutchPercent -self.tickDt/self.vehicle.mrGbMS.ClutchTimeDec ) 
			self.vehicle:mrGbMSetState( "IsNeutral", true )
		elseif self.vehicle.mrGbMS.ManualClutch > 0.9 then
			self.vehicle:mrGbMSetState( "IsNeutral", true )
		end
		
		if     self.vehicle.mrGbML.gearShiftingNeeded == gearboxMogli.gearShiftingNoThrottle then
			self.vehicle:mrGbMDoGearShift() 
			self.vehicle.mrGbML.gearShiftingNeeded = 0 
		elseif self.vehicle.mrGbML.gearShiftingNeeded == 2 and g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime then	
			if      self.lastRealMotorRpm > 0.8 * self.vehicle.mrGbMS.MaxTargetRpm 
					and g_currentMission.time + g_currentMission.time > self.vehicle.mrGbML.gearShiftingTime + self.vehicle.mrGbML.clutchShiftingTime then
				self.vehicle.mrGbML.gearShiftingNeeded  = 3
			end
			if self.lastRealMotorRpm < 0.9 * self.vehicle.mrGbMS.MaxTargetRpm then
				accelerationPedal = 1
			else
				accelerationPedal = 0.8
			end
		elseif self.vehicle.mrGbML.gearShiftingNeeded > 0 then
			if g_currentMission.time>=self.vehicle.mrGbML.gearShiftingTime then
				if self.vehicle.mrGbML.gearShiftingNeeded < 2 then	
					self.vehicle:mrGbMDoGearShift() 
				end 
				self.vehicle.mrGbML.gearShiftingNeeded = 0 
			elseif self.vehicle.mrGbML.gearShiftingNeeded < 2 then	
				if self.autoClutchPercent <= 0 then
					self.vehicle:mrGbMDoGearShift() 
				end 
			end 
		end

		self.noTransmission = true
		self.timeShiftTab   = nil
		
		if      self.vehicle.mrGbMS.Hydrostatic 
				and self.targetRpm > gearboxMogli.eps
				then
			local hTgt = self.absWheelSpeedRpm * self:getMogliGearRatio() / self.targetRpm 
			
			if     self.vehicle.mrGbMS.HydrostaticMin >= 0 then
				hTgt = Utils.clamp( hTgt, self.vehicle.mrGbMS.HydrostaticStart, self.vehicle.mrGbMS.HydrostaticMax ) 
			elseif self.vehicle.mrGbMS.ReverseActive then	
				hTgt = Utils.clamp( hTgt, self.vehicle.mrGbMS.HydrostaticStart, -self.vehicle.mrGbMS.HydrostaticMin ) 
			else
				hTgt = Utils.clamp( hTgt, self.vehicle.mrGbMS.HydrostaticStart,  self.vehicle.mrGbMS.HydrostaticMax ) 
			end
			
			if math.abs( hTgt - self.hydrostaticFactor ) > gearboxMogli.eps then
				if hTgt > self.hydrostaticFactor then
					self.hydrostaticFactor = self.hydrostaticFactor + math.min( hTgt - self.hydrostaticFactor,  self.tickDt * self.vehicle.mrGbMS.HydrostaticIncFactor ) 		
				else
					self.hydrostaticFactor = self.hydrostaticFactor + math.max( hTgt - self.hydrostaticFactor, -self.tickDt * self.vehicle.mrGbMS.HydrostaticDecFactor )
				end
			end					
		end
					
--**********************************************************************************************************		
	else
--**********************************************************************************************************		
		self.vehicle:mrGbMSetState( "IsNeutral", false )
		if self.vehicle.mrGbML.ReverserNeutral then
			self.vehicle.mrGbML.ReverserNeutral     = false
			self.vehicle.mrGbML.DirectionChangeTime = g_currentMission.time
		end
		
		-- acceleration for idle/minimum rpm		
		local minThrottle = math.max( 0.2, handThrottle ) 
		if     accelerationPedal < -gearboxMogli.accDeadZone then
		-- no min throttle while braking 
			minThrottle = 0
		elseif self.nonClampedMotorRpm < minRpmReduced and self.stallWarningTimer ~= nil then
		--full power
			minThrottle = 1
		elseif self.nonClampedMotorRpm >= self.minRequiredRpm then
		-- not needed 
			minThrottle = 0
		elseif lastNoTransmission then
		-- initialize => keep default value 
		else
		-- smooth transition 
			delta       = math.min( 0.1 * self.vehicle.mrGbMS.RatedRpm, self.minRequiredRpm - self.vehicle.mrGbMS.CurMinRpm )
			if handThrottle > 0 then 
				delta = delta * ( 1 - 0.9 * handThrottle ) 
			end 
			if self.nonClampedMotorRpm <= self.minRequiredRpm - delta then
				minThrottle = 1
			else 
				minThrottle = ( self.minRequiredRpm - self.nonClampedMotorRpm ) / delta 
			end
		end
	
		if     self.vehicle.mrGbML.gearShiftingNeeded == gearboxMogli.gearShiftingNoThrottle then
	--**********************************************************************************************************		
	-- during gear shift with release throttle 
			if     self.vehicle:mrGbMGetAutoClutch() then
				if g_currentMission.time >= self.vehicle.mrGbML.gearShiftingTime then
					self.vehicle:mrGbMDoGearShift() 
					self.vehicle.mrGbML.gearShiftingNeeded = 0
				end
				accelerationPedal = 0
				self.noTorque     = true
			elseif ( accelerationPedal < gearboxMogli.accDeadZone and self.vehicle.cruiseControl.state == 0 )
					or self.vehicle.mrGbMS.ManualClutch < 0.1 then
				self.vehicle:mrGbMDoGearShift() 
				self.vehicle.mrGbML.gearShiftingNeeded = 0 
			end			

			self.lastClutchClosedTime = g_currentMission.time
			self.deltaRpm = 0
			
		elseif self.vehicle.mrGbML.gearShiftingNeeded > 0 then
	--**********************************************************************************************************		
	-- during gear shift with automatic clutch
			if self.vehicle.mrGbML.gearShiftingNeeded == 2 and g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime then	
				if      self.lastRealMotorRpm > 0.8 * self.vehicle.mrGbMS.MaxTargetRpm 
						and g_currentMission.time + g_currentMission.time > self.vehicle.mrGbML.gearShiftingTime + self.vehicle.mrGbML.clutchShiftingTime then
					self.vehicle.mrGbML.gearShiftingNeeded  = 3
				end
				if self.lastRealMotorRpm < 0.9 * self.vehicle.mrGbMS.MaxTargetRpm then
					accelerationPedal = 1
				else
					accelerationPedal = 0.8
				end
			else               
				accelerationPedal = 0
				self.noTorque     = true
			end

			if g_currentMission.time >= self.vehicle.mrGbML.gearShiftingTime then
				if self.vehicle.mrGbML.gearShiftingNeeded < 2 then	
					self.vehicle:mrGbMDoGearShift() 
				end 
				self.vehicle.mrGbML.gearShiftingNeeded = 0 
				self.vehicle.mrGbML.manualClutchTime = 0
				clutchMode                   = 2 
			elseif self.vehicle.mrGbML.gearShiftingNeeded < 2 then
				if self.autoClutchPercent > 0 and g_currentMission.time < self.vehicle.mrGbML.clutchShiftingTime then
					self.autoClutchPercent   = Utils.clamp( ( self.vehicle.mrGbML.clutchShiftingTime - g_currentMission.time )/self.vehicle.mrGbMS.ClutchShiftTime, 0, self.autoClutchPercent ) 					
				else
					self.vehicle:mrGbMDoGearShift() 
					self.noTransmission = true
				end 
			else
				self.noTransmission = true
			end 
			self.prevNonClampedMotorRpm = self.vehicle.mrGbMS.CurMaxRpm
			self.extendAutoShiftTimer   = true
			
			self.lastClutchClosedTime = g_currentMission.time
			self.deltaRpm = 0
			
		elseif self.vehicle.mrGbML.gearShiftingNeeded < 0 then
	--**********************************************************************************************************		
	-- during gear shift with manual clutch
			self.noTransmission = true			
			self.vehicle:mrGbMDoGearShift() 
			self.vehicle.mrGbML.gearShiftingNeeded = 0						
			
			self.lastClutchClosedTime = g_currentMission.time
			self.deltaRpm = 0
			
		elseif not ( self.vehicle:mrGbMGetAutoClutch() ) and self.vehicle.mrGbMS.ManualClutch < gearboxMogli.minClutchPercent then
	--**********************************************************************************************************		
	-- manual clutch pressed
			self.noTransmission = true		
			self.lastClutchClosedTime = g_currentMission.time
			self.deltaRpm = 0
			
		else
	--**********************************************************************************************************		
	-- normal drive with gear and clutch
			self.noTransmission = false

			if self.vehicle.mrGbMS.NeutralNoSync then 
				self.vehicle:mrGbMSetState( "NeutralNoSync", false )
			end 
			
			local accHydrostaticTarget = false

	--**********************************************************************************************************		
	-- reduce hydrostaticFactor instead of braking  
			if      self.vehicle.mrGbMS.Hydrostatic
					and self.vehicle.mrGbMS.ConstantRpm then
				accHydrostaticTarget = true			
			end
			
	--**********************************************************************************************************		
	-- no transmission while braking 
			if      self.vehicle.cruiseControl.state == 0
					and self.vehicle.steeringEnabled
					and autoOpenClutch 
					and accelerationPedal       < self.vehicle.mrGbMG.brakeNeutralLimit 
					and self.nonClampedMotorRpm < self.minRequiredRpm
					and ( self.vehicle.axisForwardIsAnalog 
						or not accHydrostaticTarget
						or currentAbsSpeed       < self.vehicle.mrGbMG.minAbsSpeed ) then
				self.noTransmission = true
				self.lastClutchClosedTime = self.vehicle.mrGbML.autoShiftTime
			end
		
			clutchMode = 1 -- calculate clutch percent respecting inc/dec time ms

	--**********************************************************************************************************		
	-- hydrostatic drive
			if self.vehicle.mrGbMS.Hydrostatic then
				-- target RPM
				local c = self.lastRealMotorRpm 
				local t = self.targetRpm
				
				if self.torqueRpmReduxMode ~= nil then -- and self.torqueRpmReduxMode < 2 then
					t = math.min( t, self.torqueRpmReference - self.torqueRpmReduction )
				end
				
				-- boundaries hStart, hMin & hMax
				local hMax = self.vehicle.mrGbMS.HydrostaticMax			
				-- find the best hMin
				local hMin = self.vehicle.mrGbMS.HydrostaticMin 
				
				if self.vehicle.mrGbMS.HydrostaticMin < 0 then
					if self.vehicle.mrGbMS.HydrostaticMin < 0 and self.vehicle.mrGbMS.ReverseActive then	
						hMax = -self.vehicle.mrGbMS.HydrostaticMin 
					end
					hMin = 0 --gearboxMogli.eps
				end
				
				local w0   = self.absWheelSpeedRpm
				local wMin = self.absWheelSpeedRpm + math.min( 0, self.absWheelSpeedRpm - prevWheelSpeedRpm )
				local wMax = self.absWheelSpeedRpm + math.max( 0, self.absWheelSpeedRpm - prevWheelSpeedRpm )
				
				local spdFix = -1
				if self.vehicle.mrGbMS.FixedRatio > gearboxMogli.eps then
					local _,minFix,maxFix = self.vehicle:mrGbMGetGearSpeed()
					spdFix = minFix + ( maxFix - minFix ) * self.vehicle.mrGbMS.FixedRatio 
					spdFix = spdFix / ( 3.6 * hMax )
				end
				
				if self.vehicle:mrGbMGetAutomatic() then
					local gearMaxSpeed = self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].ratio
														 * self.vehicle.mrGbMS.GlobalRatioFactor
					if self.vehicle.mrGbMS.ReverseActive then	
						gearMaxSpeed = gearMaxSpeed * self.vehicle.mrGbMS.ReverseRatio 
					end
					
					local currentGear = self:combineGear()
					local maxGear
					if     not self.vehicle:mrGbMGetAutoShiftRange() then
						maxGear = table.getn( self.vehicle.mrGbMS.Gears )
					elseif not self.vehicle:mrGbMGetAutoShiftGears() then 
						maxGear = table.getn( self.vehicle.mrGbMS.Ranges )
					else
						maxGear = table.getn( self.vehicle.mrGbMS.Gears ) * table.getn( self.vehicle.mrGbMS.Ranges )
					end
					
					local refTime   = self.lastClutchClosedTime
					local downTimer = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort
					local upTimer   = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort
					
					local bestE     = nil
					local bestR     = nil
					local bestS     = nil
					local bestG     = currentGear
					local bestH     = self.hydrostaticFactor
					local tooBig    = false
					local tooSmall  = false
					
					if      self.vehicle.cruiseControl.state > 0 
							and self.vehicle.mrGbMS.CurrentGearSpeed * self.vehicle.mrGbMS.IdleRpm / self.vehicle.mrGbMS.RatedRpm > currentSpeedLimit then
						-- allow down shift after short timeout
					elseif self.vehicle.mrGbML.lastGearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
						downTimer = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutLong 
					elseif self.vehicle.mrGbML.lastGearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
						if      accelerationPedal       > 0.5
								and self.nonClampedMotorRpm > self.vehicle.mrGbMS.RatedRpm then
							-- allow up shift after short timeout
							upTimer   = refTime -- + self.vehicle.mrGbMS.AutoShiftTimeoutShort
						else
							upTimer   = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutLong 
						end
					elseif self.hydrostaticFactor > hMax - gearboxMogli.eps then
						upTimer   = math.min( refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort, upTimer )
					elseif self.hydrostaticFactor < self.vehicle.mrGbMS.HydrostaticStart - gearboxMogli.eps then
						downTimer = math.min( refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort, downTimer )
					end		
					
					local minSpd = gearboxMogli.huge 
					for g=1,maxGear do
						local i2g, i2r = self:splitGear( g )
						local spd = self.vehicle.mrGbMS.Gears[i2g].speed
											* self.vehicle.mrGbMS.Ranges[i2r].ratio
											* gearMaxSpeed 
						if minSpd > spd then
							minSpd = spd
						end
					end
					
					for g=1,maxGear do
						local isValidEntry = true
						local i2g, i2r = self:splitGear( g )
					
						if isValidEntry and self.vehicle:mrGbMGetAutoShiftGears() and gearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Gears[i2g], i2g, i2r ) then
							isValidEntry = false
						end
						if isValidEntry and self.vehicle:mrGbMGetAutoShiftRange() and gearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Ranges[i2r], i2g, i2r ) then
							isValidEntry = false
						end
					
						local spd = self.vehicle.mrGbMS.Gears[i2g].speed
											* self.vehicle.mrGbMS.Ranges[i2r].ratio
											* gearMaxSpeed 
											
						if spdFix > 0 then
							local h = spdFix / spd
							if h > hMax or h < hMin then
								isValidEntry = false
							end
						end
						
						if spd > minSpd + gearboxMogli.eps then
							if w0 * gearboxMogli.gearSpeedToRatio( self.vehicle, spd ) < minRpmReduced * self.vehicle.mrGbMS.HydrostaticStart then
								isValidEntry = false
							end
						end
												
						if g ~= currentGear then						
							if not isValidEntry then
							-- nothing 
							elseif self.vehicle.mrGbMS.AutoShiftTimeoutLong > 0 then								
								local autoShiftTimeout = 0
								if     spd < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
									autoShiftTimeout = downTimer							
								elseif spd > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
									autoShiftTimeout = upTimer
								else
									autoShiftTimeout = math.min( downTimer, upTimer )
								end
								
								autoShiftTimeout = autoShiftTimeout + self.vehicle.mrGbMS.GearTimeToShiftGear
								
								if autoShiftTimeout > g_currentMission.time then
									if gearboxMogli.debugGearShift then print(tostring(g)..": Still waiting") end
									isValidEntry = false
								end
							end
							
							if not isValidEntry then
							--nothing
							elseif  accelerationPedal < -gearboxMogli.accDeadZone
							    and spd           > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
								if gearboxMogli.debugGearShift then print(tostring(g)..": no down shift I") end
								isValidEntry = false
							elseif  self.deltaRpm < -gearboxMogli.autoShiftMaxDeltaRpm
									and spd           > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
								if gearboxMogli.debugGearShift then print(tostring(g)..": no down shift II") end
								isValidEntry = false
							elseif  self.deltaRpm > gearboxMogli.autoShiftMaxDeltaRpm
									and spd           < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
								if gearboxMogli.debugGearShift then print(tostring(g)..": no up shift III") end
								isValidEntry = false
							end
						end

						if isValidEntry then	
							local r = gearboxMogli.gearSpeedToRatio( self.vehicle, spd )					
							local w = w0 * r
					
							if w <= gearboxMogli.eps or c <= gearboxMogli.eps then
								if bestS == nil or bestS > spd then
									bestS = spd
									bestG = g
									bestR = 9999
									bestE = -1
									bestH = self.vehicle.mrGbMS.HydrostaticStart
								end
							else
								local h = w / c
								local e = 0
								local r = 0
								
								if     h < hMin + gearboxMogli.eps then
									r = gearboxMogli.eps + hMin - h
								elseif h > hMax - gearboxMogli.eps then
									r = gearboxMogli.eps + h - hMax
								else
									e = self:getHydroEff( h )
								end
								
								if     bestS == nil 
										or bestR > r + gearboxMogli.eps 
										or ( math.abs( bestR - r ) < gearboxMogli.eps and bestE < e ) then
									bestG = g
									bestS = spd
									bestE = e
									bestR = r
									bestH = h
								elseif  g == currentGear
										and hMin * t <= w and w <= hMax * t then
								elseif  math.abs( bestR - r ) < gearboxMogli.eps 
										and math.abs( bestE - e ) < gearboxMogli.eps then
									local hb = w0 * bestR / t
									local ht = w / t
									if hb <= hMin or hb >= hMax and hMin < ht and ht < hMax then
										bestG = g
										bestS = spd
										bestE = e
										bestR = r
										bestH = h
									end
								end
							end
						end
					end
					
					if self.vehicle.mrGbMG.debugInfo then
						self.vehicle.mrGbML.autoShiftInfo = string.format( "rpm: %4.0f target: %4.0f gear: %2d speed: %5.3f hydro: %4.2f\n",
																																self.lastRealMotorRpm, 
																																t, 
																																currentGear, 
																																self.vehicle.mrGbMS.CurrentGearSpeed,
																																self.hydrostaticFactor )
					end
					
					if bestS == nil then
						if self.vehicle.mrGbMG.debugInfo then
							self.vehicle.mrGbML.autoShiftInfo = self.vehicle.mrGbML.autoShiftInfo .. "nothing found: "..tostring(tooBig).." "..tostring(tooSmall)
						end
					else
						if self.vehicle.mrGbMG.debugInfo then
							self.vehicle.mrGbML.autoShiftInfo = self.vehicle.mrGbML.autoShiftInfo ..
																									string.format( "bestG: %2d bestS: %5.3f bestE: %4.2f bestR: %4.0f bestH: %4.2f",
																																	bestG, bestS, bestE, bestR, bestH )
						end
					end 
					
					if bestG ~= currentGear then	
						local i2g, i2r = self:splitGear( bestG )
						
						if self.vehicle.mrGbML.autoShiftInfo ~= nil and ( self.vehicle.mrGbMG.debugPrint or gearboxMogli.debugGearShift ) then
							print(self.vehicle.mrGbML.autoShiftInfo)
							print("-------------------------------------------------------")
						end
						
						if self.vehicle:mrGbMGetAutoShiftGears() then
							self.vehicle:mrGbMSetCurrentGear( i2g ) 
						end
						if self.vehicle:mrGbMGetAutoShiftRange() then
							self.vehicle:mrGbMSetCurrentRange( i2r ) 
						end
						clutchMode                           = 2
						self.vehicle.mrGbML.manualClutchTime = 0
						self.hydrostaticFactor = bestH
						self.maxRpmIncrease    = gearboxMogli.huge + 1	
						self.hTgtTab           = nil
					end
				end

				
				if self.vehicle.mrGbML.gearShiftingNeeded == 0 then
					-- min RPM
					local r = self:getMogliGearRatio()
					local w = w0 * r
					
					-- min / max RPM
					local n0 = math.max( minTarget, self.minTargetRpm )
					local m0 = math.max( t, math.min( self.vehicle.mrGbMS.HydrostaticMaxRpm, self:getThrottleMaxRpm( accelerationPedal / self.vehicle.mrGbMS.MaxRpmThrottle ), self.maxTargetRpm ))

					if self.vehicle.mrGbMS.IsCombine and self.vehicle:getIsTurnedOn() then
						n0 = Utils.clamp( self.vehicle.mrGbMS.ThreshingMinRpm, n0, m0 )
						m0 = Utils.clamp( self.vehicle.mrGbMS.ThreshingMaxRpm, n0, m0 )
					end
					
					local hFix = -1
					if spdFix > 0 then
						hFix  = Utils.clamp( hMax * spdFix / self.vehicle.mrGbMS.CurrentGearSpeed, hMin, hMax )
						n0    = minRpmReduced
					end
					
					if self.vehicle.mrGbMS.ConstantRpm and getMaxPower then
						t = Utils.clamp( self.maxPowerRpm, t - self.vehicle.mrGbMS.HydrostaticPtoDiff, t )
					end
					
					if getMaxPower and currentSpeedLimit > self.currentSpeed then
						currentSpeedLimit = self.currentSpeed
					end
					
					local d = gearboxMogli.hydroEffDiff
					if self.torqueRpmReduxMode ~= nil then
						d = 0
					elseif d < gearboxMogli.huge and gearboxMogli.hydroEffDiffInc > 0 then
						d = d + math.min(1,1.4-1.4*self.motorLoadS) * gearboxMogli.hydroEffDiffInc
					end
		
					local speedControl = false 
					if self.vehicle.mrGbMS.ConstantRpm then 
						if     self.vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE then 
							speedControl = true 
						elseif self.vehicle.mrGbML.hydroTargetSpeed ~= nil then 
							speedControl = true 
						elseif self.ptoSpeedLimit                   ~= nil then	
							speedControl = true 
						end 
					end 
					
					if self.vehicle.mrGbMS.ConstantRpm and not speedControl then 
					-- throttle really regulates the ratio => RPM might be too low or too high
						d  = gearboxMogli.huge
						n0 = self.vehicle.mrGbMS.CurMinRpm
						m0 = self.vehicle.mrGbMS.CurMaxRpm
					elseif spdFix > 0 then
						d  = gearboxMogli.huge
					elseif self.vehicle.mrGbMS.ConstantRpm then
						d  = math.min( d, self.vehicle.mrGbMS.HydrostaticPtoDiff )
					end
					
					if self.torqueRpmReduxMode ~= nil and self.torqueRpmReduxMode == 2 then
						n0 = math.min( n0, self.torqueRpmReference - self.torqueRpmReduction )
						m0 = math.min( m0, self.torqueRpmReference - self.torqueRpmReduction )
					end
					
					local m1    = Utils.clamp( t + d, n0, m0 )
					local n1    = Utils.clamp( t - d, n0, m0 )
					
					local hMin1 = Utils.clamp( w / m1, hMin, hMax )
					local hMax1 = Utils.clamp( w / n1, hMin, hMax )
					local hTgt  = Utils.clamp( w / t, hMin1, hMax1 )
					
					if     hFix > 0 then
						hTgt = Utils.clamp( hFix, hMin1, hMax1 )	
					elseif hMin1 > hMax1 - gearboxMogli.eps then
						hTgt = hMin1
					elseif  self.vehicle.mrGbMS.ConstantRpm and speedControl then					
						hTgt = Utils.clamp( self.vehicle.mrGbMS.RatedRpm * currentSpeedLimit / ( t * self.vehicle.mrGbMS.CurrentGearSpeed ), hMin1, hMax1 )						
					elseif  self.vehicle.mrGbMS.ConstantRpm then 
						hTgt = Utils.clamp( hMin + self.accS * ( hMax - hMin ), hMin1, hMax1 )	
					elseif not ( self.vehicle.mrGbMS.HydrostaticDirect ) then
						local sp = nil
						local sf = nil						
						local ti = Utils.clamp( math.floor( 200 * ( hMax1 - hMin1 ) + 0.5 ), 10, 100 )
						local td = 1 / ti
						local rTgt = t
						local tp = nil
						local tf = nil
						local tr = nil
						local ss = nil
						local se = nil
						local te = nil
						
						for f=0,ti do
							local h2 = hMax1 + f * ( hMin1 - hMax1 ) * td
							local r2 = w / math.max( h2, gearboxMogli.eps )
													
							local mt = self.currentTorqueCurve:get( r2 )
							if mt > gearboxMogli.eps and mt >= self.ptoMotorTorque then
								local e  = self:getHydroEff( h2 )
								local rt = self:getTransTorqueAcc( r2, accelerationPedal, mt - self.ptoMotorTorque )
								local lt = Utils.clamp( 1 - e, 0, 1 ) * rt
								rt = rt - lt
								if self.usedTransTorque < rt and self.rawTransTorque < self.lastTransTorque*0.99 then
									rt = self.usedTransTorque 
								end
								rt = rt + self.ptoMotorTorque + lt
								
								local ratio = self.fuelCurve:get( r2 ) / gearboxMogli.powerFuelCurve:get( Utils.clamp(rt/mt,0,1) )
								local rp = rt * r2
								local dp = math.max( 0, 1.25*math.max( requestedPower, self.requestedPower ) - mt * r2 )
								local df = ratio * rp
																
								if     sp == nil 
										or dp < sp 
										or ( dp == sp and df < sf ) then
									sp   = dp
									sf   = df 
									ss   = mt * r2
									se   = e
									hTgt = h2
									rTgt = r2
								end
								
								if     tr == nil
										or math.abs( t - r2 ) < math.abs( tr - r2 ) then
									tp = mt * r2
									tf = df
									tr = r2
									te = e
								end
							end
						end
						
						if self.vehicle.mrGbMG.debugInfo then
							if sp == nil then
								self.vehicle.mrGbML.hydroFuelInfo = "not found"
							else
								self.vehicle.mrGbML.hydroFuelInfo = string.format("%4.0f, %6g: %4.0f, %6g, %6g, %5.3f / %4.0f, %6g, %6g, %5.3f", 
																																	t, self.requestedPower*gearboxMogli.powerFactor0, 
																																	tr, tf, tp*gearboxMogli.powerFactor0, te,
																																	rTgt, sf, ss*gearboxMogli.powerFactor0, se )
							end
						end
					end
					
					if self.hydrostaticFactor < self.vehicle.mrGbMS.HydrostaticStart then
						self.maxRpmIncrease = gearboxMogli.huge + 1						
					end
					
					if gearboxMogli.debugGearShift and self.torqueRpmReduxMode ~= nil then
						print(string.format("torqueRpmReduction r: %4d n: %4d m: %4d t: %4d / h: %6f t: %6f / %6f / %6f",
																self.torqueRpmReference - self.torqueRpmReduction,
																n1,
																m1,
																t,
																self.hydrostaticFactor,
																hTgt,
																currentSpeedLimit*3.6,
																self.currentSpeed*3.6))
					end
					
					-- HydrostaticLossFxTorqueRatio
					-- HydrostaticLossFxRpmRatio 
					
					local hFx = 1
					if hTgt > gearboxMogli.eps and self.vehicle.mrGbMS.HydrostaticLossFxRpmRatio > 0 and self.torqueRpmReduxMode == nil then
						local f 
						if     self.usedTransTorque <  gearboxMogli.eps then
							f = 0
						elseif self.usedTransTorque >= self.maxMotorTorque * self.vehicle.mrGbMS.HydrostaticLossFxTorqueRatio then
							f = 1
						else
							f = self.usedTransTorque / ( self.maxMotorTorque * self.vehicle.mrGbMS.HydrostaticLossFxTorqueRatio )
						end
						
					--hFx = 1 / ( 1 + f * self.vehicle.mrGbMS.HydrostaticLossFxRpmRatio )						
					--if hTgt * hFx * self.vehicle.mrGbMS.MaxTargetRpm < w then
					--	hFx = math.min( w / ( hTgt * self.vehicle.mrGbMS.MaxTargetRpm ), 1 )
					--end
					
						hFx = 1 + f * self.vehicle.mrGbMS.HydrostaticLossFxRpmRatio 
						
						if self.vehicle.mrGbMG.debugInfo then
							self.vehicle.mrGbML.hydroTorqueFxInfo = string.format( "%5.3f, %4d => %4.2f", f, t, hFx )
						end
						
						hTgt = hTgt * hFx
					end					

					local rMax = math.min( self.vehicle.mrGbMS.HydrostaticMaxRpm, self.maxTargetRpm )
					local rMin = minRpmReduced
					if      self.hydrostaticFactor                   < 0.95 * hMax
							and self.vehicle.mrGbMS.HydrostaticMaxRpmLow ~= nil 
							and self.vehicle.mrGbMS.HydrostaticMaxRpmLow < rMax then
					-- limit max RPM at low speed ( 80% rMax <= 10 km/h, 100% rMax >= 20 km/h )
						local s = self.currentSpeed*3.6
						if s < self.vehicle.mrGbMS.HydrostaticMaxRpmSpeedHigh then
							rLow = self.vehicle.mrGbMS.HydrostaticMaxRpmLow
							if s > self.vehicle.mrGbMS.HydrostaticMaxRpmSpeedLow then
								rLow = rLow + ( rMax - rLow ) * ( s - self.vehicle.mrGbMS.HydrostaticMaxRpmSpeedLow ) 
																							/ ( self.vehicle.mrGbMS.HydrostaticMaxRpmSpeedHigh - self.vehicle.mrGbMS.HydrostaticMaxRpmSpeedLow )
							end
							rMax = math.min( rMax, math.max( rLow, t ) )							
						end
					end
					
					if accelerationPedal < -gearboxMogli.accDeadZone then 
						hDF = 1
					else 
						hDF = self.vehicle.mrGbMS.HydrostaticDecFactor
					end 
					hIF   = self.vehicle.mrGbMS.HydrostaticIncFactor	
					
					if self.vehicle.mrGbMS.ConstantRpm and not speedControl then 
						rMin = n0
						rMax = m0
					elseif self.torqueRpmReduxMode ~= nil then 
						hDF = 1
						if self.torqueRpmReduxMode == 2 then
							hIF = 1
						else
							hIF = 0
						end
					elseif self.vehicle.mrGbMS.ConstantRpm then
						hIF = hIF * ( 1 - self.motorLoadS )
					elseif accelerationPedal < 0.95 and self.accP < self.accS then
						hIF = 0
					end
					
					hMin1 = math.max( hMin, 
														math.min( math.max( self.hydrostaticFactor - self.tickDt * hDF, wMin * r / rMax ),
																			wMax * r / rMin,
																			hMax ) )
					hMax1 = math.min( hMax, 
														math.max( math.min( self.hydrostaticFactor + self.tickDt * hIF, wMax * r / rMin ), 
																			self.vehicle.mrGbMS.HydrostaticStart,
																			wMin * r / rMax,
																			hMin ) )
					local hMin2 = Utils.clamp( wMin * r / self:getNextPossibleRpm( t + d, n0, m0 ), hMin1, hMax1 )
					local hMax2 = Utils.clamp( wMax * r / self:getNextPossibleRpm( t - d, n0, m0 ), hMin1, hMax1 )
										
					if hFix > 0 then
						hMin2 = math.min( hMin2, hFix )
						hMax2 = math.min( hMax2, hFix )
					end
					
					self.hydrostaticFactor = Utils.clamp( hTgt, hMin2, hMax2 )

					if     spdFix > 0 then 
					-- simulated fixed gear ratio => keep minThrottle
					elseif speedControl then 
					-- regulate min RPM via hydrostaticFactor only
						minThrottle = 0
					elseif not self.vehicle.mrGbMS.ConstantRpm then 
					-- regulate min RPM via hydrostaticFactor only
						minThrottle = 0
					end 
					
					if gearboxMogli.debugGearShift then
						if self.hydrostaticFactor > gearboxMogli.eps then
							print(string.format("C: s: %6g w0: %6g w: %4d t: %4d h: %6g hT: %6g %6g..%6g %6g..%6g %6g..%6g",
																	self.currentSpeed * gearboxMogli.factor30pi * self.vehicle.movingDirection,
																	w0,
																	w,
																	w/self.hydrostaticFactor,
																	self.hydrostaticFactor,
																	hTgt,
																	hMin,hMax,hMin1,hMax1,hMin2,hMax2))
						else
							print(string.format("D")) 
						end
					end
					
					self.maxRpmIncrease = math.max( self.maxRpmIncrease, self.tickDt * self.vehicle.mrGbMS.RpmIncFactor )
				end
				
				self.vehicle.mrGbML.afterShiftRpm = nil
				
				-- launch & clutch					
				local hStart = math.max( hMin, gearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbMS.CurrentGearSpeed ) / gearboxMogli.maxManualGearRatio )
				 
				if     self.vehicle.mrGbMS.HydrostaticLaunch then
					clutchMode             = -1
				elseif self.hydrostaticFactor < hStart 
						or self.autoClutchPercent + gearboxMogli.eps < 1 then
					clutchMode             = 1
					self.hydrostaticFactor = math.max( self.hydrostaticFactor, hStart )
				else
					local smallestGearSpeed  = self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].speed 
																	 * self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].ratio
																	 * self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].ratio
																	 * self.vehicle.mrGbMS.GlobalRatioFactor
																	 * hMin
																	 * 3.6
					if self.vehicle.mrGbMS.ReverseActive then	
						smallestGearSpeed = smallestGearSpeed * self.vehicle.mrGbMS.ReverseRatio 
					end															 
					
					if currentAbsSpeed < smallestGearSpeed then
						clutchMode             = 1
					else
						clutchMode             = -1
						self.hydrostaticFactor = math.max( self.hydrostaticFactor, hStart )
					end			
				end			
				
				-- check static boundaries
				if     self.hydrostaticFactor > hMax then
					self.hydrostaticFactor = hMax
				end 
				if self.hydrostaticFactor < hMin then
					self.hydrostaticFactor = hMin
				end
				
	--**********************************************************************************************************		
	-- automatic shifting			
	--**********************************************************************************************************		
			elseif self.vehicle:mrGbMGetAutomatic() 
					and not ( self.vehicle.mrGbMS.AllAuto 
								and self.vehicle.mrGbMS.AllAutoMode      <= 0
								and self.vehicle.mrGbMS.AutoShiftRequest == 0 ) then
				local maxAutoRpm   = self.vehicle.mrGbMS.CurMaxRpm - math.min( 50, 0.5 * ( self.vehicle.mrGbMS.CurMaxRpm - self.vehicle.mrGbMS.RatedRpm ) )
				local halfOverheat = 0.5 * self.vehicle.mrGbMS.ClutchOverheatStartTime										
				local gearMaxSpeed = self.vehicle.mrGbMS.GlobalRatioFactor
				if self.vehicle.mrGbMS.ReverseActive then	
					gearMaxSpeed = gearMaxSpeed * self.vehicle.mrGbMS.ReverseRatio 
				end
				
				local possibleCombinations = {}
				local shiftRange1st        = false

				table.insert( possibleCombinations, { gear     = self.vehicle.mrGbMS.CurrentGear,
																							range1   = self.vehicle.mrGbMS.CurrentRange,
																							range2   = self.vehicle.mrGbMS.CurrentRange2,
																							priority = 0} )

				local alwaysShiftGears  =  self.vehicle.mrGbMS.GearTimeToShiftGear    < self.vehicle.mrGbMG.maxTimeToSkipGear 
																or self.vehicle.mrGbMS.ShiftNoThrottleGear
																or ( self.vehicle.mrGbMS.MatchGears ~= nil and self.vehicle.mrGbMS.MatchGears == "true" )
				local alwaysShiftRange  =  self.vehicle.mrGbMS.GearTimeToShiftHl      < self.vehicle.mrGbMG.maxTimeToSkipGear 
																or self.vehicle.mrGbMS.ShiftNoThrottleHl
																or ( self.vehicle.mrGbMS.MatchRanges ~= nil and self.vehicle.mrGbMS.MatchRanges == "true" )
				local alwaysShiftRange2 =  self.vehicle.mrGbMS.GearTimeToShiftRanges2 < self.vehicle.mrGbMG.maxTimeToSkipGear
																or self.vehicle.mrGbMS.ShiftNoThrottleRanges2
				
				local downRpm   = math.max( self.vehicle.mrGbMS.IdleRpm,  self.vehicle.mrGbMS.MinTargetRpm * gearboxMogli.rpmReduction ) 
				local upRpm     = math.min( self.vehicle.mrGbMS.MaxTargetRpm, math.max( self.vehicle.mrGbMS.RatedRpm, self.maxMaxPowerRpm ) ) * gearboxMogli.autoShiftUpRatio
							
				if self.vehicle.mrGbMS.AutoShiftDownRpm ~= nil and self.vehicle.mrGbMS.AutoShiftDownRpm > downRpm then
					downRpm = self.vehicle.mrGbMS.AutoShiftDownRpm
				end
				if self.vehicle.mrGbMS.AutoShiftUpRpm   ~= nil and self.vehicle.mrGbMS.AutoShiftUpRpm   < upRpm   then
					upRpm  = self.vehicle.mrGbMS.AutoShiftUpRpm
				end
				
				-- up-/downRpm for score calculation 
				local downRpmS, upRpmS 				
				if self.vehicle.mrGbMS.ConstantRpm then
					-- PTO => keep RPM
					downRpmS = Utils.clamp( minRpmReduced       - gearboxMogli.ptoRpmThrottleDiff, downRpm, upRpm )
					upRpmS   = Utils.clamp( self.minRequiredRpm + gearboxMogli.ptoRpmThrottleDiff, downRpm, upRpm )
				else
					downRpmS = math.max( self.targetRpm - gearboxMogli.autoShiftRpmDiff, downRpm, math.min( self.minTargetRpm, self.maxTargetRpm - gearboxMogli.ptoRpmThrottleDiff ), minRpmReduced )
					upRpmS   = math.min( self.targetRpm + gearboxMogli.autoShiftRpmDiff, upRpm,   math.max( self.minTargetRpm + gearboxMogli.ptoRpmThrottleDiff, self.maxTargetRpm ) )
				end
				
				local rpmC = self.absWheelSpeedRpmS * gearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbMS.CurrentGearSpeed )
				if      accelerationPedal < -gearboxMogli.accDeadZone
						and self.vehicle.mrGbMS.CurrentGearSpeed > self.vehicle.mrGbMS.LaunchGearSpeed + gearboxMogli.eps then
					-- allow immediate down shift while braking
					downRpm = math.min( math.max( downRpm, self.targetRpm ), upRpm )
				end
				
				local m2g = table.getn( self.vehicle.mrGbMS.Gears )
				local m2r = table.getn( self.vehicle.mrGbMS.Ranges )
				local m22 = table.getn( self.vehicle.mrGbMS.Ranges2 )
									
				local function loop( possibleCombinations, n0, n1, n2 )
					local tmp = {}
					for i,p in pairs( possibleCombinations ) do
						table.insert( tmp, p )
					end
					
					local function push( i0, i1, i2 ) 
						local p={} 
						p[n0]=i0
						p[n1]=i1 
						p[n2]=i2
						return p
					end
					
					local function pop( p ) 
						return p[n0], p[n1], p[n2]
					end
					
					local c0, c1, c2 = pop( { gear   = self.vehicle.mrGbMS.CurrentGear,
																		range1 = self.vehicle.mrGbMS.CurrentRange,
																		range2 = self.vehicle.mrGbMS.CurrentRange2 } )
					local a0, a1, a2 = pop( { gear   = alwaysShiftGears,
																		range1 = alwaysShiftRange,
																		range2 = alwaysShiftRange2 } )
					local r0, r1, r2 = pop( { gear   = self.vehicle.mrGbMS.Gears,
																		range1 = self.vehicle.mrGbMS.Ranges,
																		range2 = self.vehicle.mrGbMS.Ranges2 } )
					
					for _,p in pairs( possibleCombinations ) do					
						for i0,g in pairs(r0) do
							local _, i1, i2     = pop( p )
							local priority      = 0
							local fg, f1, f2
							local tg, t1, t2
							local skip = false
							
							do
								local f2g, t2g = 1, m2g
								local f2r, t2r = 1, m2r
								local f22, t22 = 1, m22
								local q = push( i0, i1, i2 )
								
								if q.range1 == nil or q.range1 < 1 or q.range1 > m2r then
									print(tostring(q))
									gearboxMogli.printCallStack()
								end
																
								f2r = math.max( f2r, Utils.getNoNil( self.vehicle.mrGbMS.Gears[q.gear].minRange, 1 ) )
								t2r = math.min( t2r, Utils.getNoNil( self.vehicle.mrGbMS.Gears[q.gear].maxRange, m2r ) )
								f22 = math.max( f22, Utils.getNoNil( self.vehicle.mrGbMS.Gears[q.gear].minRange2, 1 ) )
								t22 = math.min( t22, Utils.getNoNil( self.vehicle.mrGbMS.Gears[q.gear].maxRange2, m22 ) )
								f2g = math.max( f2g, Utils.getNoNil( self.vehicle.mrGbMS.Ranges[q.range1].minGear, 1 ) )
								t2g = math.min( t2g, Utils.getNoNil( self.vehicle.mrGbMS.Ranges[q.range1].maxGear, m2g ) )
								f22 = math.max( f2r, Utils.getNoNil( self.vehicle.mrGbMS.Ranges[q.range1].minRange2, 1 ) )
								t22 = math.min( t2r, Utils.getNoNil( self.vehicle.mrGbMS.Ranges[q.range1].maxRange2, m22 ) )
								f2g = math.max( f2g, Utils.getNoNil( self.vehicle.mrGbMS.Ranges2[q.range2].minGear, 1 ) )
								t2g = math.min( t2g, Utils.getNoNil( self.vehicle.mrGbMS.Ranges2[q.range2].maxGear, m2g ) )
								f2r = math.max( f2r, Utils.getNoNil( self.vehicle.mrGbMS.Ranges2[q.range2].minRange, 1 ) )
								t2r = math.min( t2r, Utils.getNoNil( self.vehicle.mrGbMS.Ranges2[q.range2].maxRange, m2r ) )

								fg, f1, f2 = pop( { gear=f2g, range1=f2r, range2=f22 } )
								tg, t1, t2 = pop( { gear=f2g, range1=f2r, range2=f22 } )
							end
							
							if self.vehicle.mrGbMS.ReverseActive  then
								if g.forwardOnly then
									skip = true
								end
							else
								if g.reverseOnly then
									skip = true
								end
							end
							
							if a0 or ( ( i1 == c1 or a1 ) and ( i2 == c2 or a2 ) ) then
								priority = 0
							else				
							--skip     = true
								priority = 10
							end
							
								-- keep the complete range!!!
							if     i0 > c0 then
								if     n0 == "gear" and n1 == "range1" then
									i1 = Utils.clamp( i1 + r0[c0].upRangeOffset,1, m2r )
								elseif n0 == "range1" and n1 == "gear" then
									i1 = Utils.clamp( i1 + r0[c0].upGearOffset, 1, m2g )
								end
							elseif i0 < c0 then
								if     n0 == "gear" and n1 == "range1" then
									i1 = Utils.clamp( i1 + r0[c0].downRangeOffset,1, m2r )
								elseif n0 == "range1" and n1 == "gear" then
									i1 = Utils.clamp( i1 + r0[c0].downGearOffset, 1, m2g )
								end
							end
							
							if not skip then
								if p.priority > priority then
									priority = p.priority
								end
								
								for _,q in pairs( tmp ) do
									local j0, j1, j2 = pop( q )
									if j0 == i0 and j1 == i1 and j2 == i2 then
										if q.priority > priority then
											q.priority = priority 
										end
										skip = true
										break 
									end
								end
								
								if not skip then
									local q = push( i0, i1, i2 )
									q.priority = priority
									table.insert( tmp, q )
								end
							end
						end
					end
					
					return tmp
				end
						
				-- loop over gears 
				if self.vehicle:mrGbMGetAutoShiftGears() then
					possibleCombinations = loop( possibleCombinations, "gear", "range1", "range2" )
				end
						
				-- loop over range1
				if self.vehicle:mrGbMGetAutoShiftRange() then
					possibleCombinations = loop( possibleCombinations, "range1", "gear", "range2" )
				end
								
				-- loop over range2
				if self.vehicle:mrGbMGetAutoShiftRange2() then
					possibleCombinations = loop( possibleCombinations, "range2", "gear", "range1" )
				end
				
				local minTimeToShift = math.huge
				local refSpeed = self.vehicle.mrGbMS.CurrentGearSpeed --math.max( self.vehicle.mrGbMS.LaunchGearSpeed, self.vehicle.mrGbMS.CurrentGearSpeed )
				
				do
					local tmp = {}
					for i,p in pairs( possibleCombinations ) do
						local i2g = p.gear
						local i2r = p.range1
						local i22 = p.range2
						if not ( gearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Gears[i2g],   i2g, i2r, i22 )
									or gearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Ranges[i2r],  i2g, i2r, i22 )
									or gearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Ranges2[i22], i2g, i2r, i22 ) ) then
							p.gearSpeed = gearMaxSpeed * self.vehicle.mrGbMS.Gears[p.gear].speed 
																	* self.vehicle.mrGbMS.Ranges[p.range1].ratio
																	* self.vehicle.mrGbMS.Ranges2[p.range2].ratio
							p.isCurrent   = true
							p.timeToShiftMax = 0
							p.timeToShiftSum = 0
							
							if p.gear ~= self.vehicle.mrGbMS.CurrentGear then
								p.isCurrent      = false
								local timeToShift = self.vehicle.mrGbMS.GearTimeToShiftGear
								if      self.vehicle.mrGbMS.CurrentGear < p.gear
										and self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].upShiftMs ~= nil
										and self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].upShiftMs > timeToShift then
									timeToShift = self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].upShiftMs
								end
								if      self.vehicle.mrGbMS.CurrentGear > p.gear
										and self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].downShiftMs ~= nil
										and self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].downShiftMs > timeToShift then
									timeToShift = self.vehicle.mrGbMS.Gears[self.vehicle.mrGbMS.CurrentGear].downShiftMs
								end
								p.timeToShiftMax = math.max( p.timeToShiftMax, timeToShift )
								p.timeToShiftSum = p.timeToShiftSum + timeToShift
								p.priority       = math.max( p.priority, self.vehicle.mrGbMS.AutoShiftPriorityG )
							end
							if p.range1 ~= self.vehicle.mrGbMS.CurrentRange then
								p.isCurrent      = false
								local timeToShift = self.vehicle.mrGbMS.GearTimeToShiftHl
								if      self.vehicle.mrGbMS.CurrentRange < p.gear
										and self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].upShiftMs ~= nil
										and self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].upShiftMs > timeToShift then
									timeToShift = self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].upShiftMs
								end
								if      self.vehicle.mrGbMS.CurrentRange > p.gear
										and self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].downShiftMs ~= nil
										and self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].downShiftMs > timeToShift then
									timeToShift = self.vehicle.mrGbMS.Ranges[self.vehicle.mrGbMS.CurrentRange].downShiftMs
								end
								p.timeToShiftMax = math.max( p.timeToShiftMax, timeToShift )
								p.timeToShiftSum = p.timeToShiftSum + timeToShift
								p.priority       = math.max( p.priority, self.vehicle.mrGbMS.AutoShiftPriorityR )
							end
							if p.range2 ~= self.vehicle.mrGbMS.CurrentRange2 then
								p.isCurrent      = false
								local timeToShift = self.vehicle.mrGbMS.GearTimeToShiftRanges2
								if      self.vehicle.mrGbMS.CurrentRange2 < p.gear
										and self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].upShiftMs ~= nil
										and self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].upShiftMs > timeToShift then
									timeToShift = self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].upShiftMs
								end
								if      self.vehicle.mrGbMS.CurrentRange2 > p.gear
										and self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].downShiftMs ~= nil
										and self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].downShiftMs > timeToShift then
									timeToShift = self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].downShiftMs
								end
								p.timeToShiftMax = math.max( p.timeToShiftMax, timeToShift )
								p.timeToShiftSum = p.timeToShiftSum + timeToShift
								p.priority       = math.max( p.priority, self.vehicle.mrGbMS.AutoShiftPriority2 )
							end
							
							if      p.priority == 1 
									and ( p.timeToShiftMax <= self.vehicle.mrGbMG.maxTimeToSkipGear 
										 or accelerationPedal < -gearboxMogli.accDeadZone
										 or ( accelerationPedal > 0.8 and self.deltaRpm < -gearboxMogli.autoShiftMaxDeltaRpm-gearboxMogli.autoShiftMaxDeltaRpm ) ) then
								p.priority = 0
							end
							
							p.plog = 0
							-- 0.6667 .. 1.3333 => 0
							-- < 0.5 or > 23    => 3
							if p.gearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed then
							  p.plog   = math.min( math.max( 0, math.abs( math.log( p.gearSpeed / self.vehicle.mrGbMS.CurrentGearSpeed ) ) - 0.2877 ) * 7.4, 3 )
							end
							p.priority = p.priority + 0.1 * math.floor( p.plog * 3 )
							
							if not p.isCurrent and minTimeToShift > p.timeToShiftMax then
								minTimeToShift = p.timeToShiftMax
							end
							
							table.insert( tmp, p )
						end
					end
					possibleCombinations = tmp
				end
								
				local function sortGears( a, b )
					for _,comp in pairs( {"gearSpeed","timeToShiftMax","gear","range1","range2"} ) do
						if     a[comp] < b[comp] - gearboxMogli.eps then
							return true
						elseif a[comp] > b[comp] + gearboxMogli.eps then
							return false
						end
					end
					return false
				end
				table.sort( possibleCombinations, sortGears )
				
				local dumpIt = string.format("%4.2f ",self.vehicle.mrGbMS.CurrentGearSpeed)
				for i,p in pairs( possibleCombinations ) do
					dumpIt = dumpIt .. string.format("%2d: %4.2f %4.2f %4.2f ",i,p.gearSpeed,p.plog,p.priority)
				end
				
				local maxGear   = table.getn( possibleCombinations )
				local currentGearPower = self.absWheelSpeedRpmS * gearRatio
				
				if self.vehicle.mrGbMS.CurMinRpm < currentGearPower and currentGearPower < self.vehicle.mrGbMS.CurMaxRpm then
					currentGearPower = currentGearPower * self.currentTorqueCurve:get( currentGearPower )
				else
					currentGearPower = 0
				end

				local maxDcSpeed = math.huge
				
				if      self.vehicle.dCcheckModule ~= nil
						and self.vehicle:dCcheckModule("gasAndGearLimiter") 
						and self.vehicle.driveControl.gasGearLimiter.gearLimiter ~= nil 
						and self.vehicle.driveControl.gasGearLimiter.gearLimiter < 1.0 then				
					maxDcSpeed = self.vehicle.driveControl.gasGearLimiter.gearLimiter * possibleCombinations[maxGear][4]
				end

				local upTimerMode   = 1
				local downTimerMode = 1

				if accelerationPedal < gearboxMogli.accDeadZone then
					self.lastAccelerationStart = g_currentMission.time
				elseif self.lastAccelerationStart == nil then
					self.lastAccelerationStart = 0
				end
				
				if      self.lastRealMotorRpm   > upRpm
						and ( self.lastRealMotorRpm > self.vehicle.mrGbMS.MaxTargetRpm 
							 or self.clutchRpm        > upRpm ) then
					-- allow immediate up shift
					upTimerMode   = -1
				elseif  accelerationPedal                    < -gearboxMogli.accDeadZone
						and self.vehicle.mrGbMS.CurrentGearSpeed > self.vehicle.mrGbMS.LaunchGearSpeed + gearboxMogli.eps then
					-- allow immediate down shift while braking
					upTimerMode   = 2
					downTimerMode = 1
				elseif  self.clutchOverheatTimer ~= nil
						and self.clutchPercent       < self.vehicle.mrGbMS.MaxClutchPercent - 0.1
						and self.clutchOverheatTimer > 0.5 * self.vehicle.mrGbMS.ClutchOverheatStartTime then
					downTimerMode = -1
				elseif  self.clutchRpm           < downRpm then
					-- allow down shift after short timeout
				--if self.vehicle.mrGbMS.CurrentGearSpeed > self.vehicle.mrGbMS.LaunchGearSpeed then
				--	downTimerMode = 0
				--end
				elseif  self.vehicle.cruiseControl.state > 0 
						and self.vehicle.mrGbMS.CurrentGearSpeed * downRpm / self.vehicle.mrGbMS.RatedRpm > currentSpeedLimit then
					-- allow down shift after short timeout
				elseif self.vehicle.mrGbML.lastGearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
					downTimerMode = 2
				elseif self.vehicle.mrGbML.lastGearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
					upTimerMode   = 2
				end		
				
				if     self.vehicle.mrGbMS.AutoShiftRequest > 0 then
					downTimerMode = 2
					upTimeMode    = 0
				elseif self.vehicle.mrGbMS.AutoShiftRequest < 0 then
					downTimerMode = 0
					upTimeMode    = 2
				end
				
				local sMin = nil
				local sMax = nil
				
				local bestScore = math.huge
				local bestGear  = -1
				local bestSpeed = gearboxMogli.eps
				
				local currScore = math.huge
				local currGear  = -1
				local currSpeed = gearboxMogli.eps
				
				local nextScore = math.huge
				local nextGear  = -1
				local nextSpeed = gearboxMogli.eps
				
				if self.lastAutoShiftScore ~= nil then 
					for _,g in pairs( self.lastAutoShiftScore ) do 
						for _,r1 in pairs( g ) do 
							for _,r2 in pairs( r1 ) do 
								r2.lastValid = r2.nextValid 
								r2.nextValid = false 								
							end 
						end 
					end 
				end 
				
				for i,p in pairs( possibleCombinations ) do
					p.score = math.huge
					p.rpmHi = self.absWheelSpeedRpmS * gearboxMogli.gearSpeedToRatio( self.vehicle, p.gearSpeed )
					p.rpmLo = p.rpmHi					
					--**********************************************************************************--
					-- estimate speed lost: 5.4 km/h lost at wheelLoad above 50 kNm for every 800 ms					
					if      p.timeToShiftMax    > 0 
							and accelerationPedal   > 0
							and p.gearSpeed         > 0 
							and self.maxMotorTorque > 0 
							and p.rpmHi            <= upRpm then
						-- rpmLo can become negative !!!
						p.rpmLo = p.rpmHi - p.timeToShiftMax * 0.00125 * Utils.clamp( self.wheelLoadS * 0.02, 0, 1 ) * self.vehicle.mrGbMS.RatedRpm / p.gearSpeed
						
						p.rpmLo = math.max( 0.5 * p.rpmHi, p.rpmLo )
					--if p.rpmHi >= downRpm and p.rpmLo < downRpm then p.rpmLo = downRpm end						
					end
					
					local isValidEntry = true
					
					if     p.rpmLo > upRpm then
						isValidEntry = false
					elseif downRpm                   <= rpmC and rpmC <= upRpm
							and p.rpmLo + gearboxMogli.eps < rpmC and rpmC < p.rpmHi - gearboxMogli.eps
							and p.timeToShiftMax           > self.vehicle.mrGbMG.maxTimeToSkipGear then
						-- the current gear is still valid => keep it
						p.priority = math.max( p.priority, 8 )
					elseif p.rpmHi < rpmC and rpmC < downRpm then
						-- the current gear is better than the new one
						p.priority = math.max( p.priority, 9 )
					elseif p.rpmHi > rpmC and rpmC > upRpm   then
						-- the current gear is better than the new one
						p.priority = math.max( p.priority, 9 )
					end

					if     self.vehicle.mrGbMS.AutoShiftRequest > 0 then
						if p.gearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
							isValidEntry = false 
						end
					elseif self.vehicle.mrGbMS.AutoShiftRequest < 0 then
						if p.gearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
							isValidEntry = false 
						end
					else
					
						if      self.vehicle.mrGbML.DirectionChangeTime ~= nil
								and g_currentMission.time  < self.vehicle.mrGbML.DirectionChangeTime + self.vehicle.mrGbMG.autoShiftTimeoutLong
								and p.gearSpeed            < self.vehicle.mrGbMS.LaunchGearSpeed - gearboxMogli.eps 
								and p.gearSpeed            < self.vehicle.mrGbMS.CurrentGearSpeed then
							isValidEntry = false
							dumpIt = dumpIt .. string.format("\n%d is not valid (a)",i)
						end
						
						-- no down shift if just idling  
						if      accelerationPedal      <  gearboxMogli.accDeadZone
								and downTimerMode          > 0
								and p.gearSpeed            < self.vehicle.mrGbMS.LaunchGearSpeed - gearboxMogli.eps 
								and p.gearSpeed            < self.vehicle.mrGbMS.CurrentGearSpeed
								and self.stallWarningTimer == nil 
								then
							isValidEntry = false
							dumpIt = dumpIt .. string.format("\n%d is not valid (b)",i)
						end
					end
						
					if p.gearSpeed * 3.6 < self.vehicle.mrGbMG.minAutoGearSpeed then
					--p.priority = 10
						isValidEntry = false
						dumpIt = dumpIt .. string.format("\n%d is not valid (c)",i)
					end
					if      self.vehicle.mrGbMS.MinAutoGearSpeed > self.vehicle.mrGbMG.minAutoGearSpeed 
							and p.gearSpeed * 3.6 < self.vehicle.mrGbMS.MinAutoGearSpeed then
						isValidEntry = false
						dumpIt = dumpIt .. string.format("\n%d is not valid (c)",i)
					end
					if      self.vehicle.mrGbMS.MaxAutoGearSpeed > self.vehicle.mrGbMG.minAutoGearSpeed 
							and p.gearSpeed * 3.6 > self.vehicle.mrGbMS.MaxAutoGearSpeed then
						isValidEntry = false
						dumpIt = dumpIt .. string.format("\n%d is not valid (c)",i)
					end					
						
					if p.gearSpeed > maxDcSpeed then
						p.priority = 10
					end
					
					if      self.vehicle.cruiseControl.state > 0 
							and p.gearSpeed * self.vehicle.mrGbMS.IdleRpm > currentSpeedLimit * self.vehicle.mrGbMS.RatedRpm then
						p.priority = 10
					end			
					
					if      isValidEntry 
							and not p.isCurrent then
						if      self.torqueRpmReduxMode ~= nil
								and p.gearSpeed   > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
							isValidEntry = false
							dumpIt = dumpIt .. string.format("\n%d is not valid (d)",i)
						elseif  self.deltaRpm < -gearboxMogli.autoShiftMaxDeltaRpm
								and p.gearSpeed   > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
							isValidEntry = false
							dumpIt = dumpIt .. string.format("\n%d is not valid (d)",i)
						elseif  self.deltaRpm > gearboxMogli.autoShiftMaxDeltaRpm
								and p.gearSpeed   < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
							isValidEntry = false
							dumpIt = dumpIt .. string.format("\n%d is not valid (e)",i)
						end
					end
					
					if      isValidEntry 
							and not p.isCurrent 
							and self.vehicle.mrGbMS.AutoShiftTimeoutLong > 0 then
							
						local autoShiftTimeout = 0
						if     p.gearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
							autoShiftTimeout = downTimerMode							
						elseif p.gearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
							autoShiftTimeout = upTimerMode
						else
							autoShiftTimeout = math.max( 0, math.min( downTimerMode, upTimerMode ) )
						end
						
						local refTime	
						if      accelerationPedal < -gearboxMogli.accDeadZone
								and p.gearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps 
								and p.gearSpeed > self.vehicle.mrGbMS.LaunchGearSpeed  - gearboxMogli.eps then
							refTime = self.vehicle.mrGbML.autoShiftTime		
						elseif  autoShiftTimeout < 0 then 
							refTime = self.vehicle.mrGbML.autoShiftTime
						elseif  p.gearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
							refTime = math.max( self.lastAccelerationStart, self.lastClutchClosedTime )
						else
							refTime = self.lastClutchClosedTime
						end
						
						if     autoShiftTimeout >= 2 then
							autoShiftTimeout = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutLong
						elseif p.priority >= 3 then
							autoShiftTimeout = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort * ( 3 + autoShiftTimeout )
						elseif p.priority >= 2 then
							autoShiftTimeout = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort * ( 2 + autoShiftTimeout )
						elseif p.priority >= 1 then
							autoShiftTimeout = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort * 2
						elseif autoShiftTimeout > 0 then
							autoShiftTimeout = refTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort 
						else 
							autoShiftTimeout = refTime
						end
						autoShiftTimeout   = math.max( autoShiftTimeout, refTime + 100 )
						if     autoShiftTimeout + minTimeToShift   > g_currentMission.time then
							isValidEntry = false
							dumpIt = dumpIt .. string.format("\n%d is not valid (f)",i)
						elseif autoShiftTimeout + p.timeToShiftSum > g_currentMission.time then
							p.priority = math.max( p.priority, 7 )
						end
					end
					
					if isValidEntry or self.vehicle.mrGbMG.debugPrint or gearboxMogli.debugGearShift or self.vehicle.mrGbML.autoShiftInfoPrint then
            local testRpm
						
						testRpm = self:getRpmScore( p.rpmLo, downRpmS, upRpmS )
						if p.rpmHi > p.rpmLo then
							testRpm = math.max( testRpm, self:getRpmScore( p.rpmHi, downRpmS, upRpmS ) )
						end

						local testPwr = 0
						if accelerationPedal > 0 or self.vehicle.mrGbMS.ConstantRpm then
							local t2 = p.rpmLo * self.currentTorqueCurve:get( p.rpmLo ) -- * gearboxMogli.autoShiftPowerRatio
							
							local deltaRatio = 0.15
							if getMaxPower then
								deltaRatio = 0.03
							elseif self.requestedPower > 0.99 * self.currentMaxPower then
								deltaRatio = 0.05
							elseif self.requestedPower > 0.80 * self.currentMaxPower then
								deltaRatio = 0.15 - 0.5 * ( self.requestedPower / self.currentMaxPower - 0.8 )
							end
						
							testPwr = Utils.clamp( ( self.requestedPower - t2 ) / self.currentMaxPower - deltaRatio, 0, 1 )
						end
						
						if     testRpm > 0 then
						-- reach RPM window
							p.score = 3 + testRpm
						elseif testPwr > 0 then
						-- and optimize power afterwards
							p.score = 2 + testPwr
						elseif p.priority >= 2
								or ( p.priority >= 1 and p.gearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps ) then
						-- sort by priority 
							p.score = 1 + 0.1 * math.min( p.priority, 10 )
						elseif self.vehicle.mrGbMS.ConstantRpm then
						-- PTO => optimize target RPM
							p.score = math.abs( self.targetRpm - p.rpmHi ) / self.vehicle.mrGbMS.RatedRpm
						elseif accelerationPedal < -gearboxMogli.accDeadZone then
						-- braking
							p.score = math.abs( self.targetRpm - p.rpmHi ) / self.vehicle.mrGbMS.RatedRpm
						elseif accelerationPedal <  gearboxMogli.accDeadZone then
						-- no acceleration => no fuel => optimize target RPM
							p.score = 0.1 + 0.9 * math.abs( self.targetRpm - p.rpmHi ) / self.vehicle.mrGbMS.RatedRpm
							if p.isCurrent then
								p.score = 0
							end
						else
						-- optimize fuel usage ratio
							p.score = Utils.clamp( 0.001 * self.fuelCurve:get( p.rpmHi ), 0, 0.4 )
							if p.rpmLo < p.rpmHi then
								p.score = math.max( p.score, Utils.clamp( 0.001 * self.fuelCurve:get( p.rpmLo ), 0, 0.4 ) )
							end
							if p.isCurrent then
								p.score = p.score * 0.99
							end
						end
					end
					
					if isValidEntry then
						if self.lastAutoShiftScore == nil then	 
							self.lastAutoShiftScore = {} 
						end 
						--p.gear  
						--p.range2
						--p.range1
						
						if self.lastAutoShiftScore[p.gear] == nil then 
							self.lastAutoShiftScore[p.gear] = {} 
						end 
						if self.lastAutoShiftScore[p.gear][p.range1] == nil then 
							self.lastAutoShiftScore[p.gear][p.range1] = {} 
						end 
						if self.lastAutoShiftScore[p.gear][p.range1][p.range2] == nil then 
							self.lastAutoShiftScore[p.gear][p.range1][p.range2] = {} 
						end 
						local lastScore = self.lastAutoShiftScore[p.gear][p.range1][p.range2] 
						
						if lastScore.lastValid then 
							lastScore.score = lastScore.score + self.vehicle.mrGbML.smoothFast * ( p.score - lastScore.score ) 
						else 
							lastScore.score = 4 + self.vehicle.mrGbML.smoothFast * ( p.score - 4 ) 
						end 
						p.score = lastScore.score
						lastScore.nextValid = true 
					
						-- gear is possible 																			
						if     bestScore == nil
								or bestScore > p.score
								or ( math.abs( bestScore - p.score ) < 1e-4
								 and math.abs( self.vehicle.mrGbMS.CurrentGearSpeed - p.gearSpeed ) < math.abs( self.vehicle.mrGbMS.CurrentGearSpeed - bestSpeed ) )
								then
							bestScore = p.score
							bestGear  = i
							bestSpeed = p.gearSpeed
						end		
						
						if p.isCurrent then
							currScore = p.score
							currGear  = i
							currSpeed = p.gearSpeed
						else
							if     nextScore == nil
									or nextScore > p.score
									or ( math.abs( nextScore - p.score ) < 1e-4
									 and math.abs( self.vehicle.mrGbMS.CurrentGearSpeed - p.gearSpeed ) < math.abs( self.vehicle.mrGbMS.CurrentGearSpeed - nextSpeed ) )
									then
								nextScore = p.score
								nextGear  = i
								nextSpeed = p.gearSpeed
							end		
						end	
						
					end
				end
						
				self.vehicle.mrGbDump = dumpIt 
				
				local bestRpmLo, bestRpmHi = -1, -1
				if possibleCombinations[bestGear] ~= nil then
					p = possibleCombinations[bestGear]
					bestRpmLo = p.rpmLo
					bestRpmHi = p.rpmHi
				end
				local nextRpmLo, nextRpmHi = -1, -1
				if possibleCombinations[nextGear] ~= nil then
					p = possibleCombinations[nextGear]
					nextRpmLo = p.rpmLo
					nextRpmHi = p.rpmHi
				end
				
				self.vehicle.mrGbML.autoShiftInfo = string.format("%4d / %4d (%4g) / %4d..%4d %3d%% / %1d %1d\ncurrent: %6.3f %2d %5.2f\nbest: %6.3f %2d %5.2f %4d %4d\nnext: %6.3f %2d %5.2f %4d %4d",
																													rpmC,
																													self.lastRealMotorRpm,
																													self.deltaRpm,
																													downRpmS,
																													upRpmS,
																													accelerationPedal*100,
																													upTimerMode,
																													downTimerMode,
																													Utils.getNoNil( currScore, -1 ),
																													Utils.getNoNil( currGear,  -1 ),
																													Utils.getNoNil( currSpeed, -1 ),
																													Utils.getNoNil( bestScore, -1 ),
																													Utils.getNoNil( bestGear,  -1 ),
																													Utils.getNoNil( bestSpeed, -1 ),
																													Utils.getNoNil( bestRpmLo, -1 ),
																													Utils.getNoNil( bestRpmHi, -1 ),
																													Utils.getNoNil( nextScore, -1 ),
																													Utils.getNoNil( nextGear,  -1 ),
																													Utils.getNoNil( nextSpeed, -1 ),
																													Utils.getNoNil( nextRpmLo, -1 ),
																													Utils.getNoNil( nextRpmHi, -1 ) )
				
				local doit = self.vehicle.mrGbML.autoShiftInfoPrint
				
				if bestGear ~= nil and possibleCombinations[bestGear] ~= nil then
					local p = possibleCombinations[bestGear]
					if     p.gear   ~= self.vehicle.mrGbMS.CurrentGear 
							or p.range2 ~= self.vehicle.mrGbMS.CurrentRange2 
							or p.range1 ~= self.vehicle.mrGbMS.CurrentRange then
							
						if self.vehicle.mrGbMG.debugPrint or gearboxMogli.debugGearShift then doit = true end
						
						self.vehicle:mrGbMSetState( "CurrentGear",   p.gear ) 		
						self.vehicle:mrGbMSetState( "CurrentRange",  p.range1 ) 
						self.vehicle:mrGbMSetState( "CurrentRange2", p.range2 )
	
						clutchMode                           = 2
						self.vehicle.mrGbML.manualClutchTime = 0
					end
				end										
				
				if doit then
					self.vehicle.mrGbML.autoShiftInfoPrint = false
					for i,p in pairs(possibleCombinations) do
						print(string.format("%2d, %2d, %2d (%1d): %5.2f",p.gear,p.range1,p.range2,p.priority,p.gearSpeed*3.6)
																..", "..tostring(self.vehicle.mrGbMS.Ranges2[p.range2].name)
																..", "..tostring(self.vehicle.mrGbMS.Gears[p.gear].name)
																..", "..tostring(self.vehicle.mrGbMS.Ranges[p.range1].name)
																..", "..string.format("%4d (%4d)",p.rpmHi,p.rpmLo)
																..", "..tostring(p.isCurrent)
																.." => "..tostring(p.score))
					end
					print(self.vehicle.mrGbML.autoShiftInfo)
				end
				
			end
		end
		
	--**********************************************************************************************************		
	-- min thorttle part II		
		if     accelerationPedal < -gearboxMogli.accDeadZone then
			minThrottle = 0
		elseif self.clutchPercent < gearboxMogli.eps then 
			minThrottle = 0
		end
		local minusRpm    = - maxDeltaThrottle 
		local plusRpm     = maxDeltaThrottle 
		if self.stallWarningTimer ~= nil then
			plusRpm = gearboxMogli.huge 
		elseif not ( self.vehicle.mrGbMS.TorqueConverterOrHydro ) and self.clutchPercent >= gearboxMogli.eps then  
			plusRpm = plusRpm * self.clutchPercent
		end
		self.minThrottle  = Utils.clamp( self.minThrottle + Utils.clamp( minThrottle - self.minThrottle, minusRpm, plusRpm ), 0, 1 )
	end
	
	--**********************************************************************************************************		
	-- clutch			
	
	local lastTCR = self.lastTorqueConverterRatio 
	local lastTCL = self.torqueConverterLockupMs
	local lastCOT = self.lastClutchOpenTime
	local lastCCF = self.lastClutchCloseForced
	if lastTCR ~= nil and lastTCR > 0 then 
		local d = self.tickDt / math.max( 10, self.vehicle.mrGbMS.TorqueConverterTime )
		if self.noTransmission then 
			d = d * 10
		end 
		self.lastTorqueConverterRatio = math.max( 0, lastTCR - d )
	end 		
	self.torqueConverterLockupMs  = nil
	self.lastClutchOpenTime       = nil
	self.lastClutchCloseForced    = nil
	
	if      not ( self.vehicle.isMotorStarted ) then 
		self.throttleRpm = math.max( 0, self.throttleRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor ) 
	elseif  self.clutchPercent > 0.999         
			and not lastNoTransmission              
			and not self.noTransmission then 
		self.throttleRpm = self.lastRealMotorRpm 
	else 
		local r = self:getThrottleMaxRpm( math.max( 0, handThrottle, accelerationPedal ), true )
		
		if brakeNeutral == 2 then 
			r = self.vehicle.mrGbMS.IdleRpm
		elseif not self.vehicle.mrGbMS.NeutralActive and self.vehicle.mrGbML.gearShiftingNeeded > 0 then 
			if      self.vehicle.mrGbML.gearShiftingNeeded == 1
					and self.vehicle.mrGbML.beforeShiftRpm     ~= nil
					and self.vehicle.mrGbML.gearShiftingEffect then
				r = self.vehicle.mrGbML.beforeShiftRpm
			elseif  self.vehicle.mrGbML.gearShiftingNeeded == 2 then 
				r = self.vehicle.mrGbMS.MaxTargetRpm
			else 
				r = self.vehicle.mrGbMS.IdleRpm
			end
		elseif self.noTorque then 
			r = self.vehicle.mrGbMS.IdleRpm
		elseif self.torqueRpmReduction ~= nil then
			r = math.min( math.max( self.torqueRpmReference - self.torqueRpmReduction, self.vehicle.mrGbMS.CurMinRpm ), r )
		end
		
		self.throttleRpm = math.max( math.min( self.minRequiredRpm, self.lastMotorRpm + self.tickDt * self.vehicle.mrGbMS.RpmIncFactorNeutral),
																 self.throttleRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, 
																 math.min( r, self.throttleRpm + self.tickDt * self.vehicle.mrGbMS.RpmIncFactorNeutral ) )
	end 
	
	if self.vehicle.mrGbMG.debugInfo then
		self.vehicle.mrGbML.clutchDebug = ""
	end
	
	if self.noTransmission then
		self.lastClutchOpenTime = g_currentMission.time 
		self.autoClutchPercent  = 0 
	elseif clutchMode < 0 then
		self.autoClutchPercent  = self.vehicle.mrGbMS.MaxClutchPercent
	elseif clutchMode > 0 then
		local openRpm   = self.vehicle.mrGbMS.OpenRpm  + self.vehicle.mrGbMS.ClutchRpmShift * math.max( 1.4*self.motorLoadS - 0.4, 0 )
		local closeRpm  = self.vehicle.mrGbMS.CloseRpm + self.vehicle.mrGbMS.ClutchRpmShift * math.max( 1.4*self.motorLoadS - 0.4, 0 ) 
		local targetRpm = self.targetRpm
		local r0 = math.min( self.minRequiredRpm * 1.1, math.max( self.vehicle.mrGbMS.IdleRpm * 1.1, self.targetRpm ) )		
		if targetRpm > r0 then 
			if accelerationPedal < 0.5 then 
				targetRpm = r0 + 2 * accelerationPedal * ( targetRpm - r0 )
			end 
		else 
			targetRpm = r0
		end		
				
		if     clutchMode > 1 then
			openRpm        = self.maxTargetRpm 
			closeRpm       = self.maxTargetRpm 
			if     self.vehicle.mrGbMS.TorqueConverter then
				targetRpm = self.lastRealMotorRpm
			elseif self.vehicle.mrGbML.afterShiftRpm ~= nil then
				targetRpm = math.max( self.minRequiredRpm, self.vehicle.mrGbML.afterShiftRpm )
			end
	--elseif self.vehicle.mrGbMS.Hydrostatic then
	--	openRpm         = self.vehicle.mrGbMS.CurMaxRpm
	--	closeRpm        = math.min( self.vehicle.mrGbMS.CurMaxRpm, self.targetRpm + gearboxMogli.hydroEffDiff )
	--	if self.vehicle.mrGbMS.AutoShiftUpRpm ~= nil and closeRpm > self.vehicle.mrGbMS.AutoShiftUpRpm then
	--		closeRpm = self.vehicle.mrGbMS.AutoShiftUpRpm 
	--	end
	--	if closeRpm > self.vehicle.mrGbMS.HydrostaticMaxRpm then
	--		closeRpm = self.vehicle.mrGbMS.HydrostaticMaxRpm
	--	end		
		end
		
		if      self.vehicle.mrGbMS.TorqueConverter 
				and self.vehicle.mrGbMS.TorqueConverterLockupMs ~= nil 
				and ( getMaxPower or self.vehicle.mrGbMS.ConstantRpm ) then
			openRpm = math.max( openRpm, closeRpm )
		end
		
		local fromClutchPercent   = gearboxMogli.minClutchPercent + gearboxMogli.minClutchPercent 
		local toClutchPercent     = self.vehicle.mrGbMS.MaxClutchPercent
		
		if      clutchMode > 1 then 
			if     self.vehicle.mrGbML.gearShiftingEffect      then 
				self.torqueConverterLockupMs = lastTCL 
			elseif self.vehicle.mrGbML.afterShiftClutch == nil then
				self.autoClutchPercent = fromClutchPercent
			elseif self.vehicle.mrGbML.afterShiftClutch < 0 then 
				self.autoClutchPercent = self:getClutchPercent( targetRpm, openRpm, closeRpm, fromClutchPercent, fromClutchPercent, toClutchPercent )
			else 
				self.autoClutchPercent = Utils.clamp( self.vehicle.mrGbML.afterShiftClutch, fromClutchPercent, toClutchPercent )
			end
			self.vehicle.mrGbML.afterShiftClutch = nil
			self.lastClutchOpenTime              = g_currentMission.time 

		elseif  self.vehicle.mrGbMS.TorqueConverter
		    and self.vehicle.mrGbMS.TorqueConverterLockupMs ~= nil 
				and self.clutchRpm > closeRpm then 
			-- timer for torque converter lockup clutch
			if lastTCL == nil then
				self.torqueConverterLockupMs = g_currentMission.time + self.vehicle.mrGbMS.TorqueConverterLockupMs
			else
				self.torqueConverterLockupMs = lastTCL 
				if lastTCL > g_currentMission.time and self.autoClutchPercent < 1 then
					local f = ( lastTCL - g_currentMission.time ) / self.vehicle.mrGbMS.TorqueConverterLockupMs
					self.autoClutchPercent = math.max( self.autoClutchPercent, 1 + f * ( self.vehicle.mrGbMS.MaxClutchPercent - 1 ) )			
				else
					self.autoClutchPercent = 1
				end
			end
		else			
			if lastCOT == nil or self.vehicle.mrGbMS.ManualClutch < 0.8 then 
				self.lastClutchOpenTime = g_currentMission.time 
			else 
				self.lastClutchOpenTime = lastCOT
			end
			self.autoClutchPercent = Utils.clamp( self.autoClutchPercent, 0, math.min( self.vehicle.mrGbMS.ManualClutch, self.vehicle.mrGbMS.MaxClutchPercent ) )
			if self.vehicle.mrGbMS.TorqueConverter then		
				
				local d = self.tickDt / math.max( 10, self.vehicle.mrGbMS.TorqueConverterTime + self.motorLoadS * self.vehicle.mrGbMS.TorqueConverterTimeInc )
				if lastTCR == nil or self.vehicle.mrGbMS.ManualClutch < gearboxMogli.eps then
					self.lastTorqueConverterRatio = 0
				elseif self.motorLoadP > 0.3 then
					self.lastTorqueConverterRatio = math.min( 1, lastTCR + d * ( self.motorLoadP - 0.3 ) / 0.7 )
				elseif self.motorLoadP < 0.3 then
					self.lastTorqueConverterRatio = math.max( 0, lastTCR - d * ( 0.3 - self.motorLoadP ) / 0.3 )
				else
					self.lastTorqueConverterRatio = lastTCR
				end
				
				local f = math.sqrt( self.lastTorqueConverterRatio )
				
				if openRpm > self.vehicle.mrGbMS.IdleRpm then
					openRpm = math.min( self.maxTargetRpm + f * ( self.vehicle.mrGbMS.IdleRpm - self.maxTargetRpm ), openRpm )
				end
				closeRpm  = self.maxTargetRpm + f * ( self.vehicle.mrGbMS.MinCloseRpm - self.maxTargetRpm )
			else
				local fx = 2 * ( 1 - self.vehicle.mrGbMS.ShuttleFactor )
				local t0 = fx * self.vehicle.mrGbMS.ClutchTimeIncForced						
				local t1 = math.max( 0, math.min( 250 + 750 * ( fx - 1 ), 0.5 * t0 ) )
				local t2 = t0 - t1 
				
				if lastCCF ~= nil then 
					self.lastClutchCloseForced = lastCCF 
				elseif  self.nonClampedMotorRpm > closeRpm
						and self.nonClampedMotorRpm > minRpmReduced then 
					self.lastClutchCloseForced = g_currentMission.time 
				elseif g_currentMission.time > self.lastClutchOpenTime + t1 then
					self.lastClutchCloseForced = g_currentMission.time 
				end 
				
				if self.lastClutchCloseForced ~= nil then 
					local fc = fromClutchPercent 
					if     g_currentMission.time >= self.lastClutchOpenTime    + t0 then 
						fc = 1 
					elseif g_currentMission.time >= self.lastClutchCloseForced + t2 then 
						fc = 1 
					else 
						fc = self.vehicle.mrGbMS.MinClutchPercent * ( g_currentMission.time - self.lastClutchCloseForced ) / t2
					end 
					fromClutchPercent = math.min( math.max( fc, fromClutchPercent ), toClutchPercent ) 
					if clutchMode <= 1 then 
						-- keep RPM below closeRpm
						targetRpm = math.min( targetRpm, math.max( minRpmReduced, closeRpm ) )
					end
				else 
					-- allow to the rev up before closing the clutch
					targetRpm = math.max( targetRpm, self.throttleRpm )
				end 
				fromClutchPercent = math.min( fromClutchPercent, toClutchPercent )
				closeRpm  = self.vehicle.mrGbMS.MaxTargetRpm
			end 
			
			toClutchPercent   = math.min( toClutchPercent,   
																		math.max( math.min( self.vehicle.mrGbMS.MinClutchPercent, 
																												self.autoClutchPercent + 10 * self.tickDt/self.vehicle.mrGbMS.ClutchTimeInc ),
																							self.autoClutchPercent + self.tickDt/self.vehicle.mrGbMS.ClutchTimeInc ) )
			fromClutchPercent = math.max( fromClutchPercent, self.autoClutchPercent - self.tickDt/self.vehicle.mrGbMS.ClutchTimeDec )
			
			local prevPercent = self.autoClutchPercent
			
			if self.lastOpenRpm == nil then
				self.lastOpenRpm  = openRpm 
				self.lastCloseRpm = closeRpm 
			else 
				d = 0.001 * self.tickDt * ( self.vehicle.mrGbMS.MaxTargetRpm - self.vehicle.mrGbMS.IdleRpm )
				self.lastOpenRpm  = self.lastOpenRpm  + Utils.clamp( openRpm  - self.lastOpenRpm , -d, d )
				self.lastCloseRpm = self.lastCloseRpm + Utils.clamp( closeRpm - self.lastCloseRpm, -d, d )
				openRpm  = self.lastOpenRpm 
				closeRpm = self.lastCloseRpm
			end
				
			self.autoClutchPercent = self:getClutchPercent( targetRpm, openRpm, closeRpm, fromClutchPercent, prevPercent, toClutchPercent )
			
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.clutchDebug = string.format( "%4s = self:getClutchPercent( %4s, %4s, %4s, %4s, %4s, %4s, %4s ) [%4s]",
																												 per2String( self.autoClutchPercent ),
																												 rpm2String( self.nonClampedMotorRpm ),
																												 rpm2String( targetRpm ),
																												 rpm2String( openRpm ),
																												 rpm2String( closeRpm ),
																												 per2String( fromClutchPercent ),
																												 per2String( prevPercent ),
																												 per2String( toClutchPercent ),
																												 rpm2String( minRpmReduced )
																												)																			
			end
		end
	end 					
	
	local lastStallWarningTimer = self.stallWarningTimer
	self.stallWarningTimer = nil
	
	if     self.noTransmission then
		self.clutchPercent = 0
	else
		if     self.vehicle:mrGbMGetAutoClutch()
				or self.vehicle.mrGbMS.TorqueConverterOrHydro then
			self.clutchPercent = math.min( self.autoClutchPercent, self.vehicle.mrGbMS.ManualClutch )
		elseif autoCloseClutch then
		-- shuttle and manual clutch 
			local c = ( g_currentMission.time - autoClutchTimer ) / autoClutchSpeed
			self.clutchPercent = math.min( math.max( c, self.autoClutchPercent ), self.vehicle.mrGbMS.ManualClutch )		
			
			if self.vehicle.mrGbMG.debugInfo then
				self.vehicle.mrGbML.autoCloseClutch = string.format("%5d / %5d, %5.3f, %5.3f => %5.3f", 
																														g_currentMission.time - autoClutchTimer,
																														autoClutchSpeed,
																														c,
																														self.autoClutchPercent,
																														self.vehicle.mrGbMS.ManualClutch ) 
			end
		else
			self.clutchPercent = self.vehicle.mrGbMS.ManualClutch
		end
		
		local minRpm = math.max( 0.5 * self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.CurMinRpm - 100 )
		if      not ( self.noTransmission )
				and self.clutchPercent > 0.1
				and self.nonClampedMotorRpm < minRpm
				and not ( self.vehicle.mrGbMS.Hydrostatic and self.vehicle.mrGbMS.HydrostaticLaunch ) then
			if lastStallWarningTimer == nil then
				self.stallWarningTimer = g_currentMission.time
			else
				self.stallWarningTimer = lastStallWarningTimer
				local w1 = gearboxMogli.getText( "gearboxMogliTEXT_Stall1", "RPM is too low" )
				local w2 = gearboxMogli.getText( "gearboxMogliTEXT_Stall2", "motor stopped because RPM was too low" )
				if     g_currentMission.time > self.stallWarningTimer + self.vehicle.mrGbMG.stallMotorOffTime then
					self.stallWarningTimer = nil
					self:motorStall( string.format("%s (%4.0f < %4.0f)", w2, self.nonClampedMotorRpm, minRpm ),
													 string.format("%s (%4.0f < %4.0f)", w1, self.nonClampedMotorRpm, minRpm ) )
				elseif g_currentMission.time > self.stallWarningTimer + self.vehicle.mrGbMG.stallWarningTime then
					self.vehicle:mrGbMSetState( "WarningText", string.format("%s (%4.0f < %4.0f)", w1, self.nonClampedMotorRpm, minRpm ))
				end		
			end		
		end
		
	end
	
	
	--**********************************************************************************************************		
	-- no transmission => min throttle 
	if self.noTorque       then
		accelerationPedal   = 0
	end
	if self.clutchPercent < gearboxMogli.minClutchPercent then
		self.noTransmission = true
	end

	local it = self.vehicle.mrGbMS.IdleEnrichment + math.max( 0, handThrottle ) * ( 1 - self.vehicle.mrGbMS.IdleEnrichment )
	if     self.lastRealMotorRpm < self.minRequiredRpm - 1 then
		it = 0.5
	elseif self.lastRealMotorRpm > self.minRequiredRpm + 1 then
		it = 0
	end
	self.idleThrottle   = Utils.clamp( self.idleThrottle + Utils.clamp( it - self.idleThrottle, -maxDeltaThrottle, maxDeltaThrottle ), 0, 1 )
	
	local f = 1
	if self.vehicle.mrGbML.gearShiftingNeeded > 0 then
		f = 2
	end

	if self.noTransmission then				
		self.minThrottle  = self.idleThrottle
	end	
	
	--**********************************************************************************************************		
	-- timer for automatic shifting				
	if      self.noTransmission then
		self.lastClutchClosedTime = g_currentMission.time
		self.hydrostaticStartTime = nil
		self.deltaRpm             = 0
	elseif  self.lastClutchClosedTime            > g_currentMission.time 
			and self.clutchPercent                  >= self.vehicle.mrGbMS.MaxClutchPercent - gearboxMogli.eps then
		-- cluch closed => "start" the timer
		self.lastClutchClosedTime = g_currentMission.time 
	elseif  math.abs( accelerationPedal )        < gearboxMogli.accDeadZone
			and self.vehicle.mrGbMS.CurrentGearSpeed < self.vehicle.mrGbMS.LaunchGearSpeed + gearboxMogli.eps 
			and ( self.clutchPercent                >= self.vehicle.mrGbMS.MaxClutchPercent - gearboxMogli.eps
			   or self.vehicle.mrGbMS.TorqueConverter )
			and self.lastClutchClosedTime            < g_currentMission.time 
			and self.vehicle.steeringEnabled
			then
		-- no down shift for small gears w/o throttle
		self.lastClutchClosedTime = g_currentMission.time 
	end
	
	
	--**********************************************************************************************************		
	-- overheating of clutch				
	if self.vehicle.mrGbMS.ClutchCanOverheat and not ( self.vehicle:getIsHired() ) then
		if 0.1 < self.clutchPercent and self.clutchPercent < 0.9 then
			if self.clutchOverheatTimer == nil then
				self.clutchOverheatTimer = 0
			else
				self.clutchOverheatTimer = self.clutchOverheatTimer + self.tickDt * self.motorLoadP * Utils.clamp( 1 - self:getGearRatioFactor(), 0, 1 )
			end

			if self.vehicle.mrGbMS.ClutchOverheatMaxTime > 0 then
				self.clutchOverheatTimer = math.min( self.clutchOverheatTimer, self.vehicle.mrGbMS.ClutchOverheatMaxTime )
			end
			
			if self.clutchOverheatTimer > self.vehicle.mrGbMS.ClutchOverheatStartTime then
				local w = gearboxMogli.getText( "gearboxMogliTEXT_ClutchOverheating", "clutch is overheating" )
				if      self.vehicle.mrGbMS.WarningText ~= nil
						and self.vehicle.mrGbMS.WarningText ~= "" 
						and self.vehicle.mrGbMS.WarningText ~= w 
						and string.len( self.vehicle.mrGbMS.WarningText ) < 200 then
					w = self.vehicle.mrGbMS.WarningText .. " / " .. w
				end
					
				self.vehicle:mrGbMSetState( "WarningText", w )
				
				if self.vehicle.mrGbMS.ClutchOverheatIncTime > 0 then
					local e = 1 + ( self.clutchOverheatTimer - self.vehicle.mrGbMS.ClutchOverheatStartTime ) / self.vehicle.mrGbMS.ClutchOverheatIncTime
					self.clutchPercent = self.clutchPercent ^ e
				end
			end
		elseif self.clutchOverheatTimer ~= nil then
			self.clutchOverheatTimer = self.clutchOverheatTimer - self.tickDt
			
			if self.clutchOverheatTimer < 0 then
				self.clutchOverheatTimer = nil
			end
		end
	elseif self.clutchOverheatTimer ~= nil then 
		self.clutchOverheatTimer = nil
	end

	--**********************************************************************************************************		
	-- calculate max RPM increase based on current RPM
	local tab = self.lastMaxRpmTab 
	self.lastMaxRpmTab = nil 
	
	if      not self.vehicle.mrGbMS.NeutralActive
			and self.vehicle.mrGbML.gearShiftingNeeded == 1 
			and self.vehicle.mrGbML.gearShiftingEffect
			and self.vehicle.mrGbML.beforeShiftRpm     ~= nil 
			and g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime + 150 then
		self.maxPossibleRpm = self.vehicle.mrGbML.beforeShiftRpm
		self.lastMaxRpmTab = { { t = 0, m = self.vehicle.mrGbML.beforeShiftRpm } }
		self.rpmIncFactor   = self.vehicle.mrGbMS.RpmIncFactorNeutral
	elseif self.noTransmission or self.vehicle.mrGbML.gearShiftingNeeded ~= 0 then
		self.maxPossibleRpm = gearboxMogli.huge
		self.rpmIncFactor   = self.vehicle.mrGbMS.RpmIncFactorNeutral
	elseif self.torqueRpmReduxMode ~= nil and self.torqueRpmReduxMode == 2 then
	  self.maxPossibleRpm = math.max( self.torqueRpmReference - self.torqueRpmReduction, self.vehicle.mrGbMS.CurMinRpm )
	elseif self.maxRpmIncrease >= gearboxMogli.huge then
		self.maxPossibleRpm = self.vehicle.mrGbMS.CurMaxRpm
		self.rpmIncFactorS  = self.vehicle.mrGbMS.RpmIncFactor
	else
		local m 
		if tab == nil then
			m = self.vehicle.mrGbMS.CurMaxRpm
			self.lastMaxRpmTab = { { t = 0, m = m } }
		else 
			m = math.max( self.lastRealMotorRpm, self.vehicle.mrGbMS.IdleRpm )
			self.lastMaxRpmTab = { { t = 0, m = m } }
			
			local mm = m
			local cm = 1
			for _,tm in pairs( tab ) do
				local t = tm.t + self.tickDt 
				if t < gearboxMogli.deltaLimitTimeMs then
					table.insert( self.lastMaxRpmTab, { t = t, m = tm.m } )
					mm = mm + tm.m + t * self.rpmIncFactor
					cm = cm + 1
				end
			end
			
			if cm > 1 then
				m = math.max( m, mm / cm )
			end
		end
		
		self.maxPossibleRpm = m + self.maxRpmIncrease
		
		if self.maxPossibleRpm < self.clutchRpm then
			self.maxPossibleRpm = self.clutchRpm
		end
		if self.maxPossibleRpm < minRpmReduced then
			self.maxPossibleRpm = minRpmReduced
		end
		if self.maxPossibleRpm > self.vehicle.mrGbMS.CurMaxRpm then
			self.maxPossibleRpm = self.vehicle.mrGbMS.CurMaxRpm
		end

		if self.vehicle.mrGbML.afterShiftRpm ~= nil then 
			if self.vehicle.mrGbML.gearShiftingEffect then
				if self.maxPossibleRpm > self.vehicle.mrGbML.afterShiftRpm then
					self.maxPossibleRpm               = self.vehicle.mrGbML.afterShiftRpm
					self.vehicle.mrGbML.afterShiftRpm = self.vehicle.mrGbML.afterShiftRpm + self.maxRpmIncrease 
				else
					self.vehicle.mrGbML.afterShiftRpm = nil
				end
			else 
				self.vehicle.mrGbML.afterShiftRpm   = nil
			end
		end
	end
	
	if      self.vehicle.mrGbML.gearShiftingEffect
			and self.vehicle.mrGbML.gearShiftingNeeded == 0
			and g_currentMission.time > self.vehicle.mrGbML.lastShiftTime    + 150
			and g_currentMission.time > self.vehicle.mrGbML.gearShiftingTime + 150 then
		self.vehicle.mrGbML.gearShiftingEffect = false 
		self.vehicle.mrGbML.afterShiftRpm      = nil
	end
	
----**********************************************************************************************************		
---- do not cut torque in case of open clutch or torque converter
--if self.clutchPercent < 1 and self.maxPossibleRpm < self.vehicle.mrGbMS.CloseRpm then
--	self.maxPossibleRpm = self.vehicle.mrGbMS.CloseRpm
--end	
		
	if      self.vehicle:mrGbMGetOnlyHandThrottle()
			and self.nonClampedMotorRpm > math.max( self.minRequiredRpm, handThrottleRpm ) + gearboxMogli.ptoRpmThrottleDiff then 
		self.lastThrottle = self.minThrottle 
	else 
		self.lastThrottle = math.max( self.minThrottle, accelerationPedal )
	end 
	
--**********************************************************************************************************	
	if     self.vehicle.mrGbML.gearShiftingNeeded == gearboxMogli.gearShiftingNoThrottle then
		self.vehicle:mrGbMSetState( "DoubleClutch", 3 )
	elseif self.vehicle.mrGbML.gearShiftingNeeded == 2 then
		self.vehicle:mrGbMSetState( "DoubleClutch", 1 )
	elseif self.vehicle.mrGbML.gearShiftingNeeded  < 0 then
		self.vehicle:mrGbMSetState( "DoubleClutch", 2 )
	elseif self.vehicle.mrGbML.NeutralActive and not self.vehicle:mrGbMGetAutoClutch() and accelerationPedal > 0.1 then
		self.vehicle:mrGbMSetState( "DoubleClutch", 2 )
	else
		self.vehicle:mrGbMSetState( "DoubleClutch", 0 )
	end
	
--**********************************************************************************************************	
-- VehicleMotor.updateGear II
	self.gear, self.gearRatio = self.getBestGear(self, acceleration, self.wheelSpeedRpm, self.vehicle.mrGbMS.CurMaxRpm*0.1, requiredWheelTorque, self.minRequiredRpm )
--**********************************************************************************************************	
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getMotorRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getMotorRpm( cIn )
	if self.noTransmission then
		return self.throttleRpm
	end
	if cIn == nil and self.clutchPercent > 0.999 then
		return self.clutchRpm
	end
	local c = self.clutchPercent
	if type( cIn ) == "number" then
		c = cIn
	end
	return c * self.clutchRpm + ( 1-c ) * self.throttleRpm
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getThrottleMaxRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getThrottleMaxRpm( acc, init )
	if     acc == nil then 
		acc = self.lastThrottle 
	elseif acc >= 1 then
		if init then
			return self.vehicle.mrGbMS.MaxTargetRpm
		end
		return self.maxTargetRpm
	elseif acc <= 0 then
		if init then
			return self.vehicle.mrGbMS.IdleRpm
		end
		return self.minRequiredRpm
	end
	local r = self.vehicle.mrGbMS.IdleRpm + acc * math.max( 0, self.vehicle.mrGbMS.MaxTargetRpm - self.vehicle.mrGbMS.IdleRpm )
	if init then
		return r
	end
	return Utils.clamp( r, self.minRequiredRpm, self.maxTargetRpm )
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getNextPossibleRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getNextPossibleRpm( rpm, lowerRpm, upperRpm )
	local curRpm = self.lastRealMotorRpm
	if self.lastMaxPossibleRpm ~= nil and self.lastMaxPossibleRpm < self.lastRealMotorRpm then
		curRpm     = self.lastMaxPossibleRpm
	end
	
	local l = Utils.getNoNil( lowerRpm, self.vehicle.mrGbMS.CurMinRpm )
	local u = Utils.getNoNil( upperRpm, self.vehicle.mrGbMS.CurMaxRpm )
	if self.torqueRpmReduxMode ~= nil and self.torqueRpmReduxMode == 2 then
		u = math.min( u, self.torqueRpmReference - self.torqueRpmReduction )
		l = math.min( l, self.torqueRpmReference - self.torqueRpmReduction - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor )
	end
	local minRpm = Utils.clamp( curRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, l, u )
	local maxRpm = Utils.clamp( curRpm + self.tickDt * self.rpmIncFactor,                l, u )
	
	if     rpm < minRpm then
		return minRpm
	elseif rpm > maxRpm then
		return maxRpm
	end
	
	return rpm
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getClutchPercent
--**********************************************************************************************************	
function gearboxMogliMotor:getClutchPercent( targetRpm, openRpm, closeRpm, fromPercent, curPercent, toPercent )

	local minPercent = 0 --self.vehicle.mrGbMS.MinClutchPercent
	local maxPercent = 1 --self.vehicle.mrGbMS.MaxClutchPercent
	
	if fromPercent ~= nil and minPercent < fromPercent then
		minPercent = fromPercent
	end
	if toPercent   ~= nil and maxPercent > toPercent   then
		maxPercent = toPercent 
	end
	
	if minPercent + gearboxMogli.eps > maxPercent then
		return maxPercent 
	end

	if self.throttleRpm < self.clutchRpm then 
		return maxPercent 
	end 
	if self.clutchRpm > closeRpm or self.nonClampedMotorRpm > closeRpm then 
		return maxPercent 
	end 
	if self.nonClampedMotorRpm <= openRpm and self.vehicle.mrGbMS.CurMinRpm < openRpm then
		return minPercent
	end 
		
	local target        = math.max( self.clutchRpm, targetRpm	)
	local eps           = maxPercent - minPercent
	local delta         = ( self.throttleRpm - self.clutchRpm ) * eps	
	local times         = math.max( gearboxMogli.clutchLoopTimes, math.ceil( delta / gearboxMogli.clutchLoopDelta ) )	
	local clutchRpm     = maxPercent * self.clutchRpm + ( 1 - maxPercent ) * self.throttleRpm
	local clutchPercent = maxPercent
	local diff, diffi, rpm
	
	delta = delta / times 
	eps   = eps   / times 
	
	
	for i=0,times do
		clutchRpm = clutchRpm + delta
		diffi     = math.abs( target - clutchRpm )
		if diff == nil or diff > diffi then
			diff = diffi
			clutchPercent = maxPercent - i * eps
		end
	end
		
	return clutchPercent
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getRpmScore
--**********************************************************************************************************	
function gearboxMogliMotor:getRpmScore( rpm, downRpm, upRpm ) 

	local f = downRpm-999
	local t = upRpm  +999

	if rpm < self.vehicle.mrGbMS.IdleRpm or rpm > self.vehicle.mrGbMS.MaxTargetRpm then 
		return 1
	elseif downRpm <= rpm and rpm <= upRpm then
		return 0
	elseif rpm <= f
	    or rpm >= t then
		return 0.999
	elseif rpm < downRpm then
		return ( downRpm - rpm ) * 0.001
	elseif rpm > upRpm then
		return ( rpm - upRpm ) * 0.001
	end
	-- error
	print("warning: invalid parameters in gearboxMogliMotor:getRpmScore( "..tostring(rpm)..", "..tostring(downRpm)..", "..tostring(upRpm).." )")
	return 1
end

--**********************************************************************************************************	
-- gearboxMogliMotor:splitGear
--**********************************************************************************************************	
function gearboxMogliMotor:splitGear( i ) 
	local i2g, i2r = 1, 1
	if     not self.vehicle:mrGbMGetAutoShiftRange() then
		i2g = i
		i2r = self.vehicle.mrGbMS.CurrentRange
	elseif not self.vehicle:mrGbMGetAutoShiftGears() then 
		i2g = self.vehicle.mrGbMS.CurrentGear
		i2r = i
	elseif self.vehicle.mrGbMS.GearTimeToShiftGear > self.vehicle.mrGbMS.GearTimeToShiftHl + 10 then
		-- shifting gears is more expensive => avoid paradox up/down shifts
		i2g = 1
		i2r = i
		local m = table.getn( self.vehicle.mrGbMS.Ranges )
		while i2r > m do
			i2g = i2g + 1
			i2r = i2r - m
		end		
	else
		i2r = 1
		i2g = i
		local m = table.getn( self.vehicle.mrGbMS.Gears )
		while i2g > m do
			i2r = i2r + 1
			i2g = i2g - m
		end
	end
	if i ~= self:combineGear( i2g, i2r ) then
		print("ERROR in GEARBOX: "..tostring(i).." ~= combine( "..tostring(i2r)..", "..tostring(i2g).." )")
	end
	return i2g,i2r
end

--**********************************************************************************************************	
-- gearboxMogliMotor:combineGear
--**********************************************************************************************************	
function gearboxMogliMotor:combineGear( I2g, I2r ) 
	local i2g = Utils.getNoNil( I2g, self.vehicle.mrGbMS.CurrentGear )
	local i2r = Utils.getNoNil( I2r, self.vehicle.mrGbMS.CurrentRange )
	
	if     not self.vehicle:mrGbMGetAutoShiftRange() then
		return i2g
	elseif not self.vehicle:mrGbMGetAutoShiftGears() then 
		return i2r
	elseif self.vehicle.mrGbMS.GearTimeToShiftGear > self.vehicle.mrGbMS.GearTimeToShiftHl + 10 then
		-- shifting gears is more expensive => avoid paradox up/down shifts
		local m = table.getn( self.vehicle.mrGbMS.Ranges )
		return i2r + m * ( i2g-1 )
	else
		local m = table.getn( self.vehicle.mrGbMS.Gears )
		return i2g + m * ( i2r-1 )
	end
	return 1
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getRotInertia
--**********************************************************************************************************	
function gearboxMogliMotor:getTransTorqueAcc( rpm, accIn, torque )
	if accIn <= 0 or torque <= 0 then
		return 0 
	end
	
	local acc = accIn

	if self.vehicle.mrGbMS.PowerManagement then
		local p1 = rpm * torque
		local p0 = 0
		if self.vehicle.mrGbMS.EcoMode then
			p0 = math.min( self.currentMaxPower, 0.9 * self.maxPower )
		else
			p0 = self.maxPower
		end
		p0 = acc * ( p0 - rpm * self.ptoMotorTorque )
		
		local old = acc
		
		if     p0 <= 0 
				or p1 <= 0 then
			acc = 1
		elseif p0 >= p1 then
			acc = 1
		else
			acc = p0 / p1
		end

		if self.vehicle.mrGbMG.debugInfo then
			self.vehicle.mrGbML.accDebugInfo = string.format( "%3.0f%%, %7.3f %7.3f => %3.0f%%", old*100, p0, p1, acc*100 )
		end
	elseif self.vehicle.mrGbMS.EcoMode then
		acc = acc * 0.9
	end		

	return torque * acc 
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getRotInertia
--**********************************************************************************************************	
function gearboxMogliMotor:getRotInertia()
	self.vehicle.mrGbML.momentOfInertia = math.max( self.vehicle.mrGbMG.momentOfInertiaMin, 0.001 * self.moiFactor * self.vehicle.mrGbMS.MomentOfInertia )
	return self.vehicle.mrGbML.momentOfInertia
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getDampingRate
--**********************************************************************************************************	
function gearboxMogliMotor:getDampingRate()
	local r = self.vehicle.mrGbMG.inertiaToDampingRatio * self:getRotInertia()
	return r
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getMaximumForwardSpeed
--**********************************************************************************************************	
function gearboxMogliMotor:getMaximumForwardSpeed()
	local m = self.vehicle.mrGbMS.CurrentGearSpeed
	if self.vehicle.mrGbMS.Hydrostatic then
		m = self.vehicle.mrGbMS.HydrostaticMax * m
	end
	
	if m < self.original.maxForwardSpeed then
		m = 0.5 * m + 0.5 * self.original.maxForwardSpeed
	end
	
	return m             
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getMaximumBackwardSpeed
--**********************************************************************************************************	
function gearboxMogliMotor:getMaximumBackwardSpeed()
	local m = self.vehicle.mrGbMS.CurrentGearSpeed
	if self.vehicle.mrGbMS.Hydrostatic then
		if self.vehicle.mrGbMS.HydrostaticMin < 0 then
			m = -self.vehicle.mrGbMS.HydrostaticMin * m
		else
			m = self.vehicle.mrGbMS.HydrostaticMax * m
		end
	end
	
	if m < self.original.maxBackwardSpeed then
		m = 0.5 * m + 0.5 * self.original.maxBackwardSpeed
	end
	
	return m	
end

end