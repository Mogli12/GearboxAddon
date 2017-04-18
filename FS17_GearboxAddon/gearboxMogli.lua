--***************************************************************
--
-- gearboxMogli
-- 
-- version 1.300 by mogli (biedens)
-- created at 2015/03/09
-- changed at 2015/06/15
--
--***************************************************************

local gearboxMogliVersion=1.500

-- allow modders to include this source file together with mogliBase.lua in their mods
if gearboxMogli == nil or gearboxMogli.version == nil or gearboxMogli.version < gearboxMogliVersion then

--***************************************************************
--mogliBase20.newClass( "gearboxMogli", "mrGbMS" )
if _G[g_currentModName..".mogliBase"] == nil then
	source(Utils.getFilename("mogliBase.lua", g_currentModDirectory))
end
_G[g_currentModName..".mogliBase"].newClass( "gearboxMogli", "mrGbMS" )
--***************************************************************

gearboxMogli.version              = gearboxMogliVersion
gearboxMogli.huge                 = 1E+9
gearboxMogli.eps                  = 1E-9
gearboxMogli.factor30pi           = 9.5492965855137201461330258023509
gearboxMogli.factorpi30           = 0.10471975511965977461542144610932
gearboxMogli.rpmRatedMinus        = 100 -- 100  -- min RPM at 900 RPM
gearboxMogli.rpmMinus             = 300 -- 100  -- min RPM at 900 RPM
gearboxMogli.rpmPlus              = 200  -- braking at 2350 RPM
gearboxMogli.minRpmInSpeedHudDelta=  500
gearboxMogli.maxRpmInSpeedHudDelta= 2500
gearboxMogli.ptoRpmFactor         = 0.900 -- 0.75 -- reduce PTO RPM; e.g. 1900 with PTO and 2200 rated RPM
gearboxMogli.ptoRpmFactorEco      = 2/3   -- 0.5  -- reduce PTO RPM in eco mode; e.g. 1600 with PTO and 2200 rated RPM
gearboxMogli.autoShiftRpmDiff     = 50
gearboxMogli.autoShiftPowerRatio  = 1.03
gearboxMogli.autoShiftMaxDeltaRpm = 1E-3
gearboxMogli.minClutchPercent     = 0.01
gearboxMogli.minClutchPercentStd  = 0.4
gearboxMogli.minClutchPercentTC   = 0.2
gearboxMogli.minClutchPercentTCL  = 0.2
gearboxMogli.maxClutchPercentTC   = 0.95
gearboxMogli.clutchLoopTimes      = 10
gearboxMogli.clutchLoopDelta      = 10
gearboxMogli.minHydrostaticFactor = 5e-3
gearboxMogli.maxGearRatio         = 37699.11184                     -- 0.01 km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.minGearRatio         = 1.508                           -- 250  km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.maxHydroGearRatio    = gearboxMogli.maxGearRatio / 100 -- 1.0  km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.maxManualGearRatio   = gearboxMogli.maxGearRatio / 20  -- 0.2  km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.brakeFxSpeed         = 2.5  -- m/s = 9 km/h
gearboxMogli.rpmReduction         = 0.85 -- 15% RPM reduction allowed e.g. 330 RPM for 2200 rated RPM 
gearboxMogli.maxPowerLimit        = 0.97 -- 97% max power is equal to max power
gearboxMogli.smoothLittle         = 0.2
gearboxMogli.smoothFast           = 0.12
gearboxMogli.smoothMedium         = 0.04
gearboxMogli.smoothSlow           = 0.015
gearboxMogli.hydroEffDiff         = 500
gearboxMogli.hydroEffDiffInc      = 0 --150
gearboxMogli.hydroEffMin          = 0.5
gearboxMogli.ptoRpmThrottleDiff   = 50
gearboxMogli.powerFactor0         = 0.1424083769633507853403141361257
gearboxMogli.fuelFactor           = 1/(830*60*60*1000)-- 830 g per liter per hour => liter per millisecond
gearboxMogli.accDeadZone          = 0.15
gearboxMogli.blowOffVentilTime0   = 1500
gearboxMogli.blowOffVentilTime1   = 1000
gearboxMogli.blowOffVentilTime2   = 100
gearboxMogli.debugGearShift       = false
gearboxMogli.globalsLoaded        = false
gearboxMogli.ptoSpeedLimitMin     = 2   / 3.6  -- minimal speed limit
gearboxMogli.ptoSpeedLimitIni     = 0.2 / 3.6  -- initial offset for ptoSpeedLimit 
gearboxMogli.ptoSpeedLimitOff     = 2.0 / 3.6  -- turn off ptoSpeedLimit 
gearboxMogli.ptoSpeedLimitDec     = 0.2 / 3600 -- brake 
gearboxMogli.ptoSpeedLimitInc     = 1.0 / 3600 -- accelerate by 2 km/h per second 
gearboxMogli.ptoSpeedLimitRatio   = 0.01
gearboxMogli.combineUseRealArea   = true
gearboxMogli.AIPowerShift         = "P"
gearboxMogli.AIGearboxOff         = "N"
gearboxMogli.AIAllAuto            = "A"
gearboxMogli.AIGearboxOn          = "Y"
gearboxMogli.kmhTOms              = 5 / 18
gearboxMogli.extraSpeedLimit      = 0.25
gearboxMogli.extraSpeedLimitMs    = 5 / 72
gearboxMogli.deltaLimitTimeMs     = 333
gearboxMogli.speedLimitBrake      = 2 / 3.6 -- m/s
gearboxMogli.speedLimitMode       = "B" -- "T"orque limit only / "M"ax RPM only / "B"oth
gearboxMogli.motorBrakeTime       = 250     
gearboxMogli.motorLoadExp         = 1.5
gearboxMogli.powerCurveFactor     = 0.95
gearboxMogli.gearShiftingNoThrottle = 178 -- just a big integer
gearboxMogli.trustClutchRpmTimer  = 0
gearboxMogli.brakeForceLimitRpm   = 25

gearboxMogliGlobals                       = {}
gearboxMogliGlobals.debugPrint            = false
gearboxMogliGlobals.transmissionEfficiency= 0.96
-- Giants is cheating: 0.86 * 0.88 = 0.7568 > 0.72 => torqueFactor = 0.86 * 0.88 / ( 0.72 * 0.94 )
gearboxMogliGlobals.torqueFactor          = 0.86 * 0.88 / ( 0.72 * gearboxMogliGlobals.transmissionEfficiency )  
gearboxMogliGlobals.blowOffVentilVol      = 0.14
gearboxMogliGlobals.drawTargetRpm         = false 
gearboxMogliGlobals.drawReqPower          = false
gearboxMogliGlobals.defaultOn             = true
gearboxMogliGlobals.noDisable             = false
gearboxMogliGlobals.disableManual         = false
gearboxMogliGlobals.blowOffVentilRpmRatio = 0.7
gearboxMogliGlobals.minTimeToShift			  = 1    -- ms
gearboxMogliGlobals.minTimeToShiftReverse = 252  -- ms
gearboxMogliGlobals.maxTimeToSkipGear  	  = 251  -- ms
gearboxMogliGlobals.autoShiftTimeoutLong  = 3000 -- ms
gearboxMogliGlobals.autoShiftTimeoutShort = 1500 -- ms -- let it go up to ratedRPM !!!
gearboxMogliGlobals.autoShiftTimeoutHydroL= 100  -- ms 
gearboxMogliGlobals.autoShiftTimeoutHydroS= 0    -- ms
gearboxMogliGlobals.shiftEffectTime			  = 251  -- ms
gearboxMogliGlobals.shiftTimeMsFactor     = 1
gearboxMogliGlobals.playGrindingSound     = true
gearboxMogliGlobals.defaultHudMode        = 1    -- 0: no HUD, 1: big HUD, 2: small HUD with gear name only
gearboxMogliGlobals.hudPositionX          = 0.84
gearboxMogliGlobals.hudPositionY          = 0.7
gearboxMogliGlobals.hudTextSize           = 0.02
gearboxMogliGlobals.hudTitleSize          = 0.03
gearboxMogliGlobals.hudBorder             = 0.005
gearboxMogliGlobals.hudWidth              = 0.15
gearboxMogliGlobals.stallWarningTime      = 250
gearboxMogliGlobals.stallMotorOffTime     = 1250
gearboxMogliGlobals.realFuelUsage         = true
gearboxMogliGlobals.idleFuelTorqueRatio   = 0.2
gearboxMogliGlobals.defaultLiterPerSqm    = 1.2  -- 1.2 l/m² for wheat
gearboxMogliGlobals.combineDefaultSpeed   = 10   -- km/h
gearboxMogliGlobals.combineDynamicRatio   = 0.6
gearboxMogliGlobals.combineDynamicChopper = 0.8
gearboxMogliGlobals.dtDeltaTargetFast     = 0.0005 -- 2 second 
gearboxMogliGlobals.dtDeltaTargetSlow     = 0.0002 -- 5 seconds
gearboxMogliGlobals.ddsDirectory          = "dds/"
gearboxMogliGlobals.initMotorOnLoad       = true
gearboxMogliGlobals.ptoSpeedLimit         = true
gearboxMogliGlobals.clutchExp             = 2.0
gearboxMogliGlobals.clutchFactor          = 1.2
gearboxMogliGlobals.grindingMinRpmDelta   = 200
gearboxMogliGlobals.grindingMaxRpmSound   = 600
gearboxMogliGlobals.grindingMaxRpmDelta   = gearboxMogli.huge
gearboxMogliGlobals.defaultEnableAI       = gearboxMogli.AIPowerShift
gearboxMogliGlobals.autoHold              = true
gearboxMogliGlobals.minAutoGearSpeed      = 1.0   -- 0.2777 -- m/s
gearboxMogliGlobals.minAbsSpeed           = 1.0   -- km/h
gearboxMogliGlobals.brakeNeutralTimeout   = 1000  -- ms
gearboxMogliGlobals.brakeNeutralLimit     = -0.3
gearboxMogliGlobals.DefaultRevUpMs0       = 2000  -- ms
gearboxMogliGlobals.DefaultRevUpMs1       = 2000  -- ms
gearboxMogliGlobals.DefaultRevDownMs      = 2000  -- ms
gearboxMogliGlobals.HydroSpeedIdleRedux   = 1e-3  -- 0.04  -- default reduce by 10 km/h per second => 0.4 km/h with const. RPM and w/o acc.
gearboxMogliGlobals.smoothGearRatio       = true  -- smooth gear ratio with hydrostatic drive
gearboxMogliGlobals.minClutchTimeManual   = 3000  -- ms; time from 0% to 100% for the digital manual clutch
gearboxMogliGlobals.momentOfInertiaBase   = 2     -- J in unit kg m^2; for a cylinder with mass m and radius r: J = 0.5 * m * r^2
gearboxMogliGlobals.momentOfInertia       = 4     -- J in unit kg m^2; for a cylinder with mass m and radius r: J = 0.5 * m * r^2
gearboxMogliGlobals.momentOfInertiaBaseH  = 1
gearboxMogliGlobals.momentOfInertiaH      = 1
gearboxMogliGlobals.inertiaToDampingRatio = 0.333
gearboxMogliGlobals.momentOfInertiaMin    = 1e-5  -- is already multiplied by 1e-3!!!
gearboxMogliGlobals.brakeForceRatio       = 0.03  -- tested, see issue #101
gearboxMogliGlobals.maxRpmThrottle        = 0.9
gearboxMogliGlobals.noSpeedMatching       = false -- option to disable speed matching for all vehicles 
gearboxMogliGlobals.autoStartStop         = false -- option to enable auto start stop for all vechiles

--**********************************************************************************************************	
-- gearboxMogli.prerequisitesPresent 7
--**********************************************************************************************************	
function gearboxMogli.prerequisitesPresent(specializations) 
	return true
end 

--**********************************************************************************************************	
-- gearboxMogli:load
--**********************************************************************************************************	
function gearboxMogli:load(savegame) 
	local key = "vehicle.gearboxMogli"
	if hasXMLProperty(self.xmlFile, key) then
		gearboxMogli.initFromXml(self,self.xmlFile,key,"vehicle",true)
	end
end

--**********************************************************************************************************	
-- gearboxMogli.getNoNil2
--**********************************************************************************************************	
function gearboxMogli.getNoNil2( v0, v1, v2, use2 )
	if v0 == nil then
		if v2 ~= nil and use2 then
			return v2
		end
		return v1
	end
	return v0
end

--**********************************************************************************************************	
-- gearboxMogli generic getter methods
--**********************************************************************************************************	
gearboxMogli.stateWithSetGet = { "IsOnOff", 
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
																 "DecelerateToLimit",
																 "EcoMode",
																 "HudMode" }

for _,state in pairs( gearboxMogli.stateWithSetGet ) do
	gearboxMogli["mrGbMGet"..state] = function(self)
		return self.mrGbMS[state]
	end
	gearboxMogli["mrGbMSet"..state] = function(self, value, noEventSend )
		gearboxMogli.mbSetState( self, state, value, noEventSend ) 		
	end
end

--**********************************************************************************************************	
-- gearboxMogli:initClient
--**********************************************************************************************************	
function gearboxMogli:initClient()		

	-- state
	self.mrGbMS = {}
	-- locals used for calculations
	self.mrGbML = {}
	-- draw
	self.mrGbMD = {}
	-- backup
	self.mrGbMB = {}
	
	if self.mrGbMG == nil then
		if not( gearboxMogli.globalsLoaded ) then
			gearboxMogli.globalsLoaded = true
			file = gearboxMogli.modsDirectory.."gearboxAddonConfig.xml"
			if fileExists(file) then	
				gearboxMogli.globalsLoad( file, "vehicles.gearboxMogliGlobals", gearboxMogliGlobals )	
			end		
			gearboxMogliGlobals.hudWidth = Utils.clamp( 16.0 * g_screenHeight * gearboxMogliGlobals.hudWidth / ( 9.0 * g_screenWidth ), 0.05, 0.3 )
			if gearboxMogliGlobals.hudWidth + gearboxMogliGlobals.hudPositionX > 1 then
				gearboxMogliGlobals.hudPositionX = 1 - gearboxMogliGlobals.hudWidth
			end
		end	
		
		self.mrGbMG = gearboxMogliGlobals
	end

	self.mrGbMSetState    = gearboxMogli.mbSetState
	self.mrGbMDoGearShift = gearboxMogli.mrGbMDoGearShift
	
	gearboxMogli.initStateHandling( self )
	gearboxMogli.registerState( self, "IsOn",          false, gearboxMogli.mrGbMOnSetIsOn )
	gearboxMogli.registerState( self, "BlowOffVentilPlay",false )
	gearboxMogli.registerState( self, "GrindingGearsVol", 0 )--, gearboxMogli.debugEvent )
	gearboxMogli.registerState( self, "DrawText",      "off" )
	gearboxMogli.registerState( self, "DrawText2",     "off" )
	gearboxMogli.registerState( self, "G27Mode",       0 ) 	
	gearboxMogli.registerState( self, "WarningText",   "",    gearboxMogli.mrGbMOnSetWarningText )
	gearboxMogli.registerState( self, "InfoText",      "",    gearboxMogli.mrGbMOnSetInfoText )
	gearboxMogli.registerState( self, "ConstantRpm",   false )
	gearboxMogli.registerState( self, "NoUpdateStream",false, gearboxMogli.mrGbMOnSetNoUpdateStream )
	gearboxMogli.registerState( self, "NUSMessage",    {},    gearboxMogli.mrGbMOnSetNUSMessage )
	
--**********************************************************************************************************	
-- state variables with setter methods	
	for _,state in pairs( gearboxMogli.stateWithSetGet ) do
		self["mrGbMSet"..state] = gearboxMogli["mrGbMSet"..state] 
		self["mrGbMGet"..state] = gearboxMogli["mrGbMGet"..state] 
	end
	
	gearboxMogli.registerState( self, "IsOnOff",       false )
	gearboxMogli.registerState( self, "CurrentGear",   1,     gearboxMogli.mrGbMOnSetGear ) 
	gearboxMogli.registerState( self, "CurrentRange",  1,     gearboxMogli.mrGbMOnSetRange )
	gearboxMogli.registerState( self, "CurrentRange2", 1,     gearboxMogli.mrGbMOnSetRange2 )
	gearboxMogli.registerState( self, "NewGear",       0,     gearboxMogli.mrGbMOnSetNewGear ) 
	gearboxMogli.registerState( self, "NewRange",      0,     gearboxMogli.mrGbMOnSetNewRange )
	gearboxMogli.registerState( self, "NewRange2",     0,     gearboxMogli.mrGbMOnSetNewRange2 )
	gearboxMogli.registerState( self, "NewReverse",    false, gearboxMogli.mrGbMOnSetNewReverse )
	gearboxMogli.registerState( self, "IsNeutral",     true )
	gearboxMogli.registerState( self, "Automatic",     false )
	gearboxMogli.registerState( self, "ReverseActive", false, gearboxMogli.mrGbMOnSetReverse )
	gearboxMogli.registerState( self, "NeutralActive", true,  gearboxMogli.mrGbMOnSetNeutral ) 	
	gearboxMogli.registerState( self, "AutoHold",     false ) 	
	gearboxMogli.registerState( self, "AutoClutch",    true  )
	gearboxMogli.registerState( self, "ManualClutch",  1,     gearboxMogli.mrGbMOnSetManualClutch )
	gearboxMogli.registerState( self, "HandThrottle",  0 )
	gearboxMogli.registerState( self, "SpeedLimiter",  false )
	gearboxMogli.registerState( self, "AllAuto",       false )
	gearboxMogli.registerState( self, "EcoMode",       false )
	gearboxMogli.registerState( self, "HudMode",       self.mrGbMG.defaultHudMode )
	gearboxMogli.registerState( self, "CurrentGearSpeed", 0 )

--**********************************************************************************************************	
-- special getter functions for motor parameters
	self.mrGbMGetClutchPercent     = gearboxMogli.mrGbMGetClutchPercent
	self.mrGbMGetAutoClutchPercent = gearboxMogli.mrGbMGetAutoClutchPercent
	self.mrGbMGetCurrentRPM        = gearboxMogli.mrGbMGetCurrentRPM
	self.mrGbMGetTargetRPM         = gearboxMogli.mrGbMGetTargetRPM
	self.mrGbMGetMotorLoad         = gearboxMogli.mrGbMGetMotorLoad 
	self.mrGbMGetUsedPower         = gearboxMogli.mrGbMGetUsedPower
	self.mrGbMGetThroughPut        = gearboxMogli.mrGbMGetThroughPut
	self.mrGbMGetModeText          = gearboxMogli.mrGbMGetModeText 
	self.mrGbMGetModeShortText     = gearboxMogli.mrGbMGetModeShortText 
	self.mrGbMGetGearText          = gearboxMogli.mrGbMGetGearText 
	self.mrGbMGetIsOn              = gearboxMogli.mrGbMGetIsOn 
	self.mrGbMGetAutoStartStop     = gearboxMogli.mrGbMGetAutoStartStop 
	self.mrGbMGetAutoShiftGears    = gearboxMogli.mrGbMGetAutoShiftGears 
	self.mrGbMGetAutoShiftRange    = gearboxMogli.mrGbMGetAutoShiftRange  
	self.mrGbMGetAutoShiftRange2   = gearboxMogli.mrGbMGetAutoShiftRange2 
	self.mrGbMGetGearSpeed         = gearboxMogli.mrGbMGetGearSpeed
	self.mrGbMGetGearNumber        = gearboxMogli.mrGbMGetGearNumber
	self.mrGbMGetRangeNumber       = gearboxMogli.mrGbMGetRangeNumber
	self.mrGbMGetRange2Number      = gearboxMogli.mrGbMGetRange2Number
	self.mrGbMGetHasAllAuto        = gearboxMogli.mrGbMGetHasAllAuto
	self.mrGbMGetAutoHold          = gearboxMogli.mrGbMGetAutoHold
	self.mrGbMGetOnlyHandThrottle  = gearboxMogli.mrGbMGetOnlyHandThrottle
	self.mrGbMGetHydrostaticFactor = gearboxMogli.mrGbMGetHydrostaticFactor
	self.mrGbMSetLanuchGear        = gearboxMogli.mrGbMSetLanuchGear
	self.mrGbMGetEqualizedRpm      = gearboxMogli.mrGbMGetEqualizedRpm
	
--**********************************************************************************************************	

	self.mrGbML.lastSumDt          = 0 
	self.mrGbML.soundSumDt         = 0 
	self.mrGbML.lastShiftTime      = 0
	self.mrGbML.autoShiftTime      = 0
	self.mrGbML.lastGearSpeed      = 0	
	self.mrGbML.warningTimer       = 0	
	self.mrGbML.infoTimer          = 0	
	self.mrGbML.manualClutchTime   = 0
	self.mrGbML.gearShiftingNeeded = 0 
	self.mrGbML.gearShiftingTime   = 0 
	self.mrGbML.clutchShiftingTime = 0 
	self.mrGbML.doubleClutch       = false
	self.mrGbML.lastReverse        = false
	self.mrGbML.dirtyFlag          = self:getNextDirtyFlag() 
	self.mrGbML.wantedAcceleration = 0
	self.mrGbML.blowOffVentilTime0 = 0
	self.mrGbML.blowOffVentilTime1 = 0
	self.mrGbML.blowOffVentilTime2 = -1
	self.mrGbML.oneButtonClutchTimer = 0
	self.mrGbML.strawDisableTime     = 0
	self.mrGbML.currentCuttersArea   = 0
	self.mrGbML.currentRealArea      = 0
	self.mrGbML.maxRealArea          = 0
	self.mrGbML.cutterAreaPerSecond  = 0
	self.mrGbML.realAreaPerSecond    = 0
	self.mrGbML.updateStreamErrors   = 0
	self.mrGbML.MotorLoad            = 0
	self.mrGbML.DirectionChangeTime  = 0
	
	if gearboxMogli.ovArrowUpWhite == nil then
		local w  = math.floor(0.0095 * g_screenWidth) / g_screenWidth * gearboxMogli.getUiScale()
		local h = w * g_screenAspectRatio;
		local x = g_currentMission.speedMeterIconOverlay.x
		local y = g_currentMission.speedMeterIconOverlay.y
		
		gearboxMogli.ovArrowUpWhite   = Overlay:new("ovArrowUpWhite",   Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_up_white.dds",   gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovArrowUpGray    = Overlay:new("ovArrowUpGray",    Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_up_gray.dds",    gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovArrowDownWhite = Overlay:new("ovArrowDownWhite", Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_down_white.dds", gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovArrowDownGray  = Overlay:new("ovArrowDownGray",  Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_down_gray.dds",  gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovHandBrakeUp    = Overlay:new("ovHandBrakeUp",    Utils.getFilename( self.mrGbMG.ddsDirectory.."hand_brake_up.dds",    gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovHandBrakeDown  = Overlay:new("ovHandBrakeDown",  Utils.getFilename( self.mrGbMG.ddsDirectory.."hand_brake_down.dds",  gearboxMogli.baseDirectory), x, y, w, h)
	end
	
	self.mrGbMD.Tgt        = 0 
	self.mrGbMD.lastTgt    = 0 
	self.mrGbMD.Clutch     = 0 
	self.mrGbMD.lastClutch = 0 
	self.mrGbMD.Fuel       = 0 
	self.mrGbMD.lastPower  = 0 
	self.mrGbMD.Power      = 0 
	self.mrGbMD.lastRate   = 0 
	self.mrGbMD.Rate       = 0 
	self.mrGbMD.Hydro      = 255
	self.mrGbMD.lastHydro  = 255
	
	self.mrGbML.lastAcceleration  = 0
	self.mrGbML.lastBrakePedal    = 1
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetEqualizedRpm
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetEqualizedRpm( r )
--return math.min( self.mrGbMS.OrigMaxRpm, self.mrGbMS.OrigMinRpm + math.max( 0, ( r - self.mrGbMS.IdleRpm ) ) * self.mrGbMS.EqualizedRpmFactor )
	return self.mrGbMS.OrigMinRpm + ( r - self.mrGbMS.IdleRpm ) * self.mrGbMS.EqualizedRpmFactor
end

--**********************************************************************************************************	
-- gearboxMogli.completeXMLGearboxEntry
--**********************************************************************************************************	
function gearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, fixEntry )
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
-- gearboxMogli:initFromXml
--**********************************************************************************************************	
function gearboxMogli:initFromXml(xmlFile,xmlString,xmlSource,serverAndClient,motorConfig) 

--**************************************************************************************************	
	if xmlSource == "vehicle" then
		self.mrGbMG = {}
		for n,v in pairs( gearboxMogliGlobals ) do
			self.mrGbMG[n] = v
		end
		
		self.mrGbMG.playGrindingSound = false
		gearboxMogli.globalsLoad2( xmlFile, "vehicle.gearboxMogliGlobals", self.mrGbMG )	
		self.mrGbMG.hudWidth = Utils.clamp( 16.0 * g_screenHeight * self.mrGbMG.hudWidth / ( 9.0 * g_screenWidth ), 0.05, 0.3 )
		if self.mrGbMG.hudWidth + self.mrGbMG.hudPositionX > 1 then
			self.mrGbMG.hudPositionX = 1 - self.mrGbMG.hudWidth
		end
		gearboxMogli.noInputWarning = true
	else
		if not( gearboxMogli.globalsLoaded ) then
			gearboxMogli.globalsLoaded = true
			file = gearboxMogli.modsDirectory.."gearboxAddonConfig.xml"
			if fileExists(file) then	
				gearboxMogli.globalsLoad( file, "vehicles.gearboxMogliGlobals", gearboxMogliGlobals )	
			end		
			gearboxMogliGlobals.hudWidth = Utils.clamp( 16.0 * g_screenHeight * gearboxMogliGlobals.hudWidth / ( 9.0 * g_screenWidth ), 0.05, 0.3 )
			if gearboxMogliGlobals.hudWidth + gearboxMogliGlobals.hudPositionX > 1 then
				gearboxMogliGlobals.hudPositionX = 1 - gearboxMogliGlobals.hudWidth
			end
		end	
		
		self.mrGbMG = gearboxMogliGlobals
	end
	
--**************************************************************************************************		
	gearboxMogli.initClient( self )		
	
	local excludeList = {}
	local default 
	
	if not ( serverAndClient ) then
		if self.mrGbMS ~= nil then
			for n,_ in pairs(self.mrGbMS) do
				excludeList[n] = true
			end	
		end	
	end
	
--**************************************************************************************************	
	self.mrGbMS.ConfigVersion           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#version" ),1.4)
	self.mrGbMS.NoDisable               = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#noDisable" ),self.mrGbMG.noDisable)
	if self.mrGbMS.NoDisable then
		self.mrGbMS.DefaultOn             = true
	else
		self.mrGbMS.DefaultOn             = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#defaultOn" ),self.mrGbMG.defaultOn )
	end
	self.mrGbMS.showHud                 = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#showHud" ),true)
	self.mrGbMS.drawTargetRpm           = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#drawTargetRpm" ),self.mrGbMG.drawTargetRpm)
	self.mrGbMS.SwapGearRangeKeys       = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#swapGearRangeKeys" ),false)
	self.mrGbMS.TransmissionEfficiency  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#transmissionEfficiency"), gearboxMogliGlobals.transmissionEfficiency) 
	
	self.mrGbMS.IdleRpm	                = math.max( Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idleRpm"),  self.motor.minRpm ), self.motor.minRpm )
	self.mrGbMS.OrigMinRpm              = self.motor.minRpm
	self.mrGbMS.OrigMaxRpm              = self.motor.maxRpm	
	self.mrGbMS.CurMinRpm               = math.max( self.mrGbMS.IdleRpm  - gearboxMogli.rpmMinus, 0 )
	self.mrGbMS.CurMaxRpm               = self.mrGbMS.OrigMaxRpm + gearboxMogli.rpmPlus
	self.mrGbMS.OrigRatedRpm            = math.min( math.max( self.motor.maxRpm - gearboxMogli.rpmRatedMinus, 2 * self.mrGbMS.IdleRpm ), self.motor.maxRpm )
	self.mrGbMS.RatedRpm                = math.min( Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#ratedRpm"), self.mrGbMS.OrigRatedRpm ), self.motor.maxRpm )
	self.mrGbMS.AccelerateToLimit       = 5  -- km/h per second
	self.mrGbMS.DecelerateToLimit       = 10 -- km/h per second
	self.mrGbMS.MinTargetRpm            = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#minTargetRpm"), 0.7 * math.max( 0.475 * self.mrGbMS.RatedRpm, self.mrGbMS.IdleRpm ) + 0.3 * self.mrGbMS.RatedRpm )
	self.mrGbMS.IdleEnrichment          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idleEnrichment"), 0.02 )
	self.mrGbMS.BrakeForceRatio         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#brakeForceRatio"), self.mrGbMG.brakeForceRatio )
	
--**************************************************************************************************	
	self.mrGbMS.RpmInSpeedHud           = getXMLBool( xmlFile, xmlString .. "#rpmInSpeedHud")
	self.mrGbMS.MinHudRpm               = getXMLFloat(xmlFile, xmlString .. "#minHudRpm")
	self.mrGbMS.MaxHudRpm               = getXMLFloat(xmlFile, xmlString .. "#maxHudRpm")
--**************************************************************************************************	
	self.mrGbMS.Engine = {}
	self.mrGbMS.Sound  = {}
	self.mrGbMS.Engine.maxTorque = 0;
	self.mrGbMS.Engine.maxTorqueRpm = 0;
	self.mrGbMS.Engine.minRpm = gearboxMogli.huge;
	self.mrGbMS.Engine.maxRpm = 0;

	local torqueI = 0;
	local torqueF = nil
	local torqueP = 0
	local realEngineBaseKey = nil
	
	for i=1,3 do
		local key 
		if     i == 1 then
			if self.configurations.motor ~= nil then
				if motorConfig == nil then				
					key = string.format(xmlString..".engines.engine(%d)", self.configurations.motor-1)
				elseif motorConfig[self.configurations.motor] ~= nil then
					key = string.format(xmlString..".engines.engine(%d)", motorConfig[self.configurations.motor]-1)
				end
			end
		elseif i == 2 then
			key = xmlString..".engines.engine(0)"
		else
			key = xmlString..".realEngine"
		end
		
		if key ~= nil and getXMLFloat(xmlFile, key..".torque(0)#rpm") ~= nil then
			realEngineBaseKey = key
			break
		end
	end

	if realEngineBaseKey ~= nil then
		local s = getXMLString( xmlFile, realEngineBaseKey.."#name" )
		if self.configurations.motor ~= nil then
			local t = getXMLString( self.xmlFile, string.format("vehicle.motorConfigurations.motorConfiguration(%d)#name",self.configurations.motor-1))
			self.mrGbMS.EngineName = t
			
			if     t == "$l10n_configuration_valueDefault" or t == "l10n_configuration_valueDefault" then
				self.mrGbMS.EngineName = s
				if s ~= nil then
				--print('FS17_GearboxAddon: Engine name: "'..s..'"')			
				end
			elseif s == nil then
			--print('FS17_GearboxAddon: Vehicle motorConfiguration name: "'..t..'"')
			elseif s ~= t then
				print('FS17_GearboxAddon: Warning! Engine names to not match: "'..s..'" <> "'..t..'"')
			else
			--print('FS17_GearboxAddon: Engine and vehicle motorConfiguration name: "'..t..'"')
			end
		elseif s ~= nil then
			self.mrGbMS.EngineName = s
		--print('FS17_GearboxAddon: Engine name: "'..s..'"')			
		end
		
		while true do
			local key = string.format(realEngineBaseKey..".torque(%d)", torqueI);
			local rpm = getXMLFloat(xmlFile, key.."#rpm");
			local torque = getXMLFloat(xmlFile, key.."#motorTorque");
			if torque == nil then
				torque = getXMLFloat(xmlFile, key.."#ptoTorque");
				if torque ~= nil then
					torque = torque / self.mrGbMS.TransmissionEfficiency
				end
			end		

			if torque == nil or rpm == nil then --or fuelUsageRatio==nil then
				break;
			end;
			
			if self.mrGbMS.Engine.torqueValues == nil then
				--print("loading motor with new torque curve")
				self.mrGbMS.Engine.torqueValues = {}
				torqueF = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#torqueFactor"), self.mrGbMG.torqueFactor) / 1000
			end
			
			torque = torque * torqueF 
		
			self.mrGbMS.Engine.torqueValues[torqueI+1] = {v=torque, time = rpm}
					
			if torque>self.mrGbMS.Engine.maxTorque + gearboxMogli.eps then
				self.mrGbMS.Engine.maxTorqueRpm = rpm;
			end;			
			if torque>self.mrGbMS.Engine.maxTorque then
				self.mrGbMS.Engine.maxTorque = torque;
			end;
			
			local ecoTorque = getXMLFloat(xmlFile, key.."#motorTorqueEco");
			if ecoTorque == nil then
				ecoTorque = getXMLFloat(xmlFile, key.."#ptoTorqueEco");
				if ecoTorque ~= nil then
					ecoTorque = ecoTorque / self.mrGbMS.TransmissionEfficiency
				end
			end		
			if      ecoTorque ~= nil
					and ( ecoTorque > 0 or self.mrGbMS.Engine.ecoTorqueValues ~= nil ) then
				ecoTorque = ecoTorque * torqueF 
				
				if self.mrGbMS.Engine.ecoTorqueValues == nil then
					self.mrGbMS.Engine.ecoTorqueValues = {}
				end
				table.insert( self.mrGbMS.Engine.ecoTorqueValues, {v=ecoTorque, time = rpm} )
			end
			
			local fuelUsageRatio = getXMLFloat(xmlFile, key.."#fuelUsageRatio");
			if      fuelUsageRatio ~= nil
					and ( fuelUsageRatio > 0 or self.mrGbMS.Engine.fuelUsageValues ~= nil ) then
				if self.mrGbMS.Engine.fuelUsageValues == nil then
					self.mrGbMS.Engine.fuelUsageValues = {}
				end
				table.insert( self.mrGbMS.Engine.fuelUsageValues, {v=fuelUsageRatio, time = rpm} )
			end
			
			if      self.mrGbMS.Engine.maxRpm < rpm 
					and ( torque > 0 or torqueP > 0 ) then
				self.mrGbMS.Engine.maxRpm = rpm
			end
			if      self.mrGbMS.Engine.minRpm > rpm 
					and torque > 0 then
				self.mrGbMS.Engine.minRpm = rpm
			end
			torqueI = torqueI + 1;	
			torqueP = torque
		end

		if torqueI > 0 then
			self.mrGbMS.IdleRpm	  = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#idleRpm"), 800);
			self.mrGbMS.RatedRpm  = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#ratedRpm"), 2100);
			self.mrGbMS.CurMinRpm = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#minRpm"), math.max( self.mrGbMS.IdleRpm  - gearboxMogli.rpmMinus, self.mrGbMS.Engine.minRpm ))
			self.mrGbMS.CurMaxRpm = self.mrGbMS.Engine.maxRpm + gearboxMogli.rpmPlus
			self.mrGbMS.MinTargetRpm = math.min( self.mrGbMS.MinTargetRpm, self.mrGbMS.Engine.maxTorqueRpm / gearboxMogli.rpmReduction )
		end
		
		self.mrGbMS.BoostMinSpeed = Utils.getNoNil( getXMLFloat(xmlFile, realEngineBaseKey.."#boostMinSpeed"), 30 ) / 3600
	end
		
	if self.mrGbMS.Engine.fuelUsageValues == nil then
		local fuelUsageRatio = getXMLFloat(xmlFile, xmlString.."#minFuelUsageRatio")
		if fuelUsageRatio == nil then
			self.mrGbMS.GlobalFuelUsageRatio = Utils.getNoNil( getXMLFloat(xmlFile, xmlString.."#fuelUsageRatio"), 230 )			
		else
			self.mrGbMS.GlobalFuelUsageRatio = fuelUsageRatio / 0.9
		end
	end
	
	local maxTorque = 0
	
	if torqueI > 0 then
		maxTorque             = self.mrGbMS.Engine.maxTorque
	else
		maxTorque             = self.motor.torqueCurve:getMaximum()
	end
						
	self.mrGbMS.Sound.MaxRpm = getXMLFloat(xmlFile, xmlString .. "#soundMaxRpm")
	if self.mrGbMS.Sound.MaxRpm == nil then
		self.mrGbMS.Sound.MaxRpm = self.mrGbMS.RatedRpm
	end

--**************************************************************************************************	
-- PTO RPM
--**************************************************************************************************		
	self.mrGbMS.PtoRpm                  = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#ptoRpm"),    
																												self.mrGbMS.IdleRpm + 50 * math.floor( 0.5 + 0.02 * gearboxMogli.ptoRpmFactor * ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) ) ) 
	self.mrGbMS.PtoRpmEco               = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#ptoRpmEco"),    
																												self.mrGbMS.IdleRpm + 50 * math.floor( 0.5 + 0.02 * gearboxMogli.ptoRpmFactorEco * ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) ) ) 
	if self.mrGbMS.PtoRpmEco > self.mrGbMS.PtoRpm then
		self.mrGbMS.PtoRpmEco             = self.mrGbMS.PtoRpm
	end
	
	local maxPtoTorqueRatio = 0.5
	local maxPtoTorqueSpeed = 10

--**************************************************************************************************	
-- combine
--**************************************************************************************************		
	if SpecializationUtil.hasSpecialization(Combine, self.specializations) then	
		self.mrGbMS.IsCombine                    = true
		
		local width  = getXMLFloat(xmlFile, xmlString .. ".combine#defaultWidth") 
		local speed = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#defaultSpeed"), self.mrGbMG.combineDefaultSpeed )
		maxPtoTorqueSpeed = math.min( maxPtoTorqueSpeed, speed )
		local f = 1.36 * self.mrGbMG.torqueFactor / gearboxMogli.powerFactor0 * 7 / speed
		local du0, dc0, dci, dp0, dpi = 0, 0, 0, 0, 0
		
		local storeItem = StoreItemsUtil.storeItemsByXMLFilename[self.configFileName:lower()]
		
		if storeItem ~= nil and storeItem.category == "forageHarvesters" then
			dp0 = 30 * maxTorque 
			dpi = 9.200
		else
			dp0 = 50 * maxTorque 
			dc0 = 3.2* maxTorque
			dpi = 6
			dci = 0.383
		end
		
		if width ~= nil then
			local defaultFruit = getXMLString(xmlFile, xmlString .. ".combine#defaultFruit")			
			local defaultLiterPerSqm = self.mrGbMG.defaultLiterPerSqm
			
			if defaultFruit == nil and storeItem ~= nil and storeItem.category == "forageHarvesters" then
				defaultFruit = "chaff"
			end
			
			if     defaultFruit == nil
					or defaultFruit == "wheat"  then
				defaultLiterPerSqm = 1.2
			elseif defaultFruit == "barley" then
				defaultLiterPerSqm = 1.1
			elseif defaultFruit == "rape" then
				defaultLiterPerSqm = 0.6
			elseif defaultFruit == "maize" then
				defaultLiterPerSqm = 1.2
			elseif defaultFruit == "potato" then
				defaultLiterPerSqm = 4
			elseif defaultFruit == "sugarBeet" then
				defaultLiterPerSqm = 3.5
			elseif defaultFruit == "grass" then
				defaultLiterPerSqm = 1.2
			elseif defaultFruit == "dryGrass" then
				defaultLiterPerSqm = 1.2
			elseif defaultFruit == "chaff" then
				defaultLiterPerSqm = 3.9
			else
				print('FS17_GearboxAddon: Warning! Unknown fruit type: "'..tostring(defaultFruit)..'"' )
			end
			
			defaultLiterPerSqm = defaultLiterPerSqm * self.mrGbMG.defaultLiterPerSqm / 1.2
			
			local factor = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#defaultLiterPerSqm"), defaultLiterPerSqm )
			
			local dynamicRatio = getXMLFloat(xmlFile, xmlString .. ".combine#dynamicRatio")
			
			if     defaultFruit   == "chaff" 
					or ( defaultFruit == nil and defaultLiterPerSqm > 3 ) then
				if dynamicRatio == nil then
					dynamicRatio = self.mrGbMG.combineDynamicChopper
				end
				du0 = 0
				dc0 = 0
				dci = 0
				dp0 = width * 60 * ( 1 - dynamicRatio )
				dpi = 11.5 * dynamicRatio
			else
				if dynamicRatio == nil then
					dynamicRatio = self.mrGbMG.combineDynamicRatio
				end
				du0 = 6 + width
				dp0 = width * 25 * ( 1 - dynamicRatio )
				dpi = 10 * dynamicRatio
				dc0 = dp0 * 0.06/0.94
				dci = dpi * 0.06/0.94
			end
		end	
	
		if self.mrGbMG.debugPrint then
			print(string.format("combine settings: du0: %8.3f dp0: %8.3f dpi: %8.3f dc0: %8.3f dci: %8.3f rp0: %8.3f rc0: %8.3f (%8.3f)", du0, dp0, dpi, dc0, dci, dp0/maxTorque, dc0/maxTorque, maxTorque ))
		end			
			
		self.mrGbMS.ThreshingMinRpm              = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#minRpm")                      , 0.2 * self.mrGbMS.IdleRpm + 0.8 * self.mrGbMS.RatedRpm )
		self.mrGbMS.ThreshingMaxRpm              = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#maxRpm")                      , self.mrGbMS.RatedRpm )
		self.mrGbMS.UnloadingPowerConsumption    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#unloadingPowerConsumption")   , du0 ) * f
		
		self.mrGbMS.ThreshingPowerConsumption    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#threshingPowerConsumption")   , dp0 ) * f
		self.mrGbMS.ThreshingPowerConsumptionInc = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#threshingPowerConsumptionInc"), dpi ) * f
		self.mrGbMS.ChopperPowerConsumption      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#chopperPowerConsumption")     , dc0 ) * f
		self.mrGbMS.ChopperPowerConsumptionInc   = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#chopperPowerConsumptionInc")  , dci ) * f
		
		self.mrGbMS.ThreshingReductionFactor     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#powerReductionFactor")        , 0 ) 
		self.mrGbMS.ThreshingSoundOffset         = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#threshingSoundOffset")        , 0.95 ) 
		self.mrGbMS.ThreshingSoundScale          = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#threshingSoundScale")         , 0.1 ) 
		
		self.addCutterArea = Utils.appendedFunction(self.addCutterArea, gearboxMogli.addCutterArea)
	end
	
--**************************************************************************************************	
-- reduce PTO torque at low speed
--**************************************************************************************************		
	self.mrGbMS.MaxPtoTorqueRatio       = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#maxPtoTorqueRatio" ), maxPtoTorqueRatio ) 
	self.mrGbMS.MaxPtoTorqueRatioInc    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#maxPtoTorqueRatioInc" ), ( 1-self.mrGbMS.MaxPtoTorqueRatio ) / maxPtoTorqueSpeed ) 

--**************************************************************************************************	
-- speed limiter
--**************************************************************************************************		
	self.mrGbMS.AutoStartStop           = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#autoStartStop"), true)
	self.mrGbMS.MaxSpeedLimiter         = getXMLBool( xmlFile, xmlString .. "#speedLimiter")
	self.mrGbMS.MaxRpmThrottle          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#maxRpmThrottle"), self.mrGbMG.maxRpmThrottle )
	self.mrGbMS.CruiseControlBrake      = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#cruiseControlBrake" ), self.mrGbMS.AutoStartStop)
	
	self.mrGbMS.OnlyHandThrottle        = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#onlyHandThrottle" ), false)
	self.mrGbMS.MinHandThrottle         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#minHandThrottle" ), 0.5)
	self.mrGbMS.PtoSpeedLimit	          = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#ptoSpeedLimit"), self.mrGbMG.ptoSpeedLimit )
	
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

	local hasHydrostat = hasXMLProperty(xmlFile, xmlString ..".hydrostatic.efficiency(0)#ratio" ) 
										or hasXMLProperty(xmlFile, xmlString ..".hydrostatic#profile" ) 
	
	self.mrGbMS.AutoShiftUpRpm        = getXMLFloat(xmlFile, xmlString .. ".gears#autoUpRpm") 
	self.mrGbMS.AutoShiftDownRpm      = getXMLFloat(xmlFile, xmlString .. ".gears#autoDownRpm") 
	self.mrGbMS.AutoShiftRpmReduction = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".gears#autoRpmReduction"), (1-gearboxMogli.rpmReduction) * self.mrGbMS.RatedRpm )
	self.mrGbMS.AutoShiftRange2       = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(1)#automatic"), false )
	self.mrGbMS.AutoShiftHl           = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(0)#automatic"), false )
	self.mrGbMS.AutoShiftGears        = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".gears#automatic"), (self.mrGbMS.AutoShiftUpRpm ~= nil) )
	if self.mrGbMS.AutoShiftGears then
		self.mrGbMS.DisableManual       = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#disableManual" ), self.mrGbMG.disableManual or hasHydrostat )
	else                             
		self.mrGbMS.DisableManual       = false
	end
	
	if hasHydrostat then
		default = self.mrGbMG.momentOfInertiaBaseH + self.mrGbMG.momentOfInertiaH * maxTorque
	else
		default = self.mrGbMG.momentOfInertiaBase  + self.mrGbMG.momentOfInertia  * maxTorque
	end
	self.mrGbMS.MomentOfInertia         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#momentOfInertia"), default )
	
--**************************************************************************************************	
-- Clutch parameter
--**************************************************************************************************		
	self.mrGbMS.TorqueConverter         = getXMLBool( xmlFile, xmlString .. "#torqueConverter" )	
	self.mrGbMS.MaxClutchPercent        = getXMLFloat(xmlFile, xmlString .. "#maxClutchRatio")
	
	if self.mrGbMS.TorqueConverter == nil and self.mrGbMS.MaxClutchPercent == nil then
		self.mrGbMS.TorqueConverter    = false
		self.mrGbMS.MaxClutchPercent   = 1
	elseif self.mrGbMS.MaxClutchPercent == nil then
		if self.mrGbMS.TorqueConverter then
			self.mrGbMS.MaxClutchPercent = gearboxMogli.maxClutchPercentTC
		else
			self.mrGbMS.MaxClutchPercent = 1
		end
	elseif self.mrGbMS.TorqueConverter == nil then
		self.mrGbMS.TorqueConverter    = ( self.mrGbMS.MaxClutchPercent < 0.99 )		
	end
	
	if self.mrGbMS.MaxClutchPercent > 1 then 
		self.mrGbMS.MaxClutchPercent   = 1 
	end	
	
	self.mrGbMS.TorqueConverterOrHydro  = false
	if self.mrGbMS.TorqueConverter then
		self.mrGbMS.TorqueConverterOrHydro = true
	elseif hasHydrostat then
		self.mrGbMS.TorqueConverterOrHydro = true
	end

	self.mrGbMS.TorqueConverterEfficiency = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#torqueConverterEfficiency"), math.min( 0.9, self.mrGbMS.TransmissionEfficiency ) )

	
	if self.mrGbMS.TorqueConverter then 
		default = gearboxMogli.huge --self.mrGbMS.CurMaxRpm
--elseif self.mrGbMS.Engine.maxTorque > 0 then
--	default = 0.5 * ( self.mrGbMS.IdleRpm + self.mrGbMS.Engine.maxTorqueRpm )
--else
--	default = 0.585 * self.mrGbMS.OrigMaxRpm
	else
		default = math.max( 0.62 * self.mrGbMS.RatedRpm, self.mrGbMS.IdleRpm )
		if self.mrGbMS.Engine.maxTorque > 0 then
			default = math.min( default, self.mrGbMS.Engine.maxTorqueRpm )
		end
	end
	self.mrGbMS.CloseRpm                = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchCloseRpm"), default )
	
	default = self.mrGbMS.CurMinRpm-1 -- no automatic opening of clutch by default!!!
	if self.mrGbMS.TorqueConverter then 
		default = math.min( self.mrGbMS.CloseRpm, self.mrGbMS.RatedRpm )
	end
	self.mrGbMS.OpenRpm                 = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchOpenRpm"), default )
	self.mrGbMS.ClutchRpmShift          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchRpmShift"), 0 )
	
	default = self.mrGbMS.CloseRpm-1
	if self.mrGbMS.TorqueConverter then 
		default = math.min( self.mrGbMS.RatedRpm, self.mrGbMS.CloseRpm + 0.1 * self.mrGbMS.RatedRpm )
	end
	self.mrGbMS.ClutchMaxTargetRpm      = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchMaxTargetRpm"), default )
	
	local clutchEngagingTimeMs          = getXMLFloat(xmlFile, xmlString .. "#clutchEngagingTimeMs")
	local clutchTimeManualDefault      
	if clutchEngagingTimeMs == nil then
		if     hasHydrostat then
			clutchEngagingTimeMs = 1
		elseif self.mrGbMS.TorqueConverter then
			clutchEngagingTimeMs = 100
		elseif getXMLBool(xmlFile, xmlString .. ".gears#automatic") then
			clutchEngagingTimeMs = 200
		else
			clutchEngagingTimeMs = 400 -- 1000 = 1s
		end
	end
	
	self.mrGbMS.TorqueConverterLockupMs = getXMLFloat(xmlFile, xmlString .. "#torqueConverterLockupMs")
	if      self.mrGbMS.TorqueConverter 
			and self.mrGbMS.CloseRpm < self.mrGbMS.RatedRpm 
			and self.mrGbMS.TorqueConverterLockupMs == nil then
		self.mrGbMS.TorqueConverterLockupMs = 1000
	end		
	
	self.mrGbMS.MinClutchPercent        = getXMLFloat(xmlFile, xmlString .. "#minClutchRatio")
	if     self.mrGbMS.MinClutchPercent == nil then 
		if      self.mrGbMS.TorqueConverter 
				and self.mrGbMS.TorqueConverterLockupMs ~= nil
				and self.mrGbMS.TorqueConverterLockupMs >= 0 then
			self.mrGbMS.MinClutchPercent    = gearboxMogli.minClutchPercentTCL
		elseif self.mrGbMS.TorqueConverterOrHydro then
			self.mrGbMS.MinClutchPercent    = gearboxMogli.minClutchPercentTC
		else
			self.mrGbMS.MinClutchPercent    = gearboxMogli.minClutchPercentStd 
		end
	end
	if self.mrGbMS.MinClutchPercent < 2 * gearboxMogli.minClutchPercent then 
		self.mrGbMS.MinClutchPercent      = 2 * gearboxMogli.minClutchPercent 
	end	
	
	if self.mrGbMS.TorqueConverter then
		self.mrGbMS.TorqueConverterFactor = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#torqueConverterMaxFactor"),3)
	end
		
	self.mrGbMS.ClutchTimeInc           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeIncreaseMs"), clutchEngagingTimeMs )
	self.mrGbMS.ClutchTimeDec           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeDecreaseMs"), 0.50 * clutchEngagingTimeMs ) 		
	self.mrGbMS.ClutchShiftTime         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchShiftingTimeMs"), 0.25 * self.mrGbMS.ClutchTimeDec) 
	self.mrGbMS.ClutchTimeManual        = math.max( Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeManualMs"), self.mrGbMG.minClutchTimeManual ), self.mrGbMS.ClutchTimeInc )
	self.mrGbMS.ClutchCanOverheat       = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#clutchCanOverheat"), not self.mrGbMS.TorqueConverterOrHydro ) 
	self.mrGbMS.ClutchOverheatStartTime = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchOverheatStartTimeMs"), 5000 ) 
	self.mrGbMS.ClutchOverheatIncTime   = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchOverheatIncTimeMs"), 5000 ) 
	self.mrGbMS.ClutchOverheatMaxTime   = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchOverheatIncTimeMs"), 25000 ) 
	
	local alwaysDoubleClutch            = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. "#doubleClutch"), false) 
	self.mrGbMS.GearsDoubleClutch       = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".gears#doubleClutch"), alwaysDoubleClutch) 
	self.mrGbMS.Range1DoubleClutch      = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(0)#doubleClutch"), alwaysDoubleClutch) 
	self.mrGbMS.Range2DoubleClutch      = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(1)#doubleClutch"), alwaysDoubleClutch) 
	self.mrGbMS.ReverseDoubleClutch     = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".reverse#doubleClutch"), alwaysDoubleClutch) 
	
	self.mrGbMS.GearTimeToShiftGear     = gearboxMogli.getNoNil2(getXMLFloat(xmlFile, xmlString .. ".gears#shiftTimeMs"), 650, -1, hasHydrostat and self.mrGbMS.DisableManual )
	self.mrGbMS.GearShiftEffectGear     = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".gears#shiftEffect"),     self.mrGbMS.GearTimeToShiftGear < self.mrGbMG.shiftEffectTime )
	self.mrGbMS.GearTimeToShiftHl       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(0)#shiftTimeMs"),  750 ) 
	self.mrGbMS.GearShiftEffectHl       = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(0)#shiftEffect"), self.mrGbMS.GearTimeToShiftHl < self.mrGbMG.shiftEffectTime )
	self.mrGbMS.GearTimeToShiftRanges2  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".ranges(1)#shiftTimeMs"), 1200 ) 
	self.mrGbMS.GearShiftEffectRanges2  = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(1)#shiftEffect"), self.mrGbMS.GearTimeToShiftRanges2 < self.mrGbMG.shiftEffectTime )
	self.mrGbMS.GearTimeToShiftReverse  = math.max( Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".reverse#shiftTimeMs"), 0 ), self.mrGbMG.minTimeToShiftReverse )

	self.mrGbMS.GearTimeToShiftGear     = self.mrGbMS.GearTimeToShiftGear    * self.mrGbMG.shiftTimeMsFactor
	self.mrGbMS.GearTimeToShiftHl       = self.mrGbMS.GearTimeToShiftHl      * self.mrGbMG.shiftTimeMsFactor
	self.mrGbMS.GearTimeToShiftRanges2  = self.mrGbMS.GearTimeToShiftRanges2 * self.mrGbMG.shiftTimeMsFactor
	
	local default = self.mrGbMS.MinClutchPercent
	if self.mrGbMS.TorqueConverter then
		default = -1
	elseif hasHydrostat then
		default = 1
	end
	
	self.mrGbMS.ClutchAfterShiftGear    = gearboxMogli.getNoNil2(getXMLFloat(xmlFile, xmlString .. ".gears#clutchRatio"),     default, 1, self.mrGbMS.GearShiftEffectGear ) 
	self.mrGbMS.ClutchAfterShiftHl      = gearboxMogli.getNoNil2(getXMLFloat(xmlFile, xmlString .. ".ranges(0)#clutchRatio"), default, 1, self.mrGbMS.GearShiftEffectHl ) 
	self.mrGbMS.ClutchAfterShiftRanges2 = gearboxMogli.getNoNil2(getXMLFloat(xmlFile, xmlString .. ".ranges(1)#clutchRatio"), default, 1, self.mrGbMS.GearShiftEffectRanges2 ) 
	self.mrGbMS.ClutchAfterShiftReverse = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".reverse#clutchRatio"), default )

	self.mrGbMS.ManualClutchGear      	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".gears#manualClutch"),     self.mrGbMS.ClutchAfterShiftGear + 0.1 <= self.mrGbMS.MaxClutchPercent )
	self.mrGbMS.ManualClutchHl        	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(0)#manualClutch"), self.mrGbMS.ClutchAfterShiftHl + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	self.mrGbMS.ManualClutchRanges2   	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(1)#manualClutch"), self.mrGbMS.ClutchAfterShiftRanges2 + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	self.mrGbMS.ManualClutchReverse   	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".reverse#manualClutch"),   self.mrGbMS.ClutchAfterShiftReverse + 0.1 <= self.mrGbMS.MaxClutchPercent )
		
	self.mrGbMS.ShiftNoThrottleGear   	= getXMLBool( xmlFile, xmlString .. ".gears#shiftNoThrottle")
	self.mrGbMS.ShiftNoThrottleHl     	= getXMLBool( xmlFile, xmlString .. ".ranges(0)#shiftNoThrottle")
	self.mrGbMS.ShiftNoThrottleRanges2	= getXMLBool( xmlFile, xmlString .. ".ranges(1)#shiftNoThrottle") 		
	
	self.mrGbMS.GlobalRatioFactor       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#globalRatioFactor"), 1 ) --1.025 )

	local revUpMs0                      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revUpMs"),  self.mrGbMG.DefaultRevUpMs0 ) 
	local f                             = revUpMs0 /  math.max(1,self.mrGbMG.DefaultRevUpMs0)
	local revUpMs1                      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revUpMsFullLoad"),  self.mrGbMG.DefaultRevUpMs1 * f ) 
	local revDownMs                     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revDownMs"), self.mrGbMG.DefaultRevDownMs * f ) 
	self.mrGbMS.RpmIncFactor            = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 1, revUpMs0 )
	self.mrGbMS.RpmIncFactorFull        = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 1, revUpMs1 )
	self.mrGbMS.RpmDecFactor            = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 1, revDownMs )
	
--**************************************************************************************************	
-- Sound parameter
--**************************************************************************************************		
	self.mrGbMS.IdlePitchFactor         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idlePitchFactor"), -1 )
	self.mrGbMS.IdlePitchMax            = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idlePitchMax"), -1 )
	self.mrGbMS.RunPitchFactor          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runPitchFactor"), -1 )
	self.mrGbMS.RunPitchMax             = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runPitchMax"), -1 )
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
		if xmlSource == "vehicle" then
			self.mrGbMS.BlowOffVentilVolume = 0
		else
			if self.mrGbMS.AutoStartStop then
				default = 1
			else
				default = 2
			end
			self.mrGbMS.BlowOffVentilVolume = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".blowOffVentilSound#volume" ), default ) * self.mrGbMG.blowOffVentilVol
		end
	else
		self.mrGbMS.BlowOffVentilFile = Utils.getFilename( self.mrGbMS.BlowOffVentilFile, self.baseDirectory )
	end
		
	if self.mrGbMS.GrindingSoundFile == nil then
		if xmlSource == "vehicle" then
			self.mrGbMS.GrindingSoundVolume = 0
		else
			self.mrGbMS.GrindingSoundVolume = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".grindingGearsSound#volume" ), 1.5 )
		end
	else
		self.mrGbMS.GrindingSoundFile = Utils.getFilename( self.mrGbMS.GrindingSoundFile, self.baseDirectory )
	end
		
--**************************************************************************************************	
-- Gears, Ranges, Reverse, ...
--**************************************************************************************************		
	local reverseMinGear  = getXMLInt(xmlFile, xmlString .. ".reverse#minGear")
	local reverseMaxGear  = getXMLInt(xmlFile, xmlString .. ".reverse#maxGear")
	local reverseMinRange = getXMLInt(xmlFile, xmlString .. ".reverse#minRange")
	local reverseMaxRange = getXMLInt(xmlFile, xmlString .. ".reverse#maxRange")
	local rangeGearOffset = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".ranges(0)#gearOffset"), 0) 
	local gearRangeOffset = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".gears#rangeOffset"), 0) 
	local minRatio        = 0.6
	local prevSpeed, gearTireRevPerKm, gearInvRadiusAxleSpeed
	self.mrGbMS.Gears     = {} 
	
	local b1, b2
	
--**************************************************************************************************		
	local i  = 0 
	local fo = false
	local ro = false
	while true do
		local baseName = xmlString .. string.format(".gears.gear(%d)", i) 		
		local speed    = getXMLFloat(xmlFile, baseName .. "#speed") 
		
		if speed==nil then
			local invRatio = getXMLFloat(xmlFile, baseName .. "#inverseRatio") 
			
			if invRatio ~= nil then
				if gearTireRevPerKm == nil then
					local radius = getXMLFloat(xmlFile, xmlString .. ".gears#wheelRadius" )
					if radius == nil then
						local w = getXMLFloat(xmlFile, xmlString .. ".gears#tireWidth" )
						local r = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".gears#tireRatio" ), 80 )
						local d = getXMLFloat(xmlFile, xmlString .. ".gears#rimDiameter" )
						if w ~= nil and d ~= nil then
							-- w is in mm
							-- r is in %
							-- d is in inch
							radius = w * r * 0.00001 + 0.0127 * d
						end
					end
					if radius == nil then
						radius = self.wheels[1].radius
					end
					gearTireRevPerKm = 1000 / ( 2 * math.pi * radius )
				end
				
				if gearInvRadiusAxleSpeed == nil then
					gearInvRadiusAxleSpeed = getXMLFloat(xmlFile, xmlString .. ".gears#axleSpeed" )
					if gearInvRadiusAxleSpeed == nil then
						gearInvRadiusAxleSpeed = self.mrGbMS.RatedRpm * 60 / ( 3.6 * self.motor.maxForwardSpeed * gearTireRevPerKm )
					end
				end
				
				speed = self.mrGbMS.RatedRpm * 60 / ( gearInvRadiusAxleSpeed * gearTireRevPerKm * invRatio )
			end
		end
		
		if speed==nil then
			local maxRatio = getXMLFloat(xmlFile, baseName .. "#maxForwardSpeedRatio") 
			if maxRatio ~= nil then
				speed = 3.6 * maxRatio * self.motor.maxForwardSpeed / self.mrGbMS.GlobalRatioFactor
			end
		end
		
		if speed==nil then
			break 
		end 
		
		local atRpm = getXMLFloat(xmlFile, baseName .. "#atRpm") 
		if atRpm ~= nil and atRpm > 0 then
			speed = speed * self.mrGbMS.RatedRpm / atRpm 
		end
		
		i = i + 1 
		local name  = Utils.getNoNil(getXMLString(xmlFile, baseName .. "#name"), tostring(i)) 

		local newEntry = gearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {speed=speed/3.6,name=name} )
		
		if newEntry.forwardOnly == nil and ( reverseMinGear ~= nil or reverseMaxGear ~= nil ) then
			newEntry.forwardOnly = not ( ( reverseMinGear == nil or i >= reverseMinGear ) and ( reverseMaxGear == nil or i <= reverseMaxGear ) )
		end		
		
		if newEntry.forwardOnly then fo = true end
		if newEntry.reverseOnly then ro = true end
			
		newEntry.upRangeOffset   = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#upRangeOffset" ),  -gearRangeOffset ) 
		newEntry.downRangeOffset = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#downRangeOffset" ), gearRangeOffset ) 
		
		local r = 0
		while true do
			local baseName2 = baseName .. string.format(".extraName(%d)",r)
			r = r + 1
			local extraName = getXMLString(xmlFile, baseName2 .. "#name")
			if extraName == nil then
				break
			end
			local r1 = Utils.getNoNil( getXMLInt( xmlFile, baseName2 .. "#range1" ),  0 ) 
			local r2 = Utils.getNoNil( getXMLInt( xmlFile, baseName2 .. "#range2" ),  0 ) 
			if newEntry.extraNames == nil then
				newEntry.extraNames = {}
			end
			if newEntry.extraNames[r1] == nil then
				newEntry.extraNames[r1] = {}
			end
			newEntry.extraNames[r1][r2] = extraName
		end
		
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
		local newEntry = {speed=self.motor.maxForwardSpeed/self.mrGbMS.GlobalRatioFactor,name=""} 
		table.insert(self.mrGbMS.Gears, newEntry)  -- m/s
	end 	
	
	b1 = getXMLBool(xmlFile, xmlString .. ".reverse#resetGear")
	b2 = getXMLBool(xmlFile, xmlString .. ".gears#reverseReset")
	if b1 == nil and b2 == nil then
		self.mrGbMS.ReverseResetGear = fo and ro
	else
		self.mrGbMS.ReverseResetGear = b1 or b2 
	end

			
--**************************************************************************************************		
	self.mrGbMS.Ranges = {} 
	i  = 0 
	fo = false
	ro = false
	local generateNames = true 
	while true do
		local baseName = xmlString .. string.format(".ranges(0).range(%d)", i) 		
		local ratio = getXMLFloat(xmlFile, baseName .. "#ratio") 
		if ratio==nil then
			local g = Utils.getNoNil( getXMLInt(xmlFile, baseName .. "#gear") , table.getn(self.mrGbMS.Gears) )
			local s = getXMLFloat(xmlFile, baseName .. "#speed") 
			if s ~= nil and self.mrGbMS.Gears[g] ~= nil then
				ratio = s / (3.6*self.mrGbMS.Gears[g].speed)
			end
		end 
		if ratio==nil then
			local invRatio = getXMLFloat(xmlFile, baseName .. "#inverseRatio") 
			if invRatio ~= nil then
				ratio=1/invRatio
			end
		end
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
		
		local newEntry = gearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {ratio=ratio,name=name} )
		
		if newEntry.forwardOnly then fo = true end
		if newEntry.reverseOnly then ro = true end
			
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
	
	b1 = getXMLBool(xmlFile, xmlString .. ".reverse#resetRange")
	b2 = getXMLBool(xmlFile, xmlString .. ".ranges(0)#reverseReset")
	if b1 == nil and b2 == nil then
		self.mrGbMS.ReverseResetRange = fo and ro
	else
		self.mrGbMS.ReverseResetRange = b1 or b2 
	end
	
--**************************************************************************************************		
	
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
	
--**************************************************************************************************		
	self.mrGbMS.Ranges2 = {} 
	i  = 0 
	fo = false
	ro = false
	while true do
		local baseName = xmlString .. string.format(".ranges(1).range(%d)", i) 		
		local ratio = getXMLFloat(xmlFile, baseName .. "#ratio") 
		if ratio==nil then
			local g = Utils.getNoNil( getXMLInt(xmlFile, baseName .. "#gear") , table.getn(self.mrGbMS.Gears) )
			local s = getXMLFloat(xmlFile, baseName .. "#speed") 
			if s ~= nil and self.mrGbMS.Gears[g] ~= nil then
				ratio = s / (3.6*self.mrGbMS.Gears[g].speed)
			end
		end 
		if ratio==nil then
			break 
		end 
		i = i + 1 
		
		local name = getXMLString(xmlFile, baseName .. "#name") 
		if name == nil then
			name = "G"..tostring(i) 
		end
		local newEntry = gearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {ratio=ratio,name=name} )
		
		if newEntry.forwardOnly then fo = true end
		if newEntry.reverseOnly then ro = true end
			
		table.insert(self.mrGbMS.Ranges2, newEntry)  -- m/s
	end 
	
	if i==0 then
		local newEntry = {ratio=1,name=""} 
		table.insert(self.mrGbMS.Ranges2, newEntry)  -- m/s
	end
		
	b1 = getXMLBool(xmlFile, xmlString .. ".ranges(1)#reverseReset")
	if b1 == nil then
		self.mrGbMS.ReverseResetRange2    = fo and ro
	else
		self.mrGbMS.ReverseResetRange2    = b1
	end

	--**************************************************************************************************		
	self.mrGbMS.ReverseRatio            = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. ".reverse#ratio"), 1) 

	
	local hasDefaultGear = true
	self.mrGbMS.DefaultGear        = getXMLInt(xmlFile, xmlString .. ".gears#defaultGear")
	if     self.mrGbMS.DefaultGear == nil
			or self.mrGbMS.DefaultGear  < 1 then
		self.mrGbMS.DefaultGear = 1
		hasDefaultGear          = false
	elseif self.mrGbMS.DefaultGear  > table.getn(self.mrGbMS.Gears) then
		self.mrGbMS.DefaultGear = table.getn(self.mrGbMS.Gears)
		hasDefaultGear          = false
	end
	if hasHydrostat and not hasDefaultGear then
		hasDefaultGear = true
		if self.mrGbMS.DisableManual then
			self.mrGbMS.DefaultGear = 1
		else
			self.mrGbMS.DefaultGear = table.getn(self.mrGbMS.Gears)
		end
	end
		
 	self.mrGbMS.DefaultRange       = getXMLInt(xmlFile, xmlString .. ".ranges(0)#defaultRange")
	if     self.mrGbMS.DefaultRange == nil
			or self.mrGbMS.DefaultRange  > table.getn(self.mrGbMS.Ranges) then
		self.mrGbMS.DefaultRange     = table.getn(self.mrGbMS.Ranges)
	elseif self.mrGbMS.DefaultRange  < 1 then
		self.mrGbMS.DefaultRange     = 1
	end
	
	self.mrGbMS.DefaultRange2      = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. ".ranges(1)#defaultRange"), table.getn(self.mrGbMS.Ranges2)) 
	if     self.mrGbMS.DefaultRange2 == nil
			or self.mrGbMS.DefaultRange2  > table.getn(self.mrGbMS.Ranges2) then
		self.mrGbMS.DefaultRange2    = table.getn(self.mrGbMS.Ranges2)
	elseif self.mrGbMS.DefaultRange2  < 1 then
		self.mrGbMS.DefaultRange2    = 1
	end
	
	self.mrGbMS.ReverseActive      = true	
	self.mrGbMS.ResetRevGear       = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.DefaultGear, self.mrGbMS.DefaultGear, "gear" )
	self.mrGbMS.ResetRevRange      = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.DefaultRange, self.mrGbMS.DefaultRange, "range" )
	self.mrGbMS.ResetRevRange2     = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.DefaultRange2, self.mrGbMS.DefaultRange2, "range2" )
	
	self.mrGbMS.ReverseActive      = false	
	self.mrGbMS.ResetFwdGear       = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.DefaultGear, self.mrGbMS.DefaultGear, "gear" )
	self.mrGbMS.ResetFwdRange      = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.DefaultRange, self.mrGbMS.DefaultRange, "range" )
	self.mrGbMS.ResetFwdRange2     = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.DefaultRange2, self.mrGbMS.DefaultRange2, "range2" )
	
	local defaultLaunchSpeed       = 10
	
	if hasDefaultGear then
		defaultLaunchSpeed           = self.mrGbMS.Gears[self.mrGbMS.DefaultGear].speed
																 * self.mrGbMS.Ranges[self.mrGbMS.DefaultRange].ratio
																 * self.mrGbMS.Ranges2[self.mrGbMS.DefaultRange2].ratio
																 * self.mrGbMS.GlobalRatioFactor
																 * 3.6
  end	
	if hasHydrostat then
		defaultLaunchSpeed           = 3.6
	end
	self.mrGbMS.LaunchGearSpeed    = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. "#launchGearSpeed"), defaultLaunchSpeed ) / 3.6
	if not hasDefaultGear then
		local r = self.mrGbMS.Ranges[self.mrGbMS.DefaultRange].ratio
						* self.mrGbMS.Ranges2[self.mrGbMS.DefaultRange2].ratio
						* self.mrGbMS.GlobalRatioFactor
						* 3.6
		local d = nil
		for i,g in pairs(self.mrGbMS.Gears) do
			if not ( g.reverseOnly ) then
				local s = math.abs( r * g.speed - self.mrGbMS.LaunchGearSpeed )
				if d == nil or d > s then
					self.mrGbMS.DefaultGear = i
					d = s
				end
			end
		end
	end
	
	-- start with 7 km/h with "drueckung" 15% => 8 km/h
	self.mrGbMS.LaunchPtoSpeed     = Utils.getNoNil(getXMLInt(xmlFile, xmlString .. "#ptolaunchSpeed"), 8 ) / 3.6 
	self.mrGbMS.MatchRanges        = getXMLString(xmlFile, xmlString .. ".ranges(0)#speedMatching")
  self.mrGbMS.MatchGears         = getXMLString(xmlFile, xmlString .. ".gears#speedMatching")
	
	if      self.mrGbMS.MatchRanges == nil 
			and self.mrGbMS.MatchGears  == nil then
		if      self.mrGbMS.AutoShiftGears
				and self.mrGbMS.AutoShiftHl then
			-- gears and ranges are already shifted automatic
			self.mrGbMS.MatchGears  = "false"
			self.mrGbMS.MatchRanges = "false"
		elseif  self.mrGbMS.GearShiftEffectGear then
			-- default speed matching for power shift 
			self.mrGbMS.MatchGears  = "true"
			self.mrGbMS.MatchRanges = "false"
		elseif  self.mrGbMS.GearShiftEffectHl   then
			-- default speed matching for power shift 
			self.mrGbMS.MatchGears  = "false"
			self.mrGbMS.MatchRanges = "true"
		elseif  self.mrGbMS.AutoShiftGears then
			-- find best gear (automatic)
			self.mrGbMS.MatchGears  = "true"
			self.mrGbMS.MatchRanges = "false"
		elseif  self.mrGbMS.AutoShiftHl then
			-- find best range (automatic)
			self.mrGbMS.MatchGears  = "false"
			self.mrGbMS.MatchRanges = "true"
		else
			local r1,rp,rl, g1,gp,gl
			for _,r in pairs(self.mrGbMS.Ranges) do
				if not ( r.reverseOnly ) then
					if r1 == nil then
						r1 = r.ratio
						rp = r.ratio 
						rl = r.ratio 
					end
					if r1 > r.ratio then
						r1 = r.ratio 
					end 
					if rl < r.ratio then
						rp = rl
						rl = r.ratio 
					elseif rl > r.ratio and r.ratio > rp then
						rp = r.ratio
					end
				end
			end
			for _,g in pairs(self.mrGbMS.Gears) do
				if not ( g.reverseOnly ) then
					if g1 == nil then
						g1 = g.speed
						gp = g.speed 
						gl = g.speed 
					end
					if g1 > g.speed then
						g1 = g.speed 
					end 
					if gl < g.speed then
						gp = gl
						gl = g.speed 
					elseif gl > g.speed and g.speed > gp then
						gp = g.speed 
					end
				end
			end
			
			if     r1 == nil 
					or g1 == nil 
					or r1 == rl
					or g1 == gl then
				-- not more than one gear and more than one range
				self.mrGbMS.MatchRanges = "false"
				self.mrGbMS.MatchGears  = "false"
			elseif rp * gl < rl * g1 then
				-- 2nd last range in last gear is smaller then last range in 1st gear
				self.mrGbMS.MatchRanges = "false"
				self.mrGbMS.MatchGears  = "true"
			elseif self.mrGbMS.SwapGearRangeKeys then
				-- gears and ranges are swapped 
				self.mrGbMS.MatchRanges = "end"
				self.mrGbMS.MatchGears  = "false"
			else 
				self.mrGbMS.MatchRanges = "false"
				self.mrGbMS.MatchGears  = "end"
			end
		end
	elseif  self.mrGbMS.MatchRanges == nil then
		self.mrGbMS.MatchRanges = "false"
	elseif  self.mrGbMS.MatchGears  == nil then
		self.mrGbMS.MatchGears  = "false"
	end
	
--**************************************************************************************************	
-- speed matching disabled via global settings
	if self.mrGbMG.noSpeedMatching then
		self.mrGbMS.MatchRanges          = "false"
		self.mrGbMS.MatchGears           = "false"
		self.mrGbMS.StartInSmallestGear  = false
		self.mrGbMS.StartInSmallestRange = false
	end
	
--**************************************************************************************************	
-- Hydrostatic
--**************************************************************************************************			
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
		
		table.insert(self.mrGbMS.HydrostaticEfficiency, {time=ratio,v=factor})  
	end 

	self.mrGbMS.HydrostaticVolumePump     = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#volumePump")
	self.mrGbMS.HydrostaticVolumeMotor    = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#volumeMotor")
	self.mrGbMS.HydrostaticPressure       = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#pressure")
	self.mrGbMS.HydrostaticCoupling       = getXMLString(xmlFile,xmlString .. ".hydrostatic#coupling")
	self.mrGbMS.HydrostaticMaxTorque      = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxTorque")
	if self.mrGbMS.HydrostaticMaxTorque ~= nil then
		self.mrGbMS.HydrostaticMaxTorque = self.mrGbMS.HydrostaticMaxTorque * 0.001
	end
	local hit = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#minMaxTimeMs")
	local hdt = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxMinTimeMs")
	self.mrGbMS.HydrostaticDirect         = getXMLBool(xmlFile, xmlString .. ".hydrostatic#direct")

	if i <= 0 then
		self.mrGbMS.HydrostaticProfile = getXMLString(xmlFile, xmlString .. ".hydrostatic#profile")
	  
		if self.mrGbMS.HydrostaticProfile == nil then
		elseif self.mrGbMS.HydrostaticProfile == "ZF"   then
			print('FS17_GearboxAddon: Warning! Hydrostatic profile "ZF" is out dated. Please use "Input" instead')
			self.mrGbMS.HydrostaticProfile = "Input"
		elseif self.mrGbMS.HydrostaticProfile == "Fendt"   then
			print('FS17_GearboxAddon: Warning! Hydrostatic profile "Fendt" is out dated. Please use "Output" instead and adjust the gear ratios.')
			self.mrGbMS.HydrostaticProfile = "Output"
			if not ( getXMLBool(xmlFile, xmlString .. ".hydrostatic#correctGearSpeed") ) then
				for i,g in pairs(self.mrGbMS.Gears) do
					g.speed = g.speed * 1.333333333
				end
			end
		elseif self.mrGbMS.HydrostaticProfile == "Combine" then
			print('FS17_GearboxAddon: Warning! Hydrostatic profile "Combine" is out dated. Please use "Direct" instead and adjust the gear ratios.')
			self.mrGbMS.HydrostaticProfile = "Direct"
			if not ( getXMLBool(xmlFile, xmlString .. ".hydrostatic#correctGearSpeed") ) then
				for i,g in pairs(self.mrGbMS.Gears) do
					g.speed = g.speed * 1.4
				end
			end
		end
		
		if self.mrGbMS.HydrostaticProfile == nil then
			-- nothing 
		elseif self.mrGbMS.HydrostaticProfile == "Input" then
			self.mrGbMS.HydrostaticMin = 0
			self.mrGbMS.HydrostaticMax = 1.333333333
			self.mrGbMS.TransmissionEfficiency = 0.98
		--self.mrGbMS.HydrostaticMaxTorque   = 1.1 * maxTorque
			self.mrGbMS.HydrostaticEfficiency  = {}
			
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.00,v=gearboxMogli.hydroEffMin })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.05,v=0.500})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.22,v=0.680})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.67,v=0.870})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.80,v=0.930})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.90,v=0.970})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.95,v=0.978})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.00,v=0.980})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.04,v=0.970})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.10,v=0.945})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.20,v=0.920})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.33,v=0.890})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.50,v=0.860})
			
			i = table.getn( self.mrGbMS.HydrostaticEfficiency )
		elseif self.mrGbMS.HydrostaticProfile == "Output" then
			self.mrGbMS.HydrostaticMin = -0.7
			self.mrGbMS.HydrostaticMax = 1
			self.mrGbMS.TransmissionEfficiency = 0.98
		--self.mrGbMS.HydrostaticMaxTorque   = 2 * maxTorque
			self.mrGbMS.HydrostaticEfficiency  = {}

			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-1	 ,v=0.65 })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.01,v=0.82 })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0	   ,v=gearboxMogli.hydroEffMin })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.01 ,v=0.825})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1	   ,v=0.98 })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.5  ,v=0.89 })

			i = table.getn( self.mrGbMS.HydrostaticEfficiency )
		elseif self.mrGbMS.HydrostaticProfile == "Direct" then
			self.mrGbMS.HydrostaticMin = -1
			self.mrGbMS.HydrostaticMax = 1
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticPtoDiff     = 200
			self.mrGbMS.HydrostaticEfficiency  = {}
		
			if self.mrGbMS.HydrostaticDirect == nil then 
				self.mrGbMS.HydrostaticDirect = true 
			end

			for i,g in pairs(self.mrGbMS.Gears) do
				if g.forwardOnly or g.reverseOnly then
					self.mrGbMS.HydrostaticMin = 0
					break
				end
			end
			
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-1 , v=0.87})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.85 , v=0.92})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.7 , v=0.93})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.5 , v=0.87})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.15 , v=0.71})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.01 , v=0.6})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0 , v=gearboxMogli.hydroEffMin })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.01 , v=0.6})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.15 , v=0.75})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.3 , v=0.85})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.5 , v=0.93})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.65 , v=0.975})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.7 , v=0.98})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.75 , v=0.975})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.85 , v=0.95})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1 , v=0.9})

			i = table.getn( self.mrGbMS.HydrostaticEfficiency )
		elseif self.mrGbMS.HydrostaticProfile == "Compound" then
			self.mrGbMS.HydrostaticMin = 0
			self.mrGbMS.HydrostaticMax = 1
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticEfficiency  = {}

			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0 , v=gearboxMogli.hydroEffMin })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.01 , v=0.57})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.07 , v=0.75})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.1 , v=0.81})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.17 , v=0.96})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.18 , v=0.97})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.19 , v=0.977})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.2 , v=0.98})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.21 , v=0.975})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.22 , v=0.94})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.23 , v=0.925})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.25 , v=0.92})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.3 , v=0.918})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.35 , v=0.92})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.4 , v=0.935})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.48 , v=0.965})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.49 , v=0.969})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.5 , v=0.97})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.51 , v=0.968})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.52 , v=0.96})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.53 , v=0.94})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.54 , v=0.9})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.55 , v=0.88})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.56 , v=0.88})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.6 , v=0.89})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.65 , v=0.895})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.7 , v=0.9})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.8 , v=0.908})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1 , v=0.91})

			i = table.getn( self.mrGbMS.HydrostaticEfficiency )
		else
			print('FS17_GearboxAddon: Error! Invalid hydrostatic profile "'..tostring(self.mrGbMS.HydrostaticProfile)..'"')
			self.mrGbMS.HydrostaticProfile = "Direct"
		end
	end
	
	if     i > 0 
			or self.mrGbMS.HydrostaticProfile     ~= nil 
			or self.mrGbMS.HydrostaticPressure    ~= nil 
			or self.mrGbMS.HydrostaticVolumePump  ~= nil
			or self.mrGbMS.HydrostaticVolumeMotor ~= nil 
			or self.mrGbMS.HydrostaticCoupling    ~= nil then		
			
		self.mrGbMS.Hydrostatic = true
		
		if     self.mrGbMS.HydrostaticPressure    ~= nil 
				or self.mrGbMS.HydrostaticVolumePump  ~= nil
				or self.mrGbMS.HydrostaticVolumeMotor ~= nil 
				or self.mrGbMS.HydrostaticCoupling    ~= nil then
				
			print("FS17_GearboxAddon: Warning! Hydrostatic coupling is only experimental")
				
			self.mrGbMS.HydrostaticMin       = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#minRatio"), -1 )
			self.mrGbMS.HydrostaticMax       = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRatio"), 1.41421356 )
			
			if self.mrGbMS.HydrostaticPressure == nil then
				self.mrGbMS.HydrostaticPressure = 400
			end
			
			if self.mrGbMS.HydrostaticCoupling == nil then
				self.mrGbMS.HydrostaticCoupling = "direct"
			end
			
			if self.mrGbMS.HydrostaticVolumePump  == nil and self.mrGbMS.HydrostaticVolumeMotor == nil then
				self.mrGbMS.HydrostaticVolumePump   = 20000 * self.mrGbMS.HydrostaticMaxTorque * math.pi / self.mrGbMS.HydrostaticPressure
				self.mrGbMS.HydrostaticVolumeMotor  = self.mrGbMS.HydrostaticVolumePump
			elseif self.mrGbMS.HydrostaticVolumeMotor == nil then
				self.mrGbMS.HydrostaticVolumeMotor  = self.mrGbMS.HydrostaticVolumePump
			elseif self.mrGbMS.HydrostaticVolumePump == nil then
				self.mrGbMS.HydrostaticVolumePump   = self.mrGbMS.HydrostaticVolumeMotor
			end
		end
	
		if i > 0 then
			local tmp
			tmp = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#minRatio")
			if      tmp ~= nil 
					and self.mrGbMS.HydrostaticEfficiency[1].time <= tmp 
					and tmp < self.mrGbMS.HydrostaticEfficiency[i].time then
				self.mrGbMS.HydrostaticMin = tmp
			end
			tmp = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRatio")
			if      tmp ~= nil 
					and self.mrGbMS.HydrostaticEfficiency[1].time < tmp 
					and tmp <= self.mrGbMS.HydrostaticEfficiency[i].time then
				self.mrGbMS.HydrostaticMax = tmp
			end	
		end	
	
		local dft
		if self.mrGbMS.HydrostaticMaxRpm == nil then
			dft = self.mrGbMS.CurMaxRpm
			if self.mrGbMS.MaxSpeedLimiter then
				dft = self.mrGbMS.RatedRpm
			end
			self.mrGbMS.HydrostaticMaxRpm = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxWheelRpm"), dft )
		end
		if self.mrGbMS.HydrostaticStart == nil then
			dft = Utils.clamp( 0, self.mrGbMS.HydrostaticMin, self.mrGbMS.HydrostaticMax )
			self.mrGbMS.HydrostaticStart  = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#startFactor"), dft )
		end
		if self.mrGbMS.HydrostaticPtoDiff == nil then
			dft = gearboxMogli.ptoRpmThrottleDiff
			self.mrGbMS.HydrostaticPtoDiff = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#ptoRpmDelta"), dft )
		end
		
		dft = Utils.getNoNil( hit, 5000 )
		if dft < 100 then
			-- do not smooth 
			self.mrGbMS.HydrostaticIncFactor = 1
		else
			self.mrGbMS.HydrostaticIncFactor = 1 / dft
		end
		dft = Utils.getNoNil( hdt, 5000 )
		if hdt == nil and hit ~= nil then
			-- compatibility
			self.mrGbMS.HydrostaticDecFactor = self.mrGbMS.HydrostaticIncFactor
		elseif dft < 100 then
			-- do not smooth 
			self.mrGbMS.HydrostaticDecFactor = 1
		else
			self.mrGbMS.HydrostaticDecFactor = 1 / dft
		end
		
		local sc = getXMLBool(xmlFile, xmlString .. ".hydrostatic#startWithClutch")
		if sc == nil then
			local smallestGearSpeed  = self.mrGbMS.Gears[1].speed 
															* self.mrGbMS.Ranges[1].ratio 
															* self.mrGbMS.Ranges2[1].ratio
															* self.mrGbMS.GlobalRatioFactor
															* self.mrGbMS.HydrostaticMin
															* 3.6
			
			if smallestGearSpeed < 1 then
				self.mrGbMS.HydrostaticLaunch = true
			else                            
				self.mrGbMS.HydrostaticLaunch = false
			end
		else
			self.mrGbMS.HydrostaticLaunch = not ( sc )
		end
		
		if      self.mrGbMS.HydrostaticMax > gearboxMogli.eps 
				and math.abs( self.mrGbMS.HydrostaticMax - 1 ) > gearboxMogli.eps 
				and getXMLBool(xmlFile, xmlString .. ".hydrostatic#correctGearSpeed") then
			for i,g in pairs( self.mrGbMS.Gears ) do
				g.speed = g.speed / self.mrGbMS.HydrostaticMax
			end
		end
	else
		self.mrGbMS.Hydrostatic         = false
	end

--**************************************************************************************************	
-- misc. parameter
--**************************************************************************************************		
	self.mrGbMS.PowerManagement = getXMLBool(xmlFile, xmlString .. "#powerManagement")
	if self.mrGbMS.PowerManagement == nil then
		if     self.mrGbMS.Hydrostatic then
			if     self.mrGbMS.HydrostaticCoupling == nil 
					or self.mrGbMS.HydrostaticCoupling ~= "direct" then
				self.mrGbMS.PowerManagement = true
			end
		elseif self.mrGbMS.AutoShiftGears
			  or self.mrGbMS.AutoShiftHl
				or self.mrGbMS.AutoShiftRange2 then
			self.mrGbMS.PowerManagement = true
		else
			self.mrGbMS.PowerManagement = false
		end
	end
	
	if not ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 ) then
		self.mrGbMS.DisableManual       = false
	end
	
	self.mrGbMS.AutoShiftTimeoutLong  = gearboxMogli.getNoNil2(getXMLFloat(xmlFile, xmlString .. ".gears#autoShiftTimeout"),  self.mrGbMG.autoShiftTimeoutLong , self.mrGbMG.autoShiftTimeoutHydroL, self.mrGbMS.Hydrostatic and self.mrGbMS.DisableManual )
	self.mrGbMS.AutoShiftTimeoutShort = gearboxMogli.getNoNil2(getXMLFloat(xmlFile, xmlString .. ".gears#autoShiftTimeout2"), self.mrGbMG.autoShiftTimeoutShort, self.mrGbMG.autoShiftTimeoutHydroS, self.mrGbMS.Hydrostatic and self.mrGbMS.DisableManual )
		
	if self.mrGbMS.AutoShiftTimeoutShort > self.mrGbMS.AutoShiftTimeoutLong then
		self.mrGbMS.AutoShiftTimeoutShort = self.mrGbMS.AutoShiftTimeoutLong
	end
	
	autoShiftPriorityG = getXMLFloat(xmlFile, xmlString .. ".gears#autoShiftPriority")
	autoShiftPriorityR = getXMLFloat(xmlFile, xmlString .. ".ranges(0)#autoShiftPriority")
	autoShiftPriority2 = getXMLFloat(xmlFile, xmlString .. ".ranges(1)#autoShiftPriority")	
	
	self.mrGbMS.AutoShiftPriorityG = 0
	self.mrGbMS.AutoShiftPriorityR = 0
	self.mrGbMS.AutoShiftPriority2 = 0
	
	do
		local p = {}
		
		table.insert( p, { p=autoShiftPriorityG, t=self.mrGbMS.GearTimeToShiftGear   , c="AutoShiftPriorityG" } )
		table.insert( p, { p=autoShiftPriorityR, t=self.mrGbMS.GearTimeToShiftHl     , c="AutoShiftPriorityR" } )
		table.insert( p, { p=autoShiftPriority2, t=self.mrGbMS.GearTimeToShiftRanges2, c="AutoShiftPriority2" } )
		
		table.sort( p, function(a,b) if a.p == nil or b.p == nil then return a.t<b.t end return a.p<b.p end )
		
		local p0 = 0
		local lp = nil
		local lt = nil
		for i,q in pairs(p) do
		--print(tostring(i).." "..tostring(q.c).." "..tostring(q.t).." "..tostring(q.p))
			
			if not ( ( q.p ~= nil and lp ~= nil and q.p == lp )
						or ( q.p == nil and lp == nil and lt ~= nil and q.t == lt ) ) then				
				p0 = p0 + 1
			end
			
			self.mrGbMS[q.c] = p0
			lp = q.p
			lt = q.t
		end
	end
--print("priorities: "..tostring(self.mrGbMS.AutoShiftPriorityG)..", "..tostring(self.mrGbMS.AutoShiftPriorityR)..", "..tostring(self.mrGbMS.AutoShiftPriority2))
	
	self.mrGbMS.StartInSmallestGear  = getXMLBool(xmlFile, xmlString .. ".gears#startInSmallest")
	self.mrGbMS.StartInSmallestRange = getXMLBool(xmlFile, xmlString .. ".ranges(0)#startInSmallest")

	if self.mrGbMS.StartInSmallestGear == nil then
		if     table.getn( self.mrGbMS.Ranges ) < 2
				or self.mrGbMS.GearTimeToShiftGear  > self.mrGbMG.shiftEffectTime 
				or self.mrGbMS.GearTimeToShiftGear  > self.mrGbMS.GearTimeToShiftHl then
			self.mrGbMS.StartInSmallestGear = false
		else
			self.mrGbMS.StartInSmallestGear = true
		end
	end
	
	if self.mrGbMS.StartInSmallestRange == nil then
		if     table.getn( self.mrGbMS.Gears )  < 2
				or self.mrGbMS.StartInSmallestGear
				or self.mrGbMS.GearTimeToShiftHl    > self.mrGbMG.shiftEffectTime 
				or self.mrGbMS.GearTimeToShiftHl    > self.mrGbMS.GearTimeToShiftGear then
			self.mrGbMS.StartInSmallestRange = false
		else
			self.mrGbMS.StartInSmallestRange = true
		end
	end
	
	local enableAI = getXMLBool( xmlFile, xmlString .. "#enableAI" )
	if enableAI == nil then
		if     self.mrGbMS.Hydrostatic then
			self.mrGbMS.EnableAI = gearboxMogli.AIGearboxOn
		else
			self.mrGbMS.EnableAI = self.mrGbMG.defaultEnableAI
		end
	elseif enableAI then
		self.mrGbMS.EnableAI = gearboxMogli.AIGearboxOn
	else
		self.mrGbMS.EnableAI = gearboxMogli.AIGearboxOff
	end	
	
	self.mrGbMS.MaxAIGear   = getXMLInt(xmlFile, xmlString .. "#maxAIGear")
	self.mrGbMS.MaxAIRange  = getXMLInt(xmlFile, xmlString .. "#maxAIRange")
	self.mrGbMS.MaxAIRange2 = getXMLInt(xmlFile, xmlString .. "#maxAIRange2")

	if self.mrGbMS.Run2PitchEffect == nil then
		if self.mrGbMS.Hydrostatic then
			self.mrGbMS.Run2PitchEffect = 0
		elseif self.mrGbMS.AutoShiftGears then
			self.mrGbMS.Run2PitchEffect = 0.1
		else
			self.mrGbMS.Run2PitchEffect = 0
		end
	end
	
	self.mrGbMS.G27Gears = {} 
	local revereGear     = nil
	local defaultGear    = self.mrGbMS.DefaultGear
	local g27Entries     = self.mrGbMS.Gears 
	if self.mrGbMS.SwapGearRangeKeys then
		defaultGear = self.mrGbMS.DefaultRange
		g27Entries  = self.mrGbMS.Ranges 
	end
	
	for i,entry in pairs( g27Entries ) do
		if not ( entry.reverseOnly ) then
			local j=1
			while self.mrGbMS.G27Gears[j] ~= nil do
				j = j + 1
			end
			if j > 7 then
				for j=1,6 do
					self.mrGbMS.G27Gears[j] = self.mrGbMS.G27Gears[j+1]
				end
				self.mrGbMS.G27Gears[7] = i
			else
				self.mrGbMS.G27Gears[j] = i
			end
			
		elseif ( revereGear == nil or i < defaultGear ) then
			revereGear = i
		end
	end
	
	if revereGear ~= nil then
		if self.mrGbMS.G27Gears[7] ~= nil then
			for j=1,6 do
				self.mrGbMS.G27Gears[j] = self.mrGbMS.G27Gears[j+1]
			end
		end
		self.mrGbMS.G27Gears[7] = -revereGear
	end
	for j=1,7 do
		if self.mrGbMS.G27Gears[j] == nil then
			self.mrGbMS.G27Gears[j] = 0
		end
	end

	self.mrGbMS.sendTargetRpm   = self.mrGbMS.drawTargetRpm
	self.mrGbMS.sendReqPower    = self.mrGbMG.drawReqPower
	self.mrGbMS.sendHydro       = false
	
	if self.mrGbMS.OnlyHandThrottle then
		self.mrGbMS.sendHydro     = true
		self.mrGbMS.sendTargetRpm = true
	end
	
	self.mrGbMS.MaxGearSpeed = 0
	for i,g in pairs( self.mrGbMS.Gears ) do
		if self.mrGbMS.MaxGearSpeed < g.speed then
			self.mrGbMS.MaxGearSpeed = g.speed 
		end
	end

	local rr1 = 1
	for i,r in pairs( self.mrGbMS.Ranges ) do
		if rr1 < r.ratio then
			rr1 = r.ratio 
		end
	end
	local rr2 = 1
	for i,r in pairs( self.mrGbMS.Ranges2 ) do
		if rr2 < r.ratio then
			rr2 = r.ratio 
		end
	end

	if rr1 > 1 or rr2 > 1 then
		self.mrGbMS.MaxGearSpeed = self.mrGbMS.MaxGearSpeed * rr1 * rr2 
	end
	if self.mrGbMS.ReverseRatio > 1 then
		self.mrGbMS.MaxGearSpeed = self.mrGbMS.MaxGearSpeed * self.mrGbMS.ReverseRatio 
	end
	self.mrGbMS.MaxGearSpeed = self.mrGbMS.MaxGearSpeed * self.mrGbMS.GlobalRatioFactor
	
	self.mrGbMS.NormSpeedFactorS = 255 / self.mrGbMS.MaxGearSpeed
	self.mrGbMS.NormSpeedFactorC = 3.6 / self.mrGbMS.NormSpeedFactorS
	
--**********************************************************************************************************		
-- sound 
--**********************************************************************************************************		

	self.mrGbMS.EqualizedRpmFactor = ( self.mrGbMS.Sound.MaxRpm - self.mrGbMS.OrigMinRpm ) / ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) 
	self.mrGbMS.EqualizedMaxRpm    = self:mrGbMGetEqualizedRpm( self.mrGbMS.CurMaxRpm )
	do
		-- original RPM range
		local rpmRange  = self.mrGbMS.OrigMaxRpm - self.mrGbMS.OrigMinRpm		
		-- scale pitch max to wider RPM range => original pitch at new rated RPM plus 100
		local rpmFactor = self.mrGbMS.EqualizedMaxRpm / self.mrGbMS.Sound.MaxRpm		
		local rpsRange  = rpmRange / 60
				
		local function soundHelper( sound, pitchScale, pitchMax, factor, newMax )
			local s = pitchScale
			local m = pitchMax 
			
			if sound.sample ~= nil then
				if factor < 0 and newMax < 0 then 
					m = sound.pitchOffset + math.min( pitchMax - sound.pitchOffset, pitchScale * rpsRange )
				else
					if factor > 0 then
						s = pitchScale * factor
					end
					
					if     newMax < 0 then 
						m = sound.pitchOffset + s * rpsRange
					elseif newMax > 0 then 
						m = sound.pitchOffset + ( newMax - sound.pitchOffset ) * rpmFactor
					else
						m = pitchMax
					end 
				end 
				
				if factor < 0 then
					s = ( m - sound.pitchOffset ) / rpsRange
				end
				
				m = math.max( m * rpmFactor, pitchMax )
			end
						
			return s, m
		end
		
		self.mrGbMS.Sound.IdlePitchScale, self.mrGbMS.Sound.IdlePitchMax = soundHelper( self.sampleMotor,     self.motorSoundPitchScale,     self.motorSoundPitchMax,     self.mrGbMS.IdlePitchFactor, self.mrGbMS.IdlePitchMax )
		self.mrGbMS.Sound.RunPitchScale,  self.mrGbMS.Sound.RunPitchMax  = soundHelper( self.sampleMotorRun,  self.motorSoundRunPitchScale,  self.motorSoundRunPitchMax,  self.mrGbMS.RunPitchFactor,  self.mrGbMS.RunPitchMax  )
		self.mrGbMS.Sound.LoadPitchScale, self.mrGbMS.Sound.LoadPitchMax = soundHelper( self.sampleMotorLoad, self.motorSoundLoadPitchScale, self.motorSoundLoadPitchMax, self.mrGbMS.RunPitchFactor,  self.mrGbMS.RunPitchMax  )		
		self.mrGbMS.Sound.LoadMinimalVolumeFactor = self.motorSoundLoadMinimalVolumeFactor
		self.mrGbMS.Sound.ReverseDriveSample = self.sampleReverseDrive.sample
	end
	
--**********************************************************************************************************		
-- server fields...	
--**********************************************************************************************************		
	if not ( serverAndClient ) then
		for n,_ in pairs(self.mrGbMS) do
			if not ( excludeList[n] ) then
				gearboxMogli.registerServerField( self, n )
			end
		end	
	end	
--**************************************************************************************************	
	
-- set the default values for SERVER		
	self.mrGbMS.Automatic     = self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2
	self.mrGbMS.IsOnOff       = self.mrGbMS.DefaultOn
	self.mrGbMS.NeutralActive = self.mrGbMS.AutoStartStop	
	self.mrGbMS.CurrentGear   = self.mrGbMS.DefaultGear
	self.mrGbMS.CurrentRange  = self.mrGbMS.DefaultRange
	self.mrGbMS.CurrentRange2 = self.mrGbMS.DefaultRange2
	self.mrGbMS.NewGear       = self.mrGbMS.DefaultGear
	self.mrGbMS.NewRange      = self.mrGbMS.DefaultRange
	self.mrGbMS.NewRange2     = self.mrGbMS.DefaultRange2
	self.mrGbMS.ManualClutch  = 1
-- set the default values for SERVER		
--**********************************************************************************************************		


--**********************************************************************************************************		
-- Try to initialize motor during load
--**********************************************************************************************************		
	if self.mrGbMG.initMotorOnLoad and self.motor ~= nil and self.motor.minRpm ~= nil and self.motor.minRpm > 0 then
		self.mrGbML.motor = gearboxMogliMotor:new( self, self.motor )			
		if self.mrGbML.motor ~= nil then
			self.mrGbMB.motor = self.motor	
		end
	end
	self.mrGbMB.cruiseControlMaxSpeed = self.cruiseControl.maxSpeed
--**********************************************************************************************************		
  
	self.mrGbML.smoothSlow   = 1
	self.mrGbML.smoothMedium = 1
	self.mrGbML.smoothFast   = 1
	self.mrGbML.smoothLittle = 1
end
		
--**********************************************************************************************************	
-- gearboxMogli.getSmoothBase
--**********************************************************************************************************	
function gearboxMogli.getSmoothBase( dt )	
	if     gearboxMogli.lastSmoothBaseV  == nil
			or gearboxMogli.lastSmoothBaseDt == nil
			or gearboxMogli.lastSmoothBaseDt ~= dt then
		gearboxMogli.lastSmoothBaseV  = 0.3 * ( dt * 0.06 + math.sqrt( dt * 0.06 ) )
		gearboxMogli.lastSmoothBaseDt = dt
	end
	return gearboxMogli.lastSmoothBaseV
end

--**********************************************************************************************************	
-- gearboxMogli:checkIfReady
--**********************************************************************************************************	
function gearboxMogli:checkIfReady( noEventSend )
	if self.mrGbMS == nil then
		print("FS17_GearboxAddon: Error! GearboxAddon not initialized")
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
		print("FS17_GearboxAddon: Error! Client initialization failed")
		self:mrGbMSetState( "IsOn", false, noEventSend )
		return 
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mbIsSoundActive
--**********************************************************************************************************	
function gearboxMogli:mbIsSoundActive()
	if self.isClient and self.isMotorStarted then -- and ( self.isEntered or not ( self.steeringEnabled ) ) then
		return true
	end
	return false
end
		
--**********************************************************************************************************	
-- gearboxMogli:mbIsActiveForInput
--**********************************************************************************************************	
function gearboxMogli:mbIsActiveForInput(onlyTrueIfSelected)
  if not ( self.isEntered ) or g_gui.currentGui ~= nil or g_currentMission.isPlayerFrozen then
    return false
  end
  if onlyTrueIfSelected == nil or onlyTrueIfSelected then
    return self.selectedImplement == nil
	end
  return true
end

--**********************************************************************************************************	
-- gearboxMogli:update
--**********************************************************************************************************	
function gearboxMogli:update(dt)

	if self.mrGbMS == nil then
		return
	end

	if self.mrGbML.updateStreamErrors > 10 and not self.mrGbMS.NoUpdateStream then
		self:mrGbMSetState( "NoUpdateStream", true )
	end
	
	self.mrGbML.smoothBase   = gearboxMogli.getSmoothBase( dt )
	self.mrGbML.smoothSlow   = Utils.clamp( gearboxMogli.smoothSlow   * self.mrGbML.smoothBase, 0, 1 )
	self.mrGbML.smoothMedium = Utils.clamp( gearboxMogli.smoothMedium	* self.mrGbML.smoothBase, 0, 1 )
	self.mrGbML.smoothFast   = Utils.clamp( gearboxMogli.smoothFast   * self.mrGbML.smoothBase, 0, 1 )
	self.mrGbML.smoothLittle = Utils.clamp( gearboxMogli.smoothLittle * self.mrGbML.smoothBase, 0, 1 )
	
	if self.actualLoadPercentage == nil or not ( self.isMotorStarted ) then
		self.mrGbML.MotorLoad = 0
	else
		self.mrGbML.MotorLoad = self.mrGbML.MotorLoad + self.mrGbML.smoothMedium * ( self.actualLoadPercentage - self.mrGbML.MotorLoad )
	end
	
	local processInput = true
	
	self.motorSoundLoadMinimalVolumeFactor = self.mrGbMS.Sound.LoadMinimalVolumeFactor
	
	if     self.hasChangedGearBoxAddon then
	-- IncreaseRPMWhileTipping.lua
		if not self.mrGbMS.IsOnOff then
			self:mrGbMSetState( "IsOn", false ) 		
			self.mrGbML.turnedOffByIncreaseRPMWhileTipping = true
		end
		processInput = false
	elseif self.mrGbMS.NoDisable then
		self:mrGbMSetIsOnOff( true ) 
	elseif gearboxMogli.mbIsActiveForInput(self, false) and gearboxMogli.mbHasInputEvent( "gearboxMogliON_OFF" ) then
		if     self:getIsHired() then
			if self.mrGbMS.IsOnOff then
				self:mrGbMSetIsOnOff( false ) 
			else
				self:mrGbMSetState( "WarningText", "Cannot exchange gearbox while vehicle is hired" )
			end
		elseif not ( self.isMotorStarted ) then
			self:mrGbMSetIsOnOff( not self.mrGbMS.IsOnOff ) 
		elseif g_currentMission.missionInfo.automaticMotorStartEnabled then
			self:mrGbMSetIsOnOff( not self.mrGbMS.IsOnOff ) 
			self.mrGbML.turnOnMotorTimer = g_currentMission.time + 200
			self:stopMotor()
		elseif self.isMotorStarted then
			self:mrGbMSetState( "WarningText", "Cannot exchange gearbox while motor is running" )
		end
		processInput = false
	end
	
	if      self.mrGbMS.WarningText ~= nil
			and self.mrGbMS.WarningText ~= "" then
		if self.isEntered then
			g_currentMission:showBlinkingWarning(self.mrGbMS.WarningText, self.mrGbML.warningTimer - g_currentMission.time )
			self.mrGbMS.WarningText = ""
		elseif g_currentMission.time < self.mrGbML.warningTimer then
	--	g_currentMission:addWarning(self.mrGbMS.WarningText, 0.018, 0.033)
		else
			self.mrGbMS.WarningText = ""
		end
	end
	
	if self.mrGbML.turnOnMotorTimer ~= nil and g_currentMission.time > self.mrGbML.turnOnMotorTimer then
		self.mrGbML.turnOnMotorTimer = nil
		if not ( self.isMotorStarted ) then
			self:startMotor()
		end
	end
	
	if      self.mrGbMS.IsOnOff 
			and self.mrGbML.turnedOffByIncreaseRPMWhileTipping
			and not ( self.hasChangedGearBoxAddon ) then
		self.mrGbML.turnedOffByIncreaseRPMWhileTipping = false
	end
	
	if self.isMotorStarted and self.motor.minRpm > 0 and self.mrGbMS.IsOnOff then
		if self.mrGbML.motor == nil then 
	-- initialize as late as possible 			
			if not ( self.mbClientInitDone30 ) then return end
			if self.motor == nil then return end
		
			if self.mrGbML.motor == nil then
				self.mrGbML.motor = gearboxMogliMotor:new( self, self.motor )			
				self.mrGbMB.motor = self.motor	
			end
		end
		if self.mrGbML.motor == nil or self.mrGbMB.motor == nil then 
	-- no backup of original motor => error in gearboxMogliMotor:new
			local code = 0
			if self.mrGbML.motor == nil then code = code + 1 end
			if self.mrGbMB.motor == nil then code = code + 2 end
			print("FS17_GearboxAddon: Error! Initialization of motor failed: "..tostring(self.configFileName).." ("..tostring(code)..")")
			self.mrGbML.motor = nil
			self:mrGbMSetIsOnOff( false ) 
			self:mrGbMSetState( "IsOn", false ) 	
			return
		end
	end
	
	if self.mrGbMS.IsOn then
		if self.mrGbMB.Sound == nil then
			self.mrGbMB.Sound = { self.motorSoundPitchScale,     self.motorSoundPitchMax, 
														self.motorSoundRunPitchScale,  self.motorSoundRunPitchMax, 
														self.motorSoundLoadPitchScale, self.motorSoundLoadPitchMax,
														self.sampleReverseDrive.sample }
		end
		
		self.motorSoundPitchScale     = self.mrGbMS.Sound.IdlePitchScale
		self.motorSoundPitchMax       = self.mrGbMS.Sound.IdlePitchMax
		self.motorSoundRunPitchScale  = self.mrGbMS.Sound.RunPitchScale  
		self.motorSoundRunPitchMax    = self.mrGbMS.Sound.RunPitchMax
		self.motorSoundLoadPitchScale = self.mrGbMS.Sound.LoadPitchScale 
		self.motorSoundLoadPitchMax   = self.mrGbMS.Sound.LoadPitchMax
		self.sampleReverseDrive.sample = nil
	else
		if self.mrGbMB.Sound ~= nil then
			self.motorSoundPitchScale,     self.motorSoundPitchMax, 
			self.motorSoundRunPitchScale,  self.motorSoundRunPitchMax,
			self.motorSoundLoadPitchScale, self.motorSoundLoadPitchMax,
			self.sampleReverseDrive.sample = unpack( self.mrGbMB.Sound )
			self.mrGbMB.Sound = nil
		end
	
		return 
	end 	
		
	if self.mrGbMS.CurMinRpm == nil or self.mrGbMS.CurMaxRpm == nil then
		print("FS17_GearboxAddon: Error! Initialization of motor failed")
	end
	
	if self.isServer and not ( self.mrGbML.firstTimeRun ) then
		self.mrGbML.firstTimeRun = true
		self:mrGbMSetState( "CurrentGear",   gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears,   self.mrGbMS.CurrentGear,   self.mrGbMS.DefaultGear,   "gear" ) )
		self:mrGbMSetState( "CurrentRange",  gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges,  self.mrGbMS.CurrentRange,  self.mrGbMS.DefaultRange,  "range" ) )
		self:mrGbMSetState( "CurrentRange2", gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, self.mrGbMS.DefaultRange2, "range2" ) )		
	end	

	if self.mrGbMG.debugPrint and not ( gearboxMogli.consoleCommand1 ) then
		gearboxMogli.consoleCommand1 = true
		self.mrGbMTestNet = gearboxMogli.mrGbMTestNet
		self.mrGbMTestAPI = gearboxMogli.mrGbMTestAPI
		self.mrGbMDebug   = gearboxMogli.mrGbMDebug
		addConsoleCommand("mrGbMTestNet", "Test networking of gearboxMogli", "mrGbMTestNet", self)
		addConsoleCommand("mrGbMTestAPI", "Test API of gearboxMogli", "mrGbMTestAPI", self)
		addConsoleCommand("mrGbMDebug", "Console output during gear shift", "mrGbMDebug", self)
	end

--**********************************************************************************************************			
-- area per second calculation for combines 
--**********************************************************************************************************			
	if self.mrGbML.strawDisableTime ~= nil and self.mrGbML.strawDisableTime > g_currentMission.time then 
		local timeUntilDisable = self.mrGbML.strawDisableTime - g_currentMission.time
		local numToDrop
		
		numToDrop = math.min((dt*self.mrGbML.currentCuttersArea)/timeUntilDisable, self.mrGbML.currentCuttersArea)
		self.mrGbML.currentCuttersArea  = self.mrGbML.currentCuttersArea - numToDrop
		self.mrGbML.cutterAreaPerSecond = numToDrop * 1000 / dt

		numToDrop = math.min((dt*self.mrGbML.currentRealArea)/timeUntilDisable, self.mrGbML.currentRealArea)
		self.mrGbML.currentRealArea  = self.mrGbML.currentRealArea - numToDrop		
    self.mrGbML.realAreaPerSecond   = numToDrop * 1000 / dt
	else
		self.mrGbML.cutterAreaPerSecond = 0
    self.mrGbML.realAreaPerSecond   = 0
	end
	
--**********************************************************************************************************			
-- driveControl 
--**********************************************************************************************************			
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
				if self:mrGbMGetAutoHold() then
					self:mrGbMSetState( "AutoHold", true )
				end
			elseif self.mrGbML.lastDCHandBrake then
				if self:mrGbMGetAutoClutch() and not ( self:mrGbMGetAutoStartStop() ) then
					self:mrGbMSetNeutralActive( false )
				end
			end
			self.mrGbML.lastDCHandBrake = self.driveControl.handBrake.isActive
		end
	end
	
--**********************************************************************************************************			
-- text	
--**********************************************************************************************************			
	if self.isServer then
		local text = ""
		local text2 = ""

		if not ( self.isMotorStarted ) then
			text = gearboxMogli.getText( "gearboxMogliTEXT_OFF", "off" )
		elseif not ( self.steeringEnabled ) then
			text = gearboxMogli.getText( "gearboxMogliTEXT_AI", "AI" )
			text2 = text
			if self:mrGbMGetHasAllAuto() then
				if not ( self:mrGbMGetAutoShiftGears() and self:mrGbMGetAutoShiftRange() ) then
					text = text .. " (M)"
				end
			elseif self.mrGbMS.Hydrostatic then
			elseif ( self.mrGbMS.AutoShiftGears  and not self:mrGbMGetAutoShiftGears() )
					or ( self.mrGbMS.AutoShiftHl     and not self:mrGbMGetAutoShiftRange() ) 
					or ( self.mrGbMS.AutoShiftRange2 and not self:mrGbMGetAutoShiftRange2() ) then
				text = text .. " (M)"
			end
		elseif driveControlHandBrake then
			text = gearboxMogli.getText( "gearboxMogliTEXT_BRAKE", "handbrake" )
		elseif self.mrGbMS.AutoHold then
			text = gearboxMogli.getText( "gearboxMogliTEXT_AUTO_HOLD", "auto hold" )
			if self:mrGbMGetAutomatic() then
				text = text .. " (A)"
			end
		elseif self.mrGbML.gearShiftingNeeded == gearboxMogli.gearShiftingNoThrottle then
			text = gearboxMogli.getText( "gearboxMogliTEXT_NT", "release throttle" )
			text2 = text
		elseif self.mrGbML.gearShiftingNeeded < 0 then
			text = gearboxMogli.getText( "gearboxMogliTEXT_DC", "double clutch" ) .." "..tostring(-self.mrGbML.gearShiftingNeeded)
			text2 = text
		elseif self.mrGbMS.NeutralActive then
			text = gearboxMogli.getText( "gearboxMogliTEXT_NEUTRAL", "neutral" )
			if self:mrGbMGetAutomatic() then
				text = text .. " (A)"
			end
		elseif self.mrGbMS.AllAuto then
			text = gearboxMogli.getText( "gearboxMogliTEXT_ALLAUTO", "all auto" )
			if not ( self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftRange2 ) then
				text2 = "A"
			end
		elseif self.mrGbMS.Hydrostatic then
			text = gearboxMogli.getText( "gearboxMogliTEXT_VARIO", "CVT" )
		elseif self:mrGbMGetAutomatic() then
			text = gearboxMogli.getText( "gearboxMogliTEXT_AUTO", "auto" )
		elseif self.mrGbMS.G27Mode == 1 then
			text = gearboxMogli.getText( "gearboxMogliTEXT_NOGEAR", "no gear" )
			text2 = text
		else
			text = gearboxMogli.getText( "gearboxMogliTEXT_MANUAL", "manual" )
			if self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftRange2 then
				text2 = text
			end
		end
		
		if      not ( driveControlShuttle )
				and ( ( self.mrGbMS.ReverseActive and not ( self.isReverseDriving ) )
					 or ( not self.mrGbMS.ReverseActive and self.isReverseDriving ) ) then
			if text  ~= "" then text  = text  .. " " end
			text = text .. "(R)" 	
		end
		if self.mrGbMS.SpeedLimiter then
			if text  ~= "" then text  = text  .. " " end
			if text2 ~= "" then text2 = text2 .. " " end
			text = text .. "(L)"
			text2 = text2 .. "(L)"
		end
		if self.mrGbMS.G27Mode > 0 then
			if text  ~= "" then text  = text  .. " " end
			text = text .. "G27"
		end
		if self.mrGbMS.G27Mode > 1 then
			if text2 ~= "" then text2 = text2 .. " " end
			text2 = text2 .. "G27"			
		end
		if self.mrGbMS.EcoMode then
			if text  ~= "" then text  = text  .. " " end
			if text2 ~= "" then text2 = text2 .. " " end
			text = text .. "(eco)"
			text2 = text2 .. "(eco)"
		end
		
		self:mrGbMSetState( "DrawText", text )
		self:mrGbMSetState( "DrawText2", text2 )
	end
		
--**********************************************************************************************************			
-- inputs	
--**********************************************************************************************************			
	if gearboxMogli.mbIsActiveForInput( self, false ) then					
		-- auto start/stop
		if      self.mrGbMS.NeutralActive
				and self.isMotorStarted
				and self:mrGbMGetAutoStartStop()
				and g_currentMission.time > self.motorStartTime
				and not ( driveControlHandBrake )
				and ( self.axisForward < -0.1 or self.cruiseControl.state ~= 0 ) then
			self:mrGbMSetNeutralActive( false ) 
		end
		
		if not self.mrGbMS.NeutralActive and self.mrGbMS.AutoHold then
			self:mrGbMSetState( "AutoHold", false )		
		end

		if self.mrGbMS.AllAuto and not ( self:mrGbMGetHasAllAuto() ) then
			self:mrGbMSetState( "AllAuto", false )		
		end

		if not self.mrGbMS.AllAuto then
			local autoClutch = self.mrGbMS.AutoClutch
			if gearboxMogli.mbHasInputEvent( "gearboxMogliAUTOCLUTCH2" ) then
				autoClutch = not ( autoClutch )
			end

			if     autoClutch
					or ( not ( self.mrGbMS.AutoClutch )
					 and ( self.mrGbMS.DisableManual 
							or ( self.mrGbMS.Hydrostatic
							 and self.mrGbMS.HydrostaticLaunch )
							or self.mrGbMS.DisableManual ) ) then
				self:mrGbMSetAutoClutch( true )
			else
				self:mrGbMSetAutoClutch( false )
				self:mrGbMSetAutomatic( false, noEventSend )
			end
		end
		
		local clutchSpeed = 1 / math.max( self.mrGbMS.ClutchShiftTime, 1 )
		if not ( self:mrGbMGetAutoClutch() ) then
			clutchSpeed     = math.max( 0.002, clutchSpeed )
		end
		
		if     gearboxMogli.mbIsInputPressed( "gearboxMogliCLUTCH_3" ) then
			self.mrGbML.oneButtonClutchTimer = g_currentMission.time + 100
			self:mrGbMSetManualClutch( math.max( 0, self.mrGbMS.ManualClutch - dt * clutchSpeed ))
		elseif InputBinding.gearboxMogliCLUTCH ~= nil then
			local targetClutchPercent = InputBinding.getDigitalInputAxis(InputBinding.gearboxMogliCLUTCH)
			if InputBinding.isAxisZero(targetClutchPercent) then
				targetClutchPercent = InputBinding.getAnalogInputAxis(InputBinding.gearboxMogliCLUTCH)
				if not InputBinding.isAxisZero(targetClutchPercent) then
					targetClutchPercent = Utils.clamp( 0.55 * ( targetClutchPercent + 1 ), 0, 1 ) 
					if math.abs( targetClutchPercent - self.mrGbMS.ManualClutch ) > 0.01 then
						self.mrGbML.oneButtonClutchTimer = math.huge
						self:mrGbMSetManualClutch( targetClutchPercent ) 
					end
				end
			elseif targetClutchPercent < 0 then
				self.mrGbML.oneButtonClutchTimer = math.huge
				self:mrGbMSetManualClutch( math.max( 0, self.mrGbMS.ManualClutch - dt * clutchSpeed ))
			elseif targetClutchPercent > 0 then
				self.mrGbML.oneButtonClutchTimer = math.huge
				self:mrGbMSetManualClutch( math.min( 1, self.mrGbMS.ManualClutch + dt * clutchSpeed ))
			end
		end

		if     self.mrGbML.oneButtonClutchTimer == nil
				or self.mrGbMS.ClutchTimeManual     < dt
				or g_currentMission.time >= self.mrGbML.oneButtonClutchTimer + self.mrGbMS.ClutchTimeManual then
			if self.mrGbMS.ManualClutch < 1 then
				self:mrGbMSetManualClutch( 1 )
			end
		elseif g_currentMission.time > self.mrGbML.oneButtonClutchTimer then
			local mi = ( g_currentMission.time - self.mrGbML.oneButtonClutchTimer ) / self.mrGbMS.ClutchTimeManual
			local ma = math.min( 1, self.mrGbMS.ManualClutch + dt / self.mrGbMS.ClutchTimeInc )
			if self.motor.targetRpm == nil then
				self:mrGbMSetManualClutch( mi )
			else
				self:mrGbMSetManualClutch( self.motor:getClutchPercent( self.motor.targetRpm, self.mrGbMS.OpenRpm, self.mrGbMS.CloseRpm, mi, ma ) )
			end
		--print(string.format("%d, %5.2f%% <= %5.2f%% <= %5.2f%%",g_currentMission.time - self.mrGbML.oneButtonClutchTimer, mi*100,self.mrGbMS.ManualClutch*100,ma*100))
		end
		
		if InputBinding.gearboxMogliMINRPM ~= nil then
			local handThrottle = InputBinding.getDigitalInputAxis(InputBinding.gearboxMogliMINRPM)
			if InputBinding.isAxisZero(handThrottle) then
				handThrottle = InputBinding.getAnalogInputAxis(InputBinding.gearboxMogliMINRPM)
				if not InputBinding.isAxisZero(handThrottle) then
					self:mrGbMSetHandThrottle( handThrottle )
				end
			elseif handThrottle < 0 then
				self:mrGbMSetHandThrottle( self.mrGbMS.HandThrottle - 0.0004 * dt )
			elseif handThrottle > 0 then
				self:mrGbMSetHandThrottle( self.mrGbMS.HandThrottle + 0.0004 * dt ) 
			end
		end
			
		-- avoid conflicts with driveControl
		--if     gearboxMogli.mbHasInputEvent( "driveControlHandbrake" ) then
		if     not processInput
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_1" )
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_2" )
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_3" )
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_4" ) then
			-- ignore
		elseif gearboxMogli.mbHasInputEvent( "TOGGLE_CHOPPER" ) and self.mrGbMS.IsCombine then
			-- ignore
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliECO" ) then
			self:mrGbMSetState( "EcoMode", not self.mrGbMS.EcoMode )
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliHUD" ) then
			-- HUD mode	
		--local m = self.mrGbMS.HudMode + 1
		--if m > 2 then 
		--	m = 0
		--end
			local m = self.mrGbMG.defaultHudMode
			if self.mrGbMS.HudMode == 1 then
				m = 2
			else
				m = 1
			end
			self:mrGbMSetState( "HudMode", m )
		elseif  gearboxMogli.mbHasInputEvent( "gearboxMogliAllAuto" )
				and self:mrGbMGetHasAllAuto() then
			-- toggle always AI => has to work with worker too
			self:mrGbMSetState( "AllAuto", not self.mrGbMS.AllAuto )
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliNEUTRAL" ) then
			if self.mrGbMS.AllAuto then
				if not self.mrGbMS.NeutralActive then
					self:setCruiseControlState(0)
				end
				self:mrGbMSetNeutralActive( not self.mrGbMS.NeutralActive ) 
			elseif self.mrGbMS.AutoClutch and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 ) then
				if     self.mrGbMS.DisableManual then
					self:mrGbMSetNeutralActive( not self.mrGbMS.NeutralActive ) 
					self:mrGbMSetAutomatic( true ) 
				elseif self.mrGbMS.AutoStartStop and self.mrGbMS.AutoClutch then
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
		elseif not ( driveControlShuttle ) and gearboxMogli.mbHasInputEvent( "gearboxMogliREVERSE" ) then			
		--self:setCruiseControlState(0)
			self:mrGbMSetReverseActive( not self.mrGbMS.ReverseActive ) 
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliSPEEDLIMIT" ) then -- speed limiter
			self:mrGbMSetSpeedLimiter( not self.mrGbMS.SpeedLimiter ) 
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliACCTOLIMIT" ) then -- speed limiter acc.
			self:mrGbMSetAccelerateToLimit( self.mrGbMS.AccelerateToLimit + 1 )
			self:mrGbMSetDecelerateToLimit( self.mrGbMS.AccelerateToLimit * 2 )
			self:mrGbMSetState( "InfoText", string.format( "Speed Limiter: +%2.0f km/h/s / -%2.0f km/h/s", self.mrGbMS.AccelerateToLimit, self.mrGbMS.DecelerateToLimit ))
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliDECTOLIMIT" ) then -- speed limiter dec.
			self:mrGbMSetAccelerateToLimit( self.mrGbMS.AccelerateToLimit - 1 )
			self:mrGbMSetDecelerateToLimit( self.mrGbMS.AccelerateToLimit * 2 )
			self:mrGbMSetState( "InfoText", string.format( "Speed Limiter: +%2.0f km/h/s / -%2.0f km/h/s", self.mrGbMS.AccelerateToLimit, self.mrGbMS.DecelerateToLimit ))
		elseif table.getn( self.mrGbMS.Ranges2 ) > 1 and gearboxMogli.mbHasInputEvent( "gearboxMogliSHIFTRANGE2UP" ) then -- high/low range shift
			self:mrGbMSetCurrentRange2(self.mrGbMS.CurrentRange2+1)                                       
		elseif table.getn( self.mrGbMS.Ranges2 ) > 1 and gearboxMogli.mbHasInputEvent( "gearboxMogliSHIFTRANGE2DOWN" ) then -- high/low range shift
			self:mrGbMSetCurrentRange2(self.mrGbMS.CurrentRange2-1)
		elseif table.getn( self.mrGbMS.Ranges ) > 1 and gearboxMogli.mbHasInputEvent( "gearboxMogliSHIFTRANGEUP" ) then -- high/low range shift
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear+1, false, true) 
			else
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange+1, false, true)                                        
			end 
		elseif table.getn( self.mrGbMS.Ranges ) > 1 and gearboxMogli.mbHasInputEvent( "gearboxMogliSHIFTRANGEDOWN" ) then -- high/low range shift
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear-1, false, true) 	
			else
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange-1, false, true) 
			end 
		elseif not ( self.mrGbMS.DisableManual ) and gearboxMogli.mbHasInputEvent( "gearboxMogliSHIFTGEARUP" ) then
			self:mrGbMSetState( "G27Mode", 0 ) 
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange+1, false, true)                                        
			else
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear+1, false, true) 
			end 
		elseif not ( self.mrGbMS.DisableManual ) and gearboxMogli.mbHasInputEvent( "gearboxMogliSHIFTGEARDOWN" ) then
			self:mrGbMSetState( "G27Mode", 0 ) 
			if self.mrGbMS.SwapGearRangeKeys then
				self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange-1, false, true) 
			else
				self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear-1, false, true) 	
			end 
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliGEARFWD" )  then 
		--self:setCruiseControlState(0) 
			self:mrGbMSetReverseActive( false ) 
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliGEARBACK" ) then 
		--self:setCruiseControlState(0) 
			self:mrGbMSetReverseActive( true ) 
		end
		
		if self.mrGbMS.DisableManual or self:getIsHired() then
			self:mrGbMSetState( "G27Mode", 0 ) 
		else
			local gear = 0
			if     gearboxMogli.mbIsInputPressed( "gearboxMogliGEAR1" ) then gear=self.mrGbMS.G27Gears[1]
			elseif gearboxMogli.mbIsInputPressed( "gearboxMogliGEAR2" ) then gear=self.mrGbMS.G27Gears[2]
			elseif gearboxMogli.mbIsInputPressed( "gearboxMogliGEAR3" ) then gear=self.mrGbMS.G27Gears[3]
			elseif gearboxMogli.mbIsInputPressed( "gearboxMogliGEAR4" ) then gear=self.mrGbMS.G27Gears[4]
			elseif gearboxMogli.mbIsInputPressed( "gearboxMogliGEAR5" ) then gear=self.mrGbMS.G27Gears[5]
			elseif gearboxMogli.mbIsInputPressed( "gearboxMogliGEAR6" ) then gear=self.mrGbMS.G27Gears[6]
			elseif gearboxMogli.mbIsInputPressed( "gearboxMogliGEARR" ) then gear=self.mrGbMS.G27Gears[7]
			end
			
		--self.mrGbML.G27Gear = tostring(gear)
			
			local noAutomatic = true
			if self.mrGbMS.SwapGearRangeKeys then
				noAutomatic = not self:mrGbMGetAutoShiftRange()
			else
				noAutomatic = not self:mrGbMGetAutoShiftGears()
			end
			
		--self.mrGbML.G27Gear = self.mrGbML.G27Gear ..", "..tostring(noAutomatic)..", "..tostring(self.mrGbMS.G27Mode)
			
			if noAutomatic and ( self.mrGbMS.G27Mode > 0 or gear ~= 0 ) then		
				if self.mrGbMS.G27Mode <= 0 then
					if self.mrGbMS.NeutralActive then
						self:mrGbMSetState( "G27Mode", 1 ) 
					else
						self:mrGbMSetState( "G27Mode", 2 ) 
					end
				end
			
				local curGear = 0
				if self.mrGbMS.G27Mode >= 2  then
					if self.mrGbMS.SwapGearRangeKeys then
						curGear   = self.mrGbMS.CurrentRange
					else
						curGear   = self.mrGbMS.CurrentGear
					end					
					if self.mrGbMS.ReverseActive then
						curGear = -curGear 
					end				
					if self.mrGbMS.G27Gears[7] >= 0 then
						curGear = math.abs( curGear )
					end											
				end											

			--self.mrGbML.G27Gear = self.mrGbML.G27Gear .." => "..tostring(curGear)..", "..tostring(gear)
				
				if curGear ~= gear then					
					local manClutch = self.mrGbMS.ManualClutchGear
					if self:mrGbMGetAutoClutch() then
						manClutch = false
					elseif ( curGear>0 and gear<0 ) or ( curGear<0 and gear>0 ) then
						manClutch = self.mrGbMS.ManualClutchReverse
					elseif self.mrGbMS.SwapGearRangeKeys then
						manClutch = self.mrGbMS.ManualClutchHl
					end
	
				--self.mrGbML.G27Gear = self.mrGbML.G27Gear ..", "..tostring(manClutch)
	
					if gearboxMogli.mrGbMCheckGrindingGears( self, manClutch, noEventSend ) then
					-- do nothing 
					elseif gear == 0 then
						self:mrGbMSetNeutralActive( true, false, true )	
						self:mrGbMSetState( "G27Mode", 1 ) 
					else
						if self.mrGbMS.G27Gears[7] < 0 then
							self:mrGbMSetReverseActive( (gear < 0) )
						end
						
						if self.mrGbMS.SwapGearRangeKeys then
							self:mrGbMSetCurrentRange(math.abs(gear), false, true)
							curGear = self.mrGbMS.CurrentRange
						else
							self:mrGbMSetCurrentGear(math.abs(gear), false, true)
							curGear = self.mrGbMS.CurrentGear
						end
						
						if self.mrGbMS.ReverseActive then
							curGear = -curGear 
						end			

						self:mrGbMSetState( "G27Mode", 2 ) 
					--if not self:mrGbMGetAutoStartStop() then
						self:mrGbMSetNeutralActive( false, false, true )
						self:mrGbMSetState( "AutoHold", false )											
					--end
					end
				end
				
			--self.mrGbML.G27Gear = self.mrGbML.G27Gear .." => "..tostring(self.mrGbMS.G27Mode)
				
			elseif self.mrGbMS.G27Mode > 0 then
				self:mrGbMSetState( "G27Mode", 0 ) 

			--self.mrGbML.G27Gear = self.mrGbML.G27Gear .." => off"				
			end
		end
--**********************************************************************************************************					
-- auto start stop or manual clutch if vehicle is not controlled 
--**********************************************************************************************************			
	elseif  self.steeringEnabled 
			and self.isMotorStarted
			and not self.isHired
			and self.isClient then
		-- open clutch if RPM is too low
		if      self.isEntered
				and g_gui:getIsGuiVisible() 
				and g_gui.currentGuiName ~= "ChatDialog" 
				and not ( self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch )
				and self:mrGbMGetCurrentRPM() <= 1.1 * self.mrGbMS.IdleRpm then
			self:mrGbMSetManualClutch( 0 )
		end
		-- set one button clutch timer on all clients
		if self.mrGbMS.ManualClutch == 0 then
			self.mrGbML.oneButtonClutchTimer = g_currentMission.time + 100
		end
	end
	
	if      self.isServer 
			and self:mrGbMGetOnlyHandThrottle()
			and not ( self.isMotorStarted ) then
		-- no hand throttle w/o motor
		self:mrGbMSetHandThrottle( 0 )
	end

--**********************************************************************************************************					
	if self.isMotorStarted and self.mrGbML.motor ~= nil then
		-- switch the motor 
		self.motor = self.mrGbML.motor
		
		if self.mrGbMS.BlowOffVentilVolume > 0 then			
			if self.isEntered and gearboxMogli.mbIsSoundActive( self ) and self.mrGbMS.BlowOffVentilPlay then
				self.mrGbMS.BlowOffVentilPlay = false
				
				if self.mrGbMS.BlowOffVentilFile == nil then
					if gearboxMogli.BOVSample == nil then
						gearboxMogli.BOVSample = createSample("gearboxMogliBOVSample")
						local fileName = Utils.getFilename( "blowOffVentil.wav", gearboxMogli.baseDirectory )
						loadSample(gearboxMogli.BOVSample, fileName, false)
					end
					playSample(gearboxMogli.BOVSample, 1, self.mrGbMS.BlowOffVentilVolume, 0)	
				else
					if self.mrGbML.blowOffVentilSample == nil then
						self.mrGbML.blowOffVentilSample = createSample("gearboxMogliBOVSample")
						loadSample( self.mrGbML.blowOffVentilSample, self.mrGbMS.BlowOffVentilFile, false )
					end
					playSample( self.mrGbML.blowOffVentilSample, 1, self.mrGbMS.BlowOffVentilVolume, 0 )	
				end
			end
		end
		
		if self.mrGbMS.GrindingSoundVolume > 0 then
			if gearboxMogli.mbIsSoundActive( self ) and self.mrGbMS.GrindingGearsVol > 0 then
				local v = self.mrGbMS.GrindingGearsVol
				self.mrGbMS.GrindingGearsVol = 0

				local sample = nil
				
				if self.mrGbMS.GrindingSoundFile == nil then
					if gearboxMogli.GrindingSample == nil then
						gearboxMogli.GrindingSample = createSample("gearboxMogliGrindingSample")
						local fileName = Utils.getFilename( "grinding.wav", gearboxMogli.baseDirectory )
						loadSample(gearboxMogli.GrindingSample, fileName, false)
					end
					sample = gearboxMogli.GrindingSample
				else
					if self.mrGbML.grindingSample == nil then
						self.mrGbML.grindingSample = createSample("gearboxMogliGrindingSample")
						loadSample(self.mrGbML.grindingSample, self.mrGbMS.GrindingSoundFile, false)
					end
					sample = self.mrGbML.grindingSample
				end
				
				
				if sample ~= nil then
					if     v <= 0 then
						self.mrGbML.grindingSampleEnd = nil
						self.mrGbML.grindingSampleVol = nil
						stopSample( sample )
					elseif self.mrGbML.grindingSampleEnd == nil 
							or self.mrGbML.grindingSampleEnd < g_currentMission.time
							or self.mrGbML.grindingSampleVol < v then
						self.mrGbML.grindingSampleEnd = g_currentMission.time + getSampleDuration( sample )
						self.mrGbML.grindingSampleVol = v
						playSample( sample, 1, v * self.mrGbMS.GrindingSoundVolume, 0 )	
					end
				end
			end
		end
		
--**********************************************************************************************************			
		-- this is from Motorized.lua 
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
		local alpha = math.pow(0.01, dt*0.001);
		local roundPerMinute = targetRpmOffset + alpha*(self.lastRoundPerMinute-targetRpmOffset);
				
		local realRpmOffset     = self.motor:getEqualizedMotorRpm() - minRpm
		
		local tmp = self.lastRoundPerMinute
		
		self.lastRoundPerMinute = targetRpmOffset + ( realRpmOffset - targetRpmOffset ) / alpha
	end
	
--**********************************************************************************************************			
-- reverse driving sound
--**********************************************************************************************************			
	if self.mrGbMS.Sound.ReverseDriveSample ~= nil then
		self.sampleReverseDrive.sample = self.mrGbMS.Sound.ReverseDriveSample

		if      self.isMotorStarted
				and self.mrGbML.motor ~= nil
				and self:getIsActiveForSound() 
				and self.mrGbMS.ReverseActive 
				and not self.mrGbMS.NeutralActive then
			SoundUtil.playSample(self.sampleReverseDrive, 0, 0, nil)
		else
			SoundUtil.stopSample(self.sampleReverseDrive)
		end
		
		self.sampleReverseDrive.sample = nil
	end				
	
--**********************************************************************************************************			
-- sound pitch and volume
--**********************************************************************************************************			
	
	if self.motorSoundLoadFactor ~= nil and self.motorSoundLoadFactor > 0.5 then
	-- at least half of the motor sound load volume even at low RPM
		self.motorSoundLoadMinimalVolumeFactor = math.max( self.mrGbMS.Sound.LoadMinimalVolumeFactor, ( self.motorSoundLoadFactor - 0.5 ) * self.sampleMotorLoad.volume )
	else
		self.motorSoundLoadMinimalVolumeFactor = self.mrGbMS.Sound.LoadMinimalVolumeFactor
	end			

	if      self.steeringEnabled 
			and self.isServer 
			and self.isMotorStarted
			and not ( self.isEntered or self.isControlled ) then
	
--**********************************************************************************************************			
-- drive control parallel mode
--**********************************************************************************************************			
		if      self.dCcheckModule                  ~= nil
				and self.driveControl                   ~= nil
				and self:dCcheckModule("cruiseControl")  
				and self.driveControl.cruiseControl     ~= nil
			--and g_currentMission.controlledVehicle  ~= self 
				and self.cruiseControl.state             > 0 then
				
			local rootVehicle = self:getRootAttacherVehicle();
				
			if self.driveControl.cruiseControl.mode == self.driveControl.cruiseControl.MODE_STOP_FULL then
				local trailerFillLevel, trailerCapacity = rootVehicle:getAttachedTrailersFillLevelAndCapacity()
				if trailerFillLevel~= nil and trailerCapacity~= nil then
					if trailerFillLevel >= trailerCapacity then
						self:setCruiseControlState(0);
					end;
				end;
				self.driveControl.cruiseControl.refVehicle = nil;
			elseif self.driveControl.cruiseControl.mode == self.driveControl.cruiseControl.MODE_STOP_EMPTY then
				local trailerFillLevel, trailerCapacity = rootVehicle:getAttachedTrailersFillLevelAndCapacity()
				if trailerFillLevel~= nil and trailerCapacity~= nil then
					if trailerFillLevel <= 0 then
						self:setCruiseControlState(0);
					end;
				end;
				self.driveControl.cruiseControl.refVehicle = nil;
			elseif  self.driveControl.cruiseControl.mode                == self.driveControl.cruiseControl.MODE_PARALLEL
					and self.driveControl.cruiseControl.refVehicle          ~= nil
					and self.driveControl.cruiseControl.refVehicle.rootNode ~= nil then
				local dx, _, dz = localDirectionToWorld(rootVehicle.rootNode, 0, 0, 1)
				local sdx, _, sdz = localDirectionToWorld(self.driveControl.cruiseControl.refVehicle.rootNode, 0, 0, 1)
											
				local diffAngle = (dx*sdx + dz*sdz)/(math.sqrt(dx^2+dz^2)*math.sqrt(sdx^2+sdz^2))
				diffAngle = math.acos(diffAngle);
				
				if diffAngle > math.rad(20) then
					self:setCruiseControlState(0);
				else				
					self:setCruiseControlMaxSpeed(self.driveControl.cruiseControl.refVehicle.lastSpeed*3600/math.cos(diffAngle))
					self.cruiseControl.wasSpeedChanged = true;
					self.cruiseControl.changeCurrentDelay = 0;

					if g_server ~= nil then
						g_server:broadcastEvent(SetCruiseControlSpeedEvent:new(self, self.cruiseControl.speed), nil, nil, self)
					else
						g_client:getServerConnection():sendEvent(SetCruiseControlSpeedEvent:new(self, self.cruiseControl.speed))
					end

					self.cruiseControl.speedSent = self.cruiseControl.speed
				end
			end
		end

--**********************************************************************************************************			
-- keep on going if not entered 
--**********************************************************************************************************		
		if      self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE then
			Drivable.updateVehiclePhysics(self, 0, false, 0, false, false, dt)
		elseif  self:mrGbMGetCurrentRPM() > 1.1 * self.mrGbMS.IdleRpm then
			if self.mrGbMS.AutoHold then
				Drivable.updateVehiclePhysics(self, 1, false, 0, false, true, dt)
			else
				Drivable.updateVehiclePhysics(self, 0, false, 0, false, false, dt)
			end
		end
	end		
end 

--**********************************************************************************************************	
-- gearboxMogli:addCutterArea
--**********************************************************************************************************	
function gearboxMogli:addCutterArea( cutter, area, realArea, inputFruitType, fruitType )
	if self.mrGbMS.IsCombine and 0 < area then
		self.mrGbML.currentRealArea    = self.mrGbML.currentRealArea + realArea	
		if self.mrGbML.maxRealArea     < self.mrGbML.currentRealArea then
			self.mrGbML.maxRealArea      = self.mrGbML.currentRealArea
		end
		
		local timeAdd = Utils.getNoNil( self.strawToggleTime, 2000 ) 
		if timeAdd > 500 and self.mrGbML.maxRealArea > 0 then
			timeAdd = 500 + ( 1 - self.mrGbML.currentRealArea / self.mrGbML.maxRealArea ) * ( timeAdd - 500 )
		end
		
		self.mrGbML.currentCuttersArea    = self.mrGbML.currentCuttersArea + area
		self.mrGbML.currentInputFruitType = inputFruitType 
		self.mrGbML.currentFruitType      = fruitType 
		if self.mrGbML.strawDisableTime == nil then
			self.mrGbML.strawDisableTime = g_currentMission.time + timeAdd 
		else
			self.mrGbML.strawDisableTime = math.max( self.mrGbML.strawDisableTime, g_currentMission.time + timeAdd )
		end
	end
end

--**********************************************************************************************************	
-- gearboxMogli:onReverseDirectionChanged 
--**********************************************************************************************************	
function gearboxMogli:onReverseDirectionChanged ( direction )
	if      self.isServer 
			and self.mrGbMS ~= nil
			and self.mrGbMS.IsOn
			then
		self:mrGbMSetReverseActive( not self.mrGbMS.ReverseActive ) 
	end
end

--**********************************************************************************************************	
-- gearboxMogli:onLeave
--**********************************************************************************************************	
function gearboxMogli:onLeave()
	if self.mrGbMS == nil or self.mrGbML == nil or self.mrGbML.motor == nil then
		return
	end

	if      self.steeringEnabled 
			and self.mrGbMS.IsOn 
			and self.isMotorStarted
			and self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE
			and not self.isHired then
		if self:mrGbMGetAutoStartStop() then 
			self:mrGbMSetNeutralActive( true, false, true )
			self:mrGbMSetState( "IsNeutral", true )
		else
			self.mrGbML.oneButtonClutchTimer = g_currentMission.time + 100
			self:mrGbMSetManualClutch( 0 )
		end
		self:mrGbMSetState( "AutoHold", true )
	end
end

--**********************************************************************************************************	
-- gearboxMogli:updateTick
--**********************************************************************************************************	
function gearboxMogli:updateTick(dt)

	if self.mrGbMS == nil or self.mrGbML == nil or self.mrGbMD == nil then
		return
	end	
	
	if self.isActive then
		if self.isServer then
			if not ( self.mrGbMS.IsOnOff ) then
				self:mrGbMSetState( "IsOn", false ) 
			elseif not ( self.steeringEnabled ) then
				
				if  self.mrGbMS.EnableAI ~= gearboxMogli.AIGearboxOff then
					self:mrGbMSetState( "IsOn", true ) 
				
					if not ( self.mrGbML.aiControlled ) then
						self.mrGbML.aiControlled    = true
						self.mrGbML.aiBackupGear    = self.mrGbMS.CurrentGear
						self.mrGbML.aiBackupRange   = self.mrGbMS.CurrentRange 
						self.mrGbML.aiBackupRange2  = self.mrGbMS.CurrentRange2 
						self.mrGbML.aiBackupReverse = self.mrGbMS.ReverseActive 
						
						self:mrGbMSetReverseActive( false )
						
						if self.aiIsStarted then
							if self.mrGbMS.MaxAIRange2 ~= nil and self.mrGbMS.MaxAIRange2 < self.mrGbMS.CurrentRange2 then
								self:mrGbMSetCurrentRange2( self.mrGbMS.MaxAIRange2 ) 	
							end
							if self:mrGbMGetAutomatic() then
								gearboxMogli.setLaunchGear( self, false, true )
							end
							if self.mrGbMS.MaxAIRange ~= nil and self.mrGbMS.MaxAIRange < self.mrGbMS.CurrentRange then
								self:mrGbMSetCurrentRange( self.mrGbMS.MaxAIRange ) 	
							end
							if self.mrGbMS.MaxAIGear  ~= nil and self.mrGbMS.MaxAIGear  < self.mrGbMS.CurrentGear  then
								self:mrGbMSetCurrentGear( self.mrGbMS.MaxAIGear ) 	
							end
						elseif self:mrGbMGetAutomatic() then
							gearboxMogli.setLaunchGear( self, false, true )
						end
						
					elseif self.mrGbML.gearShiftingNeeded == 0 then
						if self.mrGbMS.ReverseActive then
							self.mrGbML.aiGearR  = self.mrGbMS.CurrentGear
							self.mrGbML.aiRangeR = self.mrGbMS.CurrentRange
						else
							self.mrGbML.aiGearF  = self.mrGbMS.CurrentGear
							self.mrGbML.aiRangeF = self.mrGbMS.CurrentRange
						end
					end					
				else
					self:mrGbMSetState( "IsOn", false ) 	
				end

			elseif self.mrGbML.aiControlled then
				self.mrGbML.aiControlled = false
				self:mrGbMSetNeutralActive( true, false, true )
				self:mrGbMSetState( "AutoHold", true )
				self:mrGbMSetState( "IsOn", true ) 

				self:mrGbMSetReverseActive( self.mrGbML.aiBackupReverse )
				if self.mrGbMS.CurrentRange2 ~= self.mrGbML.aiBackupRange2 then
					self:mrGbMSetCurrentRange2( self.mrGbML.aiBackupRange2 ) 	
				end
				if self.mrGbMS.CurrentRange ~= self.mrGbML.aiBackupRange then
					self:mrGbMSetCurrentRange( self.mrGbML.aiBackupRange ) 	
				end
				if self.mrGbMS.CurrentGear ~= self.mrGbML.aiBackupGear then
					self:mrGbMSetCurrentGear( self.mrGbML.aiBackupGear ) 	
				end
				
			else		
				self:mrGbMSetState( "IsOn", true ) 
			end 	
			
		--if not ( self.isMotorStarted ) or g_currentMission.time < self.motorStartTime then
		--	self:mrGbMSetNeutralActive( true, false, true )
		--	self:mrGbMSetState( "AutoHold", true )
		--end
			
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
				if self.mrGbMS.AutoShiftRange2 and self.mrGbMS.ManualClutchRanges2 then
					self:mrGbMSetAutoClutch( true ) 
				end
			end 	
		end
		
		self.mrGbML.lastSumDt = self.mrGbML.lastSumDt + dt
				
		local maxSumDt = 333
		if self.isServer and self.mrGbMS.NoUpdateStream then
			maxSumDt = 1000
		end
		
		if self.mrGbML.lastSumDt > maxSumDt then
			if self.isServer and self.mrGbMS.IsOn and self.mrGbML.motor ~= nil and self.motor == self.mrGbML.motor then
				self.mrGbMD.Tgt    = 0
				self.mrGbMD.Clutch = 0
				self.mrGbMD.Power  = 0
				self.mrGbMD.Hydro  = 255
				
				if self.isMotorStarted then
					if self.motor.targetRpm     ~= nil then
						self.mrGbMD.Tgt  = tonumber( Utils.clamp( math.floor( 200*(self.motor.targetRpm-self.mrGbMS.CurMinRpm)/(self.mrGbMS.RatedRpm-self.mrGbMS.CurMinRpm)+0.5), 0, 255 ))	 				
					end
					self.mrGbMD.Clutch = tonumber( Utils.clamp( math.floor( gearboxMogli.mrGbMGetAutoClutchPercent( self ) * 200+0.5), 0, 255 ))	
					if      self.mrGbMS.sendReqPower 
							and self.motor.usedTransTorque        ~= nil
							and self.motor.lastPtoTorque          ~= nil
							and self.motor.prevNonClampedMotorRpm ~= nil
							and self.mrGbMS.CurMinRpm             ~= nil then
						local power = ( self.motor.usedTransTorque + self.motor.lastPtoTorque ) * math.max( self.motor.prevNonClampedMotorRpm, self.mrGbMS.CurMinRpm )
						self.mrGbMD.Power  = tonumber( Utils.clamp( math.floor( power * gearboxMogli.powerFactor0 / self.mrGbMG.torqueFactor + 0.5 ), 0, 65535 ))	
					end
					if self.mrGbMS.Hydrostatic and not ( self.motor.noTransmission ) then
						if self.mrGbMS.HydrostaticMax - self.mrGbMS.HydrostaticMin > gearboxMogli.eps then
							self.mrGbMD.Hydro = 200 * Utils.clamp( ( self.motor.hydrostaticFactor - self.mrGbMS.HydrostaticMin ) / ( self.mrGbMS.HydrostaticMax - self.mrGbMS.HydrostaticMin ), 0, 1 )
						else
							self.mrGbMD.Hydro = 200
						end
					end
				end

				self.mrGbMD.Rate     = tonumber( Utils.clamp( math.floor( gearboxMogli.mrGbMGetThroughPutS( self ) + 0.5 ), 0, 255 ))						
				
				if     self.mrGbMD.lastClutch ~= self.mrGbMD.Clutch
						or ( self.mrGbMS.sendHydro     and self.mrGbMD.lastHydro  ~= self.mrGbMD.Hydro )
						or ( self.mrGbMS.sendTargetRpm and self.mrGbMD.lastTgt    ~= self.mrGbMD.Tgt   )
						or ( self.mrGbMS.sendReqPower  and self.mrGbMD.lastPower  ~= self.mrGbMD.Power )
						or ( self.mrGbMS.IsCombine     and self.mrGbMD.lastRate   ~= self.mrGbMD.Rate  )
						then
					self.mrGbMD.lastTgt    = self.mrGbMD.Tgt
					self.mrGbMD.lastClutch = self.mrGbMD.Clutch
					self.mrGbMD.lastPower  = self.mrGbMD.Power 
					self.mrGbMD.lastRate   = self.mrGbMD.Rate
					self.mrGbMD.lastHydro  = self.mrGbMD.Hydro

					if self.mrGbMS.NoUpdateStream then					
						local message = {}
						message.Clutch = self.mrGbMD.Clutch
						
						if self.mrGbMS.sendHydro     then message.Hydro = self.mrGbMD.Hydro end		 
						if self.mrGbMS.sendTargetRpm then message.Rpm   = self.mrGbMD.Tgt   end			
						if self.mrGbMS.sendReqPower  then message.Power = self.mrGbMD.Power end			
						if self.mrGbMS.IsCombine     then message.Rate  = self.mrGbMD.Rate  end		
						
						self:mrGbMSetState( "NUSMessage", message )
					else
						self:raiseDirtyFlags(self.mrGbML.dirtyFlag) 
					end 
				end 
			end			
			self.mrGbML.lastSumDt = 0
		end 
		
		if self.mrGbML.lastFuelFillLevel == nil or self.mrGbML.lastFuelDt == nil then
			self.mrGbML.lastFuelFillLevel = self.fuelFillLevel
			self.mrGbML.fuelFillLevel     = self.fuelFillLevel
			self.mrGbML.lastFuelDt        = 0
			self.mrGbMD.Fuel              = 0
		else
			self.mrGbML.lastFuelDt = self.mrGbML.lastFuelDt + dt
			self.mrGbML.fuelFillLevel = self.mrGbML.fuelFillLevel + self.mrGbML.smoothSlow * ( self.fuelFillLevel - self.mrGbML.fuelFillLevel )
			if self.mrGbML.lastFuelDt > 250 then
				local fuelUsed = self.mrGbML.lastFuelFillLevel - self.mrGbML.fuelFillLevel
				self.mrGbML.lastFuelFillLevel = self.mrGbML.fuelFillLevel
				if self.isFuelFilling then
					fuelUsed = fuelUsed + self.fuelFillLitersPerSecond * self.mrGbML.lastFuelDt * 0.001
				end
				local fuelUsageRatio   = fuelUsed * (1000 * 3600) / self.mrGbML.lastFuelDt
			--self.mrGbMD.Fuel       = self.mrGbMD.Fuel + gearboxMogli.smoothMedium * ( fuelUsageRatio - self.mrGbMD.Fuel )
				self.mrGbMD.Fuel       = fuelUsageRatio
				self.mrGbML.lastFuelDt = 0
			end 		
		end 		
	end	
end 

--**********************************************************************************************************	
-- gearboxMogli:readUpdateStream
--**********************************************************************************************************	
function gearboxMogli:readUpdateStream(streamId, timestamp, connection)
  if connection:getIsServer() and not ( self.mrGbMS.NoUpdateStream ) then
	--if streamReadBool( streamId ) then
		local checkId = streamReadUInt8( streamId )
		if checkId ~= nil and checkId == 178 then
			if self.mrGbMD == nil then
				self.mrGbMD = {}
			end
			self.mrGbMD.Clutch = streamReadUInt8( streamId ) 
			
			if self.mrGbMS.sendHydro     then self.mrGbMD.Hydro  = streamReadUInt8( streamId  ) end		 
			if self.mrGbMS.sendTargetRpm then self.mrGbMD.Tgt    = streamReadUInt8( streamId  ) end			
			if self.mrGbMS.sendReqPower  then self.mrGbMD.Power  = streamReadUInt16( streamId ) end			
			if self.mrGbMS.IsCombine     then self.mrGbMD.Rate   = streamReadUInt8( streamId  ) end		
		elseif checkId == nil or checkId ~= 142 then
			print("FS17_GearboxAddon: Error! There is another specialization with incorrect readUpdateStream implementation ("..tostring(checkId)..")")
			if self.mrGbMD ~= nil then
				self.mrGbML.updateStreamErrors = self.mrGbML.updateStreamErrors + 1
			end
		end 
  end 
end 

--**********************************************************************************************************	
-- gearboxMogli:writeUpdateStream
--**********************************************************************************************************	
function gearboxMogli:writeUpdateStream(streamId, connection, dirtyMask)
  if not connection:getIsServer() and not ( self.mrGbMS.NoUpdateStream ) then
		if bitAND(dirtyMask, self.mrGbML.dirtyFlag) ~= 0 then			
			streamWriteUInt8(streamId, 178 )
			streamWriteUInt8(streamId, self.mrGbMD.Clutch ) 
			
			if self.mrGbMS.sendHydro     then streamWriteUInt8(streamId, self.mrGbMD.Hydro  ) end		 
			if self.mrGbMS.sendTargetRpm then streamWriteUInt8(streamId, self.mrGbMD.Tgt    ) end			
			if self.mrGbMS.sendReqPower  then streamWriteUInt16(streamId,self.mrGbMD.Power ) end			
			if self.mrGbMS.IsCombine     then streamWriteUInt8(streamId, self.mrGbMD.Rate   ) end
		else
			streamWriteUInt8(streamId, 142 )
		end 
	end 
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNoUpdateStream
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNoUpdateStream( old, new, noEventSend )
	self.mrGbMS.NoUpdateStream = new
	if new and not ( old ) then
		print("FS17_GearboxAddon: Error! There is another specialization with incorrect readUpdateStream implementation => turning off update stream")
		self.mrGbML.lastSumDt  = 1001
		self.mrGbMD.lastClutch = -1
	elseif old and not ( new ) then 
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNUSMessage
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNUSMessage( old, new, noEventSend )
	self.mrGbMS.NUSMessage = new
	if type( new ) == "table" then
		for n,v in pairs( new ) do
			self.mrGbMD[n] = v
		end
	end			
end

--**********************************************************************************************************	
-- gearboxMogli:delete
--**********************************************************************************************************	
function gearboxMogli:delete()
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
-- gearboxMogli:deleteMap
--**********************************************************************************************************	
function gearboxMogli:deleteMap()
	if gearboxMogli.backgroundOverlayId ~= nil then
		pcall( delete, gearboxMogli.backgroundOverlayId )
		gearboxMogli.backgroundOverlayId = nil
	end
	if gearboxMogli.BOVSample ~= nil then
		pcall( delete, gearboxMogli.BOVSample )
		gearboxMogli.BOVSample= nil
	end
end

--**********************************************************************************************************	
-- gearboxMogli:draw
--**********************************************************************************************************	
function gearboxMogli:draw() 	
	
--if self.mrGbML.motor == nil then return end
	
	if self.mrGbMS.IsOn and self.mrGbMS.showHud and self.mrGbMS.HudMode > 0 then
		if      self.mrGbMS.InfoText ~= nil
				and self.mrGbMS.InfoText ~= "" then
			if g_currentMission.time < self.mrGbML.infoTimer then
				g_currentMission:addExtraPrintText(self.mrGbMS.InfoText)
			else
				self.mrGbMS.InfoText = ""
			end
		end
		
		local gearText = self:mrGbMGetGearText()
		
		if self.mrGbMS.HudMode == 1 then
	
			if gearboxMogli.backgroundOverlayId == nil then
				gearboxMogli.backgroundOverlayId = createImageOverlay( "dataS2/menu/blank.png" )
				setOverlayColor( gearboxMogli.backgroundOverlayId, 0,0,0, 0.4 )
			end	
			
			local ovTop    = self.mrGbMG.hudPositionY   -- title plus 0.03 plus character size of title (0.03)
			local deltaY   = self.mrGbMG.hudTextSize 
			local titleY   = self.mrGbMG.hudTitleSize
			local ovBorder = self.mrGbMG.hudBorder   
			local ovLeft   = self.mrGbMG.hudPositionX + self.mrGbMG.hudBorder
			local ovRight  = self.mrGbMG.hudPositionX + self.mrGbMG.hudWidth - self.mrGbMG.hudBorder   
			local ovW      = self.mrGbMG.hudWidth
			local ovX      = self.mrGbMG.hudPositionX
			          
			local uiScale  = gearboxMogli.getUiScale()
			
			if math.abs( uiScale - 1 ) > gearboxMogli.eps then
				if ovX > 0.5 then
					ovX     = 1 - ( 1 - ovX     ) * uiScale
					ovLeft  = 1 - ( 1 - ovLeft  ) * uiScale
					ovRight = 1 - ( 1 - ovRight ) * uiScale
				else
					ovX     = ovX      * uiScale
					ovLeft  = ovLeft   * uiScale
					ovRight = ovRight  * uiScale
				end
				
				deltaY    = deltaY   * uiScale 
				titleY    = titleY   * uiScale 
				ovBorder  = ovBorder * uiScale 
				ovW       = ovW      * uiScale 
			end

			local drawY0   = ovTop - 1.25*deltaY - titleY - self.mrGbMG.hudBorder
			
			--==============================================
			-- enable/disable infos
			--==============================================
			local ovRows   = 0
			local infos    = {}
			if      self.mrGbMS.EngineName    ~= nil
					and self.configurations.motor ~= nil then					
				ovRows = ovRows + 1 infos[ovRows] = "engine"
			end
			if     self.mrGbMS.Hydrostatic and self.mrGbMS.DisableManual then
				if gearText ~= "" then			
					ovRows = ovRows + 1 infos[ovRows] = "gear"
				end
			elseif  not self.mrGbMS.AllAuto
					and ( self:mrGbMGetOnlyHandThrottle() or self.mrGbMS.HandThrottle > 0.01 ) then
				ovRows = ovRows + 1 infos[ovRows] = "target1"		
			else
				ovRows = ovRows + 1 infos[ovRows] = "speed"
			end
			ovRows = ovRows + 1 infos[ovRows] = "rpm"
			if self.mrGbMG.drawTargetRpm then
				ovRows = ovRows + 1 infos[ovRows] = "target"
			elseif self:mrGbMGetOnlyHandThrottle() or self.mrGbMS.HandThrottle > 0 then
				ovRows = ovRows + 1 infos[ovRows] = "hand"
			end
			if self.mrGbMG.drawReqPower  then
				ovRows = ovRows + 1 infos[ovRows] = "power"
			end
			ovRows = ovRows + 1 infos[ovRows] = "load"
		--if self.mrGbMD.Fuel > 0 then
				ovRows = ovRows + 1 infos[ovRows] = "fuel"
		--end
			if not self:mrGbMGetAutoClutch() then
				ovRows = ovRows + 1 infos[ovRows] = "clutch"
			elseif self.mrGbMD.Clutch < 200  then
				ovRows = ovRows + 1 infos[ovRows] = "clutch2"
			end
			if self.mrGbMG.debugPrint and self.isServer and self.mrGbMS.IsCombine then
				ovRows = ovRows + 1 infos[ovRows] = "pto"
			elseif self.mrGbMD.Rate ~= nil and self.mrGbMD.Rate > 0 then
				ovRows = ovRows + 1 infos[ovRows] = "combine"
			end
			--==============================================
			
			local ovH      = titleY + ( ovRows + 1 ) * deltaY + ovBorder + ovBorder -- title is 0.03 points above drawY0; add border of 0.01 x 2
			local ovY      = ovTop - ovH
			
			renderOverlay( gearboxMogli.backgroundOverlayId, ovX, ovY, ovW, ovH )
		
			setTextAlignment(RenderText.ALIGN_LEFT) 
			setTextColor(1, 1, 1, 1) 

			setTextBold(true) 
			renderText(ovLeft, drawY0 + titleY, titleY, self.mrGbMS.DrawText) 			     	
			setTextBold(false) 
			
			--==============================================
			-- render infos
			--==============================================
			local drawY
			
			local speed = self:mrGbMGetGearSpeed()
			if self.mrGbMS.MaxSpeedLimiter then
				if self.mrGbMS.ReverseActive then
					if self.motor.maxBackwardSpeed ~= nil then
						speed = math.min( speed, 3.6 * self.motor.maxBackwardSpeed )
					end
				else
					if self.motor.maxForwardSpeed ~= nil then
						speed = math.min( speed, 3.6 * self.motor.maxForwardSpeed )
					end
				end
			end					
			
			
			for col=1,2 do
				drawY = drawY0 
				
				if col == 1 then
					setTextAlignment(RenderText.ALIGN_LEFT) 
				else
					setTextAlignment(RenderText.ALIGN_RIGHT) 
				end
				
				for row,info in pairs( infos ) do
				
					if     info == "engine" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, self.mrGbMS.EngineName) 	
						end
					elseif info == "gear" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearText) 	
						end
					elseif info == "speed" then
						if col == 1 then
							local t
							if gearText == "" then
								t = "Max. speed"
							else
								t = gearText
							end
							renderText(ovLeft, drawY, deltaY, t) 	
						else
							renderText(ovRight,drawY, deltaY, string.format("%3.1f km/h", speed ))
						end
					elseif info == "target1" then
						if col == 1 then
							local t
							if gearText == "" then
								t = "Max. speed"
							else
								t = gearText
							end
							renderText(ovLeft, drawY, deltaY, t) 	
						else
							local ir = self.mrGbMS.IdleRpm / self.mrGbMS.RatedRpm
							local sp = math.min( speed, self:mrGbMGetGearSpeed() * ( ir + self.mrGbMS.HandThrottle * ( 1 - ir ) ) )
							renderText(ovRight,drawY, deltaY, string.format("%3.1f km/h", sp ))
						end
					elseif info == "target3" then
						renderText(ovRight, drawY, deltaY, string.format("%3d %%", math.floor( self.mrGbMD.Hydro * 0.5 + 0.5 ) ))  		
					elseif info == "rpm" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Current rpm")
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f rpm", math.floor( self:mrGbMGetCurrentRPM() * 0.1 +0.5)*10)) 		
						end
					elseif info == "target" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Target rpm")
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f rpm", math.floor( self:mrGbMGetTargetRPM() * 0.1 +0.5)*10)) 		
						end
					elseif info == "power" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Power")
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f HP", self:mrGbMGetUsedPower() ))
						end
					elseif info == "load" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Load")
						else
							renderText(ovRight, drawY, deltaY, string.format("%3d %%", math.floor( Utils.getNoNil( self:mrGbMGetMotorLoad(), 0 ) *10+0.5 )*10 )) 
						end
					elseif info == "fuel" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Fuel used")
						else
							renderText(ovRight, drawY, deltaY, string.format("%3d l/h", self.mrGbMD.Fuel ))
						end
					elseif info == "clutch" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Clutch")
						else
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %%", math.floor( self.mrGbMS.ManualClutch * 100 + 0.5 ) ))
						end
					elseif info == "clutch2" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Auto clutch")
						else
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %%", self.mrGbMD.Clutch*0.5 ))
						end
					elseif info == "hand" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Hand throttle")	
						else
						--renderText(ovRight, drawY, deltaY, string.format("%3d %%", math.floor( self.mrGbMS.HandThrottle * 100 + 0.5 ) ))
							local r = self.mrGbMS.IdleRpm + self.mrGbMS.HandThrottle * ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm )
							renderText(ovRight, drawY, deltaY, string.format("%4.0f rpm", math.floor( r * 0.1 +0.5)*10)) 		
						end
					elseif info == "combine" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "Combine")	
						else
							renderText(ovRight, drawY, deltaY, string.format("%3.0f t/h", self.mrGbMD.Rate ) )
						end
					elseif info == "pto" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "PTO Debug")	
						else
							local f = math.max( self.motor.prevNonClampedMotorRpm, self.mrGbMS.CurMinRpm ) 
							local p = f*self.motor.usedTransTorque     
											+ f*self.motor.lastPtoTorque  
											+ f*self.motor.lastMissingTorque 
							if     self.motor.lastMissingTorque > 0 then
								setTextColor(1, 0, 0, 1) 
							elseif 0.2 * self.motor.lastPtoTorque > 0.8 * self.motor.usedTransTorque then
								setTextColor(1, 1, 0, 1) 
							else
								setTextColor(0, 1, 0, 1) 
							end
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %%", 100 * p / self.motor.maxPower ) )  		          
							setTextColor(1, 1, 1, 1) 
						end
					end
					
					drawY = drawY - deltaY
				end
			end
			--==============================================

			
			drawY = drawY + 0.25*deltaY
			renderText(ovRight, drawY, 0.5*deltaY, gearboxMogli.getText( "gearboxMogliVERSION", "Gearbox by mogli" ) )  		          

			if InputBinding.gearboxMogliON_OFF ~= nil and not self.mrGbMS.NoDisable then
				g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliON", "Gearbox [on]"),  InputBinding.gearboxMogliON_OFF);		
			end

			if InputBinding.gearboxMogliAllAuto ~= nil then
				if self.mrGbMS.AllAuto then
					g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliAllAutoON", "All auto [on]"),  InputBinding.gearboxMogliAllAuto);	
				elseif self:mrGbMGetHasAllAuto() and self.steeringEnabled then
					g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliAllAutoOFF", "All auto [off]"),  InputBinding.gearboxMogliAllAuto);		
				end
			end
			
		elseif self.mrGbMS.HudMode == 2 then
			setTextAlignment(RenderText.ALIGN_LEFT) 
			setTextBold(false)
			
			local w  = math.floor(0.0095 * g_screenWidth) / g_screenWidth * gearboxMogli.getUiScale()
			local h = w * g_screenAspectRatio;
			local x = g_currentMission.speedMeterIconOverlay.x
			local y = g_currentMission.speedMeterIconOverlay.y
	
			local text = self.mrGbMS.DrawText2 .." "..gearText
			renderText( x, y+h, h, text )

			if InputBinding.gearboxMogliHUD ~= nil then
				g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliHUD", "Gearbox HUD"),  InputBinding.gearboxMogliHUD);		
			end
		end
			
		setTextAlignment(RenderText.ALIGN_LEFT) 
		setTextBold(false)
		
		local revShow = self.mrGbMS.ReverseActive
		if self.isReverseDriving then
			revShow = not revShow
		end
			
		if not ( self:mrGbMGetNeutralActive() ) then
			if revShow then
				gearboxMogli.ovArrowDownWhite:render()
			else
				gearboxMogli.ovArrowUpWhite:render()
			end
		elseif self:mrGbMGetAutoStartStop() then
			if revShow then
				gearboxMogli.ovArrowDownGray:render()
			else
				gearboxMogli.ovArrowUpGray:render()
			end
		else
			if revShow then
				gearboxMogli.ovHandBrakeDown:render()
			else
				gearboxMogli.ovHandBrakeUp:render()
			end
		end
			
	else
		if InputBinding.gearboxMogliON_OFF ~= nil and not self.mrGbMS.NoDisable then
			g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliOFF", "Gearbox [off]"), InputBinding.gearboxMogliON_OFF);		
		end
	end
	
end 

--**********************************************************************************************************	
-- gearboxMogli:getSaveAttributesAndNodes
--**********************************************************************************************************	
function gearboxMogli:getSaveAttributesAndNodes(nodeIdent)

	local attributes = ""

	if self.mrGbMS ~= nil then
		if not self:mrGbMGetAutoShiftGears() then
			attributes = attributes.." mrGbMCurrentGear=\""  .. tostring(self.mrGbMS.CurrentGear  ) .. "\""
		end
		if not self:mrGbMGetAutoShiftRange() then
			attributes = attributes.." mrGbMCurrentRange=\"" .. tostring(self.mrGbMS.CurrentRange ) .. "\""
		end
		if not self:mrGbMGetAutoShiftRange2() then
			attributes = attributes.." mrGbMCurrentRange2=\"" ..tostring(self.mrGbMS.CurrentRange2 ) .. "\""
		end
		
		if self.mrGbMS.ResetFwdGear   ~= self.mrGbMS.DefaultGear   then
			attributes = attributes.." mrGbMResetFwdGear=\""    .. tostring(self.mrGbMS.ResetFwdGear   ) .. "\""
		end
		if self.mrGbMS.ResetFwdRange  ~= self.mrGbMS.DefaultRange  then
			attributes = attributes.." mrGbMResetFwdRange=\""   .. tostring(self.mrGbMS.ResetFwdRange  ) .. "\""
		end
		if self.mrGbMS.ResetFwdRange2 ~= self.mrGbMS.DefaultRange2 then
			attributes = attributes.." mrGbMResetFwdRange2=\""  .. tostring(self.mrGbMS.ResetFwdRange2 ) .. "\""
		end

		if self.mrGbMS.ResetRevGear   ~= self.mrGbMS.DefaultGear   then
			attributes = attributes.." mrGbMResetRevGear=\""    .. tostring(self.mrGbMS.ResetRevGear   ) .. "\""
		end
		if self.mrGbMS.ResetRevRange  ~= self.mrGbMS.DefaultRange  then
			attributes = attributes.." mrGbMResetRevRange=\""   .. tostring(self.mrGbMS.ResetRevRange  ) .. "\""
		end
		if self.mrGbMS.ResetRevRange2 ~= self.mrGbMS.DefaultRange2 then
			attributes = attributes.." mrGbMResetRevRange2=\""  .. tostring(self.mrGbMS.ResetRevRange2 ) .. "\""
		end

		if self.mrGbMS.G27Mode > 0 then
			attributes = attributes.." mrGbMG27Mode=\"" ..tostring(self.mrGbMS.G27Mode ) .. "\""
		end
		if not ( self.mrGbMS.AutoClutch ) then
			attributes = attributes.." mrGbMAutoClutch=\"" .. tostring(self.mrGbMS.AutoClutch ) .. "\""
		end
		if    self.mrGbMS.AllAuto then
			attributes = attributes.." mrGbMAllAuto=\"" .. tostring( self.mrGbMS.AllAuto ) .. "\""  
		elseif not ( self.mrGbMS.Automatic ) and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 ) then
			attributes = attributes.." mrGbMAutomatic=\"" .. tostring( self.mrGbMS.Automatic ) .. "\""  
		end
		if self.mrGbMS.DefaultOn ~= self.mrGbMS.IsOnOff then
			attributes = attributes.." mrGbMIsOnOff=\"" .. tostring( self.mrGbMS.IsOnOff ) .. "\""     
		end
		if self.mrGbMS.EcoMode then
			attributes = attributes.." mrGbMEcoMode=\"" .. tostring( self.mrGbMS.EcoMode ) .. "\""     
		end
		if self.mrGbMG.defaultHudMode ~= self.mrGbMS.HudMode then
			attributes = attributes.." mrGbMHudMode=\"" .. tostring( self.mrGbMS.HudMode ) .. "\""     
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
-- gearboxMogli:loadFromAttributesAndNodes
--**********************************************************************************************************	
function gearboxMogli:loadHelperInt( xmlFile, key, attr )
	local i = getXMLInt( xmlFile, key )
	if i ~= nil then
		self.mrGbMS[attr] = i
	end
end
function gearboxMogli:loadHelperBool( xmlFile, key, attr )
	local b = getXMLBool( xmlFile, key )
	if b ~= nil then
		self.mrGbMS[attr] = b
	end
end

function gearboxMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	local i, b
	
	if self.mrGbMS ~= nil then
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMCurrentGear"   , "DefaultGear"       )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMCurrentRange"  , "DefaultRange"      )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMCurrentRange2" , "DefaultRange2"     )
                                                                            
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetFwdGear"  , "ResetFwdGear"      )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetFwdRange" , "ResetFwdRange"     )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetFwdRange2", "ResetFwdRange2"    )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetRevGear"  , "ResetRevGear"      )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetRevRange" , "ResetRevRange"     )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetRevRange2", "ResetRevRange2"    )
                                                                            
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMG27Mode"       , "G27Mode"           )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMSpeedDec"      , "DecelerateToLimit" )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMHudMode"       , "HudMode"           )
                                                                            
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMAutoClutch"    , "AutoClutch"        )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMAllAuto"       , "AllAuto"           )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMAutomatic"     , "Automatic"         )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMIsOnOff"       , "IsOnOff"           )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMEcoMode"       , "EcoMode"           )


	--self:mrGbMSetState( "FirstTimeRun", false )
	end
	
	return BaseMission.VEHICLE_LOAD_OK
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMIsNotValidEntry
--**********************************************************************************************************	
function gearboxMogli:mrGbMIsNotValidEntry( entry, cg, c1, c2 )

	if self.mrGbMS.ReverseActive then
		if entry.forwardOnly then
			return true
		end
	else
		if entry.reverseOnly then
			return true
		end
	end
	
	local cg0 = Utils.getNoNil( cg, self.mrGbMS.CurrentGear )
	local cr1 = Utils.getNoNil( c1, self.mrGbMS.CurrentRange )
	local cr2 = Utils.getNoNil( c2, self.mrGbMS.CurrentRange2 )
	
	for i=1,3 do
		local check
		if     i == 1 then
			check = self.mrGbMS.Gears[cg0]
		elseif i == 2 then
			check = self.mrGbMS.Ranges[cr1]
		else --if i == 3 then
			check = self.mrGbMS.Ranges2[cr2]
		end
		
		if check == nil then
			return true
		end
		if check.minGear   ~= nil and cg0 < check.minGear   then
			return true
		end
		if check.maxGear   ~= nil and cg0 > check.maxGear   then
			return true
		end
		if check.minRange  ~= nil and cr1 < check.minRange then
			return true
		end 
		if check.maxRange  ~= nil and cr1 > check.maxRange  then
			return true
		end
		if check.minRange2 ~= nil and cr2 < check.minRange2 then
			return true
		end
		if check.maxRange2 ~= nil and cr2 > check.maxRange2 then
			return true
		end	
	end
	
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetNewEntry
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetNewEntry( entries, current, index, name )

	local new = Utils.clamp( index, 1, table.getn( entries ) )
	local cg  = self.mrGbMS.CurrentGear
	local cr  = self.mrGbMS.CurrentRange
	local c2  = self.mrGbMS.CurrentRange2
	
	local function moveIt()
		if     name == "gear"  then
			cg = new	
		elseif name == "range" then
			cr = new 
		elseif name == "range2" then
			c2 = new 
		end
	end
	
	moveIt()

	if new > current then
		while new < table.getn( entries ) 
			and gearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr, c2 ) do
			new = new + 1
			moveIt()
		end
	end
	while new > 1
		and gearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr, c2 ) do
		new = new -1
		moveIt()
	end
	while new < table.getn( entries ) 
		and gearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr, c2 ) do
		new = new + 1
		moveIt()
	end
		
	if gearboxMogli.mrGbMIsNotValidEntry( self, entries[new], cg, cr, c2 ) then
		return current
	end
	
	return new
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMCheckGrindingGears
--**********************************************************************************************************	
function gearboxMogli:mrGbMCheckGrindingGears( checkIt, noEventSend )
	if self.steeringEnabled and checkIt and not ( self:mrGbMGetAutoClutch() ) and not ( self:mrGbMGetAutomatic() ) then
		if self.mrGbMS.ManualClutch > self.mrGbMS.MinClutchPercent + 0.1 then
			self:mrGbMSetState( "InfoText", string.format( "Cannot shift gear; clutch > %3.0f%%", 100*Utils.clamp( self.mrGbMS.MinClutchPercent + 0.1, 0, 1 ) ))
			self.mrGbMS.GrindingGearsVol = 0
			self:mrGbMSetState( "GrindingGearsVol", 1 )
			return true
		end		
	end		
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMCheckDoubleClutch
--**********************************************************************************************************	
function gearboxMogli:mrGbMCheckDoubleClutch( checkIt, noEventSend )
	if      self.steeringEnabled 
			and math.abs( self.lastSpeedReal ) > 0.0003
			and checkIt 
			and not ( self:mrGbMGetAutoClutch() ) 
			and not ( self:mrGbMGetAutomatic() ) then
		return true
	end		
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetRangeForNewGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetRangeForNewGear( newGear )
	local newRange = self.mrGbMS.CurrentRange
	if      newGear > self.mrGbMS.CurrentGear 
			and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].upRangeOffset   ~= nil then 
		newRange = self.mrGbMS.CurrentRange + self.mrGbMS.Gears[self.mrGbMS.CurrentGear].upRangeOffset
	elseif  newGear < self.mrGbMS.CurrentGear
			and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].downRangeOffset ~= nil then 
		newRange = self.mrGbMS.CurrentRange + self.mrGbMS.Gears[self.mrGbMS.CurrentGear].downRangeOffset
	end

	newRange = gearboxMogli.adjustRangeToEntry( self, self.mrGbMS.Gears[newGear] )
	
	if      not self.mrGbMS.NeutralActive
			and ( self:mrGbMGetAutoShiftRange()
				 or ( self.mrGbMS.MatchRanges ~= nil
					and self.mrGbMS.MatchRanges ~= "false"
					and ( self.mrGbMS.G27Mode    <= 0
						 or not self.mrGbMS.SwapGearRangeKeys )
					and ( ( newGear ~= self.mrGbMS.CurrentGear
							and self.mrGbMS.MatchRanges == "true" )
						 or ( newGear > self.mrGbMS.CurrentGear
							and self.mrGbMS.MatchRanges == "end"
							and self.mrGbMS.CurrentRange == table.getn( self.mrGbMS.Ranges ) )
						 or ( newGear < self.mrGbMS.CurrentGear
							and self.mrGbMS.MatchRanges == "end"
							and self.mrGbMS.CurrentRange == 1 ) ) ) ) then
		
		local speed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio
		local delta = nil
		for i,r in pairs(self.mrGbMS.Ranges) do
			if not gearboxMogli.mrGbMIsNotValidEntry( self, r, newGear, i ) then			
				local diff = self.mrGbMS.Gears[newGear].speed * r.ratio - speed 
				if newGear < self.mrGbMS.CurrentGear then
					if      diff < 0
							and ( delta == nil or delta < diff ) then
						delta = diff
						newRange = i
					end
				else
					if      diff > 0
							and ( delta == nil or delta > diff ) then
						delta = diff
						newRange = i
					end
				end
			end
		end
	end
	
	newRange = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, newRange, "range" )
	return newRange
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetCurrentGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetCurrentGear( new, noEventSend, manual )
	if      not ( self.mrGbMS.NeutralActive )
			and gearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchGear, noEventSend ) then
		return false
	end
	
	local newGear  = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, new, "gear" )

	if      newGear ~= self.mrGbMS.CurrentGear 
			and gearboxMogli.mrGbMCheckDoubleClutch( self, self.mrGbMS.GearsDoubleClutch, noEventSend ) then
		if self.isServer then
			if not gearboxMogli.checkGearShiftDC( self, newGear, "G", noEventSend ) then		
				return true -- better false ???
			end
		else
			self:mrGbMSetState( "NewGear", new, noEventSend )
			return true
		end
	end

	local newRange = self.mrGbMS.CurrentRange
	if manual then
		newRange = gearboxMogli.mrGbMGetRangeForNewGear( self, newGear )
	else
		newRange = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, newRange, "range" )
	end
	
	if newGear ~= self.mrGbMS.CurrentGear then
		self:mrGbMSetState( "CurrentRange", newRange, noEventSend ) 
		self:mrGbMSetState( "CurrentRange2", gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2,  self.mrGbMS.CurrentRange2, "range2" ), noEventSend ) 
		self:mrGbMSetState( "CurrentGear",  newGear,  noEventSend ) 		

		if      self.steeringEnabled 
				and not ( self:mrGbMGetAutoClutch() ) 
				and not ( self:mrGbMGetAutomatic() ) 
				and self.mrGbMS.IsNeutral
				and self.mrGbMS.ManualClutch <= self.mrGbMS.MinClutchPercent + 0.1 then	
			self:mrGbMSetNeutralActive( false, noEventSend, true )
		end
		
		if self.isServer and manual and self.mrGbMS.NeutralActive then
			if self.mrGbMS.ReverseActive then
				self:mrGbMSetState( "ResetRevGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetRevRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			else
				self:mrGbMSetState( "ResetFwdGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			end
		end
		
		return true
	end
	
	return false
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetRangeForNewGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetGearForNewRange( newRange )
	local newGear  = self.mrGbMS.CurrentGear
	if      newRange > self.mrGbMS.CurrentRange then 
		newGear = self.mrGbMS.CurrentGear + self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].upGearOffset
	elseif  newRange < self.mrGbMS.CurrentRange then  
		newGear = self.mrGbMS.CurrentGear + self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].downGearOffset
	end
	
	newGear = gearboxMogli.adjustGearToEntry( self, self.mrGbMS.Ranges[newRange] )
	
	if      not self.mrGbMS.NeutralActive
			and ( self:mrGbMGetAutoShiftGears()
				 or ( self.mrGbMS.MatchGears ~= nil
					and self.mrGbMS.MatchGears ~= "false"
					and ( self.mrGbMS.G27Mode    <= 0
						 or self.mrGbMS.SwapGearRangeKeys )
					and ( ( newRange ~= self.mrGbMS.CurrentRange
							and self.mrGbMS.MatchGears == "true" )
						 or ( newRange > self.mrGbMS.CurrentRange
							and self.mrGbMS.MatchGears == "end"
							and self.mrGbMS.CurrentGear == table.getn( self.mrGbMS.Gears ) )
						 or ( newRange < self.mrGbMS.CurrentRange
							and self.mrGbMS.MatchGears == "end"
							and self.mrGbMS.CurrentGear == 1 ) ) ) ) then
		
		local speed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio
		local delta = nil
		for i,g in pairs(self.mrGbMS.Gears) do
			if not gearboxMogli.mrGbMIsNotValidEntry( self, g, i, newRange ) then
				local diff = g.speed * self.mrGbMS.Ranges[newRange].ratio - speed 
				if newRange < self.mrGbMS.CurrentRange then
					if      diff < 0
							and ( delta == nil or delta < diff ) then
						delta = diff
						newGear = i
					end
				else
					if      diff > 0
							and ( delta == nil or delta > diff ) then
						delta = diff
						newGear = i
					end
				end
			end
		end
	end
	
	newGear = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, newGear, "gear" )
	return newGear 
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetCurrentRange
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetCurrentRange( new, noEventSend, manual )
	if      not ( self.mrGbMS.NeutralActive )
			and gearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchHl, noEventSend ) then
		return false
	end

	local newRange = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, new, "range" )

	if      newRange ~= self.mrGbMS.CurrentRange 
			and gearboxMogli.mrGbMCheckDoubleClutch( self, self.mrGbMS.Range1DoubleClutch, noEventSend ) then
		if self.isServer then
			if not gearboxMogli.checkGearShiftDC( self, newRange, "1", noEventSend ) then		
				return true -- better false ???
			end
		else
			self:mrGbMSetState( "NewRange", new, noEventSend )
			return true
		end
	end

	local newGear  = self.mrGbMS.CurrentGear
	if manual then
		newGear = gearboxMogli.mrGbMGetGearForNewRange( self, newRange )
	else
		newGear = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, newGear, "gear" )
	end
	
	if newRange ~= self.mrGbMS.CurrentRange then
		self:mrGbMSetState( "CurrentGear",  newGear,  noEventSend ) 		
		self:mrGbMSetState( "CurrentRange2", gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2,  self.mrGbMS.CurrentRange2, "range2" ), noEventSend ) 
		self:mrGbMSetState( "CurrentRange", newRange, noEventSend ) 
	
		if      self.steeringEnabled 
				and not ( self:mrGbMGetAutoClutch() ) 
				and not ( self:mrGbMGetAutomatic() ) 
				and self.mrGbMS.IsNeutral
				and self.mrGbMS.ManualClutch <= self.mrGbMS.MinClutchPercent + 0.1 then
			self:mrGbMSetNeutralActive( false, noEventSend, true )
		end

		if self.isServer and manual and self.mrGbMS.NeutralActive then
			if self.mrGbMS.ReverseActive then
				self:mrGbMSetState( "ResetRevGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetRevRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			else
				self:mrGbMSetState( "ResetFwdGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			end
		end
		
		return true
	end
	
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetCurrentRange2
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetCurrentRange2(new, noEventSend)
	if      not ( self.mrGbMS.NeutralActive )
			and gearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchRanges2, noEventSend ) then
		return 
	end

	local newRange2 = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, new, "range2" )

	if      newRange2 ~= self.mrGbMS.CurrentRange2 
			and gearboxMogli.mrGbMCheckDoubleClutch( self, self.mrGbMS.Range2DoubleClutch, noEventSend ) then
		if self.isServer then
			if not gearboxMogli.checkGearShiftDC( self, newRange2, "2", noEventSend ) then		
				return true -- better false ???
			end
		else
			self:mrGbMSetState( "NewRange2", new, noEventSend )
			return true
		end
	end
	
	if newRange2 ~= self.mrGbMS.CurrentRange2 then
		local newRange = self.mrGbMS.CurrentRange
		local newGear  = self.mrGbMS.CurrentGear
		
		if not self.mrGbMS.NeutralActive then
			local speed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio * self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio
			local delta = nil
			local fr    = self.motor:combineGear( self.mrGbMS.CurrentGear, self.mrGbMS.CurrentRange )
			local to    = self.motor:combineGear( table.getn( self.mrGbMS.Gears ), table.getn( self.mrGbMS.Ranges ) )
			if newRange2 > self.mrGbMS.CurrentRange2 then
				to = fr
				fr = 1
			end
			for i=fr,to do
				local i2g, i2r = self.motor:splitGear( i )
				local skip = false
				if      not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Gears[i2g], i2g, i2r, newRange2 )
						and not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges[i2r], i2g, i2r, newRange2 ) then
					local diff = self.mrGbMS.Gears[i2g].speed * self.mrGbMS.Ranges[i2r].ratio * self.mrGbMS.Ranges2[newRange2].ratio - speed 
					if newRange2 < self.mrGbMS.CurrentRange2 then
						if      diff < 0
								and ( delta == nil or delta < diff ) then
							delta    = diff
							newGear  = i2g
							newRange = i2r
						end
					else
						if      diff > 0
								and ( delta == nil or delta > diff ) then
							delta    = diff
							newGear  = i2g
							newRange = i2r
						end
					end
				end
			end
		end
						
		newRange = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, newRange, "range" )
		newGear  = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears,  self.mrGbMS.CurrentGear,  newGear,  "gear" )
		
		
		self:mrGbMSetState( "CurrentRange", newRange, noEventSend ) 
		self:mrGbMSetState( "CurrentGear",  newGear,  noEventSend ) 		
		self:mrGbMSetState( "CurrentRange2", newRange2, noEventSend ) 

		if      self.steeringEnabled 
				and not ( self:mrGbMGetAutoClutch() ) 
				and not ( self:mrGbMGetAutomatic() ) 
				and self.mrGbMS.IsNeutral
				and self.mrGbMS.ManualClutch <= self.mrGbMS.MinClutchPercent + 0.1 then
			self:mrGbMSetNeutralActive( false, noEventSend, true )
		end

		if self.isServer and manual and self.mrGbMS.NeutralActive then
			if self.mrGbMS.ReverseActive then
				self:mrGbMSetState( "ResetRevGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetRevRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			else
				self:mrGbMSetState( "ResetFwdGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			end
		end
		
		return true
	end
	
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetAccelerateToLimit
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetAccelerateToLimit( value, noEventSend )
	self:mrGbMSetState( "AccelerateToLimit", Utils.clamp( value, 1, 10 ), noEventSend ) 		
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetDecelerateToLimit
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetDecelerateToLimit( value, noEventSend )
	self:mrGbMSetState( "DecelerateToLimit", Utils.clamp( value, 1, 20 ), noEventSend ) 		
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetAutomatic
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetAutomatic( value, noEventSend )
	local new = false 
	if value and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 ) then
		new = true 
	end 
	self:mrGbMSetState( "Automatic", new, noEventSend ) 		
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetNeutralActive
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetNeutralActive( value, noEventSend, noCheck )

--if value ~= self.mrGbMS.NeutralActive then
--	gearboxMogli.debugEvent( self, self.mrGbMS.NeutralActive, value, noEventSend )
--end

	if      not ( value )
			and self.mrGbMS.NeutralActive
			and not ( noCheck )
			and gearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchReverse, noEventSend ) then
		return false
	end

	self:mrGbMSetState( "NeutralActive", value, noEventSend ) 
	
	return true
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetReverseActive
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetReverseActive( value, noEventSend )
	if      self.mrGbMS.ReverseActive ~= nil
			and self.mrGbMS.ReverseActive ~= value 
			and not ( self.mrGbMS.NeutralActive )
			and gearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchReverse, noEventSend ) then
		return false
	end
	
	local f = -1
	if value then
		f = 1
	end
	
	if self.mrGbMS.ReverseActive ~= value then
		self.mrGbML.DirectionChangeTime = g_currentMission.time
		self.mrGbML.ReverserNeutral     = true
		
		if gearboxMogli.mrGbMCheckDoubleClutch( self, self.mrGbMS.ReverseDoubleClutch, noEventSend ) then
			if self.isServer then
				if not gearboxMogli.checkGearShiftDC( self, value, "R", noEventSend ) then		
					return true -- better false ???
				end
			else
				self:mrGbMSetState( "NewReverse", value, noEventSend )
				return true
			end
		end
	end

	if      self.steeringEnabled 
			and not ( self:mrGbMGetAutoClutch() ) 
			and not ( self:mrGbMGetAutomatic() ) 
			and self.mrGbMS.IsNeutral
			and self.mrGbMS.ManualClutch <= self.mrGbMS.MinClutchPercent + 0.1 then
		self:mrGbMSetNeutralActive( false, noEventSend, true )
	end
	
	self:mrGbMSetState( "ReverseActive", value, noEventSend ) 

	return true
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetHandThrottle
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetHandThrottle( value, noEventSend )
	self:mrGbMSetState( "HandThrottle", Utils.clamp( value, 0, 1 ), noEventSend )
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetManualClutch
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetManualClutch( value, noEventSend )
	self:mrGbMSetState( "ManualClutch", Utils.clamp( value, 0, 1 ), noEventSend ) 		
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoClutchPercent
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoClutchPercent()
	if self.mrGbML.motor == nil or not ( self.isServer ) then
		return 0
	end
	
	if     self.mrGbMS.NeutralActive then
		return 0
	elseif self.mrGbMS.ManualClutch < 1
	    or not self:mrGbMGetAutoClutch() then
		return self.mrGbMS.ManualClutch
	elseif self.mrGbMS.TorqueConverterOrHydro then
		return 1
	else
		return self.motor.clutchPercent
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetClutchPercent
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetClutchPercent()
	if self.mrGbML.motor == nil then
		return 0
	end
	if self:mrGbMGetAutoClutch() then 
		if self.isServer then
			return gearboxMogli.mrGbMGetAutoClutchPercent( self )
		end
		return self.mrGbMD.Clutch*0.005
	end	
	return self.mrGbMS.ManualClutch
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetCurrentRPM
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetCurrentRPM()
	if self.mrGbML.motor == nil then
		if self.motor ~= nil then
			return self.motor:getEqualizedMotorRpm()
		else
			return nil
		end
	end
--if self.isServer then
		return Utils.getNoNil( self.motor.lastMotorRpm, self.motor:getEqualizedMotorRpm() )
--end
--return self.mrGbMS.CurMinRpm + self.mrGbMD.Rpm * (self.mrGbMS.RatedRpm-self.mrGbMS.CurMinRpm) * 0.005
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetTargetRPM
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetTargetRPM()
	if self.mrGbML.motor == nil then
		return nil
	end

	if not ( self.mrGbMS.sendTargetRpm ) then
		self:mrGbMSetState( "sendTargetRpm", true )
		return 0
	else
		if self.isServer then
			return self.motor.targetRpm 
		end
		return self.mrGbMS.CurMinRpm + self.mrGbMD.Tgt * (self.mrGbMS.RatedRpm-self.mrGbMS.CurMinRpm) * 0.005
	end
	return nil
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetUsedPower
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetUsedPower()
	if self.mrGbML.motor == nil then
		return nil
	end
	
	if not ( self.mrGbMS.sendReqPower ) then
		self:mrGbMSetState( "sendReqPower", true )
		return 0
	else
		return self.mrGbMD.Power
	end
	return nil
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetHydrostaticFactor
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetHydrostaticFactor( defaultNoHydro )		

	if self.mrGbMS.Hydrostatic then
		if not ( self.mrGbMS.sendHydro ) then
			self:mrGbMSetState( "sendHydro", true )
		elseif 0 <= self.mrGbMD.Hydro and self.mrGbMD.Hydro <= 200 then
			return self.mrGbMS.HydrostaticMin + 0.005 * self.mrGbMD.Hydro * ( self.mrGbMS.HydrostaticMax - self.mrGbMS.HydrostaticMin )
		end
	end
	
	return defaultNoHydro
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetCombineLS(erver) liters per second
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetCombineLS()
	local sqm = 0
	if gearboxMogli.combineUseRealArea then
		sqm = self.mrGbML.realAreaPerSecond  
	else
		sqm = self.mrGbML.cutterAreaPerSecond
	end
	
	if      self.mrGbMS.IsCombine 
			and sqm ~= nil
			and sqm > 0 then
		
		sqm = sqm * g_currentMission:getFruitPixelsToSqm()

		local fruitType
		if      self.mrGbML.currentFruitType == nil then
			fruitType = FruitUtil.FRUITTYPE_UNKNOWN  
		elseif  self.mrGbML.currentFruitType      == FruitUtil.FRUITTYPE_CHAFF
				and self.mrGbML.currentInputFruitType ~= nil
		    and self.mrGbML.currentInputFruitType ~= FruitUtil.FRUITTYPE_MAIZE then
			fruitType = self.mrGbML.currentInputFruitType
		else
			fruitType = self.mrGbML.currentFruitType
		end			

		if     fruitType == FruitUtil.FRUITTYPE_WHEAT     then
			sqm = sqm * 1.2
		elseif fruitType == FruitUtil.FRUITTYPE_BARLEY    then
			sqm = sqm * 1.1
		elseif fruitType == FruitUtil.FRUITTYPE_RAPE      then
			sqm = sqm * 0.6
		elseif fruitType == FruitUtil.FRUITTYPE_MAIZE     then
			sqm = sqm * 1.2
		elseif fruitType == FruitUtil.FRUITTYPE_POTATO    then
			sqm = sqm * 4  
		elseif fruitType == FruitUtil.FRUITTYPE_SUGARBEET then
			sqm = sqm * 3.5
		elseif fruitType == FruitUtil.FRUITTYPE_GRASS     then
			sqm = sqm * 1.2
		elseif fruitType == FruitUtil.FRUITTYPE_DRYGRASS  then
			sqm = sqm * 1.2
		elseif fruitType == FruitUtil.FRUITTYPE_CHAFF     then
			sqm = sqm * 3.9
		elseif  fruitType                                         ~= nil 
				and FruitUtil.fruitIndexToDesc[fruitType]             ~= nil 
				and FruitUtil.fruitIndexToDesc[fruitType].literPerSqm ~= nil then
			if not ( gearboxMogli.combineUseRealArea ) then     
			-- factor 2 because of spraySum in CutterAreaEvent.lua
				sqm = sqm * 2 * FruitUtil.fruitIndexToDesc[fruitType].literPerSqm 
			elseif  FruitUtil.fruitIndexToDesc[fruitType].origLiterPerSqm ~= nil then
			-- realistic yield 
				sqm = sqm * FruitUtil.fruitIndexToDesc[fruitType].origLiterPerSqm
			else
			-- standard
				sqm = sqm * FruitUtil.fruitIndexToDesc[fruitType].literPerSqm
			end
		else
			sqm = 0
		end

	else
		sqm = 0
	end
	
	return sqm
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetThroughPutS
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetThroughPutS()
	if self.mrGbML.motor == nil then
		return nil
	end
	
	if      self.mrGbMS.IsCombine 
			and self.mrGbML.cutterAreaPerSecond ~= nil
			and self.mrGbML.cutterAreaPerSecond > 0 then
			
		sqm = self.mrGbML.cutterAreaPerSecond * g_currentMission:getFruitPixelsToSqm()
			
		local fruitType= FruitUtil.FRUITTYPE_UNKNOWN  
		if self.mrGbML.currentFruitType ~= nil then
			fruitType = self.mrGbML.currentFruitType
		end			
		if      fruitType ~= FruitUtil.FRUITTYPE_UNKNOWN 
				and FruitUtil.fruitIndexToDesc[fruitType]             ~= nil
				and FruitUtil.fruitIndexToDesc[fruitType].literPerSqm ~= nil then
			sqm = sqm * FruitUtil.fruitIndexToDesc[fruitType].literPerSqm
		end		
		if      fruitType ~= FruitUtil.FRUITTYPE_UNKNOWN 
				and FruitUtil.fruitTypeToFillType[fruitType]                               ~= nil
				and FillUtil.fillTypeIndexToDesc[FruitUtil.fruitTypeToFillType[fruitType]] ~= nil then
			return sqm * FillUtil.fillTypeIndexToDesc[FruitUtil.fruitTypeToFillType[fruitType]].massPerLiter * 3600
		else
			return sqm * 3.6
		end
	end

	return 0
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetThroughPut
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetThroughPut()
	if self.mrGbML.motor == nil then
		return nil
	end
	
	if     self.isServer then
		return gearboxMogli.mrGbMGetThroughPutS( self )
	elseif self.mrGbMD.Rate ~= nil then
		return self.mrGbMD.Rate
	end
	return 0
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetMotorLoad
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetMotorLoad()
	return self.mrGbML.MotorLoad 
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetGearText
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetGearText()

	if     self.mrGbMS               == nil
			or self.mrGbMS.Gears         == nil
			or self.mrGbMS.CurrentGear   == nil
			or self.mrGbMS.Ranges        == nil
			or self.mrGbMS.CurrentRange  == nil
			or self.mrGbMS.Ranges2       == nil 
			or self.mrGbMS.CurrentRange2 == nil then
		return ""
	end

	if self.mrGbMS.G27Mode       == 1 then
		return gearboxMogli.getText( "gearboxMogliTEXT_NOGEAR", "no gear" )
	end
	
	local gearText = Utils.getNoNil( self.mrGbMS.Gears[self.mrGbMS.CurrentGear].name, "" )
	if self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name ~= nil and self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name ~= "" then
	--if self.mrGbMS.SwapGearRangeKeys then
	--	gearText = gearText .." ".. self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name
	--else
			gearText = self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name .." ".. gearText
	--end
	end
	if self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name ~= nil and self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name ~= "" then
		gearText = self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name .." ".. gearText
	end
	
	if self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames ~= nil then
		local r1 = self.mrGbMS.CurrentRange
		local r2 = self.mrGbMS.CurrentRange2
		
		while true do		
			if      self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[r1]     ~= nil 
					and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[r1][r2] ~= nil then
				gearText = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[r1][r2]
				if r1 == 0 and self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name ~= nil and self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name ~= "" then
					gearText = self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].name .." ".. gearText
				end
				if r2 == 0 and self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name ~= nil and self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name ~= "" then
					gearText = self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].name .." ".. gearText
				end
				break
			end
			
			if     r2 ~= 0 then
				r2 = 0
			elseif r1 ~= 0 then
				r1 = 0
				r2 = self.mrGbMS.CurrentRange2
			else
				break 
			end
		end
	end
	
	return gearText
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetNumberHelper
--**********************************************************************************************************	
function gearboxMogli.mrGbMGetNumberHelper( array, current, rev )
	if type(array) ~= "table" or current == nil then
		return 0
	end
	
	local number = 0
	
	for i,g in pairs(array) do
		if i > current then
			break
		end
		if rev then
			if not ( g.forwardOnly ) then
				number = number + 1 
			end
		else
			if not ( g.reverseOnly ) then
				number = number + 1 
			end
		end
	end
	
	return number
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetGearSpeed
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetGearSpeed()
	if self.motor == nil then
		return 0
	end
	if self.mrGbMD == nil then
		return 3.6 * self.motor.maxForwardSpeed
	end
	
	local speed 
	speed = 3.6 * self.mrGbMS.CurrentGearSpeed 
	if self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticMax ~= nil then
		speed = speed * self.mrGbMS.HydrostaticMax
	end
	return speed
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetGearNumber
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetGearNumber()
	if self.mrGbMS == nil then
		return 0
	end
	return gearboxMogli.mrGbMGetNumberHelper( self.mrGbMS.Gears, self.mrGbMS.CurrentGear, self.mrGbMS.ReverseActive )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetRangeNumber
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetRangeNumber()
	if self.mrGbMS == nil then
		return 0
	end
	return gearboxMogli.mrGbMGetNumberHelper( self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, self.mrGbMS.ReverseActive )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetRange2Number
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetRange2Number()
	if self.mrGbMS == nil then
		return 0
	end
	return gearboxMogli.mrGbMGetNumberHelper( self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, self.mrGbMS.ReverseActive )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetModeText
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetModeText()
	return self.mrGbMS.DrawText
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetModeShortText
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetModeShortText()
	return self.mrGbMS.DrawText2
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetIsOn
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetIsOn()
	return self.mrGbMS.IsOn
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetHasAllAuto
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetHasAllAuto()

	if not self.mrGbMS.AutoShiftHl then
		local cf, cr = 0, 0
		for _,r in pairs(self.mrGbMS.Ranges) do
			if r.forwardOnly then
				cf = cf + 1
			elseif r.reverseOnly then
				cr = cr + 1
			else
				cf = cf + 1
				cr = cr + 1 
			end
		end
		if cf > 1 or cr > 1 then
			return true
		end
	end
	
	if not self.mrGbMS.AutoShiftGears then
		local cf, cr = 0, 0
		for _,g in pairs(self.mrGbMS.Gears) do
			if g.forwardOnly then
				cf = cf + 1
			elseif g.reverseOnly then
				cr = cr + 1
			else
				cf = cf + 1
				cr = cr + 1 
			end
		end
		if cf > 1 or cr > 1 then
			return true
		end
	end
	
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoStartStop
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoStartStop()
	return self.mrGbMS.AllAuto or self.mrGbMS.AutoStartStop or self.mrGbMG.autoStartStop or not ( self.steeringEnabled )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoShiftGears
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoShiftGears()

	local i = 0
	for _,r in pairs( self.mrGbMS.Gears ) do
		if not self.mrGbMS.ReverseActive and r.reverseOnly then
		elseif self.mrGbMS.ReverseActive and r.forwardOnly then
		else
			i = i + 1
		end
	end
	
	if i <= 1 then
		return false
	end
	
	if      self.mrGbMS.AllAuto then
		return true
	elseif  self.mrGbMS.Automatic 
			and self.mrGbMS.AutoShiftGears then
		return true
	elseif not ( self.steeringEnabled ) then
		if      self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
				and self:mrGbMGetHasAllAuto() then
			return true
		elseif  self.mrGbMS.AutoShiftGears
				or  self.mrGbMS.AutoShiftHl
				or  self.mrGbMS.AutoShiftRange2 then
			return false
		elseif  self.mrGbMS.EnableAI == gearboxMogli.AIPowerShift
				and self.mrGbMS.GearShiftEffectGear then
			return true
		end
	end
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoShiftRange
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoShiftRange()

	local i = 0
	for _,r in pairs( self.mrGbMS.Ranges ) do
		if not self.mrGbMS.ReverseActive and r.reverseOnly then
		elseif self.mrGbMS.ReverseActive and r.forwardOnly then
		else
			i = i + 1
		end
	end
	
	if i <= 1 then
		return false
	end
	
	if      self.mrGbMS.AllAuto then
		return true
	elseif  self.mrGbMS.Automatic 
			and self.mrGbMS.AutoShiftHl then
		return true
	elseif not ( self.steeringEnabled ) then
		if      self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
				and self:mrGbMGetHasAllAuto() then
			return true
		elseif  self.mrGbMS.AutoShiftGears
				or  self.mrGbMS.AutoShiftHl
				or  self.mrGbMS.AutoShiftRange2 then
			return false
		elseif  self.mrGbMS.EnableAI == gearboxMogli.AIPowerShift
				and self.mrGbMS.GearShiftEffectHl then
			return true
		end
	end
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoShiftRange
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoShiftRange2()

	local i = 0
	for _,r in pairs( self.mrGbMS.Ranges2 ) do
		if not self.mrGbMS.ReverseActive and r.reverseOnly then
		elseif self.mrGbMS.ReverseActive and r.forwardOnly then
		else
			i = i + 1
		end
	end
	
	if i <= 1 then
		return false
	end
	
	if      self.mrGbMS.AllAuto then
		return true
	elseif  self.mrGbMS.Automatic 
			and self.mrGbMS.AutoShiftRange2 then
		return true
	elseif not ( self.steeringEnabled ) then
		if      self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
				and self:mrGbMGetHasAllAuto() then
			return true
		elseif  self.mrGbMS.AutoShiftGears
				or  self.mrGbMS.AutoShiftHl
				or  self.mrGbMS.AutoShiftRange2 then
			return false
		elseif  self.mrGbMS.EnableAI == gearboxMogli.AIPowerShift
				and self.mrGbMS.GearShiftEffectRanges2 then
			return true
		end
	end
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoClutch
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoClutch()
	return self.mrGbMS.AllAuto 
			or self.mrGbMS.AutoClutch 
			or not ( self.steeringEnabled ) 
			or ( self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetIsOn
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutomatic()
	if      self.mrGbMS.AllAuto then
		return true
	elseif  self.mrGbMS.Automatic then
		return true
	elseif  not ( self.steeringEnabled )
			and self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
			and self:mrGbMGetHasAllAuto() then
		return true
	elseif  not ( self.steeringEnabled )
			and self.mrGbMS.EnableAI == gearboxMogli.AIPowerShift
			and ( self.mrGbMS.GearShiftEffectGear or self.mrGbMS.GearShiftEffectHl ) then
		return true
	end
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMPrepareGearShift
--**********************************************************************************************************	
function gearboxMogli:mrGbMPrepareGearShift( timeToShift, clutchPercent, doubleClutch, shiftingEffect, noThrottle )
	if self.isServer then
	--print("prepare gear shift (server): "..
	--			tostring(self.mrGbMS.CurrentGear)	..", "..
	--			tostring(self.mrGbMS.CurrentRange)..", "..
	--			tostring(self.mrGbMS.CurrentRange2)..", "..	
	--			tostring(self.mrGbMS.ReverseActive)..", "..
	--			tostring(self.mrGbMS.NeutralActive))
	
		if self.mrGbML.motor ~= nil then
			self.mrGbML.beforeShiftRpm = self.motor.lastRealMotorRpm 
			if gearboxMogli.debugGearShift then
				self.mrGbML.debugTimer = g_currentMission.time + 1000
			end				
			-- reset some values...
			self.motor.requestedPower1 = nil
			self.motor.targetRpm1      = nil
		end
		self.mrGbML.autoShiftTime = g_currentMission.time + timeToShift
		
		if      shiftingEffect and ( timeToShift >= 0 ) 
				and not self.mrGbMS.NeutralActive 
				and self.mrGbML.gearShiftingTime <= self.mrGbML.autoShiftTime then
			self.mrGbML.gearShiftingEffect = true
		else
			self.mrGbML.gearShiftingEffect = false
		end
		
		local minTimeToShift = self.mrGbMG.minTimeToShift
		
		if self.mrGbMS.NeutralActive then
			gearboxMogli.mrGbMDoGearShift(self)
			self.mrGbML.gearShiftingNeeded = 0
		elseif noThrottle and not self:mrGbMGetAutoClutch() then
			if     self.mrGbML.gearShiftingNeeded ~= 0 then
			-- nothing
			elseif self.mrGbMS.NeutralActive 
					or self.mrGbMS.ManualClutch < self.mrGbMS.MinClutchPercent + 0.1 then
				gearboxMogli.mrGbMDoGearShift(self)
			else
				self.mrGbML.gearShiftingNeeded = gearboxMogli.gearShiftingNoThrottle
				self.mrGbML.gearShiftingTime   = g_currentMission.time + math.max( minTimeToShift, timeToShift )
			end
		elseif  ( timeToShift < 0 or ( timeToShift == 0 and minTimeToShift == 0 ) ) 
				and self.mrGbML.gearShiftingTime < g_currentMission.time
				and self.mrGbML.gearShiftingNeeded == 0 then
			gearboxMogli.mrGbMDoGearShift(self)		
		elseif self:mrGbMGetAutoClutch() then
			self.mrGbML.gearShiftingNeeded   = 1
			self.mrGbML.gearShiftingTime     = math.max( self.mrGbML.gearShiftingTime, g_currentMission.time + math.max( minTimeToShift, timeToShift ) ) 
			if self.mrGbML.afterShiftClutch == nil or self.mrGbML.afterShiftClutch > clutchPercent then
				self.mrGbML.afterShiftClutch   = clutchPercent
			end
			if doubleClutch then
				self.mrGbML.doubleClutch       = true
				self.mrGbML.clutchShiftingTime = math.max( self.mrGbML.clutchShiftingTime, g_currentMission.time + 0.4 * timeToShift ) 
			else
				self.mrGbML.clutchShiftingTime = math.max( self.mrGbML.clutchShiftingTime, g_currentMission.time + self.mrGbMS.ClutchShiftTime ) 
			end
		elseif doubleClutch then
			self.mrGbML.gearShiftingNeeded  = -1 
		else
			gearboxMogli.mrGbMDoGearShift(self)		
			self.mrGbML.gearShiftingNeeded  = 0
		end
	else
		print("FS17_GearboxAddon: Error! gearboxMogli:mrGbMPrepareGearShift called at client")
	end 
	
--print("B: "..tostring(self.mrGbML.beforeShiftRpm))
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMDoGearShift
--**********************************************************************************************************	
function gearboxMogli:mrGbMDoGearShift()
	if self.isServer then
	--print("do gear shift (server): "..
	--			tostring(self.mrGbMS.CurrentGear)	..", "..
	--			tostring(self.mrGbMS.CurrentRange)..", "..
	--			tostring(self.mrGbMS.CurrentRange2)..", "..	
	--			tostring(self.mrGbMS.ReverseActive)..", "..
	--			tostring(self.mrGbMS.NeutralActive))
	
		
		if     self.mrGbMS               == nil
				or self.mrGbMS.Gears         == nil
				or self.mrGbMS.CurrentGear   == nil
				or self.mrGbMS.Ranges        == nil
				or self.mrGbMS.CurrentRange  == nil
				or self.mrGbMS.Ranges2       == nil 
				or self.mrGbMS.CurrentRange2 == nil then
			self:mrGbMSetState( "CurrentGearSpeed", 0 )
			return
		end

		if     self.mrGbML.gearShiftingTime < g_currentMission.time then
			self.mrGbML.gearShiftingNeeded = 0
		elseif self.mrGbML.doubleClutch then
			self.mrGbML.gearShiftingNeeded = 2
		else
			self.mrGbML.gearShiftingNeeded = 3
		end
		self.mrGbML.doubleClutch = false
		
		local gearMaxSpeed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed 
		                   * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio 
											 * self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio
											 * self.mrGbMS.GlobalRatioFactor
		if self.mrGbMS.ReverseActive then	
			gearMaxSpeed = gearMaxSpeed * self.mrGbMS.ReverseRatio 
		end
		
		self.mrGbML.lastShiftTime    = g_currentMission.time
		self.mrGbML.autoShiftTime    = g_currentMission.time
		self.mrGbML.lastGearSpeed    = Utils.getNoNil( self.mrGbMS.CurrentGearSpeed, 0 )				
		self:mrGbMSetState( "CurrentGearSpeed", gearMaxSpeed )
		
		if self.mrGbML.motor ~= nil then	
			self.mrGbML.motor.deltaRpm = 0
			
			if self.mrGbML.beforeShiftRpm ~= nil then
				self.mrGbML.afterShiftRpm = Utils.clamp( self.mrGbML.beforeShiftRpm * self.mrGbML.lastGearSpeed / self.mrGbMS.CurrentGearSpeed, self.mrGbML.motor.vehicle.mrGbMS.IdleRpm, self.mrGbML.motor.vehicle.mrGbMS.CurMaxRpm )
			else
				self.mrGbML.afterShiftRpm = nil
			end
			
			if self.mrGbMS.Hydrostatic then
				self.motor.hydrostaticFactorT = self.mrGbMS.HydrostaticStart
			end
			self.motor.ratioFactorR = nil
		else
			self.mrGbML.afterShiftClutch  = nil
			self.mrGbML.beforeShiftRpm    = nil
			self.mrGbML.afterShiftRpm     = nil
		end		
	end 

--print("B: "..tostring(self.mrGbML.beforeShiftRpm).." => A: "..tostring(self.mrGbML.afterShiftRpm))
end 

--**********************************************************************************************************	
-- gearboxMogli:setLaunchGear
--**********************************************************************************************************	
function gearboxMogli:setLaunchGear( noEventSend, init )	
	
	local gear      = self.mrGbMS.CurrentGear
	local oldGear   = self.mrGbMS.CurrentGear
	local range     = self.mrGbMS.CurrentRange
	local oldRange  = self.mrGbMS.CurrentRange
	local gearSpeed = self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio * self.mrGbMS.GlobalRatioFactor	
	local maxSpeed  = self.mrGbMS.LaunchGearSpeed
	
	if self.mrGbMS.ConstantRpm then
		maxSpeed      = self.mrGbMS.LaunchPtoSpeed
		if self.mrGbMS.HandThrottle > 0 then
			maxSpeed    = maxSpeed * self.mrGbMS.IdleRpm / ( self.mrGbMS.IdleRpm + self.mrGbMS.HandThrottle * ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) )
		end
	end
	
	if self.mrGbMS.ReverseActive then
		gearSpeed = gearSpeed * self.mrGbMS.ReverseRatio 
	end

	local skip = false
	
	if not ( init ) then
		if self.mrGbMS.CurrentGearSpeed ~= nil and self.mrGbMS.CurrentGearSpeed < maxSpeed then
			maxSpeed = self.mrGbMS.CurrentGearSpeed
		end
		if not self.steeringEnabled then
			if self.mrGbMS.ReverseActive then
				if self.mrGbML.aiGearR ~= nil and self.mrGbML.aiRangeR ~= nil then
					gear  = self.mrGbML.aiGearR
					range = self.mrGbML.aiRangeR
					skip  = true
				end
			else
				if self.mrGbML.aiGearF ~= nil and self.mrGbML.aiRangeF ~= nil then
					gear  = self.mrGbML.aiGearF
					range = self.mrGbML.aiRangeF
					skip  = true
				end
			end
		end
	end
	
	if not skip then
		local lg, lr, l2 = self.mrGbMS.CurrentGear, self.mrGbMS.CurrentRange, self.mrGbMS.CurrentRange2
		
		if     self:mrGbMGetAutoShiftGears()
				or self.mrGbMS.MatchGears == "true"
				or self.mrGbMS.ReverseResetGear then
			if self.mrGbMS.ReverseActive then
				lg = self.mrGbMS.ResetRevGear
			else
				lg = self.mrGbMS.ResetFwdGear
			end						
		end
		if     self:mrGbMGetAutoShiftRange()
				or self.mrGbMS.MatchRanges == "true"
				or self.mrGbMS.ReverseResetRange then
			if self.mrGbMS.ReverseActive then
				lr = self.mrGbMS.ResetRevRange
			else
				lr = self.mrGbMS.ResetFwdRange
			end			
		end
		if     self:mrGbMGetAutoShiftRange2()
				or self.mrGbMS.ReverseResetRange2 then
			if self.mrGbMS.ReverseActive then
				l2 = self.mrGbMS.ResetRevRange2
			else
				l2 = self.mrGbMS.ResetFwdRange2
			end			
		end

		lg = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, lg, "gear" )
		lr = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, lr, "range" )
		l2 = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, l2, "range2" )
		
		self:mrGbMSetState( "CurrentGear", lg, noEventSend ) 
		self:mrGbMSetState( "CurrentRange", lr, noEventSend ) 
		self:mrGbMSetState( "CurrentRange2", l2, noEventSend ) 
	
		maxSpeed = self.mrGbMS.Gears[lg].speed
						 * self.mrGbMS.Ranges[lr].ratio
						 * self.mrGbMS.Ranges2[l2].ratio
						 * self.mrGbMS.GlobalRatioFactor
						 * 3.6

		if self.mrGbMS.ReverseActive then
			maxSpeed = maxSpeed * self.mrGbMS.ReverseRatio 
		end

		self:mrGbMSetState( "LaunchGearSpeed", maxSpeed, noEventSend ) 
	else
		if self:mrGbMGetAutoShiftRange() then
			self:mrGbMSetCurrentRange( range, noEventSend ) 	
		end
		if self:mrGbMGetAutoShiftGears() then 
			self:mrGbMSetCurrentGear( gear, noEventSend ) 	
		end
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetLanuchGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetLanuchGear( noEventSend )
	if self.steeringEnabled then
		gearboxMogli.setLaunchGear( self, noEventSend )
	end		
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetReverse
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetReverse( old, new, noEventSend )

	self.mrGbMS.ReverseActive = new 
	--timer to shift the "reverse/forward"
	
	--remember current gear of old direction 
	if ( not ( new ) and old ) or ( new and not ( old ) ) then
		if 			self.mrGbMS.ReverseResetGear
				and not ( self:mrGbMGetAutoShiftGears()
							 or self.mrGbMS.MatchGears == "true" ) then
			if old then
				self:mrGbMSetState( "ResetRevGear", self.mrGbMS.CurrentGear, noEventSend )
			else
				self:mrGbMSetState( "ResetFwdGear", self.mrGbMS.CurrentGear, noEventSend )
			end						
		end
		if      self.mrGbMS.ReverseResetRange
				and not ( self:mrGbMGetAutoShiftRange()
							 or self.mrGbMS.MatchRanges == "true" ) then
			if old then
				self:mrGbMSetState( "ResetRevRange", self.mrGbMS.CurrentRange, noEventSend )
			else
				self:mrGbMSetState( "ResetFwdRange", self.mrGbMS.CurrentRange, noEventSend )
			end			
		end
		if      self.mrGbMS.ReverseResetRange2
				and not self:mrGbMGetAutoShiftRange2() then
			if old then
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend )
			else
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend )
			end			
		end
	end
	
	-- restore last gear of new direction 
	self:mrGbMSetLanuchGear( noEventSend )	

	if self.isServer then
		self.mrGbML.lastReverse = Utils.getNoNil( old, false )
		gearboxMogli.mrGbMPrepareGearShift( self, self.mrGbMS.GearTimeToShiftReverse, self.mrGbMS.ClutchAfterShiftReverse, self.mrGbMS.ReverseDoubleClutch, false ) 
		if ( not ( new ) and old ) or ( new and not ( old ) ) then
			if self.mrGbMS.Hydrostatic then
				self.motor.hydrostaticFactorT = self.mrGbMS.HydrostaticStart
			end
			self.mrGbML.motor.speedLimitS       = 0
			self.mrGbML.motor.motorLoadOverflow = 0
		end
	end	
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoHold
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoHold( )
	if not ( self.steeringEnabled ) then
		return false
	elseif self:mrGbMGetAutoStartStop() then
		return true
	elseif self.dCcheckModule ~= nil and self:dCcheckModule("handBrake") then
		return false
	end
	return self.mrGbMG.autoHold
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetOnlyHandThrottle
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetOnlyHandThrottle( )
	if not ( self.steeringEnabled ) then
		return false
	elseif self.mrGbMS.AllAuto then
		return false 
	end
	return self.mrGbMS.OnlyHandThrottle 
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNeutral
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNeutral( old, new, noEventSend )		
	self.mrGbMS.NeutralActive   = new 

	if new and self.mrGbMS.G27Mode <= 0  then
		self:mrGbMSetLanuchGear( noEventSend )
	end
	
	if self.isServer then
		gearboxMogli.mrGbMPrepareGearShift( self, 0, self.mrGbMS.MinClutchPercent, false, false ) 
		if self.mrGbML.motor ~= nil then
			self.mrGbML.motor.speedLimitS = 0
		end
		
		if new then
			if self.mrGbMS.Hydrostatic then
				self.motor.hydrostaticFactorT = self.mrGbMS.HydrostaticStart
			end
		else
			self:mrGbMSetState( "AutoHold", false )
			if      self:mrGbMGetOnlyHandThrottle()
					and self.mrGbMS.HandThrottle < self.mrGbMS.MinHandThrottle then
				self:mrGbMSetHandThrottle( self.mrGbMS.MinHandThrottle, noEventSend )
			end								
		end
	end
end 

--**********************************************************************************************************	
-- gearboxMogli:adjustGearToEntry
--**********************************************************************************************************	
function gearboxMogli:adjustGearToEntry( n, g )
	local j = Utils.getNoNil( g, self.mrGbMS.CurrentGear )
	local ma = table.getn( self.mrGbMS.Gears )	
	
	if j < 1 then
		j = 1
	elseif j > ma then
		j = ma
	end
	
	if n == nil then
		return j
	end

	local i = j
	local m = ma	
	if n.maxGear ~= nil and n.maxGear < m then
		m = n.maxGear 
	end
	
	while j > m and i > 1 do
		i = i - 1
		if     self.mrGbMS.Gears[i].forwardOnly and self.mrGbMS.ReverseActive then
		elseif self.mrGbMS.Gears[i].reverseOnly and not self.mrGbMS.ReverseActive then
		else
			j = i
		end
	end

	i = j
	m = 1
	if n.minGear ~= nil and n.minGear > m then
		m = n.minGear
	end	
	
	while j < m and i < ma do
		i = i + 1
		if     self.mrGbMS.Gears[i].forwardOnly and self.mrGbMS.ReverseActive then
		elseif self.mrGbMS.Gears[i].reverseOnly and not self.mrGbMS.ReverseActive then
		else
			j = i
		end
	end
	
	return j
end

--**********************************************************************************************************	
-- gearboxMogli:adjustRangeToEntry
--**********************************************************************************************************	
function gearboxMogli:adjustRangeToEntry( n, r )
	local j = Utils.getNoNil( r, self.mrGbMS.CurrentRange )
	local ma = table.getn( self.mrGbMS.Ranges )	
	
	if j < 1 then
		j = 1
	elseif j > ma then
		j = ma
	end
	
	if n == nil then
		return j
	end

	local i = j
	local m = ma	
	if n.maxRange ~= nil and n.maxRange < m then
		m = n.maxRange 
	end
	
	while j > m and i > 1 do
		i = i - 1
		if     self.mrGbMS.Ranges[i].forwardOnly and self.mrGbMS.ReverseActive then
		elseif self.mrGbMS.Ranges[i].reverseOnly and not self.mrGbMS.ReverseActive then
		else
			j = i
		end
	end

	i = j
	m = 1
	if n.minRange ~= nil and n.minRange > m then
		m = n.minRange
	end	
	
	while j < m and i < ma do
		i = i + 1
		if     self.mrGbMS.Ranges[i].forwardOnly and self.mrGbMS.ReverseActive then
		elseif self.mrGbMS.Ranges[i].reverseOnly and not self.mrGbMS.ReverseActive then
		else
			j = i
		end
	end
	
	return j
end

--**********************************************************************************************************	
-- gearboxMogli:adjustRange2ToEntry
--**********************************************************************************************************	
function gearboxMogli:adjustRange2ToEntry( n, r )
	local j = Utils.getNoNil( r, self.mrGbMS.CurrentRange2 )
	local ma = table.getn( self.mrGbMS.Ranges2 )	
	
	if j < 1 then
		j = 1
	elseif j > ma then
		j = ma
	end
	
	if n == nil then
		return j
	end

	local i = j
	local m = ma	
	if n.maxRange2 ~= nil and n.maxRange2 < m then
		m = n.maxRange2 
	end
	
	while j > m and i > 1 do
		i = i - 1
		if     self.mrGbMS.Ranges2[i].forwardOnly and self.mrGbMS.ReverseActive then
		elseif self.mrGbMS.Ranges2[i].reverseOnly and not self.mrGbMS.ReverseActive then
		else
			j = i
		end
	end

	i = j
	m = 1
	if n.minRange2 ~= nil and n.minRange2 > m then
		m = n.minRange2
	end	
	
	while j < m and i < ma do
		i = i + 1
		if     self.mrGbMS.Ranges2[i].forwardOnly and self.mrGbMS.ReverseActive then
		elseif self.mrGbMS.Ranges2[i].reverseOnly and not self.mrGbMS.ReverseActive then
		else
			j = i
		end
	end
	
	return j
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetRange
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetRange( old, new, noEventSend )
		
	local timeToShift = self.mrGbMS.GearTimeToShiftHl
	
	self.mrGbMS.CurrentRange = new
	self.mrGbMS.NewRange     = new

	if self.mrGbMS.Ranges[new] ~= nil then
		local n = self.mrGbMS.Ranges[new]
		if n.forwardOnly then
			self.mrGbMS.ReverseActive = false
		end
		if n.reverseOnly then
			self.mrGbMS.ReverseActive = true
		end
		
		self.mrGbMS.CurrentGear   = gearboxMogli.adjustGearToEntry( self, n )
		self.mrGbMS.CurrentRange2 = gearboxMogli.adjustRange2ToEntry( self, n )
	end
	
	--timer to shift the "range"
	if self.isServer then
		gearboxMogli.mrGbMPrepareGearShift( self, timeToShift, self.mrGbMS.ClutchAfterShiftHl, self.mrGbMS.Range1DoubleClutch, self.mrGbMS.GearShiftEffectHl, self.mrGbMS.ShiftNoThrottleHl ) 
	end 
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetRange2
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetRange2( old, new, noEventSend )
		
	local timeToShift = self.mrGbMS.GearTimeToShiftRanges2
	
	self.mrGbMS.CurrentRange2 = new
	self.mrGbMS.NewRange2     = new

	if self.mrGbMS.Ranges2[new] ~= nil then
		local n = self.mrGbMS.Ranges2[new]
		if n.forwardOnly then
			self.mrGbMS.ReverseActive = false
		end
		if n.reverseOnly then
			self.mrGbMS.ReverseActive = true
		end
		
		self.mrGbMS.CurrentGear   = gearboxMogli.adjustGearToEntry( self, n )
		self.mrGbMS.CurrentRange  = gearboxMogli.adjustRangeToEntry( self, n )
	end
	
	--timer to shift the "range 2"
	if self.isServer then	
		gearboxMogli.mrGbMPrepareGearShift( self, timeToShift, self.mrGbMS.ClutchAfterShiftRanges2, self.mrGbMS.Range2DoubleClutch, self.mrGbMS.GearShiftEffectRanges2, self.mrGbMS.ShiftNoThrottleRanges2 ) 		
	end 
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetGear( old, new, noEventSend )

	local timeToShift = self.mrGbMS.GearTimeToShiftGear
		
	self.mrGbMS.CurrentGear = new
	self.mrGbMS.NewGear     = new
	
	if self.mrGbMS.Gears[new] ~= nil then
		local n = self.mrGbMS.Gears[new]
		if n.forwardOnly then
			self.mrGbMS.ReverseActive = false
		end
		if n.reverseOnly then
			self.mrGbMS.ReverseActive = true
		end
		
		self.mrGbMS.CurrentRange  = gearboxMogli.adjustRangeToEntry( self, n )
		self.mrGbMS.CurrentRange2 = gearboxMogli.adjustRange2ToEntry( self, n )
	end
	
	if self.isServer then			
		--timer to set the gear
		gearboxMogli.mrGbMPrepareGearShift( self, timeToShift, self.mrGbMS.ClutchAfterShiftGear, self.mrGbMS.GearsDoubleClutch, self.mrGbMS.GearShiftEffectGear, self.mrGbMS.ShiftNoThrottleGear ) 	 	
	end
end

--**********************************************************************************************************	
-- gearboxMogli:checkGearShiftDC
--**********************************************************************************************************	
function gearboxMogli:checkGearShiftDC( new, what, noEventSend )

	local g1 = self.mrGbMS.CurrentGear
	local g2 = self.mrGbMS.CurrentRange 
	local g3 = self.mrGbMS.CurrentRange2 
	local gr = self.mrGbMS.ReverseActive
	local dc = false
	
	if     what == "G"    then
		g1 = new
		dc = self.mrGbMS.GearsDoubleClutch
	elseif what == "1"  then 
		g2 = new
		dc = self.mrGbMS.Range1DoubleClutch
	elseif what == "2"  then 
		g3 = new
		dc = self.mrGbMS.Range2DoubleClutch
	elseif what == "R" then 
		gr = new
		dc = self.mrGbMS.ReverseDoubleClutch
	else
		return true
	end

	if      gearboxMogli.mrGbMCheckDoubleClutch( self, dc, noEventSend )
			and self.motor.transmissionInputRpm ~= nil then				
		
		local s  = self.mrGbMS.Gears[g1].speed 
	           * self.mrGbMS.Ranges[g2].ratio 
						 * self.mrGbMS.Ranges2[g3].ratio
						 * self.mrGbMS.GlobalRatioFactor
		if gr then	
			s = self.mrGbMS.ReverseRatio * s
		end
		
		local r1 = gearboxMogli.gearSpeedToRatio( self, self.mrGbMS.CurrentGearSpeed )
		local r2 = gearboxMogli.gearSpeedToRatio( self, s )
		local w  = self.motor.clutchRpm * r2 / r1
		
		local v = 0			
		if self.motor.transmissionInputRpm < w then
			v = ( w - self.motor.transmissionInputRpm ) / self.mrGbMG.grindingMinRpmDelta
		else
			v = ( self.motor.transmissionInputRpm - w ) / self.mrGbMG.grindingMaxRpmSound
			if v > 1 and self.motor.transmissionInputRpm - w < self.mrGbMG.grindingMaxRpmDelta then
				v = 0.999
			end
		end
		
		-- grinding sound if v > 0.5, no shift if v > 1
		v = math.max( v + v - 1, 0 )
		
		if self.mrGbMG.debugPrint then
			print(string.format("DC: %3.0fkm/h (%3.0f) %3.0fkm/h (%3.0f) => in %4.0f U/min / out %4.0f U/min => %1.2f", self.mrGbMS.CurrentGearSpeed, r1, s, r2, self.motor.transmissionInputRpm, w, v ))
		end
			
		if     v > 1 then
			self:mrGbMSetNeutralActive( true, noEventSend )
			self:mrGbMSetState( "WarningText", string.format( "Cannot shift gear: rpm in: %4.0f / out: %4.0f", self.motor.transmissionInputRpm, w ))
			self.mrGbMS.GrindingGearsVol = 0
			self:mrGbMSetState( "GrindingGearsVol", 1 )
			return false
		elseif v > 0 and v > self.mrGbMS.GrindingGearsVol then
			self:mrGbMSetState( "InfoText", string.format( "Cannot shift gear: rpm in: %4.0f / out: %4.0f", self.motor.transmissionInputRpm, w ))
			self:mrGbMSetState( "GrindingGearsVol", v )
		elseif self.mrGbMS.GrindingGearsVol > 0 then
			self:mrGbMSetState( "GrindingGearsVol", 0 )
		end
	end
	
	return true
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNewGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNewGear( old, new, noEventSend )
	if self.isServer then		
		self:mrGbMSetCurrentGear( new, noEventSend, true )
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNewRange
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNewRange( old, new, noEventSend )
	if self.isServer then		
		self:mrGbMSetCurrentRange( new, noEventSend, true )
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNewRange2
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNewRange2( old, new, noEventSend )
	if self.isServer then		
		self:mrGbMSetCurrentRange2( new, noEventSend )
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetNewRange2
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetNewReverse( old, new, noEventSend )
	if self.isServer then		
		self:mrGbMSetReverseActive( new, noEventSend )
	end
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetIsOn
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetIsOn( old, new, noEventSend )

	self.mrGbMS.IsOn = new

	if new then				
		self:mrGbMSetState( "CurrentGear", self.mrGbMS.DefaultGear, noEventSend ) 
		self:mrGbMSetState( "CurrentRange", self.mrGbMS.DefaultRange, noEventSend ) 
		self:mrGbMSetState( "CurrentRange2", self.mrGbMS.DefaultRange2, noEventSend ) 
		
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
			gearboxMogliMotor.copyRuntimeValues( self.mrGbMB.motor, self.mrGbML.motor )
			self.motor = self.mrGbML.motor
		end
		self:mrGbMDoGearShift() 
		
		self.cruiseControl.maxSpeed   = self.mrGbMS.MaxGearSpeed * math.max( 1, ( self.mrGbMS.CurMaxRpm - gearboxMogli.rpmPlus ) / self.mrGbMS.RatedRpm ) * 3.6
		if self.mrGbMS.Hydrostatic then
			self.cruiseControl.maxSpeed = self.cruiseControl.maxSpeed * self.mrGbMS.HydrostaticMax
		end
		if self.mrGbMS.MaxSpeedLimiter and self.motor.maxForwardSpeed ~= nil and self.cruiseControl.maxSpeed > self.motor.maxForwardSpeed * 3.6 then
			self.cruiseControl.maxSpeed = self.motor.maxForwardSpeed * 3.6
		end	
		self.cruiseControl.speed = math.min( self.cruiseControl.speed, self.cruiseControl.maxSpeed )
	
	elseif old and self.mrGbML.motor ~= nil then
		if self.isServer then
			self:mrGbMSetState( "DefaultGear", self.mrGbMS.CurrentGear, noEventSend ) 
			self:mrGbMSetState( "DefaultRange", self.mrGbMS.CurrentRange, noEventSend ) 
			self:mrGbMSetState( "DefaultRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
		end
		self.mrGbML.gearShiftingNeeded = 0 	
		if self.mrGbMB.motor ~= nil then
			gearboxMogliMotor.copyRuntimeValues( self.mrGbML.motor, self.mrGbMB.motor )
			self.motor = self.mrGbMB.motor
		end
		
		if self.mrGbMB.cruiseControlMaxSpeed ~= nil then
			self.cruiseControl.maxSpeed = self.mrGbMB.cruiseControlMaxSpeed 
		end
		self.cruiseControl.speed = math.min( self.cruiseControl.speed, self.cruiseControl.maxSpeed )
		
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
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetWarningText
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetWarningText( old, new, noEventSend )
	self.mrGbMS.WarningText  = new
  self.mrGbML.warningTimer = g_currentMission.time + 2000
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetInfoText
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetInfoText( old, new, noEventSend )
	self.mrGbMS.InfoText  = new
  self.mrGbML.infoTimer = g_currentMission.time + 2000
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetManualClutch
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetManualClutch( old, new, noEventSend )
	self.mrGbMS.ManualClutch     = new
  self.mrGbML.manualClutchTime = g_currentMission.time
end

--**********************************************************************************************************	
-- gearboxMogli:newUpdateWheelsPhysics
--**********************************************************************************************************	
function gearboxMogli:newUpdateWheelsPhysics( superFunc, dt, currentSpeed, acc, doHandbrake, requiredDriveMode, ... )
	if self.mrGbMS == nil or not ( self.mrGbMS.IsOn ) or self.motor ~= self.mrGbML.motor then		
		return superFunc( self, dt, currentSpeed, acc, doHandbrake, requiredDriveMode, ... )
	end
	if self.motor.updateMotorRpm == nil or self.motor.updateMotorRpm ~= gearboxMogliMotor.updateMotorRpm then
		return superFunc( self, dt, currentSpeed, acc, doHandbrake, requiredDriveMode, ... )
	end
	
--if self.steeringEnabled and self.isReverseDriving  then
--	acc = -acc
--end
	
	-- self.doHandbrake is set to false if a dialog is shown
	if self.isMotorStarted and self.steeringEnabled and self.isControlled then
		doHandbrake = false
	end
	
	local acceleration        = acc
	local accelerationPedal   = 0
	local brakePedal          = 0
	local brakeLights         = false
	
	local oldHts              = self.lastSpeedReal*1000
	if self.mrGbML.hydroTargetSpeed ~= nil then
		oldHts = math.min( oldHts, self.mrGbML.hydroTargetSpeed )
		self.mrGbML.hydroTargetSpeed = nil
	end

	if self.steeringEnabled then
	-- driveControl and GPS
		if      self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE
				or  self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_FULL   then
			acceleration = 1
		elseif  self.cruiseControl.state <= 0 
				and g_currentMission.driveControl            ~= nil
				and g_currentMission.driveControl.useModules ~= nil
				and g_currentMission.driveControl.useModules.handBrake
				and self.driveControl.handBrake              ~= nil 
				and self.driveControl.handBrake.isActive then
			doHandbrake  = true
			acceleration = -self.axisForward 
		elseif  self.mrGbMS.Hydrostatic 
				and self.mrGbMS.ConstantRpm then
			local m = self.motor.maxForwardSpeed
			if self.mrGbMS.ReverseActive then
				m = self.motor.maxBackwardSpeed 
			end
			if not self:mrGbMGetAutomatic() then
				m = math.min( m, self.mrGbMS.CurrentGearSpeed * self.mrGbMS.HydrostaticMax )
			end
			 
			local decHts = Utils.clamp( ( 1.4142 * math.min( 0, acceleration ) )^2, self.mrGbMG.HydroSpeedIdleRedux, 1 )			
			local newHts = math.min( math.max( acceleration * m, oldHts - decHts * 0.001 * dt * self.mrGbMS.DecelerateToLimit ), oldHts + 0.001 * dt * self.mrGbMS.AccelerateToLimit )

			if acceleration < 0 then
				if self.axisForwardIsAnalog then
					self.mrGbML.hydroTargetTimer = nil
					if acceleration > -0.7071 then
						acceleration = 0
					end
				else
					if self.mrGbML.hydroTargetTimer == nil then
						self.mrGbML.hydroTargetTimer = g_currentMission.time + 1000
					end
					if g_currentMission.time < self.mrGbML.hydroTargetTimer then
						acceleration = 0
					end
				end
			elseif self.mrGbML.hydroTargetTimer ~= nil then
				self.mrGbML.hydroTargetTimer = nil
			end
			
			self.mrGbML.hydroTargetSpeed = Utils.clamp( newHts, 0, m )
		end		
		
		if acceleration < -0.001 then
			brakeLights = true
		end
	elseif doHandbrake  then
		self.motor.speedLimitS = 0
		self:mrGbMSetNeutralActive( true )
		acceleration = -1
	elseif self.movingDirection*currentSpeed*acc < -0.0003 then
		acceleration = -( 1 - ( 1 - math.abs( acc ) )^2 )
		self:mrGbMSetNeutralActive( true )
	elseif math.abs( acc ) > 0.001 then
		acceleration = ( 1 - ( 1 - math.abs( acc ) )^2 )
		self:mrGbMSetReverseActive( acc < 0 )
		self:mrGbMSetNeutralActive( false )
	else
		acceleration = 0
		self.motor.speedLimitS = 0
		self:mrGbMSetNeutralActive( true )
	end
	
	-- blow off ventil
	if      not ( self.motor.noTorque )
			and acceleration                   > 0.5 
			and ( self:mrGbMGetCurrentRPM()    > self.mrGbMS.IdleRpm + self.mrGbMG.blowOffVentilRpmRatio * ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) 
				 or g_currentMission.time        < self.mrGbML.blowOffVentilTime1 )
			and g_currentMission.time          > self.mrGbML.blowOffVentilTime0 then
		self.mrGbML.blowOffVentilTime1 = g_currentMission.time + gearboxMogli.blowOffVentilTime1
		self.mrGbML.blowOffVentilTime2 = -1
	end			

	--if self.mrGbMS.PlayBOVRpm > 0 and self:mrGbMGetCurrentRPM() < self.mrGbMS.PlayBOVRpm and self.mrGbMS.PlayBOV2 and self.mrGbMS.BlowOffVentilVolume > 0 then
	if      ( self.motor.noTorque or acceleration < 0.001 )
			and g_currentMission.time         < self.mrGbML.blowOffVentilTime1 then
		if     self.mrGbML.blowOffVentilTime2 < 0 then
			self.mrGbML.blowOffVentilTime2 = g_currentMission.time + gearboxMogli.blowOffVentilTime2
		elseif g_currentMission.time > self.mrGbML.blowOffVentilTime2 then
			self.mrGbML.blowOffVentilTime1 = 0
			self.mrGbML.blowOffVentilTime2 = -1
			self.mrGbML.blowOffVentilTime0 = g_currentMission.time + gearboxMogli.blowOffVentilTime0
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
		
	--*******************
	-- cruise control 
	--*******************
	self.motor:updateMotorRpm( dt )
	
	if     not ( self.mrGbMS.SpeedLimiter or self.cruiseControl.state > 0 ) 
			or not self.steeringEnabled
			or self.mrGbMS.CruiseControlBrake
			or self.mrGbMS.AllAuto
			or gearboxMogli.speedLimitMode == "M" then
		self.motor.limitMaxRpm = true
	elseif gearboxMogli.speedLimitMode == "T" then
		self.motor.limitMaxRpm = false
	elseif math.abs( currentSpeed ) * 3600 <= self.cruiseControl.speed then
		self.motor.limitMaxRpm = true
	elseif self.motor.usedTransTorque < gearboxMogli.eps then
		self.motor.limitMaxRpm = false
	end

	if not self.motor.limitMaxRpm then
		if currentSpeed * 3600 >= self.cruiseControl.speed + gearboxMogli.extraSpeedLimit then
			acceleration = 0
		end
	end
	
	self.motor:updateSpeedLimit( dt )
	
	if      self.tempomatMogliV17 ~= nil 
			and self.tempomatMogliV17.keepSpeedLimit ~= nil 
			and math.abs( currentSpeed ) * 3600 > self.tempomatMogliV17.keepSpeedLimit + 1 then
		brakeLights = true
	end
	
	if     doHandbrake or self.mrGbMS.AutoHold or not ( self.isMotorStarted ) or g_currentMission.time < self.motorStartTime then
		-- hand brake
		if math.abs(self.rotatedTime) < 0.01 or self.articulatedAxis == nil then
			brakePedal = 1
		end
	elseif acceleration < 0 then
		-- braking 
		brakePedal   = -acceleration
	elseif self.mrGbMS.ReverseActive then
		-- reverse 
		accelerationPedal = -acceleration
	else                
		-- forward        
		accelerationPedal =  acceleration
	end
	
	
	if      ( self:mrGbMGetAutoHold() or ( self:mrGbMGetAutoClutch() and acceleration > 0.001 ) )
			and ( ( self.movingDirection * currentSpeed >  2.7777777778e-4 and self.mrGbMS.ReverseActive )
				 or ( self.movingDirection * currentSpeed < -2.7777777778e-4 and not ( self.mrGbMS.ReverseActive ) ) ) then
		-- wrong direction                              
		brakePedal  = 1
		brakeLights = true
	end
	
	if      self:mrGbMGetAutoHold()
			and g_currentMission.time > self.mrGbML.DirectionChangeTime + 2000
			and math.abs( currentSpeed ) < 5.5555555556e-5
			and not self.motor.noTransmission
			and ( ( self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch ) or self.mrGbMS.ManualClutch > 0.9 )
			and acceleration < 0.1 then
		-- auto hold
		brakePedal  = 1
	end
		
	self.setBrakeLightsVisibility(self, brakeLights)
	if not ( self.isReverseDriving ) then
		self.setReverseLightsVisibility(self, self.mrGbMS.ReverseActive)
	end
	
	gearboxMogliMotor.mrGbMUpdateGear( self.motor, acceleration )	
	
	local absAccelerationPedal = math.abs(accelerationPedal)
	local wheelDriveTorque = 0
	 
	self.mrGbML.lastAcceleration  = acceleration
	self.mrGbML.lastBrakePedal    = brakePedal 

	
	if next(self.differentials) ~= nil and self.motorizedNode ~= nil then
		local torque,_,brakeForce = self.motor:getTorque(accelerationPedal, false) 
		local maxRpm      = self.motor:getCurMaxRpm()
		local ratio       = self.motor:getGearRatio()		
		local maxRotSpeed = maxRpm * gearboxMogli.factorpi30
		local c           = 0
		
		brakePedal = math.max( brakePedal, brakeForce )
						
		if     self.motor.clutchPercent < gearboxMogli.minClutchPercent + gearboxMogli.minClutchPercent then
			c = 0
		else
			local cp = self.motor.clutchPercent
			if self.mrGbMS.TorqueConverter then
				cp = self.mrGbMS.ManualClutch
			end

			c = self.mrGbMG.clutchFactor * self.motor.maxMotorTorque * ( ( 0.5 * ( 1 - math.cos( math.pi * cp )) ) ^ self.mrGbMG.clutchExp )
		end
		
		setVehicleProps(self.motorizedNode, torque, maxRotSpeed, ratio, c, self.motor:getRotInertia(), self.motor:getDampingRate());
		
	--if self.mrGbML.debugTimer ~= nil and g_currentMission.time < self.mrGbML.debugTimer and not ( self.mrGbMS.Hydrostatic ) then
		if      gearboxMogli.debugGearShift
				and ( self.mrGbMS.Hydrostatic 
					 or ( self.mrGbML.debugTimer ~= nil 
						and g_currentMission.time < self.mrGbML.debugTimer ) ) then
		  if not ( gearboxMogli.debugGearShiftHeader ) then
				gearboxMogli.debugGearShiftHeader = true
				print("AccPed: slAcc,  limit, torque,  brake,   nc.mot.RPM, motor RPM,  wheel RPM,  max RPM,     rot speed,  speed, ratio 1, ratio 2, factor, clutch, shift")
			end
			print(string.format("%6.2f%%: %4.0f Nm, %4.0f Nm, %4.0f Nm, %4.0f U/min, %4.0f U/min, %4.0f U/min, %4.0f U/min, %4.0f U/min, %4.2f %4.2f km/h, %3.1f, %3.1f, %4.0f, %3.0f%%, %d ",
													accelerationPedal*100,
													brakePedal*1000,
													torque*1000, 
													self.motor.lastMotorTorque*1000,
													self.motor.nonClampedMotorRpm,
													self.motor.lastRealMotorRpm,
													self.motor.clutchRpm,
													self.motor.maxPossibleRpm,
													maxRpm, 
													maxRotSpeed,
													self.lastSpeedReal * self.movingDirection * 3600,
													ratio,
													gearboxMogliMotor.getMogliGearRatio( self.motor ),
													c*1000,
													self.motor.clutchPercent * 100,
													self.mrGbML.gearShiftingNeeded)..tostring(self.motor.noTorque))
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

	return 
end

--**********************************************************************************************************	
-- gearboxMogli:gearSpeedToRatio
--**********************************************************************************************************	
function gearboxMogli:gearSpeedToRatio( gearSpeed )
	if gearSpeed > gearboxMogli.eps then 
		return math.min( self.mrGbMS.RatedRpm / ( gearSpeed * gearboxMogli.factor30pi ), gearboxMogli.huge )
	else
		return gearboxMogli.huge 
	end
end


--**********************************************************************************************************	
-- gearboxMogliMotor
--**********************************************************************************************************	

gearboxMogliMotor = {}
gearboxMogliMotor_mt = Class(gearboxMogliMotor)

setmetatable( gearboxMogliMotor, { __index = function (table, key) return VehicleMotor[key] end } )

--**********************************************************************************************************	
-- gearboxMogliMotor:new
--**********************************************************************************************************	
function gearboxMogliMotor:new( vehicle, motor )

	local interpolFunction = linearInterpolator1
	local interpolDegree   = 2
	
	local self = {}

	setmetatable(self, gearboxMogliMotor_mt)

	self.vehicle          = vehicle
	self.original         = motor 	
	self.torqueCurve      = AnimCurve:new( interpolFunction, interpolDegree )
	
	if gearboxMogli.powerFuelCurve == nil then
		gearboxMogli.powerFuelCurve = AnimCurve:new( interpolFunction, interpolDegree )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.010, time=0.0} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.125, time=0.02} )
		gearboxMogli.powerFuelCurve:addKeyframe( {v=0.240, time=0.06} )
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
		for _,k in pairs(vehicle.mrGbMS.Engine.torqueValues) do
			self.torqueCurve:addKeyframe( k )	
		end
		
		if vehicle.mrGbMS.Engine.ecoTorqueValues ~= nil then
			self.ecoTorqueCurve = AnimCurve:new( interpolFunction, interpolDegree )
			for _,k in pairs(vehicle.mrGbMS.Engine.ecoTorqueValues) do
				self.ecoTorqueCurve:addKeyframe( k )	
			end
		end
	
		self.maxTorqueRpm   = vehicle.mrGbMS.Engine.maxTorqueRpm
		self.maxMotorTorque = vehicle.mrGbMS.Engine.maxTorque
	else
		local idleTorque    = motor.torqueCurve:get(vehicle.mrGbMS.OrigMinRpm) --/ self.vehicle.mrGbMS.TransmissionEfficiency
		self.torqueCurve:addKeyframe( {v=0.1*idleTorque, time=0} )
		self.torqueCurve:addKeyframe( {v=0.9*idleTorque, time=vehicle.mrGbMS.CurMinRpm} )
		local vMax  = 0
		local tMax  = vehicle.mrGbMS.OrigMaxRpm
		local tvMax = 0
		local vvMax = 0
		for _,k in pairs(motor.torqueCurve.keyframes) do
			if k.time > vehicle.mrGbMS.CurMinRpm then 
				local kv = k.v --/ self.vehicle.mrGbMS.TransmissionEfficiency
				local kt = math.min( k.time, vehicle.mrGbMS.CurMaxRpm - 1 )
				
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
			local r = Utils.clamp( vehicle.mrGbMS.CurMaxRpm - tMax, 1, gearboxMogli.rpmRatedMinus )
			self.torqueCurve:addKeyframe( {v=0.9*vMax, time=tMax + 0.25*r} )
			self.torqueCurve:addKeyframe( {v=0.5*vMax, time=tMax + 0.50*r} )
			self.torqueCurve:addKeyframe( {v=0.1*vMax, time=tMax + 0.75*r} )
			self.torqueCurve:addKeyframe( {v=0, time=tMax + r} )
			tMax = tMax + r
		end
		
		self.maxTorqueRpm   = tvMax	
		self.maxMotorTorque = self.torqueCurve:getMaximum()
	end

	self.fuelCurve = AnimCurve:new( interpolFunction, interpolDegree )
	if vehicle.mrGbMS.Engine.fuelUsageValues == nil then		
		self.fuelCurve:addKeyframe( { v = 0.96 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.CurMinRpm } )
		self.fuelCurve:addKeyframe( { v = 0.94 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.IdleRpm } )
		self.fuelCurve:addKeyframe( { v = 0.91 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.8*self.vehicle.mrGbMS.IdleRpm+0.2*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 0.90 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.6*self.vehicle.mrGbMS.IdleRpm+0.4*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 0.92 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.3*self.vehicle.mrGbMS.IdleRpm+0.7*self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 1.00 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.RatedRpm } )		
		self.fuelCurve:addKeyframe( { v = 1.25 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = 0.5*self.vehicle.mrGbMS.RatedRpm+0.5*self.vehicle.mrGbMS.CurMaxRpm } )		
		self.fuelCurve:addKeyframe( { v = 2.00 * vehicle.mrGbMS.GlobalFuelUsageRatio, time = self.vehicle.mrGbMS.CurMaxRpm } )		
	else
		for _,k in pairs(vehicle.mrGbMS.Engine.fuelUsageValues) do
			self.fuelCurve:addKeyframe( k )	
		end
	end
	
--local minTargetRpm = math.max( vehicle.mrGbMS.MinTargetRpm, self.vehicle.mrGbMS.IdleRpm+1 )
	local minTargetRpm = self.vehicle.mrGbMS.IdleRpm+1
	
	self.rpmPowerCurve  = AnimCurve:new( interpolFunction, interpolDegree )	
	self.maxPower       = minTargetRpm * self.torqueCurve:get( minTargetRpm ) 		
	self.maxPowerRpm    = self.vehicle.mrGbMS.RatedRpm 
	self.maxMaxPowerRpm = self.vehicle.mrGbMS.RatedRpm
	self.rpmPowerCurve:addKeyframe( {v=minTargetRpm-1, time=0} )				
	self.rpmPowerCurve:addKeyframe( {v=minTargetRpm,   time=gearboxMogli.powerCurveFactor*self.maxPower} )		

	local lastP = self.maxPower 
	local lastR = self.maxPowerRpm

	for _,k in pairs(self.torqueCurve.keyframes) do			
		local p = k.v*k.time
		if     p      >  self.maxPower then
			self.maxPower       = p
			self.maxPowerRpm    = k.time
			self.maxMaxPowerRpm = k.time
			self.rpmPowerCurve:addKeyframe( {v=k.time, time=gearboxMogli.powerCurveFactor*self.maxPower} )		
		elseif  p     >= gearboxMogli.maxPowerLimit * self.maxPower then
			self.maxMaxPowerRpm = k.time
		elseif  lastP >= gearboxMogli.maxPowerLimit * self.maxPower 
		    and lastP >  p + gearboxMogli.eps then
			self.maxMaxPowerRpm = lastR + ( k.time - lastR ) * ( lastP - gearboxMogli.maxPowerLimit * self.maxPower ) / ( lastP - p )
		end
		lastP = p
		lastR = k.time
	end
	if gearboxMogli.powerCurveFactor < 1 then
		local f = 0.5 * ( 1 + gearboxMogli.powerCurveFactor )
		self.rpmPowerCurve:addKeyframe( {v=self.maxMaxPowerRpm, time=f*self.maxPower} )			
		self.rpmPowerCurve:addKeyframe( {v=self.maxPowerRpm,    time=self.maxPower} )			
	end
	
	if self.ecoTorqueCurve ~= nil then
		self.maxEcoPower   = minTargetRpm * self.ecoTorqueCurve:get( minTargetRpm ) 		
		self.ecoPowerCurve = AnimCurve:new( interpolFunction, interpolDegree )
		self.ecoPowerCurve:addKeyframe( {v=minTargetRpm-1, time=0} )				
		self.ecoPowerCurve:addKeyframe( {v=minTargetRpm,   time=gearboxMogli.powerCurveFactor*self.maxEcoPower} )		
		for _,k in pairs(self.ecoTorqueCurve.keyframes) do			
			local p = k.v*k.time
			if self.maxEcoPower < p then
				self.maxEcoPower  = p
				self.ecoPowerCurve:addKeyframe( {v=k.time, time=gearboxMogli.powerCurveFactor*self.maxEcoPower} )		
			end
		end
		if gearboxMogli.powerCurveFactor < 1 then
			local f = 0.5 * ( 1 + gearboxMogli.powerCurveFactor )
			self.ecoPowerCurve:addKeyframe( {v=self.maxMaxPowerRpm, time=f*self.maxEcoPower} )		
			self.ecoPowerCurve:addKeyframe( {v=self.maxPowerRpm,    time=self.maxEcoPower} )		
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
	
	self.minRpm                  = vehicle.mrGbMS.OrigMinRpm
	self.maxRpm                  = vehicle.mrGbMS.OrigMaxRpm	
	self.minRequiredRpm          = self.vehicle.mrGbMS.IdleRpm
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
	self.usedTransTorque         = 0
	self.noTransTorque           = 0
	self.motorLoadP              = 0
	self.targetRpm               = self.vehicle.mrGbMS.IdleRpm
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
	self.lowBrakeForceScale      = motor.lowBrakeForceScale
	self.lowBrakeForceSpeedLimit = 0.01 -- motor.lowBrakeForceSpeedLimit
		
	self.maxPossibleRpm          = self.vehicle.mrGbMS.RatedRpm
	self.wheelSpeedRpm           = 0
	self.noTransmission          = true
	self.noTorque                = true
	self.ptoOn                   = false
	self.clutchPercent           = 0
	self.minThrottle             = 0.3
	self.minThrottleS            = 0.3
	self.lastMotorRpm            = motor.lastMotorRpm
	self.lastRealMotorRpm        = motor.lastRealMotorRpm
	self.prevMotorRpm            = motor.lastMotorRpm
	self.prevNonClampedMotorRpm  = motor.nonClampedMotorRpm
	self.nonClampedMotorRpmS     = motor.nonClampedMotorRpm
	self.deltaRpm                = 0
	self.transmissionInputRpm    = 0
	self.motorLoad               = 0
	self.usedMotorTorque         = 0
	self.lastMotorTorque         = 0
	self.lastTransTorque         = 0
	self.neededPtoTorque         = 0
	self.lastPtoTorque           = 0
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
	self.rpmIncFactor            = self.vehicle.mrGbMS.RpmIncFactor	
	self.lastBrakeForce          = 0
	
	self.interalResistence       = 0.3 * self.torqueCurve:get( self.vehicle.mrGbMS.RatedRpm ) / self.vehicle.mrGbMS.RatedRpm
	
	self:chooseTorqueCurve( true )

	self.ratioFactorG = 1
	self.ratioFactorR = nil
	
	return self
end

--**********************************************************************************************************	
-- gearboxMogliMotor.chooseTorqueCurve
--**********************************************************************************************************	
function gearboxMogliMotor:chooseTorqueCurve( eco )
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
end

--**********************************************************************************************************	
-- gearboxMogliMotor.copyRuntimeValues
--**********************************************************************************************************	
function gearboxMogliMotor.copyRuntimeValues( motorFrom, motorTo )

	motorTo.nonClampedMotorRpm      = Utils.getNoNil( motorFrom.nonClampedMotorRpm, 0 )
	motorTo.clutchRpm               = Utils.getNoNil( motorFrom.clutchRpm        , motorTo.nonClampedMotorRpm )   
	motorTo.lastMotorRpm            = Utils.getNoNil( motorFrom.lastMotorRpm     , motorTo.nonClampedMotorRpm )  
	motorTo.lastRealMotorRpm        = Utils.getNoNil( motorFrom.lastRealMotorRpm , motorTo.nonClampedMotorRpm )      
	motorTo.equalizedMotorRpm       = Utils.getNoNil( motorFrom.equalizedMotorRpm, motorTo.nonClampedMotorRpm )
	motorTo.lastPtoRpm              = motorFrom.lastPtoRpm
	motorTo.gear                    = motorFrom.gear               
	motorTo.gearRatio               = motorFrom.gearRatio          
	motorTo.rpmLimit                = motorFrom.rpmLimit 
	motorTo.speedLimit              = motorFrom.speedLimit
	motorTo.minSpeed                = motorFrom.minSpeed

	motorTo.rotInertia              = motorFrom.rotInertia 
	motorTo.dampingRate             = motorFrom.dampingRate

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
function gearboxMogliMotor:getLimitedGearRatio( r, withSign )
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
		print("FS17_GearboxAddon: Error! gearRatio is too small: "..tostring(r))
		gearboxMogli.printCallStack( self.vehicle )
		if withSign and r < 0 then
			return -gearboxMogli.minGearRatio
		else
			return  gearboxMogli.minGearRatio
		end
	end
	
	if a > gearboxMogli.maxGearRatio then
		print("FS17_GearboxAddon: Error! gearRatio is too big: "..tostring(r))
		gearboxMogli.printCallStack( self.vehicle )
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
function gearboxMogliMotor:getGearRatio()
	return self:getLimitedGearRatio( self.gearRatio, true )
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
function gearboxMogliMotor:updateSpeedLimit( dt )
	self.currentSpeedLimit = math.huge
	
	local speedLimit = self.vehicle:getSpeedLimit(true)
	
	if not ( self.vehicle.steeringEnabled ) then
		speedLimit = math.min( speedLimit, self.speedLimit )
	end
	
	if      self.vehicle.tempomatMogliV17 ~= nil 
			and self.vehicle.tempomatMogliV17.keepSpeedLimit ~= nil then
		speedLimit = math.min( speedLimit, self.vehicle.tempomatMogliV17.keepSpeedLimit )
	end
	
	speedLimit = speedLimit * gearboxMogli.kmhTOms

	if     self.vehicle.mrGbMS.SpeedLimiter 
			or self.vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE  
			or self.vehicle.mrGbML.hydroTargetSpeed ~= nil then

		local cruiseSpeed = speedLimit
		if self.vehicle.mrGbMS.SpeedLimiter or self.vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE then
			cruiseSpeed = math.min( cruiseSpeed, self.vehicle.cruiseControl.speed * gearboxMogli.kmhTOms )
		end
		
		if self.vehicle.mrGbML.hydroTargetSpeed ~= nil then
			cruiseSpeed = math.min( cruiseSpeed, self.vehicle.mrGbML.hydroTargetSpeed ) 
		end
		
		if dt == nil then
			dt = self.tickDt
		end
		
		if self.speedLimitS == nil then 
			self.speedLimitS = math.abs( self.vehicle.lastSpeedReal*1000 )
		end
		-- limit speed limiter change to given km/h per second
		local limitMax   =  0.001 * gearboxMogli.kmhTOms * self.vehicle.mrGbMS.AccelerateToLimit * dt
		local decToLimit = self.vehicle.mrGbMS.DecelerateToLimit
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
		self.speedLimitS = math.min( speedLimit, math.abs( self.vehicle.lastSpeedReal*1000 ) )
	end
	
	if self.vehicle.mrGbMS.MaxSpeedLimiter then
		local maxSpeed = self.maxForwardSpeed
		
		if self.vehicle.mrGbMS.ReverseActive then
			maxSpeed = self.maxBackwardSpeed
		end		
		
		if speedLimit > maxSpeed then
			speedLimit = maxSpeed
		end
	end
						
	self.currentSpeedLimit = speedLimit 
	
	return speedLimit + gearboxMogli.extraSpeedLimitMs
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getCurMaxRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getCurMaxRpm( forGetTorque )

	curMaxRpm = gearboxMogli.huge
						
	if self.ratioFactorR ~= nil then 		
		if forGetTorque or not ( self.vehicle.mrGbMS.Hydrostatic ) then
			curMaxRpm = self.maxPossibleRpm / self.ratioFactorR
		end
	
		local speedLimit   = gearboxMogli.huge
		
		if self.ptoSpeedLimit ~= nil then
			speedLimit = self.ptoSpeedLimit
		end
		
		if forGetTorque or self.limitMaxRpm then
			speedLimit = math.min( speedLimit, self:getSpeedLimit() )
		elseif self.ptoOn then
			speedLimit = math.min( speedLimit, self:getSpeedLimit() + gearboxMogli.speedLimitBrake )
		end
		
		if speedLimit < gearboxMogli.huge then
			speedLimit = speedLimit + gearboxMogli.extraSpeedLimitMs
			curMaxRpm  = Utils.clamp( speedLimit * gearboxMogli.factor30pi * self:getMogliGearRatio() * self.ratioFactorG, 1, curMaxRpm )
		end
		
		if self.rpmLimit ~= nil and self.rpmLimit < curMaxRpm then
			curMaxRpm  = self.rpmLimit
		end
		
		if curMaxRpm < self.vehicle.mrGbMS.CurMinRpm then
			curMaxRpm  = self.vehicle.mrGbMS.CurMinRpm 
		end
		
		speedLimit = self.vehicle:getSpeedLimit(true)
		if speedLimit < gearboxMogli.huge then
			speedLimit = speedLimit * gearboxMogli.kmhTOms
			speedLimit = speedLimit + gearboxMogli.extraSpeedLimitMs
			curMaxRpm  = Utils.clamp( speedLimit * gearboxMogli.factor30pi * self:getMogliGearRatio() * self.ratioFactorG, 1, curMaxRpm )
		end
	end
	
	if forGetTorque then
		if self.ratioFactorR ~= nil then
			curMaxRpm = curMaxRpm * self.ratioFactorR
		else
			curMaxRpm = self.maxPossibleRpm
		end
	else
		self.lastCurMaxRpm = curMaxRpm
	end
	
	return curMaxRpm
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getBestGear
--**********************************************************************************************************	
function gearboxMogliMotor:getBestGear( acceleration, wheelSpeedRpm, accSafeMotorRpm, requiredWheelTorque, requiredMotorRpm )

	local gearRatio = self:getMogliGearRatio() * self.ratioFactorG
	
	if self.vehicle.mrGbMS.ReverseActive then
		return -1, -gearRatio
	else
		return 1, gearRatio
	end
end

--**********************************************************************************************************	
-- gearboxMogliMotor:motorStall
--**********************************************************************************************************	
function gearboxMogliMotor:motorStall( warningText1, warningText2 )
	self.vehicle:mrGbMSetNeutralActive(true, false, true)
	if not ( g_currentMission.missionInfo.automaticMotorStartEnabled ) then
		self.vehicle:stopMotor()
	end
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getTorque
--**********************************************************************************************************	
function gearboxMogliMotor:getTorque( acceleration, limitRpm )

	self.lastTransTorque         = 0
	self.noTransTorque           = 0
	self.lastPtoTorque           = 0
	self.neededPtoTorque         = 0	
	self.lastMissingTorque       = 0
	
	local lastPtoTorque   = self.lastPtoTorque	
	local acc             = math.max( self.minThrottle, self.lastThrottle )
	local brakePedal      = 0
	local rpm             = self.lastRealMotorRpm
	local torque          = 0

	local pt = 0
	self.neededPtoTorque = PowerConsumer.getTotalConsumedPtoTorque(self.vehicle) 
	
--if self.vehicle.mrGbMS.EcoMode and self.neededPtoTorque > 0 then
--	self.neededPtoTorque = self.neededPtoTorque * self.vehicle.mrGbMS.PtoRpm / self.vehicle.mrGbMS.PtoRpmEco
--end

	if self.neededPtoTorque > 0 then
	  pt = self.neededPtoTorque / self.ptoMotorRpmRatio
	end

	local eco = false
	if      self.ecoTorqueCurve ~= nil
			and ( self.vehicle.mrGbMS.EcoMode
				 or not ( self.neededPtoTorque                   > 0
						-- or self.motorLoadS                        > 0.99
							 or ( self.vehicle.mrGbMS.IsCombine and self.vehicle:getIsTurnedOn() )
							 or math.abs( self.vehicle.lastSpeedReal ) > self.vehicle.mrGbMS.BoostMinSpeed ) ) then
		eco = true
	end
	self:chooseTorqueCurve( eco )
	
	if self.noTorque then
		torque = 0
	else
		torque = self.currentTorqueCurve:get( rpm ) 
	end
	
	self.lastMotorTorque	= torque
	
	if self.vehicle.mrGbMS.IsCombine then
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

		if rpm < self.vehicle.mrGbMS.ThreshingMaxRpm then
			local f      = Utils.clamp( 1 - self.vehicle.mrGbMS.ThreshingReductionFactor * ( 1 - rpm / self.vehicle.mrGbMS.ThreshingMaxRpm ), 0, 1 )
			combinePower = combinePower * f
		end
		
		pt = pt + ( combinePower / rpm )
	end
	
	if pt > 0 then
		if not ( self.noTransmission 
					or self.noTorque 
					or self.vehicle.mrGbMS.Hydrostatic
					or ( self.vehicle.mrGbMS.TorqueConverter and self.vehicle.mrGbMS.OpenRpm > self.maxPowerRpm - 1 ) ) then
			local mt = self.currentTorqueCurve:get( Utils.clamp( self.lastRealMotorRpm, self.vehicle.mrGbMS.IdleRpm, self.vehicle.mrGbMS.RatedRpm ) ) 
			if mt < pt then
			--print(string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ).." @RPM: "..tostring(self.lastRealMotorRpm))
				if self.ptoWarningTimer == nil then
					self.ptoWarningTimer = g_currentMission.time
				end
				if      g_currentMission.time > self.ptoWarningTimer + 10000 then
					self.ptoWarningTimer = nil
					
					gearboxMogliMotor.motorStall( self, string.format("Motor stopped due to missing power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ), 
																								string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ) )
				elseif  g_currentMission.time > self.ptoWarningTimer + 2000 then
					self.vehicle:mrGbMSetState( "WarningText", string.format("Not enough power for PTO: %4.0f Nm < %4.0fNm", mt*1000, pt*1000 ))
				end			
			elseif self.ptoWarningTimer ~= nil then
				self.ptoWarningTimer = nil
			end
		else
			self.ptoWarningTimer = nil
		end
		
		local maxPtoTorqueRatio = math.min( 1, self.vehicle.mrGbMS.MaxPtoTorqueRatio + math.abs( self.vehicle.lastSpeedReal*3600 ) * self.vehicle.mrGbMS.MaxPtoTorqueRatioInc )
		
		if     torque < 1e-4 then
			self.lastPtoTorque = 0
			self.ptoSpeedLimit = nil
		elseif self.noTransmission 
				or self.noTorque then
			self.lastPtoTorque = math.min( torque, pt )
			self.ptoSpeedLimit = nil
		elseif maxPtoTorqueRatio <= 0 then
			self.lastPtoTorque = 0
		elseif maxPtoTorqueRatio <  1 then
			local m = maxPtoTorqueRatio 
			if self.nonClampedMotorRpm > self.vehicle.mrGbMS.IdleRpm and math.abs( self.vehicle.lastSpeedReal ) > 2.78e-4 then
				m = math.max( m, 1 - self.usedTransTorque / torque )
			end
			self.lastPtoTorque = math.min( pt, m * torque )
		else
			self.lastPtoTorque = math.min( pt, torque )
		end
				
		if self.lastPtoTorque < pt then
			self.lastMissingTorque = self.lastMissingTorque + pt - self.lastPtoTorque
		end
		torque             = torque - self.lastPtoTorque
		
--print(string.format("%3d %4d %4d %4d",maxPtoTorqueRatio*100,torque*1000,pt*1000,self.lastPtoTorque*1000))		
	else
		if self.ptoWarningTimer ~= nil then
			self.ptoWarningTimer = nil
		end
		if self.ptoSpeedLimit   ~= nil then
			self.ptoSpeedLimit   = nil
		end
	end

-- limit RPM
	local limitA = self.vehicle.mrGbMS.CurMaxRpm
	local limitC = self.vehicle.mrGbMS.CurMaxRpm
	if      not self.noTransmission 
			and not self.noTorque
		--and not ( self.vehicle.mrGbMS.Hydrostatic )
			and self.vehicle.cruiseControl.state == 0
			and self.vehicle.steeringEnabled 
			and gearboxMogli.eps < acc and acc < self.vehicle.mrGbMS.MaxRpmThrottle then
			
		local noLimit = false
		local o = "reverseOnly"
		if self.vehicle.mrGbMS.ReverseActive then
			o = "forwardOnly"
		end
		
		for j=1,3 do
			local n, g, c, f
			
			if     j==1 then
				n = "speed"
        g = self.vehicle.mrGbMS.Gears
        c = self.vehicle.mrGbMS.CurrentGear
				f = self.vehicle.mrGbMGetAutoShiftGears
			elseif j==2 then
				n = "ratio"
			  g = self.vehicle.mrGbMS.Ranges
			  c = self.vehicle.mrGbMS.CurrentRange
				f = self.vehicle.mrGbMGetAutoShiftRange
			else
				n = "ratio"
			  g = self.vehicle.mrGbMS.Ranges2
			  c = self.vehicle.mrGbMS.CurrentRange2
				f = self.vehicle.mrGbMGetAutoShiftRange2
			end

			local r = g[c][n]

			if f( self.vehicle ) then
				for i=c+1,table.getn( g ) do
					if g[i][n] > r and not ( g[i][o] ) then
						noLimit = true
						break
					end
				end
			end
			
			if noLimit then
				break
			end
		end
		
		if not noLimit then
			limitA = math.min( limitA, self:getThrottleMaxRpm( acc / self.vehicle.mrGbMS.MaxRpmThrottle ) )
		end
	end
	
	if self.lastMaxPossibleRpm ~= nil then
		limitA = math.min( limitA, self.lastMaxPossibleRpm )
	end
	limitA   = math.max( self.minRequiredRpm, limitA )
	if not ( self.vehicle.mrGbMS.Hydrostatic ) then
		limitC = math.min( self:getCurMaxRpm( true ), limitA )
	end
	if     self.vehicle:mrGbMGetOnlyHandThrottle()
			or self.vehicle.mrGbMS.HandThrottle > 0.01 then
		limitA = self.minRequiredRpm
	end
	
-- motor brake force
	if self.noTransmission then
		self.lastBrakeForce = 0
		brakeForce          = 0
	else
		local t0 = self.lastMotorTorque
		local r0 = math.max( self.maxMaxPowerRpm, self.vehicle.mrGbMS.RatedRpm )
		if self.nonClampedMotorRpm > r0 then
			t0 = math.max( t0, self.torqueCurve:get( r0 ) )
		end
		if     self.nonClampedMotorRpm <= self.vehicle.mrGbMS.IdleRpm
				or self.vehicle.mrGbMS.BrakeForceRatio <= 0 then
			brakeForce = 0
		else
			if r0 > self.vehicle.mrGbMS.IdleRpm + gearboxMogli.eps then
				brakeForce = self.vehicle.mrGbMS.BrakeForceRatio * ( self.nonClampedMotorRpm - self.vehicle.mrGbMS.IdleRpm ) / ( r0 - self.vehicle.mrGbMS.IdleRpm )
			else
				brakeForce = self.vehicle.mrGbMS.BrakeForceRatio
			end
			
			if     self.noTorque 
					or acc                     <= 0
					or self.nonClampedMotorRpm >= limitC + gearboxMogli.brakeForceLimitRpm then
				brakeForce = brakeForce * t0
			else
				local a0 = acc
				if self.nonClampedMotorRpm > limitC + gearboxMogli.eps then
					a0 = math.min( a0, ( limitC + gearboxMogli.brakeForceLimitRpm - self.nonClampedMotorRpm ) / gearboxMogli.brakeForceLimitRpm )
				end

				if a0 <= 0 then
					brakeForce = brakeForce * t0
				elseif a0 >= 1 then
					brakeForce = 0
				else
					brakeForce = brakeForce * ( t0 - a0 * self.lastMotorTorque )
				end
			end
		end
		self.lastBrakeForce = self.lastBrakeForce + self.vehicle.mrGbML.smoothFast * ( brakeForce - self.lastBrakeForce )
		brakeForce          = self.lastBrakeForce
	end
	
	if self.noTorque or torque <= 0 or acc <= 0 then
		if torque < 0 then
			self.lastMissingTorque = self.lastMissingTorque - torque
		end
		torque = 0
	else
	--if     self.vehicle.mrGbMS.Hydrostatic  then
	--elseif self.nonClampedMotorRpm > limitA then
		if     self.nonClampedMotorRpm > limitA + gearboxMogli.ptoRpmThrottleDiff then
			self.lastMotorTorque = self.lastMotorTorque - torque 
			torque               = 0
		elseif not self.limitMaxRpm and self.nonClampedMotorRpm > limitC then
			self.lastMotorTorque = self.lastMotorTorque - torque 
			torque               = 0
		end
		
		if self.vehicle.mrGbMS.PowerManagement and acc > 0 then
			local p1 = rpm * ( self.lastMotorTorque - self.lastPtoTorque )
			local p0 = 0
			if self.vehicle.mrGbMS.EcoMode then
				p0 = self.currentMaxPower
			else
				p0 = self.maxPower
			end
			p0 = acc * ( p0 - rpm * self.lastPtoTorque )
			
			if     p0 <= 0 
					or p1 <= 0 then
				acc = 1
			elseif p0 >= p1 then
				acc = 1
			else
				acc = p0 / p1
			end
		end
		
		torque = torque * acc		
	end
	
	if     self.noTransmission 
			or self.noTorque then
		self.ptoSpeedLimit = nil
	elseif  self.lastMissingTorque > gearboxMogli.ptoSpeedLimitRatio * self.lastMotorTorque 
			and self.vehicle.mrGbMS.PtoSpeedLimit 
			and ( not ( self.vehicle.steeringEnabled ) 
				or  self.vehicle.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE
				or  self.vehicle.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_FULL )
			and self.vehicle.lastSpeedReal*1000 > gearboxMogli.ptoSpeedLimitMin then
		if self.ptoSpeedLimit ~= nil then
			self.ptoSpeedLimit = math.max( self.ptoSpeedLimit - self.tickDt * gearboxMogli.ptoSpeedLimitDec, gearboxMogli.ptoSpeedLimitMin )
		else		
			self.ptoSpeedLimit = math.max( self.vehicle.lastSpeedReal*1000 - gearboxMogli.ptoSpeedLimitIni, gearboxMogli.ptoSpeedLimitMin )
		end
	elseif self.ptoSpeedLimit ~= nil then
		if gearboxMogli.ptoSpeedLimitInc > 0 then
			self.ptoSpeedLimit = self.ptoSpeedLimit + self.tickDt * gearboxMogli.ptoSpeedLimitInc
			if self.ptoSpeedLimit > self.vehicle.lastSpeedReal*1000 + gearboxMogli.ptoSpeedLimitOff then
				self.ptoSpeedLimit = nil
			end
		else
			self.ptoSpeedLimit = nil
		end
	end
	
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
		end
	end

	if     torque < 0 then
		self.lastMissingTorque      = self.lastMissingTorque - torque
		self.transmissionEfficiency = 0
	elseif self.noTransmission then
		self.noTransTorque          = torque * self.vehicle.mrGbMG.idleFuelTorqueRatio
		self.transmissionEfficiency = 0
	elseif self.vehicle.mrGbMS.HydrostaticCoupling ~= nil then
		local Mm = torque 		
		local Mi, Mf = 0, 0
		local h  = self.hydrostaticFactor
		
		self.hydrostatVolumeMotor = self.vehicle.mrGbMS.HydrostaticVolumeMotor
		self.hydrostatVolumePump  = self.vehicle.mrGbMS.HydrostaticVolumePump 
		
		if     self.vehicle.mrGbMS.HydrostaticCoupling == "output" then
			if 2.1 * h < 1 then
				self.hydrostatVolumePump  = self.vehicle.mrGbMS.HydrostaticVolumePump  * 1.1 * h / ( 1 - h )
			else
				self.hydrostatVolumeMotor = self.vehicle.mrGbMS.HydrostaticVolumeMotor * ( 1 - h ) / ( h * 1.1 )
			end
			Mi      = Mm
			Mf      = Mm
		elseif self.vehicle.mrGbMS.HydrostaticCoupling == "input" then
			self.hydrostatVolumePump  = math.max( self.vehicle.mrGbMS.HydrostaticVolumePump * ( h - 1 ), gearboxMogli.eps-self.hydrostatVolumeMotor )
			Mi      = math.max( -1, 1.1 * self.hydrostatVolumePump / ( self.hydrostatVolumePump + self.hydrostatVolumeMotor ) ) * Mm 
			Mf      = Mm - Mi
		else
			h = h * 1.1
			if h < 1 then
				self.hydrostatVolumePump  = self.vehicle.mrGbMS.HydrostaticVolumePump  * h
			else
				self.hydrostatVolumeMotor = self.vehicle.mrGbMS.HydrostaticVolumeMotor / h
			end
			Mi      = Mm
		end
		
		if self.hydrostatPressureO == nil then
			self.hydrostatPressureO = 0
			self.hydrostatPressureI = 0
			self.hydrostatFlow      = 0
		end
		
		local Po = Utils.getNoNil( self.hydrostatPressureO, 0 )
		local Pi = Po -- math.min( Po, self.vehicle.mrGbMS.HydrostaticPressure )

		if math.abs( self.hydrostatVolumePump ) > gearboxMogli.eps then -- and Po < self.vehicle.mrGbMS.HydrostaticPressure then
			Pi = Utils.clamp( Pi + 0.95 * Mi * 20000 * math.pi / self.hydrostatVolumePump, 0, self.vehicle.mrGbMS.HydrostaticPressure )
		--Pi = Pi + 0.95 * Mi * 20000 * math.pi / self.hydrostatVolumePump
		end
		
		self.hydrostatPressureI = self.hydrostatPressureI + self.vehicle.mrGbML.smoothLittle * ( Pi - self.hydrostatPressureI )
	--Pi = Utils.clamp( self.hydrostatPressureI, 0, self.vehicle.mrGbMS.HydrostaticPressure )
		
		local Mo = 0
		if self.noTransmission or self.noTorque or self.vehicle.mrGbML.lastAcceleration <= 0 then
			Mo = 0
		else
			Mo = 0.95 * Pi * self.hydrostatVolumeMotor / ( 20000 * math.pi )
		end		
		
		Mo = Mo
		Mf = Mf * self.vehicle.mrGbMS.TransmissionEfficiency
		local Mw				
						
		if     self.vehicle.mrGbMS.HydrostaticCoupling == "output" then
			Mw = math.max( 0, Mo + Mf )
		elseif self.vehicle.mrGbMS.HydrostaticCoupling == "input" then
			Mw = self.vehicle.mrGbMS.TransmissionEfficiency * ( Mm - ( Pi-Po ) * self.hydrostatVolumePump / ( 0.95 * 20000 * math.pi ) )
		else 
			Mw = Mo
		end
		
		if self.vehicle.mrGbMG.debugPrint then
			print(string.format("Torque: Mi: %4.0f Mf: %4.0f (%4.0f, %3.0f%%) Vi: %4.0f Pi: %4.0f Mo: %4.0f Vo: %4.0f Po: %4.0f Ni: %4.0f No: %4.0f h: %1.3f => %4.0f (%f)", 
													Mi*1000,
													Mf*1000,
													Mm*1000,
													acc*100,
													self.hydrostatVolumePump,
													Pi,
													Mo*1000,
													self.hydrostatVolumeMotor,
													Po,
													rpm,
													self.clutchRpm,
													h,
													Mw*1000,
													Mw-self.hydrostaticFactor*Mm))
		end
		
		
		if torque > gearboxMogli.eps then
			self.transmissionEfficiency = Mw / torque 
		else
			self.transmissionEfficiency = 1
		end
		
	elseif torque > 0 then
					
		local e = self.vehicle.mrGbMG.transmissionEfficiency
		
		if self.vehicle.mrGbMS.Hydrostatic then
			e = self:getHydroEff( self.hydrostaticFactor )
		else
			e = self.vehicle.mrGbMS.TransmissionEfficiency
		end

		if self.noTransmission then
			self.transmissionEfficiency = 0
		elseif self.clutchPercent < gearboxMogli.eps then
			self.transmissionEfficiency = 0
		elseif self.clutchPercent < 1 and self.vehicle.mrGbMS.TorqueConverter then
			self.transmissionEfficiency = self.vehicle.mrGbMS.TorqueConverterEfficiency 
		else
			self.transmissionEfficiency = e
		end
	end
	
	torque = torque * self.transmissionEfficiency	
	self.lastTransTorque = torque

	local lastG = self.ratioFactorG
	self.ratioFactorG = 1
	self.ratioFactorR = 1
	
	if     self.noTransmission then
		self.ratioFactorR  = nil
		self.lastGearRatio = nil
		self.lastGMax      = nil
		
	--if     self.vehicle.mrGbMS.Hydrostatic     then
	--	local hMax = self.vehicle.mrGbMS.HydrostaticMax
	--	if self.vehicle.mrGbMS.ReverseActive and self.vehicle.mrGbMS.HydrostaticMin < 0 then
	--		hMax = -self.vehicle.mrGbMS.HydrostaticMin
	--	end
	--	self.ratioFactorG  = 1 / hMax
	--	self.gearRatio     = self:getMogliGearRatio() * self.ratioFactorG
	--	if self.vehicle.mrGbMS.ReverseActive then 
	--		self.gearRatio   = -self.gearRatio
	--	end
	--	self.lastGearRatio = self.gearRatio
	--end
	elseif self.vehicle.mrGbMS.Hydrostatic then

		local r = self:getMogliGearRatio()
	
		if      self.hydrostaticFactor < gearboxMogli.minHydrostaticFactor then
			if self.vehicle.mrGbMS.ReverseActive then 
				self.lastGearRatio = -gearboxMogli.maxHydroGearRatio
			else
				self.lastGearRatio =  gearboxMogli.maxHydroGearRatio
			end
		end
		
		local gMax = gearboxMogli.huge
		if      self.vehicle.mrGbMS.HydrostaticMaxTorque ~= nil
				and torque > self.hydrostaticFactor * ( torque + self.vehicle.mrGbMS.HydrostaticMaxTorque ) then
			gMax = 1 + self.vehicle.mrGbMS.HydrostaticMaxTorque / torque
			if self.lastGMax == nil then
				self.lastGMax = gMax
			else
				self.lastGMax = self.lastGMax + self.vehicle.mrGbML.smoothMedium * ( gMax - self.lastGMax )
			end
			gMax = self.lastGMax
		else
			self.lastGMax = nil
		end
		
		if gearboxMogli.maxHydroGearRatio * self.hydrostaticFactor < r then
			self.ratioFactorG = math.min( gMax, gearboxMogli.maxHydroGearRatio / r )
		else
			self.ratioFactorG = math.min( gMax, 1 / self.hydrostaticFactor )
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
				self.ratioFactorG = g / r
			end
		end
		
		if self.vehicle.mrGbMS.ReverseActive then 
			self.gearRatio = -g
		else
			self.gearRatio =  g
		end
		self.lastGearRatio = self.gearRatio
		
		if self.hydrostaticFactor < gearboxMogli.minHydrostaticFactor then
			self.ratioFactorR = 1
		else --if self.ratioFactorG * self.hydrostaticFactor < 1 then
			self.ratioFactorR = 1 / ( self.ratioFactorG * self.hydrostaticFactor )
		end
		
	elseif self.autoClutchPercent < 1 and self.vehicle.mrGbMS.TorqueConverter then
		local c = self.clutchRpm / self:getMotorRpm( self.autoClutchPercent )
		if c * self.vehicle.mrGbMS.TorqueConverterFactor > 1 then
			self.ratioFactorG = 1 / c
		else
			self.ratioFactorG = self.vehicle.mrGbMS.TorqueConverterFactor
		end
		self.ratioFactorG = lastG + self.vehicle.mrGbML.smoothLittle * ( self.ratioFactorG - lastG )
		-- clutch percentage will be applied additionally => undo ratioFactorG in updateMotorRpm 
		self.ratioFactorR = 1 / self.ratioFactorG
	end
	
	if self.ratioFactorR == nil then
	elseif self.ratioFactorR < 0 then
		self.ratioFactorR = nil
	elseif self.ratioFactorR > 1e6 then
		self.ratioFactorR = 1e6 
	end
	
	return torque, brakePedal, brakeForce
end

--**********************************************************************************************************	
-- gearboxMogliMotor:updateMotorRpm
--**********************************************************************************************************	
function gearboxMogliMotor:updateMotorRpm( dt )
	local vehicle = self.vehicle
	self.tickDt                  = dt
	self.prevNonClampedMotorRpm  = self.nonClampedMotorRpm
	self.prevMotorRpm            = self.lastRealMotorRpm
	self.prevClutchRpm           = self.clutchRpm
	
	self.nonClampedMotorRpm, self.clutchRpm, self.usedTransTorque = getMotorRotationSpeed(vehicle.motorizedNode)		
	self.nonClampedMotorRpm  = self.nonClampedMotorRpm * gearboxMogli.factor30pi
	self.clutchRpm           = self.clutchRpm          * gearboxMogli.factor30pi
	self.requiredWheelTorque = self.maxMotorTorque*math.abs(self.gearRatio)	
	self.wheelSpeedRpm       = self.vehicle.lastSpeedReal * 1000 * gearboxMogli.factor30pi * self.vehicle.movingDirection	

	if not ( self.noTransmission ) and math.abs( self.gearRatio ) > gearboxMogli.eps then
		local w = self.clutchRpm / self.gearRatio
		if gearboxMogli.trustClutchRpmTimer <= dt then
			self.wheelSpeedRpm = w
			if     self.trustClutchRpmTimer == nil 
					or self.trustClutchRpmTimer > g_currentMission.time + 1000 then
				self.trustClutchRpmTimer = g_currentMission.time + 1000
			elseif self.trustClutchRpmTimer < g_currentMission.time then	
				self.wheelSpeedRpm = w
			else
				self.wheelSpeedRpm = self.wheelSpeedRpm + 0.001 * ( self.trustClutchRpmTimer - g_currentMission.time ) * ( w - self.wheelSpeedRpm )
			end
			if self.trustClutchRpmTimer >= g_currentMission.time then
				self.clutchRpm = self.wheelSpeedRpm * self.gearRatio
			end
		end
	elseif self.trustClutchRpmTimer ~= nil then
		self.trustClutchRpmTimer = nil
	end
	
	if self.ratioFactorR ~= nil then	
		self.clutchRpm = self.ratioFactorR * self.clutchRpm          
	elseif self.prevClutchRpm ~= nil then
		self.clutchRpm = self.prevClutchRpm + Utils.clamp( self:getThrottleRpm() - self.prevClutchRpm, -dt * self.vehicle.mrGbMS.RpmDecFactor, dt * self.vehicle.mrGbMS.RpmIncFactor )
	else
		self.clutchRpm = self:getThrottleRpm()
	end
	
	if self.vehicle.isMotorStarted and gearboxMogli.debugGearShift then
		if not ( self.noTransmission ) and self.ratioFactorR ~= nil and self.hydrostaticFactor > gearboxMogli.eps then
			print(string.format("A: %4.2f km/h s: %6.3f w: %6.0f n: %4.0f c: %4.0f g: %6.3f fr: %6.3f fg: %6.3f h: %6.3f r: %6.3f g: %d", 
													self.vehicle.lastSpeedReal*3600,
													self.wheelSpeedRpm,
													self.wheelSpeedRpm * self:getMogliGearRatio() / self.hydrostaticFactor,
													self.nonClampedMotorRpm,
													self.clutchRpm,
													self.gearRatio,
													self.ratioFactorR,
													self.ratioFactorG,
													self.hydrostaticFactor,
													self.ratioFactorR*self.ratioFactorG*self.hydrostaticFactor,
													self.vehicle.mrGbMS.CurrentGear ))
		else
			print(string.format("B: %4.2f km/h s: %6.3f t: %4d c: %4d (%4d) n: %4d (%4d)",
													self.vehicle.lastSpeedReal*3600,
													self.wheelSpeedRpm,
													self:getThrottleRpm(),
													self.clutchRpm, self.prevClutchRpm,
													self.nonClampedMotorRpm, self.prevNonClampedMotorRpm))
		end
	end
		
	if not ( self.vehicle.isMotorStarted ) then
		self.motorLoadOverflow   = 0
		self.nonClampedMotorRpm  = 0
	elseif not ( self.noTransmission ) and self.ratioFactorR ~= nil then
		self.nonClampedMotorRpm  = self:getMotorRpm()
		if self.motorLoadOverflow == nil then
			self.motorLoadOverflow = 0
		end
	elseif self.prevNonClampedMotorRpm ~= nil then
		self.motorLoadOverflow   = 0
		self.nonClampedMotorRpm  = self.prevNonClampedMotorRpm + Utils.clamp( self:getThrottleRpm() - self.prevNonClampedMotorRpm,
																																					-dt * self.vehicle.mrGbMS.RpmDecFactor,
																																					 dt * self.vehicle.mrGbMS.RpmIncFactor )	
	else
		self.motorLoadOverflow   = 0
		self.nonClampedMotorRpm  = self:getThrottleRpm()
	end
	
	self.usedTransTorque = self.usedTransTorque + self.motorLoadOverflow
	if self.usedTransTorque > self.lastTransTorque then
		self.motorLoadOverflow = self.usedTransTorque - self.lastTransTorque
		self.usedTransTorque   = self.lastTransTorque
	else
		self.motorLoadOverflow = 0
	end
		
	
	if not ( self.vehicle.isMotorStarted ) then
		self.usedTransTorque   = 0
		self.lastRealMotorRpm  = 0
		self.lastMotorRpm      = 0
	elseif self.noTransmission then
		self.usedTransTorque   = self.noTransTorque
		self.lastRealMotorRpm  = self.lastMotorRpm
	else
		if self.transmissionEfficiency ~= nil and 0.1 <= self.transmissionEfficiency and self.transmissionEfficiency < 1 then
			self.usedTransTorque = self.usedTransTorque / self.transmissionEfficiency
		end
		self.lastRealMotorRpm  = math.max( self.vehicle.mrGbMS.CurMinRpm, math.min( self.nonClampedMotorRpm, self.vehicle.mrGbMS.CurMaxRpm ) )
		
		local m = gearboxMogli.maxManualGearRatio 
		if self.vehicle.mrGbMS.Hydrostatic then	
			m = gearboxMogli.maxHydroGearRatio 
		end		
		if math.abs( self.gearRatio ) >= m - gearboxMogli.eps then
			local minRpmReduced   = Utils.clamp( self.minRequiredRpm * gearboxMogli.rpmReduction, self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.RatedRpm * gearboxMogli.rpmReduction )		
			self.lastRealMotorRpm = math.max( self.lastRealMotorRpm, minRpmReduced )
		end
		
		local diff = self.lastRealMotorRpm - self.lastMotorRpm
		if self.vehicle.mrGbMS.Hydrostatic or self.clutchPercent < 1 then
			diff = diff * self.vehicle.mrGbML.smoothFast
		end
		local rpm = self.lastMotorRpm + Utils.clamp( diff, -dt * self.vehicle.mrGbMS.RpmDecFactor, dt * self.vehicle.mrGbMS.RpmIncFactor )
		
		self.lastMotorRpm = Utils.clamp( rpm, self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.CurMaxRpm )
	end
	
	self.lastAbsDeltaRpm = self.lastAbsDeltaRpm + self.vehicle.mrGbML.smoothMedium * ( math.abs( self.prevNonClampedMotorRpm - self.nonClampedMotorRpm ) - self.lastAbsDeltaRpm )	
	self.deltaMotorRpm   = math.floor( self.lastRealMotorRpm - self.nonClampedMotorRpm + 0.5 )
	
	local c = self.clutchPercent
	if not ( self.vehicle.mrGbMS.Hydrostatic or self.vehicle:mrGbMGetAutoClutch() ) then
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
	
	self.nonClampedMotorRpmS = self.nonClampedMotorRpmS + gearboxMogli.smoothFast * ( self.nonClampedMotorRpm - self.nonClampedMotorRpmS )	
	self.lastPtoRpm          = self.lastRealMotorRpm
	self.equalizedMotorRpm   = self.vehicle:mrGbMGetEqualizedRpm( self.lastMotorRpm )
		
	self.usedMotorTorque     = self.usedTransTorque + self.lastPtoTorque + self.lastMissingTorque
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
function gearboxMogliMotor:mrGbMUpdateGear( accelerationPedal )

	-- Vehicle.drawDebugRendering !!!
	self.debugEffectiveTorqueGraph    = nil
	self.debugEffectivePowerGraph     = nil
	self.debugEffectiveGearRatioGraph = nil
	self.debugEffectiveRpmGraph       = nil

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
	local gearRatio          = self:getMogliGearRatio()
	self.lastMaxPossibleRpm  = Utils.getNoNil( self.maxPossibleRpm, self.vehicle.mrGbMS.CurMaxRpm )
	local lastNoTransmission = self.noTransmission
	local lastNoTorque       = self.noTorque 
	self.noTransmission      = false
	self.noTorque            = not ( self.vehicle.isMotorStarted )
	self.maxPossibleRpm      = self.vehicle.mrGbMS.CurMaxRpm
	
--**********************************************************************************************************	

	self.ptoMotorRpmRatio    = self.original.ptoMotorRpmRatio
	local currentSpeed       = 3.6 * self.wheelSpeedRpm * gearboxMogli.factorpi30 --3600 * self.vehicle.lastSpeedReal * self.vehicle.movingDirection
	local currentAbsSpeed    = currentSpeed
	if self.vehicle.mrGbMS.ReverseActive then
		currentAbsSpeed        = -currentSpeed
	end
	
--**********************************************************************************************************	
	-- current RPM and power

	self.minRequiredRpm = self.vehicle.mrGbMS.IdleRpm
	
	lastPtoOn  = self.ptoOn
	self.ptoOn = false
	--if self.vehicle.mrGbMS.Hydrostatic then
	
	local handThrottle = -1
	
	if     self.vehicle:mrGbMGetOnlyHandThrottle()
			or self.vehicle.mrGbMS.HandThrottle > 0.01 then
		handThrottle = self.vehicle.mrGbMS.HandThrottle
	end
	
	local handThrottleRpm = self.vehicle.mrGbMS.IdleRpm 
	if handThrottle >= 0 then
		self.ptoOn = true
	--handThrottleRpm     = self.vehicle.mrGbMS.IdleRpm + handThrottle * math.max( 0, self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm )
		handThrottleRpm     = self:getThrottleMaxRpm( handThrottle )
		self.minRequiredRpm = math.max( self.minRequiredRpm, handThrottleRpm )
	end
	if self.vehicle.mrGbMS.AllAuto then
		handThrottle = -1
	end
	
	local ptoTq = self.neededPtoTorque --PowerConsumer.getTotalConsumedPtoTorque(self.vehicle)
	if ptoTq > 0 then
		self.ptoOn = true
	end	
	
	local ptoRpm = PowerConsumer.getMaxPtoRpm( self.vehicle )
	
	if ptoRpm ~= nil and ptoRpm > 0 then
		local p0 = self.vehicle.mrGbMS.PtoRpm
		if self.vehicle.mrGbMS.EcoMode then
			p0 = self.vehicle.mrGbMS.PtoRpmEco
		end
		
		self.ptoMotorRpmRatio = p0 / ptoRpm

		if self.minRequiredRpm < p0 then
			self.minRequiredRpm = p0
		end
	end
	
--if      self.limitMaxRpm 
--		and accelerationPedal    > 0.01 
--		and currentAbsSpeed      > self.currentSpeedLimit * 3.6 - 1
--		and self.usedTransTorque < accelerationPedal * self.lastTransTorque then
--	if     self.usedTransTorque <= 0.01 * self.lastTransTorque then
--		accelerationPedal = 0.01
--	else
--		accelerationPedal = self.usedTransTorque / self.lastTransTorque
--	end
--end
	self.lastThrottle = math.max( self.minThrottle, accelerationPedal )
	
	-- acceleration pedal and speed limit
	local currentSpeedLimit = self.currentSpeedLimit
	currentSpeedLimit       = currentSpeedLimit + gearboxMogli.extraSpeedLimitMs
	if self.ptoSpeedLimit ~= nil and currentSpeedLimit > self.ptoSpeedLimit then
		currentSpeedLimit = self.ptoSpeedLimit
	end
		
	local prevWheelSpeedRpm = self.absWheelSpeedRpm
	self.absWheelSpeedRpm = self.wheelSpeedRpm
	if self.vehicle.mrGbMS.ReverseActive then 
		self.absWheelSpeedRpm = -self.absWheelSpeedRpm
	end
	
	self.absWheelSpeedRpm   = math.max( self.absWheelSpeedRpm, 0 )	
	self.absWheelSpeedRpmS  = self.absWheelSpeedRpmS + self.vehicle.mrGbML.smoothFast * ( self.absWheelSpeedRpm - self.absWheelSpeedRpmS )
	local deltaRpm          = ( self.absWheelSpeedRpm - prevWheelSpeedRpm ) / self.tickDt         
	self.deltaRpm           = self.deltaRpm + self.vehicle.mrGbML.smoothMedium * ( deltaRpm - self.deltaRpm )
	local currentPower      = ( self.usedTransTorque + self.lastPtoTorque ) * math.max( self.prevNonClampedMotorRpm, self.vehicle.mrGbMS.IdleRpm )
	local getMaxPower       = ( self.lastMissingTorque > 0 )
	
	if self.vehicle.mrGbMS.IsCombine then
		if self.vehicle:getIsTurnedOn() then
			self.ptoOn          = true
			local targetRpmC 
			if self.vehicle.steeringEnabled and handThrottle >= 0 then
			--targetRpmC        = math.max( self.vehicle.mrGbMS.ThreshingMinRpm, self.vehicle.mrGbMS.IdleRpm + handThrottle * math.max( 0, self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm ) )
				targetRpmC        = self.vehicle.mrGbMS.IdleRpm + handThrottle * math.max( 0, self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm )
			elseif self.lastMissingTorque > 0 then
			--targetRpmC        = math.min( self.vehicle.mrGbMS.ThreshingMaxRpm, self.maxMaxPowerRpm )
				targetRpmC        = self.vehicle.mrGbMS.ThreshingMaxRpm
			elseif getMaxPower then
				targetRpmC        = Utils.clamp( self.maxMaxPowerRpm, self.vehicle.mrGbMS.ThreshingMinRpm, self.vehicle.mrGbMS.ThreshingMaxRpm )
			else
				targetRpmC        = self.currentPowerCurve:get( math.max( self.usedMotorTorque, 1.25 * self.lastPtoTorque ) * math.max( self.prevNonClampedMotorRpm, self.vehicle.mrGbMS.IdleRpm ) )
				targetRpmC        = Utils.clamp( targetRpmC, self.vehicle.mrGbMS.ThreshingMinRpm, self.vehicle.mrGbMS.ThreshingMaxRpm )
				if handThrottle >= 0 then 
					targetRpmC      = math.max( targetRpmC, self.vehicle.mrGbMS.IdleRpm + handThrottle * math.max( 0, self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm ) )
				end
			end			
			if self.targetRpmC == nil or self.targetRpmC < targetRpmC then
				self.targetRpmC   = targetRpmC 
			else
				self.targetRpmC   = self.targetRpmC + self.vehicle.mrGbML.smoothSlow * ( targetRpmC - self.targetRpmC )		
			end
			self.minRequiredRpm = self.targetRpmC
		else
			self.targetRpmC     = nil
		end
	end

	self.vehicle:mrGbMSetState( "ConstantRpm", self.ptoOn )
	
	
--if      handThrottle    >= 0
--		and handThrottleRpm < self.minRequiredRpm 
--		and self.vehicle.mrGbMS.RatedRpm   > self.vehicle.mrGbMS.IdleRpm + gearboxMogli.eps then
--	self.vehicle:mrGbMSetHandThrottle( ( self.minRequiredRpm - self.vehicle.mrGbMS.IdleRpm ) / ( self.vehicle.mrGbMS.RatedRpm - self.vehicle.mrGbMS.IdleRpm ) )
--end
	
	local minRpmReduced = Utils.clamp( self.minRequiredRpm * gearboxMogli.rpmReduction, self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.RatedRpm * gearboxMogli.rpmReduction )		

	local rp = math.max( ( self.lastPtoTorque + self.lastMissingTorque ) * math.max( self.prevNonClampedMotorRpm, self.vehicle.mrGbMS.IdleRpm ), self.lastThrottle * self.currentMaxPower )
	
	if     self.usedTransTorque < self.lastTransTorque - gearboxMogli.eps then
		requestedPower = math.min( rp, currentPower )
	elseif getMaxPower then
		requestedPower = self.currentMaxPower
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

--print(string.format( "%3.0f%% %4.0f %4.0f %4.0f %4.0f => %4.0f ", self.lastThrottle*100, currentPower, pp, rp, self.currentMaxPower, requestedPower )..tostring(getMaxPower))
	
	self.motorLoadP = 0
	
	if     not ( self.vehicle.isMotorStarted ) then
		self.motorLoadS1 = nil
		self.motorLoadP = 0
	elseif self.lastRealMotorRpm >= self.vehicle.mrGbMS.CurMaxRpm or self.lastMotorTorque < gearboxMogli.eps then
		self.motorLoadP = 0
	else
		self.motorLoadP = self.usedMotorTorque / self.lastMotorTorque
	end

	if     self.prevMotorRpm > self.vehicle.mrGbMS.RatedRpm and self.lastMotorTorque * self.prevMotorRpm  < self.maxRatedTorque * self.vehicle.mrGbMS.RatedRpm then
		self.motorLoadP = 0.2 * self.motorLoadP + 0.8 * self.usedMotorTorque * self.prevMotorRpm / ( self.maxRatedTorque * self.vehicle.mrGbMS.RatedRpm )
	elseif self.lastMissingTorque > 0 and self.motorLoadP < 1 then
		self.motorLoadP = 1
	elseif lastNoTorque then
		self.motorLoadP = 0
	end

	if self.requestedPower1 == nil then
		self.requestedPower1 = requestedPower
	else
		local slow = self.vehicle.mrGbMG.dtDeltaTargetSlow * self.tickDt * self.currentMaxPower
		local fast = self.vehicle.mrGbMG.dtDeltaTargetFast * self.tickDt * self.currentMaxPower
		
		self.requestedPower1 = self.requestedPower1 + Utils.clamp( requestedPower - self.requestedPower1, -slow, fast )
	end
  self.requestedPower = self.requestedPower1
	
	if self.motorLoadS1 == nil then
		self.motorLoadS1 = self.motorLoadP
		self.motorLoadS2 = self.motorLoadP
		self.motorLoadP  = Utils.clamp( self.motorLoadP, 0, 1 )
		self.motorLoadS	 = self.motorLoadP
	else
		local slow = self.vehicle.mrGbMG.dtDeltaTargetSlow * self.tickDt
		local fast = self.vehicle.mrGbMG.dtDeltaTargetFast * self.tickDt
		
		self.motorLoadS1 = self.motorLoadS1 + Utils.clamp( self.motorLoadP - self.motorLoadS1, -fast, fast )	
		self.motorLoadS2 = self.motorLoadS2 + Utils.clamp( self.motorLoadP - self.motorLoadS2, -slow, slow )
		
		self.motorLoadS	 = Utils.clamp( math.max( self.motorLoadS1, self.motorLoadS2 ), 0, 1 )	
		self.motorLoadP  = Utils.clamp( self.motorLoadP, 0, 1 )
  end		

	local mlf = Utils.clamp( 1 - ( 1 - self.motorLoadP )^gearboxMogli.motorLoadExp, 0, 1 ) 
	if     self.vehicle.mrGbML.gearShiftingNeeded == 2
			or ( self.vehicle.mrGbML.gearShiftingNeeded > 0 and self.vehicle.mrGbML.doubleClutch )
			or self.vehicle.mrGbML.gearShiftingNeeded  < 0 then
		mlf = math.max( 0.5, mlf )
	end
	if  not lastNoTransmission
			and self.nonClampedMotorRpm > self.prevNonClampedMotorRpm + self.maxRpmIncrease - gearboxMogli.eps then
		mlf = math.max( 0.9 * accelerationPedal, mlf )
	end
	self.motorLoad = math.max( 0, self.maxMotorTorque * mlf - self.neededPtoTorque / self.ptoMotorRpmRatio )
	
	local wheelLoad   = 0
	if not ( lastNoTransmission ) then
		wheelLoad       = math.abs( self.usedTransTorque * self.gearRatio	)
	end
	if self.wheelLoadS == nil then
		self.wheelLoadS = wheelLoad
	else
		self.wheelLoadS = self.wheelLoadS + self.vehicle.mrGbML.smoothSlow * ( wheelLoad - self.wheelLoadS )		
  end		
	
	local targetRpm 
	if     lastNoTransmission then
	-- no transmission 
		targetRpm = self.minRequiredRpm
	elseif self.ptoOn then
		targetRpm = self.minRequiredRpm
	else
		targetRpm = Utils.clamp( self.currentPowerCurve:get( requestedPower ), self.minRequiredRpm, self.vehicle.mrGbMS.RatedRpm )
	end

	local minTarget = minRpmReduced
	if minRpmReduced < self.vehicle.mrGbMS.MinTargetRpm then
		if     currentAbsSpeed < gearboxMogli.eps then
			minTarget = minRpmReduced
		elseif currentAbsSpeed < 2 then
			minTarget = minRpmReduced + ( self.vehicle.mrGbMS.MinTargetRpm - minRpmReduced ) * currentAbsSpeed * 0.5 
		else
			minTarget = self.vehicle.mrGbMS.MinTargetRpm
		end
	end
	if targetRpm < minTarget then
		targetRpm = minTarget	
	elseif self.vehicle.cruiseControl.state ~= 0
			or not self.vehicle.steeringEnabled then
	-- nothing
	elseif accelerationPedal <= 0 then
		targetRpm = minTarget	
	elseif gearboxMogli.eps < accelerationPedal and accelerationPedal < self.vehicle.mrGbMS.MaxRpmThrottle then
		local tr = self:getThrottleMaxRpm( accelerationPedal / self.vehicle.mrGbMS.MaxRpmThrottle )
		if     tr < minTarget then
			targetRpm = minTarget 
		elseif tr > targetRpm then
			targetRpm = tr
		end
	end
	
	if self.targetRpm1 == nil then
		self.targetRpm1 = targetRpm 
	else
		local slow = self.vehicle.mrGbMG.dtDeltaTargetSlow * self.tickDt * ( self.maxPowerRpm - self.vehicle.mrGbMS.MinTargetRpm )
		local fast = self.vehicle.mrGbMG.dtDeltaTargetFast * self.tickDt * ( self.maxPowerRpm - self.vehicle.mrGbMS.MinTargetRpm )
		
		self.targetRpm1 = self.targetRpm1 + Utils.clamp( targetRpm - self.targetRpm1, -slow, fast )		
  end		
	
--print(string.format("%3d%%, %6g, %6g, %3d%%, %4d, %4d, %4d",
--										accelerationPedal*100,
--										self.usedTransTorque,
--										self.lastTransTorque,
--										requestedPower/self.currentMaxPower*100,
--										targetRpm,
--										self.targetRpm1,
--										self.targetRpm))
												
	self.targetRpm = self.targetRpm1
	
	if      self.ptoOn then
	-- reduce target RPM to accelerate and increase to brake 
		self.targetRpm = Utils.clamp( self.minRequiredRpm - accelerationPedal * gearboxMogli.ptoRpmThrottleDiff, self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.RatedRpm )		
	end
					
	-- clutch calculations...
	local clutchMode = 0 -- no clutch calculation

	if self.lastClutchClosedTime < self.vehicle.mrGbML.autoShiftTime then
		self.lastClutchClosedTime = self.vehicle.mrGbML.autoShiftTime
	end
	
  local r = self.vehicle.mrGbMS.RpmIncFactor + self.motorLoadP * self.motorLoadP * ( self.vehicle.mrGbMS.RpmIncFactorFull - self.vehicle.mrGbMS.RpmIncFactor )
  self.rpmIncFactor   = self.rpmIncFactor + self.vehicle.mrGbML.smoothMedium * ( r - self.rpmIncFactor )
	self.maxRpmIncrease = self.tickDt * self.rpmIncFactor
			
--**********************************************************************************************************		
	local oldAccTimer = self.hydroAccTimer
	self.hydroAccTimer = nil

--**********************************************************************************************************		
-- no transmission / neutral 
--**********************************************************************************************************		
	local brakeNeutral   = false
	local autoOpenClutch = self.vehicle:mrGbMGetAutoClutch() or ( self.vehicle.mrGbMS.Hydrostatic and self.vehicle.mrGbMS.HydrostaticLaunch )
	
	if      self.vehicle.mrGbMS.Hydrostatic
			and self.ptoOn 
			and not ( self.vehicle.mrGbML.ReverserNeutral )
			and accelerationPedal < -0.5
			and currentAbsSpeed >= self.vehicle.mrGbMG.minAbsSpeed then
		autoOpenClutch = false
	end
	
	if     self.vehicle.mrGbMS.G27Mode > 0 
			or not self.vehicle.mrGbMS.NeutralActive 
			or self.vehicle:getIsHired() then
		if     accelerationPedal >= -0.001 
				or currentAbsSpeed   >= self.vehicle.mrGbMG.minAbsSpeed then
			self.brakeNeutralTimer = g_currentMission.time + self.vehicle.mrGbMG.brakeNeutralTimeout
		end
	else
		if accelerationPedal > 0.001 then
			self.brakeNeutralTimer = g_currentMission.time + self.vehicle.mrGbMG.brakeNeutralTimeout
		end
	end
	
	if     self.vehicle.mrGbMS.NeutralActive
			or self.vehicle.mrGbMS.G27Mode == 1
			or not ( self.vehicle.isMotorStarted ) 
			or g_currentMission.time < self.vehicle.motorStartTime then
	-- off or neutral
		brakeNeutral = true
	elseif  self.vehicle.mrGbML.ReverserNeutral
			and autoOpenClutch
			and currentAbsSpeed < -1.8 then
	-- reverser and did not stop yet
		brakeNeutral = true
	elseif  self.vehicle.mrGbMS.Hydrostatic
			and self.vehicle.mrGbMS.HydrostaticMin < gearboxMogli.eps
			and accelerationPedal >= -0.001 then
		brakeNeutral = false
--elseif  currentAbsSpeed < -1.8 
--		and math.abs( self.vehicle.lastSpeedReal * 3600 ) > 1
--		and autoOpenClutch 
--		and not self.vehicle.mrGbMS.TorqueConverterOrHydro then
--	brakeNeutral  = true 
--	self.noTorque = true
	elseif self.vehicle.cruiseControl.state ~= 0 
			or not autoOpenClutch then
	-- no automatic stop or cruise control is on 
		brakeNeutral = false
	elseif accelerationPedal >= -0.001 then
	-- not braking 
		if      accelerationPedal      <  0.1
				and self.clutchRpm          <  0
				and self.vehicle:mrGbMGetAutoStartStop() 
				and self.vehicle.mrGbMS.G27Mode  <= 0 
				and not self.vehicle.mrGbMS.TorqueConverterOrHydro then				
	-- idle
			brakeNeutral = true 
		else
			brakeNeutral = false
		end
	elseif currentAbsSpeed       < self.vehicle.mrGbMG.minAbsSpeed + self.vehicle.mrGbMG.minAbsSpeed 
			or self.lastMotorRpm     < minRpmReduced 
			or ( self.lastMotorRpm   < self.minRequiredRpm and self.minThrottle > 0.2 ) then
	-- no transmission 
		brakeNeutral = true 
	else
		brakeNeutral = false
	end
	
--print(string.format("%1.3f %4d %s %2.1f", accelerationPedal, self.brakeNeutralTimer - g_currentMission.time, tostring(brakeNeutral), currentAbsSpeed))
		
	if brakeNeutral then
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
				and self.vehicle:mrGbMGetAutoHold( )
				and self.brakeNeutralTimer  < g_currentMission.time then
			self.vehicle:mrGbMSetState( "AutoHold", true )
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

		self.noTransmission  = true
		self.requestedPower1 = nil
		
		if      self.vehicle.mrGbMS.Hydrostatic 
				and self.targetRpm > gearboxMogli.eps
				and self.hydrostaticFactorT ~= nil then
			local hTgt = self.absWheelSpeedRpm * self:getMogliGearRatio() / self.targetRpm 
			
			if     self.vehicle.mrGbMS.HydrostaticMin >= 0 then
				hTgt = Utils.clamp( hTgt, self.vehicle.mrGbMS.HydrostaticStart, self.vehicle.mrGbMS.HydrostaticMax ) 
			elseif self.vehicle.mrGbMS.ReverseActive then	
				hTgt = Utils.clamp( hTgt, self.vehicle.mrGbMS.HydrostaticStart, -self.vehicle.mrGbMS.HydrostaticMin ) 
			else
				hTgt = Utils.clamp( hTgt, self.vehicle.mrGbMS.HydrostaticStart,  self.vehicle.mrGbMS.HydrostaticMax ) 
			end
			
			if math.abs( hTgt - self.hydrostaticFactorT ) > gearboxMogli.eps then
				if hTgt > self.hydrostaticFactorT then
					self.hydrostaticFactorT = self.hydrostaticFactorT + math.min( hTgt - self.hydrostaticFactorT,  self.tickDt * self.vehicle.mrGbMS.HydrostaticIncFactor ) 		
				else
					self.hydrostaticFactorT = self.hydrostaticFactorT + math.max( hTgt - self.hydrostaticFactorT, -self.tickDt * self.vehicle.mrGbMS.HydrostaticDecFactor )
				end
			end					
		end
		
--**********************************************************************************************************		
	else
--**********************************************************************************************************		
		self.vehicle:mrGbMSetState( "IsNeutral", false )
		self.vehicle.mrGbML.ReverserNeutral = false
		
		-- acceleration for idle/minimum rpm		
		if      self.vehicle.mrGbMS.Hydrostatic 
				and self.vehicle.mrGbMS.HydrostaticMin < gearboxMogli.minHydrostaticFactor then
			self.minThrottle  = 0
			self.minThrottleS = 0
		elseif lastNoTransmission then
			self.minThrottle  = math.max( 0.3, self.vehicle.mrGbMS.HandThrottle )
			self.minThrottleS = math.max( 0.3, self.vehicle.mrGbMS.HandThrottle )
			self.targetRpm = minRpmReduced
		else
			local minThrottleRpm = minRpmReduced 
			if handThrottle > 0 then
				minThrottleRpm = Utils.clamp( handThrottleRpm - gearboxMogli.ptoRpmThrottleDiff, minRpmReduced, self.minRequiredRpm )
			end
			if self.nonClampedMotorRpm <= minThrottleRpm then
				self.minThrottle  = 1
			elseif self.nonClampedMotorRpm < self.minRequiredRpm then
				self.minThrottle = ( self.minRequiredRpm - self.nonClampedMotorRpm ) / ( self.minRequiredRpm - minThrottleRpm )
			else
				self.minThrottle = 0
			end			
			self.minThrottleS = Utils.clamp( self.minThrottleS + self.vehicle.mrGbML.smoothFast * ( self.minThrottle - self.minThrottleS ), 0, 1 )
		end
		
		self.lastThrottle = math.max( self.minThrottle, accelerationPedal )								
		
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
			elseif ( accelerationPedal < 0.1 and self.vehicle.cruiseControl.state == 0 )
					or self.vehicle.mrGbMS.ManualClutch < self.vehicle.mrGbMS.MinClutchPercent + 0.1 then
				self.vehicle:mrGbMDoGearShift() 
				self.vehicle.mrGbML.gearShiftingNeeded = 0 
			end			

		elseif self.vehicle.mrGbML.gearShiftingNeeded > 0 then
	--**********************************************************************************************************		
	-- during gear shift with automatic clutch
			if self.vehicle.mrGbML.gearShiftingNeeded == 2 and g_currentMission.time < self.vehicle.mrGbML.gearShiftingTime then	
				if self.lastRealMotorRpm > 0.97 * self.vehicle.mrGbMS.RatedRpm then
					self.vehicle.mrGbML.gearShiftingNeeded  = 3
				end
				accelerationPedal = 1
			else               
				accelerationPedal = 0
				self.noTorque     = true
			end

			if g_currentMission.time >= self.vehicle.mrGbML.gearShiftingTime then
				if self.vehicle.mrGbML.gearShiftingNeeded < 2 then	
					self.vehicle:mrGbMDoGearShift() 
				end 
				self.vehicle.mrGbML.gearShiftingNeeded = 0 
				self.maxPossibleRpm          = self.vehicle.mrGbMS.CurMaxRpm 
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
			
		elseif self.vehicle.mrGbML.gearShiftingNeeded < 0 then
	--**********************************************************************************************************		
	-- during gear shift with manual clutch
			self.noTransmission = true			
			self.vehicle:mrGbMDoGearShift() 
			self.vehicle.mrGbML.gearShiftingNeeded = 0						
			
		elseif not ( self.vehicle:mrGbMGetAutoClutch() ) and self.vehicle.mrGbMS.ManualClutch < self.vehicle.mrGbMS.MinClutchPercent + 0.1 then
	--**********************************************************************************************************		
	-- manual clutch pressed
			self.noTransmission = true		
		else
	--**********************************************************************************************************		
	-- normal drive with gear and clutch
			self.noTransmission = false

			local accHydrostaticTarget = false

	--**********************************************************************************************************		
	-- reduce hydrostaticFactor instead of braking  
			if      self.vehicle.mrGbMS.Hydrostatic
					and self.ptoOn then
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
			end
		
			clutchMode = 1 -- calculate clutch percent respecting inc/dec time ms

	--**********************************************************************************************************		
	-- hydrostatic drive
			if self.vehicle.mrGbMS.Hydrostatic then
				-- target RPM
				local c = self.lastRealMotorRpm 
				local t = self.targetRpm
				local a = math.min( accelerationPedal, self.lastThrottle )
				
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
					local bestH     = self.hydrostaticFactorT
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
							elseif  self.deltaRpm < -gearboxMogli.autoShiftMaxDeltaRpm
									and spd           > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
								if gearboxMogli.debugGearShift then print(tostring(g)..": no down shift II") end
								isValidEntry = false
							elseif  self.deltaRpm > gearboxMogli.autoShiftMaxDeltaRpm
									and spd           < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
								if gearboxMogli.debugGearShift then print(tostring(g)..": no up shift II") end
								isValidEntry = false
							end
						end

						if isValidEntry then	
							local r = gearboxMogli.gearSpeedToRatio( self.vehicle, spd )					
							local w = w0 * r
					
							if w <= gearboxMogli.eps then
								if bestS == nil or bestS > spd then
									bestS = spd
									bestG = g
									bestR = 9999
									bestE = -1
									bestH = self.vehicle.mrGbMS.HydrostaticStart
								end
							else
								local h = w / t
								
								if hMin <= h and h <= hMax then
									local e = self:getHydroEff( h )
									if bestS == nil or bestR > 0 or bestE < e then
										bestG = g
										bestS = spd
										bestE = e
										bestR = 0
										bestH = h
									end
								elseif bestS == nil or bestR > 0 then
									local r = math.abs( t - w / Utils.clamp( h, math.max( hMin, gearboxMogli.eps ), hMax ) )
									if bestE == nil or bestR > r then
										bestG = g
										bestS = spd
										bestE = 0
										bestR = r
										bestH = h
									end
								end
							end
						end
					end
					
					self.vehicle.mrGbML.autoShiftInfo = string.format( "rpm: %4.0f target: %4.0f gear: %2d speed: %5.3f hydro: %4.2f\n",
																															self.lastRealMotorRpm, 
																															t, 
																															currentGear, 
																															self.vehicle.mrGbMS.CurrentGearSpeed,
																															self.hydrostaticFactor )
					if bestS == nil then
						self.vehicle.mrGbML.autoShiftInfo = self.vehicle.mrGbML.autoShiftInfo .. "nothing found: "..tostring(tooBig).." "..tostring(tooSmall)
					else
						self.vehicle.mrGbML.autoShiftInfo = self.vehicle.mrGbML.autoShiftInfo ..
																								string.format( "bestG: %2d bestS: %5.3f bestE: %4.2f bestR: %4.0f",
																																bestG, bestS, bestE, bestR )
					end 
					
					if bestG ~= currentGear then	
						local i2g, i2r = self:splitGear( bestG )
						
						if self.vehicle.mrGbMG.debugPrint or gearboxMogli.debugGearShift then
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
						self.hydrostaticFactorT = bestH
					end
				end

				
				if self.vehicle.mrGbML.gearShiftingNeeded == 0 then
					-- min RPM
					local r = self:getMogliGearRatio()
					local w = w0 * r

					-- min / max RPM
					local n0 = minTarget
					local m0 = self.vehicle.mrGbMS.HydrostaticMaxRpm
					
					if self.torqueRpmReduction ~= nil then
						n0 = math.min( n0, self.torqueRpmReference - self.torqueRpmReduction )
						m0 = math.min( m0, self.torqueRpmReference - self.torqueRpmReduction )
						t  = math.min( t,  self.torqueRpmReference - self.torqueRpmReduction )
					end
										
					local d = gearboxMogli.hydroEffDiff
					if d < gearboxMogli.huge and gearboxMogli.hydroEffDiffInc > 0 then
						d = d + math.min(1,1.4-1.4*self.motorLoadS) * gearboxMogli.hydroEffDiffInc
					end
					
					if self.ptoOn and d > self.vehicle.mrGbMS.HydrostaticPtoDiff then
						d = self.vehicle.mrGbMS.HydrostaticPtoDiff
					end
					
					local m1    = Utils.clamp( t + d, n0, m0 )
					local n1    = Utils.clamp( t - d, n0, m0 )					
					local hMin1 = Utils.clamp( w / m1, hMin, hMax )
					local hMax1 = Utils.clamp( w / n1, hMin, hMax )
					local hTgt  = Utils.clamp( w / t, hMin1, hMax1 )

					if     hMin1 > hMax1 - gearboxMogli.eps then
						hTgt = hMin1
					elseif self.ptoOn and ( self.vehicle.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE or self.vehicle.mrGbML.hydroTargetSpeed ~= nil ) then
						hTgt = Utils.clamp( self.vehicle.mrGbMS.RatedRpm * currentSpeedLimit / ( t * self.vehicle.mrGbMS.CurrentGearSpeed ), hMin1, hMax1 )						
					elseif not ( self.vehicle.mrGbMS.HydrostaticDirect ) then
						local sp = nil
						local sf = nil						
						local ti = Utils.clamp( math.floor( 200 * ( hMax1 - hMin1 ) + 0.5 ), 10, 100 )
						local td = 1 / ti
						
						for f=0,ti do
							local h2 = hMax1 + f * ( hMin1 - hMax1 ) * td
							local r2 = w / math.max( h2, gearboxMogli.eps )
													
							local mt = self.currentTorqueCurve:get( r2 )
							if mt > gearboxMogli.eps and mt > self.lastPtoTorque then
								local e  = self:getHydroEff( h2 )
								local rt = a * ( mt - self.lastPtoTorque ) 
								local lt = Utils.clamp( 1 - e, 0, 1 ) * rt
								rt = rt - lt
								if self.usedTransTorque < rt and self.usedTransTorque < self.lastTransTorque - gearboxMogli.eps then
									rt = self.usedTransTorque 
								end
								
								local ratio = self.fuelCurve:get( r2 ) / math.max( 0.001, gearboxMogli.powerFuelCurve:get( ( rt + self.lastPtoTorque + lt ) / mt ) )										
								local rp = ( rt + self.lastPtoTorque + lt ) * r2
								local dp = math.max( 0, requestedPower - mt * r2 )
								local df = ratio * rp
																
								if     sp == nil 
										or dp < sp 
										or ( dp == sp and df < sf ) then
									sp   = dp
									sf   = df 
									hTgt = h2
								end
							end
						end
					end
					
					if gearboxMogli.debugGearShift and self.torqueRpmReduction ~= nil then
						print(string.format("torqueRpmReduction r: %4d n: %4d m: %4d t: %4d / h: %6f t: %6f / %6f / %6f",
																self.torqueRpmReference - self.torqueRpmReduction,
																n1,
																m1,
																t,
																self.hydrostaticFactor,
																hTgt,
																currentSpeedLimit*3.6,
																self.vehicle.lastSpeedReal*3600))
					end
						
					if     self.hydrostaticFactorT == nil 
							or self.torqueRpmReduction ~= nil
							or ( self.vehicle.mrGbMS.HydrostaticIncFactor >= 1 and self.vehicle.mrGbMS.HydrostaticDecFactor >= 1 )
							or self.lastRealMotorRpm > self.lastMaxPossibleRpm 
							or self.lastRealMotorRpm > m0
							or self.lastRealMotorRpm < n0 then
						self.hydrostaticFactorT = hTgt
					elseif math.abs( hTgt - self.hydrostaticFactorT ) > gearboxMogli.eps then
						if hTgt > self.hydrostaticFactorT then
							self.hydrostaticFactorT = self.hydrostaticFactorT + math.min( hTgt - self.hydrostaticFactorT,  self.tickDt * self.vehicle.mrGbMS.HydrostaticIncFactor ) 		
						else
							self.hydrostaticFactorT = self.hydrostaticFactorT + math.max( hTgt - self.hydrostaticFactorT, -self.tickDt * self.vehicle.mrGbMS.HydrostaticDecFactor )
						end
					end				
					
					if      self.hydrostaticFactorT > gearboxMogli.minHydrostaticFactor 
							and not ( self.vehicle.mrGbMS.HydrostaticDirect )
							and not ( self.ptoOn ) then
						self.targetRpm = Utils.clamp( w / self.hydrostaticFactorT, n1, m1 )
					end
					
					local hMin2 = Utils.clamp( wMin * r / self:getNextPossibleRpm( t + d, n0, m0 ), hMin, hMax )
					local hMax2 = Utils.clamp( wMax * r / self:getNextPossibleRpm( t - d, n0, m0 ), hMin, hMax )
					
					self.hydrostaticFactor = Utils.clamp( self.hydrostaticFactorT, hMin2, hMax2 )
					
					if gearboxMogli.debugGearShift then
						if self.hydrostaticFactor > gearboxMogli.eps then
							print(string.format("C: s: %6g w0: %6g w: %4d t: %4d h: %6g hT: %6g; %6g..%6g; %6g..%6g; %6g..%6g",
																	self.vehicle.lastSpeedReal * 1000 * gearboxMogli.factor30pi * self.vehicle.movingDirection,
																	w0,
																	w,
																	w/self.hydrostaticFactor,
																	self.hydrostaticFactor,
																	self.hydrostaticFactorT,
																	hMin,hMax,hMin1,hMax1,hMin2,hMax2))
						else
							print(string.format("D")) 
						end
					end
				end
				
				self.vehicle.mrGbML.afterShiftRpm = nil
				
				-- launch & clutch					
				local r = gearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbMS.CurrentGearSpeed )
				if     self.vehicle.mrGbMS.HydrostaticLaunch then
					clutchMode             = 0
					self.autoClutchPercent = self.vehicle.mrGbMS.MaxClutchPercent
				elseif self.hydrostaticFactor <= hMin0 then
					clutchMode             = 1
					self.hydrostaticFactor = hMin0 
				elseif self.autoClutchPercent + gearboxMogli.eps < 1 then
					clutchMode             = 1
					self.hydrostaticFactor = math.max( self.hydrostaticFactor, r / gearboxMogli.maxManualGearRatio )
				elseif self.hydrostaticFactor < r / gearboxMogli.maxManualGearRatio then
					-- open clutch to stop
					clutchMode             = 1
					self.hydrostaticFactor = r / gearboxMogli.maxManualGearRatio
				else				
					local smallestGearSpeed  = self.vehicle.mrGbMS.Gears[bestG].speed 
																	 * self.vehicle.mrGbMS.Ranges[1].ratio 
																	 * self.vehicle.mrGbMS.Ranges2[1].ratio
																	 * self.vehicle.mrGbMS.GlobalRatioFactor
																	 * hMin0
																	 * 3.6
					if self.vehicle.mrGbMS.ReverseActive then	
						smallestGearSpeed = smallestGearSpeed * self.vehicle.mrGbMS.ReverseRatio 
					end															 
					
					if currentAbsSpeed < smallestGearSpeed then
						clutchMode             = 1
					else
						clutchMode             = 0
						self.autoClutchPercent = self.vehicle.mrGbMS.MaxClutchPercent
						self.hydrostaticFactor = math.max( self.hydrostaticFactor, r / gearboxMogli.maxManualGearRatio )
					end			
				end			
				
				-- check static boundaries
				if     self.hydrostaticFactor > hMax then
					self.hydrostaticFactor = hMax
				elseif self.hydrostaticFactor < hMin then
					self.hydrostaticFactor = hMin
				end
				
	--**********************************************************************************************************		
	-- automatic shifting			
			elseif self.vehicle:mrGbMGetAutomatic() then		
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
				local upRpm     = math.max( self.vehicle.mrGbMS.RatedRpm, self.maxMaxPowerRpm )
							
				if self.vehicle.mrGbMS.AutoShiftDownRpm ~= nil and self.vehicle.mrGbMS.AutoShiftDownRpm > downRpm then
					downRpm = self.vehicle.mrGbMS.AutoShiftDownRpm
				end
				if self.vehicle.mrGbMS.AutoShiftUpRpm   ~= nil and self.vehicle.mrGbMS.AutoShiftUpRpm   < upRpm   then
					upRpm  = self.vehicle.mrGbMS.AutoShiftUpRpm
				end
				
				if self.ptoOn then
					upRpm   = Utils.clamp( self.minRequiredRpm + gearboxMogli.autoShiftRpmDiff, downRpm, upRpm )
					downRpm = Utils.clamp( math.max( self.minRequiredRpm - gearboxMogli.autoShiftRpmDiff, minRpmReduced ), downRpm, upRpm )
				end
				local rpmC = self.absWheelSpeedRpmS * gearboxMogli.gearSpeedToRatio( self.vehicle, self.vehicle.mrGbMS.CurrentGearSpeed )
				
				if self.vehicle.mrGbMS.TorqueConverter and downRpm <= self.vehicle.mrGbMS.ClutchMaxTargetRpm then
					downRpm = downRpm * self.vehicle.mrGbMS.MinClutchPercent
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
								p.timeToShiftMax = math.max( p.timeToShiftMax, self.vehicle.mrGbMS.GearTimeToShiftGear )
								p.timeToShiftSum = p.timeToShiftSum + self.vehicle.mrGbMS.GearTimeToShiftGear
								p.priority       = math.max( p.priority, self.vehicle.mrGbMS.AutoShiftPriorityG )
							end
							if p.range1 ~= self.vehicle.mrGbMS.CurrentRange then
								p.isCurrent      = false
								p.timeToShiftMax = math.max( p.timeToShiftMax, self.vehicle.mrGbMS.GearTimeToShiftHl )
								p.timeToShiftSum = p.timeToShiftSum + self.vehicle.mrGbMS.GearTimeToShiftHl
								p.priority       = math.max( p.priority, self.vehicle.mrGbMS.AutoShiftPriorityR )
							end
							if p.range2 ~= self.vehicle.mrGbMS.CurrentRange2 then
								p.isCurrent      = false
								p.timeToShiftMax = math.max( p.timeToShiftMax, self.vehicle.mrGbMS.GearTimeToShiftRanges2 )
								p.timeToShiftSum = p.timeToShiftSum + self.vehicle.mrGbMS.GearTimeToShiftRanges2								
								p.priority       = math.max( p.priority, self.vehicle.mrGbMS.AutoShiftPriority2 )
							end
							
							if p.priority == 1 and p.timeToShiftMax <= self.vehicle.mrGbMG.maxTimeToSkipGear then
								p.priority = 0
							end
							
						--if p.gearSpeed < self.vehicle.mrGbMS.LaunchGearSpeed - gearboxMogli.eps then
						----p.priority = math.max( p.priority, 3 )
						--	p.priority = p.priority + 3
						--end
							-- 0.6667 .. 1.3333 => 0
							-- < 0.5 or > 23    => 3
							p.plog     = math.min( math.max( 0, math.abs( math.log( p.gearSpeed / self.vehicle.mrGbMS.CurrentGearSpeed ) ) - 0.2877 ) * 7.4, 3 )
							p.plog     = 0.1 * math.floor( p.plog * 10 )
							p.priority = math.max( p.priority, p.plog )
							
							if minTimeToShift > p.timeToShiftMax then
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
				
				local dumpIt = string.format("%4.2f;; ",self.vehicle.mrGbMS.CurrentGearSpeed)
				for i,p in pairs( possibleCombinations ) do
					dumpIt = dumpIt .. string.format("%2d: %4.2f %4.2f %4.2f;; ",i,p.gearSpeed,p.plog,p.priority)
				end
				self.vehicle.mrGbDump = dumpIt 
				
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
				
				if      self.lastMotorRpm     > upRpm
						and self.lastRealMotorRpm > upRpm
						and self.clutchRpm        > upRpm then
					-- allow immediate up shift
					upTimerMode   = 0
				elseif  accelerationPedal                    < -gearboxMogli.accDeadZone
						and self.vehicle.mrGbMS.CurrentGearSpeed > self.vehicle.mrGbMS.LaunchGearSpeed then
					-- allow immediate down shift while braking
					downTimerMode = 0
				elseif  self.clutchOverheatTimer ~= nil
						and self.clutchPercent       < 0.9 
						and self.clutchOverheatTimer > 0.5 * self.vehicle.mrGbMS.ClutchOverheatStartTime then
					downTimerMode = 0
				elseif  self.clutchRpm           < downRpm then
					-- allow down shift after short timeout
					if self.vehicle.mrGbMS.CurrentGearSpeed > self.vehicle.mrGbMS.LaunchGearSpeed then
						downTimerMode = 0
					end
				elseif  self.vehicle.cruiseControl.state > 0 
						and self.vehicle.mrGbMS.CurrentGearSpeed * downRpm / self.vehicle.mrGbMS.RatedRpm > currentSpeedLimit then
					-- allow down shift after short timeout
				elseif self.vehicle.mrGbML.lastGearSpeed < self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
					downTimerMode = 2
				elseif self.vehicle.mrGbML.lastGearSpeed > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
					upTimerMode   = 2
				end		
				
				local sMin = nil
				local sMax = nil
				
				local bestScore = math.huge
				local bestGear  = -1
				local bestSpeed = gearboxMogli.eps
				
				local nextScore = math.huge
				local nextGear  = -1
				local nextSpeed = gearboxMogli.eps
				
				for i,p in pairs( possibleCombinations ) do
					p.score = math.huge
					p.rpmHi = self.absWheelSpeedRpmS * gearboxMogli.gearSpeedToRatio( self.vehicle, p.gearSpeed )
					p.rpmLo = p.rpmHi					
					--**********************************************************************************--
					-- estimate speed lost: 5.4 km/h lost at wheelLoad above 50 kNm for every 800 ms					
					if p.timeToShiftMax > 0 and p.gearSpeed > 0 and self.maxMotorTorque > 0 and p.rpmHi <= upRpm then
						-- rpmLo can become negative !!!
						p.rpmLo = p.rpmHi - p.timeToShiftMax * 0.00125 * Utils.clamp( self.wheelLoadS * 0.02, 0, 1 ) * self.vehicle.mrGbMS.RatedRpm / p.gearSpeed
						
						p.rpmLo = math.max( 0.5 * p.rpmHi, p.rpmLo )
					--if p.rpmHi >= downRpm and p.rpmLo < downRpm then p.rpmLo = downRpm end						
					end
									
					local isValidEntry = true
					
					if      downRpm                   <= rpmC and rpmC <= upRpm
							and p.rpmLo + gearboxMogli.eps < rpmC and rpmC < p.rpmHi - gearboxMogli.eps
							and p.timeToShiftMax           > self.vehicle.mrGbMG.maxTimeToSkipGear then
						-- the current gear is still valid => keep it
						p.priority = math.max( p.priority, 8 )
					elseif p.rpmHi < rpmC and rpmC < downRpm then
						-- the current gear is better than the new onw
						p.priority = math.max( p.priority, 9 )
					elseif p.rpmHi > rpmC and rpmC > upRpm   then
						-- the current gear is better than the new onw
						p.priority = math.max( p.priority, 9 )
					end
					
					if      self.vehicle.mrGbML.DirectionChangeTime ~= nil
							and g_currentMission.time  < self.vehicle.mrGbML.DirectionChangeTime + 2000
							and p.gearSpeed            < self.vehicle.mrGbMS.LaunchGearSpeed - gearboxMogli.eps 
							and p.gearSpeed            < self.vehicle.mrGbMS.CurrentGearSpeed then
						isValidEntry = false
					end
					
					-- no down shift if just idling  
					if      accelerationPedal      < gearboxMogli.accDeadZone
							and downTimerMode          > 1
							and p.gearSpeed            < self.vehicle.mrGbMS.LaunchGearSpeed - gearboxMogli.eps 
							and p.gearSpeed            < self.vehicle.mrGbMS.CurrentGearSpeed
							and self.stallWarningTimer == nil 
							then
					--isValidEntry = false
						p.priority = math.max( p.priority, 6.5 )
					end
						
					if p.gearSpeed < self.vehicle.mrGbMG.minAutoGearSpeed then
					--p.priority = 10
						isValidEntry = false
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
						if      self.deltaRpm < -gearboxMogli.autoShiftMaxDeltaRpm
								and p.gearSpeed   > self.vehicle.mrGbMS.CurrentGearSpeed + gearboxMogli.eps then
							isValidEntry = false
						elseif  self.deltaRpm > gearboxMogli.autoShiftMaxDeltaRpm
								and p.gearSpeed   < self.vehicle.mrGbMS.CurrentGearSpeed - gearboxMogli.eps then
							isValidEntry = false
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
							autoShiftTimeout = math.min( downTimerMode, upTimerMode )
						end
						
						if autoShiftTimeout > 0 then
							if     autoShiftTimeout >= 2 then
								autoShiftTimeout = self.lastClutchClosedTime + self.vehicle.mrGbMS.AutoShiftTimeoutLong
							else
								autoShiftTimeout = self.lastClutchClosedTime + self.vehicle.mrGbMS.AutoShiftTimeoutShort 
							end
							if     autoShiftTimeout + minTimeToShift   > g_currentMission.time then
								isValidEntry = false
							elseif autoShiftTimeout + p.timeToShiftSum > g_currentMission.time then
								p.priority = math.max( p.priority, 7 )
							end
						end
					end
					
					if isValidEntry or self.vehicle.mrGbMG.debugPrint or gearboxMogli.debugGearShift or self.vehicle.mrGbML.autoShiftInfoPrint then
            local testRpm
						
						testRpm = self:getRpmScore( p.rpmHi, downRpm, upRpm )
						if     testRpm < 1 and p.rpmLo < p.rpmHi then
							testRpm = 0.5 * ( testRpm + self:getRpmScore( p.rpmLo, downRpm, upRpm ) )
						end

						local t1, t2 = 0, 0
						if self.vehicle.mrGbMS.CurMinRpm <= p.rpmHi and p.rpmHi <= self.vehicle.mrGbMS.CurMaxRpm then
							t1 = self.currentTorqueCurve:get( p.rpmHi ) * gearboxMogli.autoShiftPowerRatio
						end
						if     p.rpmLo >= p.rpmHi then
							t2 = t1
						elseif self.vehicle.mrGbMS.CurMinRpm <= p.rpmLo and p.rpmLo <= self.vehicle.mrGbMS.CurMaxRpm then
							t2 = self.currentTorqueCurve:get( p.rpmLo ) * gearboxMogli.autoShiftPowerRatio
						end		
					
						local testPwr = Utils.clamp( ( self.requestedPower - 0.8 * p.rpmHi * t1 ) / self.currentMaxPower, 0, 1 )
					
						if p.rpmLo < p.rpmHi then
							testPwr = 0.5 * ( testPwr + Utils.clamp( ( self.requestedPower - 0.8 * p.rpmLo * t2 ) / self.currentMaxPower, 0, 1 ) )
						end
						
						if     testRpm > 0 then
						-- reach RPM window
							p.score = 3 + testRpm
					--	p.score = 2 + 0.1 * math.min( p.priority, 10 ) + 0.01 * testRpm 
						elseif testPwr > 0 then
						-- and optimize power afterwards
						--p.score = 2 + testPwr
							p.score = 2 + 0.1 * math.min( p.priority, 10 ) + 0.01 * testPwr
						elseif p.priority > 0 then
						-- sort by priority 
							p.score = 1 + 0.1 * math.min( p.priority, 10 )
						else
						-- optimize fuel usage ratio
							p.score = Utils.clamp( 0.001 * self.fuelCurve:get( p.rpmHi ), 0, 0.4 )
							if p.rpmLo < p.rpmHi then
								p.score = math.max( p.score, Utils.clamp( 0.001 * self.fuelCurve:get( p.rpmLo ), 0, 0.4 ) )
						--elseif not p.isCurrent and self.motorLoadS > 0.3 then
						--	p.score = p.score * ( 1 + 0.14 * ( self.motorLoadS - 0.3 ) )
							end
						end
					end
					
					if isValidEntry then
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
						
						if not p.isCurrent then
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
								
				self.vehicle.mrGbML.autoShiftInfo = string.format("%4d / %4d / %4d..%4d\nB: %6.3f %2d %5.2f\nN: %6.3f %2d %5.2f",
																													rpmC,
																													self.lastRealMotorRpm,
																													downRpm,
																													upRpm,
																													Utils.getNoNil( bestScore, -1 ),
																													Utils.getNoNil( bestGear,  -1 ),
																													Utils.getNoNil( bestSpeed, -1 ),
																													Utils.getNoNil( nextScore, -1 ),
																													Utils.getNoNil( nextGear,  -1 ),
																													Utils.getNoNil( nextSpeed, -1 ) )
				
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
	end
	
	--**********************************************************************************************************		
	-- clutch			
	
	if clutchMode > 0 and not ( self.noTransmission ) then
		if self.vehicle:mrGbMGetAutoClutch() or self.vehicle.mrGbMS.TorqueConverter then
			local openRpm   = self.vehicle.mrGbMS.OpenRpm  + self.vehicle.mrGbMS.ClutchRpmShift * math.max( 1.4*self.motorLoadS - 0.4, 0 )
			local closeRpm  = self.vehicle.mrGbMS.CloseRpm + self.vehicle.mrGbMS.ClutchRpmShift * math.max( 1.4*self.motorLoadS - 0.4, 0 ) 
			local targetRpm = self.targetRpm
			
			if     clutchMode > 1 then
				openRpm        = self.vehicle.mrGbMS.RatedRpm 
				closeRpm       = self.vehicle.mrGbMS.RatedRpm 
				if self.vehicle.mrGbML.afterShiftRpm ~= nil and not ( self.vehicle.mrGbMS.TorqueConverter ) then
					targetRpm = math.max( self.minRequiredRpm, self.vehicle.mrGbML.afterShiftRpm )
				end
				self.torqueConverterLockupMs = nil
			elseif self.vehicle.mrGbMS.TorqueConverter and not self.ptoOn then
				-- reduce close RPM depending on motor load
				local refRpm   = math.max( self.lastMotorRpm, minRpmReduced )
			
				if self.vehicle.mrGbMS.CloseRpm > refRpm then
					closeRpm = refRpm + self.motorLoadS * ( self.vehicle.mrGbMS.CloseRpm - refRpm )
				end							
			elseif self.vehicle.mrGbMS.Hydrostatic then
				openRpm         = self.vehicle.mrGbMS.CurMaxRpm
				closeRpm        = math.min( self.vehicle.mrGbMS.CurMaxRpm, self.targetRpm + gearboxMogli.hydroEffDiff )
				if self.vehicle.mrGbMS.AutoShiftUpRpm ~= nil and closeRpm > self.vehicle.mrGbMS.AutoShiftUpRpm then
					closeRpm = self.vehicle.mrGbMS.AutoShiftUpRpm 
				end
				if closeRpm > self.vehicle.mrGbMS.HydrostaticMaxRpm then
					closeRpm = self.vehicle.mrGbMS.HydrostaticMaxRpm
				end		
			end
			
			if      self.vehicle.mrGbMS.TorqueConverter 
					and self.vehicle.mrGbMS.TorqueConverterLockupMs ~= nil 
					and ( getMaxPower or self.ptoOn ) then
				openRpm = math.max( openRpm, closeRpm )
			end
			
			local fromClutchPercent   = self.vehicle.mrGbMS.MinClutchPercent
			local toClutchPercent     = self.vehicle.mrGbMS.MaxClutchPercent

			if      clutchMode > 1 
					and self.vehicle.mrGbML.afterShiftClutch ~= nil then
				if self.vehicle.mrGbML.afterShiftClutch < 0 then
					self.autoClutchPercent = self:getClutchPercent( targetRpm, openRpm, closeRpm, fromClutchPercent, toClutchPercent )
				else
					self.autoClutchPercent = self.vehicle.mrGbML.afterShiftClutch
				end
			elseif  self.vehicle.mrGbMS.TorqueConverter
			    and self.torqueConverterLockupMs ~= nil
			    and self.torqueConverterLockupMs < g_currentMission.time
					and self.clutchRpm                > openRpm then
				self.autoClutchPercent = 1
			else
				-- timer for torque converter lockup clutch
				if      self.vehicle.mrGbMS.TorqueConverter
						and self.vehicle.mrGbMS.TorqueConverterLockupMs ~= nil 
						and ( self.clutchRpm < self.vehicle.mrGbMS.CloseRpm
							 or self.torqueConverterLockupMs == nil ) then
					self.torqueConverterLockupMs = g_currentMission.time + self.vehicle.mrGbMS.TorqueConverterLockupMs
				end

				self.autoClutchPercent = Utils.clamp( self.autoClutchPercent, 0, self.vehicle.mrGbMS.MaxClutchPercent )
				
				if clutchMode <= 1 then
					if self.nonClampedMotorRpm > self.vehicle.mrGbMS.CurMinRpm and self.tickDt < self.vehicle.mrGbMS.ClutchTimeDec then
						fromClutchPercent = math.max( fromClutchPercent, self.autoClutchPercent - self.tickDt/self.vehicle.mrGbMS.ClutchTimeDec )
					end
					local timeInc = self.vehicle.mrGbMS.ClutchShiftTime
					if self.clutchRpm < closeRpm then
						timeInc = self.vehicle.mrGbMS.ClutchTimeInc
					end
					if self.tickDt < timeInc then
						toClutchPercent = math.min( toClutchPercent, self.autoClutchPercent + self.tickDt/timeInc )
					end
				end
				
				local c = self:getClutchPercent( targetRpm, openRpm, closeRpm, fromClutchPercent, toClutchPercent )
				
				if self.vehicle.mrGbML.debugTimer ~= nil and g_currentMission.time < self.vehicle.mrGbML.debugTimer then
					print(string.format("Clutch mode %d: %3.0f%% => %3.0f%% o: %4.0f U/min c: %4.0f U/min / %3.0f%% .. %3.0f%%",
					                    clutchMode,
															self.autoClutchPercent*100,
															c*100,
															openRpm,
															closeRpm,
															fromClutchPercent*100,
															toClutchPercent*100 ))
				end
				
				self.autoClutchPercent = c
			end
			
		else
			self.autoClutchPercent   = self.vehicle.mrGbMS.MaxClutchPercent
		end 		
	else
		self.torqueConverterLockupMs = nil
	end 					
	
	local lastStallWarningTimer = self.stallWarningTimer
	self.stallWarningTimer = nil
	
	if     self.noTransmission then
		self.clutchPercent = 0
	elseif self.vehicle:mrGbMGetAutoClutch() or self.vehicle.mrGbMS.TorqueConverterOrHydro then
		self.clutchPercent = math.min( self.autoClutchPercent, self.vehicle.mrGbMS.ManualClutch )
		
		if not ( self.noTransmission ) and self.vehicle.mrGbML.debugTimer ~= nil and g_currentMission.time < self.vehicle.mrGbML.debugTimer and self.autoClutchPercent < self.vehicle.mrGbMS.MaxClutchPercent then
			self.vehicle.mrGbML.debugTimer = math.max( g_currentMission.time + 200, self.vehicle.mrGbML.debugTimer )
		end
	else
	--local minRpm = math.min( 100, 0.5 * self.vehicle.mrGbMS.CurMinRpm ) --math.max( 0.5 * self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.CurMinRpm - 100 )
		local minRpm = math.max( 0.5 * self.vehicle.mrGbMS.CurMinRpm, self.vehicle.mrGbMS.CurMinRpm - 100 )
		if not ( self.noTransmission ) and self.vehicle.mrGbMS.ManualClutch > self.vehicle.mrGbMS.MinClutchPercent and self.nonClampedMotorRpm < minRpm then
			if lastStallWarningTimer == nil then
				self.stallWarningTimer = g_currentMission.time
			else
				self.stallWarningTimer = lastStallWarningTimer
				if     g_currentMission.time > self.stallWarningTimer + self.vehicle.mrGbMG.stallMotorOffTime then
					self.stallWarningTimer = nil
					self:motorStall( string.format("Motor stopped because RPM too low: %4.0f < %4.0f", self.nonClampedMotorRpm, minRpm ),
													 string.format("RPM is too low: %4.0f < %4.0f", self.nonClampedMotorRpm, minRpm ) )
				elseif g_currentMission.time > self.stallWarningTimer + self.vehicle.mrGbMG.stallWarningTime then
					self.vehicle:mrGbMSetState( "WarningText", string.format("RPM is too low: %4.0f < %4.0f", self.nonClampedMotorRpm, minRpm ))
				end		
			end		
		end
		
		self.clutchPercent = self.vehicle.mrGbMS.ManualClutch
	end
	
	
	--**********************************************************************************************************		
	-- no transmission => min throttle 
	if self.noTorque       then
		self.lastThrottle   = 0
		accelerationPedal   = 0
	end
	if self.clutchPercent < gearboxMogli.minClutchPercent then
		self.noTransmission = true
	end
	if self.noTransmission then
		self.minThrottle    = 0
	--if self.lastRealMotorRpm < self.minRequiredRpm + 10 then
	--	self.minThrottle  = self.vehicle.mrGbMS.IdleEnrichment
	--end		
		self.minThrottle = self.vehicle.mrGbMS.IdleEnrichment + math.max( 0, handThrottle ) * ( 1 - self.vehicle.mrGbMS.IdleEnrichment )
		if     self.lastRealMotorRpm < self.minRequiredRpm - 1 then
			self.minThrottle = 1
		elseif self.lastRealMotorRpm > self.minRequiredRpm + 1 then
			self.minThrottle = 0
		end
		self.minThrottleS   = Utils.clamp( self.minThrottleS + 0.1 * ( self.minThrottle - self.minThrottleS ), 0, 1 )
		self.minThrottle    = self.minThrottleS
		
		if self.noTorque then
			self.lastThrottle = 0
		elseif self.vehicle:mrGbMGetOnlyHandThrottle() then
			self.lastThrottle = self.vehicle.mrGbMS.HandThrottle
		else
			self.lastThrottle = math.max( self.vehicle.mrGbMS.HandThrottle, accelerationPedal )
		end
		local f = 1
		if self.vehicle.mrGbML.gearShiftingNeeded > 0 then
			f = 2
		end
		if self.lastThrottle > 0 and self.lastThrottle > ( self.lastMotorRpm / self.maxRpm )  then
			self.lastMotorRpm  = Utils.clamp( self.lastMotorRpm + f * self.lastThrottle * self.tickDt * self.vehicle.mrGbMS.RpmIncFactor, 
																			 self.minRequiredRpm, 
																			 self:getThrottleMaxRpm( ) )
		else
			self.lastMotorRpm  = Utils.clamp( self.lastMotorRpm - self.tickDt * self.vehicle.mrGbMS.RpmDecFactor, self.minRequiredRpm, self.vehicle.mrGbMS.CurMaxRpm )
		end	
		self.lastThrottle   = math.max( self.minThrottle, self.lastThrottle )	
	end	
	
	--**********************************************************************************************************		
	-- timer for automatic shifting				
	if      self.noTransmission then
		self.lastClutchClosedTime = g_currentMission.time + self.vehicle.mrGbMS.AutoShiftTimeoutShort
		self.hydrostaticStartTime = nil
		self.deltaRpm = 0
	elseif  self.lastClutchClosedTime            > g_currentMission.time 
			and self.clutchPercent                  >= self.vehicle.mrGbMS.MaxClutchPercent - gearboxMogli.eps then
		-- cluch closed => "start" the timer
		self.lastClutchClosedTime = g_currentMission.time 
	elseif  accelerationPedal                    < gearboxMogli.accDeadZone
			and self.vehicle.mrGbMS.CurrentGearSpeed < self.vehicle.mrGbMS.LaunchGearSpeed - gearboxMogli.eps 
			and self.clutchPercent                  >= self.vehicle.mrGbMS.MaxClutchPercent - gearboxMogli.eps
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
				local w = "Clutch is overheating"
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
	if self.noTransmission then
		self.maxPossibleRpm = gearboxMogli.huge
		self.lastMaxRpmTab  = nil
		self.rpmIncFactor   = self.vehicle.mrGbMS.RpmIncFactor
	elseif self.lastMissingTorque > 0 then
		self.maxPossibleRpm = self.vehicle.mrGbMS.CurMaxRpm
		self.lastMaxRpmTab  = nil
		self.rpmIncFactor   = self.vehicle.mrGbMS.RpmIncFactorFull
	else
		local tab = nil
		if self.lastMaxRpmTab == nil then
		--tab = nil
		elseif lastNoTransmission then
		--tab = nil
		else
			tab = self.lastMaxRpmTab
		end
		
		local m 
		if type( self.lastRealMotorRpm ) == "number" then
			m = self.lastRealMotorRpm
		else
			print( 'ERROR in gearboxMogli.lua(7838): type( self.lastRealMotorRpm ) ~= "number"' )
			m = self.nonClampedMotorRpm
		end
		if m < self.vehicle.mrGbMS.IdleRpm then
			m = self.vehicle.mrGbMS.IdleRpm
		end
		
		self.lastMaxRpmTab = {}
		table.insert( self.lastMaxRpmTab, { t = 0, m = m } )
				
		if tab ~= nil then
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
		if      self.vehicle.mrGbMS.Hydrostatic
				and self.maxPossibleRpm > self.vehicle.mrGbMS.HydrostaticMaxRpm then
			self.maxPossibleRpm = self.vehicle.mrGbMS.HydrostaticMaxRpm
		end
		
		if self.vehicle.mrGbML.afterShiftRpm ~= nil then -- and self.vehicle.mrGbML.gearShiftingEffect then
			if self.maxPossibleRpm > self.vehicle.mrGbML.afterShiftRpm then
				self.maxPossibleRpm               = self.vehicle.mrGbML.afterShiftRpm
				self.vehicle.mrGbML.afterShiftRpm = self.vehicle.mrGbML.afterShiftRpm + self.maxRpmIncrease 
			else
				self.vehicle.mrGbML.afterShiftRpm = nil
			end
		end
	end
	
	if self.vehicle.mrGbML.afterShiftRpm ~= nil and self.vehicle.mrGbML.gearShiftingEffect and not self.noTransmission then 
		self.lastMotorRpm = self.vehicle.mrGbML.afterShiftRpm
		self.vehicle.mrGbML.gearShiftingEffect = false
	end
	
	--**********************************************************************************************************		
	-- do not cut torque in case of open clutch or torque converter
	if self.clutchPercent < 1 and self.maxPossibleRpm < self.vehicle.mrGbMS.CloseRpm then
		self.maxPossibleRpm = self.vehicle.mrGbMS.CloseRpm
	end	
	
	--**********************************************************************************************************		
	-- reduce RPM if more power than available is requested 
	local reductionMinRpm = self.vehicle.mrGbMS.CurMinRpm 
	if     currentAbsSpeed < 1 then
		reductionMinRpm = self.vehicle.mrGbMS.CurMaxRpm 
	elseif currentAbsSpeed < 2 then
		reductionMinRpm = self.vehicle.mrGbMS.CurMaxRpm + ( currentAbsSpeed - 1 ) * ( self.vehicle.mrGbMS.CurMinRpm - self.vehicle.mrGbMS.CurMaxRpm )
	end
	
	if      self.lastMissingTorque  > 0 
			and self.nonClampedMotorRpm > reductionMinRpm
			and not ( self.noTransmission ) then
		if self.torqueRpmReduction == nil then
			self.torqueRpmReference = self.nonClampedMotorRpm
			self.torqueRpmReduction = 0
		end
		local m = self.vehicle.mrGbMS.CurMinRpm
		self.torqueRpmReduction   = math.min( self.nonClampedMotorRpm - reductionMinRpm, self.torqueRpmReduction + math.min( 0.2, self.lastMissingTorque / self.lastMotorTorque ) * self.tickDt * self.vehicle.mrGbMS.RpmDecFactor )
	elseif  self.torqueRpmReduction ~= nil then
		self.torqueRpmReduction = self.torqueRpmReduction - self.tickDt * self.rpmIncFactor 
		if self.torqueRpmReduction < 0 then
			self.torqueRpmReference = nil
			self.torqueRpmReduction = nil
		end
	end
	if self.torqueRpmReduction ~= nil and not self.vehicle.mrGbMS.Hydrostatic then
		self.maxPossibleRpm = Utils.clamp( self.torqueRpmReference - self.torqueRpmReduction, self.vehicle.mrGbMS.CurMinRpm, self.maxPossibleRpm )
	end
	
	self.lastThrottle = math.max( self.minThrottle, accelerationPedal )
	
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
		return self:getThrottleRpm()
	end
	local c = self.clutchPercent
	if type( cIn ) == "number" then
		c = cIn
	end
	return c * self.clutchRpm + ( 1-c ) * self:getThrottleRpm()
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getThrottleRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getThrottleRpm( )
	return math.max( self.minRequiredRpm, self.vehicle.mrGbMS.IdleRpm + self.lastThrottle * ( self.vehicle.mrGbMS.CurMaxRpm - self.vehicle.mrGbMS.IdleRpm ) )
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getThrottleRpm
--**********************************************************************************************************	
function gearboxMogliMotor:getThrottleMaxRpm( acc )
	if acc == nil then acc = self.lastThrottle end
	return math.max( self.minRequiredRpm, self.vehicle.mrGbMS.IdleRpm + acc * math.max( 0, math.max( self.maxMaxPowerRpm, self.vehicle.mrGbMS.RatedRpm ) - self.vehicle.mrGbMS.IdleRpm ) )
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
function gearboxMogliMotor:getClutchPercent( targetRpm, openRpm, closeRpm, fromPercent, toPercent )

	if fromPercent ~= nil and toPercent ~= nil and fromPercent >= toPercent then
		return fromPercent
	end
	if closeRpm <= self.clutchRpm and self.clutchRpm <= self.vehicle.mrGbMS.CurMaxRpm then
		return Utils.getNoNil( toPercent, self.vehicle.mrGbMS.MaxClutchPercent )
	end
	if self.lastRealMotorRpm < self.vehicle.mrGbMS.CurMinRpm and self.vehicle.mrGbMS.CurMinRpm < openRpm then
		return Utils.getNoNil( fromPercent, self.vehicle.mrGbMS.MinClutchPercent )
	end	
	
	local minPercent    = self.vehicle.mrGbMS.MinClutchPercent + Utils.clamp( 0.5 + 0.02 * ( self.lastRealMotorRpm - openRpm ), 0, 1 ) * math.max( 0, self.autoClutchPercent - self.vehicle.mrGbMS.MinClutchPercent )
	local maxPercent    = self.vehicle.mrGbMS.MaxClutchPercent		
	
	if fromPercent ~= nil and minPercent < fromPercent then
		minPercent        = fromPercent
	end
	if toPercent   ~= nil and maxPercent > toPercent   then
		maxPercent        = toPercent 
	end
	
	if minPercent + gearboxMogli.eps > maxPercent then
		return minPercent 
	end
	
	local target        = math.min( targetRpm, self.vehicle.mrGbMS.ClutchMaxTargetRpm )
	local throttle      = self:getThrottleRpm()
	
	local eps           = maxPercent - minPercent
	local delta         = ( throttle - math.max( self.clutchRpm, 0 ) ) * eps
	
	local times         = math.max( gearboxMogli.clutchLoopTimes, math.ceil( delta / gearboxMogli.clutchLoopDelta ) )
	delta = delta / times 
	eps   = eps   / times 
	
	local clutchRpm     = maxPercent * math.max( self.clutchRpm, 0 ) + ( 1 - maxPercent ) * throttle
	local clutchPercent = maxPercent
	local diff, diffi, rpm
	
	for i=0,times do
		clutchRpm = clutchRpm + delta
		diffi     = math.abs( target - clutchRpm )
		if diff == nil or diff > diffi then
			diff = diffi
			clutchPercent = maxPercent - i * eps
		end
	end
	
	if      gearboxMogli.debugGearShift
			and self.autoClutchPercent < self.vehicle.mrGbMS.MaxClutchPercent
			and fromPercent ~= nil
			and toPercent   ~= nil then
		print(string.format("Clutch: cur: %4.0f tar: %4.0f opn: %4.0f cls: %4.0f rg: %1.3f .. %1.3f => tar: %4.0f thr: %4.0f whl: %4.0f => mo %4.0f clu %4.0f diffi %4.0f => %1.3f (%4.4f %4.4f)",
												self.lastRealMotorRpm, targetRpm, openRpm, closeRpm,
												fromPercent, toPercent,
												target, throttle, self.clutchRpm, self:getMotorRpm(),
												clutchRpm, diff, clutchPercent, eps, delta ) )
	end 
	
	return clutchPercent 
end

--**********************************************************************************************************	
-- gearboxMogliMotor:getRpmScore
--**********************************************************************************************************	
function gearboxMogliMotor:getRpmScore( rpm, downRpm, upRpm ) 

	local f = downRpm-1000
	local t = upRpm  +1000

	if downRpm <= rpm and rpm <= upRpm then
		return 0
	elseif rpm <= f
	    or rpm >= t then
		return 1
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
function gearboxMogliMotor:getRotInertia()
	local r = 0.001 * self.vehicle.mrGbMS.MomentOfInertia 
	if self.noTransmission then
		r = 0
	elseif self.ratioFactorR == nil then
		r = 0
	elseif self.ratioFactorR  > 1 then
		r = r / self.ratioFactorR
	elseif self.clutchPercent < 1 then
		r = self.clutchPercent * r
	end
	return math.max( self.vehicle.mrGbMG.momentOfInertiaMin, r )
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

--**********************************************************************************************************	
-- gearboxMogli:afterLoadMotor
--**********************************************************************************************************	
function gearboxMogli:afterLoadMotor(xmlFile)
	if self.mrGbML ~= nil then 
		self.mrGbML.motor = nil
	end
end

--**********************************************************************************************************	
-- gearboxMogli:newGetLastSpeed
--**********************************************************************************************************	
function gearboxMogli:newGetLastSpeed( superFunc, ... )
	if  	 self.mrGbMS == nil 
			or self.mrGbML == nil 
			or self.mrGbML.smoothFast == nil
			or not ( self.mrGbMS.IsOn ) then	
		return superFunc( self, ... )
	end
	
	local speed = superFunc( self, ... )
	if self.mrGbML.lastSpeed == nil then
		self.mrGbML.lastSpeed = speed
	elseif self.isServer then
		self.mrGbML.lastSpeed = self.mrGbML.lastSpeed + self.mrGbML.smoothFast * ( speed - self.mrGbML.lastSpeed )
	else
		self.mrGbML.lastSpeed = self.mrGbML.lastSpeed + self.mrGbML.smoothSlow * ( speed - self.mrGbML.lastSpeed )
	end
	
	return self.mrGbML.lastSpeed
end	

--**********************************************************************************************************	
-- gearboxMogli:newSetHudValue
--**********************************************************************************************************	
function gearboxMogli:newSetHudValue( superFunc, hud, value, maxValue, ... )
	if     self.mrGbMS        == nil 
			or self.mrGbMB        == nil 
			or not ( self.isMotorStarted )
			or not ( self.mrGbMS.IsOn ) 
			or self.mrGbMB.motor  == nil then
		return superFunc( self, hud, value, maxValue, ... )
	elseif self.motor.updateMotorRpm == nil or self.motor.updateMotorRpm ~= gearboxMogliMotor.updateMotorRpm then
		return superFunc( self, hud, value, maxValue, ... )
	elseif  self.rpmHud   ~= nil
			and self.rpmHud   == hud then
	elseif  self.speedHud ~= nil
			and self.speedHud == hud then
	else
		return superFunc( self, hud, value, maxValue, ... )
	end

	if value < 0 then
		value = 0
	end
	
	for _,hudItem in pairs(hud) do
		if hudItem.numbers ~= nil then
			if hudItem.lastValue == nil or math.abs(hudItem.lastValue-value) > 1/(10^(hudItem.precision+1)) then
				local displayedValue
				
				if self.rpmHud   == hud then
					displayedValue = self:mrGbMGetCurrentRPM()
				else
					displayedValue = value
				end
				
				if hudItem.maxValue ~= nil then
					displayedValue = math.min( displayedValue, hudItem.maxValue )
				end
				
				local speed = tonumber(string.format("%."..hudItem.precision.."f", displayedValue));
				Utils.setNumberShaderByValue(hudItem.numbers, speed, hudItem.precision, true);
				hudItem.lastValue = value;
			end;
		end;
		
		if hudItem.animName ~= nil then
			local displayedValue = value
			local normValue = 0

			if self.speedHud == hud then
				maxValue = g_i18n:getSpeed(Utils.getNoNil(self.mrGbMB.cruiseControlMaxSpeed,30))
			end
			
			local minValueAnim = Utils.getNoNil( hudItem.minValueAnim, 0 )
			local maxValueAnim = Utils.getNoNil( hudItem.maxValueAnim, maxValue )
			
			if self.rpmHud == hud or ( self.speedHud == hud and self.mrGbMS.RpmInSpeedHud ) then
				displayedValue = self:mrGbMGetCurrentRPM()
				
				if self.speedHud == hud then
					minValueAnim = gearboxMogli.minRpmInSpeedHudDelta
					maxValueAnim = gearboxMogli.maxRpmInSpeedHudDelta
				end
			
				if self.mrGbMS.MinHudRpm ~= nil then
					minValueAnim = self.mrGbMS.MinHudRpm
				end
				if self.mrGbMS.MaxHudRpm ~= nil then
					maxValueAnim = self.mrGbMS.MaxHudRpm
				end
			end
			
			if maxValueAnim  <= minValueAnim or displayedValue <= minValueAnim then
				normValue = 0
			elseif displayedValue >= maxValueAnim then
				normValue = 1
			else
				normValue = Utils.round((displayedValue-minValueAnim)/(maxValueAnim-minValueAnim), 3)
			end		
			
			if hudItem.lastNormValue == nil or math.abs(hudItem.lastNormValue - normValue) > 0.01 then
				self:setAnimationTime(hudItem.animName, normValue, true);
				hudItem.lastNormValue = normValue;
			end;
		end
	end
end
	
--**********************************************************************************************************			
-- fuel usage
--**********************************************************************************************************			
function gearboxMogli:newUpdateFuelUsage(origFunc, superFunc, dt)
	if  	 self.mrGbMS          == nil 
			or self.motor           == nil
			or self.motor.fuelCurve == nil
			or not ( self.mrGbMS.IsOn )
			or not ( self.mrGbMG.realFuelUsage ) then	
		return origFunc( self, superFunc, dt )
	end
	if superFunc ~= nil then
		if not superFunc(self, dt) then
			return false
		end
	end
	
	if self.isMotorStarted then		
		local rpm    = Utils.clamp( self.motor.prevMotorRpm, self.mrGbMS.CurMinRpm, self.motor.maxPossibleRpm )
		local torque = Utils.clamp( self.motor.usedTransTorque + self.motor.lastPtoTorque, 0, self.motor.lastMotorTorque )
		local power  = torque * rpm * gearboxMogli.powerFactor0 / ( 1.36 * self.mrGbMG.torqueFactor )
		local ratio  = self.motor.fuelCurve:get( rpm )			
		
		if self.motor.lastMotorTorque > 0 then
			ratio = ratio / math.max( 0.001, gearboxMogli.powerFuelCurve:get( torque / self.motor.lastMotorTorque ) )
		else
			ratio = 0
		end
		
		local fuelUsed  = ratio * power * dt * gearboxMogli.fuelFactor		
		if fuelUsed > 0 then
			if g_currentMission.missionInfo.fuelUsageLow then
				fuelUsed = fuelUsed * 0.7
			end
			
		--if self.mrGbML.checkFuelFillLevel ~= nil and self.fuelFillLevel ~= nil then
		--	print("Fuel used: "..tostring(fuelUsed).." ("..tostring(self.mrGbML.checkFuelFillLevel - self.fuelFillLevel)..")")
		--end
			
			if self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
				local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL)
				g_currentMission.missionStats:updateStats("expenses", delta);
				g_currentMission:addSharedMoney(-delta, "purchaseFuel");
			else
				self:setFuelFillLevel(self.fuelFillLevel-fuelUsed);
				g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed);
			end
			
			self.mrGbML.checkFuelFillLevel = self.fuelFillLevel
		end
		
		if self.fuelUsageHud ~= nil then
			VehicleHudUtils.setHudValue(self, self.fuelUsageHud, fuelUsed*1000/dt*60*60);
		end
	end
	
	return true
end
	
--**********************************************************************************************************			
-- Motorized:readUpdateStream
--**********************************************************************************************************			
function gearboxMogli:newReadUpdateStream( superFunc, streamId, timestamp, connection )
	if     self.mrGbMS        == nil 
			or self.mrGbMB        == nil 
			or not ( self.mrGbMS.IsOn ) 
			or self.mrGbMB.motor  == nil then
		return superFunc( self, streamId, timestamp, connection )
	end
	
	if connection.isServer then
		self.motor.lastMotorRpm   = self.mrGbMS.CurMinRpm + streamReadUIntN(streamId, 11) * ( self.mrGbMS.CurMaxRpm - self.mrGbMS.CurMinRpm ) / 2047;
		self.motor:setEqualizedMotorRpm( self:mrGbMGetEqualizedRpm( self.motor.lastMotorRpm ) )
		self.actualLoadPercentage = streamReadUIntN(streamId, 7) / 127

		if streamReadBool(streamId) then
			local fuelFillLevel = streamReadUIntN(streamId, 15)/32767*self.fuelCapacity;
			self:setFuelFillLevel(fuelFillLevel)
		end
	end
end	

--**********************************************************************************************************			
-- Motorized:writeUpdateStream
--**********************************************************************************************************			
function gearboxMogli:newWriteUpdateStream( superFunc, streamId, connection, dirtyMask )
	if     self.mrGbMS        == nil 
			or self.mrGbMB        == nil 
			or not ( self.mrGbMS.IsOn ) 
			or self.mrGbMB.motor  == nil then
		return superFunc( self, streamId, connection, dirtyMask )
	end

	if not connection.isServer then
		local rpm = ( self.motor.lastMotorRpm - self.mrGbMS.CurMinRpm ) / ( self.mrGbMS.CurMaxRpm - self.mrGbMS.CurMinRpm )
		
		streamWriteUIntN(streamId, Utils.clamp( math.floor( 0.5 + rpm * 2047), 0, 2047 ), 11);
		streamWriteUIntN(streamId, Utils.clamp( math.floor( 0.5 + self.actualLoadPercentage * 127 ), 0, 127 ), 7);

		if streamWriteBool(streamId, bitAND(dirtyMask, self.motorizedDirtyFlag) ~= 0) then
			local percent = 0;
			if self.fuelCapacity ~= 0 then
				percent = Utils.clamp(self.fuelFillLevel / self.fuelCapacity, 0, 1);
			end
			streamWriteUIntN(streamId, math.floor(percent*32767), 15);
		end
	end
end

--**********************************************************************************************************	
WheelsUtil.updateWheelsPhysics = Utils.overwrittenFunction( WheelsUtil.updateWheelsPhysics,gearboxMogli.newUpdateWheelsPhysics )
--Vehicle.getLastSpeed = Utils.overwrittenFunction( Vehicle.getLastSpeed, gearboxMogli.newGetLastSpeed )
VehicleHudUtils.setHudValue = Utils.overwrittenFunction( VehicleHudUtils.setHudValue, gearboxMogli.newSetHudValue )
Motorized.loadMotor = Utils.appendedFunction( Motorized.loadMotor, gearboxMogli.afterLoadMotor )
Motorized.updateFuelUsage = Utils.overwrittenFunction( Motorized.updateFuelUsage, gearboxMogli.newUpdateFuelUsage )
Motorized.readUpdateStream = Utils.overwrittenFunction( Motorized.readUpdateStream, gearboxMogli.newReadUpdateStream )
Motorized.writeUpdateStream = Utils.overwrittenFunction( Motorized.writeUpdateStream, gearboxMogli.newWriteUpdateStream )
--**********************************************************************************************************	

--oldClamp = Utils.clamp
--function Utils.clamp(value, minVal, maxVal)
--	if value == nil or minVal == nil or maxVal == nil then
--		gearboxMogli.debugEvent( nil, value, minVal, maxVal )
--		return 0
--	end
--	return oldClamp(value, minVal, maxVal)
--end


function gearboxMogli:mrGbMTestNet()
	local vehicle = self
	if g_currentMission ~= nil and g_currentMission.controlledVehicle ~= nil then
		vehicle = g_currentMission.controlledVehicle
	end
	
	gearboxMogli.mogliBaseTestStream( vehicle )
end

function gearboxMogli:mrGbMTestAPI()
	local vehicle = self
	if g_currentMission ~= nil and g_currentMission.controlledVehicle ~= nil then
		vehicle = g_currentMission.controlledVehicle
	end
	
	print("vehicle.mrGbMGetClutchPercent        : "..tostring(vehicle:mrGbMGetClutchPercent())) 
	print("vehicle.mrGbMGetAutoClutchPercent    : "..tostring(vehicle:mrGbMGetAutoClutchPercent())) 
	print("vehicle.mrGbMGetCurrentRPM           : "..tostring(vehicle:mrGbMGetCurrentRPM())) 
	print("vehicle.mrGbMGetTargetRPM            : "..tostring(vehicle:mrGbMGetTargetRPM())) 
	print("vehicle.mrGbMGetMotorLoad            : "..tostring(vehicle:mrGbMGetMotorLoad())) 
	print("vehicle.mrGbMGetUsedPower            : "..tostring(vehicle:mrGbMGetUsedPower())) 
	print("vehicle.mrGbMGetModeText             : "..tostring(vehicle:mrGbMGetModeText())) 
	print("vehicle.mrGbMGetModeShortText        : "..tostring(vehicle:mrGbMGetModeShortText())) 
	print("vehicle.mrGbMGetGearText             : "..tostring(vehicle:mrGbMGetGearText())) 
	print("vehicle.mrGbMGetIsOn                 : "..tostring(vehicle:mrGbMGetIsOn())) 
                                              
	print("vehicle.mrGbMGetIsOnOff              : "..tostring(vehicle:mrGbMGetIsOnOff())) 
	print("vehicle.mrGbMGetCurrentGear          : "..tostring(vehicle:mrGbMGetCurrentGear())) 
	print("vehicle.mrGbMGetGearSpeed            : "..tostring(vehicle:mrGbMGetGearSpeed())) 
	print("vehicle.mrGbMGetGearNumber           : "..tostring(vehicle:mrGbMGetGearNumber())) 
	print("vehicle.mrGbMGetCurrentRange         : "..tostring(vehicle:mrGbMGetCurrentRange())) 
	print("vehicle.mrGbMGetRangeNumber          : "..tostring(vehicle:mrGbMGetRangeNumber())) 
	print("vehicle.mrGbMGetCurrentRange2        : "..tostring(vehicle:mrGbMGetCurrentRange2())) 
	print("vehicle.mrGbMGetRange2Number         : "..tostring(vehicle:mrGbMGetRange2Number())) 
	print("vehicle.mrGbMGetAutomatic            : "..tostring(vehicle:mrGbMGetAutomatic())) 
	print("vehicle.mrGbMGetAutoStartStop        : "..tostring(vehicle:mrGbMGetAutoStartStop())) 
	print("vehicle.mrGbMGetNeutralActive        : "..tostring(vehicle:mrGbMGetNeutralActive())) 
	print("vehicle.mrGbMGetReverseActive        : "..tostring(vehicle:mrGbMGetReverseActive())) 
	print("vehicle.mrGbMGetSpeedLimiter         : "..tostring(vehicle:mrGbMGetSpeedLimiter())) 
	print("vehicle.mrGbMGetHandThrottle         : "..tostring(vehicle:mrGbMGetHandThrottle())) 
	print("vehicle.mrGbMGetAutoClutch           : "..tostring(vehicle:mrGbMGetAutoClutch())) 
	print("vehicle.mrGbMGetManualClutch         : "..tostring(vehicle:mrGbMGetManualClutch())) 	
	print("vehicle.mrGbMGetAccelerateToLimit    : "..tostring(vehicle:mrGbMGetAccelerateToLimit())) 	
	print("vehicle.mrGbMGetDecelerateToLimit    : "..tostring(vehicle:mrGbMGetDecelerateToLimit())) 	
	print("vehicle.mrGbMGetHasAllAuto           : "..tostring(vehicle:mrGbMGetHasAllAuto())) 	
	print("vehicle.mrGbMGetAutoHold             : "..tostring(vehicle:mrGbMGetAutoHold())) 	
	print("vehicle.mrGbMGetOnlyHandThrottle     : "..tostring(vehicle:mrGbMGetOnlyHandThrottle())) 	
	print("vehicle.mrGbMGetHydrostaticFactor    : "..tostring(vehicle:mrGbMGetHydrostaticFactor())) 	
	
	print("vehicle.tempomatMogliGetSpeedLimit   : "..tostring(vehicle:tempomatMogliGetSpeedLimit())) 	
	print("vehicle.tempomatMogliGetSpeedLimit2  : "..tostring(vehicle:tempomatMogliGetSpeedLimit2())) 	
end

function gearboxMogli:mrGbMDebug()
	gearboxMogli.debugGearShift = not gearboxMogli.debugGearShift
	
	if g_currentMission.controlledVehicle ~= nil then
		self = g_currentMission.controlledVehicle
		
		if self.mrGbML ~= nil then
			self.mrGbML.debugTimer = g_currentMission.time + 1000
		end
	end
	
	print("debugGearShift: "..tostring(gearboxMogli.debugGearShift))
end
end

