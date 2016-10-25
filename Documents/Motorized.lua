--======================================================================================================
-- preLoad
--======================================================================================================
-- Description

	-- Called before loading

-- Definition

	-- preLoad(table savegame)

-- Arguments
-- table	savegame	savegame
--======================================================================================================
-- Code
function Motorized:preLoad(savegame)
	self.addToPhysics = Utils.overwrittenFunction(self.addToPhysics, Motorized.addToPhysics);
end

--======================================================================================================
-- load
--======================================================================================================
-- Description

	-- Called on loading

-- Definition

	-- load(table savegame)

-- Arguments
-- table	savegame	savegame
--======================================================================================================
-- Code
function Motorized:load(savegame)
	self.getIsMotorStarted = Utils.overwrittenFunction(self.getIsMotorStarted, Motorized.getIsMotorStarted);
	self.getDeactivateOnLeave = Utils.overwrittenFunction(self.getDeactivateOnLeave, Motorized.getDeactivateOnLeave);
	self.getDeactivateLights = Utils.overwrittenFunction(self.getDeactivateLights, Motorized.getDeactivateLights);
	self.updateFuelUsage = Utils.overwrittenFunction(self.updateFuelUsage, Motorized.updateFuelUsage);
	self.startMotor = SpecializationUtil.callSpecializationsFunction("startMotor");
	self.stopMotor = SpecializationUtil.callSpecializationsFunction("stopMotor");
	self.setIsFuelFilling = SpecializationUtil.callSpecializationsFunction("setIsFuelFilling");
	self.setFuelFillLevel = SpecializationUtil.callSpecializationsFunction("setFuelFillLevel");
	self.addFuelFillTrigger = Motorized.addFuelFillTrigger;
	self.removeFuelFillTrigger = Motorized.removeFuelFillTrigger;
	self.motorizedNode = nil;
	for _, component in pairs(self.components) do
		if component.motorized then
			self.motorizedNode = component.node;
			break;
		end
	end
	Motorized.loadDifferentials(self, self.xmlFile, self.differentialIndex);
	Motorized.loadMotor(self, self.xmlFile, self.configurations["motor"]);
	Motorized.loadSounds(self, self.xmlFile, self.configurations["motor"]);
	self.motorizedFillActivatable = MotorizedRefuelActivatable:new(self);
	self.fuelFillTriggers = {};
	self.isFuelFilling = false;
	self.fuelFillLitersPerSecond = 10;
	self.fuelFillLevel = 0;
	self.lastFuelFillLevel = 0;
	self:setFuelFillLevel(self.fuelCapacity);
	self.sentFuelFillLevel = self.fuelFillLevel;
	self.stopMotorOnLeave = true;
	if self.isClient then
		self.exhaustParticleSystems = {};
		local exhaustParticleSystemCount = Utils.getNoNil(getXMLInt(self.xmlFile, "vehicle.exhaustParticleSystems#count"), 0);
		for i=1, exhaustParticleSystemCount do
			local namei = string.format("vehicle.exhaustParticleSystems.exhaustParticleSystem%d", i);
			local ps = {}
			ParticleUtil.loadParticleSystem(self.xmlFile, ps, namei, self.components, false, nil, self.baseDirectory)
			ps.minScale = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.exhaustParticleSystems#minScale"), 0.5);
			ps.maxScale = Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.exhaustParticleSystems#maxScale"), 1);
			table.insert(self.exhaustParticleSystems, ps)
		end
		if #self.exhaustParticleSystems == 0 then
			self.exhaustParticleSystems = nil
		end
		local exhaustFlapIndex = getXMLString(self.xmlFile, "vehicle.exhaustFlap#index");
		if exhaustFlapIndex ~= nil then
			self.exhaustFlap = {};
			self.exhaustFlap.node = Utils.indexToObject(self.components, exhaustFlapIndex);
			self.exhaustFlap.maxRot = Utils.degToRad(Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.exhaustFlap#maxRot"),0));
		end
		self.exhaustEffects = {};
		Motorized.loadExhaustEffects(self, self.xmlFile, self.exhaustEffects);
		if table.getn(self.exhaustEffects) == 0 then
			self.exhaustEffects = nil;
		end
	end
	self.motorStartDuration = 0;
	if self.sampleMotorStart ~= nil then
		self.motorStartDuration = self.sampleMotorStart.duration;
	end
	self.motorStartDuration = Utils.getNoNil( Utils.getNoNil(getXMLFloat(self.xmlFile, "vehicle.motorStartDuration"), self.motorStartDuration), 0);
	self.motorStartTime = 0;
	self.lastRoundPerMinute = 0;
	self.actualLoadPercentage = 0;
	self.maxDecelerationDuringBrake = 0;
	self.motorizedDirtyFlag = self:getNextDirtyFlag();
	self.isMotorStarted = false;
	self.motorStopTimer = g_motorStopTimerDuration
	self.fuelFillLevelHud = VehicleHudUtils.loadHud(self, self.xmlFile, "fuel");
	self.rpmHud = VehicleHudUtils.loadHud(self, self.xmlFile, "rpm");
	self.timeHud = VehicleHudUtils.loadHud(self, self.xmlFile, "time");
	if self.timeHud ~= nil then
		self.minuteChanged = Utils.appendedFunction(self.minuteChanged, Motorized.minuteChanged);
		g_currentMission.environment:addMinuteChangeListener(self);
		self:minuteChanged();
	end
	self.speedHud = VehicleHudUtils.loadHud(self, self.xmlFile, "speed");
	self.fuelUsageHud = VehicleHudUtils.loadHud(self, self.xmlFile, "fuelUsage");
	if savegame ~= nil then
		local fuelFillLevel = getXMLFloat(savegame.xmlFile, savegame.key.."#fuelFillLevel");
		if fuelFillLevel ~= nil then
			if self.fuelCapacity ~= 0 then
				local minFuelFillLevel = 0.1*self.fuelCapacity
				local numToRefill = math.max(minFuelFillLevel - fuelFillLevel, 0);
				if numToRefill > 0 then
					fuelFillLevel = minFuelFillLevel;
					local delta = numToRefill * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL)
					g_currentMission.missionStats:updateStats("expenses", delta);
					g_currentMission:addSharedMoney(-delta, "purchaseFuel");
				end
			end
			self:setFuelFillLevel(fuelFillLevel);
		end
	end
	self.motorTurnedOnRotationNodes = Utils.loadRotationNodes(self.xmlFile, {}, "vehicle.turnedOnRotationNodes.turnedOnRotationNode", "motor", self.components);
end

--======================================================================================================
-- loadExhaustEffects
--======================================================================================================
-- Description

	-- Loading of exhaust effects from xml file

-- Definition

	-- loadExhaustEffects(integer xmlFile, table exhaustEffects)

-- Arguments
-- integer	xmlFile	id of xml object
-- table	exhaustEffects	table to ass exhaustEffects
--======================================================================================================
-- Code
function Motorized:loadExhaustEffects(xmlFile, exhaustEffects)
	local i = 0;
	while true do
		local key = string.format("vehicle.exhaustEffects.exhaustEffect(%d)", i);
		if not hasXMLProperty(xmlFile, key) then
			break;
		end
		local linkNode = Utils.indexToObject(self.components, getXMLString(xmlFile, key.."#index"));
		local filename = getXMLString(xmlFile, key .. "#filename");
		if filename ~= nil and linkNode ~= nil then
			local i3dNode = Utils.loadSharedI3DFile(filename, self.baseDirectory, false, false, false);
			if i3dNode ~= 0 then
				local node = getChildAt(i3dNode, 0);
				if getHasShaderParameter(node, "param") then
					local effect = {};
					effect.effectNode = node
					effect.node = linkNode
					effect.filename = filename;
					link(effect.node, effect.effectNode);
					setVisibility(effect.effectNode, false);
					delete(i3dNode);
					effect.minRpmColor = Utils.getVectorNFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#minRpmColor"), "0 0 0 1"), 4);
					effect.maxRpmColor = Utils.getVectorNFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#maxRpmColor"), "0.0384 0.0359 0.0627 2.0"), 4);
					effect.minRpmScale = Utils.getNoNil(getXMLFloat(xmlFile, key.."#minRpmScale"), 0.25);
					effect.maxRpmScale = Utils.getNoNil(getXMLFloat(xmlFile, key.."#maxRpmScale"), 0.95);
					effect.maxForwardSpeed = Utils.getNoNil(getXMLFloat(xmlFile, key.."#maxForwardSpeed"), math.ceil(self.motor:getMaximumForwardSpeed()*3.6));
					effect.maxBackwardSpeed = Utils.getNoNil(getXMLFloat(xmlFile, key.."#maxBackwardSpeed"), math.ceil(self.motor:getMaximumBackwardSpeed()*3.6));
					effect.xzRotationsOffset = Utils.getRadiansFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#xzRotationsOffset"), "0 0"), 2);
					effect.xzRotationsForward = Utils.getRadiansFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#xzRotationsForward"), "0 0"), 2);
					effect.xzRotationsBackward = Utils.getRadiansFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#xzRotationsBackward"), "0 0"), 2);
					effect.xzRotationsLeft = Utils.getRadiansFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#xzRotationsLeft"), "0 0"), 2);
					effect.xzRotationsRight = Utils.getRadiansFromString(Utils.getNoNil(getXMLString(xmlFile, key.."#xzRotationsRight"), "0 0"), 2);
					effect.xRot = 0;
					effect.zRot = 0;
					table.insert(exhaustEffects, effect);
				end
			end
		end
		i = i + 1;
	end
	self.exhaustEffectMaxSteeringSpeed = 0.001;
