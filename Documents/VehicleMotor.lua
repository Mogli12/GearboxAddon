--======================================================================================================
-- new
--======================================================================================================
-- Description

		-- Creating new motor

-- Definition

		-- new(integer minRpm, integer maxRpm, float maxForwardSpeed, float maxBackwardSpeed, table torqueCurve, float brakeForce, float forwardGearRatio, float backwardGearRatio, float minForwardGearRatio, float maxForwardGearRatio, float minBackwardGearRatio, float maxBackwardGearRatio, integer ptoMotorRpmRatio, float rpmFadeOutRange, float maxTorque, float maxMotorPower)

-- Arguments
-- integer	minRpm	min rpm
-- integer	maxRpm	max rpm
-- float	maxForwardSpeed	max forward speed
-- float	maxBackwardSpeed	max backward speed
-- table	torqueCurve	torque curve (AnimCurve)
-- float	brakeForce	brake force
-- float	forwardGearRatio	forward gear ratio
-- float	backwardGearRatio	backward gear ratio
-- float	minForwardGearRatio	min forward gear ratio
-- float	maxForwardGearRatio	max forward gear ratio
-- float	minBackwardGearRatio	min backward gear ratio
-- float	maxBackwardGearRatio	max backward gear ratio
-- integer	ptoMotorRpmRatio	pto motor rpm ratio
-- float	rpmFadeOutRange	rpm fade out range
-- float	maxTorque	max torque
-- float	maxMotorPower	max motor power
-- Return Values
-- table	motorInstance	motor instance
--======================================================================================================
-- Code
function VehicleMotor:new(vehicle, minRpm, maxRpm, maxForwardSpeed, maxBackwardSpeed, torqueCurve, brakeForce, forwardGearRatio, backwardGearRatio, minForwardGearRatio, maxForwardGearRatio, minBackwardGearRatio, maxBackwardGearRatio, ptoMotorRpmRatio, rpmFadeOutRange, maxTorque, maxMotorPower, minSpeed)
	local self = {};
	setmetatable(self, VehicleMotor_mt);
	self.vehicle = vehicle;
	self.minRpm = minRpm;
	self.maxRpm = maxRpm;
	self.minSpeed = minSpeed;
	self.maxForwardSpeed = maxForwardSpeed; -- speed in m/s
	self.maxBackwardSpeed = maxBackwardSpeed;
	self.maxClutchTorque = 5; -- amount of torque that can be transferred from motor to clutch/wheels [t m s^-2]
	self.torqueCurve = torqueCurve;
	self.brakeForce = brakeForce;
	self.gear = 0;
	self.gearRatio = 0;
	self.forwardGearRatios = {forwardGearRatio};
	self.backwardGearRatios = {backwardGearRatio};
	self.minForwardGearRatio = minForwardGearRatio;
	self.maxForwardGearRatio = maxForwardGearRatio;
	self.minBackwardGearRatio = minBackwardGearRatio;
	self.maxBackwardGearRatio = maxBackwardGearRatio;
	self.lastRealMotorRpm = 0;
	self.lastMotorRpm = 0;
	self.rpmFadeOutRange = rpmFadeOutRange;
	self.rpmLimit = math.huge;
	self.speedLimit = math.huge; -- Speed limit in km/h
	self.speedLimitAcc = math.huge;
	-- this is not clamped by minRpm
	self.nonClampedMotorRpm = 0;
	self.equalizedMotorRpm = 0;
	self.clutchRpm = 0;
	self.motorLoad = 0;
	self.requiredMotorPower = 0;
	if self.maxForwardSpeed == nil then
		self.maxForwardSpeed = self:calculatePhysicalMaximumForwardSpeed();
	end
	if self.maxBackwardSpeed == nil then
		self.maxBackwardSpeed = self:calculatePhysicalMaximumBackwardSpeed();
	end
	self.maxMotorTorque = self.torqueCurve:getMaximum();
	self.ptoMotorRpmRatio = ptoMotorRpmRatio;
	self.maxMotorPower = maxMotorPower;
	self.rotInertia = 0.001; -- Rotational inertia of the motor, mostly defined by the flywheel [t m^2]
	self.dampingRate = 0.0007; -- Damping rate of the motor if the acceleration pedal is 0 [t m^2 s^-1]
	return self;
