function WheelsUtil.updateWheelsPhysics(self, dt, currentSpeed, acceleration, doHandbrake, requiredDriveMode)
	local accelerationPedal = 0;
	local brakePedal = 0;
	if not g_currentMission.missionInfo.stopAndGoBraking then
		self.hasStopped = Utils.getNoNil(self.hasStopped, false);
		self.nextMovingDirection = Utils.getNoNil(self.nextMovingDirection, 0);
		if math.abs(acceleration) < 0.001 and math.abs(self.lastSpeedAcceleration) < 0.0001 and math.abs(self.lastSpeedReal) < 0.0001 and math.abs(self.lastMovedDistance) < 0.001 then
			self.hasStopped = true;
			accelerationPedal = 0;
			brakePedal = 1;
		elseif math.abs(self.lastSpeedReal) > 0.0001 then
			self.hasStopped = false;
		end
		if self.hasStopped and math.abs(acceleration) > 0.001 then
			self.nextMovingDirection = acceleration;
		end
		if self.nextMovingDirection * acceleration > 0.001 then
			accelerationPedal = acceleration;
			brakePedal = 0;
		elseif not self.hasStopped then
			accelerationPedal = 0;
			if self.nextMovingDirection == 0 then
				brakePedal = 1;
			else
				--brakePedal = math.abs(acceleration);
				if math.abs(acceleration) < 0.001 then
					if currentSpeed < self.motor.lowBrakeForceSpeedLimit or doHandbrake then
						if math.abs(self.rotatedTime) < 0.01 or self.articulatedAxis == nil then
							brakePedal = 1;
						end
					else
						brakePedal = self.motor.lowBrakeForceScale;
					end
				else
					brakePedal = math.abs(acceleration);
				end
			end
		end
	else
		local brakeAcc = false;
		if (self.movingDirection*currentSpeed*Utils.sign(acceleration*self.reverserDirection)) < -0.0003 then	  -- 0.0003 * 3600 = 1.08 km/h
			-- do we want to accelerate in the opposite direction of the vehicle speed?
			brakeAcc = true;
		end;
		if math.abs(acceleration) < 0.001 then
			accelerationPedal = 0;
			if currentSpeed < self.motor.lowBrakeForceSpeedLimit or doHandbrake then
				if math.abs(self.rotatedTime) < 0.01 or self.articulatedAxis == nil then
					brakePedal = 1;
				end;
			else
				brakePedal = self.motor.lowBrakeForceScale;
			end;
		else
			if not brakeAcc then
				accelerationPedal = acceleration;
				brakePedal = 0;
			else
				accelerationPedal = 0;
				brakePedal = math.abs(acceleration);
			end;
		end;
	end
	--self:setBrakeLightsVisibility(brakePedal > 0);
	if g_currentMission.missionInfo.stopAndGoBraking then
		self:setBrakeLightsVisibility(brakePedal > 0 and currentSpeed > 0.0003 and acceleration < -0.001);
	else
		self:setBrakeLightsVisibility(brakePedal > 0 and not self.hasStopped and acceleration < -0.001);
	end
	self:setReverseLightsVisibility(self.movingDirection < 0 and (currentSpeed > 0.0006 or accelerationPedal < 0) and self.reverserDirection == 1);
	self.motor:updateMotorRpm(dt);
	self.motor:updateGear(accelerationPedal, dt);
	local absAccelerationPedal = math.abs(accelerationPedal);
	local wheelDriveTorque = 0;
	--print(string.format("brakeAcc:%s  acc.:%6.4f  accPed.:%6.4f  braPed.:%6.4f  curSpeed:%6.4f", tostring(brakeAcc), acceleration, accelerationPedal, brakePedal, currentSpeed));
	if next(self.differentials) ~= nil and self.motorizedNode ~= nil then
		--print(string.format("set vehicle props: %.2fkN %.1frpm ratio: %.1f", self.motor:getTorque(accelerationPedal, false), self.motor:getCurMaxRpm(), self.motor:getGearRatio()));
		local maxRotSpeed = self.motor:getCurMaxRpm() * math.pi / 30;
		local torque = self.motor:getTorque(accelerationPedal * self.reverserDirection, false);
		setVehicleProps(self.motorizedNode, torque, maxRotSpeed, self.motor:getGearRatio() * self.reverserDirection, self.motor:getMaxClutchTorque(), self.motor:getRotInertia(), self.motor:getDampingRate());
	else
		-- ToDo: can be dismissed, or do we still want to support vehicles without a differential?
		local numTouching = 0;
		local numNotTouching = 0;
		local numHandbrake = 0;
		local axleSpeedSum = 0;
		for _, wheel in pairs(self.wheels) do
			if wheel.driveMode >= requiredDriveMode then
				if doHandbrake and wheel.hasHandbrake then
					numHandbrake = numHandbrake +1;
				else
					if wheel.hasGroundContact then
						numTouching = numTouching+1;
					else
						numNotTouching = numNotTouching+1;
					end
				end
			end
		end
		if numTouching > 0 and absAccelerationPedal > 0.01 then
			local axisTorque, brakePedalMotor = WheelsUtil.getWheelTorque(self, accelerationPedal);
			if axisTorque ~= 0 then
				wheelDriveTorque = axisTorque / (numTouching+numNotTouching); --*0.7);
			else
				brakePedal = brakePedalMotor;
			end
		end
	end
	local doBrake = brakePedal > 0; --(brakePedal > 0 and self.lastSpeed > 0.0002) or doHandbrake;			  -- ToDo
	for _, implement in pairs(self.attachedImplements) do
		if implement.object ~= nil then
			if doBrake then
				implement.object:onBrake(brakePedal);
			else
				implement.object:onReleaseBrake();
			end
		end
	end
	for _, wheel in pairs(self.wheels) do
		WheelsUtil.updateWheelPhysics(self, wheel, doHandbrake, wheelDriveTorque, brakePedal, requiredDriveMode, dt)
	end
end