end

--======================================================================================================
-- loadDifferentials
--======================================================================================================
-- Description

	-- Load differentials from xml

-- Definition

	-- loadDifferentials(integer xmlFile, integer configDifferentialIndex)

-- Arguments
-- integer	xmlFile	id of xml object
-- integer	configDifferentialIndex	index of differential config
--======================================================================================================
-- Code
function Motorized:loadDifferentials(xmlFile, configDifferentialIndex)
	local key,_  = Vehicle.getXMLConfigurationKey(xmlFile, configDifferentialIndex, "vehicle.differentialConfigurations.differentials", "vehicle.differentials", "differential");
	self.differentials = {};
	if self.isServer and self.motorizedNode ~= nil then
		local i = 0;
		while true do
			local key = string.format(key..".differential(%d)", i);
			if not hasXMLProperty(xmlFile, key) then
				break;
			end
			local torqueRatio = Utils.getNoNil(getXMLFloat(xmlFile, key.."#torqueRatio"), 0.5);
			local maxSpeedRatio = Utils.getNoNil(getXMLFloat(xmlFile, key.."#maxSpeedRatio"), 1.3);
			local diffIndex1, diffIndex1IsWheel;
			local diffIndex2, diffIndex2IsWheel;
			local wheelIndex1 = getXMLInt(xmlFile, key.."#wheelIndex1");
			if wheelIndex1 ~= nil then
				local wheel = self.wheels[wheelIndex1+1];
				if wheel ~= nil then
					diffIndex1IsWheel = true;
					diffIndex1 = wheelIndex1+1;
				end
			else
				diffIndex1IsWheel = false;
				diffIndex1 = getXMLInt(xmlFile, key.."#differentialIndex1");
			end
			local wheelIndex2 = getXMLInt(xmlFile, key.."#wheelIndex2");
			if wheelIndex2 ~= nil then
				local wheel = self.wheels[wheelIndex2+1];
				if wheel ~= nil then
					diffIndex2IsWheel = true;
					diffIndex2 = wheelIndex2+1;
				end
			else
				diffIndex2IsWheel = false;
				diffIndex2 = getXMLInt(xmlFile, key.."#differentialIndex2");
			end
			if diffIndex1 ~= nil and diffIndex2 ~= nil then
				table.insert(self.differentials, {torqueRatio=torqueRatio, maxSpeedRatio=maxSpeedRatio, diffIndex1=diffIndex1, diffIndex1IsWheel=diffIndex1IsWheel, diffIndex2=diffIndex2, diffIndex2IsWheel=diffIndex2IsWheel});
				addDifferential(self.motorizedNode, diffIndex1IsWheel and self.wheels[diffIndex1].wheelShape or diffIndex1, diffIndex1IsWheel, diffIndex2IsWheel and self.wheels[diffIndex2].wheelShape or diffIndex2, diffIndex2IsWheel, torqueRatio, maxSpeedRatio);
			else
				print("Error: Invalid differential indices in '"..self.configFileName.."'");
			end
			i = i + 1;
		end
	end
end

--======================================================================================================
-- addToPhysics
--======================================================================================================
-- Description

	-- Add to physics

-- Definition

	-- addToPhysics()

-- Return Values
-- boolean	success	success
--======================================================================================================
-- Code
function Motorized:addToPhysics(superFunc)
	if superFunc ~= nil then
		if not superFunc(self) then
			return false;
		end
	end
	if self.isServer then
		if self.motorizedNode ~= nil then
			for _, differential in pairs(self.differentials) do
				local diffIndex1IsWheel, diffIndex1, diffIndex2IsWheel, diffIndex2 = differential.diffIndex1IsWheel, differential.diffIndex1, differential.diffIndex2IsWheel, differential.diffIndex2;
				if diffIndex1IsWheel then
					diffIndex1 = self.wheels[diffIndex1].wheelShape;
				end
				if diffIndex2IsWheel then
					diffIndex2 = self.wheels[diffIndex2].wheelShape;
				end
				addDifferential(self.motorizedNode, diffIndex1, diffIndex1IsWheel, diffIndex2, diffIndex2IsWheel, differential.torqueRatio, differential.maxSpeedRatio);
			end
		end
	end
	return true
end

--======================================================================================================
-- loadMotor
--======================================================================================================
-- Description

	-- Load motor from xml file

-- Definition

	-- loadMotor(integer xmlFile, integer motorId)