end;

--======================================================================================================
-- setLowBrakeForce
--======================================================================================================
-- Description

	-- Set low brake force

-- Definition

	-- setLowBrakeForce(float lowBrakeForceScale, float lowBrakeForceSpeedLimit)

-- Arguments
-- float	lowBrakeForceScale	low brake force scale
-- float	lowBrakeForceSpeedLimit	low brake force speed limit
--======================================================================================================
-- Code
function VehicleMotor:setLowBrakeForce(lowBrakeForceScale, lowBrakeForceSpeedLimit)
	self.lowBrakeForceScale = lowBrakeForceScale;
	self.lowBrakeForceSpeedLimit = lowBrakeForceSpeedLimit;
end;

--======================================================================================================
-- getMaxClutchTorque
--======================================================================================================
-- Description

	-- Returns max clutch torque

-- Definition

	-- getMaxClutchTorque()

-- Return Values
-- float	maxClutchTorque	max clutch torque
--======================================================================================================
-- Code
function VehicleMotor:getMaxClutchTorque()
	return self.maxClutchTorque;
end

--======================================================================================================
-- getRotInertia
--======================================================================================================
-- Description

	-- Returns rotation inertia

-- Definition

	-- getRotInertia()

-- Return Values
-- float	rotInertia	rotation inertia
--======================================================================================================
-- Code
function VehicleMotor:getRotInertia()
	return self.rotInertia;
end

--======================================================================================================
-- setRotInertia
--======================================================================================================
-- Description

	-- Sets rotation inertia

-- Definition

	-- setRotInertia(float rotInertia)

-- Arguments
-- float	rotInertia	rotation inertia
--======================================================================================================
-- Code
function VehicleMotor:setRotInertia(rotInertia)
	self.rotInertia = rotInertia;
end

--======================================================================================================
-- getDampingRate
--======================================================================================================
-- Description

	-- Returns damping rate

-- Definition

	-- getDampingRate()

-- Return Values
-- float	dampingRate	damping rate
--======================================================================================================
-- Code
function VehicleMotor:getDampingRate()
	return self.dampingRate;
end

--======================================================================================================
-- setDampingRate
--======================================================================================================
-- Description

	-- Sets damping rate

-- Definition

	-- setDampingRate(float dampingRate)

-- Arguments
-- float	dampingRate	new damping rate
--======================================================================================================
-- Code
function VehicleMotor:setDampingRate(dampingRate)
	self.dampingRate = dampingRate;
end

--======================================================================================================
-- getMaxTorque
--======================================================================================================
-- Description

	-- Returns max torque

-- Definition

	-- getMaxTorque()

-- Return Values
-- float	maxMotorTorque	max motor torque
--======================================================================================================
-- Code
function VehicleMotor:getMaxTorque()
	return self.maxMotorTorque;
end

--======================================================================================================
-- getBrakeForce
--======================================================================================================
-- Description

	-- Returns brake force

-- Definition

	-- getBrakeForce()

-- Return Values
-- float	brakeForce	brake force
--======================================================================================================
-- Code
function VehicleMotor:getBrakeForce()
	return self.brakeForce;
end

--======================================================================================================
-- getMinRpm
--======================================================================================================
-- Description

	-- Returns min rpm

-- Definition

	-- getMinRpm()

-- Return Values
-- integer	minRpm	min rpm
--======================================================================================================
-- Code
function VehicleMotor:getMinRpm()
	return self.minRpm;
end

--======================================================================================================
-- getMaxRpm
--======================================================================================================
-- Description

	-- Returns max rpm

-- Definition

	-- getMaxRpm()

-- Return Values
-- integer	maxRpm	max rpm
--======================================================================================================
-- Code
function VehicleMotor:getMaxRpm()
	return self.maxRpm;
