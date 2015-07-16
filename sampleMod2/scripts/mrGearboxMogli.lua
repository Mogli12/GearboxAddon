--***************************************************************
--
-- mrGearboxMogli
-- 
-- version 1.106 by mogli (biedens)
-- 2015/03/09
--
--***************************************************************

local mrGearboxMogliVersion=1.106

-- allow modders to include this source file together with mogliBase.lua in their mods
if mrGearboxMogli == nil or mrGearboxMogli.version == nil or mrGearboxMogli.version < mrGearboxMogliVersion then

--***************************************************************
mogliBase20.newClass( "mrGearboxMogli", "mrGbMS" )
--***************************************************************

mrGearboxMogli.version              = mrGearboxMogliVersion
mrGearboxMogli.huge                 = 1000000
mrGearboxMogli.eps                  = 1E-6
mrGearboxMogli.factor30pi           = 9.5492965855137201461330258023509
mrGearboxMogli.factorpi30           = 0.10471975511965977461542144610932
mrGearboxMogli.factor255            = 0.0039215686274509803921568627451
mrGearboxMogli.rpmMinus             = 100  -- min RPM at 900 RPM
mrGearboxMogli.rpmFadeOut           = 100  -- no torque at 2300 RPM
mrGearboxMogli.rpmPlus              = 200  -- braking at 2350 RPM
mrGearboxMogli.ptoRpmMinus          = 300  -- reduce PTO RPM; e.g. 1900 with PTO and 2200 rated RPM
mrGearboxMogli.minClutchPercent     = 1E-3
mrGearboxMogli.maxGearRatio         = 260  -- 1.30 km/h @900 RPM / 3.19 km/h @2200 RPM / gear ratio might be bigger, but no clutch in this case
mrGearboxMogli.maxHydroGearRatio    = 1659 -- 0.5 km/h @rated RPM / gear ratio might be bigger, but no clutch in this case
mrGearboxMogli.brakeFxSpeed         = 5    -- m/s = 18 km/h
mrGearboxMogli.rpmReduction         = 0.93 -- 7% RPM reduction allowed
mrGearboxMogli.smooth1              = 0.030 --0.05
mrGearboxMogli.smooth2              = 0.010 --0.025
mrGearboxMogli.smoothRpm            = 0.125
mrGearboxMogli.smoothPossible       = 0.05
mrGearboxMogli.smoothSpeed          = 0.2
mrGearboxMogli.smoothLastSpeed      = 0.02
mrGearboxMogli.smoothTorque         = 0.125 -- careful if used together with limitRpmIncrease="M"!
mrGearboxMogli.smoothHydro          = 0.5
mrGearboxMogli.hydroEffDiff         = 75
mrGearboxMogli.powerFactor0         = 0.1424083769633507853403141361257
mrGearboxMogli.powerFactor          = 0.12735463732663294333816676444222 -- with torqueFactor !!! original is 0.1424083769633507853403141361257
mrGearboxMogli.accDeadZone          = 0.15
mrGearboxMogli.blowOffVentilTime0   = 1000
mrGearboxMogli.blowOffVentilTime1   = 1000
mrGearboxMogli.blowOffVentilTime2   = 100
mrGearboxMogli.limitRpmIncrease     = "H" -- "H"uge/"T"orque/"M"axPossible/"TM" see smoothTorque
mrGearboxMogli.debugGearShift       = false
mrGearboxMogli.globalsLoaded        = false
mrGearboxMogli.rpmIncPerGearSpeed   = false
mrGearboxMogli.superFastDownShift   = false
mrGearboxMogli.resetSoundTime       = 400
mrGearboxMogli.consoleCommand       = false

mrGearboxMogliGlobals                       = {}
mrGearboxMogliGlobals.torqueFactor          = 1.1182033096926713947990543735225  -- Giants is cheating: 0.86 * 0.88 = 0.7568 > 0.72 => torqueFactor = 0.86 * 0.88 / ( 0.72 * 0.94 )
mrGearboxMogliGlobals.blowOffVentilVol      = 0.14
mrGearboxMogliGlobals.drawTargetRpm         = false 
mrGearboxMogliGlobals.drawReqPower          = false
mrGearboxMogliGlobals.defaultOn             = true
mrGearboxMogliGlobals.disableManual         = false
mrGearboxMogliGlobals.blowOffVentilRpmRatio = 0.7
mrGearboxMogliGlobals.minTimeToShift			  = 0  -- ms
mrGearboxMogliGlobals.maxTimeToSkipGear  	  = 251 -- ms
mrGearboxMogliGlobals.shiftEffectTime			  = 251 -- ms
mrGearboxMogliGlobals.modifySound           = true
mrGearboxMogliGlobals.modifyVolume          = true
mrGearboxMogliGlobals.modifyTransVol        = true
mrGearboxMogliGlobals.shiftTimeMsFactor     = 1
mrGearboxMogliGlobals.playGrindingSound     = true
--setSamplePitch( mrGearboxMogli.BOVSample, 0.85 )

--**********************************************************************************************************	
-- mrGearboxMogli.prerequisitesPresent 
--**********************************************************************************************************	
function mrGearboxMogli.prerequisitesPresent(specializations) 
	return true
end 

--**********************************************************************************************************	
-- mrGearboxMogli:load
--**********************************************************************************************************	
function mrGearboxMogli:load(xmlFile) 
	local key = "vehicle.gearboxMogli"
	if hasXMLProperty(xmlFile, key) then
		mrGearboxMogli.initFromXml(self,xmlFile,key,"vehicle",true)
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli.getNoNil2
--**********************************************************************************************************	
function mrGearboxMogli.getNoNil2( v0, v1, v2, use2 )
	if v0 == nil then
		if v2 ~= nil and use2 then
			return v2
		end
		return v1
	end
	return v0
end

--**********************************************************************************************************	
-- mrGearboxMogli generic getter methods
--**********************************************************************************************************	
mrGearboxMogli.stateWithSetGet = { "IsOnOff", 
                                   "CurrentGear", 
																	 "CurrentRange", 
																	 "CurrentRange2",
																	 "Automatic", 
																	 "NeutralActive", 
																	 "ReverseActive", 
																	 "SpeedLimiter",  
																	 "HandThrottle", 
																	 "AutoClutch", 
																	 "ManualClutch",
																	 "AccelerateToLimit",
																	 "DecelerateToLimit" }

for _,state in pairs( mrGearboxMogli.stateWithSetGet ) do
	mrGearboxMogli["mrGbMGet"..state] = function(self)
		return self.mrGbMS[state]
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:initClient
--**********************************************************************************************************	
function mrGearboxMogli:initClient()		
	-- state
	self.mrGbMS = {}
	-- locals used for calculations
	self.mrGbML = {}
	-- draw
	self.mrGbMD = {}
	-- backup
	self.mrGbMB = {}

	self.mrGbMSetState    = mrGearboxMogli.mbSetState
	self.mrGbMDoGearShift = mrGearboxMogli.mrGbMDoGearShift
	
	mrGearboxMogli.registerState( self, "IsOn",          false, mrGearboxMogli.mrGbMOnSetIsOn )
	mrGearboxMogli.registerState( self, "BlowOffVentilPlay",false )
	mrGearboxMogli.registerState( self, "GrindingGearsPlay",false )
	mrGearboxMogli.registerState( self, "ResetSoundRPM", -1 )
	mrGearboxMogli.registerState( self, "DrawText",      "off" )
	mrGearboxMogli.registerState( self, "G27Mode",       0 ) 	
	mrGearboxMogli.registerState( self, "WarningText",   "",    mrGearboxMogli.mrGbMOnSetWarningText )
	mrGearboxMogli.registerState( self, "InfoText",      "",    mrGearboxMogli.mrGbMOnSetInfoText )
	
--**********************************************************************************************************	
-- state variables with setter methods	
	for _,state in pairs( mrGearboxMogli.stateWithSetGet ) do
		self["mrGbMSet"..state] = mrGearboxMogli["mrGbMSet"..state] 
		self["mrGbMGet"..state] = mrGearboxMogli["mrGbMGet"..state] 
	end
	
	mrGearboxMogli.initStateHandling( self )
	mrGearboxMogli.registerState( self, "IsOnOff",       false )
	mrGearboxMogli.registerState( self, "CurrentGear",   1,     mrGearboxMogli.mrGbMOnSetGear ) 
	mrGearboxMogli.registerState( self, "CurrentRange",  1,     mrGearboxMogli.mrGbMOnSetRange )
	mrGearboxMogli.registerState( self, "CurrentRange2", 1,     mrGearboxMogli.mrGbMOnSetRange2 )
	mrGearboxMogli.registerState( self, "Automatic",     false )
	mrGearboxMogli.registerState( self, "ReverseActive", false, mrGearboxMogli.mrGbMOnSetReverse )
	mrGearboxMogli.registerState( self, "NeutralActive", false, mrGearboxMogli.mrGbMOnSetNeutral ) 	
	mrGearboxMogli.registerState( self, "AutoClutch",    true )
	mrGearboxMogli.registerState( self, "ManualClutch",  1,     mrGearboxMogli.mrGbMOnSetManualClutch )
	mrGearboxMogli.registerState( self, "HandThrottle",  0 )
	mrGearboxMogli.registerState( self, "SpeedLimiter",    false )

--**********************************************************************************************************	
-- special getter functions for motor parameters
	self.mrGbMGetClutchPercent  = mrGearboxMogli.mrGbMGetClutchPercent 
	self.mrGbMGetTargetRPM      = mrGearboxMogli.mrGbMGetTargetRPM
	self.mrGbMGetMotorLoad      = mrGearboxMogli.mrGbMGetMotorLoad 
	self.mrGbMGetUsedPower      = mrGearboxMogli.mrGbMGetUsedPower
	self.mrGbMGetModeText       = mrGearboxMogli.mrGbMGetModeText 
	self.mrGbMGetGearText       = mrGearboxMogli.mrGbMGetGearText 
	self.mrGbMGetIsOn           = mrGearboxMogli.mrGbMGetIsOn 

--**********************************************************************************************************	

	self.mrGbML.lastSumDt          = 0 
	self.mrGbML.soundSumDt         = 0 
	self.mrGbML.autoShiftUpTimer   = 0
	self.mrGbML.autoShiftDownTimer = 0
	self.mrGbML.currentGearSpeed   = 0	
	self.mrGbML.warningTimer       = 0	
	self.mrGbML.infoTimer          = 0	
	self.mrGbML.manualClutchTime   = 0
	self.mrGbML.gearShiftingNeeded = 0 
	self.mrGbML.gearShiftingTime   = 0 
	self.mrGbML.clutchShiftingTime = 0 
	self.mrGbML.doubleClutch       = false
	self.mrGbML.dirtyFlag          = self:getNextDirtyFlag() 
	self.mrGbML.wantedAcceleration = 0
	self.mrGbML.blowOffVentilTime0 = 0
	self.mrGbML.blowOffVentilTime1 = 0
	self.mrGbML.blowOffVentilTime2 = -1
	self.mrGbML.resetSoundTimer    = -1
	
	self.mrGbMD.Rpm        = 0 
	self.mrGbMD.lastRpm    = 0 
	self.mrGbMD.Clutch     = 0 
	self.mrGbMD.lastClutch = 0 
	self.mrGbMD.Load       = 0   
	self.mrGbMD.lastLoad   = 0   
	self.mrGbMD.Speed      = 0 
	self.mrGbMD.lastSpeed  = 0 
	self.mrGbMD.Fuel       = 0 
	self.mrGbMD.lastPower  = 0 
	self.mrGbMD.Power      = 0 
	
end 

--**********************************************************************************************************	
-- mrGearboxMogli.completeXMLGearboxEntry
--**********************************************************************************************************	
function mrGearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, fixEntry )
	local newEntry = fixEntry
	newEntry.reverseOnly    = getXMLBool( xmlFile, baseName .. "#reverseOnly" )		
	newEntry.forwardOnly    = getXMLBool( xmlFile, baseName .. "#forwardOnly" )
	newEntry.minGear        = getXMLFloat(xmlFile, baseName .. "#minGear" )
	newEntry.maxGear        = getXMLFloat(xmlFile, baseName .. "#maxGear" )
	newEntry.minRange       = getXMLFloat(xmlFile, baseName .. "#minRange" )
	newEntry.maxRange       = getXMLFloat(xmlFile, baseName .. "#maxRange" )
	newEntry.minRange2      = getXMLFloat(xmlFile, baseName .. "#minRange2" )
	newEntry.maxRange2      = getXMLFloat(xmlFile, baseName .. "#maxRange2" )
	return newEntry
end

--**********************************************************************************************************	
-- mrGearboxMogli:initFromXml
--**********************************************************************************************************	
function mrGearboxMogli:initFromXml(xmlFile,xmlString,xmlSource,serverAndClient) 

	mrGearboxMogli.initClient( self )		
	
	local excludeList = {}
	local default 
	
--**************************************************************************************************	
	if serverAndClient then
		mrGearboxMogliGlobals.modifySound    = false
		mrGearboxMogliGlobals.modifyVolume   = true
		mrGearboxMogliGlobals.modifyTransVol = false
		mrGearboxMogliGlobals.playGrindingSound = false
		mrGearboxMogli.globalsLoad2( xmlFile, "vehicle.gearboxMogliGlobals", mrGearboxMogliGlobals )	
		mrGearboxMogli.powerFactor = mrGearboxMogli.powerFactor0 / mrGearboxMogliGlobals.torqueFactor
	else
		if not( mrGearboxMogli.globalsLoaded ) then
			mrGearboxMogli.globalsLoaded = true
			file = mrGearboxMogli.modsDirectory.."zzzMrGearboxAddonConfig.xml"
			if fileExists(file) then	
				mrGearboxMogli.globalsLoad( file, "vehicles.gearboxMogliGlobals", mrGearboxMogliGlobals )	
				mrGearboxMogli.powerFactor = mrGearboxMogli.powerFactor0 / mrGearboxMogliGlobals.torqueFactor
			end		
		end
	
		if self.mrGbMS ~= nil then
			for n,_ in pairs(self.mrGbMS) do
				excludeList[n] = true
			end	
		end	
	end
	
--**************************************************************************************************	
	
	self.mrGbMS.ConfigVersion           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#version" ),1.4)
	self.mrGbMS.DefaultOn               = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#defaultOn" ),mrGearboxMogliGlobals.defaultOn)
	self.mrGbMS.showHud                 = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#showHud" ),true)
	self.mrGbMS.SwapGearRangeKeys       = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#swapGearRangeKeys" ),false)
	self.mrGbMS.TransmissionEfficiency  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#transmissionEfficiency"), 0.94) 
	self.mrGbMS.TransmissionEfficiencyDec=Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#transmissionEfficiencyDec"), 0 ) --0.07)
			
	self.mrGbMS.IdleRpm	                = self.motor.minRpm
	self.mrGbMS.RatedRpm                = self.motor.maxRpm	
	self.mrGbMS.PtoRpm                  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#ptoRpm"), self.mrGbMS.RatedRpm - mrGearboxMogli.ptoRpmMinus ) -- no automatic opening of clutch by default!!!
	
	self.mrGbMS.AccelerateToLimit       = 5  -- km/h per second
	self.mrGbMS.DecelerateToLimit       = 10 -- km/h per second
	
--**************************************************************************************************	
--**************************************************************************************************	
	self.mrGbMS.Engine = {}
	self.mrGbMS.Engine.maxTorque = 0;
	self.mrGbMS.Engine.maxTorqueRpm = 0;
	self.mrGbMS.Engine.minRpm = mrGearboxMogli.huge;
	self.mrGbMS.Engine.maxRpm = 0;

	local torqueI = 0;
	local torqueF = nil
	while true do
		local key = string.format(xmlString..".realEngine.torque(%d)", torqueI);
		local rpm = getXMLFloat(xmlFile, key.."#rpm");
		local torque = getXMLFloat(xmlFile, key.."#motorTorque");
		if torque == nil then
			torque = getXMLFloat(xmlFile, key.."#ptoTorque");
			if torque ~= nil then
				torque = torque / self.mrGbMS.TransmissionEfficiency
			end
		end		
		--local fuelUsageRatio = getXMLFloat(xmlFile, key.."#fuelUsageRatio");
		if torque == nil or rpm == nil then --or fuelUsageRatio==nil then
			break;
		end;
		
		if self.mrGbMS.Engine.torqueValues == nil then
			--print("loading motor with new torque curve")
			self.mrGbMS.Engine.torqueValues = {}
			torqueF = Utils.getNoNil(getXMLFloat(xmlFile, xmlString..".realEngine#torqueFactor"), mrGearboxMogliGlobals.torqueFactor) / 1000
		end
		
		torque = torque * torqueF 
  
		self.mrGbMS.Engine.torqueValues[torqueI+1] = {v=torque, time = rpm}
		--self.mrGbMS.Engine.fuelUsageRatioCurve:addKeyframe({v=fuelUsageRatio, time = rpm});
		
		if torque>self.mrGbMS.Engine.maxTorque then
			self.mrGbMS.Engine.maxTorqueRpm = rpm;
			self.mrGbMS.Engine.maxTorque = torque;
		end;
		
		if self.mrGbMS.Engine.maxRpm < rpm then
			self.mrGbMS.Engine.maxRpm = rpm
		end
		if self.mrGbMS.Engine.minRpm > rpm and torque > 0 then
			self.mrGbMS.Engine.minRpm = rpm
		end
		torqueI = torqueI + 1;		
	end;

	if torqueI > 0 then
		self.mrGbMS.IdleRpm	  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString..".realEngine#idleRpm"), 800);
		self.mrGbMS.RatedRpm  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString..".realEngine#ratedRpm"), 2100);
	end
--**************************************************************************************************	
--**************************************************************************************************		
	
	self.mrGbMS.OpenRpm                 = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchOpenRpm"), 0 ) -- no automatic opening of clutch by default!!!
	self.mrGbMS.CloseRpm                = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchCloseRpm"), self.mrGbMS.IdleRpm+200 )
	self.mrGbMS.AutoStartStop           = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#autoStartStop"), true)
	self.mrGbMS.MaxSpeedLimiter         = getXMLBool( xmlFile, xmlString .. "#speedLimiter")
	self.mrGbMS.MaxForwardSpeed         = getXMLFloat(xmlFile, xmlString .. "#maxForwardSpeed")
	self.mrGbMS.MaxBackwardSpeed        = getXMLFloat(xmlFile, xmlString .. "#maxBackwardSpeed")
	
	if self.mrGbMS.MaxSpeedLimiter == nil then
		if     self.mrGbMS.MaxForwardSpeed  ~= nil
				or self.mrGbMS.MaxBackwardSpeed ~= nil then
			self.mrGbMS.MaxSpeedLimiter = true
		else
			self.mrGbMS.MaxSpeedLimiter = self.mrGbMS.AutoStartStop 
		end
	end

	local clutchEngagingTimeMs          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchEngagingTimeMs"), 2000 )  -- 1000 = 1s
	self.mrGbMS.ClutchTimeInc           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeIncreaseMs"), clutchEngagingTimeMs )
	self.mrGbMS.ClutchTimeDec           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeDecreaseMs"), 0.50 * clutchEngagingTimeMs ) 		
	self.mrGbMS.ClutchShiftTime         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchShiftingTimeMs"), 0.25 * self.mrGbMS.ClutchTimeDec) 
	
	local alwaysDoubleClutch            = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. "#doubleClutch"), false) 
	self.mrGbMS.GearsDoubleClutch       = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".gears#doubleClutch"), alwaysDoubleClutch) 
	self.mrGbMS.Range1DoubleClutch      = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(0)#doubleClutch"), alwaysDoubleClutch) 
	self.mrGbMS.Range2DoubleClutch      = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(1)#doubleClutch"), alwaysDoubleClutch) 
	self.mrGbMS.ReverseDoubleClutch     = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".reverse#doubleClutch"), alwaysDoubleClutch) 
	
	self.mrGbMS.GearTimeToShiftGear     = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".gears#shiftTimeMs"),      750 )
	self.mrGbMS.GearShiftEffectGear     = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".gears#shiftEffect"),     self.mrGbMS.GearTimeToShiftGear < mrGearboxMogliGlobals.shiftEffectTime + 1 )
	self.mrGbMS.GearTimeToShiftHl       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(0)#shiftTimeMs"),  900 ) 
	self.mrGbMS.GearShiftEffectHl       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(0)#shiftEffect"), self.mrGbMS.GearTimeToShiftHl < mrGearboxMogliGlobals.shiftEffectTime + 1 )
	self.mrGbMS.GearTimeToShiftRanges2  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(1)#shiftTimeMs"), 1200 ) 
	self.mrGbMS.GearShiftEffectRanges2  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(1)#shiftEffect"), self.mrGbMS.GearTimeToShiftRanges2 < mrGearboxMogliGlobals.shiftEffectTime + 1 )
	self.mrGbMS.GearTimeToShiftReverse  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".reverse#shiftTimeMs"),    750 ) 

	self.mrGbMS.GearTimeToShiftGear     = self.mrGbMS.GearTimeToShiftGear    * mrGearboxMogliGlobals.shiftTimeMsFactor
	self.mrGbMS.GearTimeToShiftHl       = self.mrGbMS.GearTimeToShiftHl      * mrGearboxMogliGlobals.shiftTimeMsFactor
	self.mrGbMS.GearTimeToShiftRanges2  = self.mrGbMS.GearTimeToShiftRanges2 * mrGearboxMogliGlobals.shiftTimeMsFactor
	
	self.mrGbMS.MinClutchPercent        = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#minClutchRatio"), 2 * mrGearboxMogli.minClutchPercent )
	if self.mrGbMS.MinClutchPercent < 2 * mrGearboxMogli.minClutchPercent then self.mrGbMS.MinClutchPercent  = 2 * mrGearboxMogli.minClutchPercent end
	self.mrGbMS.MaxClutchPercent        = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#maxClutchRatio"), 1 )
	if self.mrGbMS.MaxClutchPercent > 1 then self.mrGbMS.MaxClutchPercent = 1 end
	self.mrGbMS.ClutchAfterShiftGear    = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".gears#clutchRatio"), self.mrGbMS.MinClutchPercent) 
	self.mrGbMS.ManualClutchGear        = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".gears#manualClutch"), self.mrGbMS.ClutchAfterShiftGear + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	self.mrGbMS.ClutchAfterShiftHl      = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(0)#clutchRatio"), self.mrGbMS.MinClutchPercent) 
	self.mrGbMS.ManualClutchHl          = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(0)#manualClutch"), self.mrGbMS.ClutchAfterShiftHl + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	self.mrGbMS.ClutchAfterShiftRanges2 = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(1)#clutchRatio"), self.mrGbMS.MinClutchPercent) 
	self.mrGbMS.ManualClutchRanges2     = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(1)#manualClutch"), self.mrGbMS.ClutchAfterShiftRanges2 + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	self.mrGbMS.ClutchAfterShiftReverse = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".reverse#clutchRatio"), self.mrGbMS.MinClutchPercent) 
	self.mrGbMS.ManualClutchReverse     = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".reverse#manualClutch"), not self.mrGbMS.AutoStartStop and ( self.mrGbMS.ClutchAfterShiftReverse + 0.1 <= self.mrGbMS.MaxClutchPercent ) )