-- Arguments
-- integer	xmlFile	id of xml object
-- integer	motorId	index of motor configuration
--======================================================================================================
-- Code
function Motorized:loadMotor(xmlFile, motorId)
	local key, motorId = Vehicle.getXMLConfigurationKey(xmlFile, motorId, "vehicle.motorConfigurations.motorConfiguration", "vehicle", "motor");
	local fallbackConfigKey = "vehicle.motorConfigurations.motorConfiguration(0)";
	local fallbackOldKey = "vehicle";
	self.motorType = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#type", getXMLString, "vehicle", fallbackConfigKey, fallbackOldKey);
	self.fuelCapacity = Vehicle.getConfigurationValue(xmlFile, key, ".fuelCapacity", "", getXMLFloat, 500, fallbackConfigKey, fallbackOldKey);
	local wheelKey, _ = Vehicle.getXMLConfigurationKey(xmlFile, self.configurations["wheel"], "vehicle.wheelConfigurations.wheelConfiguration", "vehicle", "wheels");
	self.fuelCapacity = Utils.getNoNil(Vehicle.getConfigurationValue(xmlFile, wheelKey, ".fuelCapacity", "", getXMLInt, nil, nil, ""), self.fuelCapacity);
	local fuelUsage = Vehicle.getConfigurationValue(xmlFile, key, ".fuelUsage", "", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	if fuelUsage == nil then
		fuelUsage = self.fuelCapacity / 5; -- default fuel usage:  full->empty: 5h
	end
	self.fuelUsage = fuelUsage / (60*60*1000); -- from l/h to l/ms
	ObjectChangeUtil.updateObjectChanges(xmlFile, "vehicle.motorConfigurations.motorConfiguration", motorId, self.components, self);
	local motorMinRpm = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#minRpm", getXMLFloat, 1000, fallbackConfigKey, fallbackOldKey);
	local motorMaxRpm = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#maxRpm", getXMLFloat, 1800, fallbackConfigKey, fallbackOldKey);
	local minSpeed = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#minSpeed", getXMLFloat, 1, fallbackConfigKey, fallbackOldKey);
	local maxForwardSpeed = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#maxForwardSpeed", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	local maxBackwardSpeed = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#maxBackwardSpeed", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	if maxForwardSpeed ~= nil then
		maxForwardSpeed = maxForwardSpeed/3.6;
	end
	if maxBackwardSpeed ~= nil then
		maxBackwardSpeed = maxBackwardSpeed/3.6;
	end
	local maxWheelSpeed = Vehicle.getConfigurationValue(xmlFile, wheelKey, ".wheels", "#maxForwardSpeed", getXMLFloat, nil, nil, "vehicle.wheels");
	if maxWheelSpeed ~= nil then
		maxForwardSpeed = maxWheelSpeed/3.6;
	end
	local brakeForce = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#brakeForce", getXMLFloat, 10, fallbackConfigKey, fallbackOldKey)*2;
	local lowBrakeForceScale = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#lowBrakeForceScale", getXMLFloat, 0.5, fallbackConfigKey, fallbackOldKey);
	local lowBrakeForceSpeedLimit = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#lowBrakeForceSpeedLimit", getXMLFloat, 20, fallbackConfigKey, fallbackOldKey)/3600;
	local forwardGearRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#forwardGearRatio", getXMLFloat, 2, fallbackConfigKey, fallbackOldKey);
	local backwardGearRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#backwardGearRatio", getXMLFloat, 1.5, fallbackConfigKey, fallbackOldKey);
	local maxForwardGearRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#maxForwardGearRatio", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	local minForwardGearRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#minForwardGearRatio", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	local maxBackwardGearRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#maxBackwardGearRatio", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	local minBackwardGearRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#minBackwardGearRatio", getXMLFloat, nil, fallbackConfigKey, fallbackOldKey);
	local rpmFadeOutRange = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#rpmFadeOutRange", getXMLFloat, 20, fallbackConfigKey, fallbackOldKey);
	local torqueScale = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#torqueScale", getXMLFloat, 1, fallbackConfigKey, fallbackOldKey);
	local ptoMotorRpmRatio = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#ptoMotorRpmRatio", getXMLFloat, 4, fallbackConfigKey, fallbackOldKey);
	--local maxTorque = 0;
	local maxMotorPower = 0;
	local torqueCurve = AnimCurve:new(linearInterpolator1);
	local torqueI = 0;
	local torqueBase = fallbackOldKey..".motor.torque"; -- fallback to old motor setup
	if key ~= nil and hasXMLProperty(xmlFile, fallbackConfigKey..".motor.torque(0)") then -- using default motor configuration
		torqueBase = fallbackConfigKey..".motor.torque";
	end
	if key ~= nil and hasXMLProperty(xmlFile, key..".motor.torque(0)") then -- using selected motor configuration
		torqueBase = key..".motor.torque";
	end
	while true do
		local torqueKey = string.format(torqueBase.."(%d)", torqueI);
		local normRpm = getXMLFloat(xmlFile, torqueKey.."#normRpm");
		local rpm;
		if normRpm == nil then
			rpm = getXMLFloat(xmlFile, torqueKey.."#rpm");
		else
			rpm = normRpm * motorMaxRpm;
		end
		local torque = getXMLFloat(xmlFile, torqueKey.."#torque");
		if torque == nil or rpm == nil then
			break;
		end
		torqueCurve:addKeyframe({v=torque*torqueScale, time = rpm});
		torqueI = torqueI +1;
		local motorPower = 1000 * ( rpm*math.pi/30*(torque*torqueScale) );
		if motorPower > maxMotorPower then
			maxMotorPower = motorPower;
		end
	end
	if self.motorType == "locomotive" then
		self.motor = LocomotiveMotor:new(self, motorMinRpm, motorMaxRpm, maxForwardSpeed, maxBackwardSpeed, torqueCurve, brakeForce, forwardGearRatio, backwardGearRatio, minForwardGearRatio, maxForwardGearRatio, minBackwardGearRatio, maxBackwardGearRatio, ptoMotorRpmRatio, rpmFadeOutRange, 0, maxMotorPower);
	else
		self.motor = VehicleMotor:new(self, motorMinRpm, motorMaxRpm, maxForwardSpeed, maxBackwardSpeed, torqueCurve, brakeForce, forwardGearRatio, backwardGearRatio, minForwardGearRatio, maxForwardGearRatio, minBackwardGearRatio, maxBackwardGearRatio, ptoMotorRpmRatio, rpmFadeOutRange, 0, maxMotorPower, minSpeed);
	end
	local rotInertia = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#rotInertia", getXMLFloat, self.motor:getRotInertia(), fallbackConfigKey, fallbackOldKey);
	local dampingRate = Vehicle.getConfigurationValue(xmlFile, key, ".motor", "#dampingRate", getXMLFloat, self.motor:getDampingRate(), fallbackConfigKey, fallbackOldKey);
	self.motor:setRotInertia(rotInertia);
	self.motor:setDampingRate(dampingRate);
	self.motor:setLowBrakeForce(lowBrakeForceScale, lowBrakeForceSpeedLimit);
end

--======================================================================================================
-- loadSounds
--======================================================================================================
-- Description

	-- Load sounds from xml file

-- Definition

	-- loadSounds(integer xmlFile)

-- Arguments
-- integer	xmlFile	id of xml object
--======================================================================================================
-- Code
function Motorized:loadSounds(xmlFile, motorId)
	if self.isClient then
		self.sampleRefuel = SoundUtil.loadSample(xmlFile, {}, "vehicle.refuelSound", "$data/maps/sounds/refuel.wav", self.baseDirectory, self.components[1].node);
		self.sampleMotorStart = SoundUtil.loadSample(xmlFile, {}, "vehicle.motorStartSound", nil, self.baseDirectory);
		self.sampleMotorStop = SoundUtil.loadSample(xmlFile, {}, "vehicle.motorStopSound", nil, self.baseDirectory);
		self.sampleMotor = SoundUtil.loadSample(xmlFile, {}, "vehicle.motorSound", nil, self.baseDirectory, self.components[1].node);
		self.sampleMotorRun = SoundUtil.loadSample(xmlFile, {}, "vehicle.motorSoundRun", nil, self.baseDirectory, self.components[1].node);
		self.sampleMotorLoad = SoundUtil.loadSample(xmlFile, {}, "vehicle.motorSoundLoad", nil, self.baseDirectory, self.components[1].node);
		self.sampleGearbox = SoundUtil.loadSample(xmlFile, {}, "vehicle.gearboxSound", nil, self.baseDirectory, self.components[1].node);
		self.sampleRetarder = SoundUtil.loadSample(xmlFile, {}, "vehicle.retarderSound", nil, self.baseDirectory, self.components[1].node);
		self.sampleBrakeCompressorStart = SoundUtil.loadSample(xmlFile, {}, "vehicle.brakeCompressorStartSound", nil, self.baseDirectory);
		self.sampleBrakeCompressorRun = SoundUtil.loadSample(xmlFile, {}, "vehicle.brakeCompressorRunSound", nil, self.baseDirectory);
		self.sampleBrakeCompressorStop = SoundUtil.loadSample(xmlFile, {}, "vehicle.brakeCompressorStopSound", nil, self.baseDirectory);
		self.sampleReverseDrive = SoundUtil.loadSample(xmlFile, {}, "vehicle.reverseDriveSound", nil, self.baseDirectory);
		self.sampleCompressedAir = SoundUtil.loadSample(xmlFile, {}, "vehicle.compressedAirSound", nil, self.baseDirectory);
		self.sampleAirReleaseValve = SoundUtil.loadSample(xmlFile, {}, "vehicle.airReleaseValveSound", nil, self.baseDirectory);
		local maxRpmDelta = (self.motor:getMaxRpm() - self.motor:getMinRpm());
		local maxRpsDelta = maxRpmDelta / 60;
		if self.sampleMotor.sample ~= nil then
			self.motorSoundPitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSound#pitchMax"), 2.0);
			self.motorSoundPitchScale = getXMLFloat(xmlFile, "vehicle.motorSound#pitchScale");
			if self.motorSoundPitchScale == nil then
				self.motorSoundPitchScale = (self.motorSoundPitchMax - self.sampleMotor.pitchOffset) / maxRpsDelta;
			end
			self.motorSoundVolumeMin = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSound#volumeMin"), self.sampleMotor.volume);
			self.motorSoundVolumeMinSpeed = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSound#volumeMinSpeed"), math.huge);
		end
		if self.sampleMotorRun.sample ~= nil then
			self.motorSoundRunPitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSoundRun#pitchMax"), 2.0);
			self.motorSoundRunPitchScale = getXMLFloat(xmlFile, "vehicle.motorSoundRun#pitchScale");
			if self.motorSoundRunPitchScale == nil then
				self.motorSoundRunPitchScale = (self.motorSoundRunPitchMax - self.sampleMotorRun.pitchOffset) / maxRpsDelta;
			end
			self.motorSoundRunMinimalVolumeFactor = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSoundRun#minimalVolumeFactor"), 0.0);
		end
		if self.sampleMotorLoad.sample ~= nil then
			self.motorSoundLoadPitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSoundLoad#pitchMax"), 2.0);
			self.motorSoundLoadPitchScale = getXMLFloat(xmlFile, "vehicle.motorSoundLoad#pitchScale");
			if self.motorSoundLoadPitchScale == nil then
				self.motorSoundLoadPitchScale = (self.motorSoundLoadPitchMax - self.sampleMotorLoad.pitchOffset) / maxRpsDelta;
			end
			self.motorSoundLoadMinimalVolumeFactor = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.motorSoundLoad#minimalVolumeFactor"), 0.0);
			self.motorSoundLoadFactor = 0;
		end
		if self.sampleGearbox.sample ~= nil then
			self.gearboxSoundVolumeMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#volumeMax"), 2.0);
			self.gearboxSoundPitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#pitchMax"), 2.0);
			self.gearboxSoundReverseVolumeMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#reverseVolumeMax"), self.gearboxSoundVolumeMax);
			self.gearboxSoundReversePitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#reversePitchMax"), self.gearboxSoundPitchMax);
			self.gearboxSoundPitchExponent = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#pitchExponent"), 1.0);
		end
		if self.sampleRetarder.sample ~= nil then
			self.retarderSoundVolumeMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.retarderSound#volumeMax"), 2.0);
			self.retarderSoundPitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.retarderSound#pitchMax"), 2.0);
			self.retarderSoundMinSpeed = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.retarderSound#minSpeed"), 5.0);
			self.retarderSoundActualVolume = 0.0;
		end
		self.pitchInfluenceFromWheels = 0;
		self.volumeInfluenceFromWheels = 0;
		self.wheelInfluenceOnGearboxSoundVolume = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#wheelInfluenceOnVolume"), 0.1);
		self.wheelInfluenceOnGearboxSoundPitch = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.gearboxSound#wheelInfluenceOnPitch"), 0.2);
		self.wheelInfluenceOnRetarderSoundVolume = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.retarderSound#wheelInfluenceOnVolume"), 0.1);
		self.wheelInfluenceOnRetarderSoundPitch = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.retarderSound#wheelInfluenceOnPitch"), 0.2);
		if self.sampleBrakeCompressorRun.sample ~= nil then
			self.brakeCompressorRunSoundPitchMax = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.brakeCompressorRunSound#pitchMax"), 2.0);
			self.brakeCompressorRunSoundPitchScale = getXMLFloat(xmlFile, "vehicle.brakeCompressorRunSound#pitchScale");
			if self.brakeCompressorRunSoundPitchScale == nil then
				self.brakeCompressorRunSoundPitchScale = (self.brakeCompressorRunSoundPitchMax - self.sampleBrakeCompressorRun.pitchOffset) / maxRpsDelta;
			end
		end
		self.brakeCompressor = {};
		self.brakeCompressor.capacity = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.brakeCompressor#capacity"), 6);
		self.brakeCompressor.refillFilllevel = math.min(self.brakeCompressor.capacity, Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.brakeCompressor#refillFillLevel"), self.brakeCompressor.capacity/2));
		self.brakeCompressor.fillSpeed = Utils.getNoNil(getXMLFloat(xmlFile, "vehicle.brakeCompressor#fillSpeed"), 0.6) / 1000;
		self.brakeCompressor.fillLevel = 0;
		self.brakeCompressor.doFill = true;
		self.soundsAdjustedToIndoorCamera = false;
		self.compressedAirSoundEnabled = false;
		self.compressionSoundTime = 0;
	end
end

--======================================================================================================
-- delete
--======================================================================================================
-- Description

	-- Called on deleting

-- Definition

	-- delete()

--======================================================================================================
-- Code
function Motorized:delete()
	if self.timeHud ~= nil then
		g_currentMission.environment:removeMinuteChangeListener(self);
	end
	for _, trigger in pairs(self.fuelFillTriggers) do
		trigger:onVehicleDeleted(self);
	end
	g_currentMission:removeActivatableObject(self.motorizedFillActivatable);
	if self.isClient then
		if self.exhaustEffects ~= nil then
			for _, effect in pairs(self.exhaustEffects) do
				Utils.releaseSharedI3DFile(effect.filename, self.baseDirectory, true);
			end
		end
		ParticleUtil.deleteParticleSystems(self.exhaustParticleSystems)
		SoundUtil.deleteSample(self.sampleRefuel);
		SoundUtil.deleteSample(self.sampleCompressedAir);
		SoundUtil.deleteSample(self.sampleAirReleaseValve);
		SoundUtil.deleteSample(self.sampleMotor);
		SoundUtil.deleteSample(self.sampleMotorRun);
		SoundUtil.deleteSample(self.sampleMotorLoad);
		SoundUtil.deleteSample(self.sampleGearbox);
		SoundUtil.deleteSample(self.sampleRetarder);
		SoundUtil.deleteSample(self.sampleMotorStart);
		SoundUtil.deleteSample(self.sampleMotorStop);
		SoundUtil.deleteSample(self.sampleReverseDrive);
		SoundUtil.deleteSample(self.sampleBrakeCompressorStart);
		SoundUtil.deleteSample(self.sampleBrakeCompressorRun);
		SoundUtil.deleteSample(self.sampleBrakeCompressorStop);
	end
end

--======================================================================================================
-- readStream
--======================================================================================================
-- Description

	-- Called on client side on join

-- Definition

	-- readStream(integer streamId, integer connection)

-- Arguments
-- integer	streamId	streamId
-- integer	connection	connection
--======================================================================================================
-- Code
function Motorized:readStream(streamId, connection)
	local isMotorStarted = streamReadBool(streamId);
	if isMotorStarted then
		self:startMotor(true);
	else
		self:stopMotor(true);
	end
	local isFuelFilling = streamReadBool(streamId);
	self:setIsFuelFilling(isFuelFilling, true);
	local newFuelFillLevel=streamReadFloat32(streamId);
	self:setFuelFillLevel(newFuelFillLevel);
end

--======================================================================================================
-- writeStream
--======================================================================================================
-- Description

	-- Called on server side on join

-- Definition

	-- writeStream(integer streamId, integer connection)

-- Arguments
-- integer	streamId	streamId
-- integer	connection	connection
--======================================================================================================
-- Code
function Motorized:writeStream(streamId, connection)
	streamWriteBool(streamId, self.isMotorStarted);
	streamWriteBool(streamId, self.isFuelFilling);
	streamWriteFloat32(streamId, self.fuelFillLevel);
end

--======================================================================================================
-- readUpdateStream
--======================================================================================================
-- Description

	-- Called on on update

-- Definition

	-- readUpdateStream(integer streamId, integer timestamp, table connection)

-- Arguments
-- integer	streamId	stream ID
-- integer	timestamp	timestamp
-- table	connection	connection
--======================================================================================================
-- Code
function Motorized:readUpdateStream(streamId, timestamp, connection)
	if connection.isServer then
		local rpm = streamReadUIntN(streamId, 11);
		rpm = rpm / 2047;
		local rpmRange = self.motor:getMaxRpm()- self.motor:getMinRpm();
		self.motor:setEqualizedMotorRpm( (rpm * rpmRange) + self.motor:getMinRpm() );
		local loadPercentage = streamReadUIntN(streamId, 7);
		self.actualLoadPercentage = loadPercentage / 127;
		if streamReadBool(streamId) then
			local fuelFillLevel = streamReadUIntN(streamId, 15)/32767*self.fuelCapacity;
			self:setFuelFillLevel(fuelFillLevel);
		end
	end
end

--======================================================================================================
-- writeUpdateStream
--======================================================================================================
-- Description

	-- Called on on update

-- Definition

	-- writeUpdateStream(integer streamId, table connection, integer dirtyMask)

-- Arguments
-- integer	streamId	stream ID
-- table	connection	connection
-- integer	dirtyMask	dirty mask
--======================================================================================================
-- Code
function Motorized:writeUpdateStream(streamId, connection, dirtyMask)
	if not connection.isServer then
		local rpmRange = self.motor:getMaxRpm() - self.motor:getMinRpm();
		local rpm = (self.motor:getEqualizedMotorRpm() - self.motor:getMinRpm()) / rpmRange;
		rpm = math.floor(rpm * 2047);
		streamWriteUIntN(streamId, rpm, 11);
		streamWriteUIntN(streamId, 127 * self.actualLoadPercentage, 7);
		if streamWriteBool(streamId, bitAND(dirtyMask, self.motorizedDirtyFlag) ~= 0) then
			local percent = 0;
			if self.fuelCapacity ~= 0 then
				percent = Utils.clamp(self.fuelFillLevel / self.fuelCapacity, 0, 1);
			end
			streamWriteUIntN(streamId, math.floor(percent*32767), 15);
		end
	end
end

--======================================================================================================
-- getSaveAttributesAndNodes
--======================================================================================================
-- Description

	-- Returns attributes and nodes to save

-- Definition

	-- getSaveAttributesAndNodes(table nodeIdent)

-- Arguments
-- table	nodeIdent	node ident
-- Return Values
-- string	attributes	attributes
-- string	nodes	nodes
--======================================================================================================
-- Code
function Motorized:getSaveAttributesAndNodes(nodeIdent)
	local attributes = 'fuelFillLevel="'..self.fuelFillLevel..'"';
	return attributes, nil;
end

--======================================================================================================
-- update
--======================================================================================================
-- Description

	-- Called on update

-- Definition

	-- update(float dt)

-- Arguments
-- float	dt	time since last call in ms
--======================================================================================================
-- Code
function Motorized:update(dt)
	if self.isClient then
		if InputBinding.hasEvent(InputBinding.TOGGLE_MOTOR_STATE) then
			if self.isEntered and self:getIsActiveForInput(false) and not g_currentMission.missionInfo.automaticMotorStartEnabled then
				if not self:getIsHired() then
					if self.isMotorStarted then
						self:stopMotor()
					else
						self:startMotor()
					end
				end
			end
		end
	end
	Utils.updateRotationNodes(self, self.motorTurnedOnRotationNodes, dt, self:getIsMotorStarted());
	if self:getIsMotorStarted() then
		local accInput = 0;
		if self.axisForward ~= nil then
			accInput = -self.axisForward;
		end
		if self.cruiseControl ~= nil and self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_OFF then
			accInput = 1;
		end
		if self.isClient then
			if self:getIsActiveForSound() then
				if not SoundUtil.isSamplePlaying(self.sampleMotorStart, 1.5*dt) then
					SoundUtil.playSample(self.sampleMotor, 0, 0, nil);
					SoundUtil.playSample(self.sampleMotorRun, 0, 0, 0);
					SoundUtil.playSample(self.sampleMotorLoad, 0, 0, 0);
					SoundUtil.playSample(self.sampleGearbox, 0, 0, 0);
					SoundUtil.playSample(self.sampleRetarder, 0, 0, 0);
					if self.brakeLightsVisibility then
						self.brakeLightsVisibilityWasActive = true;
						self.maxDecelerationDuringBrake = math.max(self.maxDecelerationDuringBrake, math.abs(accInput));
					end
					if self.brakeLightsVisibilityWasActive and not self.brakeLightsVisibility then
						self.brakeLightsVisibilityWasActive = false;
						local factor = self.maxDecelerationDuringBrake;
						self.maxDecelerationDuringBrake = 0;
						local airConsumption = self:getMaximalAirConsumptionPerFullStop();
						-- print( string.format(" -----> factor = %.2f // %.2f ", factor, airConsumption) );
						airConsumption = factor * airConsumption;
						self.brakeCompressor.fillLevel = math.max(0, self.brakeCompressor.fillLevel - airConsumption); --implementCount * self.brakeCompressor.capacity * 0.05);
					end
					if self.brakeCompressor.fillLevel < self.brakeCompressor.refillFilllevel then
						self.brakeCompressor.doFill = true;
					end
					if self.brakeCompressor.doFill and self.brakeCompressor.fillLevel == self.brakeCompressor.capacity then
						self.brakeCompressor.doFill = false;
					end
					if self.brakeCompressor.doFill then
						self.brakeCompressor.fillLevel = math.min(self.brakeCompressor.capacity, self.brakeCompressor.fillLevel + self.brakeCompressor.fillSpeed * dt);
					end
					if Vehicle.debugRendering then
						renderText(0.3, 0.16, getCorrectTextSize(0.02), string.format("brakeCompressor.fillLevel = %.1f", 100*(self.brakeCompressor.fillLevel / self.brakeCompressor.capacity) ));
					end
					if not self.brakeCompressor.doFill then
						if self.brakeCompressor.runSoundActive then
							SoundUtil.stopSample(self.sampleBrakeCompressorRun, true);
							SoundUtil.playSample(self.sampleBrakeCompressorStop, 1, 0, nil);
							self.brakeCompressor.startSoundPlayed = false;
							self.brakeCompressor.runSoundActive = false;
						end
					elseif not SoundUtil.isSamplePlaying(self.sampleBrakeCompressorStop, 1.5*dt) then
						if not self.brakeCompressor.startSoundPlayed then
							self.brakeCompressor.startSoundPlayed = true;
							SoundUtil.playSample(self.sampleBrakeCompressorStart, 1, 0, nil);
						else
							if not SoundUtil.isSamplePlaying(self.sampleBrakeCompressorStart, 1.5*dt) and not self.brakeCompressor.runSoundActive then
								self.brakeCompressor.runSoundActive = true;
								SoundUtil.playSample(self.sampleBrakeCompressorRun, 0, 0, nil);
							end
						end
					end
				end
				if self.compressionSoundTime <= g_currentMission.time then
					SoundUtil.playSample(self.sampleAirReleaseValve, 1, 0, nil);
					self.compressionSoundTime = g_currentMission.time + math.random(10000, 40000);
				end
				if self.sampleCompressedAir.sample ~= nil then
					if self.movingDirection > 0 and self.lastSpeed > self.motor:getMaximumForwardSpeed()*0.0002 then -- faster than 20% of max speed
						if accInput < -0.05 then
							-- play the compressor sound if we drive fast enough and brake
							if not self.compressedAirSoundEnabled then
								SoundUtil.playSample(self.sampleCompressedAir, 1, 0, nil);
								self.compressedAirSoundEnabled = true;
							end
						else
							self.compressedAirSoundEnabled = false;
						end
					end
				end
				SoundUtil.stop3DSample(self.sampleMotor);
				SoundUtil.stop3DSample(self.sampleMotorRun);
				SoundUtil.stop3DSample(self.sampleGearbox);
				SoundUtil.stop3DSample(self.sampleRetarder);
			else
				SoundUtil.play3DSample(self.sampleMotor);
				SoundUtil.play3DSample(self.sampleMotorRun);
			end
			-- adjust pitch and volume of samples
			if (self.wheels ~= nil and table.getn(self.wheels) > 0) or (self.dummyWheels ~= nil and table.getn(self.dummyWheels) > 0) then
				if self.sampleReverseDrive.sample ~= nil then
					if (accInput < 0 or accInput == 0) and (self:getLastSpeed() > 3 and self.movingDirection ~= self.reverserDirection) then
						if self:getIsActiveForSound() then
							SoundUtil.playSample(self.sampleReverseDrive, 0, 0, nil);
						end
					else
						SoundUtil.stopSample(self.sampleReverseDrive);
					end
				end
				local minRpm = self.motor:getMinRpm();
				local maxRpm = self.motor:getMaxRpm();
				local maxSpeed;
				if self.movingDirection >= 0 then
					maxSpeed = self.motor:getMaximumForwardSpeed()*0.001;
				else
					maxSpeed = self.motor:getMaximumBackwardSpeed()*0.001;
				end
				local motorRpm = self.motor:getEqualizedMotorRpm();
				-- Increase the motor rpm to the max rpm if faster than 75% of the full speed
				if self.movingDirection > 0 and self.lastSpeed > 0.75*maxSpeed and motorRpm < maxRpm then
					motorRpm = motorRpm + (maxRpm - motorRpm) * math.min((self.lastSpeed-0.75*maxSpeed) / (0.25*maxSpeed), 1);
				end
				-- The actual rpm offset is 50% from the motor and 50% from the speed
				local targetRpmOffset = (motorRpm - minRpm)*0.5 + math.min(self.lastSpeed/maxSpeed, 1)*(maxRpm-minRpm)*0.5;
				if Vehicle.debugRendering then
					renderText(0.3, 0.14, getCorrectTextSize(0.02), string.format("getLastMotorRpm() = %.2f", self.motor:getLastMotorRpm() ));
					renderText(0.3, 0.12, getCorrectTextSize(0.02), string.format("getEqualziedMotorRpm() = %.2f", self.motor:getEqualizedMotorRpm() ));
					renderText(0.3, 0.10, getCorrectTextSize(0.02), string.format("targetRpmOffset = %.2f", targetRpmOffset ));
				end
				local alpha = math.pow(0.01, dt*0.001);
				local roundPerMinute = targetRpmOffset + alpha*(self.lastRoundPerMinute-targetRpmOffset);
				self.lastRoundPerMinute = roundPerMinute;
				local roundPerSecondSmoothed = roundPerMinute / 60;
				if self.sampleMotor.sample ~= nil then
					local motorSoundPitch = math.min(self.sampleMotor.pitchOffset + self.motorSoundPitchScale*math.abs(roundPerSecondSmoothed), self.motorSoundPitchMax);
					SoundUtil.setSamplePitch(self.sampleMotor, motorSoundPitch);
					local deltaVolume = (self.sampleMotor.volume - self.motorSoundVolumeMin) * math.max(0.0, math.min(1.0, self:getLastSpeed()/self.motorSoundVolumeMinSpeed))
					SoundUtil.setSampleVolume(self.sampleMotor, math.max(self.motorSoundVolumeMin, self.sampleMotor.volume - deltaVolume));
				end;
				if self.sampleMotorRun.sample ~= nil then
					local motorSoundRunPitch = math.min(self.sampleMotorRun.pitchOffset + self.motorSoundRunPitchScale*math.abs(roundPerSecondSmoothed), self.motorSoundRunPitchMax);
					SoundUtil.setSamplePitch(self.sampleMotorRun, motorSoundRunPitch);
					local runVolume = roundPerMinute/(maxRpm - minRpm);
					if math.abs(accInput) < 0.01 or Utils.sign(accInput) ~= self.movingDirection or ptoVolume == 0 then
						runVolume = runVolume * 0.9;
					end;
					runVolume = Utils.clamp(runVolume, 0.0, 1.0);
					if Vehicle.debugRendering then
						renderText(0.3, 0.08, getCorrectTextSize(0.02), string.format("runVolume = %.2f", runVolume) );
					end
					if self.sampleMotorLoad.sample == nil then
						SoundUtil.setSampleVolume(self.sampleMotorRun, runVolume * self.sampleMotorRun.volume);
					else
						local motorSoundLoadPitch = math.min(self.sampleMotorLoad.pitchOffset + self.motorSoundLoadPitchScale*math.abs(roundPerSecondSmoothed), self.motorSoundLoadPitchMax);
						SoundUtil.setSamplePitch(self.sampleMotorLoad, motorSoundLoadPitch);
						if self.motorSoundLoadFactor < self.actualLoadPercentage then
							self.motorSoundLoadFactor = math.min(self.actualLoadPercentage, self.motorSoundLoadFactor + dt/500);
						elseif self.motorSoundLoadFactor > self.actualLoadPercentage then
							self.motorSoundLoadFactor = math.max(self.actualLoadPercentage, self.motorSoundLoadFactor - dt/750);
						end
						if Vehicle.debugRendering then
							renderText(0.3, 0.06, getCorrectTextSize(0.02), string.format("motorSoundLoadFactor = %.2f", self.motorSoundLoadFactor) );
						end
						SoundUtil.setSampleVolume(self.sampleMotorRun, math.max(self.motorSoundRunMinimalVolumeFactor, (1.0 - self.motorSoundLoadFactor) * runVolume * self.sampleMotorRun.volume) );
						SoundUtil.setSampleVolume(self.sampleMotorLoad, math.max(self.motorSoundLoadMinimalVolumeFactor, self.motorSoundLoadFactor * runVolume * self.sampleMotorLoad.volume) );
					end
				end
				--
				local pitchInfluence = 0;
				local volumeInfluence = 0;
				for i,wheel in pairs(self.wheels) do
					-- as in debug rendering, is this still correct?
					local susp = (wheel.netInfo.y - wheel.netInfo.yMin)/wheel.suspTravel - 0.2; -- If at yMin, we have -20% compression
					if wheel.netInfo.lastSusp == nil then
						wheel.netInfo.lastSusp = susp;
					end
					local delta = susp - wheel.netInfo.lastSusp;
					pitchInfluence = pitchInfluence + delta;
					volumeInfluence = volumeInfluence + math.abs(delta);
				end
				pitchInfluence = pitchInfluence / table.getn(self.wheels);
				volumeInfluence = volumeInfluence / table.getn(self.wheels);
				if pitchInfluence > self.pitchInfluenceFromWheels then
					self.pitchInfluenceFromWheels = math.min(pitchInfluence, self.pitchInfluenceFromWheels + dt/300);
				elseif pitchInfluence < self.pitchInfluenceFromWheels then
					self.pitchInfluenceFromWheels = math.max(pitchInfluence, self.pitchInfluenceFromWheels - dt/300);
				end
				if volumeInfluence > self.volumeInfluenceFromWheels then
					self.volumeInfluenceFromWheels = math.min(volumeInfluence, self.volumeInfluenceFromWheels + dt/300);
				elseif volumeInfluence < self.volumeInfluenceFromWheels then
					self.volumeInfluenceFromWheels = math.max(volumeInfluence, self.volumeInfluenceFromWheels - dt/300);
				end
				--renderText(0.8, 0.48, getCorrectTextSize(0.02), string.format("pitchInfluence = %.2f", pitchInfluence ));
				--renderText(0.7, 0.60, getCorrectTextSize(0.02), string.format("self.pitchInfluenceFromWheels = %.5f", self.pitchInfluenceFromWheels ));
				--renderText(0.7, 0.58, getCorrectTextSize(0.02), string.format("self.volumeInfluenceFromWheels = %.5f", self.volumeInfluenceFromWheels ));
				--
				if self.sampleGearbox.sample ~= nil then
					local speedFactor = Utils.clamp( (self:getLastSpeed() - 1) / math.ceil(self.motor:getMaximumForwardSpeed()*3.6), 0, 1);
					local pitchGearbox = Utils.lerp(self.sampleGearbox.pitchOffset, self.gearboxSoundPitchMax, speedFactor^self.gearboxSoundPitchExponent);
					local volumeGearbox = Utils.lerp(self.sampleGearbox.volume, self.gearboxSoundVolumeMax, speedFactor);
					if self.reverserDirection ~= self.movingDirection then
						speedFactor = Utils.clamp( (self:getLastSpeed() - 1) / math.ceil(self.motor:getMaximumBackwardSpeed()*3.6), 0, 1);
						pitchGearbox = Utils.lerp(self.sampleGearbox.pitchOffset, self.gearboxSoundReversePitchMax, speedFactor^self.gearboxSoundPitchExponent);
						volumeGearbox = Utils.lerp(self.sampleGearbox.volume, self.gearboxSoundReverseVolumeMax, speedFactor);
					end
					SoundUtil.setSamplePitch(self.sampleGearbox, pitchGearbox);
					SoundUtil.setSampleVolume(self.sampleGearbox, volumeGearbox);
				end
				if self.sampleRetarder.sample ~= nil then
					local speedFactor = Utils.clamp( (self:getLastSpeed() - self.retarderSoundMinSpeed) / math.ceil(self.motor:getMaximumForwardSpeed()*3.6), 0, 1);
					local pitchGearbox = Utils.lerp(self.sampleRetarder.pitchOffset, self.retarderSoundPitchMax, speedFactor);
					SoundUtil.setSamplePitch(self.sampleRetarder, pitchGearbox);
					local volumeRetarder = Utils.lerp(self.sampleRetarder.volume, self.retarderSoundVolumeMax, speedFactor);
					local targetVolume = 0.0;
					if accInput <= 0.0 and self:getLastSpeed() > self.retarderSoundMinSpeed and self.reverserDirection == self.movingDirection then
						if accInput > -0.9 then
							targetVolume = volumeRetarder;
						else
							targetVolume = self.sampleRetarder.volume;
						end
					end
					if self.retarderSoundActualVolume < targetVolume then
						self.retarderSoundActualVolume = math.min(targetVolume, self.retarderSoundActualVolume + dt/self.axisSmoothTime);
					elseif self.retarderSoundActualVolume > targetVolume then
						self.retarderSoundActualVolume = math.max(targetVolume, self.retarderSoundActualVolume - dt/self.axisSmoothTime);
					end
					SoundUtil.setSampleVolume(self.sampleRetarder, self.retarderSoundActualVolume);
					if Vehicle.debugRendering then
						renderText(0.8, 0.44, getCorrectTextSize(0.02), string.format("retarderSoundActualVolume = %.2f", self.retarderSoundActualVolume ));
						renderText(0.8, 0.42, getCorrectTextSize(0.02), string.format("getLastSpeed() = %.2f", self:getLastSpeed() ));
					end
				end
				if self.sampleBrakeCompressorRun.sample ~= nil then
					local pitchCompressor = math.min(self.sampleBrakeCompressorRun.pitchOffset + self.brakeCompressorRunSoundPitchScale*math.abs(roundPerSecondSmoothed), self.brakeCompressorRunSoundPitchMax);
					SoundUtil.setSamplePitch(self.sampleBrakeCompressorRun, pitchCompressor);
				end
			end
		end
		if self.isServer then
			if not self:getIsHired() then
				if self.lastMovedDistance > 0 then
					g_currentMission.missionStats:updateStats("traveledDistance", self.lastMovedDistance*0.001);
				end
			end
			self:updateFuelUsage(dt)
		end
	end
end

--======================================================================================================
-- updateTick
--======================================================================================================
-- Description

	-- Called on update tick

-- Definition

	-- updateTick(float dt)

-- Arguments
-- float	dt	time since last call in ms
--======================================================================================================
-- Code
function Motorized:updateTick(dt)
	if self.isServer then
		-- compare power
		--local torque,_ = self.motor:getTorque(1, false)*1000;
		--local motorPower = self.motor:getNonClampedMotorRpm()*math.pi/30*torque   -- [kW]
		--
		--self.actualLoadPercentage = motorPower / self.motor.maxMotorPower;
		-- compare torque I
		self.actualLoadPercentage = self.motor:getMotorLoad() / self.motor.maxMotorTorque;
		-- compare torque II
		--local torque,_ = self.motor:getTorque(1, false)*1000;
		--self.actualLoadPercentage = (self.motor:getMotorLoad() * 1000 / torque);
		if self:getIsActive() then
			--print(" --------------------- ");
			--print( string.format(" %.2f <= %.2f / %.2f", self.actualLoadPercentage, motorPower, self.motor.maxMotorPower) );
			--print( string.format(" %.2f <= %.2f / %.2f", self.actualLoadPercentage, self.motor:getMotorLoad(), self.motor.maxMotorTorque) );
			--print( string.format(" %.2f <= %.2f / %.2f", self.actualLoadPercentage, self.motor:getMotorLoad() * 1000, torque) );
		end
		local neededPtoTorque = PowerConsumer.getTotalConsumedPtoTorque(self);
		if neededPtoTorque > 0 then
			local ptoLoad = (neededPtoTorque / self.motor.ptoMotorRpmRatio) / self.motor.maxMotorTorque;
			self.actualLoadPercentage = math.min(1.0, self.actualLoadPercentage + ptoLoad);
		end
		if math.abs(self.fuelFillLevel-self.sentFuelFillLevel) > 0.001 then
			self:raiseDirtyFlags(self.motorizedDirtyFlag);
			self.sentFuelFillLevel = self.fuelFillLevel;
		end
		if self.isMotorStarted and not self.isControlled and not self.isEntered and not self:getIsHired() and not g_currentMission.missionInfo.automaticMotorStartEnabled then
			local isPlayerInRange = false
			local vx, vy, vz = getWorldTranslation(self.rootNode);
			for _, player in pairs(g_currentMission.players) do
				if player.isControlled then
					local px, py, pz = getWorldTranslation(player.rootNode);
					local distance = Utils.vector3Length(px-vx, py-vy, pz-vz);
					if distance < 250 then
						isPlayerInRange = true
						break
					end
				end;
			end;
			if not isPlayerInRange then
				for _, steerable in pairs(g_currentMission.steerables) do
					if steerable.isControlled then
						local px, py, pz = getWorldTranslation(steerable.rootNode);
						local distance = Utils.vector3Length(px-vx, py-vy, pz-vz);
						if distance < 250 then
							isPlayerInRange = true
							break
						end
					end;
				end;
			end
			if isPlayerInRange then
				self.motorStopTimer = g_motorStopTimerDuration
			else
				self.motorStopTimer = self.motorStopTimer - dt
				if self.motorStopTimer <= 0 then
					self:stopMotor()
				end
			end
		end
	end
	if self.isClient then
		if self:getIsMotorStarted() then
			if self.rpmHud ~= nil then
				VehicleHudUtils.setHudValue(self, self.rpmHud, self.motor:getEqualizedMotorRpm(), self.motor:getMaxRpm());
			end
			if self.speedHud ~= nil then
				local maxSpeed = 30;
				if self.cruiseControl ~= nil then
					maxSpeed = self.cruiseControl.maxSpeed;
				end
				VehicleHudUtils.setHudValue(self, self.speedHud, g_i18n:getSpeed(self:getLastSpeed() * self.speedDisplayScale), g_i18n:getSpeed(maxSpeed));
			end
			if self.exhaustParticleSystems ~= nil then
				for _, ps in pairs(self.exhaustParticleSystems) do
					local scale = Utils.lerp(self.exhaustParticleSystems.minScale, self.exhaustParticleSystems.maxScale, self.motor:getEqualizedMotorRpm() / self.motor:getMaxRpm());
					ParticleUtil.setEmitCountScale(self.exhaustParticleSystems, scale);
					ParticleUtil.setParticleLifespan(ps, ps.originalLifespan * scale)
				end
			end
			if self.exhaustFlap ~= nil then
				local minRandom = -0.1;
				local maxRandom = 0.1;
				local angle = Utils.lerp(minRandom, maxRandom, math.random()) + self.exhaustFlap.maxRot * (self.motor:getEqualizedMotorRpm() / self.motor:getMaxRpm());
				angle = Utils.clamp(angle, 0, self.exhaustFlap.maxRot);
				setRotation(self.exhaustFlap.node, angle, 0, 0);
			end
			if self.exhaustEffects ~= nil then
				local lastSpeed = self:getLastSpeed();
				self.currentDirection = {localDirectionToWorld(self.rootNode, 0, 0, 1)};
				if self.lastDirection == nil then
					self.lastDirection = self.currentDirection;
				end
				local x,y,z = worldDirectionToLocal(self.rootNode, self.lastDirection[1], self.lastDirection[2], self.lastDirection[3]);
				local dot = z;
				dot = dot / Utils.vector2Length(x,z);
				local angle = math.acos(dot);
				if x < 0 then
					angle = -angle;
				end
				local steeringPercent = math.abs((angle / dt) / self.exhaustEffectMaxSteeringSpeed);
				self.lastDirection = self.currentDirection;
				for _, effect in pairs(self.exhaustEffects) do
					local rpmScale = self.motor:getEqualizedMotorRpm() / self.motor:getMaxRpm();
					local scale = Utils.lerp(effect.minRpmScale, effect.maxRpmScale, rpmScale);
					local forwardXRot = 0;
					local forwardZRot = 0;
					local steerXRot = 0;
					local steerZRot = 0;
					local r = Utils.lerp(effect.minRpmColor[1], effect.maxRpmColor[1], rpmScale);
					local g = Utils.lerp(effect.minRpmColor[2], effect.maxRpmColor[2], rpmScale);
					local b = Utils.lerp(effect.minRpmColor[3], effect.maxRpmColor[3], rpmScale);
					local a = Utils.lerp(effect.minRpmColor[4], effect.maxRpmColor[4], rpmScale);
					setShaderParameter(effect.effectNode, "exhaustColor", r, g, b, a, false);
					-- speed rotation
					if self.movingDirection == 1 then
						local percent = Utils.clamp(lastSpeed/effect.maxForwardSpeed, 0, 1);
						forwardXRot = effect.xzRotationsForward[1] * percent;
						forwardZRot = effect.xzRotationsForward[2] * percent;
					elseif self.movingDirection == -1 then
						local percent = Utils.clamp(lastSpeed/effect.maxBackwardSpeed, 0, 1);
						forwardXRot = effect.xzRotationsBackward[1] * percent;
						forwardZRot = effect.xzRotationsBackward[2] * percent;
					end
					-- steering rotation
					if angle > 0 then
						steerXRot = effect.xzRotationsRight[1] * steeringPercent;
						steerZRot = effect.xzRotationsRight[2] * steeringPercent;
					elseif angle < 0 then
						steerXRot = effect.xzRotationsLeft[1] * steeringPercent;
						steerZRot = effect.xzRotationsLeft[2] * steeringPercent;
					end
					-- target rotations
					local targetXRot = effect.xzRotationsOffset[1] + forwardXRot + steerXRot;
					local targetZRot = effect.xzRotationsOffset[2] + forwardZRot + steerZRot;
					-- damping
					if targetXRot > effect.xRot then
						effect.xRot = math.min(effect.xRot + 0.003*dt, targetXRot);
					else
						effect.xRot = math.max(effect.xRot - 0.003*dt, targetXRot);
					end
					if targetZRot > effect.xRot then
						effect.zRot = math.min(effect.zRot + 0.003*dt, targetZRot);
					else
						effect.zRot = math.max(effect.zRot - 0.003*dt, targetZRot);
					end
					setShaderParameter(effect.effectNode, "param", effect.xRot, effect.zRot, 0, scale, false);
				end
			end
		end
	end
	if self.isFuelFilling then
		if self.isServer then
			local delta = 0;
			if self.fuelFillTrigger ~= nil then
				delta = self.fuelFillLitersPerSecond*dt*0.001;
				delta = self.fuelFillTrigger:fillFuel(self, delta);
			end
			if delta <= 0.001 then
				self:setIsFuelFilling(false);
			end
		end
	end
end

--======================================================================================================
-- draw
--======================================================================================================
-- Description

	-- Called on draw

-- Definition

	-- draw()

--======================================================================================================
-- Code
function Motorized:draw()
	if self.isEntered and self.isClient and not self:getIsHired() then
		if not g_currentMission.missionInfo.automaticMotorStartEnabled then
			if self.isMotorStarted then
				g_currentMission:addHelpButtonText(g_i18n:getText("action_stopMotor"), InputBinding.TOGGLE_MOTOR_STATE, nil, GS_PRIO_VERY_HIGH);
			else
				g_currentMission:addHelpButtonText(g_i18n:getText("action_startMotor"), InputBinding.TOGGLE_MOTOR_STATE, nil, GS_PRIO_VERY_HIGH);
			end
		end
	end
end

--======================================================================================================
-- startMotor
--======================================================================================================
-- Description

	-- Start motor

-- Definition

	-- startMotor(boolean noEventSend)

-- Arguments
-- boolean	noEventSend	no event send
--======================================================================================================
-- Code
function Motorized:startMotor(noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetMotorTurnedOnEvent:new(self, true), nil, nil, self);
		else
			g_client:getServerConnection():sendEvent(SetMotorTurnedOnEvent:new(self, true));
		end
	end
	if not self.isMotorStarted then
		self.isMotorStarted = true;
		if self.isClient then
			if self.exhaustParticleSystems ~= nil then
				for _, ps in pairs(self.exhaustParticleSystems) do
					ParticleUtil.setEmittingState(ps, true)
				end
			end
			if self:getIsActiveForSound() then
				SoundUtil.playSample(self.sampleMotorStart, 1, 0, nil);
			end
			if self.exhaustEffects ~= nil then
				for _, effect in pairs(self.exhaustEffects) do
					setVisibility(effect.effectNode, true);
					effect.xRot = effect.xzRotationsOffset[1];
					effect.zRot = effect.xzRotationsOffset[2];
					setShaderParameter(effect.effectNode, "param", effect.xRot, effect.zRot, 0, 0, false);
					local color = effect.minRpmColor;
					setShaderParameter(effect.effectNode, "exhaustColor", color[1], color[2], color[3], color[4], false);
				end
			end
		end
		self.motorStartTime = g_currentMission.time + self.motorStartDuration;
		self.compressionSoundTime = g_currentMission.time + math.random(5000, 20000);
		self.lastRoundPerMinute=0;
		if self.fuelFillLevelHud ~= nil then
			VehicleHudUtils.setHudValue(self, self.fuelFillLevelHud, self.fuelFillLevel, self.fuelCapacity);
		end
	end
end

--======================================================================================================
-- stopMotor
--======================================================================================================
-- Description

	-- Stop motor

-- Definition

	-- stopMotor(boolean noEventSend)

-- Arguments
-- boolean	noEventSend	no event send
--======================================================================================================
-- Code
function Motorized:stopMotor(noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(SetMotorTurnedOnEvent:new(self, false), nil, nil, self);
		else
			g_client:getServerConnection():sendEvent(SetMotorTurnedOnEvent:new(self, false));
		end
	end
	self.isMotorStarted = false;
	Motorized.onDeactivateSounds(self);
	if self.isClient then
		if self.exhaustParticleSystems ~= nil then
			for _, ps in pairs(self.exhaustParticleSystems) do
				ParticleUtil.setEmittingState(ps, false)
			end
		end
		if self:getIsActiveForSound() then
			SoundUtil.playSample(self.sampleMotorStop, 1, 0, nil);
			SoundUtil.playSample(self.sampleBrakeCompressorStop, 1, 0, nil);
		end
		local airConsumption = self:getMaximalAirConsumptionPerFullStop();
		self.brakeCompressor.fillLevel = math.max(0, self.brakeCompressor.fillLevel - airConsumption);
		self.brakeCompressor.startSoundPlayed = false;
		self.brakeCompressor.runSoundActive = false;
		if self.exhaustEffects ~= nil then
			for _, effect in pairs(self.exhaustEffects) do
				setVisibility(effect.effectNode, false);
			end
		end
		if self.exhaustFlap ~= nil then
			setRotation(self.exhaustFlap.node, 0, 0, 0);
		end
		if self.rpmHud ~= nil then
			VehicleHudUtils.setHudValue(self, self.rpmHud, 0, self.motor:getMaxRpm());
		end
		if self.speedHud ~= nil then
			VehicleHudUtils.setHudValue(self, self.speedHud, 0, g_i18n:getSpeed(self.motor:getMaximumForwardSpeed()));
		end
		if self.fuelFillLevelHud ~= nil then
			VehicleHudUtils.setHudValue(self, self.fuelFillLevelHud, 0, self.fuelCapacity);
		end
	end
	Motorized.turnOffImplement(self);
end

--======================================================================================================
-- turnOffImplement
--======================================================================================================
-- Description

	-- Turn off implement and childs of implement

-- Definition

	-- turnOffImplement(table object)

-- Arguments
-- table	object	object to turn off
--======================================================================================================
-- Code
function Motorized.turnOffImplement(object)
	if object.setIsTurnedOn ~= nil then
		object:setIsTurnedOn(false, true);
	end
	for _,implement in pairs(object.attachedImplements) do
		if implement.object ~= nil then
			Motorized.turnOffImplement(implement.object);
		end
	end
end

--======================================================================================================
-- onDeactivateSounds
--======================================================================================================
-- Description

	-- Called on deactivating sounds

-- Definition

	-- onDeactivateSounds()

--======================================================================================================
-- Code
function Motorized:onDeactivateSounds()
	if self.isClient then
		SoundUtil.stopSample(self.sampleMotor, true);
		SoundUtil.stopSample(self.sampleMotorRun, true);
		SoundUtil.stopSample(self.sampleMotorLoad, true);
		SoundUtil.stopSample(self.sampleGearbox, true);
		SoundUtil.stopSample(self.sampleRetarder, true);
		SoundUtil.stopSample(self.sampleMotorStart, true);
		SoundUtil.stopSample(self.sampleBrakeCompressorStart, true);
		SoundUtil.stopSample(self.sampleBrakeCompressorRun, true);
		SoundUtil.stopSample(self.sampleAirReleaseValve, true);
		SoundUtil.stopSample(self.sampleReverseDrive, true);
		SoundUtil.stop3DSample(self.sampleMotor, true);
		SoundUtil.stop3DSample(self.sampleMotorRun, true);
	end
end

--======================================================================================================
-- onEnter
--======================================================================================================
-- Description

	-- Called on enter vehicle

-- Definition

	-- onEnter(boolean isControlling)

-- Arguments
-- boolean	isControlling	is player controlling the vehicle
--======================================================================================================
-- Code
function Motorized:onEnter(isControlling)
	if g_currentMission.missionInfo.automaticMotorStartEnabled then
		self:startMotor(true)
	end
end

--======================================================================================================
-- onLeave
--======================================================================================================
-- Description

	-- Called on leaving the vehicle

-- Definition

	-- onLeave()

--======================================================================================================
-- Code
function Motorized:onLeave()
	if self.stopMotorOnLeave and g_currentMission.missionInfo.automaticMotorStartEnabled then
		self:stopMotor(true);
	end
	Motorized.onDeactivateSounds(self);
end

--======================================================================================================
-- setFuelFillLevel
--======================================================================================================
-- Description

	-- Set fuel fill level

-- Definition

	-- setFuelFillLevel(float newFillLevel)

-- Arguments
-- float	newFillLevel	new fuel fill level
--======================================================================================================
-- Code
function Motorized:setFuelFillLevel(newFillLevel)
	self.fuelFillLevel = math.max(math.min(newFillLevel, self.fuelCapacity), 0);
	if self.fuelFillLevelHud ~= nil and math.abs(self.lastFuelFillLevel-self.fuelFillLevel) > 0.1 then
		VehicleHudUtils.setHudValue(self, self.fuelFillLevelHud, self.fuelFillLevel, self.fuelCapacity);
		self.lastFuelFillLevel = self.fuelFillLevel;
	end
	if self.fuelFillLevel == 0 and self:getIsHired() then
		self:stopAIVehicle(AIVehicle.STOP_REASON_OUT_OF_FUEL)
	end
end

--======================================================================================================
-- updateFuelUsage
--======================================================================================================
-- Description

	-- Update fuel usage

-- Definition

	-- updateFuelUsage(float dt)

-- Arguments
-- float	dt	time since last call in ms
-- Return Values
-- boolean	success	success
--======================================================================================================
-- Code
function Motorized:updateFuelUsage(superFunc, dt)
	if superFunc ~= nil then
		if not superFunc(self, dt) then
			return false
		end
	end
	local rpmFactor = math.max(0.02, (self.motor:getLastMotorRpm()-self.motor:getMinRpm())/(self.motor:getMaxRpm()-self.motor:getMinRpm()));
	local loadFactor = self.motorSoundLoadFactor
	local fuelUsageFactor = 1
	if g_currentMission.missionInfo.fuelUsageLow then
		fuelUsageFactor = 0.7
	end
	local fuelUsed = fuelUsageFactor * rpmFactor * (self.fuelUsage * dt);
	if fuelUsed > 0 then
		if not self:getIsHired() or not g_currentMission.missionInfo.helperBuyFuel then
			self:setFuelFillLevel(self.fuelFillLevel-fuelUsed);
			g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed);
		elseif self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
			local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL)
			g_currentMission.missionStats:updateStats("expenses", delta);
			g_currentMission:addSharedMoney(-delta, "purchaseFuel");
		end
	end
	if self.fuelUsageHud ~= nil then
		VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsed*1000/dt*60*60);
	end
	return true