end

--======================================================================================================
-- getLastMotorRpm
--======================================================================================================
-- Description

	-- Returns last motor rpm damped

-- Definition

	-- getLastMotorRpm()

-- Return Values
-- integer	lastMotorRpm	last motor rpm
--======================================================================================================
-- Code
function VehicleMotor:getLastMotorRpm()
	return self.lastMotorRpm;
end

--======================================================================================================
-- getLastRealMotorRpm
--======================================================================================================
-- Description

	-- Returns last motor rpm real

-- Definition

	-- getLastRealMotorRpm()

-- Return Values
-- integer	lastMotorRpm	last motor rpm
--======================================================================================================
-- Code
function VehicleMotor:getLastRealMotorRpm()
	return self.lastRealMotorRpm;
end

--======================================================================================================
-- setLastRpm
--======================================================================================================
-- Description

	-- Sets last motor rpm

-- Definition

	-- setLastRpm(integer lastRpm)

-- Arguments
-- integer	lastRpm	new last motor rpm
--======================================================================================================
-- Code
function VehicleMotor:setLastRpm(lastRpm)
	self.lastRealMotorRpm = lastRpm;
	self.lastMotorRpm = self.lastMotorRpm * 0.9 + self.lastRealMotorRpm * 0.1;
end

--======================================================================================================
-- getMotorLoad
--======================================================================================================
-- Description

	-- Returns motor load

-- Definition

	-- getMotorLoad()

-- Return Values
-- float	motorLoad	motor load
--======================================================================================================
-- Code
function VehicleMotor:getMotorLoad()
	return self.motorLoad;
end

--======================================================================================================
-- getEqualizedMotorRpm
--======================================================================================================
-- Description

	-- Returns equalized motor rpm

-- Definition

	-- getEqualizedMotorRpm()

-- Return Values
-- integer	equalizedMotorRpm	equalized motor rpm
--======================================================================================================
-- Code
function VehicleMotor:getEqualizedMotorRpm()
	return self.equalizedMotorRpm;
end

--======================================================================================================
-- getPtoMotorRpmRatio
--======================================================================================================
-- Description

	-- Returns pto motor rpm ratio

-- Definition

	-- getPtoMotorRpmRatio()

-- Return Values
-- float	ptoMotorRpmRatio	pto motor rpm ratio
--======================================================================================================
-- Code
function VehicleMotor:getPtoMotorRpmRatio()
	return self.ptoMotorRpmRatio;
end

--======================================================================================================
-- getNonClampedMotorRpm
--======================================================================================================
-- Description

	-- Returns non clamped motor rpm

-- Definition

	-- getNonClampedMotorRpm()

-- Return Values
-- integer	nonClampedMotorRpm	non clamped motor rpm
--======================================================================================================
-- Code
function VehicleMotor:getNonClampedMotorRpm()
	return self.nonClampedMotorRpm;
end

--======================================================================================================
-- getClutchRpm
--======================================================================================================
-- Description

	-- Returns clutch rpm

-- Definition

	-- getClutchRpm()

-- Return Values
-- integer	clutchRpm	clutch rpm
--======================================================================================================
-- Code
function VehicleMotor:getClutchRpm()
	return self.clutchRpm;
end

--======================================================================================================
-- getTorqueCurve
--======================================================================================================
-- Description

	-- Returns torque curve

-- Definition

	-- getTorqueCurve()

-- Return Values
-- table	torqueCurve	torque curve
--======================================================================================================
-- Code
function VehicleMotor:getTorqueCurve()
	return self.torqueCurve;
end

--======================================================================================================
-- getTorque
--======================================================================================================
-- Description

	-- Returns torque

-- Definition

	-- getTorque(float acceleration, boolean limitRpm)