--self.mrGbMS.MinClutchTorque         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#minClutchTorque"), 0 )
--self.mrGbMS.ClutchTorqueClosed      = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#maxClutchTorque"), self.motor.maxClutchTorque )
--self.mrGbMS.ClutchTorqueConst       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTorqueConst"), self.motor.maxMotorTorque )
--self.mrGbMS.ClutchTorqueDiff        = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTorqueDiff"), self.motor.maxClutchTorque - self.motor.maxMotorTorque )
--self.mrGbMS.ClutchExponent          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchExponent"), 0.7 )

	self.mrGbMS.RealMotorBrakeFx        = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#motorBrakeFx"), self.motor.lowBrakeForceScale ) --0.1 )
	self.mrGbMS.GlobalRatioFactor       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#globalRatioFactor"), 1.025 )

	local revUpMs                       = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revUpMs"), 1000 ) 
	local revDownMs                     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revDownMs"),750 ) 
	self.mrGbMS.RpmIncFactor            = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / revUpMs
	self.mrGbMS.RpmDecFactor            = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / revDownMs
	if mrGearboxMogli.rpmIncPerGearSpeed then
	-- change of RPMs at 50 km/h      
		self.mrGbMS.RpmIncFactor          = self.mrGbMS.RpmIncFactor / 6.15	
	end
	
	self.mrGbMS.IdlePitchFactor         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idlePitchFactor"), -1 )
	self.mrGbMS.IdlePitchMax            = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idlePitchMax"), -1 )
	self.mrGbMS.IdleVolumeFactor        = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idleVolumeFactor"), 0.8 )
	self.mrGbMS.IdleVolumeFactorInc     = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idleVolumeFactorInc"), 1.2 )
	self.mrGbMS.RunPitchFactor          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runPitchFactor"), -1 )
	self.mrGbMS.RunPitchMax             = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runPitchMax"), -1 )
	self.mrGbMS.RunVolumeFactor         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runVolumeFactor"), 0.8 )	
	self.mrGbMS.RunVolumeFactorInc      = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runVolumeFactorInc"), 1.2 )	
	self.mrGbMS.Run2PitchEffect         = getXMLFloat(xmlFile, xmlString .. "#run2PitchEffect" )
		
	if xmlSource == "vehicle" then
		self.mrGbMS.BlowOffVentilFile     = getXMLString( xmlFile, xmlString.. ".blowOffVentilSound#file" )
		self.mrGbMS.BlowOffVentilVolume   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".blowOffVentilSound#volume" ), 1 )
		self.mrGbMS.GrindingSoundFile     = getXMLString( xmlFile, xmlString.. ".grindingGearsSound#file" )
		self.mrGbMS.GrindingSoundVolume   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".grindingGearsSound#volume" ), 1 )
	else
		self.mrGbMS.BlowOffVentilFile     = nil
		self.mrGbMS.BlowOffVentilVolume   = 0
		self.mrGbMS.GrindingSoundFile     = nil
		self.mrGbMS.GrindingSoundVolume   = 0
	end	

	if self.mrGbMS.BlowOffVentilFile == nil then
	-- no autoStartStop => old vehicle => louder blow off ventil sound
		if serverAndClient then
			self.mrGbMS.BlowOffVentilVolume = 0
		else
			if self.mrGbMS.AutoStartStop then
				default = 1.4
			else
				default = 2
			end
			self.mrGbMS.BlowOffVentilVolume = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".blowOffVentilSound#volume" ), default ) * mrGearboxMogliGlobals.blowOffVentilVol
		end
	else
		self.mrGbMS.BlowOffVentilFile = Utils.getFilename( self.mrGbMS.BlowOffVentilFile, self.baseDirectory )
	end
		
	if self.mrGbMS.GrindingSoundFile == nil then
		if serverAndClient then
			self.mrGbMS.GrindingSoundVolume = 0
		else
			self.mrGbMS.GrindingSoundVolume = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".grindingGearsSound#volume" ), 1.5 )
		end
	else
		self.mrGbMS.GrindingSoundFile = Utils.getFilename( self.mrGbMS.GrindingSoundFile, self.baseDirectory )
	end
		
	local reverseMinGear  = getXMLInt(xmlFile, xmlString .. ".reverse#minGear")
	local reverseMaxGear  = getXMLInt(xmlFile, xmlString .. ".reverse#maxGear")
	local reverseMinRange = getXMLInt(xmlFile, xmlString .. ".reverse#minRange")
	local reverseMaxRange = getXMLInt(xmlFile, xmlString .. ".reverse#maxRange")
	local rangeGearOffset = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".ranges#gearOffset"), 0) 
	local gearRangeOffset = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".gears#rangeOffset"), 0) 
	local minRatio        = 0.6
	local prevSpeed
	
	self.mrGbMS.Gears = {} 
	local i = 0 
	while true do
		local baseName = xmlString .. string.format(".gears.gear(%d)", i) 		
		local speed    = getXMLFloat(xmlFile, baseName .. "#speed") 
		if speed==nil then
			break 
		end 
		i = i + 1 
		local name  = Utils.getNoNil(getXMLString(xmlFile, baseName .. "#name"), tostring(i)) 

		local fwdOnly = getXMLBool(xmlFile, baseName .. "#forwardOnly" )
		if fwdOnly == nil then
			fwdOnly = not ( ( reverseMinGear == nil or i >= reverseMinGear )
									and ( reverseMaxGear == nil or i <= reverseMaxGear ) )
		end		
		local revOnly = Utils.getNoNil( getXMLBool( xmlFile, baseName .. "#reverseOnly" ), false )
		
		
		local newEntry = mrGearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {speed=speed/3.6,name=name} )
		
		newEntry.upRangeOffset   = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#upRangeOffset" ),  -gearRangeOffset ) 
		newEntry.downRangeOffset = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#downRangeOffset" ), gearRangeOffset ) 
		
		table.insert(self.mrGbMS.Gears, newEntry)  -- m/s
		
		if not ( newEntry.reverseOnly ) then
			if prevSpeed ~= nil then
				local m = prevSpeed / speed 
				if minRatio > m then
					minRatio = m
				end
			end
			prevSpeed = speed 
		end
	end 	
	
	if i==0 then
		local newEntry = {speed=self.motor.maxForwardSpeed/self.mrGbMS.GlobalRatioFactor,name="1"} 
		table.insert(self.mrGbMS.Gears, newEntry)  -- m/s
	end 	
			
	self.mrGbMS.Ranges = {} 
	i = 0 
	local generateNames = true 
	while true do
		local baseName = xmlString .. string.format(".ranges(0).range(%d)", i) 		
		local ratio = getXMLFloat(xmlFile, baseName .. "#ratio") 
		if ratio==nil then
			break 
		end 
		i = i + 1 
		
		local name = getXMLString(xmlFile, baseName .. "#name") 
		if name == nil then
			name = tostring(i) 
		else
			generateNames = false 
		end
		
		local newEntry = mrGearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {ratio=ratio,name=name} )
		
		newEntry.upGearOffset   = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#upGearOffset" ),  -rangeGearOffset ) 
		newEntry.downGearOffset = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#downGearOffset" ), rangeGearOffset ) 

		if      fwdOnly == nil
				and not ( ( reverseMinRange == nil or i >= reverseMinRange )
							and ( reverseMaxRange == nil or i <= reverseMaxRange ) ) then
			newEntry.forwardOnly = true
		end		
		
		table.insert(self.mrGbMS.Ranges, newEntry)  -- m/s
	end 
	
	if i==0 then
		local newEntry = {ratio=1,name=""} 
		table.insert(self.mrGbMS.Ranges, newEntry)  -- m/s
		generateNames = false
	end
	
	if generateNames then
		local fwd,rev=0,0
		for _,newRange in pairs( self.mrGbMS.Ranges ) do
			if     newRange.forwardOnly then
				fwd = fwd + 1
			elseif newRange.reverseOnly then
				rev = rev + 1
			else
				fwd = fwd + 1
				rev = rev + 1
			end
		end
		
		local fwd2,rev2=0,0

		for _,newRange in pairs( self.mrGbMS.Ranges ) do
			local isFwd,isRev=true,true
			if     newRange.forwardOnly then
				fwd2 = fwd2 + 1
				isRev = false
			elseif newRange.reverseOnly then
				rev2 = rev2 + 1
				isFwd = false
			else
				fwd2 = fwd2 + 1
				rev2 = rev2 + 1
			end
			if     isFwd then
				if     fwd == 1 then
					newRange.name = ""
				elseif fwd == 2 then
					if fwd2 == 1 then
						newRange.name = "L"
					else
						newRange.name = "H"
					end
				elseif fwd == 3 then
					if     fwd2 == 1 then
						newRange.name = "L"
					elseif fwd2 == 2 then
						newRange.name = "M"
					else
						newRange.name = "H"
					end
				elseif fwd == 4 then
					if     fwd2 == 1 then
						newRange.name = "S"
					elseif fwd2 == 2 then
						newRange.name = "L"
					elseif fwd2 == 3 then
						newRange.name = "M"
					else
						newRange.name = "H"
					end
				else
					newRange.name = "G"..tostring(fwd2)
				end
			elseif isRev then
				if rev==1 then
					newRange.name = "R"
				else
					newRange.name = "R"..tostring(rev2)
				end			
			end
		end		
	end
	
	self.mrGbMS.Ranges2 = {} 
	i = 0 
	while true do
		local baseName = xmlString .. string.format(".ranges(1).range(%d)", i) 		
		local ratio = getXMLFloat(xmlFile, baseName .. "#ratio") 
		if ratio==nil then
			break 
		end 
		i = i + 1 
		
		local name = getXMLString(xmlFile, baseName .. "#name") 
		if name == nil then
			name = "G"..tostring(i) 
		end
		local newEntry = mrGearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {ratio=ratio,name=name} )
		
		table.insert(self.mrGbMS.Ranges2, newEntry)  -- m/s
	end 
	
	if i==0 then
		local newEntry = {ratio=1,name=""} 
		table.insert(self.mrGbMS.Ranges2, newEntry)  -- m/s
	end
		
	self.mrGbMS.ReverseRatio            = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".reverse#ratio"), 1) 
	
	self.mrGbMS.ReverseResetGear        = false 
	if getXMLBool(xmlFile, xmlString .. ".reverse#resetGear") or getXMLBool(xmlFile, xmlString .. ".gears#reverseReset") then
		self.mrGbMS.ReverseResetGear      = true 
	end
	self.mrGbMS.ReverseResetRange       = false 
	if getXMLBool(xmlFile, xmlString .. ".reverse#resetRange") or getXMLBool(xmlFile, xmlString .. ".ranges(0)#reverseReset") then
		self.mrGbMS.ReverseResetRange     = true
	end
	self.mrGbMS.ReverseResetRange2      = false
	if getXMLBool(xmlFile, xmlString .. ".ranges(1)#reverseReset") then
		self.mrGbMS.ReverseResetRange2    = true
	end
	
	self.mrGbMS.DefaultGear        = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".gears#defaultGear"), 1) 
	self.mrGbMS.DefaultRange       = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".ranges(0)#defaultRange"), table.getn(self.mrGbMS.Ranges)) 
	self.mrGbMS.DefaultRange2      = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".ranges(1)#defaultRange"), table.getn(self.mrGbMS.Ranges2)) 
	self.mrGbMS.LaunchGear         = self.mrGbMS.DefaultGear
	self.mrGbMS.LaunchRange        = self.mrGbMS.DefaultRange
	self.mrGbMS.LaunchRange2       = self.mrGbMS.DefaultRange2
	
	self.mrGbMS.AutoShiftUpRpm     = getXMLFloat(xmlFile, xmlString .. ".gears#autoUpRpm") 
	self.mrGbMS.AutoShiftDownRpm   = getXMLFloat(xmlFile, xmlString .. ".gears#autoDownRpm") 
	self.mrGbMS.AutoShiftGears     = false
	self.mrGbMS.AutoShiftHl        = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(0)#automatic"), false )
	self.mrGbMS.AutoShiftGears     = getXMLBool(xmlFile, xmlString .. ".gears#automatic")
	if self.mrGbMS.AutoShiftUpRpm ~= nil and self.mrGbMS.AutoShiftGears == nil then
		self.mrGbMS.AutoShiftGears = true
	elseif self.mrGbMS.AutoShiftGears then
		self.mrGbMS.AutoShiftGears = true
		self.mrGbMS.AutoShiftUpRpm = self.mrGbMS.RatedRpm
	end
	if      self.mrGbMS.AutoShiftGears
			and self.mrGbMS.AutoShiftDownRpm == nil then
		self.mrGbMS.AutoShiftDownRpm = self.mrGbMS.RatedRpm * minRatio			
	end
	
	i = 0 
	while true do
		local baseName = xmlString .. string.format(".hydrostatic.efficiency(%d)", i) 		
		local ratio    = getXMLFloat(xmlFile, baseName .. "#ratio") 
		local factor   = getXMLFloat(xmlFile, baseName .. "#factor") 
		if ratio==nil or factor == nil then
			break 
		end 
		i = i + 1 
		
		self.mrGbMS.HydrostaticMax = ratio
		if self.mrGbMS.HydrostaticEfficiency == nil then
			self.mrGbMS.HydrostaticMin         = ratio
			self.mrGbMS.TransmissionEfficiency = factor		
			self.mrGbMS.HydrostaticEfficiency  = {}
		elseif self.mrGbMS.TransmissionEfficiency < factor then
			self.mrGbMS.TransmissionEfficiency = factor
		end
		
		table.insert(self.mrGbMS.HydrostaticEfficiency, {time=ratio,v=factor})  -- m/s
	end 
	if i > 0 then   
		self.mrGbMS.Hydrostatic         = true
		self.mrGbMS.HydrostaticMaxRpm   = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxWheelRpm") 
		self.mrGbMS.HydrostaticIncTime  = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#minMaxTimeMs"), 1000 )
		self.mrGbMS.HydrostaticStart    = Utils.getNoNil( getXMLBool(xmlFile, xmlString .. ".hydrostatic#startFactor"), Utils.clamp( 0.7, self.mrGbMS.HydrostaticMin, 1 )  )
		local sc = getXMLBool(xmlFile, xmlString .. ".hydrostatic#startWithClutch")
		if sc == nil then
			self.mrGbMS.HydrostaticLaunch = self.mrGbMS.HydrostaticMin * self.mrGbMS.Gears[1].speed < 2 -- m/s
		else
			self.mrGbMS.HydrostaticLaunch = not ( sc )
		end
	else
		self.mrGbMS.Hydrostatic         = false
	end
	
	local timeToAutoShift = 0
	if self.mrGbMS.AutoShiftGears then
		timeToAutoShift = math.max( timeToAutoShift, self.mrGbMS.GearTimeToShiftGear )
	end
	if self.mrGbMS.AutoShiftHl then
		timeToAutoShift = math.max( timeToAutoShift, self.mrGbMS.GearTimeToShiftHl )
	end
	
	self.mrGbMS.AutoShiftTimeoutLong    = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".gears#autoShiftTimeout"), 2500 +  3  * timeToAutoShift ) 
	self.mrGbMS.AutoShiftTimeoutShort   = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".gears#autoShiftTimeout2"),math.min( 2000 + 1.5 * timeToAutoShift, 0.875*revUpMs ) ) 
	self.mrGbMS.AutoShiftMinClutch      = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".gears#autoShiftMinClutch"), self.mrGbMS.MaxClutchPercent - 0.1 ) 

	if self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl then
		local default = mrGearboxMogliGlobals.disableManual or self.mrGbMS.Hydrostatic
		self.mrGbMS.DisableManual = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#disableManual" ), default)
	end
	
	local enableAI = getXMLBool( xmlFile, xmlString .. "#enableAI" )
	if enableAI == nil then
		if     self.mrGbMS.Hydrostatic then
			self.mrGbMS.EnableAI = "Y"
		elseif  ( self.mrGbMS.AutoShiftGears or table.getn( self.mrGbMS.Gears  ) < 2 )
				and ( self.mrGbMS.AutoShiftGears or table.getn( self.mrGbMS.Ranges ) < 2 ) then
			self.mrGbMS.EnableAI = "A"
		else
			self.mrGbMS.EnableAI = "N"
		end
	elseif enableAI then
		self.mrGbMS.EnableAI = "Y"
	else
		self.mrGbMS.EnableAI = "N"
	end
	
	if self.mrGbMS.Run2PitchEffect == nil then
		if self.mrGbMS.Hydrostatic then
			self.mrGbMS.Run2PitchEffect = 0
		elseif self.mrGbMS.AutoShiftGears then
			self.mrGbMS.Run2PitchEffect = 0.1
		else
			self.mrGbMS.Run2PitchEffect = 0
		end
	end
	
	if math.abs( self.mrGbMS.Run2PitchEffect ) < mrGearboxMogli.eps then
		mrGearboxMogliGlobals.modifyTransVol = false
	end
	
--**********************************************************************************************************		
-- server fields...	
	if not ( serverAndClient ) then
		for n,_ in pairs(self.mrGbMS) do
			if not ( excludeList[n] ) then
				mrGearboxMogli.registerServerField( self, n )
			end
		end	
	end	
--**************************************************************************************************	
	
-- set the default values for SERVER		
	self.mrGbMS.Automatic     = self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl
	self.mrGbMS.IsOnOff       = self.mrGbMS.DefaultOn
	self.mrGbMS.NeutralActive = self.mrGbMS.AutoStartStop	
	self.mrGbMS.CurrentGear   = self.mrGbMS.DefaultGear
	self.mrGbMS.CurrentRange  = self.mrGbMS.DefaultRange
	self.mrGbMS.CurrentRange2 = self.mrGbMS.DefaultRange2
	self.mrGbMS.ManualClutch  = self.mrGbMS.MaxClutchPercent
-- set the default values for SERVER		
--**********************************************************************************************************		
end
		
--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMDoGearShift
--**********************************************************************************************************	
function mrGearboxMogli:checkIfReady( noEventSend )
	if self.mrGbMS == nil then
		print("ERROR: GearboxAddon not initialized")
	elseif not ( self.mrGbMS.IsOn ) then
	elseif self.mrGbML                                          == nil 
			or self.mrGbMB                                          == nil
			or self.mrGbMS.Gears                                    == nil
			or self.mrGbMS.CurrentGear                              == nil
			or self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed     == nil
			or self.mrGbMS.Ranges                                   == nil
			or self.mrGbMS.CurrentRange                             == nil
			or self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio   == nil
			or self.mrGbMS.Ranges2                                  == nil
			or self.mrGbMS.CurrentRange2                            == nil
			or self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio == nil
			or self.mrGbMS.ReverseRatio                             == nil
			or self.mrGbMS.GlobalRatioFactor                        == nil then
		print("ERROR: client initialization failed")
		self:mrGbMSetState( "IsOn", false, noEventSend )
		return 
	end
end
		
--**********************************************************************************************************	
-- mrGearboxMogli:update
--**********************************************************************************************************	
function mrGearboxMogli:update(dt)

	if mrGearboxMogliGlobals.modifySound and self:getIsActiveForSound() and ( self.mrGbMB.soundPitchScale == nil or self.mrGbMB.soundRunPitchScale == nil ) then
		self.mrGbMB.soundPitchScale     = self.motorSoundPitchScale
		self.mrGbMB.soundPitchMax       = self.motorSoundPitchMax
		self.mrGbMB.soundRunPitchScale  = self.motorSoundRunPitchScale	
		self.mrGbMB.soundRunPitchMax    = self.motorSoundRunPitchMax
		self.mrGbMB.soundRun2PitchMax   = self.motorRun2PitchMax
		self.mrGbMB.soundVolume         = self.sampleMotor.volume   
		self.mrGbMB.soundRunVolume      = self.sampleMotorRun.volume
		self.mrGbMB.soundPitchOffset    = self.sampleMotor.pitchOffset   
		self.mrGbMB.soundRunPitchOffset = self.sampleMotorRun.pitchOffset
		self.mrGbMB.soundRun2PitchOffset= self.sampleMotorRun2.pitchOffset
	end

	local processInput = true
	if self:getIsActiveForInput(false) and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliON_OFF" ) then
		self:mrGbMSetIsOnOff( not self.mrGbMS.IsOnOff ) 
		processInput = false
	end

	if self.isMotorStarted and self.motor.minRpm > 0 then
		if      self.mrGbMS.IsOnOff 
				and self.mrGbML.motor == nil then 
	-- initialize as late as possible 			
			if not ( self.mbClientInitDone20 ) then return end
			if self.motor == nil then return end
		
			if self.mrGbML.motor == nil then
				self.mrGbML.motor = mrGearboxMogliMotor:new( self, self.motor )			
				self.mrGbMB.motor = self.motor	
			end
		elseif self.mrGbML.motor == nil then 
	-- not initialized => exit	
			return
		end
		
		if self.mrGbMB.motor == nil then 
	-- no backup of original motor => error in mrGearboxMogliMotor:new
			self.mrGbML.motor = nil
			self:mrGbMSetState( "IsOn", false ) 	
			return
		end
--elseif self.mrGbMB.motor ~= nil then 
--	self.motor = self.mrGbMB.motor
	end
	
	if not self.mrGbMS.IsOn then
		return 
	end 

	if self.isServer and not ( self.mrGbML.firstTimeRun ) then
		self.mrGbML.firstTimeRun = true
		self:mrGbMSetState( "CurrentGear",   mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears,   self.mrGbMS.CurrentGear,   self.mrGbMS.DefaultGear,   "gear" ) )
		self:mrGbMSetState( "CurrentRange",  mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges,  self.mrGbMS.CurrentRange,  self.mrGbMS.DefaultRange,  "range" ) )
		self:mrGbMSetState( "CurrentRange2", mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, self.mrGbMS.DefaultRange2, "range2" ) )
	end			
	
	if mrGearboxMogli.consoleCommand and not ( mrGearboxMogli.consoleCommand1 ) then
		mrGearboxMogli.consoleCommand1 = true
		self.mrGbMTestNet = mrGearboxMogli.mrGbMTestNet
		self.mrGbMTestAPI = mrGearboxMogli.mrGbMTestAPI
		self.mrGbMDebug   = mrGearboxMogli.mrGbMDebug
		addConsoleCommand("mrGbMTestNet", "Test networking of mrGearboxMogli", "mrGbMTestNet", self)
		addConsoleCommand("mrGbMTestAPI", "Test API of mrGearboxMogli", "mrGbMTestAPI", self)
		addConsoleCommand("mrGbMDebug", "Console output during gear shift", "mrGbMDebug", self)
	end

-- driveControl 
	local driveControlShuttle   = false
	local driveControlHandBrake = false
	if      self.dCcheckModule ~=  nil 
			and self.driveControl  ~= nil then
			
		if      self:dCcheckModule("shuttle")
				and self.driveControl.shuttle ~= nil 
				and self.driveControl.shuttle.isActive then
			--driveControlShuttle = true
			--if self.driveControl.shuttle.direction < 0 then
			--	self:mrGbMSetReverseActive( true )
			--else
			--	self:mrGbMSetReverseActive( false )
			--end
			self.mrGbMB.dcShuttle = true
			self.driveControl.shuttle.isActive = false
		end
		
		if      self:dCcheckModule("handBrake")
				and self.driveControl.handBrake ~= nil then
			if self.driveControl.handBrake.isActive then
				driveControlHandBrake = true
				self:mrGbMSetNeutralActive( true, false, true ) 
			elseif self.mrGbML.lastDCHandBrake then
				if not ( self.mrGbMS.AutoStartStop ) and self.mrGbMS.AutoClutch then
					self:mrGbMSetNeutralActive( false )
				end
			end
			self.mrGbML.lastDCHandBrake = self.driveControl.handBrake.isActive
		end
	end
	