end

--======================================================================================================
-- setIsFuelFilling
--======================================================================================================
-- Description

	-- Set is fuel filling

-- Definition

	-- setIsFuelFilling(boolean isFilling, boolean noEventSend)

-- Arguments
-- boolean	isFilling	new is filling state
-- boolean	noEventSend	no event send
--======================================================================================================
-- Code
function Motorized:setIsFuelFilling(isFilling, noEventSend)
	if isFilling ~= self.isFuelFilling then
		if noEventSend == nil or noEventSend == false then
			if g_server ~= nil then
				g_server:broadcastEvent(SteerableToggleRefuelEvent:new(self, isFilling), nil, nil, self);
			else
				g_client:getServerConnection():sendEvent(SteerableToggleRefuelEvent:new(self, isFilling));
			end
		end
		self.isFuelFilling = isFilling;
		if isFilling then
			-- find the first trigger which is activable
			self.fuelFillTrigger = nil;
			for i=1, table.getn(self.fuelFillTriggers) do
				local trigger = self.fuelFillTriggers[i];
				if trigger:getIsActivatable(self) then
					self.fuelFillTrigger = trigger;
					break;
				end
			end
		end
		if self.isClient and self.sampleRefuel ~= nil then
			if isFilling then
				SoundUtil.play3DSample(self.sampleRefuel);
			else
				SoundUtil.stop3DSample(self.sampleRefuel);
			end
		end
	end