-- Arguments
-- float	acceleration	acceleration
-- boolean	limitRpm	limit rpm
-- Return Values
-- float	torque	torque
-- float	brakePedal	brake pedal
--======================================================================================================
-- Code
function VehicleMotor:getTorque(acceleration, limitRpm)
	-- Note: the torque curve is undefined outside the min/max rpm range. Clamping makes the curve flat at the outside range
	local torque = self.torqueCurve:get(Utils.clamp(self.nonClampedMotorRpm, self.minRpm, self.maxRpm));
	local brakePedal = 0;
	if limitRpm then
		local maxRpm = self:getCurMaxRpm();
		local rpmFadeOutRange = self.rpmFadeOutRange*self:getGearRatio();
		local fadeStartRpm = maxRpm - rpmFadeOutRange;
		if self.nonClampedMotorRpm > fadeStartRpm then
			if self.nonClampedMotorRpm > maxRpm then
				brakePedal = math.min((self.nonClampedMotorRpm-maxRpm)/rpmFadeOutRange, 1);
				torque = 0;
			else
				torque = torque * math.max((fadeStartRpm-self.nonClampedMotorRpm)/rpmFadeOutRange, 0);
			end;
		end;
	end
	torque = torque * math.abs(acceleration);
	local neededPtoTorque = PowerConsumer.getTotalConsumedPtoTorque(self.vehicle);
	if neededPtoTorque > 0 then
		torque = math.max(torque - neededPtoTorque/self.ptoMotorRpmRatio, torque*0.1);
	end
	return torque, brakePedal;
end;

--======================================================================================================
-- getMaximumForwardSpeed
--======================================================================================================
-- Description

	-- Returns maximum forward speed

-- Definition

	-- getMaximumForwardSpeed()

-- Return Values
-- float	maxForwardSpeed	maximum forward speed
--======================================================================================================
-- Code
function VehicleMotor:getMaximumForwardSpeed()
	return self.maxForwardSpeed;
end

--======================================================================================================
-- getMaximumBackwardSpeed
--======================================================================================================
-- Description

	-- Returns maximum backward speed

-- Definition

	-- getMaximumBackwardSpeed()

-- Return Values
-- float	maxBackwardSpeed	maximum backward speed
--======================================================================================================
-- Code
function VehicleMotor:getMaximumBackwardSpeed()
	return self.maxBackwardSpeed;
end

--======================================================================================================
-- calculatePhysicalMaximumForwardSpeed
--======================================================================================================
-- Description

	-- Returns physical maximum forward speed

-- Definition

	-- calculatePhysicalMaximumForwardSpeed()

-- Return Values
-- float	physicalMaxForwardSpeed	physical maximum forward speed
--======================================================================================================
-- Code
function VehicleMotor:calculatePhysicalMaximumForwardSpeed()
	return VehicleMotor.calculatePhysicalMaximumSpeed(self.minForwardGearRatio, self.forwardGearRatios, self.maxRpm)
end

--======================================================================================================
-- calculatePhysicalMaximumBackwardSpeed
--======================================================================================================
-- Description

	-- Returns physical maximum backward speed

-- Definition

	-- calculatePhysicalMaximumBackwardSpeed()

-- Return Values
-- float	physicalMaxBackwardSpeed	physical maximum backward speed
--======================================================================================================
-- Code
function VehicleMotor:calculatePhysicalMaximumBackwardSpeed()
	return VehicleMotor.calculatePhysicalMaximumSpeed(self.minBackwardGearRatio, self.backwardGearRatios, self.maxRpm)
end

--======================================================================================================
-- calculatePhysicalMaximumSpeed
--======================================================================================================
-- Description

	-- Returns physical maximum speed

-- Definition

	-- calculatePhysicalMaximumSpeed(float minGearRatio, table gearRatios, integer maxRpm)

-- Arguments
-- float	minGearRatio	min gear ratio
-- table	gearRatios	gear ratios
-- integer	maxRpm	max rpm
-- Return Values
-- float	physicalMaxSpeed	physical maximum speed
--======================================================================================================
-- Code
function VehicleMotor.calculatePhysicalMaximumSpeed(minGearRatio, gearRatios, maxRpm)
	local minRatio;
	if minGearRatio ~= nil then
		minRatio = minGearRatio
	else
		minRatio = math.huge;
		for _, ratio in pairs(gearRatios) do
			minRatio = math.min(minRatio, ratio);
		end
	end
	return maxRpm * math.pi / (30 * minRatio);