-- text	
	if self.isServer then
		local text = ""
	--if self.isAITractorActivated or self.isAIThreshing then
		if not ( self.steeringEnabled ) then
			text = "AI"
		elseif not ( self.isMotorStarted ) then
			text = "off"
		elseif driveControlHandBrake then
			text = "handbrake"
		elseif self.mrGbML.gearShiftingNeeded < 0 then
			text = "double clutch "..tostring(-self.mrGbML.gearShiftingNeeded)
		elseif self.mrGbMS.NeutralActive then
			text = "neutral" 	
		elseif self.mrGbMS.Automatic then
			text = "auto"
		elseif self.mrGbMS.G27Mode == 1 then
			text = "no gear"
		else
			text = "manual" 	
		end
		
		if self.mrGbMS.ReverseActive and not ( driveControlShuttle ) then
			text = text .. " (R)" 	
		end
		if self.mrGbMS.SpeedLimiter then
			text = text .. " (L)"
		end
		if self.mrGbMS.G27Mode > 0 then
			text = text .. " G27"
		end
		
		self:mrGbMSetState( "DrawText", text )
	end
	
-- inputs	
	if self:getIsActiveForInput(false) then		
		if      self.mrGbMS.WarningText ~= nil
				and self.mrGbMS.WarningText ~= "" then
			if g_currentMission.time < self.mrGbML.warningTimer then
				g_currentMission:addWarning(self.mrGbMS.WarningText, 0.018, 0.033)
			else
				self.mrGbMS.WarningText = ""
			end
		end
		-- auto start/stop
		if      self.mrGbMS.AutoStartStop
				and self.mrGbMS.NeutralActive
				and not ( driveControlHandBrake )
				and ( self.axisForward < -0.1 or self.cruiseControl.state ~= 0 ) then
			self:mrGbMSetNeutralActive( false ) 
		end

		if mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliAUTOCLUTCH" ) then
			self:mrGbMSetAutoClutch( not self.mrGbMS.AutoClutch ) 
		end

		if InputBinding.mrGearboxMogliCLUTCH ~= nil then
			local targetClutchPercent = InputBinding.getDigitalInputAxis(InputBinding.mrGearboxMogliCLUTCH)
			local clutchSpeed         = 1 / math.max( self.mrGbMS.ClutchShiftTime, 1 )
			if self.mrGbMS.ManualClutch then
				clutchSpeed = math.max( 0.002, clutchSpeed )
			end
			if InputBinding.isAxisZero(targetClutchPercent) then
				targetClutchPercent = InputBinding.getAnalogInputAxis(InputBinding.mrGearboxMogliCLUTCH)
				if not InputBinding.isAxisZero(targetClutchPercent) then
					targetClutchPercent = Utils.clamp( 0.55 * ( targetClutchPercent + 1 ), 0, 1 ) * self.mrGbMS.MaxClutchPercent
					if math.abs( targetClutchPercent - self.mrGbMS.ManualClutch ) > 0.01 then
						self:mrGbMSetManualClutch( targetClutchPercent ) 
					end
				end
			elseif targetClutchPercent < 0 then
				self:mrGbMSetManualClutch( math.max( 0, self.mrGbMS.ManualClutch - dt * clutchSpeed ))
			elseif targetClutchPercent > 0 then
				self:mrGbMSetManualClutch( math.min( self.mrGbMS.MaxClutchPercent, self.mrGbMS.ManualClutch + dt * clutchSpeed ))
			end
		end
		
		if InputBinding.mrGearboxMogliMINRPM ~= nil then
			local handThrottle = InputBinding.getDigitalInputAxis(InputBinding.mrGearboxMogliMINRPM)
			if InputBinding.isAxisZero(handThrottle) then
				handThrottle = InputBinding.getAnalogInputAxis(InputBinding.mrGearboxMogliMINRPM)
				if not InputBinding.isAxisZero(handThrottle) then
					self:mrGbMSetHandThrottle( handThrottle )
				end
			elseif handThrottle < 0 then
				self:mrGbMSetHandThrottle( self.mrGbMS.HandThrottle - 0.001 * dt )
			elseif handThrottle > 0 then
				self:mrGbMSetHandThrottle( self.mrGbMS.HandThrottle + 0.001 * dt ) 
			end
		end
			
		-- avoid conflicts with driveControl
		--if     mrGearboxMogli.mbHasInputEvent( "driveControlHandbrake" ) then
		if     not processInput
				or mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_1" )
				or mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_2" )
				or mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_3" )
				or mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliCONFLICT_4" ) then
			-- ignore
		elseif mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliNEUTRAL" ) then
			if self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl then
				if     self.mrGbMS.DisableManual then
					self:mrGbMSetNeutralActive( not self.mrGbMS.NeutralActive ) 
					self:mrGbMSetAutomatic( true ) 
				elseif self.mrGbMS.AutoStartStop then
					self:mrGbMSetAutomatic( not self.mrGbMS.Automatic ) 
				elseif self.mrGbMS.NeutralActive then
					self:mrGbMSetNeutralActive( false ) 
					self:mrGbMSetAutomatic( true ) 
				elseif self.mrGbMS.Automatic then
					self:mrGbMSetAutomatic( false )
				else 
					self:mrGbMSetNeutralActive( true ) 
				end	
			else	
				if not self.mrGbMS.NeutralActive then
					self:setCruiseControlState(0)
				end
				self:mrGbMSetNeutralActive( not self.mrGbMS.NeutralActive ) 
			end
		elseif not ( driveControlShuttle ) and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliREVERSE" ) then			
		--self:setCruiseControlState(0)
			self:mrGbMSetReverseActive( not self.mrGbMS.ReverseActive ) 
		elseif mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSPEEDLIMIT" ) then -- speed limiter
			self:mrGbMSetSpeedLimiter( not self.mrGbMS.SpeedLimiter ) 
		elseif mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliACCTOLIMIT" ) then -- speed limiter acc.
			self:mrGbMSetAccelerateToLimit( self.mrGbMS.AccelerateToLimit + 1 )
			self:mrGbMSetDecelerateToLimit( self.mrGbMS.AccelerateToLimit * 2 )
			self:mrGbMSetState( "InfoText", string.format( "Speed Limiter: +%2.0f km/h/s / -%2.0f km/h/s", self.mrGbMS.AccelerateToLimit, self.mrGbMS.DecelerateToLimit ))
		elseif mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliDECTOLIMIT" ) then -- speed limiter dec.
			self:mrGbMSetAccelerateToLimit( self.mrGbMS.AccelerateToLimit - 1 )
			self:mrGbMSetDecelerateToLimit( self.mrGbMS.AccelerateToLimit * 2 )
			self:mrGbMSetState( "InfoText", string.format( "Speed Limiter: +%2.0f km/h/s / -%2.0f km/h/s", self.mrGbMS.AccelerateToLimit, self.mrGbMS.DecelerateToLimit ))
		elseif table.getn( self.mrGbMS.Ranges2 ) > 1 and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSHIFTRANGE2UP" ) then -- high/low range shift
			self:mrGbMSetCurrentRange2(self.mrGbMS.CurrentRange2+1)                                        
		elseif table.getn( self.mrGbMS.Ranges2 ) > 1 and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSHIFTRANGE2DOWN" ) then -- high/low range shift
			self:mrGbMSetCurrentRange2(self.mrGbMS.CurrentRange2-1) 
		elseif table.getn( self.mrGbMS.Ranges ) > 1 and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSHIFTRANGEUP" ) then -- high/low range shift
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear+1) 
			else
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange+1)                                        
			end 
		elseif table.getn( self.mrGbMS.Ranges ) > 1 and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSHIFTRANGEDOWN" ) then -- high/low range shift
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear-1) 	
			else
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange-1) 
			end 
		elseif not ( self.mrGbMS.DisableManual ) and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSHIFTGEARUP" ) then
			self:mrGbMSetState( "G27Mode", 0 ) 
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange+1)                                        
			else
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear+1) 
			end 
		elseif not ( self.mrGbMS.DisableManual ) and mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliSHIFTGEARDOWN" ) then
			self:mrGbMSetState( "G27Mode", 0 ) 
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange-1) 
			else
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear-1) 	
			end 
		elseif mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliGEARFWD" )  then 
		--self:setCruiseControlState(0) 
			self:mrGbMSetReverseActive( false ) 
		elseif mrGearboxMogli.mbHasInputEvent( "mrGearboxMogliGEARBACK" ) then 
		--self:setCruiseControlState(0) 
			self:mrGbMSetReverseActive( true ) 
		end
		
		if not ( self.mrGbMS.DisableManual ) then
			local gear = 0
			if     mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEAR1" ) then gear=1
			elseif mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEAR2" ) then gear=2
			elseif mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEAR3" ) then gear=3
			elseif mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEAR4" ) then gear=4
			elseif mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEAR5" ) then gear=5
			elseif mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEAR6" ) then gear=6
			elseif mrGearboxMogli.mbIsInputPressed( "mrGearboxMogliGEARR" ) then gear=-1
			end
			
			if not self.mrGbMS.Automatic and ( self.mrGbMS.G27Mode > 0 or gear ~= 0 ) then
				local manClutch = false
				local curGear   = self.mrGbMS.CurrentGear
				if not ( self.mrGbMS.AutoClutch ) and not ( self.mrGbMS.Automatic ) then
					manClutch = self.mrGbMS.ManualClutchGear
					if self.mrGbMS.SwapGearRangeKeys then
						manClutch = self.mrGbMS.ManualClutchHl
						curGear   = self.mrGbMS.CurrentRange
					end
				end
				if self.mrGbMS.G27Mode == 1 then
					curGear = 0
				end
				
				if curGear ~= gear then
					if self.mrGbMS.NeutralActive or not manClutch or self.mrGbMS.ManualClutch <= self.mrGbMS.MinClutchPercent + 0.1 then
						if gear == 0 then
							self:mrGbMSetState( "G27Mode", 1 ) 
						else
							self:mrGbMSetState( "G27Mode", 2 ) 
							self:mrGbMSetReverseActive( (gear < 0) )
							if self.mrGbMS.SwapGearRangeKeys then
								self:mrGbMSetCurrentRange(math.abs(gear))
							else
								self:mrGbMSetCurrentGear(math.abs(gear))
							end
						end
					elseif manClutch then
						self:mrGbMSetState( "InfoText", string.format( "Cannot shift gear; clutch > %3.0f%%", 100*Utils.clamp( self.mrGbMS.MinClutchPercent + 0.1, 0, 1 ) ))
						self.mrGbMS.GrindingGearsPlay = false
						self:mrGbMSetState( "GrindingGearsPlay", true )
					end
				elseif self.mrGbMS.G27Mode < 1 then
					self:mrGbMSetState( "G27Mode", 2 ) 
				end
			elseif self.mrGbMS.G27Mode > 0 then
				self:mrGbMSetState( "G27Mode", 0 ) 
			end
		end
	end

	if self.isMotorStarted and self.mrGbML.motor ~= nil then
		-- switch the motor 
		self.motor = self.mrGbML.motor
		
		if self.mrGbMS.BlowOffVentilVolume > 0 then			
			if self:getIsActiveForSound() and self.mrGbMS.BlowOffVentilPlay then
				self.mrGbMS.BlowOffVentilPlay = false
				
				if self.mrGbMS.BlowOffVentilFile == nil then
					if mrGearboxMogli.BOVSample == nil then
						mrGearboxMogli.BOVSample = createSample("mrGearboxMogliBOVSample")
						local fileName = Utils.getFilename( "blowOffVentil.wav", mrGearboxMogli.baseDirectory )
						loadSample(mrGearboxMogli.BOVSample, fileName, false)
					end
					playSample(mrGearboxMogli.BOVSample, 1, self.mrGbMS.BlowOffVentilVolume, 0)	
				else
					if self.mrGbML.blowOffVentilSample == nil then
						self.mrGbML.blowOffVentilSample = createSample("mrGearboxMogliBOVSample")
						loadSample( self.mrGbML.blowOffVentilSample, self.mrGbMS.BlowOffVentilFile, false )
					end
					playSample( self.mrGbML.blowOffVentilSample, 1, self.mrGbMS.BlowOffVentilVolume, 0 )	
				end
			end
		end
		
		if self.mrGbMS.GrindingSoundVolume > 0 then
			if self:getIsActiveForSound() and self.mrGbMS.GrindingGearsPlay then
				self.mrGbMS.GrindingGearsPlay = false

				if self.mrGbMS.GrindingSoundFile == nil then
					if mrGearboxMogli.GrindingSample == nil then
						mrGearboxMogli.GrindingSample = createSample("mrGearboxMogliGrindingSample")
						local fileName = Utils.getFilename( "grinding.wav", mrGearboxMogli.baseDirectory )
						loadSample(mrGearboxMogli.GrindingSample, fileName, false)
					end
					playSample(mrGearboxMogli.GrindingSample, 1, self.mrGbMS.GrindingSoundVolume, 0)	
				else
					if self.mrGbML.grindingSample == nil then
						self.mrGbML.grindingSample = createSample("mrGearboxMogliGrindingSample")
						loadSample(self.mrGbML.grindingSample, self.mrGbMS.GrindingSoundFile, false)
					end
					playSample(self.mrGbML.grindingSample, 1, self.mrGbMS.GrindingSoundVolume, 0)	
				end
			end
		end
				
		-- sound tuning => Motorized.lua 
		if self.mrGbMS.ResetSoundRPM >= 0 then
			if self.mrGbML.resetSoundTimer < 0 then
				self.mrGbML.resetSoundTimer = g_currentMission.time + mrGearboxMogli.resetSoundTime
			end
			self.lastRoundPerMinute   = self.mrGbMS.ResetSoundRPM
			if g_currentMission.time > self.mrGbML.resetSoundTimer then
				self.mrGbML.resetSoundTimer = -1
				self.mrGbMS.ResetSoundRPM   = -1 
			end
		end
		
		if self:getIsActiveForSound() and ( self.mrGbMB.soundPitchScale ~= nil or self.mrGbMB.soundRunPitchScale ~= nil ) then			
			local newRpmRange = self.motor.maxRpm - self.motor.minRpm
			local oldRpmRange = ( self.mrGbMB.motor.maxRpm - self.mrGbMB.motor.minRpm )
			local rpmFactor   = self.motor.maxRpm / self.mrGbMS.RatedRpm		
			local newRpsRange = newRpmRange / 60
			local oldRpsRange = oldRpmRange / 60
			
			if mrGearboxMogliGlobals.modifySound then		
				if self.mrGbMS.IdlePitchFactor < 0 and self.mrGbMS.IdlePitchMax < 0 then 
					self.motorSoundPitchMax     = math.min( self.mrGbMB.soundPitchMax, self.sampleMotor.pitchOffset + self.mrGbMB.soundPitchScale * oldRpsRange ) * rpmFactor
				else
					if self.mrGbMS.IdlePitchFactor > 0 then
						self.motorSoundPitchScale = self.mrGbMB.soundPitchScale * self.mrGbMS.IdlePitchFactor * newRpmRange / oldRpmRange
					end
					
					if     self.mrGbMS.IdlePitchMax < 0 then 
						self.motorSoundPitchMax   = self.sampleMotor.pitchOffset + self.motorSoundPitchScale * newRpsRange
					else
						if self.mrGbMS.IdlePitchMax > 0 then 
							self.motorSoundPitchMax = self.mrGbMS.IdlePitchMax * rpmFactor
						else
							self.motorSoundPitchMax = self.mrGbMB.soundPitchMax
						end 
					end 
				end 
				if self.mrGbMS.IdlePitchFactor < 0 then
					self.motorSoundPitchScale   = ( self.motorSoundPitchMax - self.sampleMotor.pitchOffset ) / newRpsRange
				end
				
				if self.mrGbMS.RunPitchFactor < 0 and self.mrGbMS.RunPitchMax < 0 then 
					self.motorSoundRunPitchMax     = math.min( self.mrGbMB.soundRunPitchMax, self.sampleMotorRun.pitchOffset + self.mrGbMB.soundRunPitchScale * oldRpsRange ) * rpmFactor
				else
					if self.mrGbMS.RunPitchFactor > 0 then
						self.motorSoundRunPitchScale = self.mrGbMB.soundRunPitchScale * self.mrGbMS.RunPitchFactor * newRpmRange / oldRpmRange
					end
					
					if     self.mrGbMS.RunPitchMax < 0 then 
						self.motorSoundRunPitchMax   = self.sampleMotorRun.pitchOffset + self.motorSoundRunPitchScale * newRpsRange
					else
						if self.mrGbMS.RunPitchMax > 0 then 
							self.motorSoundRunPitchMax = self.mrGbMS.RunPitchMax * rpmFactor
						else
							self.motorSoundRunPitchMax = self.mrGbMB.soundRunPitchMax
						end 

					end 
				end 
				if self.mrGbMS.RunPitchFactor < 0 then
					self.motorSoundRunPitchScale   = ( self.motorSoundRunPitchMax - self.sampleMotorRun.pitchOffset ) / newRpsRange
				end		
			end
			
			if mrGearboxMogliGlobals.modifyTransVol then
				local eff = ( self.mrGbMS.CurrentGear % 2 ) * self.mrGbMS.Run2PitchEffect * self.motorRun2PitchMax
				self.motorRun2PitchMax           = self.mrGbMB.soundRun2PitchMax    - eff
				self.sampleMotorRun2.pitchOffset = self.mrGbMB.soundRun2PitchOffset - eff
			end
				
			if mrGearboxMogliGlobals.modifyVolume then	
				local motorLoad 
				if self.isServer then 
					motorLoad = Utils.getNoNil( self.motor.motorLoadS1, self.motor.motorLoadS )
				else
					motorLoad = Utils.getNoNil( self:mrGbMGetMotorLoad(), 0.5 )
				end
				if self.sampleMotor.sample ~= nil then
					self.sampleMotor.volume    = self.mrGbMB.soundVolume * ( self.mrGbMS.IdleVolumeFactor + motorLoad * self.mrGbMS.IdleVolumeFactorInc )
					setSampleVolume( self.sampleMotor.sample, self.sampleMotor.volume )
				end
				if self.sampleMotorRun.sample ~= nil then
					local f0 = Utils.clamp( math.abs( self.lastRoundPerMinute ) / math.max( 1, self.motor.maxRpm - self.motor.minRpm ), 0, 1 )
					local f1 = 1.0 / math.max( f0, 0.01 )
					self.sampleMotorRun.volume = self.mrGbMB.soundRunVolume * ( self.mrGbMS.RunVolumeFactor  + f1 * motorLoad * self.mrGbMS.RunVolumeFactorInc )
				end
			end
		end
	end
--**********************************************************************************************************		
	
end 

--**********************************************************************************************************	
-- mrGearboxMogli:onLeave
--**********************************************************************************************************	
function mrGearboxMogli:onLeave()
	if self.mrGbMS == nil or self.mrGbML == nil or self.mrGbML.motor == nil then
		return
	end

	if self.steeringEnabled and self.mrGbMS.IsOn and ( self.mrGbMS.AutoClutch or self.mrGbMS.AutoStartStop ) then
		self:mrGbMSetNeutralActive( true, false, true )
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:updateTick
--**********************************************************************************************************	
function mrGearboxMogli:updateTick(dt)

	if self.mrGbMS == nil or self.mrGbML == nil or self.mrGbML.motor == nil then
		return
	end

	if self.isActive then
		if self.isServer then
			if not ( self.mrGbMS.IsOnOff ) then
				self:mrGbMSetState( "IsOn", false ) 
		--elseif self.isAITractorActivated 
		--		or self.isAIThreshing 
		--		or ( self.getIsCourseplayDriving ~= nil and self:getIsCourseplayDriving() ) then
			elseif not ( self.steeringEnabled ) then
				self.mrGbML.aiControlled = true
				if      self.mrGbMS.IsOnOff
						and ( self.mrGbMS.EnableAI   == "Y" 
						   or ( self.mrGbMS.EnableAI == "A" 
								and self.mrGbMS.Automatic ) ) then
					self:mrGbMSetState( "IsOn", true ) 
				else
					self:mrGbMSetState( "IsOn", false ) 	
				end
			elseif self.mrGbML.aiControlled then
				self.mrGbML.aiControlled = false
				self:mrGbMSetNeutralActive( true, false, true )
				self:mrGbMSetState( "IsOn", true ) 
			else		
				self:mrGbMSetState( "IsOn", true ) 
			end 	
			
			if not ( self.isMotorStarted ) then
				self:mrGbMSetNeutralActive( true, false, true )
			end
			
			if  not ( self.mrGbMS.Automatic ) 
					and self.mrGbMS.DisableManual then
				self:mrGbMSetAutomatic( true ) 
			end
	
			if self.mrGbMS.Automatic and not ( self.mrGbMS.HydrostaticLaunch ) then
				if self.mrGbMS.AutoShiftGears and self.mrGbMS.ManualClutchGear then
					self:mrGbMSetAutoClutch( true ) 
				end
				if self.mrGbMS.AutoShiftHl and self.mrGbMS.ManualClutchHl then
					self:mrGbMSetAutoClutch( true ) 
				end
			end 	
		
			if self.mrGbMS.IsOn and self.mrGbML.motor ~= nil then	
				self.mrGbML.lastSumDt = self.mrGbML.lastSumDt + dt
					
				if self.mrGbML.lastSumDt > 333 then
					if self.isMotorStarted then
						self.mrGbMD.Rpm    = tonumber( Utils.clamp( math.floor( 255*(self.motor.targetRpm-self.motor.minRpm)/(self.motor.maxRpm-self.motor.minRpm)+0.5), 0, 255 ))	 				
						self.mrGbMD.Clutch = tonumber( Utils.clamp( math.floor( self.motor.clutchPercent * 200+0.5), 0, 255 ))	
						self.mrGbMD.Load   = tonumber( Utils.clamp( math.floor( self.motor.motorLoadS*20+0.5)*5, 0, 255 ))	
						if mrGearboxMogliGlobals.drawReqPower then
							local power = ( self.motor.motorLoad + self.motor.neededPtoTorque + self.motor.lastLostTorque ) * math.max( self.motor.prevNonClampedMotorRpm, self.motor.stallRpm )
							self.mrGbMD.Power  = tonumber( Utils.clamp( math.floor( power * mrGearboxMogli.powerFactor + 0.5 ), 0, 65535 ))	
						end
					else
						self.mrGbMD.Rpm    = 0
					  self.mrGbMD.Clutch = 0
            self.mrGbMD.Load   = 0
					  self.mrGbMD.Power  = 0
					end
				--self.mrGbMD.Speed    = tonumber( Utils.clamp( math.floor( math.min( self.mrGbML.currentGearSpeed / self.mrGbMS.GlobalRatioFactor * 3.6, self.motor.speedLimit ) + 0.5 ), 0, 255 ))	
					self.mrGbMD.Speed    = tonumber( Utils.clamp( math.floor( self.mrGbML.currentGearSpeed / self.mrGbMS.GlobalRatioFactor * 3.6 + 0.5 ), 0, 255 ))	
					
					if self.mrGbMS.Hydrostatic and self.mrGbML.motor ~= nil then
						self.mrGbMD.Speed = 0
					end
					
					if self.mrGbML.lastFuelFillLevel == nil then
						self.mrGbML.lastFuelFillLevel = self.fuelFillLevel
						self.mrGbMD.Fuel              = 0
					else
						local fuelUsed = self.mrGbML.lastFuelFillLevel - self.fuelFillLevel
						self.mrGbML.lastFuelFillLevel = self.fuelFillLevel
						self.mrGbMD.Fuel              = fuelUsed * (1000 * 3600) / self.mrGbML.lastSumDt
					end
					
					if      not ( mrGearboxMogliGlobals.drawTargetRpm )					
							and ( not ( self.mrGbMS.HydrostaticLaunch )
								 or ( self.mrGbMS.AutoClutch
									and g_currentMission.time >= self.mrGbML.manualClutchTime + 5000 ) ) then
						self.mrGbMD.Rpm = 0
					end
					if not ( mrGearboxMogliGlobals.drawReqPower  ) then
						self.mrGbMD.Power = 0
					end
					
					if     self.mrGbMD.lastClutch ~= self.mrGbMD.Clutch
							or self.mrGbMD.lastRpm    ~= self.mrGbMD.Rpm
							or self.mrGbMD.lastLoad   ~= self.mrGbMD.Load   
							or self.mrGbMD.lastSpeed  ~= self.mrGbMD.Speed 
							or self.mrGbMD.lastPower  ~= self.mrGbMD.Power 
							then
						self:raiseDirtyFlags(self.mrGbML.dirtyFlag) 
					
						self.mrGbMD.lastRpm    = self.mrGbMD.Rpm
						self.mrGbMD.lastClutch = self.mrGbMD.Clutch
						self.mrGbMD.lastLoad   = self.mrGbMD.Load   
						self.mrGbMD.lastSpeed  = self.mrGbMD.Speed 
						self.mrGbMD.lastPower  = self.mrGbMD.Power 
					end 
					
					self.mrGbML.lastSumDt = 0
				end 
			else
				self.mrGbML.lastSumDt         = 0
				self.mrGbML.lastFuelFillLevel = self.fuelFillLevel
			end
		end
	end	