end

--======================================================================================================
-- addFuelFillTrigger
--======================================================================================================
-- Description

	-- Adds fuel fill trigger if vehicle enters one

-- Definition

	-- addFuelFillTrigger(table trigger)

-- Arguments
-- table	trigger	trigger
--======================================================================================================
-- Code
function Motorized:addFuelFillTrigger(trigger)
	if table.getn(self.fuelFillTriggers) == 0 then
		g_currentMission:addActivatableObject(self.motorizedFillActivatable);
	end
	table.insert(self.fuelFillTriggers, trigger);
end

--======================================================================================================
-- removeFuelFillTrigger
--======================================================================================================
-- Description

	-- Removes fuel fill trigger if vehicle leaves one

-- Definition

	-- removeFuelFillTrigger(table trigger)

-- Arguments
-- table	trigger	trigger
--======================================================================================================
-- Code
function Motorized:removeFuelFillTrigger(trigger)
	for i=1, table.getn(self.fuelFillTriggers) do
		if self.fuelFillTriggers[i] == trigger then
			table.remove(self.fuelFillTriggers, i);
			break;
		end
	end
	if table.getn(self.fuelFillTriggers) == 0 or trigger == self.fuelFillTrigger then
		if self.isServer then
			self:setIsFuelFilling(false);
		end
		if table.getn(self.fuelFillTriggers) == 0 then
			g_currentMission:removeActivatableObject(self.motorizedFillActivatable);
		end
	end