end

--======================================================================================================
-- updateMotorRpm
--======================================================================================================
-- Description

	-- Update motor rpm

-- Definition

	-- updateMotorRpm(float dt)

-- Arguments
-- float	dt	time since last call in ms
--======================================================================================================
-- Code
function VehicleMotor:updateMotorRpm(dt)
	local vehicle = self.vehicle;
	if next(vehicle.differentials) ~= nil and vehicle.motorizedNode ~= nil then
		self.nonClampedMotorRpm, self.clutchRpm, self.motorLoad = getMotorRotationSpeed(vehicle.motorizedNode)
		self.nonClampedMotorRpm = self.nonClampedMotorRpm * 30 / math.pi;
		self.clutchRpm = self.clutchRpm * 30 / math.pi;
		--[[
		local motorLoad = math.max(self.motorLoad, 0);
		-- We always require 30% of max torque extra

		local requiredWheelTorque = (motorLoad + 0.3*self.maxMotorTorque) * math.abs(self.gearRatio);

		local requiredWheelTorqueSmoothing = 0.3;
		if requiredWheelTorque > self.requiredWheelTorque then
			requiredWheelTorqueSmoothing = 0.05;
		end
		requiredWheelTorqueSmoothing = math.pow(requiredWheelTorqueSmoothing, dt*0.001);

		self.requiredWheelTorque = requiredWheelTorque + (self.requiredWheelTorque-requiredWheelTorque)*requiredWheelTorqueSmoothing;
		]]--
		self.requiredMotorPower = math.huge; -- TODO maybe adjust based on a ratio of max motor power (self.maxMotorTorque*self.maxMotorTorqueRpm*math.pi/30)
	else
		local gearRatio = self:getGearRatio();
		if vehicle.isServer then
			self.nonClampedMotorRpm = math.max(WheelsUtil.computeRpmFromWheels(vehicle) * gearRatio, 0);
		else
			self.nonClampedMotorRpm = math.max(WheelsUtil.computeRpmFromSpeed(vehicle) * gearRatio, 0);
		end
		self.clutchRpm = self.nonClampedMotorRpm;
	end
	self:setLastRpm(math.max(self.nonClampedMotorRpm, self.minRpm));
	-- the clamped motor rpm always is higher-equal than the required rpm by the pto
	--local ptoRpm = math.min(PowerConsumer.getMaxPtoRpm(self.vehicle)*self.ptoMotorRpmRatio, self.maxRpm);
	-- smoothing for raise/fall of ptoRpm
	if self.lastPtoRpm == nil then
		self.lastPtoRpm = self.minRpm;
	end;
	local ptoRpm = PowerConsumer.getMaxPtoRpm(self.vehicle)*self.ptoMotorRpmRatio;
	if ptoRpm > self.lastPtoRpm then
		self.lastPtoRpm = math.min(ptoRpm, self.lastPtoRpm + self.maxRpm*dt/2000);
	elseif ptoRpm < self.lastPtoRpm then
		self.lastPtoRpm = math.max(self.minRpm, self.lastPtoRpm - self.maxRpm*dt/1000);
	end;
	local ptoRpm = math.min(self.lastPtoRpm, self.maxRpm);
	self:setLastRpm(math.max(self.lastMotorRpm, ptoRpm));
	self.equalizedMotorRpm = self.minRpm + ( (math.max(self.nonClampedMotorRpm, (self.lastPtoRpm-self.minRpm))/self.maxRpm) * (self.maxRpm-self.minRpm) );
end;

--======================================================================================================
-- getBestGearRatio
--======================================================================================================
-- Description

	-- Returns best gear ratio