end 

--**********************************************************************************************************	
-- mrGearboxMogli:readUpdateStream
--**********************************************************************************************************	
function mrGearboxMogli:readUpdateStream(streamId, timestamp, connection)
  if connection:getIsServer() then
		if streamReadBool( streamId ) then
			self.mrGbMD.Clutch = streamReadUInt8( streamId ) 
			self.mrGbMD.Load   = streamReadUInt8( streamId )  
			self.mrGbMD.Speed  = streamReadUInt8( streamId ) 			
			self.mrGbMD.Rpm    = streamReadUInt8( streamId ) 
			
			if mrGearboxMogliGlobals.drawReqPower  then self.mrGbMD.Power = streamReadUInt16( streamId ) end			
		end 
  end 
end 

--**********************************************************************************************************	
-- mrGearboxMogli:writeUpdateStream
--**********************************************************************************************************	
function mrGearboxMogli:writeUpdateStream(streamId, connection, dirtyMask)
  if not connection:getIsServer() then
		if streamWriteBool(streamId, bitAND(dirtyMask, self.mrGbML.dirtyFlag) ~= 0) then				
			streamWriteUInt8(streamId, self.mrGbMD.Clutch ) 
			streamWriteUInt8(streamId, self.mrGbMD.Load   ) 
			streamWriteUInt8(streamId, self.mrGbMD.Speed  ) 			 
			streamWriteUInt8(streamId, self.mrGbMD.Rpm    )  
			
			if mrGearboxMogliGlobals.drawReqPower  then streamWriteUInt16(streamId, self.mrGbMD.Power  ) end			
		end 
	end 
end 

--**********************************************************************************************************	
-- mrGearboxMogli:delete
--**********************************************************************************************************	
function mrGearboxMogli:delete()
	if self.mrGbML ~= nil then
		if self.mrGbML.blowOffVentilSample ~= nil then
			pcall( delete, self.mrGbML.blowOffVentilSample )
			self.mrGbML.blowOffVentilSample= nil
		end
		if self.mrGbML.grindingSample ~= nil then
			pcall( delete, self.mrGbML.grindingSample )
			self.mrGbML.grindingSample= nil
		end
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:deleteMap
--**********************************************************************************************************	
function mrGearboxMogli:deleteMap()
	if mrGearboxMogli.backgroundOverlayId ~= nil then
		pcall( delete, mrGearboxMogli.backgroundOverlayId )
		mrGearboxMogli.backgroundOverlayId = nil
	end
	if mrGearboxMogli.BOVSample ~= nil then
		pcall( delete, mrGearboxMogli.BOVSample )
		mrGearboxMogli.BOVSample= nil
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:draw
--**********************************************************************************************************	
function mrGearboxMogli:draw() 	
	
--if self.mrGbML.motor == nil then return end
	
	if self.mrGbMS.IsOn and self.mrGbMS.showHud then
	
		if      self.mrGbMS.InfoText ~= nil
				and self.mrGbMS.InfoText ~= "" then
			if g_currentMission.time < self.mrGbML.infoTimer then
				g_currentMission:addExtraPrintText(self.mrGbMS.InfoText)
			else
				self.mrGbMS.InfoText = ""
			end
		end
	
		if mrGearboxMogli.backgroundOverlayId == nil then
			mrGearboxMogli.backgroundOverlayId = createImageOverlay( "dataS2/menu/blank.png" )
			setOverlayColor( mrGearboxMogli.backgroundOverlayId, 0,0,0, 0.4 )
		end	
		
		local gearText = self:mrGbMGetGearText()
		local drawY0   = 0.706
		local deltaY   = 0.02
		local ovTop    = drawY0 + 0.057  -- title plus 0.03 plus character size of title (0.03)
		local ovRows   = 3
		
		if gearText ~= "" then
			ovRows = ovRows + 1
		end
		if self.mrGbMD.Speed > 0 then
			ovRows = ovRows + 1
		end
		if self.mrGbMD.Rpm > 0 then
			ovRows = ovRows + 1
		end
		if mrGearboxMogliGlobals.drawReqPower  then
			ovRows = ovRows + 1
		end
		if not ( self.mrGbMS.HydrostaticLaunch ) then
			ovRows = ovRows + 1
		end

		local ovH      = 0.04 + 0.02 + ovRows * deltaY -- title is 0.03 points above drawY0; add border of 0.01 x 2
		local ovY      = ovTop - ovH
		
		renderOverlay( mrGearboxMogli.backgroundOverlayId, 0.84, ovY, 0.16, ovH )
	
		setTextAlignment(RenderText.ALIGN_LEFT) 
		setTextColor(1, 1, 1, 1) 

		setTextBold(true) 
		renderText(0.85, drawY0 + 0.03, 0.03, self.mrGbMS.DrawText) 			     	
		setTextBold(false) 
		
		local drawY    = drawY0 
			
		if gearText ~= "" then
			renderText(0.85, drawY, deltaY, gearText) 	
		else
			drawY0 = drawY0 + deltaY 
			drawY  = drawY0
		end
			
		if self.mrGbMD.Speed > 0 then
			drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Gear speed............")
		end
		drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Current rpm...........")
		if self.mrGbMD.Rpm > 0 then
			drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Target rpm............")
		end
		if mrGearboxMogliGlobals.drawReqPower  then
			drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Power.................")
		end
		drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Load..................")
		drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Fuel used.............")
		if     self.mrGbMS.HydrostaticLaunch then
		elseif self.mrGbMS.AutoClutch then 
			drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Auto clutch...........")
		else
			drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Clutch................")
		end
		if self.mrGbMS.HandThrottle > 0 then
			drawY = drawY - deltaY renderText(0.85, drawY, deltaY, "Hand throttle.........")	
		end

		
		setTextAlignment(RenderText.ALIGN_RIGHT) 
		drawY    = drawY0 
		
		if self.mrGbMD.Speed > 0 then
			drawY = drawY - deltaY renderText(0.99,drawY,deltaY, string.format("%3.1f km/h", self.mrGbMD.Speed ))
		end
		drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%4.0f rpm", math.floor(self.motor.lastMotorRpm * 0.1 +0.5)*10)) 		
		if self.mrGbMD.Rpm > 0 then
			drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%4.0f rpm", math.floor((self.motor.minRpm + self.mrGbMD.Rpm * (self.motor.maxRpm-self.motor.minRpm) * mrGearboxMogli.factor255)*0.1 +0.5)*10)) 		
		end
		if mrGearboxMogliGlobals.drawReqPower  then
			drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%4.0f HP", self.mrGbMD.Power ))				
		end
		drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%3d %%", self.mrGbMD.Load )) 	
		drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%3d l/h", self.mrGbMD.Fuel ))  		          
		if     self.mrGbMS.HydrostaticLaunch then
		elseif self.mrGbMS.AutoClutch then 
			drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%3.0f %%", self.mrGbMD.Clutch*0.5 / self.mrGbMS.MaxClutchPercent  )) 
		else
			drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%3.0f %%", math.floor( self.mrGbMS.ManualClutch / self.mrGbMS.MaxClutchPercent * 100 + 0.5 ) ))
		end
		if self.mrGbMS.HandThrottle > 0 then
			drawY = drawY - deltaY renderText(0.99, drawY, deltaY, string.format("%3d %%", math.floor( self.mrGbMS.HandThrottle * 100 + 0.5 ) ))  		          
		end
		
		drawY = drawY - 0.015 renderText(0.99, drawY, 0.01, mrGearboxMogli.getText( "mrGearboxMogliVERSION" ) )  		          
		
		setTextAlignment(RenderText.ALIGN_LEFT) 
		setTextBold(false)
		
		if InputBinding.mrGearboxMogliON_OFF ~= nil then
			g_currentMission:addHelpButtonText(mrGearboxMogli.getText("mrGearboxMogliON"),  InputBinding.mrGearboxMogliON_OFF);		
		end
	else
		if InputBinding.mrGearboxMogliON_OFF ~= nil then
			g_currentMission:addHelpButtonText(mrGearboxMogli.getText("mrGearboxMogliOFF"), InputBinding.mrGearboxMogliON_OFF);		
		end
	end
	
end 

--**********************************************************************************************************	
-- mrGearboxMogli:getSaveAttributesAndNodes
--**********************************************************************************************************	
function mrGearboxMogli:getSaveAttributesAndNodes(nodeIdent)

	local attributes = ""

	if self.mrGbMS ~= nil then
		if      self.mrGbMS.CurrentGear ~= self.mrGbMS.LaunchGear
				and not ( self.mrGbMS.AutoShiftGears and self.mrGbMS.Automatic ) then
			attributes = attributes.." mrGbMCurrentGear=\""  .. tostring(self.mrGbMS.CurrentGear  ) .. "\""
		end
		if      self.mrGbMS.CurrentRange ~= self.mrGbMS.LaunchRange
				and not ( self.mrGbMS.AutoShiftHl and self.mrGbMS.Automatic ) then
			attributes = attributes.." mrGbMCurrentRange=\"" .. tostring(self.mrGbMS.CurrentRange ) .. "\""
		end
		if self.mrGbMS.CurrentRange2 ~= self.mrGbMS.LaunchRange2 then
			attributes = attributes.." mrGbMCurrentRange2=\"" ..tostring(self.mrGbMS.CurrentRange2 ) .. "\""
		end
		if self.mrGbMS.G27Mode > 0 then
			attributes = attributes.." mrGbMG27Mode=\"" ..tostring(self.mrGbMS.G27Mode ) .. "\""
		end
		if not ( self.mrGbMS.AutoClutch ) then
			attributes = attributes.." mrGbMAutoClutch=\"" .. tostring(self.mrGbMS.AutoClutch ) .. "\""
		end
		if not ( self.mrGbMS.Automatic ) and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl ) then
			attributes = attributes.." mrGbMAutomatic=\"" .. tostring( self.mrGbMS.Automatic ) .. "\""  
		end
		if self.mrGbMS.DefaultOn ~= self.mrGbMS.IsOnOff then
			attributes = attributes.." mrGbMIsOnOff=\"" .. tostring( self.mrGbMS.IsOnOff ) .. "\""     
		end
		if self.mrGbMS.AccelerateToLimit <= 4 or self.mrGbMS.AccelerateToLimit >= 6 then
			attributes = attributes.." mrGbMSpeedAcc=\"" .. tostring( self.mrGbMS.AccelerateToLimit ) .. "\""     
		end                                                                        
		if self.mrGbMS.DecelerateToLimit <= 9 or self.mrGbMS.DecelerateToLimit >= 11 then
			attributes = attributes.." mrGbMSpeedDec=\"" .. tostring( self.mrGbMS.DecelerateToLimit ) .. "\""     
		end
	end 
	
	return attributes
end 

--**********************************************************************************************************	
-- mrGearboxMogli:loadFromAttributesAndNodes
--**********************************************************************************************************	
function mrGearboxMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	local i, b
	
	if self.mrGbMS ~= nil then
		i = getXMLInt(xmlFile, key .. "#mrGbMCurrentGear" )
		if i ~= nil then
			self.mrGbMS.DefaultGear = i
		end

		i = getXMLInt(xmlFile, key .. "#mrGbMCurrentRange" )
		if i ~= nil then
			self.mrGbMS.DefaultRange = i
		end
		
		i = getXMLInt(xmlFile, key .. "#mrGbMCurrentRange2" )
		if i ~= nil then
			self.mrGbMS.DefaultRange2 = i
		end

		i = getXMLInt(xmlFile, key .. "#mrGbMG27Mode" )
		if i ~= nil then
			self.mrGbMS.G27Mode = i
		end

		i = getXMLInt(xmlFile, key .. "#mrGbMSpeedAcc" )
		if i ~= nil then
			self.mrGbMS.AccelerateToLimit = i
		end

		i = getXMLInt(xmlFile, key .. "#mrGbMSpeedDec" )
		if i ~= nil then
			self.mrGbMS.DecelerateToLimit = i
		end

		b = getXMLBool(xmlFile, key .. "#mrGbMAutoClutch" )
		if b ~= nil then
			self.mrGbMS.AutoClutch = b
		end

		b = getXMLBool(xmlFile, key .. "#mrGbMAutomatic" )
		if b ~= nil then
			self.mrGbMS.Automatic = b
		end

		b = getXMLBool(xmlFile, key .. "#mrGbMIsOnOff" )
		if b ~= nil then
			self.mrGbMS.IsOnOff = b
		end

	--self:mrGbMSetState( "FirstTimeRun", false )
	end
	
	return BaseMission.VEHICLE_LOAD_OK
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMIsNotValidEntry
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMIsNotValidEntry( entry, cg, c1, c2 )

	if self.mrGbMS.ReverseActive then
		if entry.forwardOnly then
			return true
		end
	else
		if entry.reverseOnly then
			return true
		end
	end
	
	if entry.minGear   ~= nil and Utils.getNoNil( cg, self.mrGbMS.CurrentGear )   < entry.minGear   then
		return true
	end
	if entry.maxGear   ~= nil and Utils.getNoNil( cg, self.mrGbMS.CurrentGear )   > entry.maxGear   then
		return true
	end
	if entry.maxRange  ~= nil and Utils.getNoNil( c1, self.mrGbMS.CurrentRange )  < entry.minRange then
		return true
	end 
	if entry.maxRange  ~= nil and Utils.getNoNil( c1, self.mrGbMS.CurrentRange )  > entry.maxRange  then
		return true
	end
	if entry.maxRange2 ~= nil and Utils.getNoNil( c2, self.mrGbMS.CurrentRange2 ) < entry.minRange2 then
		return true
	end
	if entry.maxRange2 ~= nil and Utils.getNoNil( c2, self.mrGbMS.CurrentRange2 ) > entry.maxRange2 then
		return true
	end
	
	return false
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetNewEntry
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetNewEntry( entries, current, index, name )

	local new = Utils.clamp( index, 1, table.getn( entries ) )
	local cg  = self.mrGbMS.CurrentGear
	local cr  = self.mrGbMS.CurrentRange
	
	if name == "gear" then cg = new	elseif name == "range" then cr = new end

	if new > current then
		while new < table.getn( entries ) 
			and mrGearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr ) do
			new = new + 1
			if name == "gear" then cg = new	elseif name == "range" then cr = new end
		end
	end
	while new > 1
		and mrGearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr ) do
		new = new -1
		if name == "gear" then cg = new	elseif name == "range" then cr = new end
	end
	while new < table.getn( entries ) 
		and mrGearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr ) do
		new = new + 1
		if name == "gear" then cg = new	elseif name == "range" then cr = new end
	end
		
	if mrGearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr ) then
		print(string.format("no %s found: %d", name, index))
	end
	
	return new
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMCheckGrindingGears
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMCheckGrindingGears( checkIt, noEventSend )
	if self.steeringEnabled and checkIt and not ( self.mrGbMS.AutoClutch ) and not ( self.mrGbMS.Automatic ) then
		if self.mrGbMS.ManualClutch > self.mrGbMS.MinClutchPercent + 0.1 then
			self:mrGbMSetState( "InfoText", string.format( "Cannot shift gear; clutch > %3.0f%%", 100*Utils.clamp( self.mrGbMS.MinClutchPercent + 0.1, 0, 1 ) ))
			self.mrGbMS.GrindingGearsPlay = false
			self:mrGbMSetState( "GrindingGearsPlay", true )
			return true
		end		
	end		
	return false
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetCurrentGear
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetCurrentGear( new, noEventSend )
	if mrGearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchGear, noEventSend ) then
		return 
	end

	local newGear  = mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, new, "gear" )
	local newRange = self.mrGbMS.CurrentRange
	if not self.mrGbMS.Automatic then
		if     newGear > self.mrGbMS.CurrentGear and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].upRangeOffset   ~= nil then 
			newRange = self.mrGbMS.CurrentRange + self.mrGbMS.Gears[self.mrGbMS.CurrentGear].upRangeOffset
		elseif newGear < self.mrGbMS.CurrentGear and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].downRangeOffset ~= nil then 
			newRange = self.mrGbMS.CurrentRange + self.mrGbMS.Gears[self.mrGbMS.CurrentGear].downRangeOffset
		end
		newRange = mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, newRange, "range" )
	end
	
	if newGear ~= self.mrGbMS.CurrentGear then
		self:mrGbMSetState( "CurrentGear",  newGear,  noEventSend ) 		
		self:mrGbMSetState( "CurrentRange", newRange, noEventSend ) 
	end
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetCurrentRange
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetCurrentRange(new, noEventSend)
	if mrGearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchHl, noEventSend ) then
		return 
	end

	local newRange = mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, new, "range" )
	local newGear  = self.mrGbMS.CurrentGear
	if     newRange > self.mrGbMS.CurrentRange and self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].upGearOffset   ~= nil then 
		newGear = self.mrGbMS.CurrentGear + self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].upGearOffset
	elseif newRange < self.mrGbMS.CurrentRange and self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].downGearOffset ~= nil then  
		newGear = self.mrGbMS.CurrentGear + self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].downGearOffset
	end
	newGear = mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, newGear, "gear" )
	
	if newRange ~= self.mrGbMS.CurrentRange then
		self:mrGbMSetState( "CurrentRange", newRange, noEventSend ) 
		self:mrGbMSetState( "CurrentGear",  newGear,  noEventSend ) 		
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetCurrentRange2
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetCurrentRange2(new, noEventSend)
	if mrGearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchRanges2, noEventSend ) then
		return 
	end

	local newRange2 = mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, new, "range2" )
	
	if newRange2 ~= self.mrGbMS.CurrentRange2 then
		self:mrGbMSetState( "CurrentRange2", newRange2, noEventSend ) 
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetSpeedLimiter
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetSpeedLimiter( value, noEventSend )
	self:mrGbMSetState( "SpeedLimiter", value, noEventSend ) 		
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetAccelerateToLimit
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetAccelerateToLimit( value, noEventSend )
	self:mrGbMSetState( "AccelerateToLimit", Utils.clamp( value, 1, 10 ), noEventSend ) 		
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetDecelerateToLimit
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetDecelerateToLimit( value, noEventSend )
	self:mrGbMSetState( "DecelerateToLimit", Utils.clamp( value, 1, 20 ), noEventSend ) 		
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetAutomatic
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetAutomatic( value, noEventSend )
	local new = false 
	if value and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl ) then
		new = true 
	end 
	self:mrGbMSetState( "Automatic", new, noEventSend ) 		
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetNeutralActive
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetNeutralActive( value, noEventSend, noCheck )
	if      self.mrGbMS.NeutralActive ~= nil
			and self.mrGbMS.NeutralActive ~= value 
			and mrGearboxMogli.mrGbMCheckGrindingGears( self, not ( self.mrGbMS.AutoClutch or self.mrGbMS.AutoStartStop or noCheck ), noEventSend ) then
		return 
	end

	self:mrGbMSetState( "NeutralActive", value, noEventSend ) 		
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetReverseActive
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetReverseActive( value, noEventSend )
	if      self.mrGbMS.ReverseActive ~= nil
			and self.mrGbMS.ReverseActive ~= value 
			and mrGearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchReverse, noEventSend ) then
		return 
	end

	self:mrGbMSetState( "ReverseActive", value, noEventSend ) 		
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetHandThrottle
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetHandThrottle( value, noEventSend )
	self:mrGbMSetState( "HandThrottle", Utils.clamp( value, 0, 1 ), noEventSend )
end 
--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetIsOnOff
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetIsOnOff( value, noEventSend )
	self:mrGbMSetState( "IsOnOff", value, noEventSend ) 		
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetAutoClutch
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetAutoClutch( value, noEventSend )
	self:mrGbMSetState( "AutoClutch", value, noEventSend ) 		
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMSetManualClutch
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMSetManualClutch( value, noEventSend )
	self:mrGbMSetState( "ManualClutch", Utils.clamp( value, 0, 1 ), noEventSend ) 		
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetClutchPercent
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetClutchPercent()
	if self.mrGbML.motor == nil then
		return nil
	end
	if self.isServer then
		return self.motor.clutchPercent 
	end
	if self.mrGbMS.AutoClutch then 
		if self.isServer then
			return self.motor.clutchPercent
		end
		return self.mrGbMD.Clutch*0.005
	end	
	return self.mrGbMS.ManualClutch
end