end

--======================================================================================================
-- getIsMotorStarted
--======================================================================================================
-- Description

	-- Returns if motor is stated

-- Definition

	-- getIsMotorStarted()

-- Return Values
-- boolean	isStarted	motor is started
--======================================================================================================
-- Code
function Motorized:getIsMotorStarted(superFunc)
	local parent = true;
	if superFunc ~= nil then
		parent = parent and superFunc(self);
	end
	return parent and self.isMotorStarted
end;

--======================================================================================================
-- getDeactivateOnLeave
--======================================================================================================
-- Description

	-- Returns if vehicle deactivates on leave

-- Definition

	-- getDeactivateOnLeave()

-- Return Values
-- boolean	deactivate	vehicle deactivates on leave
--======================================================================================================
-- Code
function Motorized:getDeactivateOnLeave(superFunc)
	local deactivate = true
	if superFunc ~= nil then
		deactivate = deactivate and superFunc(self)
	end
	return deactivate and g_currentMission.missionInfo.automaticMotorStartEnabled
end;

--======================================================================================================
-- getDeactivateLights
--======================================================================================================
-- Description

	-- Returns if light deactivate on leaving

-- Definition

	-- getDeactivateLights()

-- Return Values
-- boolean	deactivate	deactivate on leaving
--======================================================================================================
-- Code
function Motorized:getDeactivateLights(superFunc)
	local deactivate = true
	if superFunc ~= nil then
		deactivate = deactivate and superFunc(self)
	end
	return deactivate and g_currentMission.missionInfo.automaticMotorStartEnabled
end;

--======================================================================================================
-- minuteChanged
--======================================================================================================
-- Description

	-- Called if ingame minute changes

-- Definition

	-- minuteChanged()

--======================================================================================================
-- Code
function Motorized:minuteChanged()
	local minutes = g_currentMission.environment.currentMinute;
	local hours = g_currentMission.environment.currentHour;
	local minutesString = string.format("%02d", minutes);
	VehicleHudUtils.setHudValue(self, self.timeHud, tonumber(hours.."."..minutesString), 9999);
end