-- Definition

	-- getBestGearRatio(float wheelSpeedRpm, float minRatio, float maxRatio, float accSafeMotorRpm, float requiredMotorPower, float requiredMotorRpm)

-- Arguments
-- float	wheelSpeedRpm	wheel speed rpm
-- float	minRatio	min ratio
-- float	maxRatio	max ratio
-- float	accSafeMotorRpm	acc save motor rpm
-- float	requiredMotorPower	the required motor power [kW] (can be bigger than what the motor can actually achieve)
-- float	requiredMotorRpm	fixed motor rpm to be used (if not 0)
-- Return Values
-- float	bestGearRatio	best gear ratio
--======================================================================================================
-- Code
function VehicleMotor:getBestGearRatio(wheelSpeedRpm, minRatio, maxRatio, accSafeMotorRpm, requiredMotorPower, requiredMotorRpm)
	if requiredMotorRpm ~= 0 then
		local gearRatio = math.max(requiredMotorRpm-accSafeMotorRpm, requiredMotorRpm*0.8) / math.max(wheelSpeedRpm, 0.001);
		gearRatio = Utils.clamp(gearRatio, minRatio, maxRatio);
		return gearRatio;
	end
	-- Use a minimum wheel rpm to avoid that gearRatio is ignored
	wheelSpeedRpm = math.max(wheelSpeedRpm, 0.0001);
	local bestMotorPower = 0;
	local bestGearRatio = minRatio;
	--local bestRPM = 0;
	-- TODO make this more efficient
	for gearRatio = minRatio, maxRatio, 0.5 do
		local motorRpm = wheelSpeedRpm * gearRatio;
		if motorRpm > self.maxRpm - accSafeMotorRpm then
			break;
		end
		local motorPower = self.torqueCurve:get(math.max(motorRpm, self.minRpm)) * motorRpm *math.pi/30;
		if motorPower > bestMotorPower then
			bestMotorPower = motorPower;
			bestGearRatio = gearRatio;
			--bestRPM = motorRpm;
		end
		if motorPower >= requiredMotorPower then
			break;
		end
	end
	--print(string.format("Selected best gear: %f, %.2fkW rpm %.2f wheel %.2f", bestGearRatio, bestMotorPower, bestRPM, wheelSpeedRpm,));
	return bestGearRatio;
end

--======================================================================================================
-- getBestGear
--======================================================================================================
-- Description

	-- Returns best gear

-- Definition

	-- getBestGear(float acceleration, float wheelSpeedRpm, float accSafeMotorRpm, float requiredMotorPower, float requiredMotorRpm)

-- Arguments
-- float	acceleration	acceleration
-- float	wheelSpeedRpm	wheel speed rpm
-- float	accSafeMotorRpm	acc save motor rpm
-- float	requiredMotorPower	required wheel torque
-- float	requiredMotorRpm	required motor rpm
-- Return Values
-- float	bestGear	best gear
-- float	gearRatio	gear ratio
--======================================================================================================
-- Code
function VehicleMotor:getBestGear(acceleration, wheelSpeedRpm, accSafeMotorRpm, requiredMotorPower, requiredMotorRpm)
	if math.abs(acceleration) < 0.001 then
		acceleration = 1;
		if wheelSpeedRpm < 0 then
			acceleration = -1;
		end
	end
	if acceleration > 0 then
		if self.minForwardGearRatio ~= nil then
			local wheelSpeedRpm = math.max(wheelSpeedRpm, 0);
			local bestGearRatio = self:getBestGearRatio(wheelSpeedRpm, self.minForwardGearRatio, self.maxForwardGearRatio, accSafeMotorRpm, requiredMotorPower, requiredMotorRpm);
			return 1, bestGearRatio;
		else
			return 1, self.forwardGearRatios[1];
		end
	else
		if self.minBackwardGearRatio ~= nil then
			local wheelSpeedRpm = math.max(-wheelSpeedRpm, 0)
			local bestGearRatio = self:getBestGearRatio(wheelSpeedRpm, self.minBackwardGearRatio, self.maxBackwardGearRatio, accSafeMotorRpm, requiredMotorPower, requiredMotorRpm);
			return -1, -bestGearRatio;
		else
			return -1, -self.backwardGearRatios[1];
		end
	end