--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetTargetRPM
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetTargetRPM()
	if self.mrGbML.motor == nil then
		return nil
	end

	if mrGearboxMogliGlobals.drawTargetRpm then
		if self.isServer then
			return self.motor.targetRpm 
		end
		return self.motor.minRpm + self.mrGbMD.Rpm * (self.motor.maxRpm-self.motor.minRpm) * mrGearboxMogli.factor255
	end
	return nil
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetUsedPower
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetUsedPower()
	if self.mrGbML.motor == nil then
		return nil
	end
	
	if mrGearboxMogliGlobals.drawReqPower then
		return self.mrGbMD.Power
	end
	return nil
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetMotorLoad
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetMotorLoad()
	if self.mrGbML.motor == nil then
		return nil
	end

	if self.isServer then
		return self.motor.motorLoadS 
	end
	return self.mrGbMD.Load
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetGearText
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetGearText()

	local gearText = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].name
	if self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name ~= nil and self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name ~= "" then
		if self.mrGbMS.SwapGearRangeKeys then
			gearText = gearText .." ".. self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name
		else
			gearText = self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name .." ".. gearText
		end
	end
	if self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name ~= nil and self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name ~= "" then
		gearText = self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name .." ".. gearText
	end
	
	return gearText
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetModeText
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetModeText()
	return self.mrGbMS.DrawText
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMGetIsOn
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMGetIsOn()
	return self.mrGbMS.IsOn
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMPrepareGearShift
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMPrepareGearShift( timeToShift, clutchPercent, doubleClutch, shiftingEffect )
	if self.isServer then
		if self.mrGbML.motor ~= nil then
			self.mrGbML.beforeShiftRpm = self.motor.nonClampedMotorRpm 
			if mrGearboxMogli.debugGearShift then
				self.mrGbML.debugTimer = g_currentMission.time + 1000
			end							
		end
		self.mrGbML.gearShiftingEffect = shiftingEffect and ( timeToShift >= 0 )
		local minTimeToShift = mrGearboxMogliGlobals.minTimeToShift
		if ( timeToShift < 0 or ( timeToShift == 0 and minTimeToShift == 0 ) ) and self.mrGbML.gearShiftingTime < g_currentMission.time then
			mrGearboxMogli.mrGbMDoGearShift(self)		
			self.mrGbML.gearShiftingNeeded   = 0
		elseif self.mrGbMS.AutoClutch then
			self.mrGbML.gearShiftingNeeded   = 1 
			-- reduce time to shift at very low speed
			local kmh = self.lastSpeedReal * 3600			
			if kmh < 20 then
				timeToShift = timeToShift * ( 0.5 + 0.025 * kmh )
			end
			self.mrGbML.gearShiftingTime     = math.max( self.mrGbML.gearShiftingTime, g_currentMission.time + math.max( minTimeToShift, timeToShift ) ) 
			self.mrGbML.afterShiftClutch     = clutchPercent
			if doubleClutch then
				self.mrGbML.doubleClutch       = true
				self.mrGbML.clutchShiftingTime = math.max( self.mrGbML.clutchShiftingTime, g_currentMission.time + 0.4 * timeToShift ) 
			else
				self.mrGbML.doubleClutch       = false
				self.mrGbML.clutchShiftingTime = math.max( self.mrGbML.clutchShiftingTime, g_currentMission.time + self.mrGbMS.ClutchShiftTime ) 
			end
		elseif doubleClutch then
			self.mrGbML.gearShiftingNeeded  = -1 
		else
			mrGearboxMogli.mrGbMDoGearShift(self)		
			self.mrGbML.gearShiftingNeeded  = 0
		end
	else
		print("ERROR: mrGearboxMogli:mrGbMPrepareGearShift called at client")
	end 
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMDoGearShift
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMDoGearShift(increaseOnly)
	if self.isServer then
		
		if     self.mrGbML.gearShiftingTime < g_currentMission.time then
			self.mrGbML.gearShiftingNeeded = 0
		elseif self.mrGbML.doubleClutch then
			self.mrGbML.gearShiftingNeeded = 2
		else
			self.mrGbML.gearShiftingNeeded = 3
		end
		local gearMaxSpeed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed 
		                   * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio 
											 * self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio
											 * self.mrGbMS.GlobalRatioFactor
		if self.mrGbMS.ReverseActive then	
			gearMaxSpeed = gearMaxSpeed * self.mrGbMS.ReverseRatio 
		end
		
		local lastGearSpeed = Utils.getNoNil( self.mrGbML.currentGearSpeed, 0 )
		
		if increaseOnly then
			self.mrGbML.currentGearSpeed = math.max( gearMaxSpeed, self.mrGbML.currentGearSpeed )
		else
			self.mrGbML.currentGearSpeed = gearMaxSpeed 
		end
		
		
		if self.mrGbML.motor ~= nil then		
			if mrGearboxMogli.rpmIncPerGearSpeed then
				self.mrGbML.motor.rpmIncFactor = self.mrGbMS.RpmIncFactor * math.sqrt( math.abs( mrGearboxMogli.gearSpeedToRatio( self, self.mrGbML.currentGearSpeed ) ) )
			end
			if self.mrGbML.beforeShiftRpm ~= nil then
				self.mrGbML.afterShiftRpm = Utils.clamp( self.mrGbML.beforeShiftRpm * lastGearSpeed / self.mrGbML.currentGearSpeed, self.mrGbML.motor.idleRpm, self.mrGbML.motor.maxAllowedRpm )
				if      self.mrGbML.gearShiftingEffect 
						and self.motor.minRpm < self.mrGbML.afterShiftRpm and self.mrGbML.afterShiftRpm < self.motor.maxRpm 
					--and self.mrGbML.motor.autoClutchPercent > 0.9 * self.mrGbMS.MaxClutchPercent 
						then
					self:mrGbMSetState( "ResetSoundRPM", self.mrGbML.afterShiftRpm - self.motor.minRpm ) --Utils.clamp( self.mrGbML.afterShiftRpm - self.mrGbML.motor.stallRpm, 0, 0.6 * ( self.mrGbML.motor.maxAllowedRpm - self.mrGbML.motor.stallRpm ) ) )
				end
			else
				self.mrGbML.afterShiftRpm = nil
			end
		else
			self.mrGbML.afterShiftClutch  = nil
			self.mrGbML.beforeShiftRpm    = nil
			self.mrGbML.afterShiftRpm     = nil
		end
	end 
end 

--**********************************************************************************************************	
-- mrGearboxMogli:useLaunchGear
--**********************************************************************************************************	
function mrGearboxMogli:useLaunchGear( )
	if      self.mrGbMS.Automatic
			and ( not self.mrGbMS.ReverseActive
				 or not self.mrGbMS.ReverseResetGear ) then
		return true
	end
	return false
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetReverse
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetReverse( old, new, noEventSend )

	self.mrGbMS.ReverseActive = new 
	--timer to shift the "reverse/forward"
	if self.isServer then
		mrGearboxMogli.mrGbMPrepareGearShift( self, self.mrGbMS.GearTimeToShiftReverse, self.mrGbMS.ClutchAfterShiftReverse, self.mrGbMS.ReverseDoubleClutch, false ) 
	end
	
	local default = self.mrGbMS.CurrentGear
	if     mrGearboxMogli.useLaunchGear( self ) then
		default = self.mrGbMS.LaunchGear
	elseif self.mrGbMS.Automatic then
		default = math.max( self.mrGbMS.DefaultGear, self.mrGbMS.LaunchGear )
	elseif self.mrGbMS.ReverseResetGear  then
		default = self.mrGbMS.DefaultGear
	end
	
	self:mrGbMSetState( "DefaultGear", self.mrGbMS.CurrentGear, noEventSend ) 
	self:mrGbMSetState( "CurrentGear", mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, default, "gear" ), noEventSend ) 
	
	local default = self.mrGbMS.CurrentRange
	if self.mrGbMS.ReverseResetRange then
		default = self.mrGbMS.DefaultRange
	end

	self:mrGbMSetState( "DefaultRange", self.mrGbMS.CurrentRange, noEventSend ) 
	self:mrGbMSetState( "CurrentRange", mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, default, "range" ), noEventSend ) 

	local default = self.mrGbMS.CurrentRange2
	if self.mrGbMS.ReverseResetRange2 then
		default = self.mrGbMS.DefaultRange2
	end

	self:mrGbMSetState( "DefaultRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
	self:mrGbMSetState( "CurrentRange2", mrGearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, default, "range2" ), noEventSend ) 
	
	if self.isServer then
		self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.GearTimeToShiftReverse + self.mrGbMS.AutoShiftTimeoutLong 
		self.mrGbML.autoShiftUpTimer   = g_currentMission.time + self.mrGbMS.GearTimeToShiftReverse + self.mrGbMS.AutoShiftTimeoutShort 
		if self.mrGbML.motor ~= nil then
			self.mrGbML.motor.speedLimitS = 0
		end
	end 
end 
		
--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetNeutral
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetNeutral( old, new, noEventSend )		
	self.mrGbMS.NeutralActive   = new 

	if new and mrGearboxMogli.useLaunchGear( self ) then
		self:mrGbMSetCurrentGear(self.mrGbMS.LaunchGear) 
	end
	
	if self.isServer then
		mrGearboxMogli.mrGbMPrepareGearShift( self, 0, self.mrGbMS.MinClutchPercent, false, false ) 
		self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.AutoShiftTimeoutLong 
		self.mrGbML.autoShiftUpTimer   = g_currentMission.time + self.mrGbMS.AutoShiftTimeoutShort 
		if self.mrGbML.motor ~= nil then
			self.mrGbML.motor.speedLimitS = 0
		end
	end
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetRange
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetRange( old, new, noEventSend )
		
	local timeToShift = self.mrGbMS.GearTimeToShiftHl
	if mrGearboxMogli.superFastDownShift and timeToShift < 1 and new < self.mrGbMS.CurrentRange then
		timeToShift = -1 
	end
	
	self.mrGbMS.CurrentRange = new

	--timer to shift the "range"
	if self.isServer then
		mrGearboxMogli.mrGbMPrepareGearShift( self, timeToShift, self.mrGbMS.ClutchAfterShiftHl, self.mrGbMS.Range1DoubleClutch, self.mrGbMS.GearShiftEffectHl ) 
		self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.ClutchAfterShiftHl + self.mrGbMS.AutoShiftTimeoutShort
		self.mrGbML.autoShiftUpTimer   = g_currentMission.time +self.mrGbMS.ClutchAfterShiftHl  + self.mrGbMS.AutoShiftTimeoutShort
	end 
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetRange2
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetRange2( old, new, noEventSend )
		
	local timeToShift = self.mrGbMS.GearTimeToShiftRanges2
	if mrGearboxMogli.superFastDownShift and timeToShift < 1 and new < self.mrGbMS.CurrentRange2 then
		timeToShift = -1 
	end
	
	self.mrGbMS.CurrentRange2 = new

	--timer to shift the "range 2"
	if self.isServer then	
		mrGearboxMogli.mrGbMPrepareGearShift( self, timeToShift, self.mrGbMS.ClutchAfterShiftRanges2, self.mrGbMS.Range2DoubleClutch, self.mrGbMS.GearShiftEffectRanges2 ) 
		self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.ClutchAfterShiftRanges2 + self.mrGbMS.AutoShiftTimeoutShort
		self.mrGbML.autoShiftUpTimer   = g_currentMission.time + self.mrGbMS.ClutchAfterShiftRanges2 + self.mrGbMS.AutoShiftTimeoutShort
	end 
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetGear
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetGear( old, new, noEventSend )

	local timeToShift = self.mrGbMS.GearTimeToShiftGear
	
	if     new > self.mrGbMS.CurrentGear then
		if self.isServer then
			self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.GearTimeToShiftGear + self.mrGbMS.AutoShiftTimeoutLong 
			self.mrGbML.autoShiftUpTimer   = g_currentMission.time + self.mrGbMS.GearTimeToShiftGear + self.mrGbMS.AutoShiftTimeoutShort
		end 
	elseif new < self.mrGbMS.CurrentGear then                                              
		if self.isServer then
			self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.GearTimeToShiftGear + self.mrGbMS.AutoShiftTimeoutShort
			self.mrGbML.autoShiftUpTimer   = g_currentMission.time + self.mrGbMS.GearTimeToShiftGear + self.mrGbMS.AutoShiftTimeoutLong 
		end 
		if mrGearboxMogli.superFastDownShift and timeToShift < 1 then
			timeToShift = -1
		end
	end			
	
	self.mrGbMS.CurrentGear = new
	
	if self.isServer then	
	-- adjust clutch % to fit rpm after gear shift	
		local clutchPercent = self.mrGbMS.ClutchAfterShiftGear
		if clutchPercent < 0 and self.mrGbML.motor ~= nil then
			local gearSpeed = self.mrGbMS.Gears[new].speed * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio * self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio * self.mrGbMS.GlobalRatioFactor
			if self.mrGbMS.ReverseActive then	
				gearSpeed = gearSpeed * self.mrGbMS.ReverseRatio 
			end
			clutchPercent = mrGearboxMogliMotor.getClutchPercent( self.mrGbML.motor, self.mrGbML.motor.currentRpmS, self.mrGbMS.RatedRpm, self.mrGbML.motor.currentRpmS, 1 )
		end
	
		--timer to set the gear
		mrGearboxMogli.mrGbMPrepareGearShift( self, timeToShift, clutchPercent, self.mrGbMS.GearsDoubleClutch, self.mrGbMS.GearShiftEffectGear ) 	 	
	end
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetIsOn
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetIsOn( old, new, noEventSend )

	self.mrGbMS.IsOn = new

	if new then				
		if      self.dCcheckModule ~= nil
				and self.driveControl  ~= nil
				and self:dCcheckModule("shuttle")
				and self.driveControl.shuttle ~= nil 
				and self.driveControl.shuttle.isActive then
			if self.driveControl.shuttle.direction < 0 then
				self:mrGbMSetReverseActive( true, noEventSend )  -- first gear, H range, reverse
			else
				self:mrGbMSetReverseActive( false, noEventSend )  -- first gear, H range, forward
			end
		end
		if self.mrGbML.motor ~= nil then
			mrGearboxMogliMotor.copyRuntimeValues( self.mrGbML.motor, self.mrGbML.motor )
			self.motor = self.mrGbML.motor
		end
		if self.mrGbMS.Automatic then
			self:mrGbMSetState( "CurrentGear", self.mrGbMS.LaunchGear, noEventSend ) 
			self.mrGbML.autoShiftDownTimer = g_currentMission.time + self.mrGbMS.AutoShiftTimeoutLong 
			self.mrGbML.autoShiftUpTimer   = g_currentMission.time + self.mrGbMS.AutoShiftTimeoutShort 
		end
		self:mrGbMDoGearShift() 
	elseif old and self.mrGbML.motor ~= nil then
		if self.isServer then
			self:mrGbMSetState( "DefaultGear", self.mrGbMS.CurrentGear, noEventSend ) 
			self:mrGbMSetState( "DefaultRange", self.mrGbMS.CurrentRange, noEventSend ) 
			self:mrGbMSetState( "DefaultRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
		end
		self.mrGbML.gearShiftingNeeded = 0 	
		if self.mrGbMB.motor ~= nil then
			mrGearboxMogliMotor.copyRuntimeValues( self.mrGbML.motor, self.mrGbMB.motor )
			self.motor = self.mrGbMB.motor
		end
		if self.mrGbMB.dcShuttle then
			self.mrGbMB.dcShuttle = false
			self.driveControl.shuttle.isActive = true
			if self.mrGbMS.ReverseActive then
				self.driveControl.shuttle.direction = -1
			else
				self.driveControl.shuttle.direction = 1
			end
		end
	end
	
	if not ( new ) and ( self.mrGbMB.soundPitchScale ~= nil or self.mrGbMB.soundRunPitchScale ~= nil ) then
		self.motorSoundPitchScale        = self.mrGbMB.soundPitchScale     
		self.motorSoundPitchMax          = self.mrGbMB.soundPitchMax       
		self.motorSoundRunPitchScale	   = self.mrGbMB.soundRunPitchScale  
		self.motorSoundRunPitchMax       = self.mrGbMB.soundRunPitchMax    
		self.motorRun2PitchMax           = self.mrGbMB.soundRun2PitchMax    
		self.sampleMotor.volume          = self.mrGbMB.soundVolume         
		self.sampleMotorRun.volume       = self.mrGbMB.soundRunVolume      
		self.sampleMotor.pitchOffset     = self.mrGbMB.soundPitchOffset    
		self.sampleMotorRun.pitchOffset  = self.mrGbMB.soundRunPitchOffset 
		self.sampleMotorRun2.pitchOffset = self.mrGbMB.soundRun2PitchOffset
	end 
end 

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetWarningText
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetWarningText( old, new, noEventSend )
	self.mrGbMS.WarningText  = new
  self.mrGbML.warningTimer = g_currentMission.time + 2000
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetInfoText
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetInfoText( old, new, noEventSend )
	self.mrGbMS.InfoText  = new
  self.mrGbML.infoTimer = g_currentMission.time + 2000
end

--**********************************************************************************************************	
-- mrGearboxMogli:mrGbMOnSetManualClutch
--**********************************************************************************************************	
function mrGearboxMogli:mrGbMOnSetManualClutch( old, new, noEventSend )
	self.mrGbMS.ManualClutch     = new
  self.mrGbML.manualClutchTime = g_currentMission.time
end

--**********************************************************************************************************	
-- mrGearboxMogli:newUpdateWheelsPhysics
--**********************************************************************************************************	
function mrGearboxMogli:newUpdateWheelsPhysics( superFunc, dt, currentSpeed, acc, doHandbrake, requiredDriveMode, ... )
	if self.mrGbMS == nil or not ( self.mrGbMS.IsOn ) or self.motor ~= self.mrGbML.motor then		
		return superFunc( self, dt, currentSpeed, acc, doHandbrake, requiredDriveMode, ... )
	end
	
	local acceleration        = acc
	local accelerationPedal   = 0
	local brakePedal          = 0
	local brakeLights         = false

	if self.steeringEnabled then
	-- driveControl and GPS
		if      g_currentMission.driveControl ~= nil 
				and g_currentMission.driveControl.useModules ~= nil
				and self.driveControl ~= nil then
					
			if      g_currentMission.driveControl.useModules.shuttle
					and self.driveControl.shuttle ~= nil
					and self.driveControl.shuttle.isActive then
				acceleration = -self.axisForward
			end
				
			if      g_currentMission.driveControl.useModules.handBrake
					and self.driveControl.handBrake ~= nil 
					and self.driveControl.handBrake.isActive then
				acceleration = -self.axisForward
				doHandbrake  = true
			end
		end
	elseif doHandbrake  then
		doHandbrake  = false
		if     self.mrGbML.aiBrake == nil then
			self.mrGbML.aiBrake = 0
		elseif self.mrGbML.aiBrake > -1   then
			self.mrGbML.aiBrake = math.max( self.mrGbML.aiBrake - 0.001 * dt, -1 )
		end
		self.motor.speedLimitS = 0
		acceleration = self.mrGbML.aiBrake
	elseif acc < -0.001 then
		acceleration        = -acc
		self.mrGbML.aiBrake = 0
		self:mrGbMSetReverseActive( true )
		self:mrGbMSetNeutralActive( false )
	elseif acc >  0.001 then
		acceleration        = acc
		self.mrGbML.aiBrake = 0
		self:mrGbMSetReverseActive( false )
		self:mrGbMSetNeutralActive( false )
	else
		acceleration        = 0
		self.mrGbML.aiBrake = 0
	end
	
	-- blow off ventil
	if      not ( self.motor.noTorque )
			and acceleration                   > 0.5 
			and ( self.motor.lastMotorRpm      > self.mrGbMS.IdleRpm + mrGearboxMogliGlobals.blowOffVentilRpmRatio * ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) 
				 or g_currentMission.time        < self.mrGbML.blowOffVentilTime1 )
			and g_currentMission.time          > self.mrGbML.blowOffVentilTime0 then
		self.mrGbML.blowOffVentilTime1 = g_currentMission.time + mrGearboxMogli.blowOffVentilTime1
		self.mrGbML.blowOffVentilTime2 = -1
	end			

	--if self.mrGbMS.PlayBOVRpm > 0 and self.motor.lastMotorRpm < self.mrGbMS.PlayBOVRpm and self.mrGbMS.PlayBOV2 and self.mrGbMS.BlowOffVentilVolume > 0 then
	if      ( self.motor.noTorque or acceleration < 0.001 )
			and g_currentMission.time         < self.mrGbML.blowOffVentilTime1 then
		if     self.mrGbML.blowOffVentilTime2 < 0 then
			self.mrGbML.blowOffVentilTime2 = g_currentMission.time + mrGearboxMogli.blowOffVentilTime2
		elseif g_currentMission.time > self.mrGbML.blowOffVentilTime2 then
			self.mrGbML.blowOffVentilTime1 = 0
			self.mrGbML.blowOffVentilTime2 = -1
			self.mrGbML.blowOffVentilTime0 = g_currentMission.time + mrGearboxMogli.blowOffVentilTime0
			self.mrGbMS.BlowOffVentilPlay  = false
			self:mrGbMSetState( "BlowOffVentilPlay", true )
		end
	end
	
	if self.mrGbMS.ReverseActive then
		self.GPSmovingDirection    = -1
		self.GPSmovingDirectionCnt = 40
	else
		self.GPSmovingDirection    =  1
		self.GPSmovingDirectionCnt = 40
	end	
		
	self.motor:updateMotorRpm(dt)	
	
	if     doHandbrake or self.mrGbMS.NeutralActive or not ( self.isMotorStarted ) then
		-- hand brake
		if math.abs(self.rotatedTime) < 0.01 or self.articulatedAxis == nil then
			brakePedal = 1
		end
	elseif acceleration < -0.001 then
		-- braking 
		brakePedal  = -acceleration
		brakeLights = true		
	elseif acceleration < 0.001 then
		-- just rolling 
		if currentSpeed < self.mrGbMB.motor.lowBrakeForceSpeedLimit then
			if math.abs(self.rotatedTime) < 0.01 or self.articulatedAxis == nil then
				brakePedal = 1
			end
		elseif self.motor.nonClampedMotorRpm > self.motor.idleRpm then
		-- motor brake depends on gear speed and RPM
			brakePedal = math.min( self.mrGbMS.RealMotorBrakeFx * mrGearboxMogli.brakeFxSpeed * ( self.motor.nonClampedMotorRpm - self.motor.idleRpm ) / ( math.max( self.mrGbML.currentGearSpeed, 0.1 ) * ( self.motor.maxAllowedRpm - self.motor.idleRpm ) ), 1 )
		end
	elseif self.mrGbMS.ReverseActive then
		-- reverse 
		accelerationPedal          = -acceleration
	else
		-- forward 
		accelerationPedal          =  acceleration
	end
	
	if      brakePedal <= 0 
			and ( ( self.movingDirection * currentSpeed >  0.0003 and self.mrGbMS.ReverseActive )
			   or ( self.movingDirection * currentSpeed < -0.0003 and not ( self.mrGbMS.ReverseActive ) ) ) then
		-- wrong direction 
		brakePedal  = 1
		brakeLights = true
	end

	self.setBrakeLightsVisibility(self, brakeLights)
	self.setReverseLightsVisibility(self, self.mrGbMS.ReverseActive)
	mrGearboxMogliMotor.mrGbMUpdateGear( self.motor, acceleration )	

	local absAccelerationPedal = math.abs(accelerationPedal)
	local wheelDriveTorque = 0
	
	if self.motor.minThrottle > 0 then
		absAccelerationPedal = self.motor.minThrottle + ( 1 - self.motor.minThrottle ) * absAccelerationPedal
		if self.mrGbMS.ReverseActive then
			accelerationPedal = -absAccelerationPedal
		else
			accelerationPedal =  absAccelerationPedal
		end		
	end		

	if next(self.differentials) ~= nil and self.motorizedNode ~= nil then
		local torque      = self.motor:getTorque(accelerationPedal, false)
		local maxRpm      = self.motor:getCurMaxRpm()
		local ratio       = self.motor:getGearRatio()		
		local ratioFactor = mrGearboxMogliMotor.getGearRatioFactor( self.motor )
		local maxRotSpeed = maxRpm * mrGearboxMogli.factorpi30 * ratioFactor
		
		setVehicleProps(self.motorizedNode, torque, maxRotSpeed, ratio, self.motor.maxClutchTorque * math.min( 1, self.motor.clutchPercent * 10 ))
		
		if self.mrGbML.debugTimer ~= nil and g_currentMission.time < self.mrGbML.debugTimer then
			print(string.format("%4.0f Nm, %4.0f U/min, %4.0f U/min, %4.0f U/min, %2.2f km/h %2.2f km/h, %3.1f, %3.1f, %3.1f, %3.0f%%, %d",
													torque*1000, 
													self.motor.nonClampedMotorRpm,
													self.motor.maxPossibleRpm,
													maxRotSpeed, 
													maxRotSpeed * 3.6 / math.max( ratio, 1 ),
													self.lastSpeedReal * self.movingDirection * 3600,
													ratio,
													mrGearboxMogliMotor.getMogliGearRatio( self.motor ),
													ratioFactor,
													self.motor.clutchPercent * 100,
													self.mrGbML.gearShiftingNeeded))
		elseif self.mrGbML.debugTimer ~= nil then
			self.mrGbML.debugTimer = nil
			print("=======================================================================================")
		end
													
	else
		local numTouching = 0
		local numNotTouching = 0
		local numHandbrake = 0
		local axleSpeedSum = 0

		for _, wheel in pairs(self.wheels) do
			if requiredDriveMode <= wheel.driveMode then
				if doHandbrake and wheel.hasHandbrake then
					numHandbrake = numHandbrake + 1
				elseif wheel.hasGroundContact then
					numTouching = numTouching + 1
				else
					numNotTouching = numNotTouching + 1
				end
			end
		end

		if 0 < numTouching and 0.01 < absAccelerationPedal then
			local axisTorque, brakePedalMotor = WheelsUtil.getWheelTorque(self, accelerationPedal)

			if axisTorque ~= 0 then
				wheelDriveTorque = axisTorque/(numTouching + numNotTouching)
			else
				brakePedal = brakePedalMotor
			end
		end
	end

	doBrake = 0 < brakePedal

	for _, implement in pairs(self.attachedImplements) do
		if implement.object ~= nil then
			if doBrake then
				implement.object:onBrake(brakePedal)
			else
				implement.object:onReleaseBrake()
			end
		end
	end
	
	for _, wheel in pairs(self.wheels) do
		WheelsUtil.updateWheelPhysics(self, wheel, doHandbrake, wheelDriveTorque, brakePedal, requiredDriveMode, dt)
	end

	return 
end

--**********************************************************************************************************	
-- mrGearboxMogli:gearSpeedToRatio
--**********************************************************************************************************	
function mrGearboxMogli:gearSpeedToRatio( gearSpeed )
	if gearSpeed > mrGearboxMogli.eps then 
		return math.min( self.mrGbMS.RatedRpm / ( gearSpeed * mrGearboxMogli.factor30pi ), mrGearboxMogli.huge )
	else
		return mrGearboxMogli.huge 
	end
end




--**********************************************************************************************************	
-- mrGearboxMogliMotor
--**********************************************************************************************************	

mrGearboxMogliMotor = {}
mrGearboxMogliMotor_mt = Class(mrGearboxMogliMotor)

setmetatable( mrGearboxMogliMotor, { __index = function (table, key) return VehicleMotor[key] end } )

--**********************************************************************************************************	
-- mrGearboxMogliMotor:new
--**********************************************************************************************************	
function mrGearboxMogliMotor:new( vehicle, motor )
	local self = {}

	setmetatable(self, mrGearboxMogliMotor_mt)

	self.vehicle          = vehicle
	self.original         = motor 
	
	self.idleRpm          = vehicle.mrGbMS.IdleRpm
	self.ratedRpm         = vehicle.mrGbMS.RatedRpm
	self.torqueCurve      = AnimCurve:new( motor.torqueCurve.interpolator, motor.torqueCurve.interpolatorDegree )
	
	if vehicle.mrGbMS.Engine.maxTorque > 0 then
		--print("initializing motor with new torque curve")
		for _,k in pairs(vehicle.mrGbMS.Engine.torqueValues) do
			self.torqueCurve:addKeyframe( k )	
		end
		
		self.maxTorqueRpm   = vehicle.mrGbMS.Engine.maxTorqueRpm
		self.maxMotorTorque = vehicle.mrGbMS.Engine.maxTorque
		self.stallRpm       = math.max( self.idleRpm  - mrGearboxMogli.rpmMinus, vehicle.mrGbMS.Engine.minRpm )
		self.maxAllowedRpm  = vehicle.mrGbMS.Engine.maxRpm
		
		local tvMax2 = 0
		local vvMax2 = 0
		for _,k in pairs(self.torqueCurve.keyframes) do
			if vvMax2 < k.v then
				vvMax2 = k.v
				tvMax2 = k.time
			end
		end
	else
		local zeroTorqueRpm = 0.5*motor.minRpm
		local idleTorque    = motor.torqueCurve:get(motor.minRpm) --/ self.vehicle.mrGbMS.TransmissionEfficiency
		self.torqueCurve:addKeyframe( {v=0.1*idleTorque, time=0} )
		self.torqueCurve:addKeyframe( {v=0.9*idleTorque, time=zeroTorqueRpm} )
		local vMax  = 0
		local tMax  = motor.maxRpm
		local tvMax = 0
		local vvMax = 0
		for _,k in pairs(motor.torqueCurve.keyframes) do
			if k.time > zeroTorqueRpm then 
				local kv = k.v --/ self.vehicle.mrGbMS.TransmissionEfficiency
				local kt = k.time
				
				if vvMax < k.v then
					vvMax = k.v
					tvMax = k.time
				end
				
				vMax = kv
				tMax = kt
				
				self.torqueCurve:addKeyframe( {v=kv, time=kt} )				
			end
		end		

		if vMax > 0 then
			self.torqueCurve:addKeyframe( {v=0.9*vMax, time=tMax + 25} )
			self.torqueCurve:addKeyframe( {v=0.5*vMax, time=tMax + 50} )
			self.torqueCurve:addKeyframe( {v=0.1*vMax, time=tMax + 75} )
			self.torqueCurve:addKeyframe( {v=0, time=tMax + 100} )
			tMax = tMax + 100
		end
		self.maxTorqueRpm   = tvMax	
		self.maxMotorTorque = self.torqueCurve:getMaximum()
		self.stallRpm       = math.max( self.idleRpm  - mrGearboxMogli.rpmMinus, 0 )
		self.maxAllowedRpm  = self.ratedRpm + mrGearboxMogli.rpmPlus
	end
	
	self.rpmPowerCurve = AnimCurve:new( motor.torqueCurve.interpolator, motor.torqueCurve.interpolatorDegree )
	
	self.maxPower = self.idleRpm * self.torqueCurve:get( self.idleRpm ) 		
	self.rpmPowerCurve:addKeyframe( {v=self.idleRpm,  time=0} )				
	self.rpmPowerCurve:addKeyframe( {v=self.idleRpm+1,time=self.maxPower} )				
	for _,k in pairs(self.torqueCurve.keyframes) do
		local p = k.v*k.time
		if self.maxPower < p then
			self.maxPower = p
			self.rpmPowerCurve:addKeyframe( {v=k.time, time=self.maxPower} )				
		end
	end
	
	if vehicle.mrGbMS.Hydrostatic then
		self.hydroEff = AnimCurve:new( linearInterpolator1 )
		local ktime
		for _,k in pairs(vehicle.mrGbMS.HydrostaticEfficiency) do
			--if ktime == nil then
			--	self.hydroEff:addKeyframe( { time = k.time-mrGearboxMogli.eps, v = 0 } )
			--end
			ktime = k.time
			self.hydroEff:addKeyframe( k )
		end
		--self.hydroEff:addKeyframe( { time = ktime+mrGearboxMogli.eps, v = 0 } )
	end
	
	self.ptoRpm                  = vehicle.mrGbMS.PtoRpm
	
	if vehicle.mrGbML.modifySound then
		self.minRpm                = self.stallRpm
		self.maxRpm                = self.maxAllowedRpm
	else
		self.minRpm                = motor.minRpm
		self.maxRpm                = motor.maxRpm
	end

	mrGearboxMogliMotor.copyRuntimeValues( motor, self )
	
	self.minRequiredRpm          = self.idleRpm
	self.maxClutchTorque         = motor.maxClutchTorque
	self.brakeForce              = motor.brakeForce
	self.gear                    = 0
	self.gearRatio               = 0
	self.forwardGearRatios       = motor.forwardGearRatio
	self.backwardGearRatios      = motor.backwardGearRatio
	self.minForwardGearRatio     = motor.minForwardGearRatio
	self.maxForwardGearRatio     = motor.maxForwardGearRatio
	self.minBackwardGearRatio    = motor.minBackwardGearRatio
	self.maxBackwardGearRatio    = motor.maxBackwardGearRatio
	self.rpmFadeOutRange         = motor.rpmFadeOutRange
	self.clutchRpm               = 0
	self.motorLoad               = 0
	self.requiredWheelTorque     = 0

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
	self.lowBrakeForceScale      = vehicle.mrGbMS.RealMotorBrakeFx --motor.lowBrakeForceScale
	self.lowBrakeForceSpeedLimit = 0 -- motor.lowBrakeForceSpeedLimit
		
	self.maxPossibleRpm          = self.ratedRpm
	self.wheelRpm                = 0
	self.currentRpmS             = 0
	self.noTransmission          = true
	self.noTorque                = true
	self.clutchPercent           = 0
	self.minThrottle             = 0.3
	self.minThrottleS            = 0.3
	self.lastMotorRpmS           = motor.nonClampedMotorRpm
	self.prevNonClampedMotorRpm  = motor.nonClampedMotorRpm
	self.lastMotorTorque         = 0
	self.lastTransTorque         = 0
	self.neededPtoTorque         = 0
	self.lastPtoTorque           = 0
	self.lastLostTorque          = 0
	self.lastCurMaxRpm           = self.ratedRpm
	self.motorLoadS              = 0
	self.requestedPower          = 0
	self.maxRpmIncrease          = 0
	self.tickDt                  = 0
	self.absWheelSpeedRpm        = 0
	self.hydrostaticFactor       = self.vehicle.mrGbMS.HydrostaticMin
	self.autoClutchPercent       = 0
	
	if mrGearboxMogli.rpmIncPerGearSpeed then
		self.rpmIncFactor  	       = vehicle.mrGbMS.RpmIncFactor * math.sqrt( math.abs( mrGearboxMogli.gearSpeedToRatio( vehicle, vehicle.mrGbML.currentGearSpeed ) ) )
	else
		self.rpmIncFactor  	       = vehicle.mrGbMS.RpmIncFactor 
	end
	
	return self
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor.copyRuntimeValues
--**********************************************************************************************************	
function mrGearboxMogliMotor.copyRuntimeValues( motorFrom, motorTo )

	motorTo.nonClampedMotorRpm      = motorFrom.nonClampedMotorRpm 
	motorTo.clutchRpm               = motorFrom.clutchRpm          
	motorTo.motorLoad               = motorFrom.motorLoad          
	motorTo.requiredWheelTorque     = motorFrom.requiredWheelTorque
	motorTo.lastMotorRpm            = motorFrom.lastMotorRpm       
	motorTo.gear                    = motorFrom.gear               
	motorTo.gearRatio               = motorFrom.gearRatio          
	motorTo.rpmLimit                = motorFrom.rpmLimit 
	motorTo.speedLimit              = motorFrom.speedLimit

end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:getMogliGearRatio
--**********************************************************************************************************	
function mrGearboxMogliMotor:getMogliGearRatio()
	local ratio = mrGearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbML.currentGearSpeed )
	if self.hydroEff ~= nil then
		if self.hydrostaticFactor < mrGearboxMogli.eps then
			ratio = mrGearboxMogli.maxHydroGearRatio
		else
			ratio = math.min( ratio / self.hydrostaticFactor, mrGearboxMogli.maxHydroGearRatio )
		end
	end
	return ratio
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:getGearRatioFactor
--**********************************************************************************************************	
function mrGearboxMogliMotor:getGearRatioFactor()

	local gearRatio = mrGearboxMogli.maxGearRatio 
	if not ( self.noTransmission ) then
		gearRatio = self:getMogliGearRatio()
	end
	
	return math.max( 1, math.abs( self.gearRatio / math.max( gearRatio, 1 ) ) )
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:getCurMaxRpm
--**********************************************************************************************************	
function mrGearboxMogliMotor:getCurMaxRpm()

	-- self.lastCurMaxRpm: max RPM with speed limit 
  -- maxRpm:             max RPM with speed limit AND maxPossibleRpm

	if     mrGearboxMogli.limitRpmIncrease == "M"  then
		self.lastCurMaxRpm = self.maxPossibleRpm
	elseif self.noTransmission or self.noTorque    then
		self.lastCurMaxRpm = mrGearboxMogli.huge
	elseif self.hydroEff ~= nil                    then
		self.lastCurMaxRpm = self.maxAllowedRpm
	elseif self.clutchPercent < self.vehicle.mrGbMS.MinClutchPercent + 0.75 * ( self.vehicle.mrGbMS.MaxClutchPercent - self.vehicle.mrGbMS.MinClutchPercent ) then
		self.lastCurMaxRpm = mrGearboxMogli.huge
	elseif mrGearboxMogli.limitRpmIncrease == "TM" then
		self.lastCurMaxRpm = self.maxPossibleRpm + self.maxRpmIncrease
	elseif mrGearboxMogli.limitRpmIncrease == "H" then
		self.lastCurMaxRpm = mrGearboxMogli.huge
	else
		self.lastCurMaxRpm = self.maxAllowedRpm
	end
	
	if not ( self.noTransmission ) then		
		local speedLimit = self.speedLimit*0.277778
		if self.vehicle.mrGbMS.SpeedLimiter then
			speedLimit = math.min( speedLimit, self.vehicle.cruiseControl.speed*0.277778 )
		end
		
		if self.vehicle.cruiseControl.state > 0 then
			if self.speedLimitS == nil then 
				self.speedLimitS = math.abs( self.vehicle.lastSpeedReal*1000 )
			end
			-- limit speed limiter change to given km/h per second
			local limitMax   =  0.000277778 * self.vehicle.mrGbMS.AccelerateToLimit * self.tickDt
			local decToLimit = self.vehicle.mrGbMS.DecelerateToLimit
			---- avoid to much brake force => limit to 7 km/h/s if difference below 2.77778 km/h difference
			if self.speedLimitS - 1 < speedLimit and speedLimit < self.speedLimitS and decToLimit > 7 then
				decToLimit     = 7
			end
			local limitMin   = -0.000277778 * decToLimit * self.tickDt
			self.speedLimitS = self.speedLimitS + Utils.clamp( math.min( speedLimit, self.maxForwardSpeed ) - self.speedLimitS, limitMin, limitMax )
			if speedLimit < self.maxForwardSpeed or self.speedLimitS < 0.97 * self.maxForwardSpeed then
				speedLimit = self.speedLimitS
			end
		else
			self.speedLimitS = math.abs( self.vehicle.lastSpeedReal*1000 )
		end
		  
		if self.vehicle.mrGbMS.MaxSpeedLimiter then
			if self.vehicle.mrGbMS.ReverseActive then
				speedLimit = math.min( speedLimit, self.maxBackwardSpeed )
			else
				speedLimit = math.min( speedLimit, self.maxForwardSpeed )
			end
		end
							
		if self.hydroEff ~= nil then
			speedLimit = math.min(speedLimit, self.vehicle.mrGbML.currentGearSpeed * self.vehicle.mrGbMS.HydrostaticMax )
		end

		self.lastCurMaxRpm = math.min( self.lastCurMaxRpm, speedLimit * mrGearboxMogli.factor30pi * self:getMogliGearRatio())
		self.lastCurMaxRpm = math.min( self.lastCurMaxRpm, self.rpmLimit )	
	end
			
	return self.lastCurMaxRpm
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:getBestGear
--**********************************************************************************************************	
function mrGearboxMogliMotor:getBestGear( acceleration, wheelSpeedRpm, accSafeMotorRpm, requiredWheelTorque, requiredMotorRpm )

	local bestGearRatio = mrGearboxMogliMotor.getMogliGearRatio( self )
	local maxGearRatio  = math.max( mrGearboxMogli.maxGearRatio, bestGearRatio )
		
	if self.noTorque then
		acc = 0
	end
	
	if self.clutchPercent < 1 then	  
		local absWheelSpeedRpm = wheelSpeedRpm
		local acc              = math.abs( acceleration )
		
		if self.vehicle.mrGbMS.ReverseActive then
			absWheelSpeedRpm = -wheelSpeedRpm
		end
		absWheelSpeedRpm = math.max( absWheelSpeedRpm, mrGearboxMogli.eps )
		
		local factor1 = self.ratedRpm / math.max( absWheelSpeedRpm * bestGearRatio, mrGearboxMogli.eps )
		local factor2 = self.clutchPercent + ( 1 - self.clutchPercent ) * acc * factor1
		bestGearRatio = math.min( bestGearRatio * math.max( factor2, 1 ), maxGearRatio )
		
		if bestGearRatio * absWheelSpeedRpm < self.idleRpm then
			bestGearRatio = math.min( self.idleRpm / absWheelSpeedRpm, maxGearRatio )
		end
	end

	if self.vehicle.mrGbMS.ReverseActive then
		return -1, -bestGearRatio
	else
		return 1, bestGearRatio
	end
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:getTorque
--**********************************************************************************************************	
function mrGearboxMogliMotor:getTorque( acceleration, limitRpm )

	self.lastMotorTorque  = 0
	self.lastTransTorque  = 0
	self.lastPtoTorque    = 0
	self.lastLostTorque   = 0	
	self.neededPtoTorque  = 0	
	
	local brakePedal      = 0
	local torque          = self.torqueCurve:get( math.max( self.stallRpm, self.nonClampedMotorRpm ) )
	if self.nonClampedMotorRpm > self.maxAllowedRpm then
		torque              = 0
	end
	--self.lastMotorTorque  = torque

	if self.nonClampedMotorRpm > self.maxPossibleRpm and self.clutchPercent > 0.8 * self.vehicle.mrGbMS.MaxClutchPercent then
		-- no torque if > maxPossibleRpm + 20		
		local limitMaxRpm = Utils.clamp( self.maxRpmIncrease, 1, 20 )
		if self.nonClampedMotorRpm > self.maxPossibleRpm + limitMaxRpm then
			torque = 0
		else
			torque = math.min( torque, self.lastMotorTorque * Utils.clamp( 1 - ( self.nonClampedMotorRpm - self.maxPossibleRpm ) / limitMaxRpm, 0, 1 ) )
		end
		torque   = math.max( 0.01 * self.lastMotorTorque, torque )

		if self.vehicle.mrGbML.debugTimer ~= nil and g_currentMission.time < self.vehicle.mrGbML.debugTimer then
			print(string.format("Reducing torque: %4.0f > %4.0f", self.nonClampedMotorRpm, self.maxPossibleRpm))
		end		
	end

	self.lastMotorTorque  = torque
	
	if     self.noTorque 
			or self.noTransmission then
		torque         = 0
		self.torqueS   = nil
	else
		torque         = torque * math.abs(acceleration)
		if      mrGearboxMogli.limitRpmIncrease ~= "M"
				and mrGearboxMogli.limitRpmIncrease ~= "TM" then
			if self.torqueS == nil or mrGearboxMogli.smoothTorque > 0.999 then
				self.torqueS = torque 
			else
				self.torqueS = self.torqueS + mrGearboxMogli.smoothTorque * ( torque - self.torqueS )
				torque       = math.min( torque, self.torqueS )	
			end
		end
	end
	
	if limitRpm then
		local maxRpm = self.maxAllowedRpm
		local rpmFadeOutRange = self.rpmFadeOutRange * mrGearboxMogliMotor.getMogliGearRatio( self )
		local fadeStartRpm = maxRpm - rpmFadeOutRange

		if fadeStartRpm < self.nonClampedMotorRpm then
			if maxRpm < self.nonClampedMotorRpm then
				brakePedal = math.min((self.nonClampedMotorRpm - maxRpm)/rpmFadeOutRange, 1)
				torque = 0
			else
				torque = torque*math.max((fadeStartRpm - self.nonClampedMotorRpm)/rpmFadeOutRange, 0)
			end
		end
	end

	local e = 0.94
	if     self.hydroEff ~= nil   then
		e = self.hydroEff:get( self.hydrostaticFactor )
	elseif self.clutchPercent < 1 then
		e = Utils.clamp( self.vehicle.mrGbMS.TransmissionEfficiency - self.vehicle.mrGbMS.TransmissionEfficiencyDec * ( 1 - self.clutchPercent ), 0, 1 )
	else
		e = self.vehicle.mrGbMS.TransmissionEfficiency
	end
	
	self.lastLostTorque  = torque * ( 1 - e )
	torque               = torque - self.lastLostTorque
	
	local pt = PowerConsumer.getTotalConsumedPtoTorque(self.vehicle) 
	if pt > 0 then
	  pt = pt / self.ptoMotorRpmRatio
		mt = e * self.torqueCurve:get( Utils.clamp( self.lastMotorRpm, self.idleRpm, self.ratedRpm ) ) 
		
		if mt < pt and not ( self.noTransmission or self.noTorque ) then
		--print(string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ).." @RPM: "..tostring(self.lastMotorRpm))
			if self.ptoWarningTimer == nil then
				self.ptoWarningTimer = g_currentMission.time
			end
			if      g_currentMission.time > self.ptoWarningTimer + 4000 then
				self.ptoWarningTimer = nil
				if      self.vehicle.dCcheckModule ~= nil
						and self.vehicle:dCcheckModule("manMotorStart") 
						and self.vehicle.driveControl ~= nil
						and self.vehicle.driveControl.manMotorStart ~= nil then
					self.vehicle.driveControl.manMotorStart.isMotorStarted = false
					self.vehicle:mrGbMSetState( "WarningText", string.format("Motor stopped due to missing power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ))
				else
					self.vehicle:mrGbMSetNeutralActive(true, false, true)
					self.vehicle:mrGbMSetState( "WarningText", string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ))
				end
			elseif  g_currentMission.time > self.ptoWarningTimer + 2000 then
				self.vehicle:mrGbMSetState( "WarningText", string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ))
			end			
		elseif self.ptoWarningTimer ~= nil then
			self.ptoWarningTimer = nil
		end
		
		self.lastPtoTorque = math.min( pt, torque )
		torque             = torque - self.lastPtoTorque
	elseif self.ptoWarningTimer ~= nil then
		self.ptoWarningTimer = nil
	end
	
	if torque < 0 then
		self.lastLostTorque = self.lastLostTorque + torque 
		torque              = 0
	end
	
	self.lastTransTorque = torque
	
	return torque, brakePedal
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:updateMotorRpm
--**********************************************************************************************************	
function mrGearboxMogliMotor:updateMotorRpm( dt )
	local vehicle = self.vehicle
	self.tickDt                  = dt
	self.prevNonClampedMotorRpm  = self.nonClampedMotorRpm

	if next(vehicle.differentials) ~= nil and vehicle.motorizedNode ~= nil then
		self.nonClampedMotorRpm, self.clutchRpm, self.motorLoad = getMotorRotationSpeed(vehicle.motorizedNode)
		self.nonClampedMotorRpm  = self.nonClampedMotorRpm * mrGearboxMogli.factor30pi
		self.clutchRpm           = self.clutchRpm          * mrGearboxMogli.factor30pi
		self.requiredWheelTorque = self.maxMotorTorque*math.abs(self.gearRatio)
	else
		local gearRatio = self.getGearRatio(self)

		if vehicle.isServer then
			self.nonClampedMotorRpm = math.max(WheelsUtil.computeRpmFromWheels(vehicle)*gearRatio, 0)
		else
			self.nonClampedMotorRpm = math.max(WheelsUtil.computeRpmFromSpeed(vehicle)*gearRatio, 0)
		end
	end
	
	if self.noTransmission then
		self.lastMotorRpm = Utils.clamp( self.currentRpmS, self.minRequiredRpm, self.ratedRpm )
	else
		self.lastMotorRpm = math.min( self.nonClampedMotorRpm, self.maxPossibleRpm )
	end
	self.lastMotorRpmS = self.lastMotorRpmS + mrGearboxMogli.smoothRpm * ( self.lastMotorRpm - self.lastMotorRpmS )
	
	if vehicle.mrGbML.modifySound then
		self.minRpm = self.stallRpm
		self.maxRpm = self.maxAllowedRpm
	else          
		self.minRpm = self.original.minRpm
		self.maxRpm = self.original.maxRpm
	end

	if     not ( self.vehicle.isMotorStarted ) then
		self.lastMotorRpm = 0
	elseif self.lastMotorRpm > self.maxRpm then
		self.lastMotorRpm = self.maxRpm
	elseif self.lastMotorRpm < self.minRpm then
		self.lastMotorRpm = self.minRpm
	end
	
	--if g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime and self.vehicle.mrGbML.gearShiftingEffect then
	----print("sound effect on")
	--	self.lastMotorRpm = self.minRpm
	--end
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:updateGear
--**********************************************************************************************************	
function mrGearboxMogliMotor:updateGear( acc )
	-- this method is not used here, it is just for convenience 
	if self.vehicle.mrGbMS.ReverseActive then
		acceleration = -acc
	else
		acceleration = acc
	end

	return mrGearboxMogliMotor.mrGbMUpdateGear( self, acceleration )
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:mrGbMUpdateGear
--**********************************************************************************************************	
function mrGearboxMogliMotor:mrGbMUpdateGear( accelerationPedal )

	local acceleration = math.max( accelerationPedal, 0 )
	
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
	local gearRatio          = mrGearboxMogliMotor.getMogliGearRatio( self )
	local lastMaxPossibleRpm = Utils.getNoNil( self.maxPossibleRpm, self.maxAllowedRpm )
	local wheelSpeedRpm      = 0
	local lastNoTransmission = self.noTransmission
	local lastNoTorque       = self.noTorque 
	self.noTransmission = false
	self.noTorque       = not ( self.vehicle.isMotorStarted )
	self.maxPossibleRpm = self.maxAllowedRpm

	if math.abs(self.gearRatio) < 0.001 then
		wheelSpeedRpm  = self.vehicle.lastSpeedReal*self.vehicle.movingDirection*1000*mrGearboxMogli.factor30pi
	else
		wheelSpeedRpm  = self.clutchRpm/self.gearRatio
	end