end

--======================================================================================================
-- updateGear
--======================================================================================================
-- Description

	-- Update gear

-- Definition

	-- updateGear(float acceleration)

-- Arguments
-- float	acceleration	acceleration
--======================================================================================================
-- Code
function VehicleMotor:updateGear(acceleration, dt)
	local requiredMotorPower = math.huge;
	if (acceleration >= 0) == (self.gearRatio >= 0) then
		requiredMotorPower = self.requiredMotorPower;
	end
	local requiredMotorRpm = PowerConsumer.getMaxPtoRpm(self.vehicle)*self.ptoMotorRpmRatio;
	-- 1) safe rpm for acceleration is 10% of the motor max rpm, so it will take at least 10 frames (=0.16s) until a vehicle has fully accelerated
	-- 2) replaced lastSpeedReal with clutchRPM/gearRatio => better acceleration when using high values for differentials and steeringAngle is at max/min
	local wheelSpeedRpm;
	if math.abs(self.gearRatio) < 0.001 then
		wheelSpeedRpm = self.vehicle.lastSpeedReal*self.vehicle.movingDirection * 30000/ math.pi;
	else
		wheelSpeedRpm = (self.clutchRpm/self.gearRatio); -- * math.pi/30;
	end
	self.gear, self.gearRatio = self:getBestGear(acceleration, wheelSpeedRpm, self.maxRpm*0.1, requiredMotorPower, requiredMotorRpm);
	if acceleration >= 0 then
		self.speedLimitAcc = self.maxForwardSpeed * 3.6 * acceleration;
	else
		self.speedLimitAcc = -self.maxBackwardSpeed * 3.6 * acceleration;
	end
end
-- getGearRatio
-- Description

	-- Returns gear ratio

-- Definition

	-- getGearRatio()

-- Return Values
-- float	gearRatio	gear ratio
-- Code
function VehicleMotor:getGearRatio()
	return self.gearRatio;
end;

--======================================================================================================
-- getCurMaxRpm
--======================================================================================================
-- Description

	-- Returns current max rpm

-- Definition

	-- getCurMaxRpm()

-- Return Values
-- integer	maxRpm	current max rpm
--======================================================================================================
-- Code
function VehicleMotor:getCurMaxRpm()
	local maxRpm = self.maxRpm;
	local gearRatio = self:getGearRatio();
	if gearRatio ~= 0 then
		--local speedLimit = self.speedLimit * 0.277778;
		local speedLimit = math.min(self.speedLimit, math.max(self.speedLimitAcc, self.vehicle.lastSpeedReal*3600)) * 0.277778;
		if gearRatio > 0 then
			speedLimit = math.min(speedLimit, self.maxForwardSpeed);
		else
			speedLimit = math.min(speedLimit, self.maxBackwardSpeed);
		end
		maxRpm = math.min(maxRpm, speedLimit * 30 / math.pi * math.abs(gearRatio));
	end
	maxRpm = math.min(maxRpm, self.rpmLimit);
	return maxRpm;
end;

--======================================================================================================
-- setSpeedLimit
--======================================================================================================
-- Description

	-- Sets speed limit

-- Definition

	-- setSpeedLimit(float limit)

-- Arguments
-- float	limit	new limit
--======================================================================================================
-- Code
function VehicleMotor:setSpeedLimit(limit)
	self.speedLimit = math.max(limit, self.minSpeed);
end

--======================================================================================================
-- setRpmLimit
--======================================================================================================
-- Description

	-- Sets rpm limit

-- Definition

	-- setRpmLimit(float limit)

-- Arguments
-- float	limit	new limit
--======================================================================================================
-- Code
function VehicleMotor:setRpmLimit(rpmLimit)
	self.rpmLimit = rpmLimit;
end;