--**********************************************************************************************************	

	self.ptoMotorRpmRatio  = self.original.ptoMotorRpmRatio
	currentSpeed           = 3.6 * wheelSpeedRpm * mrGearboxMogli.factorpi30 --3600 * self.vehicle.lastSpeedReal * self.vehicle.movingDirection
					
--**********************************************************************************************************	
	-- current RPM and power
	self.minRequiredRpm = self.idleRpm -- + self.vehicle.mrGbMS.HandThrottle * ( self.ratedRpm - self.idleRpm - 100 )
	local ptoOn = false
	local ptoTq = PowerConsumer.getTotalConsumedPtoTorque(self.vehicle)
	if ptoTq > 0 then
		ptoOn = true
		local ptoRpm = PowerConsumer.getMaxPtoRpm( self.vehicle )
		
		local p0 = ptoRpm * self.original.ptoMotorRpmRatio
		local p1 = self.ptoRpm
		self.ptoMotorRpmRatio = p1 / ptoRpm
		
		if p1 < p0 then
			for i=0,4 do
				p1 = self.ptoRpm + 0.25 * i * ( p0 - self.ptoRpm )
				self.ptoMotorRpmRatio = p1 / ptoRpm
				
				if 0.94 * self.ptoMotorRpmRatio * self.torqueCurve:get( p1 ) > ptoTq then
					break
				end
			end
		end
		if self.minRequiredRpm < p1 then
			self.minRequiredRpm = p1
		end
	end
	
	local minRpmReduced = math.max( self.stallRpm + 20, self.minRequiredRpm * mrGearboxMogli.rpmReduction )		

	lastWheelRpm = self.wheelRpm 
	if math.abs( gearRatio - math.abs(self.gearRatio) ) < mrGearboxMogli.eps then
		self.wheelRpm = self.clutchRpm
	elseif math.abs(self.gearRatio) < 0.001 then
		self.wheelRpm = wheelSpeedRpm * gearRatio
		if self.vehicle.mrGbMS.ReverseActive then self.wheelRpm = -self.wheelRpm end
	else
		self.wheelRpm = self.clutchRpm * gearRatio / math.abs(self.gearRatio)
	end 
	
	local absWheelSpeedRpm
	absWheelSpeedRpm = wheelSpeedRpm
	if self.vehicle.mrGbMS.ReverseActive then absWheelSpeedRpm = -absWheelSpeedRpm end
	if absWheelSpeedRpm < 0            then absWheelSpeedRpm = 0 end
	self.absWheelSpeedRpm = self.absWheelSpeedRpm + mrGearboxMogli.smoothSpeed * ( absWheelSpeedRpm - self.absWheelSpeedRpm )
	
	if not ( self.noTransmission ) then
		self.currentRpmS  = self.lastMotorRpmS --self.currentRpmS + 0.1 * ( self.nonClampedMotorRpm - self.currentRpmS )
	end

	local acc             = math.max( self.minThrottle, accelerationPedal )
	local requestedTorque = self.motorLoad + self.neededPtoTorque + self.lastLostTorque
	local currentPower    = requestedTorque * math.max( self.prevNonClampedMotorRpm, self.idleRpm )
	local requestedPower  = currentPower
	--if self.motorLoad + mrGearboxMogli.eps >= self.lastTransTorque then -- + 0.01 * self.maxPower
	--requestedPower      = math.max( requestedPower,  accelerationPedal * self.maxPower )
	local rp = self.maxPower * 0.5 * ( acc + Utils.clamp( ( lastMaxPossibleRpm - self.nonClampedMotorRpm ) / Utils.clamp( self.maxRpmIncrease, 1, 100 ), 0, 1 ) )
	local rp = self.maxPower * acc --Utils.clamp( ( lastMaxPossibleRpm - self.nonClampedMotorRpm ) / Utils.clamp( self.maxRpmIncrease, 1, 100 ), 0, acc )
	if rp > requestedPower then
		if     self.nonClampedMotorRpm > self.lastCurMaxRpm then
			requestedPower = currentPower
		elseif self.nonClampedMotorRpm + 10 > self.lastCurMaxRpm then
			requestedPower = currentPower + Utils.clamp( 0.1 * ( self.lastCurMaxRpm - self.nonClampedMotorRpm ), 0, 1 ) * ( rp - currentPower )
		else
			requestedPower = rp
		end
	end
	
	local motorLoad = 0
	
	if     not ( self.vehicle.isMotorStarted )          then
		motorLoad = 0
	elseif self.vehicle.mrGbML.gearShiftingNeeded > 0   then
		motorLoad = self.motorLoadS
	elseif lastNoTransmission or lastNoTorque           then
		motorLoad = acc
	--elseif self.lastMotorTorque <  mrGearboxMogli.eps   then
	--	motorLoad = acc
	else
		motorLoad = Utils.clamp( requestedTorque / self.lastMotorTorque, 0, 1 )
	end

	if self.requestedPower1 == nil then
		self.requestedPower1 = requestedPower
	  self.requestedPower2 = requestedPower
	  self.requestedPower  = requestedPower
	else
		self.requestedPower1 = self.requestedPower1 + mrGearboxMogli.smooth1 * ( requestedPower - self.requestedPower1 )
		self.requestedPower2 = self.requestedPower2 + mrGearboxMogli.smooth2 * ( requestedPower - self.requestedPower2 )
		self.requestedPower  = math.max( self.requestedPower1, self.requestedPower2 )
	end
	
	if self.motorLoadS1 == nil then
		self.motorLoadS1     = motorLoad
		self.motorLoadS2     = motorLoad
		self.motorLoadS	     = motorLoad
	else
		self.motorLoadS1     = self.motorLoadS1 + mrGearboxMogli.smooth1 * ( motorLoad - self.motorLoadS1 )		
		self.motorLoadS2     = self.motorLoadS2 + mrGearboxMogli.smooth2 * ( motorLoad - self.motorLoadS2 )		
		self.motorLoadS	     = math.max( self.motorLoadS1, self.motorLoadS2 )		
  end		
	
	local targetRpm = Utils.clamp( self.rpmPowerCurve:get( requestedPower ), self.minRequiredRpm, self.ratedRpm )
	
	if ptoOn and self.hydroEff ~= nil then
		targetRpm = self.minRequiredRpm
	end

	if self.targetRpm1 == nil then
		self.targetRpm1 = targetRpm 
		self.targetRpm2 = targetRpm 
		self.targetRpm  = targetRpm 
	else
		self.targetRpm1 = self.targetRpm1 + mrGearboxMogli.smooth1 * ( targetRpm - self.targetRpm1 )		
		self.targetRpm2 = self.targetRpm2 + mrGearboxMogli.smooth2 * ( targetRpm - self.targetRpm2 )		
		self.targetRpm  = math.max( self.targetRpm1, self.targetRpm2 )		
  end			
	
	-- clutch calculations...
	local clutchMode = 0 -- no clutch calculation
		
--**********************************************************************************************************		
	if     self.vehicle.mrGbMS.NeutralActive
			or self.vehicle.mrGbMS.G27Mode == 1
			or not ( self.vehicle.isMotorStarted )
			or ( self.lastMotorRpmS                   <= self.idleRpm + 100
			 and accelerationPedal                    < -0.001
			 and self.vehicle.cruiseControl.state     == 0 ) then
	-- neutral or braking
		if math.abs( currentSpeed ) < 0.3 then
			if self.vehicle.mrGbMS.AutoStartStop then
				self.vehicle:mrGbMSetNeutralActive( true ) 
			end
		end
					
		if self.vehicle.mrGbML.gearShiftingNeeded > 0 then
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
		elseif self.vehicle.mrGbML.gearShiftingNeeded < 0 then
			self.vehicle:mrGbMDoGearShift() 
			self.vehicle.mrGbML.gearShiftingNeeded = 0 
		end

		if self.vehicle.mrGbMS.AutoClutch then
			self.autoClutchPercent  = math.max( 0, self.autoClutchPercent -self.tickDt/self.vehicle.mrGbMS.ClutchTimeDec ) 
		end
		self.noTransmission = true
		self.minThrottle    = self.vehicle.mrGbMS.HandThrottle
		self.minThrottleS   = self.vehicle.mrGbMS.HandThrottle
								
		if acc > 0 then
			self.currentRpmS = Utils.clamp( self.lastMotorRpm + 5 * acc * self.tickDt * self.rpmIncFactor, self.minRequiredRpm, self.stallRpm + acc * ( self.maxAllowedRpm - self.stallRpm ) ) 
		else
			self.currentRpmS = Utils.clamp( self.lastMotorRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, self.minRequiredRpm, self.maxAllowedRpm )
		end
--**********************************************************************************************************		
	else
--**********************************************************************************************************		
		-- acceleration for idle/minimum rpm
		if lastNoTransmission then
			self.minThrottle  = 0.3
			self.minThrottleS = 0.3
		elseif self.nonClampedMotorRpm < minRpmReduced then
			self.minThrottle  = 1
			self.minThrottleS = 1
		else
			local delta       = self.nonClampedMotorRpm - self.minRequiredRpm 
			self.minThrottle  = self.motorLoadS * ( self.minRequiredRpm - 0.7 * self.idleRpm ) / ( self.ratedRpm - 0.7 * self.idleRpm ) - Utils.clamp( 0.005 * delta, -0.1, 0.1 )
			self.minThrottle  = Utils.clamp( self.minThrottle, self.vehicle.mrGbMS.HandThrottle, 1 ) 
			self.minThrottleS = self.minThrottleS + 0.1 * ( self.minThrottle - self.minThrottleS )
			if self.nonClampedMotorRpm < self.minRequiredRpm then
				self.minThrottle  = math.max( 0.3, self.minThrottle )
				self.minThrottleS = math.max( 0.3, self.minThrottleS )
			end
		end
		
		
		if self.vehicle.mrGbML.gearShiftingNeeded > 0 then
	--**********************************************************************************************************		
	-- during gear shift with automatic clutch
			if self.vehicle.mrGbML.gearShiftingNeeded == 2 and g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime then	
				if self.lastMotorRpmS > 0.9 * self.ratedRpm then
					self.vehicle.mrGbML.gearShiftingNeeded  = 3
				end
				self.currentRpmS = Utils.clamp( self.lastMotorRpm + self.tickDt * self.rpmIncFactor, self.minRequiredRpm, self.maxAllowedRpm ) 
			else               
				self.currentRpmS = Utils.clamp( self.lastMotorRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, self.minRequiredRpm, self.maxAllowedRpm )
				self.noTorque    = true
			end

			self.maxPossibleRpm = self.currentRpmS
			
			if g_currentMission.time >= self.vehicle.mrGbML.gearShiftingTime then
				if self.vehicle.mrGbML.gearShiftingNeeded < 2 then	
					self.vehicle:mrGbMDoGearShift() 
				end 
				self.vehicle.mrGbML.gearShiftingNeeded = 0 
				self.maxPossibleRpm          = self.maxAllowedRpm 
				self.noTransmission          = false
				self.noTorque                = false
				self.vehicle.mrGbML.manualClutchTime = 0
				clutchMode                   = 2 -- increase from mrGbML.autoClutchPercent to targetClutchPercent
				if self.vehicle.mrGbMS.OpenRpm < self.idleRpm then
					self.targetRpm    = math.max( self.targetRpm, self.vehicle.mrGbMS.CloseRpm )
				else
					self.targetRpm    = math.max( self.targetRpm, self.vehicle.mrGbMS.OpenRpm )
				end
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
			self.prevNonClampedMotorRpm = self.maxAllowedRpm
			
		elseif self.vehicle.mrGbML.gearShiftingNeeded < 0 then
	--**********************************************************************************************************		
	-- during gear shift with manual clutch
			self.noTransmission  = true
			
			if     self.vehicle.mrGbML.gearShiftingNeeded == -1 then	
				if self.vehicle.mrGbMS.ManualClutch > self.vehicle.mrGbMS.MaxClutchPercent - 0.1 then
					self.vehicle.mrGbML.gearShiftingNeeded = -2
				end
			elseif self.vehicle.mrGbML.gearShiftingNeeded == -2 then	
				if self.vehicle.mrGbMS.ManualClutch < self.vehicle.mrGbMS.MinClutchPercent + 0.1 then
					self.vehicle:mrGbMDoGearShift() 
					self.vehicle.mrGbML.gearShiftingNeeded = 0						
				end
			end
			
			if acc > 0 then
				self.currentRpmS = Utils.clamp( self.lastMotorRpm + 5 * acc * self.tickDt * self.rpmIncFactor, self.minRequiredRpm, self.stallRpm + acc * ( self.maxAllowedRpm - self.stallRpm ) ) 
			else
				self.currentRpmS = Utils.clamp( self.lastMotorRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, self.minRequiredRpm, self.maxAllowedRpm )
			end
		elseif not ( self.vehicle.mrGbMS.AutoClutch ) and self.vehicle.mrGbMS.ManualClutch < self.vehicle.mrGbMS.MinClutchPercent + 0.1 then
			self.noTransmission  = true
		
			if acc > 0 then
				self.currentRpmS = Utils.clamp( self.lastMotorRpm + 5 * acc * self.tickDt * self.rpmIncFactor, self.minRequiredRpm, self.stallRpm + acc * ( self.maxAllowedRpm - self.stallRpm ) ) 
			else
				self.currentRpmS = Utils.clamp( self.lastMotorRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, self.minRequiredRpm, self.maxAllowedRpm )
			end
		else
	--**********************************************************************************************************		
	-- normal drive with gear and clutch
			self.noTransmission = false
			clutchMode          = 1 -- calculate clutch percent respecting inc/dec time ms
			--self.lowBrakeForceScale = self.vehicle.mrGbMS.RealMotorBrakeFx
			
			
	--**********************************************************************************************************		
	-- hydrostatic drive without clutch => control target RPM instead of clutch percent
			if      self.hydroEff ~= nil
					and self.vehicle.mrGbMS.HydrostaticLaunch
					and ( not ( self.vehicle.mrGbMS.AutoClutch  )
						 or ( self.vehicle.mrGbML.manualClutchTime <= g_currentMission.time 
							and g_currentMission.time < self.vehicle.mrGbML.manualClutchTime + 5000 ) ) then
				local f = self.vehicle.mrGbMS.ManualClutch
				if self.vehicle.mrGbMS.AutoClutch then
					local f0 = self.targetRpm / self.ratedRpm 
					f = f + ( g_currentMission.time - self.vehicle.mrGbML.manualClutchTime  ) / 5000 * ( f0 - self.vehicle.mrGbMS.ManualClutch  )
				end
				self.targetRpm = self.ratedRpm - f * ( self.ratedRpm - self.idleRpm )
				ptoOn          = true --use exact target RPM
			end
			
	--**********************************************************************************************************		
	-- automatic shifting				
			if self.vehicle.mrGbMS.Automatic then
				if      accelerationPedal                  <  mrGearboxMogli.accDeadZone
						and ( self.vehicle.mrGbMS.CurrentRange   <  self.vehicle.mrGbMS.LaunchRange   
							 or ( self.vehicle.mrGbMS.CurrentRange == self.vehicle.mrGbMS.LaunchRange   
								and self.vehicle.mrGbMS.CurrentGear  <= self.vehicle.mrGbMS.LaunchGear ) ) then
					-- no down shift for small gears w/o throttle
					self.vehicle.mrGbML.autoShiftDownTimer = math.max( self.vehicle.mrGbML.autoShiftDownTimer, g_currentMission.time + self.vehicle.mrGbMS.AutoShiftTimeoutLong )
				elseif  accelerationPedal              >  0.5
						and self.autoClutchPercent >= self.vehicle.mrGbMS.MaxClutchPercent
						and self.lastMotorRpmS         >  self.ratedRpm         
						and self.lastMotorRpmS         >  0.5 * ( self.ratedRpm + self.maxAllowedRpm ) then
					-- allow immediate gear up if rpm is too high
					self.vehicle.mrGbML.autoShiftUpTimer   = 0
				elseif  self.autoClutchPercent <  self.vehicle.mrGbMS.AutoShiftMinClutch then
					-- no gear up if clutch is open
					self.vehicle.mrGbML.autoShiftUpTimer   = math.max( self.vehicle.mrGbML.autoShiftUpTimer, g_currentMission.time + self.vehicle.mrGbMS.AutoShiftTimeoutShort )
				end
			
				if     g_currentMission.time > self.vehicle.mrGbML.autoShiftDownTimer 
						or g_currentMission.time > self.vehicle.mrGbML.autoShiftUpTimer then
										
					local gearMaxSpeed = self.vehicle.mrGbMS.Ranges2[self.vehicle.mrGbMS.CurrentRange2].ratio
														 * self.vehicle.mrGbMS.GlobalRatioFactor
					if self.vehicle.mrGbMS.ReverseActive then	
						gearMaxSpeed = gearMaxSpeed * self.vehicle.mrGbMS.ReverseRatio 
					end
					
					local maxGear 
					local currentGear
					local launchGear
					local maxTimeToShift
					if     not ( self.vehicle.mrGbMS.AutoShiftHl ) then
						currentGear    = self.vehicle.mrGbMS.CurrentGear 
						launchGear     = self.vehicle.mrGbMS.LaunchGear
						maxGear        = table.getn( self.vehicle.mrGbMS.Gears )
						maxTimeToShift = self.vehicle.mrGbMS.GearTimeToShiftGear
					elseif not ( self.vehicle.mrGbMS.AutoShiftGears ) then 
						currentGear    = self.vehicle.mrGbMS.CurrentRange
						launchGear     = self.vehicle.mrGbMS.LaunchRange
						maxGear        = table.getn( self.vehicle.mrGbMS.Ranges )
						maxTimeToShift = self.vehicle.mrGbMS.GearTimeToShiftHl
					else
						currentGear    = self.vehicle.mrGbMS.CurrentGear + table.getn( self.vehicle.mrGbMS.Gears ) * ( self.vehicle.mrGbMS.CurrentRange - 1 )
						launchGear     = self.vehicle.mrGbMS.LaunchGear  + table.getn( self.vehicle.mrGbMS.Gears ) * ( self.vehicle.mrGbMS.LaunchRange  - 1 )
						maxGear        = table.getn( self.vehicle.mrGbMS.Gears ) * table.getn( self.vehicle.mrGbMS.Ranges )
						maxTimeToShift = math.max( self.vehicle.mrGbMS.GearTimeToShiftGear, self.vehicle.mrGbMS.GearTimeToShiftHl )
					end

					local iMin     = nil
					local iMax     = nil
					local tooSmall = false
					local tooBig   = false
					local bestSpd  = nil
					local bestSpd2 = nil
					local bestGear = currentGear 
					local lowRpm   = self.idleRpm 					
					local downRpm  = minRpmReduced
					local upRpm    = self.ratedRpm
					
					if self.vehicle.mrGbMS.AutoClutch and accelerationPedal > 0.5 then 
						local c = Utils.clamp( self.vehicle.mrGbMS.MinClutchPercent, 0.5, self.vehicle.mrGbMS.MaxClutchPercent  )
						lowRpm  = Utils.clamp( ( self.idleRpm - (1-c) * self.ratedRpm * accelerationPedal ) / c, 0, lowRpm )
					end
					if self.vehicle.mrGbMS.AutoShiftDownRpm ~= nil and self.vehicle.mrGbMS.AutoShiftDownRpm > downRpm then
						downRpm = self.vehicle.mrGbMS.AutoShiftDownRpm -- downRpm + self.motorLoadS * ( self.vehicle.mrGbMS.AutoShiftDownRpm - downRpm )
					end
					if self.vehicle.mrGbMS.AutoShiftUpRpm ~= nil and self.vehicle.mrGbMS.AutoShiftUpRpm < upRpm then
						upRpm  = self.vehicle.mrGbMS.AutoShiftUpRpm
					end
					
					if self.hydroEff ~= nil then
						upRpm   = math.min(  upRpm,self.targetRpm+100) * self.vehicle.mrGbMS.HydrostaticMax					
						downRpm = math.max(downRpm,self.targetRpm-100) * self.vehicle.mrGbMS.HydrostaticMin
					end
					
					for i = 1,maxGear do
					--if not ( self.vehicle.mrGbMS.AutoShiftGears and self.vehicle.mrGbMS.AutoShiftHl ) 
						if      maxTimeToShift > mrGearboxMogliGlobals.maxTimeToSkipGear
								and iMax ~= nil 						
								and iMax > launchGear 
								and iMax > currentGear then
							-- only shift up by one gear/range
							break
						end
						
						local i2g, i2r     = mrGearboxMogliMotor.splitGear( self, i )							
						local isValidEntry = true
						
						if isValidEntry and self.vehicle.mrGbMS.AutoShiftGears and mrGearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Gears[i2g], i2g, i2r ) then
							isValidEntry = false
						end
						if isValidEntry and self.vehicle.mrGbMS.AutoShiftHl    and mrGearboxMogli.mrGbMIsNotValidEntry( self.vehicle, self.vehicle.mrGbMS.Ranges[i2r], i2g, i2r ) then
							isValidEntry = false
						end
						if isValidEntry and i < currentGear and g_currentMission.time <= self.vehicle.mrGbML.autoShiftDownTimer then
							isValidEntry = false
						end
						if isValidEntry and i > currentGear and g_currentMission.time <= self.vehicle.mrGbML.autoShiftUpTimer then
							isValidEntry = false
						end
																	
						if isValidEntry then

							if iMin == nil then
								iMin = i
							end							
							iMax = i
							
							
							local spd = gearMaxSpeed * self.vehicle.mrGbMS.Gears[i2g].speed * self.vehicle.mrGbMS.Ranges[i2r].ratio						
							local rpm = self.absWheelSpeedRpm * mrGearboxMogli.gearSpeedToRatio( self.vehicle, spd )
							--if i ~= self.vehicle.mrGbMS.CurrentGear and self.vehicle.mrGbMS.GearTimeToShiftGear >= 0 then
							--	rpm = rpm - math.min( 100, acc * math.max( ( 1 - self.motorLoadS ) * mrGearboxMogliGlobals.minTimeToShift, self.vehicle.mrGbMS.GearTimeToShiftGear ) * self.rpmIncFactor )
							--end
							
							if     rpm > upRpm then
								tooSmall = true
							elseif rpm < lowRpm then
								tooBig   = true
							elseif self.hydroEff ~= nil then
								--test = rpm
								test = self.hydroEff:get( Utils.clamp( rpm / self.targetRpm, self.vehicle.mrGbMS.HydrostaticMin, self.vehicle.mrGbMS.HydrostaticMax ) )
								if bestSpd == nil or bestSpd < test then
									bestSpd  = test
									bestGear = i
								end
							else
							-- gear is possible 
								
								local test      = mrGearboxMogli.huge
								local test2     = mrGearboxMogli.huge
								local drueckung = self.targetRpm - 0.07 * self.ratedRpm
								local power     = rpm * self.torqueCurve:get( rpm )
								
								if     rpm < drueckung      then
									test = drueckung - rpm
								elseif rpm > self.targetRpm then
									test = rpm - self.targetRpm
								elseif i == currentGear      then
									test = -1
								else
									test = 0
								end
								
								if i ~= currentGear and power < currentPower then
									test2 = mrGearboxMogli.huge
								else
									test2 = math.abs( self.requestedPower - power )
								end
																
								if bestSpd == nil or bestSpd > test or ( bestSpd == test and bestSpd2 >= test2 ) then
									bestSpd  = test
									bestSpd2 = test2
									bestGear = i
								end	
							end
							
							if i >= launchGear and downRpm > lowRpm then
								lowRpm = downRpm
							end							
						end
					end
					
					if bestSpd == nil then
						if     tooBig   then
							bestGear = iMin						
						elseif tooSmall then
							bestGear = iMax
						end
					end
					
					if currentGear ~= bestGear then
						local i2g, i2r = mrGearboxMogliMotor.splitGear( self, bestGear )
						--print(tostring(currentGear).." / "..tostring(launchGear).." / "..tostring(maxGear).." => "..tostring(bestGear).." ("..tostring(i2g)..", "..tostring(i2r)..") "..tostring(bestSpd).." "..tostring(iMin)..".."..tostring(iMax))
						self.vehicle:mrGbMSetCurrentGear( i2g ) 
						self.vehicle:mrGbMSetCurrentRange( i2r ) 
						clutchMode                   = 2
						self.vehicle.mrGbML.manualClutchTime = 0
					end										
				end
			end
		end
		
	--**********************************************************************************************************		
	-- hydrostatic drive
		if     self.hydroEff ~= nil and not ( self.vehicle.mrGbMS.HydrostaticLaunch ) and self.clutchPercent + mrGearboxMogli.eps < self.vehicle.mrGbMS.MaxClutchPercent then
			self.hydrostaticFactor = self.vehicle.mrGbMS.HydrostaticStart  --self.vehicle.mrGbMS.HydrostaticMin
		elseif self.hydroEff ~= nil then

			local r = mrGearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbML.currentGearSpeed )
			local w = absWheelSpeedRpm * r
			local e = 0
			local h = self.hydrostaticFactor
			local m = self.ratedRpm
		
			if clutchMode > 1 and self.vehicle.mrGbML.beforeShiftRpm ~= nil then
				self.hydrostaticFactor = Utils.clamp( w / self.vehicle.mrGbML.beforeShiftRpm, self.vehicle.mrGbMS.HydrostaticMin, self.vehicle.mrGbMS.HydrostaticMax )  
				self.vehicle.mrGbML.beforeShiftRpm = nil
				self.vehicle.mrGbML.afterShiftRpm  = nil
			end
			
			if self.vehicle.mrGbMS.AutoShiftUpRpm ~= nil and self.vehicle.mrGbMS.AutoShiftUpRpm < m then
				m = self.vehicle.mrGbMS.AutoShiftUpRpm 
			end
			m = math.min(m,self.targetRpm + mrGearboxMogli.hydroEffDiff)
			
			local hMin = self.vehicle.mrGbMS.HydrostaticStart + self.motorLoadS * ( self.vehicle.mrGbMS.HydrostaticMin - self.vehicle.mrGbMS.HydrostaticStart )
			if self.vehicle.mrGbMS.Automatic and self.vehicle.mrGbMS.AutoShiftGears and self.vehicle.mrGbMS.CurrentGear > 1 then
				hMin = self.vehicle.mrGbMS.HydrostaticMin
			elseif ptoOn then
				hMin = self.vehicle.mrGbMS.HydrostaticMin
			end
			
			if self.vehicle.mrGbMS.HydrostaticMaxRpm ~= nil and w > self.vehicle.mrGbMS.HydrostaticMaxRpm * self.vehicle.mrGbMS.HydrostaticMax then
				h = self.vehicle.mrGbMS.HydrostaticMax				
			elseif w > m * self.vehicle.mrGbMS.HydrostaticMax then
				h = self.vehicle.mrGbMS.HydrostaticMax				
			elseif ptoOn or accelerationPedal < 0.001 then
				h = Utils.clamp( w / self.targetRpm, hMin, self.vehicle.mrGbMS.HydrostaticMax )  
			else
				for t = math.max(self.idleRpm,self.targetRpm-mrGearboxMogli.hydroEffDiff), m, 10 do
					local h2 = Utils.clamp( w / t, hMin, self.vehicle.mrGbMS.HydrostaticMax )  
					local e2 = math.min( self.hydroEff:get( h2 ) * t * self.torqueCurve:get( t ), requestedPower * self.vehicle.mrGbMS.TransmissionEfficiency )
					if e2 > e + mrGearboxMogli.eps then
						e = e2
						h = h2
					end
				end
			end
			
			local d = self.tickDt / self.vehicle.mrGbMS.HydrostaticIncTime
			self.hydrostaticFactor = self.hydrostaticFactor + Utils.clamp( mrGearboxMogli.smoothHydro * ( h - self.hydrostaticFactor ), -d, d )
			self.hydrostaticFactor = math.max( self.hydrostaticFactor, absWheelSpeedRpm * r / self.maxAllowedRpm ) 
			self.hydrostaticFactor = math.max( self.hydrostaticFactor, r / mrGearboxMogli.maxGearRatio )

			clutchMode = 0
			self.autoClutchPercent = self.vehicle.mrGbMS.MaxClutchPercent			
		end		
	end
	
	--**********************************************************************************************************		
	-- clutch				
	if clutchMode > 0 and not ( self.noTransmission ) then
		if self.vehicle.mrGbMS.AutoClutch then 
			local openRpm   = math.max( self.vehicle.mrGbMS.OpenRpm, self.stallRpm + 20 )
			local closeRpm  = self.vehicle.mrGbMS.CloseRpm
			local targetRpm = self.targetRpm
			
			if clutchMode > 1 then
				openRpm        = self.ratedRpm 
				closeRpm       = self.ratedRpm 
				if self.vehicle.mrGbML.afterShiftRpm ~= nil then
					targetRpm = self.vehicle.mrGbML.afterShiftRpm
				end
			else
				local refRpm   = math.max( self.lastMotorRpmS, self.idleRpm )
			
				if ptoOn or accelerationPedal > 0.5 or self.vehicle.mrGbMS.OpenRpm >= self.idleRpm then
				-- open the clutch only if needed: PTO, acceleration or torque converter
					openRpm = minRpmReduced
				
					if self.vehicle.mrGbMS.OpenRpm > minRpmReduced then
						openRpm = minRpmReduced + self.motorLoadS * ( self.vehicle.mrGbMS.OpenRpm - minRpmReduced )
					end
				end					
				if self.vehicle.mrGbMS.CloseRpm > refRpm then
					closeRpm = refRpm + self.motorLoadS * ( self.vehicle.mrGbMS.CloseRpm - refRpm )
				end
			
				if ptoOn then
				-- PTO: ensure that the rpm is not too low
					closeRpm = math.max( minRpmReduced, closeRpm )
				end
			end
		
			local targetClutchPercent = mrGearboxMogliMotor.getClutchPercent( self, self.lastMotorRpmS, targetRpm, openRpm, closeRpm, accelerationPedal )
			
			if      clutchMode > 1 then
			-- after shift
				self.autoClutchPercent = Utils.clamp( targetClutchPercent, Utils.getNoNil( self.vehicle.mrGbML.afterShiftClutch, self.vehicle.mrGbMS.MinClutchPercent ), self.vehicle.mrGbMS.MaxClutchPercent ) 
			elseif  self.tickDt > self.vehicle.mrGbMS.ClutchTimeDec
					and self.tickDt > self.vehicle.mrGbMS.ClutchTimeInc then
				self.autoClutchPercent = Utils.clamp( targetClutchPercent, 0, self.vehicle.mrGbMS.MaxClutchPercent ) 
			elseif targetClutchPercent < self.autoClutchPercent then
				self.autoClutchPercent = math.max( 0, self.autoClutchPercent - math.min( self.tickDt/self.vehicle.mrGbMS.ClutchTimeDec, self.autoClutchPercent - targetClutchPercent ) ) 
			else
				local factor
				if self.wheelRpm < closeRpm then
					factor = self.tickDt/self.vehicle.mrGbMS.ClutchTimeInc
				else
					factor = self.tickDt/self.vehicle.mrGbMS.ClutchShiftTime
				end
				self.autoClutchPercent = math.min( self.vehicle.mrGbMS.MaxClutchPercent, self.autoClutchPercent + math.min( factor, targetClutchPercent - self.autoClutchPercent ) ) 
			end 
		else
			self.autoClutchPercent   = self.vehicle.mrGbMS.MaxClutchPercent
		end 					
	end 					
	
	if     self.vehicle.mrGbMS.HydrostaticLaunch then
		self.clutchPercent = 1 --mrGearboxMogliMotor.getClutchPercent( self, self.lastMotorRpmS, targetRpm, minRpmReduced, self.minRequiredRpm, accelerationPedal )
	elseif self.vehicle.mrGbMS.AutoClutch then
		if self.vehicle.mrGbML.manualClutchTime <= g_currentMission.time and g_currentMission.time < self.vehicle.mrGbML.manualClutchTime + 5000 then
			self.clutchPercent = self.vehicle.mrGbMS.ManualClutch + ( g_currentMission.time - self.vehicle.mrGbML.manualClutchTime  ) / 5000 * ( self.autoClutchPercent - self.vehicle.mrGbMS.ManualClutch  )
		else
			self.clutchPercent = self.autoClutchPercent
		end
	else
		self.clutchPercent = self.vehicle.mrGbMS.ManualClutch
	end

	self.maxRpmIncrease = self.maxAllowedRpm - self.lastMotorRpmS 
	if self.clutchPercent < mrGearboxMogli.minClutchPercent then
		self.noTransmission = true
	elseif self.noTransmission then
		self.clutchPercent  = 0
	elseif self.hydroEff == nil then
		self.maxRpmIncrease = self.tickDt * self.rpmIncFactor

		local m = self.nonClampedMotorRpm
		if m > lastMaxPossibleRpm then
			m = lastMaxPossibleRpm
		end
		if m < self.wheelRpm then
			m = self.wheelRpm
		end
		if m < self.idleRpm then
			m = self.idleRpm 
		end
		self.maxPossibleRpm = m + self.maxRpmIncrease
		if self.vehicle.mrGbMS.MaxSpeedLimiter and self.maxPossibleRpm > self.maxAllowedRpm then
			self.maxPossibleRpm = self.maxAllowedRpm
		end
		if self.vehicle.mrGbML.afterShiftRpm ~= nil and self.vehicle.mrGbML.gearShiftingEffect then
			if self.maxPossibleRpm > self.vehicle.mrGbML.afterShiftRpm then
				self.maxPossibleRpm               = self.vehicle.mrGbML.afterShiftRpm
				self.vehicle.mrGbML.afterShiftRpm = self.vehicle.mrGbML.afterShiftRpm + self.maxRpmIncrease 
			else
				self.vehicle.mrGbML.afterShiftRpm = nil
			end
		end
	end

	self.vehicle.mrGbML.afterShiftClutch = nil
	self.vehicle.mrGbML.beforeShiftRpm   = nil
	
--**********************************************************************************************************	
-- VehicleMotor.updateGear II
	self.gear, self.gearRatio = self.getBestGear(self, acceleration, wheelSpeedRpm, self.maxAllowedRpm*0.1, requiredWheelTorque, self.minRequiredRpm )
--**********************************************************************************************************	
end

--**********************************************************************************************************	
-- mrGearboxMogliMotor:getClutchPercent
--**********************************************************************************************************	
function mrGearboxMogliMotor:getClutchPercent( currrentRpm, targetRpm, openRpm, closeRpm, accelerationPedal )

	--if currrentRpm   <= self.stallRpm then
	--	return self.vehicle.mrGbMS.MinClutchPercent
	--end
	if self.wheelRpm >= closeRpm then
		return self.vehicle.mrGbMS.MaxClutchPercent 					
	end	
	
	local minPercent, clutchPercent = self.vehicle.mrGbMS.MinClutchPercent, self.vehicle.mrGbMS.MaxClutchPercent 			

	local target   = Utils.clamp( targetRpm, self.idleRpm, closeRpm ) 
	local throttle = math.max( self.stallRpm, (self.minThrottle + ( 1 - self.minThrottle ) * math.max(0,accelerationPedal) ) * self.ratedRpm )
	
	if currrentRpm > openRpm and minPercent < self.autoClutchPercent then
	-- keep clutch closed above open rpm ratio
		minPercent = self.autoClutchPercent
	end 
	
	local eps       = 0.01 * ( clutchPercent - minPercent )
	local delta     = ( throttle - self.wheelRpm ) * eps
	local clutchRpm = (1 - clutchPercent) * throttle + clutchPercent *  self.wheelRpm
	local diff      = math.abs( target - clutchRpm )
	for i=0,100 do
		clutchRpm = clutchRpm + delta
		if math.abs( target - clutchRpm ) < diff then
			diff          = math.abs( target - clutchRpm )
			clutchPercent = self.vehicle.mrGbMS.MaxClutchPercent - i * eps
		end
	end
		
	return clutchPercent 
end

function mrGearboxMogliMotor:splitGear( i ) 
	local i2g, i2r
	if     not ( self.vehicle.mrGbMS.AutoShiftHl ) then
		i2g = i
		i2r = self.vehicle.mrGbMS.CurrentRange
	elseif not ( self.vehicle.mrGbMS.AutoShiftGears ) then 
		i2g = self.vehicle.mrGbMS.CurrentGear
		i2r = i
	else
		i2r = 1
		i2g = i
		local m = table.getn( self.vehicle.mrGbMS.Gears )
		while i2g > m do
			i2r = i2r + 1
			i2g = i2g - m
		end
		if i2g + m * ( i2r-1 ) ~= i then
			print("ERROR in GEARBOX: "..tostring(i).." ~= "..tostring(i2g).." + "..tostring(m).." * ( "..tostring(i2r).." -1 )")
		end
	end
	return i2g,i2r
end

function mrGearboxMogli:newGetLastSpeed( superFunc, ... )
	if  	 self.isServer 
			or self.mrGbMS == nil 
			or self.mrGbML == nil 
			or not ( self.mrGbMS.IsOn ) then	
		return superFunc( self, ... )
	end
	
	local speed = superFunc( self, ... )
	if self.mrGbML.lastSpeed == nil then
		self.mrGbML.lastSpeed = speed
	else
		self.mrGbML.lastSpeed = self.mrGbML.lastSpeed + mrGearboxMogli.smoothLastSpeed * ( speed - self.mrGbML.lastSpeed )
	end
	
	return self.mrGbML.lastSpeed
end	

function mrGearboxMogli:newSetHudValue( superFunc, hud, value, maxValue, ... )
	if     self.mrGbMS        == nil 
			or self.mrGbMB        == nil 
			or not ( self.mrGbMS.IsOn ) 
			or self.mrGbMB.motor  == nil 
			or self.indoorHud     == nil 
			or self.indoorHud.rpm == nil 
			or self.indoorHud.rpm ~= hud 
			or hud.animName       == nil then
		return superFunc( self, hud, value, maxValue, ... )
	end

	return superFunc( self, hud, value, self.mrGbMB.motor.maxRpm, ... )
end
	
WheelsUtil.updateWheelsPhysics = Utils.overwrittenFunction( WheelsUtil.updateWheelsPhysics,mrGearboxMogli.newUpdateWheelsPhysics )
Vehicle.getLastSpeed = Utils.overwrittenFunction( Vehicle.getLastSpeed, mrGearboxMogli.newGetLastSpeed )
IndoorHud.setHudValue = Utils.overwrittenFunction( IndoorHud.setHudValue, mrGearboxMogli.newSetHudValue )

--oldClamp = Utils.clamp
--function Utils.clamp(value, minVal, maxVal)
--	if value == nil or minVal == nil or maxVal == nil then
--		mrGearboxMogli.debugEvent( nil, value, minVal, maxVal )
--		return 0
--	end
--	return oldClamp(value, minVal, maxVal)
--end


function mrGearboxMogli:mrGbMTestNet()
	local vehicle = self
	if g_currentMission ~= nil and g_currentMission.controlledVehicle ~= nil then
		vehicle = g_currentMission.controlledVehicle
	end
	
	mrGearboxMogli.mogliBase20TestStream( vehicle )
end

function mrGearboxMogli:mrGbMTestAPI()
	local vehicle = self
	if g_currentMission ~= nil and g_currentMission.controlledVehicle ~= nil then
		vehicle = g_currentMission.controlledVehicle
	end
	
	print("vehicle.mrGbMGetClutchPercent: "..tostring(vehicle:mrGbMGetClutchPercent())) 
	print("vehicle.mrGbMGetTargetRPM    : "..tostring(vehicle:mrGbMGetTargetRPM())) 
	print("vehicle.mrGbMGetMotorLoad    : "..tostring(vehicle:mrGbMGetMotorLoad())) 
	print("vehicle.mrGbMGetUsedPower    : "..tostring(vehicle:mrGbMGetUsedPower())) 
	print("vehicle.mrGbMGetModeText     : "..tostring(vehicle:mrGbMGetModeText())) 
	print("vehicle.mrGbMGetGearText     : "..tostring(vehicle:mrGbMGetGearText())) 
	print("vehicle.mrGbMGetIsOn         : "..tostring(vehicle:mrGbMGetIsOn())) 

	print("vehicle.mrGbMGetIsOnOff      : "..tostring(vehicle:mrGbMGetIsOnOff())) 
	print("vehicle.mrGbMGetCurrentGear  : "..tostring(vehicle:mrGbMGetCurrentGear())) 
	print("vehicle.mrGbMGetCurrentRange : "..tostring(vehicle:mrGbMGetCurrentRange())) 
	print("vehicle.mrGbMGetCurrentRange2: "..tostring(vehicle:mrGbMGetCurrentRange2())) 
	print("vehicle.mrGbMGetAutomatic    : "..tostring(vehicle:mrGbMGetAutomatic())) 
	print("vehicle.mrGbMGetNeutralActive: "..tostring(vehicle:mrGbMGetNeutralActive())) 
	print("vehicle.mrGbMGetReverseActive: "..tostring(vehicle:mrGbMGetReverseActive())) 
	print("vehicle.mrGbMGetSpeedLimiter : "..tostring(vehicle:mrGbMGetSpeedLimiter())) 
	print("vehicle.mrGbMGetHandThrottle : "..tostring(vehicle:mrGbMGetHandThrottle())) 
	print("vehicle.mrGbMGetAutoClutch   : "..tostring(vehicle:mrGbMGetAutoClutch())) 
	print("vehicle.mrGbMGetManualClutch : "..tostring(vehicle:mrGbMGetManualClutch())) 	
	print("vehicle.mrGbMGetAccelerateToLimit : "..tostring(vehicle:mrGbMGetAccelerateToLimit())) 	
	print("vehicle.mrGbMGetDecelerateToLimit : "..tostring(vehicle:mrGbMGetDecelerateToLimit())) 	

	print("vehicle.tempomatMogliGetSpeedLimit   : "..tostring(vehicle:tempomatMogliGetSpeedLimit())) 	
	print("vehicle.tempomatMogliGetSpeedLimit2  : "..tostring(vehicle:tempomatMogliGetSpeedLimit2())) 	
end

function mrGearboxMogli:mrGbMDebug()
	mrGearboxMogli.debugGearShift = not mrGearboxMogli.debugGearShift
	print("debugGearShift: "..tostring(mrGearboxMogli.debugGearShift))
end
end