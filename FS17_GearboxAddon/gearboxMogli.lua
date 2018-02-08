--***************************************************************
--
-- gearboxMogli
-- 
-- version 2.200 by mogli (biedens)
--
--***************************************************************

local gearboxMogliVersion=2.200

-- allow modders to include this source file together with mogliBase.lua in their mods
if gearboxMogli == nil or gearboxMogli.version == nil or gearboxMogli.version < gearboxMogliVersion then

--***************************************************************
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
gearboxMogli.autoShiftRpmDiff     = gearboxMogli.huge -- 200
gearboxMogli.autoShiftPowerRatio  = 1.03
gearboxMogli.autoShiftMaxDeltaRpm = 1E-3
gearboxMogli.minClutchPercent     = 0.01
gearboxMogli.minClutchPercentStd  = 0.4
gearboxMogli.minClutchPercentTC   = 0.2
gearboxMogli.minClutchPercentTCL  = 0.3
gearboxMogli.maxClutchPercentTC   = 0.96
gearboxMogli.clutchLoopTimes      = 10
gearboxMogli.clutchLoopDelta      = 10
gearboxMogli.minHydrostaticFactor = 5e-3
gearboxMogli.fixedRatioDeltaRatio = 0.01 -- allow 1% deviation for hydrostatic and fixed ratio 
gearboxMogli.maxGearRatio         = 37699.11184                     -- 0.01 km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.minGearRatio         = 1.508                           -- 250  km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.maxHydroGearRatio    = gearboxMogli.maxGearRatio / 500 -- 5.0  km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.maxManualGearRatio   = gearboxMogli.maxGearRatio / 20  -- 0.2  km/h @1000 RPM / gear ratio might be bigger, but no clutch in this case
gearboxMogli.maxRatioFactorR      = gearboxMogli.huge -- 2000                            -- 0.001km/h @1000 RPM if combined with maxHydroGearRatio
gearboxMogli.brakeFxSpeed         = 2.5  -- m/s = 9 km/h
gearboxMogli.rpmReduction         = 0.925 -- 7.5% --0.85 -- 15% RPM reduction allowed e.g. 330 RPM for 2200 rated RPM 
gearboxMogli.maxPowerLimit        = 0.97 -- 97% max power is equal to max power
gearboxMogli.maxMaxPowerRatio     = 1.0  -- RPM where shift to maxMaxPowerRpm starts
gearboxMogli.smoothLittle         = 0.2
gearboxMogli.smoothFast           = 0.12
gearboxMogli.smoothMedium         = 0.04
gearboxMogli.smoothSlow           = 0.01
gearboxMogli.hydroEffDiff         = 0
gearboxMogli.hydroEffDiffInc      = 50
gearboxMogli.hydroEffMin          = 0.5
gearboxMogli.ptoRpmHydroDiff      = 25
gearboxMogli.ptoRpmThrottleDiff   = 50
gearboxMogli.lastMotorRpmDiffReal = 50
gearboxMogli.powerFactor0         = 0.1424083769633507853403141361257
gearboxMogli.powerFactorP         = gearboxMogli.powerFactor0 / 1.36
gearboxMogli.powerFactorPI        = 1.36 / gearboxMogli.powerFactor0
gearboxMogli.fuelFactor           = 1/(830*60*60*1000)-- 830 g per liter per hour => liter per millisecond
gearboxMogli.accDeadZone          = 0.1
gearboxMogli.blowOffVentilTime0   = 1500
gearboxMogli.blowOffVentilTime1   = 1000
gearboxMogli.blowOffVentilTime2   = 100
gearboxMogli.debugGearShift       = false
gearboxMogli.globalsLoaded        = false
gearboxMogli.ptoSpeedLimitMin     = 3   / 3.6  -- minimal speed limit
gearboxMogli.ptoSpeedLimitIni     = 0.2 / 3.6  -- initial offset for ptoSpeedLimit 
gearboxMogli.ptoSpeedLimitOff     = 2.0 / 3.6  -- turn off ptoSpeedLimit 
gearboxMogli.ptoSpeedLimitDec     = 0.2 / 3600 -- brake 
gearboxMogli.ptoSpeedLimitInc     = 1.0 / 3600 -- accelerate by 2 km/h per second 
gearboxMogli.ptoSpeedLimitRatio   = 0.05
gearboxMogli.ptoSpeedLimitTime    = 300
gearboxMogli.combineUseRealArea   = true
gearboxMogli.AIPowerShift         = "P"
gearboxMogli.AIGearboxOff         = "N"
gearboxMogli.AIAllAuto            = "A"
gearboxMogli.AIGearboxOn          = "Y"
gearboxMogli.kmhTOms              = 5 / 18
gearboxMogli.extraSpeedLimit      = 0.15
gearboxMogli.extraSpeedLimitMs    = gearboxMogli.extraSpeedLimit / 3.6
gearboxMogli.deltaLimitTimeMs     = 333
gearboxMogli.speedLimitBrake      = 2 / 3.6 -- m/s
gearboxMogli.speedLimitRpmDiff    = 5
gearboxMogli.motorBrakeTime       = 250     
gearboxMogli.motorLoadExp         = 1.5
gearboxMogli.gearShiftingNoThrottle = 178 -- just a big integer
gearboxMogli.trustClutchRpmTimer  = 50
gearboxMogli.brakeForceLimitRpm   = 25

gearboxMogli.enabledAtClient      = true
gearboxMogli.simplifiedAtClient   = false

gearboxMogliGlobals                       = {}
gearboxMogliGlobals.debugPrint            = false
gearboxMogliGlobals.debugInfo             = false 
gearboxMogliGlobals.transmissionEfficiency= 0.96
-- Giants is cheating: 0.86 * 0.88 = 0.7568 > 0.72 => torqueFactor = 0.86 * 0.88 / ( 0.72 * 0.94 )
gearboxMogliGlobals.torqueFactor          = 1 --0.86 * 0.88 / ( 0.72 * gearboxMogliGlobals.transmissionEfficiency )  
gearboxMogliGlobals.blowOffVentilVol      = 0.14
gearboxMogliGlobals.drawTargetRpm         = false 
gearboxMogliGlobals.drawReqPower          = false
gearboxMogliGlobals.defaultOn             = true
gearboxMogliGlobals.noDisable             = false
gearboxMogliGlobals.disableManual         = false
gearboxMogliGlobals.blowOffVentilRpmRatio = 0.7
gearboxMogliGlobals.minTimeToShift			  = 1    -- ms
gearboxMogliGlobals.minTimeToShiftReverse = 500  -- ms
gearboxMogliGlobals.maxTimeToSkipGear  	  = 251  -- ms
gearboxMogliGlobals.autoShiftTimeoutLong  = 3000 -- ms
gearboxMogliGlobals.autoShiftTimeoutShort = 600  -- ms -- let it go up to ratedRPM !!!
gearboxMogliGlobals.autoShiftTimeoutHydroL= 1000 -- ms 
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
gearboxMogliGlobals.idleFuelTorqueRatio   = 0.3
gearboxMogliGlobals.defaultLiterPerSqm    = 1.2  -- 1.2 l/m² for wheat
gearboxMogliGlobals.combineDefaultSpeed   = 10   -- km/h
gearboxMogliGlobals.combineDynamicRatio   = 0.6
gearboxMogliGlobals.combineDynamicChopper = 0.8
gearboxMogliGlobals.dtDeltaTargetFast     = 0.0003  -- 3 1/3 second 
gearboxMogliGlobals.dtDeltaTargetSlow     = 0.00014 -- 7 seconds
gearboxMogliGlobals.ddsDirectory          = "dds/"
gearboxMogliGlobals.initMotorOnLoad       = true
gearboxMogliGlobals.ptoSpeedLimit         = true
gearboxMogliGlobals.clutchExp             = 1.0
gearboxMogliGlobals.clutchFactor          = 1.2
gearboxMogliGlobals.grindingMinRpmDelta   = 200
gearboxMogliGlobals.grindingMaxRpmSound   = 600
gearboxMogliGlobals.grindingMaxRpmDelta   = gearboxMogli.huge
gearboxMogliGlobals.defaultEnableAI       = gearboxMogli.AIPowerShift
gearboxMogliGlobals.autoHold              = false -- true
gearboxMogliGlobals.minAutoGearSpeed      = 1.0   -- 0.2777 -- m/s
gearboxMogliGlobals.minAbsSpeed           = 1.0   -- km/h
gearboxMogliGlobals.brakeNeutralTimeout   = 1000  -- ms
gearboxMogliGlobals.brakeNeutralLimit     = -0.3
gearboxMogliGlobals.DefaultRevUpMs0       = 1500  -- ms time between idle and rated RPM w/o load
gearboxMogliGlobals.DefaultRevUpMs1       = 30000 -- ms time between idle and rated RPM with full load
gearboxMogliGlobals.DefaultRevUpMsH       = 30000 -- ms time between idle and rated RPM with full load (hydrostat)
gearboxMogliGlobals.DefaultRevUpMs2       = 750   -- ms time between idle and rated RPM in neutral 
gearboxMogliGlobals.DefaultRevDownMs      = 1500  -- ms time between rated and idle RPM
gearboxMogliGlobals.HydroSpeedIdleRedux   = 1e-3  -- 0.04  -- default reduce by 10 km/h per second => 0.4 km/h with const. RPM and w/o acc.
gearboxMogliGlobals.smoothGearRatio       = true  -- smooth gear ratio with hydrostatic drive
gearboxMogliGlobals.hydroMaxTorqueInput   = 0 -- 2
gearboxMogliGlobals.hydroMaxTorqueOutput  = 0 -- 3
gearboxMogliGlobals.hydroMaxTorqueDirect  = 0 -- 4
gearboxMogliGlobals.minClutchTimeManual   = 3000  -- ms; time from 0% to 100% for the digital manual clutch
gearboxMogliGlobals.momentOfInertiaBase   = 1     -- J in unit kg m^2; for a cylinder with mass m and radius r: J = 0.5 * m * r^2
gearboxMogliGlobals.momentOfInertia       = 4     -- J in unit kg m^2; for a cylinder with mass m and radius r: J = 0.5 * m * r^2
gearboxMogliGlobals.inertiaToDampingRatio = 0.333
gearboxMogliGlobals.momentOfInertiaMin    = 1e-4  -- 0.5 * 1e-3 is already multiplied by 1e-3!!!
gearboxMogliGlobals.brakeForceRatio       = 0.03  -- tested, see issue #101
gearboxMogliGlobals.maxRpmThrottle        = 0.9
gearboxMogliGlobals.maxRpmThrottleAuto    = true
gearboxMogliGlobals.noSpeedMatching       = false -- option to disable speed matching for all vehicles 
gearboxMogliGlobals.autoStartStop         = false -- option to enable auto start stop for all vechiles
gearboxMogliGlobals.useMrUWP              = 10
gearboxMogliGlobals.reduceMOIClutchLimit  = 0.5   -- reduce moment of inertia if clutch is below 50%
gearboxMogliGlobals.reduceMOILowRatio     = false -- reduce moment of inertia at low gear ratio, default is off
gearboxMogliGlobals.reduceMOILowSpeed     = false -- reduce moment of inertia at low speed, default is off
gearboxMogliGlobals.accThrottleExp        = 1.5
gearboxMogliGlobals.accelerateToLimit     = 5     -- km/h per second
gearboxMogliGlobals.decAccToLimitRatio    = 2     -- decelerateToLimit = accelerateToLimit * decAccToLimitRatio
gearboxMogliGlobals.onlyTwoSpeeds         = false -- only two CC speeds instead of three
gearboxMogliGlobals.manual4wd             = true  -- diff lock
gearboxMogliGlobals.maxDeltaAccPerMs      = 0.003 -- max delta for acceleration; it takes 333 ms from 0 to 1
gearboxMogliGlobals.uiFixedRatioStep      = 2
gearboxMogliGlobals.uiHandThrottleStep    = 50    -- 50 RPM step, little more to avoid runding problems
gearboxMogliGlobals.clutchAxisOpen        = -0.9  -- clutch axis from value from -1 to -0.9 => clutch = 0
gearboxMogliGlobals.clutchAxisClosed      =  0.9  -- clutch axis from value from 0.9 to 1   => clutch = 1
gearboxMogliGlobals.ptoRpmFactor          = 0.900 -- 0.75 -- reduce PTO RPM; e.g. 1900 with PTO and 2200 rated RPM
gearboxMogliGlobals.ptoRpmFactorEco       = 2/3   -- 0.5  -- reduce PTO RPM in eco mode; e.g. 1600 with PTO and 2200 rated RPM
gearboxMogliGlobals.minTargetRpmFactor    = 0.3   -- reduce PTO RPM in eco mode; e.g. 1600 with PTO and 2200 rated RPM
gearboxMogliGlobals.hydroRpmFactor        = 0.3   -- reduce PTO RPM in eco mode; e.g. 1600 with PTO and 2200 rated RPM
gearboxMogliGlobals.increaseRpmForPTO     = true  -- increase RPM automatically if PTO is turned on

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
	local key
	
	key = string.format("vehicle.motorConfigurations.motorConfiguration(%d).gearboxMogli", self.configurations.motor-1)	
	if hasXMLProperty(self.xmlFile, key) then
		gearboxMogli.initFromXml(self,self.xmlFile,key,nil,"vehicle",true)
		return
	end

	key = "vehicle.motorConfigurations.motorConfiguration(0).gearboxMogli"	
	if hasXMLProperty(self.xmlFile, key) then
		gearboxMogli.initFromXml(self,self.xmlFile,key,nil,"vehicle",true)
		return
	end

	key = "vehicle.gearboxMogli"
	if hasXMLProperty(self.xmlFile, key) then
		gearboxMogli.initFromXml(self,self.xmlFile,key,nil,"vehicle",true)
		return
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
																 "AllAuto",
																 "NeutralActive", 
																 "ReverseActive", 
																 "SpeedLimiter",  
																 "HandThrottle",
																 "MaxTarget",
																 "MinTarget",
																 "FixedRatio",
																 "AutoClutch", 
																 "ManualClutch",
																 "AccelerateToLimit",
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
				gearboxMogli.globalsLoad( file, "vehicles.gearboxMogliGlobals", gearboxMogliGlobals, true )	
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
	gearboxMogli.registerState( self, "AutoCloseTimer",0 )
	gearboxMogli.registerState( self, "DoubleClutch",  0 )
	gearboxMogli.registerState( self, "ToolIsDirty2",  true )
	gearboxMogli.registerState( self, "ShuttleFactor", 0.5 )
	self.mrGbMS.ToolIsDirty = false
	
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
	gearboxMogli.registerState( self, "Automatic",     true,  gearboxMogli.mrGbMOnSetAutomatic )
	gearboxMogli.registerState( self, "ReverseActive", false, gearboxMogli.mrGbMOnSetReverse )
	gearboxMogli.registerState( self, "NeutralActive", true,  gearboxMogli.mrGbMOnSetNeutral ) 	
	gearboxMogli.registerState( self, "Handbrake",     false ) 	
	gearboxMogli.registerState( self, "AutoHold",      false ) 	
	gearboxMogli.registerState( self, "AutoClutch",    true  )
	gearboxMogli.registerState( self, "ManualClutch",  1,     gearboxMogli.mrGbMOnSetManualClutch )
	gearboxMogli.registerState( self, "HandThrottle",  0 )
	gearboxMogli.registerState( self, "MinTarget",     0 )
	gearboxMogli.registerState( self, "MaxTarget",     0 )
	gearboxMogli.registerState( self, "FixedRatio",    0 )
	gearboxMogli.registerState( self, "SpeedLimiter",  false )
	gearboxMogli.registerState( self, "AllAuto",       false )
	gearboxMogli.registerState( self, "AllAuto2",      false )
	gearboxMogli.registerState( self, "AllAutoMode",   7,     gearboxMogli.mrGbMOnSetAllAutoMode )
	gearboxMogli.registerState( self, "EcoMode",       false )
	gearboxMogli.registerState( self, "HudMode",       self.mrGbMG.defaultHudMode )
	gearboxMogli.registerState( self, "CurrentGearSpeed", 0 )
	gearboxMogli.registerState( self, "AutoMinGearSpeed", 0 )
	gearboxMogli.registerState( self, "AutoMaxGearSpeed", 0 )
	gearboxMogli.registerState( self, "AutoShiftRequest", 0 )
	
	gearboxMogli.registerState( self, "GearShifterMode",    0 )
	gearboxMogli.registerState( self, "ShuttleShifterMode", 0 )
	gearboxMogli.registerState( self, "Range1ShifterMode",  0 )
	gearboxMogli.registerState( self, "Range2ShifterMode",  0 )
	
	gearboxMogli.registerState( self, "DiffLockMiddle", false )
	gearboxMogli.registerState( self, "DiffLockFront",  false )
	gearboxMogli.registerState( self, "DiffLockBack",   false )
	
	gearboxMogli.registerState( self, "MinAutoGearSpeed", 0 )
	gearboxMogli.registerState( self, "MaxAutoGearSpeed", 0 )
	
--********************************************** ************************************************************	
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
	self.mrGbMGetFuelUsageRate     = gearboxMogli.mrGbMGetFuelUsageRate
	self.mrGbMGetDecelerateToLimit = gearboxMogli.mrGbMGetDecelerateToLimit
	self.mrGbMGetDiffLockMiddle    = gearboxMogli.mrGbMGetDiffLockMiddle
	self.mrGbMGetDiffLockFront     = gearboxMogli.mrGbMGetDiffLockFront 
	self.mrGbMGetDiffLockBack      = gearboxMogli.mrGbMGetDiffLockBack 

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
	self.mrGbML.doubleClutch       = 0
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
	self.mrGbML.motorSoundLoadFactor = 0
	
	if gearboxMogli.ovArrowUpWhite == nil then
		local w  = math.floor(0.012 * g_screenWidth) / g_screenWidth * gearboxMogli.getUiScale()
		local h = w * g_screenAspectRatio
		local x = g_currentMission.speedMeterIconOverlay.x
		local y = g_currentMission.speedMeterIconOverlay.y

		x = x + 0.2*w
		y = y + g_currentMission.vehicleHudBg.height - h
		
		gearboxMogli.ovArrowUpWhite   = Overlay:new("ovArrowUpWhite",   Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_up_white.dds",   gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovArrowUpGray    = Overlay:new("ovArrowUpGray",    Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_up_gray.dds",    gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovArrowDownWhite = Overlay:new("ovArrowDownWhite", Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_down_white.dds", gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovArrowDownGray  = Overlay:new("ovArrowDownGray",  Utils.getFilename( self.mrGbMG.ddsDirectory.."arrow_down_gray.dds",  gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovHandBrakeUp    = Overlay:new("ovHandBrakeUp",    Utils.getFilename( self.mrGbMG.ddsDirectory.."hand_brake_up.dds",    gearboxMogli.baseDirectory), x, y, w, h)
		gearboxMogli.ovHandBrakeDown  = Overlay:new("ovHandBrakeDown",  Utils.getFilename( self.mrGbMG.ddsDirectory.."hand_brake_down.dds",  gearboxMogli.baseDirectory), x, y, w, h)
	
		x = x + 1.1*w
		gearboxMogli.ovDiffLockMiddle = Overlay:new("ovDiffLockMiddle", Utils.getFilename( self.mrGbMG.ddsDirectory.."diff_lock_middle.dds", gearboxMogli.baseDirectory), x, y, w, h)
		x = x + 1.1*w
		gearboxMogli.ovDiffLockFront  = Overlay:new("ovDiffLockFront",  Utils.getFilename( self.mrGbMG.ddsDirectory.."diff_lock_front.dds",  gearboxMogli.baseDirectory), x, y, w, h)
		x = x + 1.1*w
		gearboxMogli.ovDiffLockBack   = Overlay:new("ovDiffLockBack",   Utils.getFilename( self.mrGbMG.ddsDirectory.."diff_lock_back.dds",   gearboxMogli.baseDirectory), x, y, w, h)
	end
	
	self.mrGbMD.lastTgt    = 0 
	self.mrGbMD.Tgt        = 0 
	self.mrGbMD.lastClutch = 0 
	self.mrGbMD.Clutch     = 0 
	self.mrGbMD.lastPower  = 0 
	self.mrGbMD.Power      = 0 
	self.mrGbMD.lastRate   = 0 
	self.mrGbMD.Rate       = 0 
	self.mrGbMD.lastHydro  = 255
	self.mrGbMD.Hydro      = 255
	self.mrGbMD.lastSlip   = 0
	self.mrGbMD.Slip       = 0
	
	self.mrGbML.lastAcceleration  = 0
	self.mrGbML.lastBrakePedal    = 1
	self.mrGbML.fuelUsageRaw      = 0
	self.mrGbML.fuelUsageRate     = 0
	self.mrGbML.fuelUsageAvg      = 0
  self.mrGbML.fuelUsageDt       = 0
  self.mrGbML.fuelUsageClient   = 0
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetEqualizedRpm
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetEqualizedRpm( r )
--return math.min( self.mrGbMS.OrigMaxRpm, self.mrGbMS.OrigMinRpm + math.max( 0, ( r - self.mrGbMS.IdleRpm ) ) * self.mrGbMS.EqualizedRpmFactor )
	if r < self.mrGbMS.IdleRpm then
		return self.mrGbMS.OrigMinRpm
	end
	return self.mrGbMS.OrigMinRpm + ( r - self.mrGbMS.IdleRpm ) * self.mrGbMS.EqualizedRpmFactor
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetFuelUsageRate
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetFuelUsageRate( getRawValue )
	if self.isServer then
		if getRawValue then
			return self.mrGbML.fuelUsageRaw 
		end
		return self.mrGbML.fuelUsageRate
	end
	return self.mrGbML.fuelUsageClient
end

function gearboxMogli.getBit3( value, bit )
	if     bit == 1 then
		if value == 1 or value == 3 or value == 5 or value == 7 then
			return 1
		end
		return 0
	elseif bit == 2 then
		if value == 2 or value == 3 or value == 6 or value == 7 then
			return 1
		end
		return 0
	elseif bit == 3 then
		if value == 4 or value == 5 or value == 6 or value == 7 then
			return 1
		end
		return 0
	end
end

--**********************************************************************************************************	
-- gearboxMogli.completeXMLGearboxEntry
--**********************************************************************************************************	
function gearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, fixEntry )
	local newEntry = fixEntry
	newEntry.reverseOnly    = getXMLBool( xmlFile, baseName .. "#reverseOnly" )		
	newEntry.forwardOnly    = getXMLBool( xmlFile, baseName .. "#forwardOnly" )
	newEntry.minGear        = getXMLInt(xmlFile, baseName .. "#minGear" )
	newEntry.maxGear        = getXMLInt(xmlFile, baseName .. "#maxGear" )
	newEntry.minRange       = getXMLInt(xmlFile, baseName .. "#minRange" )
	newEntry.maxRange       = getXMLInt(xmlFile, baseName .. "#maxRange" )
	newEntry.minRange2      = getXMLInt(xmlFile, baseName .. "#minRange2" )
	newEntry.maxRange2      = getXMLInt(xmlFile, baseName .. "#maxRange2" )
	newEntry.upShiftMs      = getXMLFloat(xmlFile, baseName .. "#upShiftTimeMs" )
	newEntry.downShiftMs    = getXMLFloat(xmlFile, baseName .. "#downShiftTimeMs" )
	return newEntry
end

--**********************************************************************************************************	
-- gearboxMogli:initFromXml
--**********************************************************************************************************	
function gearboxMogli:initFromXml(xmlFile,xmlString,xmlMotor,xmlSource,serverAndClient,motorConfig) 

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
				gearboxMogli.globalsLoad( file, "vehicles.gearboxMogliGlobals", gearboxMogliGlobals, true )	
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
	self.mrGbMS.TransmissionName        = getXMLString(xmlFile, xmlString .. "#name" )
	self.mrGbMS.ConfigVersion           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#version" ),1.4)
	self.mrGbMS.NoDisable               = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#noDisable" ),self.mrGbMG.noDisable)
	self.mrGbMS.showHud                 = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#showHud" ),true)
	self.mrGbMS.DrawTargetRpm           = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#drawTargetRpm" ),self.mrGbMG.drawTargetRpm)
	self.mrGbMS.DrawReqPower            = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#drawTargetRpm" ),self.mrGbMG.drawReqPower)
	self.mrGbMS.SwapGearRangeKeys       = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#swapGearRangeKeys" ),false)
	self.mrGbMS.SwapGearRangeKeys0      = self.mrGbMS.SwapGearRangeKeys
	self.mrGbMS.TransmissionEfficiency  = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#transmissionEfficiency"), gearboxMogliGlobals.transmissionEfficiency) 
	
	self.mrGbMS.IdleRpm	                = math.max( Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idleRpm"),  self.motor.minRpm ), self.motor.minRpm )
	self.mrGbMS.OrigMinRpm              = self.motor.minRpm
	self.mrGbMS.OrigMaxRpm              = self.motor.maxRpm	
	
	self.mrGbMS.OrigRatedRpm            = self.mrGbMS.IdleRpm
	do
		local maxPower = 0
		for _,k in pairs(self.motor.torqueCurve.keyframes) do
			p = k.time * k.v
			if maxPower < p then
				maxPower = p
			end			
			if k.v > 0 and p >= 0.9 * maxPower then
				self.mrGbMS.OrigRatedRpm = k.time
			end
		end
	end

	self.mrGbMS.CurMinRpm               = math.max( self.mrGbMS.IdleRpm - gearboxMogli.rpmMinus, 0 )
	self.mrGbMS.CurMaxRpm               = math.max( self.mrGbMS.OrigRatedRpm + gearboxMogli.rpmPlus, self.mrGbMS.OrigMaxRpm )

	self.mrGbMS.RatedRpm                = math.min( Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#ratedRpm"), self.mrGbMS.OrigRatedRpm ), self.motor.maxRpm )
	self.mrGbMS.AccelerateToLimit       = self.mrGbMG.accelerateToLimit
	self.mrGbMS.MinTargetRpm            = getXMLFloat(xmlFile, xmlString .. "#minTargetRpm")
	self.mrGbMS.MaxTargetRpm            = getXMLFloat(xmlFile, xmlString .. "#maxTargetRpm")
	self.mrGbMS.IdleEnrichment          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idleEnrichment"), 0.1 )
	
	default   = 0	
	if self.motor.brakeForce > gearboxMogli.eps then 
		default   = self.mrGbMG.brakeForceRatio / self.motor.brakeForce
	end 
	self.mrGbMS.BrakeForceRatio         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#brakeForceRatio"), default )

	self.mrGbMS.FuelPerDistanceMinSpeed = getXMLFloat( xmlFile, xmlString .. "#fuelPerDistanceMinSpeed" )
	
--**************************************************************************************************	
	self.mrGbMS.RpmInSpeedHud           = getXMLBool( xmlFile, xmlString .. "#rpmInSpeedHud")
	self.mrGbMS.MinHudRpm               = getXMLFloat(xmlFile, xmlString .. "#minHudRpm")
	self.mrGbMS.MaxHudRpm               = getXMLFloat(xmlFile, xmlString .. "#maxHudRpm")
--**************************************************************************************************	
	self.mrGbMS.Engine = {}
	self.mrGbMS.Sound  = {}
	self.mrGbMS.Engine.maxTorque = 0
	self.mrGbMS.Engine.maxTorqueRpm = 0
	self.mrGbMS.Engine.minRpm = gearboxMogli.huge
	self.mrGbMS.Engine.maxRpm = 0
	self.mrGbMS.TorqueFactor  = 1

	local torqueI = 0
	local torqueP = 0
	local realEngineBaseKey = nil
	
	local baseIdle  = 50 * math.floor( 0.5 + 0.02 * math.max( 0.4545 * self.mrGbMS.RatedRpm, self.mrGbMS.IdleRpm ) )
	local minTgtDft = 10 * math.floor( 0.5 + 0.10 * ( baseIdle + self.mrGbMG.minTargetRpmFactor * ( self.mrGbMS.RatedRpm - baseIdle ) ) )
	
	if xmlMotor ~= nil then
		for i=1,3 do
			local key 
			if     i == 1 then
				if self.configurations.motor ~= nil then
					if motorConfig == nil then				
						key = string.format(xmlMotor..".engines.engine(%d)", self.configurations.motor-1)
					elseif motorConfig[self.configurations.motor] ~= nil then
						key = string.format(xmlMotor..".engines.engine(%d)", motorConfig[self.configurations.motor]-1)
					end
				end
			elseif i == 2 then
				key = xmlMotor..".engines.engine(0)"
			else
				key = xmlMotor..".realEngine"
			end
			
			if key ~= nil and getXMLFloat(xmlFile, key..".torque(0)#rpm") ~= nil then
				realEngineBaseKey = key
				break
			end
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
				self.mrGbMS.EngineName = s
				print('FS17_GearboxAddon: Warning! Engine names to not match: "'..s..'" <> "'..t..'"')
			else
			--print('FS17_GearboxAddon: Engine and vehicle motorConfiguration name: "'..t..'"')
			end
		elseif s ~= nil then
			self.mrGbMS.EngineName = s
		--print('FS17_GearboxAddon: Engine name: "'..s..'"')			
		end
		
		local d = getXMLString( xmlFile, realEngineBaseKey.."#displayName" )
		if d ~= nil then
			self.mrGbMS.EngineName = d
		end
		
		while true do
			local key = string.format(realEngineBaseKey..".torque(%d)", torqueI)
			local rpm = getXMLFloat(xmlFile, key.."#rpm")
			local torque = getXMLFloat(xmlFile, key.."#motorTorque")
			if torque == nil then
				torque = getXMLFloat(xmlFile, key.."#ptoTorque")
				if torque ~= nil then
					torque = torque / self.mrGbMS.TransmissionEfficiency
				end
			end		

			if torque == nil or rpm == nil then --or fuelUsageRatio==nil then
				break
			end
			
			if self.mrGbMS.Engine.torqueValues == nil then
				--print("loading motor with new torque curve")
				self.mrGbMS.Engine.torqueValues = {}
				local tf = self.mrGbMG.torqueFactor
				if self.mrIsMrVehicle then
					tf = 1
				end
				self.mrGbMS.TorqueFactor = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#torqueFactor"), tf) / 1000
			end
			
			torque = torque * self.mrGbMS.TorqueFactor 
		
			self.mrGbMS.Engine.torqueValues[torqueI+1] = {v=torque, time = rpm}
					
			if torque>self.mrGbMS.Engine.maxTorque + gearboxMogli.eps then
				self.mrGbMS.Engine.maxTorqueRpm = rpm
			end			
			if torque>self.mrGbMS.Engine.maxTorque then
				self.mrGbMS.Engine.maxTorque = torque
			end
			
			local ecoTorque = getXMLFloat(xmlFile, key.."#motorTorqueEco")
			if ecoTorque == nil then
				ecoTorque = getXMLFloat(xmlFile, key.."#ptoTorqueEco")
				if ecoTorque ~= nil then
					ecoTorque = ecoTorque / self.mrGbMS.TransmissionEfficiency
				end
			end		
			if      ecoTorque ~= nil
					and ( ecoTorque > 0 or self.mrGbMS.Engine.ecoTorqueValues ~= nil ) then
				ecoTorque = ecoTorque * self.mrGbMS.TorqueFactor 
				
				if self.mrGbMS.Engine.ecoTorqueValues == nil then
					self.mrGbMS.Engine.ecoTorqueValues = {}
				end
				table.insert( self.mrGbMS.Engine.ecoTorqueValues, {v=ecoTorque, time = rpm} )
			end
			
			local fuelUsageRatio = getXMLFloat(xmlFile, key.."#fuelUsageRatio")
			if fuelUsageRatio ~= nil and fuelUsageRatio > 0 then
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
			torqueI = torqueI + 1	
			torqueP = torque
		end

		if torqueI > 0 then
			self.mrGbMS.IdleRpm	  = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#idleRpm"), 800)
			self.mrGbMS.RatedRpm  = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#ratedRpm"), 2100)
			self.mrGbMS.CurMinRpm = Utils.getNoNil(getXMLFloat(xmlFile, realEngineBaseKey.."#minRpm"), math.max( self.mrGbMS.IdleRpm  - gearboxMogli.rpmMinus, self.mrGbMS.Engine.minRpm ))
			self.mrGbMS.CurMaxRpm = self.mrGbMS.Engine.maxRpm + gearboxMogli.rpmPlus
			if self.mrGbMS.MinTargetRpm == nil then
				self.mrGbMS.MinTargetRpm = math.max( self.mrGbMS.Engine.maxTorqueRpm * gearboxMogli.rpmReduction, minTgtDft )
			end
			local m = getXMLFloat(xmlFile, realEngineBaseKey.."#maxRpm")
			if m ~= nil then
				self.mrGbMS.MaxTargetRpm =  m
			elseif self.mrGbMS.MaxTargetRpm == nil then
				self.mrGbMS.MaxTargetRpm = 0.5 * ( self.mrGbMS.RatedRpm + math.max(self.mrGbMS.RatedRpm, self.mrGbMS.Engine.maxRpm ) )
			end
			baseIdle  = math.max( 0.475 * self.mrGbMS.RatedRpm, self.mrGbMS.IdleRpm )
		end
		
		self.mrGbMS.BoostMinSpeed = Utils.getNoNil( getXMLFloat(xmlFile, realEngineBaseKey.."#boostMinSpeed"), 30 ) / 3.6
	end
	
	self.mrGbMS.ConfigId  = self.configurations.GearboxAddon
	self.mrGbMS.BoughtIds = {}
	
	if self.boughtConfigurations ~= nil and type( self.boughtConfigurations.GearboxAddon ) == "table" then
		for id,b in pairs(self.boughtConfigurations.GearboxAddon) do
			if b then
				table.insert( self.mrGbMS.BoughtIds, id )
			end
		end
	end
	
	if self.mrGbMS.TransmissionName ~= nil then
		if self.mrGbMS.EngineName == nil then
			self.mrGbMS.EngineName = self.mrGbMS.TransmissionName
		else
			self.mrGbMS.EngineName = self.mrGbMS.EngineName.." "..self.mrGbMS.TransmissionName
		end
	end
	
	if self.mrGbMS.MinTargetRpm == nil then
		self.mrGbMS.MinTargetRpm = minTgtDft
	end
	if self.mrGbMS.MaxTargetRpm == nil then
		self.mrGbMS.MaxTargetRpm = 0.5 * ( self.mrGbMS.RatedRpm + math.max( self.mrGbMS.RatedRpm, self.mrGbMS.CurMaxRpm - gearboxMogli.rpmPlus ) )
	elseif self.mrGbMS.MaxTargetRpm < self.mrGbMS.RatedRpm then
		if self.mrGbMS.Engine.torqueValues == nil then
			print('FS17_GearboxAddon: Warning! engine maxRpm < engine ratedRpm')
		else
			print('FS17_GearboxAddon: Warning! maxTargetRpm ratedRpm')
		end
		self.mrGbMS.MaxTargetRpm = self.mrGbMS.RatedRpm
	end
	self.mrGbMS.MaxTargetRpmRatio = self.mrGbMS.MaxTargetRpm / self.mrGbMS.RatedRpm
		
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
		self.mrGbMS.Sound.MaxRpm = self.mrGbMS.OrigRatedRpm
	end
	
	self.mrGbMS.HydraulicRpm 	= Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#hydraulicRpm"), 
																							10 * math.floor( 0.5 + 0.10 * ( baseIdle + self.mrGbMG.hydroRpmFactor  * ( self.mrGbMS.RatedRpm - baseIdle ) ) ) )

--**************************************************************************************************	
-- PTO RPM
--**************************************************************************************************		
	self.mrGbMS.PtoRpm       	= Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#ptoRpm"),    
																							50 * math.floor( 0.5 + 0.02 * ( baseIdle + self.mrGbMG.ptoRpmFactor    * ( self.mrGbMS.RatedRpm - baseIdle ) ) ) )
	self.mrGbMS.PtoRpmEco   	= Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#ptoRpmEco"),    
																							50 * math.floor( 0.5 + 0.02 * ( baseIdle + self.mrGbMG.ptoRpmFactorEco * ( self.mrGbMS.RatedRpm - baseIdle ) ) ) )
	if self.mrGbMS.PtoRpmEco > self.mrGbMS.PtoRpm then
		self.mrGbMS.PtoRpmEco             = self.mrGbMS.PtoRpm
	end
	
	local maxPtoTorqueRatio = 0.5
	local maxPtoTorqueSpeed = 10

	self.mrGbMS.OnlyHandThrottle        = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#onlyHandThrottle" ), false)
	self.mrGbMS.MinHandThrottle         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#minHandThrottle" ), 0.5)
	self.mrGbMS.PtoSpeedLimit	          = Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#ptoSpeedLimit"), self.mrGbMG.ptoSpeedLimit )

--**************************************************************************************************	
-- combine
--**************************************************************************************************		
	if SpecializationUtil.hasSpecialization(Combine, self.specializations) then	
		self.mrGbMS.IsCombine                    = true
		
		local width  = getXMLFloat(xmlFile, xmlString .. ".combine#defaultWidth") 
		local speed = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#defaultSpeed"), self.mrGbMG.combineDefaultSpeed )
		maxPtoTorqueSpeed = math.min( maxPtoTorqueSpeed, speed )
		local f = gearboxMogli.powerFactorPI * 7 / speed
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

		self.mrGbMS.ThreshingMinRpm  = getXMLFloat(xmlFile, xmlString .. ".combine#minRpm")
		self.mrGbMS.ThreshingFullRpm = getXMLFloat(xmlFile, xmlString .. ".combine#fullPowerRpm")
		self.mrGbMS.ThreshingMaxRpm  = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#maxRpm"), self.mrGbMS.MaxTargetRpm )
		
		if self.mrGbMS.ThreshingMinRpm == nil then
			if      self.sampleThreshing ~= nil
					and self.sampleThreshing.pitchOffset ~= nil 
					and self.sampleThreshing.cuttingPitchOffset ~= nil 
					and self.sampleThreshing.cuttingPitchOffset < self.sampleThreshing.pitchOffset then
				self.mrGbMS.ThreshingMinRpm = self.mrGbMS.ThreshingMaxRpm * self.sampleThreshing.cuttingPitchOffset / self.sampleThreshing.pitchOffset
			else
				self.mrGbMS.ThreshingMinRpm = math.max( self.mrGbMS.MinTargetRpm, 0.2 * baseIdle + 0.8 * self.mrGbMS.RatedRpm )
			end
		end
		
		self.mrGbMS.UnloadingPowerConsumption    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#unloadingPowerConsumption")   , du0 ) * f
		
		self.mrGbMS.ThreshingPowerConsumption    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#threshingPowerConsumption")   , dp0 ) * f
		self.mrGbMS.ThreshingPowerConsumptionInc = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#threshingPowerConsumptionInc"), dpi ) * f
		self.mrGbMS.ChopperPowerConsumption      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#chopperPowerConsumption")     , dc0 ) * f
		self.mrGbMS.ChopperPowerConsumptionInc   = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#chopperPowerConsumptionInc")  , dci ) * f
		
		if     self.sampleThreshing == nil
				or self.sampleThreshing.cuttingPitchOffset == nil 
			--or self.sampleThreshing.cuttingPitchOffset == self.sampleThreshing.pitchOffset 
				or self.mrGbMS.ThreshingMinRpm >= self.mrGbMS.ThreshingMaxRpm then
			self.mrGbMS.ThreshingSoundPitchMod     = false
		else
			self.mrGbMS.ThreshingSoundPitchMod     = Utils.getNoNil( getXMLBool( xmlFile, xmlString .. ".combine#soundPitch"), true ) --self.mrGbMS.OnlyHandThrottle ) 
			
			local pf = math.min( self.sampleThreshing.cuttingPitchOffset, self.sampleThreshing.pitchOffset )
			local pt = math.max( self.sampleThreshing.cuttingPitchOffset, self.sampleThreshing.pitchOffset )
			
			pf = pt * self.mrGbMS.ThreshingMinRpm / self.mrGbMS.ThreshingMaxRpm
			
			self.mrGbMS.ThreshingSoundPitchMin     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#soundPitchMin"), pf ) 
			self.mrGbMS.ThreshingSoundPitchMax     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".combine#soundPitchMax"), pt ) 
		end
		
		if      self.mrGbMS.ThreshingSoundPitchMod 
			--and not self.mrGbMS.OnlyHandThrottle 
				and self.mrGbMS.ThreshingFullRpm == nil then
			self.mrGbMS.ThreshingFullRpm = self.mrGbMS.ThreshingMinRpm
		end
		
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
	
	self.mrGbMS.MomentOfInertia         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#momentOfInertia"), self.mrGbMG.momentOfInertiaBase  + self.mrGbMG.momentOfInertia  * maxTorque )
	
--**************************************************************************************************	
-- Clutch parameter
--**************************************************************************************************		
	self.mrGbMS.TorqueConverter         = getXMLBool( xmlFile, xmlString .. "#torqueConverter" )	
	self.mrGbMS.MaxClutchPercent        = getXMLFloat(xmlFile, xmlString .. "#maxClutchRatio")
	local torqueConverterProfile        = getXMLString( xmlFile, xmlString .. "#torqueConverterProfile" )	-- "wheelLoader" / "clutch" / "car"
	if torqueConverterProfile ~= nil and torqueConverterProfile ~= "" and self.mrGbMS.TorqueConverter == nil then
		self.mrGbMS.TorqueConverter    = true
	end
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
	if torqueConverterProfile == nil then
		if self.mrGbMS.TorqueConverter then
			torqueConverterProfile = "clutch" 
		else
			torqueConverterProfile = ""
		end
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
	
	if torqueConverterProfile == "wheelLoader" then 
		default = gearboxMogli.huge
	elseif torqueConverterProfile == "oldCar" then 
		default = 0.7 * self.mrGbMS.RatedRpm + 0.3 * baseIdle
	elseif torqueConverterProfile == "modernCar" then 
		default = 0.5 * self.mrGbMS.RatedRpm + 0.5 * baseIdle
	else
		default = math.max( 0.62 * self.mrGbMS.RatedRpm, baseIdle )
		if self.mrGbMS.Engine.maxTorque > 0 then
			default = math.min( default, self.mrGbMS.Engine.maxTorqueRpm )
		end
	end
	self.mrGbMS.CloseRpm                = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchCloseRpm"), default )
	
	if torqueConverterProfile == "wheelLoader" then 
		default = gearboxMogli.huge
	elseif self.mrGbMS.TorqueConverter then 
		default = math.min( self.mrGbMS.CloseRpm, self.mrGbMS.RatedRpm )
	else
		default = self.mrGbMS.CurMinRpm-1 -- no automatic opening of clutch by default!!!
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
			clutchEngagingTimeMs = 100
		elseif torqueConverterProfile == "wheelLoader" then 
			clutchEngagingTimeMs = 1000
		elseif torqueConverterProfile == "oldCar" then 
			clutchEngagingTimeMs = 2000
		elseif torqueConverterProfile == "modernCar" then 
			clutchEngagingTimeMs = 400
		elseif self.mrGbMS.TorqueConverter then
			clutchEngagingTimeMs = 400
		elseif getXMLBool(xmlFile, xmlString .. ".gears#automatic") then
			clutchEngagingTimeMs = 200
		else
			clutchEngagingTimeMs = 400 -- 1000 = 1s
		end
	end
	
	local dft = self.mrGbMS.TransmissionEfficiency
	if self.mrGbMS.TorqueConverter then
		dft = math.min( 0.85, self.mrGbMS.TransmissionEfficiency )
	end
	self.mrGbMS.ClutchEfficiency    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#clutchEfficiency"), dft )
	self.mrGbMS.ClutchEfficiencyInc = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#clutchEfficiencyInc"), 
																		math.max( 0, 0.95 * self.mrGbMS.TransmissionEfficiency - self.mrGbMS.ClutchEfficiency ) )

	if self.mrGbMS.TorqueConverter then
		default = 3.2 -- hanomag or car
		if torqueConverterProfile == "clutch" then
			default = 1.25 -- voith
		end
		self.mrGbMS.TorqueConverterFactor   = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#torqueConverterMaxFactor"),default) * self.mrGbMS.TransmissionEfficiency / self.mrGbMS.ClutchEfficiency
	
		self.mrGbMS.TorqueConverterLockupMs = getXMLFloat(xmlFile, xmlString .. "#torqueConverterLockupMs")
		if self.mrGbMS.CloseRpm < self.mrGbMS.RatedRpm and self.mrGbMS.TorqueConverterLockupMs == nil then
			self.mrGbMS.TorqueConverterLockupMs = 200
		end		
	
		default = 5000
		if torqueConverterProfile == "wheelLoader" then
			default = 20000
		end
		self.mrGbMS.TorqueConverterTime    = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#torqueConverterTime"), default )
		self.mrGbMS.TorqueConverterTimeInc = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#torqueConverterTimeInc"), 0 )
	end
	
	self.mrGbMS.MinClutchPercent        = getXMLFloat(xmlFile, xmlString .. "#minClutchRatio")
	if self.mrGbMS.MinClutchPercent == nil then 
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
	if self.mrGbMS.TorqueConverter then
		self.mrGbMS.MinClutchPercentTC    = self.mrGbMS.MinClutchPercent
		self.mrGbMS.MinClutchPercent      = 0
	end	
	if self.mrGbMS.MinClutchPercent < 2 * gearboxMogli.minClutchPercent then 
		self.mrGbMS.MinClutchPercent      = 2 * gearboxMogli.minClutchPercent 
	end	
	
	self.mrGbMS.ClutchTimeInc           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeIncreaseMs"), clutchEngagingTimeMs )
	self.mrGbMS.ClutchTimeDec           = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchTimeDecreaseMs"), clutchEngagingTimeMs ) 		
	self.mrGbMS.ClutchShiftTime         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#clutchShiftingTimeMs"), 0.5 * self.mrGbMS.ClutchTimeDec) 
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
	
	self.mrGbMS.GearsOnlyStopped        = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".gears#onlyStopped"), false) 
	self.mrGbMS.Range1OnlyStopped       = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(0)#onlyStopped"), false) 
	self.mrGbMS.Range2OnlyStopped       = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".ranges(1)#onlyStopped"), false) 
	self.mrGbMS.ReverseOnlyStopped      = Utils.getNoNil(getXMLBool(xmlFile, xmlString .. ".reverse#onlyStopped"), false) 
	
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

	self.mrGbMS.ManualClutchGear      	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".gears#manualClutch"),     self.mrGbMS.ClutchAfterShiftGear + 0.1 <= self.mrGbMS.MaxClutchPercent )
	self.mrGbMS.ManualClutchHl        	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(0)#manualClutch"), self.mrGbMS.ClutchAfterShiftHl + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	self.mrGbMS.ManualClutchRanges2   	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. ".ranges(1)#manualClutch"), self.mrGbMS.ClutchAfterShiftRanges2 + 0.1 <= self.mrGbMS.MaxClutchPercent ) 
	
	self.mrGbMS.ShiftNoThrottleGear   	= getXMLBool( xmlFile, xmlString .. ".gears#shiftNoThrottle")
	self.mrGbMS.ShiftNoThrottleHl     	= getXMLBool( xmlFile, xmlString .. ".ranges(0)#shiftNoThrottle")
	self.mrGbMS.ShiftNoThrottleRanges2	= getXMLBool( xmlFile, xmlString .. ".ranges(1)#shiftNoThrottle") 		
	
	self.mrGbMS.GlobalRatioFactor       = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#globalRatioFactor"), 1 ) --1.025 )

	local revUpMs0                      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revUpMs"),  self.mrGbMG.DefaultRevUpMs0 ) 
	local f                             = revUpMs0 /  math.max(1,self.mrGbMG.DefaultRevUpMs0)
	local revUpMs1 = gearboxMogli.getNoNil2( getXMLFloat(xmlFile, xmlString .. "#revUpMsFullLoad"), self.mrGbMG.DefaultRevUpMs1 * f, self.mrGbMG.DefaultRevUpMsH * f, hasHydrostat )
	local revUpMs2                      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revUpMsNeutral"),  self.mrGbMG.DefaultRevUpMs2 * f ) 
	local revDownMs                     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. "#revDownMs"), self.mrGbMG.DefaultRevDownMs * f ) 
	self.mrGbMS.RpmIncFactor            = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 10, revUpMs0 )
	self.mrGbMS.RpmIncFactorFull        = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 10, revUpMs1 )
	self.mrGbMS.RpmIncFactorNeutral     = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 10, revUpMs2 )
	self.mrGbMS.RpmDecFactor            = ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) / math.max( 10, revDownMs )
	
--**************************************************************************************************	
-- Sound parameter
--**************************************************************************************************		
	self.mrGbMS.IdlePitchFactor         = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idlePitchFactor"), -1 )
	self.mrGbMS.IdlePitchMax            = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#idlePitchMax"), -1 )
	self.mrGbMS.RunPitchFactor          = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runPitchFactor"), -1 )
	self.mrGbMS.RunPitchMax             = Utils.getNoNil(getXMLFloat(xmlFile, xmlString .. "#runPitchMax"), -1 )
	self.mrGbMS.Run2PitchEffect         = getXMLFloat(xmlFile, xmlString .. "#run2PitchEffect" )
		
	if xmlSource == "vehicle" then
		self.mrGbMS.BlowOffVentilFile           = getXMLString( xmlFile, xmlString.. ".blowOffVentilSound#file" )
		self.mrGbMS.BlowOffVentilVolume         = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".blowOffVentilSound#volume" ), 1 )
		self.mrGbMS.GrindingSoundFile           = getXMLString( xmlFile, xmlString.. ".grindingGearsSound#file" )
		self.mrGbMS.GrindingSoundVolume         = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".grindingGearsSound#volume" ), 1 )
		self.mrGbMS.HandbrakePullSoundFile      = getXMLString( xmlFile, xmlString.. ".handbrakePullSound#file" )
		self.mrGbMS.HandbrakePullSoundVolume    = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".handbrakePullSound#volume" ), 1 )
		self.mrGbMS.HandbrakeReleaseSoundFile   = getXMLString( xmlFile, xmlString.. ".handbrakeReleaseSound#file" )
		self.mrGbMS.HandbrakeReleaseSoundVolume = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".handbrakeReleaseSound#volume" ), 1 )
		self.mrGbMS.GearShiftSoundFile          = getXMLString( xmlFile, xmlString.. ".gearShiftSound#file" )
		self.mrGbMS.GearShiftSoundVolume        = Utils.getNoNil( getXMLFloat( xmlFile, xmlString.. ".gearShiftSound#volume" ), 1 )
	else
		self.mrGbMS.BlowOffVentilFile           = nil
		self.mrGbMS.BlowOffVentilVolume         = 0
		self.mrGbMS.GrindingSoundFile           = nil
		self.mrGbMS.GrindingSoundVolume         = 0
		self.mrGbMS.HandbrakePullSoundFile      = nil
		self.mrGbMS.HandbrakePullSoundVolume    = 1
		self.mrGbMS.HandbrakeReleaseSoundFile   = nil
		self.mrGbMS.HandbrakeReleaseSoundVolume = 1
		self.mrGbMS.GearShiftSoundFile          = nil
		self.mrGbMS.GearShiftSoundVolume        = 1 		
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
		local dft   = tostring(i)
		if hasHydrostat and self.mrGbMS.DisableManual then
			dft       = ""
		end
		local name  = Utils.getNoNil(getXMLString(xmlFile, baseName .. "#name"), dft) 

		local newEntry = gearboxMogli.completeXMLGearboxEntry( xmlFile, baseName, {speed=speed/3.6,name=name} )
		
		if newEntry.forwardOnly == nil and ( reverseMinGear ~= nil or reverseMaxGear ~= nil ) then
			newEntry.forwardOnly = not ( ( reverseMinGear == nil or i >= reverseMinGear ) and ( reverseMaxGear == nil or i <= reverseMaxGear ) )
		end		
		
		if newEntry.forwardOnly then fo = true end
		if newEntry.reverseOnly then ro = true end
			
		newEntry.upRangeOffset   = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#upRangeOffset" ),  -gearRangeOffset ) 
		newEntry.downRangeOffset = Utils.getNoNil( getXMLInt( xmlFile, baseName .. "#downRangeOffset" ), gearRangeOffset ) 
		newEntry.hydrostaticCoupling = getXMLString( xmlFile, baseName .. "#hydrostaticCoupling" )
		
		local r = 0
		while true do
			local baseName2 = baseName .. string.format(".extraName(%d)",r)
			r = r + 1
			local extraName  = getXMLString(xmlFile, baseName2 .. "#name")
			local extraSpeed = getXMLFloat(xmlFile, baseName2 .. "#speed")
			if extraName == nil and extraSpeed == nil then
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
			newEntry.extraNames[r1][r2] = { name = extraName, speed = extraSpeed }
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
	self.mrGbMS.ManualClutchReverse   	= getXMLBool( xmlFile, xmlString .. ".reverse#manualClutch")
	if self.mrGbMS.ManualClutchReverse == nil then
		-- unsupported parameter; but keep default handling for reverse#manualClutch
		local f = getXMLFloat(xmlFile, xmlString .. ".reverse#clutchRatio")
		if f ~= nil then
			self.mrGbMS.ManualClutchReverse = f + 0.1 <= self.mrGbMS.MaxClutchPercent
		elseif self.mrGbMS.ReverseOnlyStopped then
			self.mrGbMS.ManualClutchReverse = true
		elseif self.mrGbMS.AutoStartStop      then
			self.mrGbMS.ManualClutchReverse = false 
		elseif  self.mrGbMS.ManualClutchGear
				and self.mrGbMS.ManualClutchHl 
				and self.mrGbMS.ManualClutchRanges2 then
			self.mrGbMS.ManualClutchReverse = true
		else
			self.mrGbMS.ManualClutchReverse = false
			for _,attr in pairs({"Gears","Ranges","Ranges2"}) do
				for _,g in pairs( self.mrGbMS[attr] ) do
					if g.reverseOnly then
						if     attr == "Gears"  then
							self.mrGbMS.ManualClutchReverse = self.mrGbMS.ManualClutchGear 
						elseif attr == "Ranges" then
							self.mrGbMS.ManualClutchReverse = self.mrGbMS.ManualClutchHl 
						else
							self.mrGbMS.ManualClutchReverse = self.mrGbMS.ManualClutchRanges2 
						end
						break
					end
				end
				if self.mrGbMS.ManualClutchReverse then
					break
				end
			end
		end
	end
	self.mrGbMS.ManualClutchNeutral   	= Utils.getNoNil(getXMLBool( xmlFile, xmlString .. "#manualClutchNeutral"),    not self.mrGbMS.AutoStartStop )
	--**************************************************************************************************		
	
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
				self.mrGbMS.MatchGears  = "range" -- "true"
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
	
	if       self.mrGbMS.MatchGears  ~= "end"
			and  self.mrGbMS.MatchGears  ~= "true" then
		self.mrGbMS.MatchGears           = "false"
	end
	if       self.mrGbMS.MatchRanges ~= "end"
			and  self.mrGbMS.MatchRanges ~= "true" then
		self.mrGbMS.MatchRanges          = "false"
	end
	
	self.mrGbMS.MatchRanges0 = self.mrGbMS.MatchRanges 
	self.mrGbMS.MatchGears0  = self.mrGbMS.MatchGears  
	
--**************************************************************************************************	
	
	local function countFR( array )
		local f, r = 0, 0
		for _,item in pairs(array) do
			if     item.forwardOnly then
				f = f + 1
			elseif item.reverseOnly then
				r = r + 1
			else
				f = f + 1
				r = r + 1
			end
		end
		return f,r
	end

	self.mrGbMS.CountGearsF,  self.mrGbMS.CountGearsR  = countFR( self.mrGbMS.Gears )
	self.mrGbMS.CountRange1F, self.mrGbMS.CountRange1R = countFR( self.mrGbMS.Ranges )
	self.mrGbMS.CountRange2F, self.mrGbMS.CountRange2R = countFR( self.mrGbMS.Ranges2 )
	
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
	hydroMaxTorque                        = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxTorque")
	if hydroMaxTorque ~= nil then
		hydroMaxTorque = hydroMaxTorque * 0.001
	end
	local hit = 1000
	local hdt = 1000
	self.mrGbMS.HydrostaticDirect         = getXMLBool(xmlFile, xmlString .. ".hydrostatic#direct")
	hydroCorrectGearSpeed = getXMLBool(xmlFile, xmlString .. ".hydrostatic#correctGearSpeed")
	
	local lftr = 0
	local lfrr = 0
	local mrfg = 0

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
			self.mrGbMS.HydrostaticStart       = 0.666666667
			hit                                = 2000
			hdt                                = 2000
			self.mrGbMS.HydrostaticMin         = 0
			self.mrGbMS.HydrostaticMax         = 1.333333333
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticEfficiency  = {}
			
			mrfg = self.mrGbMG.hydroMaxTorqueInput
						
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
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.67,v=0.800})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.75,v=0.750})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=2.00,v=gearboxMogli.hydroEffMin })
			
			i = table.getn( self.mrGbMS.HydrostaticEfficiency )
		elseif self.mrGbMS.HydrostaticProfile == "Output" then
			hit = 5000
			hdt = 5000
			self.mrGbMS.HydrostaticMin = -0.7
			self.mrGbMS.HydrostaticMax = 1
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticEfficiency  = {}

			mrfg = self.mrGbMG.hydroMaxTorqueOutput
			
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-1	 ,v=0.65 })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=-0.01,v=0.82 })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0	   ,v=gearboxMogli.hydroEffMin })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=0.01 ,v=0.825})
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1	   ,v=0.98 })
			table.insert(self.mrGbMS.HydrostaticEfficiency, {time=1.5  ,v=0.89 })

			i = table.getn( self.mrGbMS.HydrostaticEfficiency )
		elseif self.mrGbMS.HydrostaticProfile == "Direct" then
			hit = 500
		  hdt = 500
			self.mrGbMS.HydrostaticMin = -1
			self.mrGbMS.HydrostaticMax = 1
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticPtoDiff     = 200			
			self.mrGbMS.HydrostaticEfficiency  = {}
			
			lftr = 0.3
			lfrr = 0.1
			mrfg = self.mrGbMG.hydroMaxTorqueDirect

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
		elseif self.mrGbMS.HydrostaticProfile == "Hydrostat" then
		--self.mrGbMS.HydrostaticCoupling = "Direct"
			self.mrGbMS.HydrostaticMin = -1
			self.mrGbMS.HydrostaticMax =  1
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticPtoDiff     = 200				
			self.mrGbMS.HydrostaticEfficiency  = {}
			
			lftr = 1.0
			lfrr = 0.1
			mrfg = self.mrGbMG.hydroMaxTorqueDirect
			
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
			
		elseif self.mrGbMS.HydrostaticProfile == "Compound" then
			self.mrGbMS.HydrostaticMin = 0
			self.mrGbMS.HydrostaticMax = 1
			self.mrGbMS.TransmissionEfficiency = 0.98
			self.mrGbMS.HydrostaticEfficiency  = {}
			
			mrfg = self.mrGbMG.hydroMaxTorqueOutput
			
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

		if mrfg <= 0 then
			if hydroMaxTorque ~= nil then
				mrfg = hydroMaxTorque / maxTorque
			else
				mrfg = gearboxMogli.huge
			end
		end
		
		self.mrGbMS.HydrostaticLossFxTorqueRatio = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#lossFxTorqueRatio"), lftr )
		self.mrGbMS.HydrostaticLossFxRpmRatio    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#lossFxRpmRatio"),    lfrr )
		self.mrGbMS.HydrostaticMaxTorqueFactor   = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxTorqueFactor"),   mrfg )
		
		if     self.mrGbMS.HydrostaticPressure    ~= nil 
				or self.mrGbMS.HydrostaticVolumePump  ~= nil
				or self.mrGbMS.HydrostaticVolumeMotor ~= nil 
				or self.mrGbMS.HydrostaticCoupling    ~= nil then
				
			if self.mrGbMS.HydrostaticProfile == nil then
				print("FS17_GearboxAddon: Warning! Hydrostatic coupling is only experimental")
			end
				
			if self.mrGbMS.HydrostaticMin      == nil then
				self.mrGbMS.HydrostaticMin      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#minRatio"), -1 )
			end
			if self.mrGbMS.HydrostaticMax      == nil then
				self.mrGbMS.HydrostaticMax      = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRatio"), 1.41421356 )
			end
			if self.mrGbMS.HydrostaticPressure == nil then
				self.mrGbMS.HydrostaticPressure = 550
			end
	
			self.mrGbMS.HydrostaticPressDelta = self.mrGbMS.HydrostaticPressure / math.max( 1, Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#pressureChangeMs"), 300 ) )
			
			self.mrGbMS.HydroPumpMotorEff     = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#efficiency"), 0.95 )
			self.mrGbMS.HydroInputRPMRatio    = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#inputRpmFactor"), 4500 / self.mrGbMS.RatedRpm )
			self.mrGbMS.HydroOutputRPMRatio   = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#outputRpmFactor"), self.mrGbMS.HydroInputRPMRatio )
	
			if self.mrGbMS.HydrostaticCoupling == nil then
				self.mrGbMS.HydrostaticCoupling = "Direct"
			end
			
			if self.mrGbMS.HydrostaticVolumePump  == nil and self.mrGbMS.HydrostaticVolumeMotor == nil then
				local t = maxTorque
				if hydroMaxTorque ~= nil then
					t = hydroMaxTorque
				end
				self.mrGbMS.HydrostaticVolumePump   = 20000  * t * math.pi / self.mrGbMS.HydrostaticPressure
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
		dft = Utils.clamp( Utils.getNoNil( self.mrGbMS.HydrostaticStart, 0.3 ), self.mrGbMS.HydrostaticMin, self.mrGbMS.HydrostaticMax )
		self.mrGbMS.HydrostaticStart  = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#startFactor"), dft )
		dft = Utils.getNoNil( self.mrGbMS.HydrostaticMaxRpm, self.mrGbMS.RatedRpm )
		self.mrGbMS.HydrostaticMaxRpm = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRpm"), dft )
		dft = Utils.getNoNil( self.mrGbMS.HydrostaticPtoDiff, gearboxMogli.ptoRpmHydroDiff )
		self.mrGbMS.HydrostaticPtoDiff = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#ptoRpmDelta"), dft )
		
		dft = Utils.getNoNil( self.mrGbMS.HydrostaticMaxRpmLow, 0.8 * self.mrGbMS.HydrostaticMaxRpm )
		self.mrGbMS.HydrostaticMaxRpmLow       = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRpmLow" ),      dft )
		dft = Utils.getNoNil( self.mrGbMS.HydrostaticMaxRpmSpeedLow,  10 )
		self.mrGbMS.HydrostaticMaxRpmSpeedLow  = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRpmLowSpeed" ), dft )
		dft = Utils.getNoNil( self.mrGbMS.HydrostaticMaxRpmSpeedHigh, 20 )
		self.mrGbMS.HydrostaticMaxRpmSpeedHigh = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxRpmSpeed"), dft )
		
		dft = Utils.getNoNil( self.mrGbMS.TransmissionEfficiency, 0.98 )
		self.mrGbMS.TransmissionEfficiency = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#baseEfficiency"), dft )
		
		dft = getXMLFloat(xmlFile, xmlString .. ".hydrostatic#minMaxTimeMs")
		if dft == nil then
			dft = hit
		else
			hdt = hit
		end
		if dft < 10 then
			-- do not smooth 
			self.mrGbMS.HydrostaticIncFactor = 1
		else
			self.mrGbMS.HydrostaticIncFactor = 1 / dft
		end
		dft = Utils.getNoNil( getXMLFloat(xmlFile, xmlString .. ".hydrostatic#maxMinTimeMs"), hdt )
		if dft < 10 then
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
				and hydroCorrectGearSpeed then
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
					or self.mrGbMS.HydrostaticCoupling ~= "Direct" then
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
	self.mrGbMS.EnableAI0   = self.mrGbMS.EnableAI
	
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

	self.mrGbMS.sendTargetRpm   = self.mrGbMS.DrawTargetRpm
	self.mrGbMS.sendReqPower    = self.mrGbMS.DrawReqPower
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

	self.mrGbMS.EqualizedRpmFactor   = ( self.mrGbMS.OrigRatedRpm - self.mrGbMS.OrigMinRpm ) / ( self.mrGbMS.RatedRpm - self.mrGbMS.IdleRpm ) 
	if self.mrGbMS.Sound.MaxRpm ~= self.mrGbMS.OrigRatedRpm and self.mrGbMS.Sound.MaxRpm > gearboxMogli.eps then
		self.mrGbMS.EqualizedRpmFactor = self.mrGbMS.EqualizedRpmFactor * self.mrGbMS.OrigRatedRpm / self.mrGbMS.Sound.MaxRpm
	end
	self.mrGbMS.EqualizedMaxRpm      = self:mrGbMGetEqualizedRpm( self.mrGbMS.CurMaxRpm )
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
		if self.sampleMotorLoad ~= nil and self.sampleMotorLoad.volume ~= nil then
			self.mrGbMS.Sound.MotorLoadVolume       = self.sampleMotorLoad.volume / 0.8
		end
	end
	
--**********************************************************************************************************		
-- differentials
--**********************************************************************************************************		
	self.mrGbMS.ModifyDifferentials = false
	
	if self.mrGbMG.manual4wd and self.differentials ~= nil and table.getn(self.differentials) == 3 then
		local md = getXMLBool(xmlFile, xmlString .. "#manual4wd")
		if md == nil then
			if self.mrGbMS.IsCombine then
				md = self.mrIsMrVehicle 
			else
				md = true
			end
		end
		
		if md then
			local pattern = {true, true, false}
			self.mrGbMS.ModifyDifferentials = true
			for k,differential in pairs(self.differentials) do
				self.mrGbMS.ModifyDifferentials = self.mrGbMS.ModifyDifferentials and differential.diffIndex1IsWheel==pattern[k] and differential.diffIndex2IsWheel==pattern[k]
			end				
		end
		
		if self.mrGbMS.ModifyDifferentials then
			local profile = getXMLString( xmlFile, xmlString .. ".differentials#profile")
			if     profile == nil then
				if     self.articulatedAxis ~= nil then
					profile = "permanent"
				elseif self.mrGbMS.AutoStartStop then
					profile = "lsd" 
				end
			end
			
			-- torque ratio  1 => everything to front 
			-- torque ratio  0 => everything to back 
			-- torque sense  1 => open differential
			-- torque sense  0 => constant torque distribution 
			-- torque sense -1 => torque goes to the slowest wheel (torsen) 
			
			self.mrGbMS.TorqueRatioMiddle = 0
			self.mrGbMS.TorqueSenseMiddle = 0
			self.mrGbMS.SpeedRatioMiddle  = self.differentials[3].maxSpeedRatio
			self.mrGbMS.TorqueRatioFront  = self.differentials[1].torqueRatio
			self.mrGbMS.TorqueSenseFront  = 1
			self.mrGbMS.SpeedRatioFront   = 1
			self.mrGbMS.TorqueRatioBack   = self.differentials[2].torqueRatio
			self.mrGbMS.TorqueSenseBack   = 0.75
			self.mrGbMS.SpeedRatioBack    = 1
			
			-- profile == "manual" is default 
			if     profile == "off"       then
				self.mrGbMS.TorqueRatioMiddle = -1
				self.mrGbMS.TorqueRatioFront  = -1
				self.mrGbMS.TorqueRatioBack   = -1
			elseif profile == "lsd"       then
				self.mrGbMS.TorqueSenseBack   = 0.25
			elseif profile == "permanent" then
				self.mrGbMS.TorqueRatioMiddle = 0.5
			elseif profile == "torsen1"   then
				self.mrGbMS.TorqueRatioMiddle = 0.5
				self.mrGbMS.TorqueSenseMiddle = -1
				self.mrGbMS.SpeedRatioBack    = self.differentials[2].maxSpeedRatio
			elseif profile == "torsen2"   then
				self.mrGbMS.TorqueRatioMiddle = 0.5
				self.mrGbMS.TorqueSenseMiddle = -1
				self.mrGbMS.TorqueRatioBack   = 0.5
				self.mrGbMS.TorqueSenseBack   = -1
				self.mrGbMS.SpeedRatioBack    = math.max( 1.3, self.differentials[2].maxSpeedRatio )
			elseif profile == "torsen3"   then
				self.mrGbMS.TorqueRatioMiddle = 0.5
				self.mrGbMS.TorqueSenseMiddle = -1
				self.mrGbMS.TorqueRatioFront  = 0.5
				self.mrGbMS.TorqueSenseFront  = -1
				self.mrGbMS.SpeedRatioFront   = math.max( 1.3, self.differentials[1].maxSpeedRatio )
				self.mrGbMS.TorqueRatioBack   = 0.5
				self.mrGbMS.TorqueSenseBack   = -1
				self.mrGbMS.SpeedRatioBack    = math.max( 1.3, self.differentials[2].maxSpeedRatio )
			end
		
			self.mrGbMS.TorqueRatioMiddle = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.middle#torqueRatio"  ), self.mrGbMS.TorqueRatioMiddle )
			self.mrGbMS.TorqueSenseMiddle = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.middle#limitedSlip"  ), self.mrGbMS.TorqueSenseMiddle )
			self.mrGbMS.SpeedRatioMiddle  = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.middle#maxSpeedRatio"), self.mrGbMS.SpeedRatioMiddle )
			self.mrGbMS.TorqueRatioFront  = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.front#torqueRatio"   ), self.mrGbMS.TorqueRatioFront  )
			self.mrGbMS.TorqueSenseFront  = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.front#limitedSlip"   ), self.mrGbMS.TorqueSenseFront  )
			self.mrGbMS.SpeedRatioFront   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.front#maxSpeedRatio" ), self.mrGbMS.SpeedRatioFront  )
			self.mrGbMS.TorqueRatioBack   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.back#torqueRatio"    ), self.mrGbMS.TorqueRatioBack   )
			self.mrGbMS.TorqueSenseBack   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.back#limitedSlip"    ), self.mrGbMS.TorqueSenseBack   )
			self.mrGbMS.SpeedRatioBack    = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.back#maxSpeedRatio"  ), self.mrGbMS.SpeedRatioBack   )
		end
	elseif self.mrGbMG.manual4wd and self.differentials ~= nil and table.getn(self.differentials) == 1 then
		self.mrGbMS.ModifyDifferentials = Utils.getNoNil( getXMLBool(xmlFile, xmlString .. "#manual4wd"), true )
		if self.mrGbMS.ModifyDifferentials then
			local profile = getXMLString( xmlFile, xmlString .. ".differentials#profile")
		
			self.mrGbMS.TorqueRatioMiddle = -1
			self.mrGbMS.TorqueSenseMiddle = 0
			self.mrGbMS.SpeedRatioMiddle  = 1
			self.mrGbMS.TorqueRatioFront  = -1
			self.mrGbMS.TorqueSenseFront  = 1
			self.mrGbMS.SpeedRatioFront   = 1
			self.mrGbMS.TorqueRatioBack   = self.differentials[1].torqueRatio
			self.mrGbMS.TorqueSenseBack   = 0.75
			self.mrGbMS.SpeedRatioBack    = 1
			
			if     profile == "off"       then
				self.mrGbMS.TorqueRatioBack   = -1
			elseif profile == "lsd"       then
				self.mrGbMS.TorqueSenseBack   = 0.25
			elseif profile == "torsen"    then
				self.mrGbMS.TorqueRatioBack   = 0.5
				self.mrGbMS.TorqueSenseBack   = -1
				self.mrGbMS.SpeedRatioBack    = math.max( 1.3, self.differentials[1].maxSpeedRatio )
			end

			self.mrGbMS.TorqueRatioBack   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.back#torqueRatio"    ), self.mrGbMS.TorqueRatioBack   )
			self.mrGbMS.TorqueSenseBack   = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.back#limitedSlip"    ), self.mrGbMS.TorqueSenseBack   )
			self.mrGbMS.SpeedRatioBack    = Utils.getNoNil( getXMLFloat( xmlFile, xmlString .. ".differentials.back#maxSpeedRatio"  ), self.mrGbMS.SpeedRatioBack   )
		end
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
	self.mrGbMS.IsOnOff       = true
	self.mrGbMS.NeutralActive = self.mrGbMS.AutoStartStop	
	self.mrGbMS.CurrentGear   = self.mrGbMS.DefaultGear
	self.mrGbMS.CurrentRange  = self.mrGbMS.DefaultRange
	self.mrGbMS.CurrentRange2 = self.mrGbMS.DefaultRange2
	self.mrGbMS.NewGear       = self.mrGbMS.DefaultGear
	self.mrGbMS.NewRange      = self.mrGbMS.DefaultRange
	self.mrGbMS.NewRange2     = self.mrGbMS.DefaultRange2
	self.mrGbMS.ManualClutch  = 1
	self.mrGbMS.Automatic     = false
	self:mrGbMSetAutomatic(true,true)
-- set the default values for SERVER		
--**********************************************************************************************************		


--**********************************************************************************************************		
-- Try to initialize motor during load
--**********************************************************************************************************		
	if Vehicle.mrLoadFinished == nil and self.mrGbMG.initMotorOnLoad and self.motor ~= nil and self.motor.minRpm ~= nil and self.motor.minRpm > 0 then
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
-- fuel usage
--**********************************************************************************************************			
local function gearboxMogliUpdateFuelUsage( self, dt )

	self.mrGbML.fuelUsageRaw = 0
	
	if self.isMotorStarted and self.mrGbMS ~= nil and self.mrGbMS.IsOn and self.motor.prevMotorRpm ~= nil then		
		local rpm
		if self.motor.lastRealMotorRpm ~= nil then
			rpm = 0.5 * ( self.motor.lastRealMotorRpm + self.motor.prevMotorRpm )
		else
			rpm = self.motor.lastRealMotorRpm
		end
		if self.motor.maxPossibleRpm ~= nil and rpm > self.motor.maxPossibleRpm then
			rpm = self.motor.maxPossibleRpm
		elseif rpm < self.mrGbMS.CurMinRpm then
			rpm = self.mrGbMS.CurMinRpm
		end
		local torque = math.max( self.motor.fuelMotorTorque, 0 )
		local motor  = self.motor.currentTorqueCurve:get( rpm ) --math.max( self.motor.lastMotorTorque, torque )		
		local tRatio = 1
		
		if self.motor.noTorque or motor <= 0 then
			tRatio = 0
			torque = 0
		elseif torque < motor then
			tRatio = torque / motor
		else
			rRatio = 1
			torque = motor 
		end
		
		local fuelUsed = self.motor.fuelCurve:get( rpm ) * torque
		local f0 = fuelUsed 
		if rpm > self.mrGbMS.RatedRpm then
			fuelUsed = math.max( fuelUsed, self.motor.ratedFuelRatio * self.motor.maxRatedTorque * tRatio * rpm / self.mrGbMS.RatedRpm )
		end
		
		local f1 = fuelUsed 
		
		fuelUsed   = fuelUsed * rpm * gearboxMogli.powerFactorP
		fuelUsed   = fuelUsed * gearboxMogli.fuelFactor / gearboxMogli.powerFuelCurve:get( tRatio )
		
		if self.mrGbMG.debugInfo then
			self.mrGbML.fuelInfo = string.format( "%4d (%4d), %3.0f%%, %4.0fNm, %4.0fNm => %5.2fl/h",
															rpm,
															self.mrGbMS.RatedRpm,
															tRatio*100,
															torque*1000,
															motor*1000,
															fuelUsed * 3600000 )
		end
										
		if fuelUsed > 0 then
			self.mrGbML.fuelUsageRaw = fuelUsed*3600000 -- liters per hour
			if g_currentMission.missionInfo.fuelUsageLow and not ( self.mrIsMrVehicle ) then
				fuelUsed = fuelUsed * 0.7
			end
										
			fuelUsed = fuelUsed * dt
			
			if self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel then
				if self.BetterFuelUsage ~= nil and self.BetterFuelUsage.helperFuelUsed ~= nil then
					self.BetterFuelUsage.helperFuelUsed = self.BetterFuelUsage.helperFuelUsed + fuelUsed
				end
				local delta = fuelUsed * g_currentMission.economyManager:getPricePerLiter(FillUtil.FILLTYPE_FUEL)
				g_currentMission.missionStats:updateStats("expenses", delta)
				g_currentMission:addSharedMoney(-delta, "purchaseFuel")
			else
				self:setFuelFillLevel(self.fuelFillLevel-fuelUsed)
				g_currentMission.missionStats:updateStats("fuelUsage", fuelUsed)
			end
			
			self.mrGbML.fuelUsageAvg = self.mrGbML.fuelUsageAvg + fuelUsed * 3600000
		end
		self.mrGbML.fuelUsageDt = self.mrGbML.fuelUsageDt  + dt

		if self.mrGbML.fuelUsageDt > 166 then
			local a = self.mrGbML.fuelUsageAvg
			local t = self.mrGbML.fuelUsageDt
			
			if self.mrGbML.fuelUsageList ~= nil then
				for i,l in pairs(self.mrGbML.fuelUsageList) do
					a = a + l.a
					t = t + l.t
				end
			end
			
			self.mrGbML.fuelUsageRate = a / t
			if self.fuelUsageHud ~= nil then
				VehicleHudUtils.setHudValue(self, self.fuelUsageHud, self.mrGbML.fuelUsageRate )
			end
			
			if self.mrGbML.fuelUsageList ~= nil then
				local j = table.getn( self.mrGbML.fuelUsageList )
				if j < 5 then
					self.mrGbML.fuelUsageList[j+1] = { a = self.mrGbML.fuelUsageList[j].a, t = self.mrGbML.fuelUsageList[j].t }
				end
				for i=j,2,-1 do
					self.mrGbML.fuelUsageList[i].a = self.mrGbML.fuelUsageList[i-1].a     
					self.mrGbML.fuelUsageList[i].t = self.mrGbML.fuelUsageList[i-1].t
				end
				self.mrGbML.fuelUsageList[1].a = self.mrGbML.fuelUsageAvg
				self.mrGbML.fuelUsageList[1].t = self.mrGbML.fuelUsageDt 
			else
				self.mrGbML.fuelUsageList = {{ a = self.mrGbML.fuelUsageAvg, t = self.mrGbML.fuelUsageDt }}
			end
			self.mrGbML.fuelUsageAvg = 0
			self.mrGbML.fuelUsageDt  = 0
		end
		
	elseif self.mrGbML.fuelUsageRate > 0 or self.mrGbML.fuelUsageList ~= nil then
		if self.fuelUsageHud ~= nil then
			VehicleHudUtils.setHudValue(self, self.fuelUsageHud, 0)
		end
		
		self.mrGbML.fuelUsageRaw  = 0
		self.mrGbML.fuelUsageRate = 0
		self.mrGbML.fuelUsageAvg  = 0
    self.mrGbML.fuelUsageDt   = 0
		self.mrGbML.fuelUsageList = nil
	end
	
	if self.mrIsMrVehicle then
		self.mrLastFuelRate = self.mrGbML.fuelUsageRaw 
	end
	
	return true
end
	
--function gearboxMogli:writeStream(streamId, connection)
--end
--function gearboxMogli:readStream(streamId, connection)
--end

--**********************************************************************************************************	
-- gearboxMogli:update
--**********************************************************************************************************	
function gearboxMogli:update(dt)

	gearboxMogli.mbSync(self)
	if not gearboxMogli.mbIsSynced(self) then
		if self.isEntered then print("not synchronized") end
		return
	end

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
		self.mrGbML.MotorLoad = self.mrGbML.MotorLoad + self.mrGbML.smoothMedium * ( math.min( self.actualLoadPercentage * 1.11, 1 ) - self.mrGbML.MotorLoad )
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
	elseif gearboxMogli.mbIsActiveForInput(self, false) then
		if     gearboxMogli.mbHasInputEvent( "gearboxMogliSETTINGS" ) then
			gearboxMogli.showSettingsUI( self )
			processInput = false
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliON_OFF" ) then
			if     self.steeringEnabled then
				gearboxMogli.enabledAtClient = not gearboxMogli.enabledAtClient
				if self.mrGbMS.NoDisable and not gearboxMogli.enabledAtClient then
					self:mrGbMSetState( "WarningText", "This gearbox is always enabled" )
				end
			elseif self.mrGbMS.EnableAI  ~= gearboxMogli.AIGearboxOff then
				self:mrGbMSetState( "EnableAI", gearboxMogli.AIGearboxOff )
			elseif self.mrGbMS.EnableAI0 ~= gearboxMogli.AIGearboxOff then
				self:mrGbMSetState( "EnableAI", self.mrGbMS.EnableAI0 )
			else
				self:mrGbMSetState( "EnableAI", gearboxMogli.AIGearboxOn )
			end
			processInput = false
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliAllAuto" ) then
			if     self.steeringEnabled then
				gearboxMogli.simplifiedAtClient = not gearboxMogli.simplifiedAtClient
				if gearboxMogli.simplifiedAtClient and not self:mrGbMGetHasAllAuto() then
					self:mrGbMSetState( "WarningText", "This gearbox does not have a simplified mode" )
				end
			elseif self.mrGbMS.EnableAI  ~= gearboxMogli.AIAllAuto then
				self:mrGbMSetState( "EnableAI", gearboxMogli.AIAllAuto )
			elseif self.mrGbMS.EnableAI0 ~= gearboxMogli.AIAllAuto then
				self:mrGbMSetState( "EnableAI", gearboxMogli.EnableAI0 )
			else
				self:mrGbMSetState( "EnableAI", gearboxMogli.AIGearboxOn )
			end
		end
	end
	
	local enabledAtClient = gearboxMogli.enabledAtClient or self.mrGbMS.NoDisable
	
	if self.isEntered and self.steeringEnabled and self.mrGbMS.IsOnOff ~= enabledAtClient then
		self:mrGbMSetIsOnOff( enabledAtClient ) 
		if self.isMotorStarted then
			self.mrGbML.turnOnMotorTimer = g_currentMission.time + 200
			self:stopMotor()
		end
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
	
	if      self.isMotorStarted
			and self.steeringEnabled
			and self.motor.minRpm > 0
			and self.mrGbMS.IsOnOff 
			and ( Vehicle.mrLoadFinished == nil or self.mrIsMrVehicle ~= nil ) then
		if self.mrGbML.motor == nil then 
	-- initialize as late as possible 			
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
		
--**********************************************************************************************************			
-- differentials
--**********************************************************************************************************			
	if      self.dCcheckModule ~= nil 
			and self:dCcheckModule("fourWDandDifferentials") 
			and self.mrGbMS.ModifyDifferentials then
		self:mrGbMSetState( "ModifyDifferentials", false )
	end
	if self.mrGbMS.ModifyDifferentials and self.isServer then
		if      self.mrGbMS.IsOn
				and self.steeringEnabled 
				and not self.mrGbMS.AllAuto
				and ( table.getn( self.differentials ) == 1 or table.getn( self.differentials ) == 3 ) then
      local getSpeedsOfDifferential;
      getSpeedsOfDifferential = function(self, diff)
				local speed1, speed2;
				if diff.diffIndex1IsWheel then
						local wheel = self.wheels[diff.diffIndex1];
						speed1 = getWheelShapeAxleSpeed(wheel.node, wheel.wheelShape) * wheel.radius;
				else
						local s1,s2 = getSpeedsOfDifferential(self, self.differentials[diff.diffIndex1+1]);
						speed1 = (s1+s2)/2;
				end
				if diff.diffIndex2IsWheel then
						local wheel = self.wheels[diff.diffIndex2];
						speed2 = getWheelShapeAxleSpeed(wheel.node, wheel.wheelShape) * wheel.radius;
				else
						local s1,s2 = getSpeedsOfDifferential(self, self.differentials[diff.diffIndex2+1]);
						speed2 = (s1+s2)/2;
				end
				return speed1,speed2;
      end
			
			local function unlockDiff( self, idx, diff )
				local speed1, speed2 = getSpeedsOfDifferential( self, diff )
				
				if     speed1 * speed2 >= 0 then
					speed1 = math.abs( speed1 )
					speed2 = math.abs( speed2 )
				elseif math.abs( speed1 ) > math.abs( speed2 ) then
					speed1 = math.abs( speed1 )
					speed2 = 0
				else
					speed1 = 0
					speed2 = math.abs( speed2 )
				end
				
				--  1 => full torque to wheel 1
				-- -1 => full torque to wheel 2
				
				local r = 0
								
				if     math.abs( speed1 - speed2 ) < gearboxMogli.eps then
					r = 0
				elseif speed1 > gearboxMogli.eps and speed2 > gearboxMogli.eps then
					if diff.mogliSpeedRatio > 1.01 then
						if     speed1 < speed2 then
							speed1 = math.min( speed1 * diff.mogliSpeedRatio, speed2 )
						elseif speed2 < speed1 then 
							speed2 = math.min( speed2 * diff.mogliSpeedRatio, speed1 )
						end
					end
					
					if     speed2 < speed1 then
						r = 1 - speed2 / speed1
					elseif speed1 < speed2 then
						r = speed1 / speed2 - 1
					end
				elseif speed1 > gearboxMogli.eps then
					r = 1
				elseif speed2 > gearboxMogli.eps then
					r = -1
				end
				
				diff.lastMogliFactor = r
				
				local tr0 = diff.mogliTorqueRatio
				local lsd = diff.mogliTorqueSense
		
				if diff.lastMogliTorqueRatio == nil then
					diff.lastMogliTorqueRatio = diff.mogliTorqueRatio
				end
				local q = tr0 + lsd * r * 0.5
				diff.lastMogliTorqueRatio = Utils.clamp( diff.lastMogliTorqueRatio + self.mrGbML.smoothLittle * ( q - diff.lastMogliTorqueRatio ), 0, 1 )
			--diff.lastMogliTorqueRatio = Utils.clamp( q, 0, 1 )
				updateDifferential(self.motorizedNode,idx-1,diff.lastMogliTorqueRatio,gearboxMogli.huge)
			end
		
		
			if     table.getn( self.differentials ) == 1 then 
				diff = self.differentials[1]
				diff.mogliLocked      = self:mrGbMGetDiffLockBack()
				diff.mogliTorqueRatio = self.mrGbMS.TorqueRatioBack
				diff.mogliTorqueSense = self.mrGbMS.TorqueSenseBack
				diff.mogliSpeedRatio  = self.mrGbMS.SpeedRatioBack
			elseif table.getn( self.differentials ) == 3 then 
				local diff = self.differentials[3]
				diff.mogliLocked      = self:mrGbMGetDiffLockMiddle() 
				diff.mogliTorqueRatio = self.mrGbMS.TorqueRatioMiddle
				diff.mogliTorqueSense = self.mrGbMS.TorqueSenseMiddle
				diff.mogliSpeedRatio  = self.mrGbMS.SpeedRatioMiddle
				
				diff = self.differentials[1]
				diff.mogliLocked      = self:mrGbMGetDiffLockFront()
				diff.mogliTorqueRatio = self.mrGbMS.TorqueRatioFront
				diff.mogliTorqueSense = self.mrGbMS.TorqueSenseFront
				diff.mogliSpeedRatio  = self.mrGbMS.SpeedRatioFront
				
				diff = self.differentials[2]
				diff.mogliLocked      = self:mrGbMGetDiffLockBack()
				diff.mogliTorqueRatio = self.mrGbMS.TorqueRatioBack
				diff.mogliTorqueSense = self.mrGbMS.TorqueSenseBack
				diff.mogliSpeedRatio  = self.mrGbMS.SpeedRatioBack
			end			
			
			for i,diff in pairs( self.differentials ) do
				local m = 0
				if     diff.mogliTorqueRatio             <=-0.01 then
					m = 1
				elseif diff.mogliLocked                          then
					m = 2
				elseif math.abs( diff.mogliTorqueSense ) <= 0.01 then
					m = 3
				else
					m = 4
				end
				if m == 4 then
					unlockDiff( self, i, diff )
				elseif diff.mogliMode == nil or diff.mogliMode ~= m then
					if     m == 1 then
						updateDifferential(self.motorizedNode,i-1,diff.torqueRatio,diff.mogliSpeedRatio)
					elseif m == 2 then
						updateDifferential(self.motorizedNode,i-1,diff.torqueRatio,1)
					else
						updateDifferential(self.motorizedNode,i-1,diff.mogliTorqueRatio,gearboxMogli.huge)
					end
				end
				diff.mogliMode = m
			end
		elseif self.differentials == nil then 
			--igonre
		elseif ( self.differentials[1] ~= nil and self.differentials[1].mogliMode ~= nil )
				or ( self.differentials[2] ~= nil and self.differentials[2].mogliMode ~= nil )
				or ( self.differentials[3] ~= nil and self.differentials[3].mogliMode ~= nil ) then
			for i,diff in pairs( self.differentials ) do
				diff.mogliMode = nil
				updateDifferential(self.motorizedNode,i-1,diff.torqueRatio,diff.maxSpeedRatio)
			end
		end
	end
	
	if      self.isClient
			and not self.mrGbMS.ModifyDifferentials
			and ( self.mrGbMS.DiffLockFront or self.mrGbMS.DiffLockMiddle or self.mrGbMS.DiffLockBack ) then
		if      self.dCcheckModule ~= nil 
				and self:dCcheckModule("fourWDandDifferentials") then
			self.mrGbMS.WarningText  = "Differentials are controlled by zzzDriveControl"
			self.mrGbML.warningTimer = g_currentMission.time + 2000			
		else
			self.mrGbMS.WarningText  = "No standard differentials found"
			self.mrGbML.warningTimer = g_currentMission.time + 2000			
		end
		self:mrGbMSetState( "DiffLockMiddle", false )
		self:mrGbMSetState( "DiffLockFront",  false )
		self:mrGbMSetState( "DiffLockBack",   false )
	end
	
--**********************************************************************************************************			
-- sound - backup/restore some settings
--**********************************************************************************************************			
	if self.mrGbMS.IsOn then
		if self.mrGbMB.updateFuelUsage == nil then
			self.mrGbMB.updateFuelUsage = self.updateFuelUsage
		elseif self.updateFuelUsage ~= gearboxMogliUpdateFuelUsage then
			self.mrGbMB.updateFuelUsage = self.updateFuelUsage
			print("Warning: self.updateFuelUsage was changed outside of FS17_GearboxAddon")
		end
		self.updateFuelUsage = gearboxMogliUpdateFuelUsage
		
		if self.mrGbMB.Sound == nil then
			local vol = nil
			if self.mrGbMS.Sound.MotorLoadVolume ~= nil then
				vol = self.sampleMotorLoad.volume
			end
			self.mrGbMB.Sound = { self.motorSoundPitchScale,     self.motorSoundPitchMax, 
														self.motorSoundRunPitchScale,  self.motorSoundRunPitchMax, 
														self.motorSoundLoadPitchScale, self.motorSoundLoadPitchMax,
														self.sampleReverseDrive.sample,self.sampleReverseDrive.sound3D, vol }
			if self.mrGbMS.ThreshingSoundPitchMod then
				self.mrGbMB.CombineCuttingPitchOffset = self.sampleThreshing.cuttingPitchOffset
			end
		end
		
		self.motorSoundPitchScale       = self.mrGbMS.Sound.IdlePitchScale
		self.motorSoundPitchMax         = self.mrGbMS.Sound.IdlePitchMax
		self.motorSoundRunPitchScale    = self.mrGbMS.Sound.RunPitchScale  
		self.motorSoundRunPitchMax      = self.mrGbMS.Sound.RunPitchMax
		self.motorSoundLoadPitchScale   = self.mrGbMS.Sound.LoadPitchScale 
		self.motorSoundLoadPitchMax     = self.mrGbMS.Sound.LoadPitchMax
		
		if self.mrGbMS.Sound.MotorLoadVolume ~= nil then
			self.sampleMotorLoad.volume   = self.mrGbMS.Sound.MotorLoadVolume
		end
		
		self.sampleReverseDrive.sample  = nil
		self.sampleReverseDrive.sound3D = nil
		
		self.mrUseMrTransmission        = nil
	else
		if self.mrGbMB.updateFuelUsage ~= nil then
			self.updateFuelUsage        = self.mrGbMB.updateFuelUsage
			self.mrGbMB.updateFuelUsage = nil
		end
		
		if self.mrGbMB.Sound ~= nil then
			self.motorSoundPitchScale,     self.motorSoundPitchMax, 
			self.motorSoundRunPitchScale,  self.motorSoundRunPitchMax,
			self.motorSoundLoadPitchScale, self.motorSoundLoadPitchMax,
			self.sampleReverseDrive.sample,self.sampleReverseDrive.sound3D,	vol = unpack( self.mrGbMB.Sound )
			if self.mrGbMS.Sound.MotorLoadVolume ~= nil then
				self.sampleMotorLoad.volume = vol
			end
			self.mrGbMB.Sound = nil
			if self.mrGbMB.CombineCuttingPitchOffset ~= nil then
				self.sampleThreshing.cuttingPitchOffset = self.mrGbMB.CombineCuttingPitchOffset
				self.mrGbMB.CombineCuttingPitchOffset   = nil
			end
		end
		
		if self.mrGbMB.mrUseMrTransmission then
			self.mrUseMrTransmission = true
		end
	
		return 
	end 	
	
	if      self.mrGbMS.ConfigId ~= nil 
			and ( self.configurations == nil or self.configurations.GearboxAddon == nil ) then
		print("GearboxAddon: setting current configuration at client")
		if self.boughtConfigurations == nil then
			self.boughtConfigurations = {}
		end
		for _,id in pairs(self.mrGbMS.BoughtIds) do
			self.boughtConfigurations.GearboxAddon[id] = true
		end	
		if self.configurations == nil then
			self.configurations = {}
		end
		self.configurations.GearboxAddon = self.mrGbMS.ConfigId
		self:addBoughtConfiguration("GearboxAddon", self.configurations.GearboxAddon)
	end
	
	if self.mrGbMS.CurMinRpm == nil or self.mrGbMS.CurMaxRpm == nil then
		print("FS17_GearboxAddon: Error! Initialization of motor failed")
	end
	
	if self.isServer and not ( self.mrGbML.firstTimeRun ) then
		self.mrGbML.firstTimeRun = true
		self:mrGbMSetLanuchGear( noEventSend )
		self:mrGbMDoGearShift( noEventSend ) 
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
	if self.isServer then
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
	end
	
--**********************************************************************************************************			
-- driveControl shuttle
--**********************************************************************************************************			
	if      self.dCcheckModule ~=  nil 
			and self.driveControl  ~= nil then
		if      self:dCcheckModule("shuttle")
				and self.driveControl.shuttle ~= nil 
				and self.driveControl.shuttle.isActive then
			self.mrGbMB.dcShuttle = true
			self.driveControl.shuttle.isActive = false
		end
	end
	
--**********************************************************************************************************			
-- cabinControls.lua lines 336..348
--**********************************************************************************************************			
	if self.driveControl == nil then
		self.driveControl = {}
		self.driveControl.isActive = true
	end
	
--**********************************************************************************************************			
-- FS17_handbrake => use self.handBrakeState	
--**********************************************************************************************************
	local enableHandbrake = true
	if g_modIsLoaded["FS17_handbrake"] and type( self.handBrakeState ) == "boolean" then
		enableHandbrake = false
		if self.isServer then
			self:mrGbMSetState( "Handbrake", self.handBrakeState )
		end
	end
	
--**********************************************************************************************************			
-- text	
--**********************************************************************************************************			
	if self.isServer then
		local text = ""
		local text2 = ""
		local isRev = false
		if     ( self.mrGbMS.ReverseActive and not ( self.isReverseDriving ) )
				or ( not self.mrGbMS.ReverseActive and self.isReverseDriving ) then
			isRev = true
		end
		
		if      self.cp ~= nil and self.cp.isDriving then
			text = gearboxMogli.getText( "gearboxMogliTEXT_CP", "courseplay" )
			text2 = text
			if not self:mrGbMGetAutomatic() and not ( self.mrGbMS.Hydrostatic ) then
				text = text .." (M)"
			end
		elseif not ( self.steeringEnabled ) then
			text = gearboxMogli.getText( "gearboxMogliTEXT_AI", "AI" )
			text2 = text
			if not self:mrGbMGetAutomatic() and not ( self.mrGbMS.Hydrostatic ) then
				text = text .." (M)"
			end
		elseif self.isMotorStarted and self.mrGbMS.AllAuto then
			text = gearboxMogli.getText( "gearboxMogliTEXT_ALLAUTO", "all auto" )
			if     isRev then
			-- see below
			elseif self.mrGbMS.Handbrake then
				text = text.." (P)"
			elseif self.mrGbMS.NeutralActive then
				text = text.." (N)"
			end
		elseif not ( self.isMotorStarted ) then
			text = gearboxMogli.getText( "gearboxMogliTEXT_OFF", "off" )
			if self.mrGbMS.Handbrake then
				text = text.." (P)"
			elseif self.mrGbMS.NeutralActive then
				text = text.." (N)"
			end
		elseif self.mrGbMS.Handbrake then
			text = gearboxMogli.getText( "gearboxMogliTEXT_BRAKE", "handbrake" )
		elseif self.mrGbMS.AutoHold and self:mrGbMGetAutoStartStop() then
			text = gearboxMogli.getText( "gearboxMogliTEXT_AUTO_HOLD", "auto hold" )
		elseif self.mrGbMS.DoubleClutch == 3 then
			text = gearboxMogli.getText( "gearboxMogliTEXT_NT", "release throttle" )
			text2 = text
		elseif self.mrGbMS.DoubleClutch >  0 then
			text = gearboxMogli.getText( "gearboxMogliTEXT_DC", "double clutch" ) -- .." "..tostring(self.mrGbMS.DoubleClutch)
			text2 = text
		elseif self.mrGbMS.NeutralActive then
			text = gearboxMogli.getText( "gearboxMogliTEXT_NEUTRAL", "neutral" )
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
		
		if isRev then
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
		if self.mrGbMS.AllAuto or not ( self.steeringEnabled ) then
			if     self.mrGbMS.AllAutoMode == 0 then
				if text  ~= "" then text  = text  .. " " end
				if text2 ~= "" then text2 = text2 .. " " end
				text = text .. "(M)"
				text2 = text2 .. "(M)"
			elseif self.mrGbMS.AllAutoMode == 7 then
			else
				local texta = "("				
				if     self.mrGbMS.CountGearsF <= 1 then
				elseif gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 1 ) > 0 then
					texta = texta .. "G"
				else
					texta = texta .. "-"
				end
				if     self.mrGbMS.CountRange1F <= 1 then
				elseif gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 2 ) > 0 then
					texta = texta .. "R"
				else
					texta = texta .. "-"
				end
				if     self.mrGbMS.CountRange2F <= 1 then
				elseif gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 3 ) > 0 then
					texta = texta .. "2"
				else
					texta = texta .. "-"
				end
				if text  ~= "" then text  = text  .. " " end
				if text2 ~= "" then text2 = text2 .. " " end
				text  = text  .. texta .. ")"
				text2 = text2 .. texta .. ")"
			end
		end
		
		self:mrGbMSetState( "DrawText", text )
		self:mrGbMSetState( "DrawText2", text2 )
	end
		
	local gearShiftSoundPlay = -1 
	local lastRange1ShifterState = self.mrGbML.Range1ShifterState
	local lastRange2ShifterState = self.mrGbML.Range2ShifterState
	self.mrGbML.Range1ShifterState = nil
	self.mrGbML.Range2ShifterState = nil
		
--**********************************************************************************************************			
-- inputs	
--**********************************************************************************************************			
	if gearboxMogli.mbIsActiveForInput( self, false ) then	
		local simplifiedAtClient = gearboxMogli.simplifiedAtClient or self.mrGbMS.AllAuto2 
	
		if     not ( self:mrGbMGetHasAllAuto() ) then
			if self.mrGbMS.AllAuto then
				self:mrGbMSetState( "AllAuto", false )		
			end
		elseif  self.isEntered 
				and self.steeringEnabled 
				and self.mrGbMS.AllAuto ~= simplifiedAtClient then
			self:mrGbMSetState( "AllAuto", simplifiedAtClient )
		end

		if enableHandbrake and self.mrGbMS.AllAuto then
			self:mrGbMSetState( "Handbrake", not self.isMotorStarted )		
		end
		
		if not self.mrGbMS.Handbrake then
			-- auto start/stop
			if      self.mrGbMS.NeutralActive
					and self.isMotorStarted
					and self:mrGbMGetAutoStartStop()
					and self.mrGbMS.G27Mode <= 0 
					and g_currentMission.time > self.motorStartTime
					and ( self.axisForward < -0.1 or self.cruiseControl.state ~= 0 ) then
				self:mrGbMSetNeutralActive( false ) 
			end
			
			if not self.mrGbMS.NeutralActive and self.mrGbMS.AutoHold then
				self:mrGbMSetState( "AutoHold", false )		
			end
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
			end
		end
		
		local clutchSpeed = 1 / math.max( self.mrGbMS.ClutchShiftTime, 1 )
	--if not ( self:mrGbMGetAutoClutch() ) then
	--	clutchSpeed     = math.max( 0.002, clutchSpeed )
	--end
		
		if     self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch then
			if self.mrGbMS.ManualClutch < 1 then
				self:mrGbMSetManualClutch( 1 )
			end
		elseif gearboxMogli.mbIsInputPressed( "gearboxMogliCLUTCH_3" ) then
			self.mrGbML.oneButtonClutchTimer = g_currentMission.time + 100
			self:mrGbMSetManualClutch( math.max( 0, self.mrGbMS.ManualClutch - dt * clutchSpeed ))
		elseif InputBinding.gearboxMogliCLUTCH ~= nil then
			local targetClutchPercent = InputBinding.getDigitalInputAxis(InputBinding.gearboxMogliCLUTCH)
			if InputBinding.isAxisZero(targetClutchPercent) then
				targetClutchPercent = InputBinding.getAnalogInputAxis(InputBinding.gearboxMogliCLUTCH)
				if not InputBinding.isAxisZero(targetClutchPercent) then
					local c = 0
					if self.mrGbMG.clutchAxisOpen < self.mrGbMG.clutchAxisClosed then
						if     targetClutchPercent >= self.mrGbMG.clutchAxisClosed then
							c = 1
						elseif targetClutchPercent <= self.mrGbMG.clutchAxisOpen   then
							c = 0
						else
							c = ( targetClutchPercent - self.mrGbMG.clutchAxisOpen ) / ( self.mrGbMG.clutchAxisClosed - self.mrGbMG.clutchAxisOpen )
						end
					else
						if     targetClutchPercent <= self.mrGbMG.clutchAxisClosed then
							c = 1
						elseif targetClutchPercent >= self.mrGbMG.clutchAxisOpen   then
							c = 0
						else
							c = ( targetClutchPercent - self.mrGbMG.clutchAxisOpen ) / ( self.mrGbMG.clutchAxisClosed - self.mrGbMG.clutchAxisOpen )
						end
					end
					if math.abs( c - self.mrGbMS.ManualClutch ) > 0.01 then
						self.mrGbML.oneButtonClutchTimer = math.huge
						self:mrGbMSetManualClutch( c ) 
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
			if self.mrGbMS.ManualClutch < 1 then
				self:mrGbMSetManualClutch( 1 )
				self:mrGbMSetState( "AutoCloseTimer", g_currentMission.time - 1 )
			end
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
			
		if InputBinding.gearboxMogliFIXEDRATIO ~= nil then
			local fixedRatio = InputBinding.getDigitalInputAxis(InputBinding.gearboxMogliFIXEDRATIO)
			if InputBinding.isAxisZero(fixedRatio) then
				fixedRatio = InputBinding.getAnalogInputAxis(InputBinding.gearboxMogliFIXEDRATIO)
				if not InputBinding.isAxisZero(fixedRatio) then
					self:mrGbMSetFixedRatio( fixedRatio )
				end
			elseif fixedRatio < 0 then
				self:mrGbMSetFixedRatio( self.mrGbMS.FixedRatio - 0.0004 * dt )
			elseif fixedRatio > 0 then
				self:mrGbMSetFixedRatio( self.mrGbMS.FixedRatio + 0.0004 * dt ) 
			end
		end
			
	  keyShiftGearUp       = "gearboxMogliSHIFTGEARUP"
		keyShiftGearDown     = "gearboxMogliSHIFTGEARDOWN"
		keyShiftGearToggle   = "gearboxMogliSHIFTGEARTOGGLE"
		keyShiftRangeUp      = "gearboxMogliSHIFTRANGEUP"
	  keyShiftRangeDown    = "gearboxMogliSHIFTRANGEDOWN"
		keyShiftRangeToggle  = "gearboxMogliSHIFTRANGETOGGLE"
		keyShiftRange2Up     = "gearboxMogliSHIFTRANGE2UP"
		keyShiftRange2Down   = "gearboxMogliSHIFTRANGE2DOWN"
		keyShiftRange2Toggle = "gearboxMogliSHIFTRANGE2TOGGLE"
		
		local autoShiftRequest = false
		
		if     self.mrGbMS.DisableManual then
			keyShiftGearUp       = ""
		  keyShiftGearDown     = ""
		  keyShiftGearToggle   = ""
		  keyShiftRangeUp      = ""
		  keyShiftRangeDown    = ""
		  keyShiftRangeToggle  = ""
		  keyShiftRange2Up     = ""
		  keyShiftRange2Down   = ""
		  keyShiftRange2Toggle = ""
		elseif self.mrGbMS.AllAuto and not self.mrGbMS.Hydrostatic and ( self.mrGbMS.AllAutoMode == 0 or self.mrGbMS.AllAutoMode == 7 ) then
			autoShiftRequest     = true
			keyShiftGearToggle   = ""
			keyShiftRangeUp      = ""
			keyShiftRangeDown    = ""
			keyShiftRangeToggle  = ""
			keyShiftRange2Up     = ""
			keyShiftRange2Down   = ""
			keyShiftRange2Toggle = ""
		elseif self.mrGbMS.SwapGearRangeKeys then
			keyShiftGearUp, 
			keyShiftGearDown,   
			keyShiftGearToggle, 
			keyShiftRangeUp,    
			keyShiftRangeDown,  
			keyShiftRangeToggle = keyShiftRangeUp,    
			                      keyShiftRangeDown,  
			                      keyShiftRangeToggle,
			                      keyShiftGearUp,     
			                      keyShiftGearDown,   
			                      keyShiftGearToggle 
		end
		
		if self.mrGbMS.GearShifterMode == 2 then
			keyShiftGearUp      = ""			
			keyShiftGearDown    = ""
			keyShiftGearToggle  = ""
		end
		
		-- avoid conflicts with driveControl
		if     not processInput
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_2" )
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_3" )
				or gearboxMogli.mbHasInputEvent( "gearboxMogliCONFLICT_4" ) then
			-- ignore
		elseif gearboxMogli.mbHasInputEvent( "TOGGLE_CHOPPER" ) and self.mrGbMS.IsCombine then
			-- ignore
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliECO" ) then
			self:mrGbMSetState( "EcoMode", not self.mrGbMS.EcoMode )
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliHANDBRAKE" ) then
			if enableHandbrake then
				self:mrGbMSetState( "Handbrake", not self.mrGbMS.Handbrake )
        if self.mrGbMS.Handbrake then
						-- handbrake pull
					if self.mrGbMS.HandbrakePullSoundVolume > 0 then
						if self.mrGbMS.HandbrakePullSoundFile == nil then
							if gearboxMogli.HandbrakePullSoundSample == nil then
								gearboxMogli.HandbrakePullSoundSample = createSample("handbrakePullSoundSample")
								local fileName = Utils.getFilename( "handbrakePull.wav", gearboxMogli.baseDirectory )
								loadSample(gearboxMogli.HandbrakePullSoundSample, fileName, false)
							end
							playSample( gearboxMogli.HandbrakePullSoundSample, 1, self.mrGbMS.HandbrakePullSoundVolume, 0 )
						else
							if self.mrGbML.HandbrakePullSoundSample == nil then
								self.mrGbML.HandbrakePullSoundSample = createSample("handbrakePullSoundSample")
								loadSample( self.mrGbML.HandbrakePullSoundSample, self.mrGbMS.HandbrakePullSoundFile, false )
							end
							playSample( self.mrGbML.HandbrakePullSoundSample, 1, self.mrGbMS.HandbrakePullSoundVolume, 0 )
						end
					end
				else
					-- handbrake release
					if self.mrGbMS.HandbrakeReleaseSoundVolume > 0 then
						if self.mrGbMS.HandbrakeReleaseSoundFile == nil then
							if gearboxMogli.HandbrakeReleaseSoundSample == nil then
								gearboxMogli.HandbrakeReleaseSoundSample = createSample("HandbrakeReleaseSoundSample")
								local fileName = Utils.getFilename( "handbrakeRelease.wav", gearboxMogli.baseDirectory )
								loadSample(gearboxMogli.HandbrakeReleaseSoundSample, fileName, false)
							end
							playSample( gearboxMogli.HandbrakeReleaseSoundSample, 1, self.mrGbMS.HandbrakeReleaseSoundVolume, 0 )
						else
							if self.mrGbML.HandbrakeReleaseSoundSample == nil then
								self.mrGbML.HandbrakeReleaseSoundSample = createSample("HandbrakeReleaseSoundSample")
								loadSample( self.mrGbML.HandbrakeReleaseSoundSample, self.mrGbMS.HandbrakeReleaseSoundFile, false )
							end
							playSample( self.mrGbML.HandbrakeReleaseSoundSample, 1, self.mrGbMS.HandbrakeReleaseSoundVolume, 0 )
						end
					end
				end
			end
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
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliDIFFLOCKMIDDLE" ) then
			if self.mrGbMS.ModifyDifferentials then
				self:mrGbMSetState( "DiffLockMiddle", not self.mrGbMS.DiffLockMiddle )
			end
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliDIFFLOCKFRONT" ) then
			if self.mrGbMS.ModifyDifferentials then
				self:mrGbMSetState( "DiffLockFront", not self.mrGbMS.DiffLockFront )
			end
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliDIFFLOCKBACK" ) then
			if self.mrGbMS.ModifyDifferentials then
				self:mrGbMSetState( "DiffLockBack", not self.mrGbMS.DiffLockBack )
			end
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliAUTOMATIC" ) then
			self:mrGbMSetAutomatic( not self.mrGbMS.Automatic )
	--elseif gearboxMogli.mbHasInputEvent( "gearboxMogliAllAuto" ) then
	--	if self.mrGbMS.AllAuto then
	--		self:mrGbMSetAllAuto( false )
	--	elseif self:mrGbMGetHasAllAuto() then
	--		self:mrGbMSetAllAuto( true )
	--	end
		elseif self.mrGbMS.GearShifterMode ~= 2 and gearboxMogli.mbHasInputEvent( "gearboxMogliNEUTRAL" ) then
			if not self.mrGbMS.NeutralActive then
				self:setCruiseControlState(0)
			end
			self:mrGbMSetNeutralActive( not self.mrGbMS.NeutralActive ) 
			gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftReverse
		elseif ( self.mrGbMS.ShuttleShifterMode == 0 or self.mrGbMS.ShuttleShifterMode == 1 ) and gearboxMogli.mbHasInputEvent( "gearboxMogliREVERSE" ) then			
		--self:setCruiseControlState(0)
			self:mrGbMSetReverseActive( not self.mrGbMS.ReverseActive ) 
			gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftReverse
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliSPEEDLIMIT" ) then -- speed limiter
			self:mrGbMSetSpeedLimiter( not self.mrGbMS.SpeedLimiter ) 
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliACCTOLIMIT" ) then -- speed limiter acc.
			self:mrGbMSetAccelerateToLimit( self.mrGbMS.AccelerateToLimit + 1 )
			self:mrGbMSetState( "InfoText", string.format( "Speed Limiter: +%2.0f km/h/s / -%2.0f km/h/s", 
													self.mrGbMS.AccelerateToLimit, self.mrGbMS.AccelerateToLimit * self.mrGbMG.decAccToLimitRatio ))
		elseif gearboxMogli.mbHasInputEvent( "gearboxMogliDECTOLIMIT" ) then -- speed limiter dec.
			self:mrGbMSetAccelerateToLimit( self.mrGbMS.AccelerateToLimit - 1 )
			self:mrGbMSetState( "InfoText", string.format( "Speed Limiter: +%2.0f km/h/s / -%2.0f km/h/s", 
													self.mrGbMS.AccelerateToLimit, self.mrGbMS.AccelerateToLimit * self.mrGbMG.decAccToLimitRatio ))
		elseif  self.mrGbMS.Range2ShifterMode == 0 
				and table.getn( self.mrGbMS.Ranges2 ) > 1
				and gearboxMogli.mbHasInputEvent( keyShiftRange2Toggle ) then
			-- toggle range 2
			local i = self.mrGbMS.CurrentRange2
			while true do
				i = i + 1 
				if i > table.getn( self.mrGbMS.Ranges2 ) then
					i = 1
				end
				if i == self.mrGbMS.CurrentRange2 then
					break
				end			
				if not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges2[i], nil, nil, i ) then			
					if self:mrGbMSetCurrentRange2(i, false) then 
						gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftRanges2 
					end
					break
				end
			end
		elseif  self.mrGbMS.Range1ShifterMode == 0 
				and table.getn( self.mrGbMS.Ranges ) > 1
				and gearboxMogli.mbHasInputEvent( keyShiftRangeToggle ) then
			-- toggle range 1			
			local i = self.mrGbMS.CurrentRange
			while true do
				i = i + 1 
				if i > table.getn( self.mrGbMS.Ranges ) then
					i = 1
				end
				if i == self.mrGbMS.CurrentRange then
					break
				end			
				if not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges[i], nil, i, nil ) then			
					if self:mrGbMSetCurrentRange(i, false, true) then 
						gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftHl
					end 
					break
				end
			end
		elseif not ( self.mrGbMS.DisableManual ) and gearboxMogli.mbHasInputEvent( keyShiftGearToggle ) then
			-- toggle gear
			local i = self.mrGbMS.CurrentGear
			while true do
				i = i + 1 
				if i > table.getn( self.mrGbMS.Gears ) then
					i = 1
				end
				if i == self.mrGbMS.CurrentGear then
					break
				end			
				if not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Gears[i], i, nil, nil ) then			
					if self:mrGbMSetCurrentGear(i, false, true) then 
						gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftGear
					end 
					break
				end
			end
		elseif table.getn( self.mrGbMS.Ranges2 ) > 1 and gearboxMogli.mbHasInputEvent( keyShiftRange2Up ) then -- high/low range shift
			if self:mrGbMSetCurrentRange2(self.mrGbMS.CurrentRange2+1) then
				gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftRanges2
			end 
		elseif table.getn( self.mrGbMS.Ranges2 ) > 1 and gearboxMogli.mbHasInputEvent( keyShiftRange2Down ) then -- high/low range shift
			if self:mrGbMSetCurrentRange2(self.mrGbMS.CurrentRange2-1) then
				gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftRanges2
			end 
		elseif table.getn( self.mrGbMS.Ranges ) > 1 and gearboxMogli.mbHasInputEvent( keyShiftRangeUp ) then -- high/low range shift
			if self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange+1, false, true) then
				gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftHl
			end 
		elseif table.getn( self.mrGbMS.Ranges ) > 1 and gearboxMogli.mbHasInputEvent( keyShiftRangeDown ) then -- high/low range shift
			if self:mrGbMSetCurrentRange(self.mrGbMS.CurrentRange-1, false, true) then
				gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftHl
			end 
		elseif gearboxMogli.mbHasInputEvent( keyShiftGearUp ) then
			self:mrGbMSetState( "G27Mode", 0 ) 
			if autoShiftRequest then
				self:mrGbMSetState( "AutoShiftRequest", 1 ) 
			elseif self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear+1, false, true) then
				gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftGear
			end
		elseif gearboxMogli.mbHasInputEvent( keyShiftGearDown ) then
			self:mrGbMSetState( "G27Mode", 0 ) 
			if autoShiftRequest then
				self:mrGbMSetState( "AutoShiftRequest", -1 ) 
			elseif self:mrGbMSetCurrentGear(self.mrGbMS.CurrentGear-1, false, true) then
				gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftGear
			end
		elseif ( self.mrGbMS.ShuttleShifterMode == 0 or self.mrGbMS.ShuttleShifterMode == 2 ) and gearboxMogli.mbHasInputEvent( "gearboxMogliGEARFWD" )  then 
		--self:setCruiseControlState(0) 
			self:mrGbMSetReverseActive( false ) 
			gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftReverse
		elseif ( self.mrGbMS.ShuttleShifterMode == 0 or self.mrGbMS.ShuttleShifterMode == 2 ) and gearboxMogli.mbHasInputEvent( "gearboxMogliGEARBACK" ) then 
		--self:setCruiseControlState(0) 
			self:mrGbMSetReverseActive( true ) 
			gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftReverse
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
			
			if noAutomatic and ( self.mrGbMS.G27Mode > 0 or gear ~= 0 or self.mrGbMS.GearShifterMode == 2 ) then		
				-- G27Mode == 1 => no gear selected => go to neutral
				-- G27Mode == 2 => a gear is selected => do not disable neutral if handbrake is engaged
			
				if self.mrGbMS.G27Mode <= 0 then
					if self.mrGbMS.NeutralActive then
						self:mrGbMSetState( "G27Mode", 1 ) 
					else
						self:mrGbMSetState( "G27Mode", 2 ) 
					end
				end
				
				local curGear = 0
				if self.mrGbMS.G27Mode >= 2 then
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

				-- always shift 
				if curGear ~= gear then					
					local manClutch   = self.mrGbMS.ManualClutchGear
					local onlyStopped = self.mrGbMS.GearsOnlyStopped 
					if self.mrGbMS.SwapGearRangeKeys then
						manClutch   = self.mrGbMS.ManualClutchHl
						onlyStopped = self.mrGbMS.Range1OnlyStopped
					end
					if ( curGear>0 and gear<0 ) or ( curGear<0 and gear>0 ) then
						manClutch   = manClutch   or self.mrGbMS.ManualClutchReverse
						onlyStopped = onlyStopped or self.mrGbMS.ReverseOnlyStopped
					end
					if self:mrGbMGetAutoClutch() then
						manClutch = false
					end
		
					if     gearboxMogli.mrGbMCheckShiftOnlyIfStopped( self, onlyStopped, noEventSend ) then
					-- do not shift because not stopped 
					elseif gear == 0 then
					-- neutral
						curGear = 0 
					elseif gearboxMogli.mrGbMCheckGrindingGears( self, manClutch, noEventSend ) then
					-- do not shift because of double clutch 
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
					end
				end
				
				if curGear == 0 then
					self:mrGbMSetNeutralActive( true, false, true )	
					self:mrGbMSetState( "G27Mode", 1 )
				else
					self:mrGbMSetState( "G27Mode", 2 ) 
					self:mrGbMSetNeutralActive( false, false, true )
					self:mrGbMSetState( "AutoHold", false )											
				end				
			elseif self.mrGbMS.G27Mode > 0 then
				self:mrGbMSetState( "G27Mode", 0 ) 
			end

			-- set range 1 via on/off button 
			if self.mrGbMS.Range1ShifterMode > 0 and keyShiftRangeToggle ~= "" then 
				self.mrGbML.Range1ShifterState = gearboxMogli.mbIsInputPressed( keyShiftRangeToggle )
				if self.mrGbMS.Range1ShifterMode == 2 then 
					self.mrGbML.Range1ShifterState = not self.mrGbML.Range1ShifterState
				end
				
				if lastRange1ShifterState == nil or lastRange1ShifterState ~= self.mrGbML.Range1ShifterState then 			
					local high, low = 1, table.getn( self.mrGbMS.Ranges )
					
					for i=table.getn( self.mrGbMS.Ranges ),1,-1 do 
						if not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges[i], nil, i, nil ) then			
							if high < i then 
								high = i 
							end 
							if low  > i then 
								low  = i 
							end 
							if low < high then 
								break 
							end 
						end 
					end 
					
					if self.mrGbML.Range1ShifterState then 
						if self:mrGbMSetCurrentRange(high, false) then 
							gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftHl 
						end
					else 
						if self:mrGbMSetCurrentRange(low, false) then 
							gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftHl 
						end
					end				
				end 
			end 
			
			-- set range 2 via on/off button 
			if self.mrGbMS.Range2ShifterMode > 0 and keyShiftRange2Toggle ~= "" then 
				self.mrGbML.Range2ShifterState = gearboxMogli.mbIsInputPressed( keyShiftRange2Toggle )
				if self.mrGbMS.Range2ShifterMode == 2 then 
					self.mrGbML.Range2ShifterState = not self.mrGbML.Range2ShifterState
				end
				
				if lastRange2ShifterState == nil or lastRange2ShifterState ~= self.mrGbML.Range2ShifterState then 			
					local high, low = 1, table.getn( self.mrGbMS.Ranges2 )
					
					for i=table.getn( self.mrGbMS.Ranges2 ),1,-1 do 
						if not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges2[i], nil, nil, i ) then			
							if high < i then 
								high = i 
							end 
							if low  > i then 
								low  = i 
							end 
							if low < high then 
								break 
							end 
						end 
					end 
					
					if self.mrGbML.Range2ShifterState then 
						if self:mrGbMSetCurrentRange2(high, false) then 
							gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftRanges2 
						end
					else 
						if self:mrGbMSetCurrentRange2(low, false) then 
							gearShiftSoundPlay = self.mrGbMS.GearTimeToShiftRanges2 
						end
					end				
				end 
			end 
		end
--**********************************************************************************************************					
-- auto start stop or manual clutch if vehicle is not controlled 
--**********************************************************************************************************			
	elseif  self.steeringEnabled 
			and self.isMotorStarted
			and not self.isHired
			and self.cruiseControl.state <= 0
			and self.isClient then
		-- open clutch if RPM is too low
		if      self.isEntered
				and g_gui:getIsGuiVisible() 
				and g_gui.currentGuiName ~= "ChatDialog" 
				and self:mrGbMGetCurrentRPM() <= 1.1 * self.mrGbMS.IdleRpm then
			if self:mrGbMGetAutoHold() then
				self:mrGbMSetNeutralActive( true, false, true ) 
				self:mrGbMSetState( "AutoHold", true )
			elseif not ( self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch ) then
				self:mrGbMSetManualClutch( 0 )
			end
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
			local v = self.mrGbMS.GrindingGearsVol
			self.mrGbMS.GrindingGearsVol = 0
			
			if self.isEntered and gearboxMogli.mbIsSoundActive( self ) and v > 0 then
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
		local minRpm = self.motor:getMinRpm()
		local maxRpm = self.motor:getMaxRpm()
		local maxSpeed 
		if self.movingDirection >= 0 then
			maxSpeed = self.motor:getMaximumForwardSpeed()*0.001
		else
			maxSpeed = self.motor:getMaximumBackwardSpeed()*0.001
		end
		local motorRpm = self.motor:getEqualizedMotorRpm()
		-- Increase the motor rpm to the max rpm if faster than 75% of the full speed
		if self.movingDirection > 0 and self.lastSpeed > 0.75*maxSpeed and motorRpm < maxRpm then
			motorRpm = motorRpm + (maxRpm - motorRpm) * math.min((self.lastSpeed-0.75*maxSpeed) / (0.25*maxSpeed), 1)
		end
		-- The actual rpm offset is 50% from the motor and 50% from the speed
		local targetRpmOffset = (motorRpm - minRpm)*0.5 + math.min(self.lastSpeed/maxSpeed, 1)*(maxRpm-minRpm)*0.5
		local alpha = math.pow(0.01, dt*0.001)
		local roundPerMinute = targetRpmOffset + alpha*(self.lastRoundPerMinute-targetRpmOffset)
				
		local realRpmOffset     = self.motor:getEqualizedMotorRpm() - minRpm
		
		local tmp = self.lastRoundPerMinute
		
		self.lastRoundPerMinute = targetRpmOffset + ( realRpmOffset - targetRpmOffset ) / alpha
	end
	
--**********************************************************************************************************			
-- reverse driving sound
--**********************************************************************************************************			
	if self.mrGbMB.Sound ~= nil and self.mrGbMB.Sound[7] ~= nil then
		self.sampleReverseDrive.sample  = self.mrGbMB.Sound[7]
		self.sampleReverseDrive.sound3D = self.mrGbMB.Sound[8]

		if      self.isMotorStarted
				and self.mrGbML.motor ~= nil
				and self:getIsActiveForSound() 
				and self.mrGbMS.ReverseActive 
				and not self.mrGbMS.NeutralActive then
			SoundUtil.playSample(self.sampleReverseDrive, 0, 0, nil)
		else
			SoundUtil.stopSample(self.sampleReverseDrive)
		end
		
		self.sampleReverseDrive.sample  = nil
		self.sampleReverseDrive.sound3D = nil
	end			
	
--**********************************************************************************************************			
-- gear shift sound
--**********************************************************************************************************			
	if      gearShiftSoundPlay >= 0
			and self.mrGbMS.GearShiftSoundVolume > 0
			and self:getIsActiveForSound() 
			and self:getIsIndoorCameraActive() then
		if gearShiftSoundPlay < self.mrGbMG.shiftEffectTime then 
			if self.sampleTurnLight then
				SoundUtil.playSample(self.sampleTurnLight, 1, 0, nil);
			else
				SoundUtil.playSample(g_currentMission.sampleTurnLight, 1, 0, nil);
			end
		elseif self.mrGbMS.GearShiftSoundFile == nil then
			if gearboxMogli.GearShiftSoundSample == nil then
				gearboxMogli.GearShiftSoundSample = createSample("GearShiftSoundSample")
				local fileName = Utils.getFilename( "shift.wav", gearboxMogli.baseDirectory )
				loadSample(gearboxMogli.GearShiftSoundSample, fileName, false)
			end
			local diff = math.min( 0.4 * gearShiftSoundPlay, self.mrGbML.clutchShiftingTime ) - 90
			if self.mrGbML.gearShiftSoundTimes == nil then
				self.mrGbML.gearShiftSoundTimes = {} 
			end 				
			table.insert( self.mrGbML.gearShiftSoundTimes, g_currentMission.time + diff )
		else
			if self.mrGbML.GearShiftSoundSample == nil then
				self.mrGbML.GearShiftSoundSample = createSample("GearShiftSoundSample")
				loadSample( self.mrGbML.GearShiftSoundSample, self.mrGbMS.GearShiftSoundFile, false )
			end
			playSample( self.mrGbML.GearShiftSoundSample, 1, self.mrGbMS.GearShiftSoundVolume, 0 )
		end
	end
	
	if self.mrGbML.gearShiftSoundTimes ~= nil then
		local nextTimes
		local playNow = false 
		for i,t in pairs( self.mrGbML.gearShiftSoundTimes )	do
			if g_currentMission.time < t then 
				if nextTimes == nil then		
					nextTimes = {} 
				end	
				table.insert( nextTimes, t )
			elseif  g_currentMission.time < t + 100
					and self:getIsActiveForSound() 
					and self:getIsIndoorCameraActive() then
				playNow = true
			end 			
		end 
		self.mrGbML.gearShiftSoundTimes = nextTimes
		if playNow then 
			playSample( gearboxMogli.GearShiftSoundSample, 1, self.mrGbMS.GearShiftSoundVolume, 0 )		
		end
	end
	
--**********************************************************************************************************			
-- threshing sound pitch 
--**********************************************************************************************************			
	if self.mrGbMS.ThreshingSoundPitchMod then		
		local d = self.mrGbMS.ThreshingSoundPitchMax - self.mrGbMS.ThreshingSoundPitchMin
		local r = self.motor:getEqualizedMotorRpm()
		local f = ( r - self.mrGbMS.ThreshingMinRpm ) / ( self.mrGbMS.ThreshingMaxRpm - self.mrGbMS.ThreshingMinRpm )
		local p = math.max( 0, self.mrGbMS.ThreshingSoundPitchMin + f * d )
		
		if self.mrGbML.threshingPitchOffset == nil then
			self.mrGbML.threshingPitchOffset = self.sampleThreshing.pitchOffset
		elseif p > self.mrGbML.threshingPitchOffset then
			self.mrGbML.threshingPitchOffset = math.min( p, self.mrGbML.threshingPitchOffset + (0.00066 * dt * d))
		elseif p < self.mrGbML.threshingPitchOffset then
			self.mrGbML.threshingPitchOffset = math.max( p, self.mrGbML.threshingPitchOffset - (0.00066 * dt * d))
		end
		
		self.sampleThreshing.cuttingPitchOffset = self.mrGbML.threshingPitchOffset
		self.sampleThreshing.currentPitchOffset = self.mrGbML.threshingPitchOffset
	end
	
--**********************************************************************************************************			
-- sound pitch and volume
--**********************************************************************************************************			
	
	if self.sampleMotorLoad.volume == nil then
		self.motorSoundLoadMinimalVolumeFactor = self.mrGbMS.Sound.LoadMinimalVolumeFactor
	else
		if self.motorSoundLoadFactor ~= nil and self.motorSoundLoadFactor > 0.5 then
		-- at least half of the motor sound load volume even at low RPM
			self.motorSoundLoadMinimalVolumeFactor = math.max( self.mrGbMS.Sound.LoadMinimalVolumeFactor, ( self.motorSoundLoadFactor - 0.5 ) * self.sampleMotorLoad.volume )
		else
			self.motorSoundLoadMinimalVolumeFactor = self.mrGbMS.Sound.LoadMinimalVolumeFactor
		end		

		if     self.mrGbMS.DoubleClutch == 1 then
			self.motorSoundLoadMinimalVolumeFactor = self.sampleMotorLoad.volume
		--self.motorSoundLoadFactor              = self.actualLoadPercentage
		elseif self.mrGbMS.DoubleClutch == 2 and self.axisForward ~= nil then
			self.motorSoundLoadMinimalVolumeFactor = math.max( self.motorSoundLoadMinimalVolumeFactor, -self.axisForward * self.sampleMotorLoad.volume )
		--self.motorSoundLoadFactor              = self.actualLoadPercentage
		end
		
		if     self.mrGbML.motorSoundLoadFactor < self.actualLoadPercentage then
			self.mrGbML.motorSoundLoadFactor = math.min( self.actualLoadPercentage, self.mrGbML.motorSoundLoadFactor + 0.010 * dt )		
		elseif self.mrGbML.motorSoundLoadFactor > self.actualLoadPercentage then
			self.mrGbML.motorSoundLoadFactor = math.max( self.actualLoadPercentage, self.mrGbML.motorSoundLoadFactor - 0.002 * dt )	
		end
		self.motorSoundLoadFactor          = self.mrGbML.motorSoundLoadFactor
	end
	
	if      self.steeringEnabled 
			and self.isServer 
			and not ( self.isEntered or self.isControlled ) then
		if self.isMotorStarted then

--**********************************************************************************************************			
-- drive control parallel mode
--**********************************************************************************************************			
			if      self.dCcheckModule                  ~= nil
					and self.driveControl                   ~= nil
					and self:dCcheckModule("cruiseControl")  
					and self.driveControl.cruiseControl     ~= nil
				--and g_currentMission.controlledVehicle  ~= self 
					and self.cruiseControl.state             > 0 then
					
				local rootVehicle = self:getRootAttacherVehicle()
					
				if self.driveControl.cruiseControl.mode == self.driveControl.cruiseControl.MODE_STOP_FULL then
					local trailerFillLevel, trailerCapacity = rootVehicle:getAttachedTrailersFillLevelAndCapacity()
					if trailerFillLevel~= nil and trailerCapacity~= nil then
						if trailerFillLevel >= trailerCapacity then
							self:setCruiseControlState(0)
						end
					end
					self.driveControl.cruiseControl.refVehicle = nil
				elseif self.driveControl.cruiseControl.mode == self.driveControl.cruiseControl.MODE_STOP_EMPTY then
					local trailerFillLevel, trailerCapacity = rootVehicle:getAttachedTrailersFillLevelAndCapacity()
					if trailerFillLevel~= nil and trailerCapacity~= nil then
						if trailerFillLevel <= 0 then
							self:setCruiseControlState(0)
						end
					end
					self.driveControl.cruiseControl.refVehicle = nil
				elseif  self.driveControl.cruiseControl.mode                == self.driveControl.cruiseControl.MODE_PARALLEL
						and self.driveControl.cruiseControl.refVehicle          ~= nil
						and self.driveControl.cruiseControl.refVehicle.rootNode ~= nil then
					local dx, _, dz = localDirectionToWorld(rootVehicle.rootNode, 0, 0, 1)
					local sdx, _, sdz = localDirectionToWorld(self.driveControl.cruiseControl.refVehicle.rootNode, 0, 0, 1)
												
					local diffAngle = (dx*sdx + dz*sdz)/(math.sqrt(dx^2+dz^2)*math.sqrt(sdx^2+sdz^2))
					diffAngle = math.acos(diffAngle)
					
					if diffAngle > math.rad(20) then
						self:setCruiseControlState(0)
					else				
						self:setCruiseControlMaxSpeed(self.driveControl.cruiseControl.refVehicle.lastSpeed*3600/math.cos(diffAngle))
						self.cruiseControl.wasSpeedChanged = true
						self.cruiseControl.changeCurrentDelay = 0

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
			if      self.cruiseControl.state > 0 then
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
		--and self.isMotorStarted
			and self.cruiseControl.state ~= Drivable.CRUISECONTROL_STATE_ACTIVE
			and not self.isHired then
		if self:mrGbMGetAutoStartStop() then 
			self:mrGbMSetNeutralActive( true, false, true )
			self:mrGbMSetState( "IsNeutral", true )
		elseif not ( self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch ) then
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

	if not gearboxMogli.mbIsSynced(self) then return end

	if self.mrGbMS == nil or self.mrGbML == nil or self.mrGbMD == nil then
		return
	end	
	
	if self.mrGbMS.ToolIsDirty2 then
		self.mrGbMS.ToolIsDirty  = true
		self.mrGbMS.ToolIsDirty2 = false 
	else
		self.mrGbMS.ToolIsDirty  = false 
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
						gearboxMogli.setLaunchGear( self, false, true )						
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
				self:setCruiseControlState(0)
			else		
				self:mrGbMSetState( "IsOn", true ) 
			end 	
			
		--if not ( self.isMotorStarted ) or g_currentMission.time < self.motorStartTime then
		--	self:mrGbMSetNeutralActive( true, false, true )
		--	self:mrGbMSetState( "AutoHold", true )
		--end
			
			if self.mrGbMS.DisableManual then
				self:mrGbMSetAutomatic( true )
			end
	
			if not self.mrGbMS.AllAuto and self:mrGbMGetAutomatic() and not ( self.mrGbMS.HydrostaticLaunch ) then
				if self:mrGbMGetAutoShiftGears() and self.mrGbMS.ManualClutchGear then
					self:mrGbMSetAutoClutch( true ) 
				end
				if self:mrGbMGetAutoShiftRange() and self.mrGbMS.ManualClutchHl then
					self:mrGbMSetAutoClutch( true ) 
				end
				if self:mrGbMGetAutoShiftRange2() and self.mrGbMS.ManualClutchRanges2 then
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
				self.mrGbMD.Slip   = 0
				
				if self.isMotorStarted then
					if self.motor.targetRpm     ~= nil then
						self.mrGbMD.Tgt  = tonumber( Utils.clamp( math.floor( 200*(self.motor.targetRpm-self.mrGbMS.CurMinRpm)/(self.mrGbMS.CurMaxRpm-self.mrGbMS.CurMinRpm)+0.5), 0, 255 ))	 				
					end
					self.mrGbMD.Clutch = tonumber( Utils.clamp( math.floor( gearboxMogli.mrGbMGetAutoClutchPercent( self ) * 200+0.5), 0, 255 ))	
					if      self.mrGbMS.sendReqPower 
							and self.motor.fuelMotorTorque        ~= nil
							and self.motor.prevNonClampedMotorRpm ~= nil
							and self.mrGbMS.CurMinRpm             ~= nil then
						local power = self.motor.fuelMotorTorque * math.max( self.motor.prevNonClampedMotorRpm, self.mrGbMS.CurMinRpm )
						self.mrGbMD.Power  = tonumber( Utils.clamp( math.floor( power * gearboxMogli.powerFactor0 + 0.5 ), 0, 65535 ))	
					end
					if self.mrGbMS.Hydrostatic and not ( self.motor.noTransmission ) then
						if self.mrGbMS.HydrostaticMax - self.mrGbMS.HydrostaticMin > gearboxMogli.eps then
							self.mrGbMD.Hydro = 200 * Utils.clamp( ( self.motor.hydrostaticFactor - self.mrGbMS.HydrostaticMin ) / ( self.mrGbMS.HydrostaticMax - self.mrGbMS.HydrostaticMin ), 0, 1 )
						else
							self.mrGbMD.Hydro = 200
						end
					end
				end
				
				self.mrGbMD.Slip     = math.floor( 100 * Utils.clamp( 1-self.motor.wheelSlipFactor, 0, 1 ) + 0.5 )
				self.mrGbMD.Rate     = tonumber( Utils.clamp( math.floor( gearboxMogli.mrGbMGetThroughPutS( self ) + 0.5 ), 0, 255 ))						
				
				if     self.mrGbMD.lastClutch ~= self.mrGbMD.Clutch
						or self.mrGbMD.lastSlip   ~= self.mrGbMD.Slip
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
					self.mrGbMD.lastSlip   = self.mrGbMD.Slip

					if self.mrGbMS.NoUpdateStream then					
						local message = {}
						message.Clutch = self.mrGbMD.Clutch
						message.Slip   = self.mrGbMD.Slip						
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
			self.mrGbML.lastFuelDt        = 0
			self.mrGbML.fuelUsageClient   = 0
		else
			self.mrGbML.lastFuelDt = self.mrGbML.lastFuelDt + dt
			if self.mrGbML.lastFuelDt > 500 then
				local fuelUsed = self.mrGbML.lastFuelFillLevel - self.fuelFillLevel
				self.mrGbML.lastFuelFillLevel = self.fuelFillLevel
				if self.isFuelFilling then
					fuelUsed = fuelUsed + self.fuelFillLitersPerSecond * self.mrGbML.lastFuelDt * 0.001
				end
				self.mrGbML.fuelUsageClient = fuelUsed * 3600000 / self.mrGbML.lastFuelDt
				self.mrGbML.lastFuelDt      = 0
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
			self.mrGbMD.Slip   = streamReadUInt8( streamId )			
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
			streamWriteUInt8(streamId, self.mrGbMD.Slip )
			
			if self.mrGbMS.sendHydro     then streamWriteUInt8(streamId, self.mrGbMD.Hydro  ) end		 
			if self.mrGbMS.sendTargetRpm then streamWriteUInt8(streamId, self.mrGbMD.Tgt    ) end			
			if self.mrGbMS.sendReqPower  then streamWriteUInt16(streamId,self.mrGbMD.Power  ) end			
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
	for _,name in pairs( {"backgroundOverlayId",
												"ovArrowUpWhite",
												"ovArrowUpGray",
												"ovArrowDownWhite",
												"ovArrowDownGray",
												"ovHandBrakeUp",
												"ovHandBrakeDown",
												"ovDiffLockMiddle",
												"ovDiffLockFront",
												"ovDiffLockBack",
												"BOVSample",
												"GrindingSample",
												"HandbrakePullSoundSample",
												"HandbrakeReleaseSoundSample",
												"GearShiftSoundSample" } ) do
		if gearboxMogli[name] ~= nil then
			local ov = gearboxMogli[name]
			gearboxMogli[name] = nil
			pcall( ov.delete, ov )
		end
	end
end

function gearboxMogli.getSpeedMeasuringUnit()
	if gearboxMogli.useMiles == nil then
		gearboxMogli.useMiles = g_gameSettings:getValue("useMiles")
		if gearboxMogli.useMiles == nil then
			gearboxMogli.useMiles = false
		end
	end
	if gearboxMogli.useMiles then
		return gearboxMogli.getText("gearboxMogliUNIT_mph", "mph" )
	end
	return gearboxMogli.getText("gearboxMogliUNIT_kph", "km/h" )
end

--**********************************************************************************************************	
-- gearboxMogli:draw
--**********************************************************************************************************	
function gearboxMogli:draw() 	

	if not gearboxMogli.mbIsSynced(self) then return end
	
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
			
			if     self:mrGbMGetDiffLockMiddle()
					or self:mrGbMGetDiffLockFront()
					or self:mrGbMGetDiffLockBack() then
				ovRows = ovRows + 1 infos[ovRows] = "difflock"
			end
			
			if      self.mrGbMS.Hydrostatic 
					and ( self:mrGbMGetOnlyHandThrottle() or self.mrGbMS.HandThrottle > 0 )
					and self.mrGbMS.RatedRpm > 1 then
				ovRows = ovRows + 1 infos[ovRows] = "target2"		
			elseif self.mrGbMS.Hydrostatic and self.mrGbMS.DisableManual then
				if gearText ~= "" then			
					ovRows = ovRows + 1 infos[ovRows] = "gear"
				end
			elseif  self:mrGbMGetOnlyHandThrottle() or self.mrGbMS.HandThrottle > 0
					and self.mrGbMS.RatedRpm > 1 then
				ovRows = ovRows + 1 infos[ovRows] = "target1"		
			elseif self.mrGbMS.AllAuto or not self:mrGbMGetAutomatic() then
				ovRows = ovRows + 1 infos[ovRows] = "speed"
			else
				ovRows = ovRows + 1 infos[ovRows] = "speed" --"speed2"
			end
			if self.isMotorStarted then
				ovRows = ovRows + 1 infos[ovRows] = "rpm"
			end
			if self.mrGbMS.DrawTargetRpm then
				ovRows = ovRows + 1 infos[ovRows] = "target"
			elseif self:mrGbMGetOnlyHandThrottle() or self.mrGbMS.HandThrottle > 0 then
				ovRows = ovRows + 1 infos[ovRows] = "hand"
			end
		--if self.mrGbMS.Hydrostatic and not ( self.mrGbMS.ConstantRpm ) and self.mrGbMS.FixedRatio > 0 then
			if self.mrGbMS.Hydrostatic and self.mrGbMS.FixedRatio > 0 then
				ovRows = ovRows + 1 infos[ovRows] = "fixed"
			end
			if self.mrGbMS.DrawReqPower  then
				ovRows = ovRows + 1 infos[ovRows] = "power"
			end
			if self.isMotorStarted then
				ovRows = ovRows + 1 infos[ovRows] = "load"
			end
			if self.isMotorStarted and ( self.isServer or not ( self:getIsHired() and g_currentMission.missionInfo.helperBuyFuel ) ) then
				ovRows = ovRows + 1 infos[ovRows] = "fuel"
			end
			if not self:mrGbMGetAutoClutch() then
				ovRows = ovRows + 1 infos[ovRows] = "clutch"
			elseif self.isMotorStarted and not self.mrGbMS.NeutralActive and self.mrGbMD.Clutch < 200 then
				ovRows = ovRows + 1 infos[ovRows] = "clutch2"
			end
			if self.mrGbMG.debugPrint and self.isServer and self.mrGbMS.IsCombine and not ( self.mrIsMrVehicle ) then
				ovRows = ovRows + 1 infos[ovRows] = "pto"
			elseif self.mrGbMD.Rate ~= nil and self.mrGbMD.Rate > 0 then
				ovRows = ovRows + 1 infos[ovRows] = "combine"
			end
			if self.mrIsMrVehicle or self.mrGbMS.ModifyDifferentials then
				ovRows = ovRows + 1 infos[ovRows] = "mrWheelSlip"
			end
			--==============================================
			
			local ovH      = titleY + ( ovRows + 1 ) * deltaY + ovBorder + ovBorder -- title is 0.03 points above drawY0 add border of 0.01 x 2
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
			
			local speed, minSp, maxSp = self:mrGbMGetGearSpeed()
			local limit = gearboxMogli.huge
			local rawSp = speed
			
			if self.mrGbMS.MaxSpeedLimiter then
				if self.mrGbMS.ReverseActive then
					if self.motor.maxBackwardSpeed ~= nil then
						limit = 3.6 * self.motor.maxBackwardSpeed
					end
				else
					if self.motor.maxForwardSpeed ~= nil then
						limit = 3.6 * self.motor.maxForwardSpeed
					end
				end
			end		
			
			speed = math.min( speed, limit )
			minSp = math.min( minSp, limit )
			
			local handRpm = self.mrGbMS.IdleRpm + self.mrGbMS.HandThrottle * ( self.mrGbMS.MaxTargetRpm - self.mrGbMS.IdleRpm ) 
			
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
					elseif info == "difflock" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_difflock", "Diff.Lock"))	
						else
							t = ""
							if self.mrGbMS.TorqueRatioMiddle < 0.01 or self.mrGbMS.TorqueRatioMiddle > 0.99 then
								if self:mrGbMGetDiffLockMiddle() then
									t = "4wd "
								else
									t = "2wd "
								end
							elseif self:mrGbMGetDiffLockMiddle() then
								t = t .. "M "
							else
								t = t .. "_ "
							end
							if self:mrGbMGetDiffLockFront()  then
								t = t .. "F "
							else
								t = t .. "_ "
							end
							if self:mrGbMGetDiffLockBack()   then
								t = t .. "B "
							else
								t = t .. "_ "
							end
							renderText(ovRight,drawY, deltaY, t) 	
						end
					elseif info == "gear" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearText) 	
						end
					elseif info == "speed" then
						if col == 1 then
							local t
							if gearText == "" then
								t = gearboxMogli.getText("gearboxMogliDRAW_maxSpeed", "Max. speed")
							else
								t = gearText
							end
							renderText(ovLeft, drawY, deltaY, t) 	
						else
							renderText(ovRight,drawY, deltaY, string.format( "%3.1f %s", g_i18n:getSpeed(speed), gearboxMogli.getSpeedMeasuringUnit() ))
						end
					elseif info == "speed2" then
						if col == 1 then
							local t
							if gearText == "" then
								t = gearboxMogli.getText("gearboxMogliDRAW_speed", "Speed")
							else
								t = gearText
							end
							renderText(ovLeft, drawY, deltaY, t) 	
						else
							renderText(ovRight,drawY, deltaY, string.format("%3.1f..%3.1f %s", g_i18n:getSpeed( minSp ), g_i18n:getSpeed(math.min( limit, maxSp )), gearboxMogli.getSpeedMeasuringUnit() ))
						end
					elseif info == "target2" then
						if col == 1 then
							local t
							if gearText == "" or self.mrGbMS.DisableManual then
								t = gearboxMogli.getText("gearboxMogliDRAW_maxSpeed", "Max. speed")
							else
								t = gearText
							end
							renderText(ovLeft, drawY, deltaY, t) 	
						else
							local sp = math.min( maxSp * handRpm / self.mrGbMS.RatedRpm, limit )
							renderText(ovRight,drawY, deltaY, string.format("%3.1f %s", g_i18n:getSpeed(sp), gearboxMogli.getSpeedMeasuringUnit() ))
						end
					elseif info == "target1" then
						if col == 1 then
							local t
							if gearText == "" then
								t = "PTO"
							else
								t = "PTO "..gearText
							end
							renderText(ovLeft, drawY, deltaY, t) 	
						else
							local sp = math.min( rawSp * handRpm / self.mrGbMS.RatedRpm, limit )
							renderText(ovRight,drawY, deltaY, string.format("%3.1f %s", g_i18n:getSpeed(sp), gearboxMogli.getSpeedMeasuringUnit() ))
						end
					elseif info == "target3" then
						if col == 1 then
						else
							renderText(ovRight, drawY, deltaY, string.format("%3d %%", math.floor( self.mrGbMD.Hydro * 0.5 + 0.5 ) ))  		
						end
					elseif info == "rpm" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_currentRpm", "Current rpm"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f %s", math.floor( self:mrGbMGetCurrentRPM() * 0.1 +0.5)*10, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" )))		
						end
					elseif info == "target" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_TargetRpm", "Target rpm"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f %s", math.floor( self:mrGbMGetTargetRPM() * 0.1 +0.5)*10, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" ))) 		
						end
					elseif info == "power" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_power", "Power"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f %s", self:mrGbMGetUsedPower(), gearboxMogli.getText("gearboxMogliUNIT_HP", "HP") ))
						end
					elseif info == "load" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_load", "Load"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%3d %%", math.floor( Utils.getNoNil( self:mrGbMGetMotorLoad(), 0 ) *10+0.5 )*10 )) 
						end
					elseif info == "fuel" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_fuel", "Fuel used"))
						elseif self.mrGbMS.FuelPerDistanceMinSpeed ~= nil and math.abs(self.lastSpeed)*3600 >= self.mrGbMS.FuelPerDistanceMinSpeed then
							renderText(ovRight, drawY, deltaY, string.format("%3d %s", self:mrGbMGetFuelUsageRate() / math.abs(self.lastSpeed*36), gearboxMogli.getText("gearboxMogliUNIT_lp100km", "l/100km" )))
						else
							renderText(ovRight, drawY, deltaY, string.format("%3d %s", self:mrGbMGetFuelUsageRate(), gearboxMogli.getText("gearboxMogliUNIT_lph", "l/h" )))
						end
					elseif info == "clutch" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_clutch", "Clutch"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %%", math.floor( self:mrGbMGetClutchPercent() * 100 + 0.5 ) ))
						end
					elseif info == "clutch2" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_autoClutch", "Auto clutch"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %%", math.floor( self:mrGbMGetClutchPercent() * 100 + 0.5 ) ))
						end
					elseif info == "hand" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_hand", "Hand throttle"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%4.0f %s", math.floor( handRpm * 0.1 +0.5)*10, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" ))) 		
						end
					elseif info == "fixed" then					
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_fixed", "Fixed ratio"))
						else
							local refRpm = self.mrGbMS.RatedRpm
							local kmh    = self.mrGbMS.FixedRatio * maxSp
							if self.mrGbMS.ConstantRpm then
								refRpm = self:mrGbMGetTargetRPM()
								kmh    = kmh * refRpm / self.mrGbMS.RatedRpm
							end
							if kmh <= limit then
								renderText(ovRight,drawY, deltaY, string.format("%3.1f %s", g_i18n:getSpeed(kmh), gearboxMogli.getSpeedMeasuringUnit() ))
							else
								renderText(ovRight,drawY, deltaY, string.format("%3.1f (%4d)", limit, refRpm * limit / kmh ))
							end
						end
					elseif info == "combine" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_combine", "Combine"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %s", self.mrGbMD.Rate, gearboxMogli.getText("gearboxMogliUNIT_tph", "t/h" )))
						end
					elseif info == "pto" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, "PTO Debug")	
						else
							local f = math.max( self.motor.prevNonClampedMotorRpm, self.mrGbMS.CurMinRpm ) 
							local p = f*self.motor.usedMotorTorque  
							if     self.motor.lastMissingTorque > 0 then
								setTextColor(1, 0, 0, 1) 
							elseif 0.2 * self.motor.ptoMotorTorque > 0.8 * self.motor.usedTransTorque then
								setTextColor(1, 1, 0, 1) 
							else
								setTextColor(0, 1, 0, 1) 
							end
							renderText(ovRight, drawY, deltaY, string.format("%3.0f %%", 100 * p / self.motor.maxPower ) )  		          
							setTextColor(1, 1, 1, 1) 
						end
					elseif info == "mrWheelSlip" then
						if col == 1 then
							renderText(ovLeft, drawY, deltaY, gearboxMogli.getText("gearboxMogliDRAW_wheelSlip", "Wheel slip"))
						else
							renderText(ovRight, drawY, deltaY, string.format("%3d %%", self.mrGbMD.Slip ))	
						end
					end
					
					drawY = drawY - deltaY
				end
			end
			--==============================================

			
			drawY = drawY + 0.25*deltaY			
			local text = gearboxMogli.getText( "gearboxMogliVERSION", "Gearbox by mogli" ) 
			if self.mrIsMrVehicle then
				text = text .. " (MR)"
			end
			renderText(ovRight, drawY, 0.5*deltaY, text )  		          
		elseif self.mrGbMS.HudMode == 2 then
			setTextAlignment(RenderText.ALIGN_LEFT) 
			setTextBold(false)
			
			local h = gearboxMogli.ovDiffLockBack.height
			local x = gearboxMogli.ovDiffLockBack.x + gearboxMogli.ovDiffLockBack.width * 1.1
			local y = gearboxMogli.ovDiffLockBack.y
	
			local text = self.mrGbMS.DrawText2 .." "..gearText
			renderText( x, y, h, text )

			if InputBinding.gearboxMogliHUD ~= nil then
				g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliHUD", "Gearbox HUD"),  InputBinding.gearboxMogliHUD)		
			end
		end
			
		setTextAlignment(RenderText.ALIGN_LEFT) 
		setTextBold(false)
		
		local revShow = self.mrGbMS.ReverseActive
		if self.isReverseDriving then
			revShow = not revShow
		end
			
		if self.mrGbMS.Handbrake then
			if revShow then
				gearboxMogli.ovHandBrakeDown:render()
			else
				gearboxMogli.ovHandBrakeUp:render()
			end
		elseif not ( self:mrGbMGetNeutralActive() ) then
			if revShow then
				gearboxMogli.ovArrowDownWhite:render()
			else
				gearboxMogli.ovArrowUpWhite:render()
			end
		else
			if revShow then
				gearboxMogli.ovArrowDownGray:render()
			else
				gearboxMogli.ovArrowUpGray:render()
			end
		end
		
		if self:mrGbMGetDiffLockMiddle() then
			gearboxMogli.ovDiffLockMiddle:render()
		end
		if self:mrGbMGetDiffLockFront()  then
			gearboxMogli.ovDiffLockFront:render()
		end
		if self:mrGbMGetDiffLockBack()   then
			gearboxMogli.ovDiffLockBack:render()
		end
	end
	
	local e = self.mrGbMS.IsOnOff
	local a = self.mrGbMS.AllAuto 
	
	if self.steeringEnabled then
		e = gearboxMogli.enabledAtClient
		a = gearboxMogli.simplifiedAtClient
	end
	
--if InputBinding.gearboxMogliON_OFF ~= nil then
--	if e then
--		g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliON", "Gearbox [on]"),  InputBinding.gearboxMogliON_OFF)		
--	else
--		g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliOFF", "Gearbox [off]"), InputBinding.gearboxMogliON_OFF)		
--	end
--end
--
--if InputBinding.gearboxMogliAllAuto ~= nil and ( a or self.steeringEnabled or self:mrGbMGetHasAllAuto() ) then
--	if a then
--		g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliAllAutoON", "All auto [on]"),  InputBinding.gearboxMogliAllAuto)	
--	else
--		g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliAllAutoOFF", "All auto [off]"),InputBinding.gearboxMogliAllAuto)		
--	end
--end

	g_currentMission:addHelpButtonText(gearboxMogli.getText("gearboxMogliInputPrefix","")..gearboxMogli.getText("gearboxMogliSETTINGS", "Settings"),InputBinding.gearboxMogliSETTINGS)		
	
end 

--**********************************************************************************************************	
-- gearboxMogli:getSaveAttributesAndNodes
--**********************************************************************************************************	
function gearboxMogli:getSaveAttributesAndNodes(nodeIdent)

	local attributes = ""

	if self.mrGbMS ~= nil then
		local rG, r1, r2
		if self.mrGbMS.ReverseActive then 
			attributes = attributes.." mrGbMReverse=\""  .. tostring(self.mrGbMS.ReverseActive ) .. "\""
			rG = self.mrGbMS.ResetRevGear
			r1 = self.mrGbMS.ResetRevRange
			r2 = self.mrGbMS.ResetRevRange2
		else
			rG = self.mrGbMS.ResetFwdGear
			r1 = self.mrGbMS.ResetFwdRange
			r2 = self.mrGbMS.ResetFwdRange2
		end
		
		if rG ~= self.mrGbMS.CurrentGear   then
			attributes = attributes.." mrGbMCurrentGear=\""    .. tostring(self.mrGbMS.CurrentGear   ) .. "\""
		end
		if r1 ~= self.mrGbMS.CurrentRange  then
			attributes = attributes.." mrGbMCurrentRange=\""   .. tostring(self.mrGbMS.CurrentRange  ) .. "\""
		end
		if r2 ~= self.mrGbMS.CurrentRange2 then
			attributes = attributes.." mrGbMCurrentRange2=\""  .. tostring(self.mrGbMS.CurrentRange2 ) .. "\""
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

		if self.mrGbMS.MinTarget > 0 then
			attributes = attributes.." mrGbMMinTarget=\"" ..tostring(self.mrGbMS.MinTarget ) .. "\""
		end
		if self.mrGbMS.MaxTarget > 0 then
			attributes = attributes.." mrGbMMaxTarget=\"" ..tostring(self.mrGbMS.MaxTarget ) .. "\""
		end
		
		if self.mrGbMS.G27Mode > 0 then
			attributes = attributes.." mrGbMG27Mode=\"" ..tostring(self.mrGbMS.G27Mode ) .. "\""
		end
		if not ( self.mrGbMS.AutoClutch ) then
			attributes = attributes.." mrGbMAutoClutch=\"" .. tostring(self.mrGbMS.AutoClutch ) .. "\""
		end
		if not ( self.mrGbMS.Automatic ) and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 ) then
			attributes = attributes.." mrGbMAutomatic=\"" .. tostring( self.mrGbMS.Automatic ) .. "\""  
		end
		if self.mrGbMS.AllAuto2 then
			attributes = attributes.." mrGbMAllAuto2=\"" .. tostring( self.mrGbMS.AllAuto2 ) .. "\""  
		end
		if self.mrGbMS.AllAutoMode < 7 then
			attributes = attributes.." mrGbMAllAutoMode=\"" .. tostring( self.mrGbMS.AllAutoMode ) .. "\""  
		end
		if self.mrGbMS.EcoMode then
			attributes = attributes.." mrGbMEcoMode=\"" .. tostring( self.mrGbMS.EcoMode ) .. "\""     
		end
		if self.mrGbMG.defaultHudMode ~= self.mrGbMS.HudMode then
			attributes = attributes.." mrGbMHudMode=\"" .. tostring( self.mrGbMS.HudMode ) .. "\""     
		end
		if math.abs( self.mrGbMS.AccelerateToLimit - self.mrGbMG.accelerateToLimit ) > 0.1 then
			attributes = attributes.." mrGbMSpeedAcc=\"" .. tostring( self.mrGbMS.AccelerateToLimit ) .. "\""     
		end     
		if self.mrGbMS.EnableAI ~= self.mrGbMS.EnableAI0 then
			attributes = attributes.." mrGbMEnableAI=\"" .. tostring( self.mrGbMS.EnableAI ) .. "\""     
		end
		if self.mrGbMS.SwapGearRangeKeys ~= self.mrGbMS.SwapGearRangeKeys0 then
			attributes = attributes.." mrGbMSwapGearRange=\"" .. tostring( self.mrGbMS.SwapGearRangeKeys ) .. "\""     
		end
		if self.mrGbMS.DrawTargetRpm ~= self.mrGbMG.drawTargetRpm then
			attributes = attributes.." mrGbMDrawTargetRpm=\"" .. tostring( self.mrGbMS.DrawTargetRpm ) .. "\""     
		end
		if self.mrGbMS.DrawReqPower ~= self.mrGbMG.drawReqPower then
			attributes = attributes.." mrGbMDrawReqPower=\"" .. tostring( self.mrGbMS.DrawReqPower ) .. "\""     
		end
		if self.mrGbMS.GearShifterMode ~= 0 then
			attributes = attributes.." mrGbMGearShifter=\"" .. tostring( self.mrGbMS.GearShifterMode ) .. "\""     
		end
		if self.mrGbMS.Range1ShifterMode ~= 0 then
			attributes = attributes.." mrGbMRange1Shifter=\"" .. tostring( self.mrGbMS.Range1ShifterMode ) .. "\""     
		end
		if self.mrGbMS.Range2ShifterMode ~= 0 then
			attributes = attributes.." mrGbMRange2Shifter=\"" .. tostring( self.mrGbMS.Range2ShifterMode ) .. "\""     
		end
		if self.mrGbMS.ShuttleShifterMode ~= 0 then
			attributes = attributes.." mrGbMShuttleShifter=\"" .. tostring( self.mrGbMS.ShuttleShifterMode ) .. "\""     
		end
		if self.mrGbMS.ShuttleFactor ~= 0.5 then
			attributes = attributes.." mrGbMShuttleFactor=\"" .. tostring( self.mrGbMS.ShuttleFactor ) .. "\""     
		end
		if self.mrGbMS.DiffLockMiddle then
			attributes = attributes.." mrGbMDiffLockMiddle=\"" .. tostring( self.mrGbMS.DiffLockMiddle ) .. "\""     
		end
		if self.mrGbMS.DiffLockFront then
			attributes = attributes.." mrGbMDiffLockFront=\"" .. tostring( self.mrGbMS.DiffLockFront ) .. "\""     
		end
		if self.mrGbMS.DiffLockBack then
			attributes = attributes.." mrGbMDiffLockBack=\"" .. tostring( self.mrGbMS.DiffLockBack ) .. "\""     
		end
		if self.mrGbMS.MatchGears ~= self.mrGbMS.MatchGears0 then
			attributes = attributes.." mrGbMMatchGears=\"" .. tostring( self.mrGbMS.MatchGears ) .. "\""     
		end
		if self.mrGbMS.MatchRanges ~= self.mrGbMS.MatchRanges0 then
			attributes = attributes.." mrGbMMatchRanges=\"" .. tostring( self.mrGbMS.MatchRanges ) .. "\""     
		end
		if self.mrGbMS.MinAutoGearSpeed > self.mrGbMG.minAutoGearSpeed then
			attributes = attributes.." mrGbMMinAutoSpeed=\"" .. tostring( self.mrGbMS.MinAutoGearSpeed ) .. "\""     
		end
		if self.mrGbMS.MaxAutoGearSpeed > self.mrGbMG.minAutoGearSpeed then
			attributes = attributes.." mrGbMMaxAutoSpeed=\"" .. tostring( self.mrGbMS.MaxAutoGearSpeed ) .. "\""     
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
function gearboxMogli:loadHelperStr( xmlFile, key, attr )
	local s = getXMLString( xmlFile, key )
	if s ~= nil then
		self.mrGbMS[attr] = s
	end
end
function gearboxMogli:loadHelperFloat( xmlFile, key, attr )
	local f = getXMLFloat( xmlFile, key )
	if f ~= nil then
		self.mrGbMS[attr] = f
	end
end

function gearboxMogli:loadFromAttributesAndNodes(xmlFile, key, resetVehicles)
	local i, b
	
	if self.mrGbMS ~= nil then
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetFwdGear"  , "ResetFwdGear"      )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetFwdRange" , "ResetFwdRange"     )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetFwdRange2", "ResetFwdRange2"    )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetRevGear"  , "ResetRevGear"      )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetRevRange" , "ResetRevRange"     )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMResetRevRange2", "ResetRevRange2"    )
		
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMReverse"       , "ReverseActive"     )
		
		if self.mrGbMS.ReverseActive then
			self.mrGbMS.CurrentGear   = self.mrGbMS.ResetRevGear
			self.mrGbMS.CurrentRange  = self.mrGbMS.ResetRevRange 
			self.mrGbMS.CurrentRange2 = self.mrGbMS.ResetRevRange2 
		else 
			self.mrGbMS.CurrentGear   = self.mrGbMS.ResetFwdGear 
			self.mrGbMS.CurrentRange  = self.mrGbMS.ResetFwdRange
			self.mrGbMS.CurrentRange2 = self.mrGbMS.ResetFwdRange2
		end

		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMCurrentGear"   , "CurrentGear"       )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMCurrentRange"  , "CurrentRange"      )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMCurrentRange2" , "CurrentRange2"     )
		
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMG27Mode"       , "G27Mode"           )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMHudMode"       , "HudMode"           )	
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMSpeedAcc"      , "AccelerateToLimit" )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMAllAutoMode"   , "AllAutoMode"       )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMGearShifter"   , "GearShifterMode"   )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMShuttleShifter", "ShuttleShifterMode")
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMRange1Shifter",  "Range1ShifterMode" )
		gearboxMogli.loadHelperInt( self, xmlFile, key .. "#mrGbMRange2Shifter",  "Range2ShifterMode" )
                                                                            
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMAutoClutch"    , "AutoClutch"        )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMAutomatic"     , "Automatic"         )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMAllAuto2"      , "AllAuto2"          )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMEcoMode"       , "EcoMode"           )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMSwapGearRange" , "SwapGearRangeKeys" )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMDrawTargetRpm" , "DrawTargetRpm"     )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMDrawReqPower"  , "DrawReqPower"      )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMDiffLockMiddle", "DiffLockMiddle"    )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMDiffLockFront" , "DiffLockFront"     )
		gearboxMogli.loadHelperBool(self, xmlFile, key .. "#mrGbMDiffLockBack"  , "DiffLockBack"      )

		gearboxMogli.loadHelperStr( self, xmlFile, key .. "#mrGbMEnableAI"      , "EnableAI"          )
		gearboxMogli.loadHelperStr( self, xmlFile, key .. "#mrGbMMatchGears"    , "MatchGears"        )
		gearboxMogli.loadHelperStr( self, xmlFile, key .. "#mrGbMMatchRanges"   , "MatchRanges"       )
		
		gearboxMogli.loadHelperFloat(self, xmlFile,key .. "#mrGbMShuttleFactor" , "ShuttleFactor"     )
		gearboxMogli.loadHelperFloat(self, xmlFile,key .. "#mrGbMMinTarget"     , "MinTarget"         )
		gearboxMogli.loadHelperFloat(self, xmlFile,key .. "#mrGbMMaxTarget"     , "MaxTarget"         )
		
		gearboxMogli.loadHelperFloat(self, xmlFile,key .. "#mrGbMMinAutoSpeed"  , "MinAutoGearSpeed"  )
		gearboxMogli.loadHelperFloat(self, xmlFile,key .. "#mrGbMMaxAutoSpeed"  , "MaxAutoGearSpeed"  )

		gearboxMogli.setLaunchGearSpeed( self, true )
		gearboxMogli.mrGbMDoGearShift( self, true )
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
			gearboxMogli.mrGbMSetGrindingGears( self, string.format("%s > %3.0f%%", 
																															gearboxMogli.getText( "gearboxMogliTEXT_GrindingClutch", "Cannot shift gear; clutch" ),
																															100*Utils.clamp( self.mrGbMS.MinClutchPercent + 0.1, 0, 1 ) ), noEventSend )
			return true
		end		
	end		
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMCheckGrindingGears
--**********************************************************************************************************	
function gearboxMogli:mrGbMCheckShiftOnlyIfStopped( onlyStopped, noEventSend )
	if self.steeringEnabled and onlyStopped and not self.mrGbMS.AllAuto then
		local s = math.abs( self.lastSpeedReal*3600 )
		if s > 1 then
			gearboxMogli.mrGbMSetGrindingGears( self, string.format( "%s > %3.0f %s", 
																															gearboxMogli.getText( "gearboxMogliTEXT_GrindingSpeed", "Cannot shift gear; speed" ),
																															g_i18n:getSpeed(1), gearboxMogli.getSpeedMeasuringUnit() ), noEventSend )
			return true
		end		
	end		
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetGrindingGears
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetGrindingGears( reason, noEventSend )
	self:mrGbMSetState( "InfoText", reason, noEventSend )
	self.mrGbMS.GrindingGearsVol = 0
	self:mrGbMSetState( "GrindingGearsVol", 1, noEventSend )
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
	
	if      not gearboxMogli.isReallyInNeutral( self )
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
function gearboxMogli:isReallyInNeutral()
	
	if     math.abs( self.lastSpeedReal ) > 0.0005 then
		return false
	elseif self.mrGbMS.G27Mode > 0 then
		if self.mrGbMS.AutoHold then
			return true
		end
	else
		if self.mrGbMS.NeutralActive then
			return true
		end
	end
	
	return false 
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetCurrentGear
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetCurrentGear( new, noEventSend, manual )
	if  		gearboxMogli.mrGbMCheckShiftOnlyIfStopped( self, self.mrGbMS.GearsOnlyStopped, noEventSend ) then
		return false
	end
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
		
		if      self.isServer 
				and manual 
				and gearboxMogli.isReallyInNeutral( self )
				then
			if self.mrGbMS.ReverseActive then
				self:mrGbMSetState( "ResetRevGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetRevRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			else
				self:mrGbMSetState( "ResetFwdGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			end
			gearboxMogli.setLaunchGearSpeed( self, noEventSend )
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
	
	if      not gearboxMogli.isReallyInNeutral( self )
			and ( self:mrGbMGetAutoShiftGears()
				 or ( self.mrGbMS.MatchGears ~= nil
					and self.mrGbMS.MatchGears ~= "false"
					and ( self.mrGbMS.G27Mode    <= 0
						 or self.mrGbMS.SwapGearRangeKeys )
					and ( ( newRange ~= self.mrGbMS.CurrentRange
							and ( self.mrGbMS.MatchGears == "true" or self.mrGbMS.MatchGears == "range" ) )
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
	if  		gearboxMogli.mrGbMCheckShiftOnlyIfStopped( self, self.mrGbMS.Range1OnlyStopped, noEventSend ) then
		return false
	end
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

		if      self.isServer 
				and manual 
				and gearboxMogli.isReallyInNeutral( self )
				then
			if self.mrGbMS.ReverseActive then
				self:mrGbMSetState( "ResetRevGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetRevRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			else
				self:mrGbMSetState( "ResetFwdGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			end
			gearboxMogli.setLaunchGearSpeed( self, noEventSend )
		end
		
		return true
	end
	
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetCurrentRange2
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetCurrentRange2(new, noEventSend)
	if  		gearboxMogli.mrGbMCheckShiftOnlyIfStopped( self, self.mrGbMS.Range2OnlyStopped, noEventSend ) then
		return false
	end
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
		
	--if not gearboxMogli.isReallyInNeutral( self ) then
	--	local speed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio * self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio
	--	local delta = nil
	--	local fr    = gearboxMogliMotor.combineGear( self.motor, self.mrGbMS.CurrentGear, self.mrGbMS.CurrentRange )
	--	local to    = gearboxMogliMotor.combineGear( self.motor, table.getn( self.mrGbMS.Gears ), table.getn( self.mrGbMS.Ranges ) )
	--	if newRange2 > self.mrGbMS.CurrentRange2 then
	--		to = fr
	--		fr = 1
	--	end
	--	for i=fr,to do
	--		local i2g, i2r = self.motor:splitGear( i )
	--		local skip = false
	--		if      not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Gears[i2g], i2g, i2r, newRange2 )
	--				and not gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges[i2r], i2g, i2r, newRange2 ) then
	--			local diff = self.mrGbMS.Gears[i2g].speed * self.mrGbMS.Ranges[i2r].ratio * self.mrGbMS.Ranges2[newRange2].ratio - speed 
	--			if newRange2 < self.mrGbMS.CurrentRange2 then
	--				if      diff < 0
	--						and ( delta == nil or delta < diff ) then
	--					delta    = diff
	--					newGear  = i2g
	--					newRange = i2r
	--				end
	--			else
	--				if      diff > 0
	--						and ( delta == nil or delta > diff ) then
	--					delta    = diff
	--					newGear  = i2g
	--					newRange = i2r
	--				end
	--			end
	--		end
	--	end
	--end
						
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

		if      self.isServer 
				and manual 
				and gearboxMogli.isReallyInNeutral( self )
				then
			if self.mrGbMS.ReverseActive then
				self:mrGbMSetState( "ResetRevGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetRevRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetRevRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			else
				self:mrGbMSetState( "ResetFwdGear",   self.mrGbMS.CurrentGear,   noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange",  self.mrGbMS.CurrentRange,  noEventSend ) 
				self:mrGbMSetState( "ResetFwdRange2", self.mrGbMS.CurrentRange2, noEventSend ) 
			end
			gearboxMogli.setLaunchGearSpeed( self, noEventSend )
		end
		
		return true
	end
	
	return false
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetAccelerateToLimit
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetAccelerateToLimit( value, noEventSend )
	self:mrGbMSetState( "AccelerateToLimit", Utils.clamp( value, 1, 20 ), noEventSend ) 		
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
			and gearboxMogli.mrGbMCheckGrindingGears( self, self.mrGbMS.ManualClutchNeutral, noEventSend ) then
		return false
	end

	self:mrGbMSetState( "NeutralActive", value, noEventSend ) 
	
	return true
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMSetReverseActive
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetReverseActive( value, noEventSend )
	if  		self.mrGbMS.ReverseActive ~= nil
			and self.mrGbMS.ReverseActive ~= value 
			and gearboxMogli.mrGbMCheckShiftOnlyIfStopped( self, self.mrGbMS.ReverseOnlyStopped, noEventSend ) then
		return false
	end
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
	
	if      self.mrGbMS.ReverseActive ~= value
			and gearboxMogli.mrGbMCheckDoubleClutch( self, self.mrGbMS.ReverseDoubleClutch, noEventSend ) then
		if self.isServer then
			if not gearboxMogli.checkGearShiftDC( self, value, "R", noEventSend ) then		
				return true -- better false ???
			end
		else
			self:mrGbMSetState( "NewReverse", value, noEventSend )
			return true
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
-- gearboxMogli:mrGbMSetFixedRatio
--**********************************************************************************************************	
function gearboxMogli:mrGbMSetFixedRatio( value, noEventSend )
	self:mrGbMSetState( "FixedRatio", Utils.clamp( value, 0, 1 ), noEventSend )
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
	if self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch then
		return self.mrGbMS.ManualClutch
	end
	if self.mrGbMS.TorqueConverterOrHydro then
		return self.mrGbMS.ManualClutch
	end
	if not self:mrGbMGetAutoClutch() and g_currentMission.time >= self.mrGbMS.AutoCloseTimer + self.mrGbMS.ClutchTimeManual then
		return self.mrGbMS.ManualClutch
	end
	return self.motor.clutchPercent
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetClutchPercent
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetClutchPercent()
	if self.mrGbML.motor == nil then
		return -1
	end
	if self.isServer then
		return gearboxMogli.mrGbMGetAutoClutchPercent( self )
	end
	if self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticLaunch then
		return self.mrGbMS.ManualClutch
	end
	if self.mrGbMS.TorqueConverterOrHydro then
		return self.mrGbMS.ManualClutch
	end
	if not self:mrGbMGetAutoClutch() and g_currentMission.time >= self.mrGbMS.AutoCloseTimer + self.mrGbMS.ClutchTimeManual then
		return self.mrGbMS.ManualClutch
	end
	return self.mrGbMD.Clutch*0.005
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetCurrentRPM
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetCurrentRPM()
	if self.mrGbML.motor == nil then
		if self.motor ~= nil then
			return self.motor:getEqualizedMotorRpm()
		else
			return -1
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
		return -1
	end

	if not ( self.mrGbMS.sendTargetRpm ) then
		self:mrGbMSetState( "sendTargetRpm", true )
		return 0
	elseif not ( self.isMotorStarted ) then
		return 0
	elseif self.isServer then
		if self.motor.targetRpm == nil then
			return self.mrGbMS.CurMinRpm
		end
		return self.motor.targetRpm
	else
		return self.mrGbMS.CurMinRpm + self.mrGbMD.Tgt * (self.mrGbMS.CurMaxRpm-self.mrGbMS.CurMinRpm) * 0.005
	end
	return 0
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetUsedPower
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetUsedPower()
	if self.mrGbML.motor == nil then
		return -1
	end
	
	if not ( self.mrGbMS.sendReqPower ) then
		self:mrGbMSetState( "sendReqPower", true )
		return 0
	else
		return self.mrGbMD.Power
	end
	return 0
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
	
	if defaultNoHydro == nil then
		return -1
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
-- gearboxMogli:mrGbMGetDecelerateToLimit
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetDecelerateToLimit()
	return self:mrGbMGetAccelerateToLimit() * self.mrGbMG.decAccToLimitRatio
end

function gearboxMogli:mrGbMGetDiffLockMiddle()
	if self.mrGbMS.ModifyDifferentials and self.mrGbMS.IsOn and self.steeringEnabled then
		return self.mrGbMS.DiffLockMiddle
	end
	return false
end

function gearboxMogli:mrGbMGetDiffLockFront()
	if self.mrGbMS.ModifyDifferentials and self.mrGbMS.IsOn and self.steeringEnabled then
		if      self.mrGbMS.DiffLockFront 
				and ( self.mrGbMS.DiffLockMiddle
					 or self.mrGbMS.TorqueRatioMiddle < 0
					 or self.mrGbMS.TorqueSenseMiddle < 0.5
					 or ( 0.01 < self.mrGbMS.TorqueRatioMiddle and self.mrGbMS.TorqueRatioMiddle < 0.99 ) ) then
			return true
		end
	end
	return false
end

function gearboxMogli:mrGbMGetDiffLockBack()
	if self.mrGbMS.ModifyDifferentials and self.mrGbMS.IsOn and self.steeringEnabled then
		return self.mrGbMS.DiffLockBack
	end
	return false
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
	
	return gearboxMogli.mrGbMGetGearText2(self, self.mrGbMS.CurrentGear, self.mrGbMS.CurrentRange, self.mrGbMS.CurrentRange2)
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetGearText
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetGearText2(gear, range1, range2)
	
	local gearText = Utils.getNoNil( self.mrGbMS.Gears[gear].name, "" )
	if self.mrGbMS.Ranges[range1].name ~= nil and self.mrGbMS.Ranges[range1].name ~= "" then
		gearText = self.mrGbMS.Ranges[range1].name .." ".. gearText
	end
	if self.mrGbMS.Ranges2[range2].name ~= nil and self.mrGbMS.Ranges2[range2].name ~= "" then
		gearText = self.mrGbMS.Ranges2[range2].name .." ".. gearText
	end
	
	if self.mrGbMS.Gears[gear].extraNames ~= nil then
		local r1 = range1
		local r2 = range2
		
		while true do		
			if      self.mrGbMS.Gears[gear].extraNames[r1]     ~= nil 
					and self.mrGbMS.Gears[gear].extraNames[r1][r2] ~= nil
					and self.mrGbMS.Gears[gear].extraNames[r1][r2].name ~= nil then
				gearText = self.mrGbMS.Gears[gear].extraNames[r1][r2].name
				if r1 == 0 and self.mrGbMS.Ranges[range1].name ~= nil and self.mrGbMS.Ranges[range1].name ~= "" then
					gearText = self.mrGbMS.Ranges[range1].name .." ".. gearText
				end
				if r2 == 0 and self.mrGbMS.Ranges2[range2].name ~= nil and self.mrGbMS.Ranges2[range2].name ~= "" then
					gearText = self.mrGbMS.Ranges2[range2].name .." ".. gearText
				end
				break
			end
			
			if     r2 ~= 0 then
				r2 = 0
			elseif r1 ~= 0 then
				r1 = 0
				r2 = range2
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
		return 0, 0, 0
	end
	if self.mrGbMS == nil then
		return 3.6 * self.motor.maxForwardSpeed, 0, 3.6 * self.motor.maxForwardSpeed
	end
	
	local s1 = 3.6 * self.mrGbMS.CurrentGearSpeed 
	local s2 = 3.6 * self.mrGbMS.AutoMinGearSpeed
	local s3 = 3.6 * self.mrGbMS.AutoMaxGearSpeed
	if self.mrGbMS.Hydrostatic and self.mrGbMS.HydrostaticMax ~= nil and self.mrGbMS.HydrostaticMin ~= nil then
		if self.mrGbMS.HydrostaticMin < 0 then
			s2 = 0
			if self.mrGbMS.ReverseActive then
				s1 = s1 * -self.mrGbMS.HydrostaticMin
				s3 = s3 * -self.mrGbMS.HydrostaticMin
			else
				s1 = s1 *  self.mrGbMS.HydrostaticMax
				s3 = s3 *  self.mrGbMS.HydrostaticMax
			end
		else
			s1 = s1 * self.mrGbMS.HydrostaticMax
			s2 = s2 * self.mrGbMS.HydrostaticMin
			s3 = s3 * self.mrGbMS.HydrostaticMax
		end
	end
	
	if      self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames ~= nil 
			and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[self.mrGbMS.CurrentRange] ~= nil 
			and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[self.mrGbMS.CurrentRange][self.mrGbMS.CurrentRange2] ~= nil 
			and self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[self.mrGbMS.CurrentRange][self.mrGbMS.CurrentRange2].speed ~= nil then
		s1 = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].extraNames[self.mrGbMS.CurrentRange][self.mrGbMS.CurrentRange2].speed
	end
	
	return s1,s2,s3
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

	if self.mrGbMS.DisableManual then
		return false 
	end
	
	if      self.mrGbMS.AutoShiftGears
			and self.mrGbMS.CountRange1F <= 1
			and self.mrGbMS.CountRange2F <= 1 then
		return false
	end
	if      self.mrGbMS.AutoShiftHl
			and self.mrGbMS.CountGearsF  <= 1
			and self.mrGbMS.CountRange2F <= 1 then
		return false
	end
	if      self.mrGbMS.AutoShiftRange2
			and self.mrGbMS.CountRange1F <= 1
			and self.mrGbMS.CountGearsF  <= 1 then
		return false
	end

	if self.mrGbMS.CountGearsF  > 1 then 
		return true 
	end
	if self.mrGbMS.CountRange1F > 1 then
		return true
	end
	if self.mrGbMS.CountRange2F > 1 then
		return true
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

	if self.mrGbMS.ReverseActive then
		if self.mrGbMS.CountGearsR <= 1 then
			return false 
		end
	else
		if self.mrGbMS.CountGearsF <= 1 then
			return false 
		end
	end
	
	if      self.mrGbMS.DisableManual then
		return true
	elseif  self.mrGbMS.G27Mode > 0 
			and not ( self.mrGbMS.SwapGearRangeKeys ) then
		return false
	elseif  self.mrGbMS.AllAuto 
			and self.mrGbMS.AllAutoMode <= 0 then
		return true
	elseif  self.mrGbMS.AllAuto 
			and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 1 ) > 0 then
		return true
	elseif  self.mrGbMS.Automatic 
			and not self.mrGbMS.AllAuto 
			and self.mrGbMS.AutoShiftGears then
		return true
	elseif not ( self.steeringEnabled ) then
		if      self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
				and self:mrGbMGetHasAllAuto()
				and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 1 ) > 0 then
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

	if self.mrGbMS.ReverseActive then
		if self.mrGbMS.CountRange1R <= 1 then
			return false 
		end
	else
		if self.mrGbMS.CountRange1F <= 1 then
			return false 
		end
	end
	
	if      self.mrGbMS.DisableManual then
		return true
	elseif  self.mrGbMS.G27Mode > 0 
			and self.mrGbMS.SwapGearRangeKeys then
		return false
	elseif  self.mrGbMS.AllAuto 
			and self.mrGbMS.AllAutoMode <= 0 then
		return true
	elseif  self.mrGbMS.AllAuto 
			and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 2 ) > 0 then
		return true
	elseif  self.mrGbMS.Automatic 
			and not self.mrGbMS.AllAuto 
			and self.mrGbMS.AutoShiftHl then
		return true
	elseif not ( self.steeringEnabled ) then
		if      self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
				and self:mrGbMGetHasAllAuto()
				and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 2 ) > 0 then
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

	if self.mrGbMS.ReverseActive then
		if self.mrGbMS.CountRange2R <= 1 then
			return false 
		end
	else
		if self.mrGbMS.CountRange2F <= 1 then
			return false 
		end
	end
	
	if      self.mrGbMS.DisableManual then
		return true
	elseif  self.mrGbMS.AllAuto 
			and self.mrGbMS.AllAutoMode <= 0 then
		return true
	elseif  self.mrGbMS.AllAuto 
			and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 3 ) > 0 then
		return true
	elseif  self.mrGbMS.Automatic 
			and not self.mrGbMS.AllAuto 
			and self.mrGbMS.AutoShiftRange2 then
		return true
	elseif not ( self.steeringEnabled ) then
		if      self.mrGbMS.EnableAI == gearboxMogli.AIAllAuto
				and self:mrGbMGetHasAllAuto() 
				and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 3 ) > 0 then
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
-- gearboxMogli:mrGbMGetAutomatic
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutomatic()
	if      self.mrGbMS.AllAuto and self:mrGbMGetHasAllAuto() then
		return true
	elseif  self.mrGbMS.Automatic 
			and ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or  self.mrGbMS.AutoShiftRange2 ) then 
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
	
		self:mrGbMSetState( "AutoShiftRequest", 0 ) 		
		
		if self.mrGbML.motor ~= nil then
			self.mrGbML.beforeShiftRpm = self.motor.lastRealMotorRpm 
			if gearboxMogli.debugGearShift then
				self.mrGbML.debugTimer = g_currentMission.time + 1000
			end				
			-- reset some values...
			self.motor.timeShiftTab = nil
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
			if     doubleClutch 
					or ( self.mrGbMS.ClutchShiftTime < 0.41 * timeToShift
					 and timeToShift                 > 990
					 and not ( self.mrGbMS.Hydrostatic ) )
					then 
				if doubleClutch then 
					self.mrGbML.doubleClutch     = 2
				else 
					self.mrGbML.doubleClutch     = 1 
				end
				self.mrGbML.clutchShiftingTime = math.max( self.mrGbML.clutchShiftingTime, g_currentMission.time + math.min( 0.4 * timeToShift, self.mrGbMS.ClutchShiftTime ) ) 
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
function gearboxMogli:mrGbMDoGearShift( noEventSend )
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
				or self.mrGbMS.CurrentRange2 == nil
				or self.mrGbMS.Gears[self.mrGbMS.CurrentGear] == nil
				or self.mrGbMS.Ranges[self.mrGbMS.CurrentRange] == nil
				or self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2] == nil
				then
			self:mrGbMSetState( "CurrentGearSpeed", 0, noEventSend )
			self:mrGbMSetState( "AutoMinGearSpeed", 0, noEventSend )
			self:mrGbMSetState( "AutoMaxGearSpeed", 0, noEventSend )
			return
		end

		if     self.mrGbML.gearShiftingTime < g_currentMission.time then
			self.mrGbML.gearShiftingNeeded = 0
		elseif self.mrGbML.doubleClutch > 0 then
			self.mrGbML.gearShiftingNeeded = 2
		else
			self.mrGbML.gearShiftingNeeded = 3
		end
		self.mrGbML.doubleClutch = 0
		
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
		self:mrGbMSetState( "CurrentGearSpeed", gearMaxSpeed, noEventSend )

		gearboxMogli.setAutoMinMaxGearSpeed( self, noEventSend )
		
		if self.mrGbML.motor ~= nil then	
			self.mrGbML.motor.deltaRpm = 0
			
			if self.mrGbML.beforeShiftRpm ~= nil then
				self.mrGbML.afterShiftRpm = Utils.clamp( self.mrGbML.beforeShiftRpm * self.mrGbML.lastGearSpeed / self.mrGbMS.CurrentGearSpeed, self.mrGbML.motor.vehicle.mrGbMS.IdleRpm, self.mrGbML.motor.vehicle.mrGbMS.CurMaxRpm )
			else
				self.mrGbML.afterShiftRpm = nil
			end
			
		--if self.mrGbMS.Hydrostatic then
		--	self.motor.hydrostaticFactor = self.mrGbMS.HydrostaticStart
		--end
			self.motor.ratioFactorR       = nil
			self.motor.torqueRpmReduxMode = nil
			self.motor.maxAccSpeedLimit   = nil
			self.motor.lastAutoShiftScore = nil
		else
			self.mrGbML.afterShiftClutch  = nil
			self.mrGbML.beforeShiftRpm    = nil
			self.mrGbML.afterShiftRpm     = nil
		end		
	end 

--print("B: "..tostring(self.mrGbML.beforeShiftRpm).." => A: "..tostring(self.mrGbML.afterShiftRpm))
end 

--**********************************************************************************************************	
-- gearboxMogli:setAutoMinMaxGearSpeed
--**********************************************************************************************************	
function gearboxMogli:setAutoMinMaxGearSpeed( noEventSend )
	local autoMinSpeed = self.mrGbMS.CurrentGearSpeed
	local autoMaxSpeed = self.mrGbMS.CurrentGearSpeed
	local fg,tg = self.mrGbMS.CurrentGear,self.mrGbMS.CurrentGear
	local f1,t1 = self.mrGbMS.CurrentRange,self.mrGbMS.CurrentRange
	local f2,t2 = self.mrGbMS.CurrentRange2,self.mrGbMS.CurrentRange2
	
	if self:mrGbMGetAutoShiftGears()  then
		fg = 1
		tg = table.getn( self.mrGbMS.Gears )
	end
	if self:mrGbMGetAutoShiftRange()  then
		f1 = 1
		t1 = table.getn( self.mrGbMS.Ranges )
	end
	if self:mrGbMGetAutoShiftRange2() then
		f2 = 1
		t2 = table.getn( self.mrGbMS.Ranges2 )
	end
	
	for ig=fg,tg do
		for i1=f1,t1 do
			for i2=f2,t2 do
				if not ( gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Gears[ig],   ig, i1, i2 )
							or gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges[i1],  ig, i1, i2 )
							or gearboxMogli.mrGbMIsNotValidEntry( self, self.mrGbMS.Ranges2[i2], ig, i1, i2 ) ) then
					local s = self.mrGbMS.Gears[ig].speed 
									* self.mrGbMS.Ranges[i1].ratio 
									* self.mrGbMS.Ranges2[i2].ratio
									* self.mrGbMS.GlobalRatioFactor
					if self.mrGbMS.ReverseActive then	
						s = s * self.mrGbMS.ReverseRatio 
					end
					if     autoMaxSpeed < s then
						autoMaxSpeed = s
					elseif autoMinSpeed > s then
						autoMinSpeed = s
					end
				end
			end
		end
	end
	
	self:mrGbMSetState( "AutoMinGearSpeed", autoMinSpeed, noEventSend )
	self:mrGbMSetState( "AutoMaxGearSpeed", autoMaxSpeed, noEventSend )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetAutomatic
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetAutomatic( old, new, noEventSend )
	if     self.mrGbMS.DisableManual then
		self.mrGbMS.Automatic = true
	elseif self.mrGbMS.AllAuto then	
	elseif not ( self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 ) then
		self.mrGbMS.Automatic = false
	else
		self.mrGbMS.Automatic = new 
	end

	gearboxMogli.setAutoMinMaxGearSpeed( self, noEventSend )
end

--**********************************************************************************************************	
-- gearboxMogli:mrGbMOnSetAllAutoMode
--**********************************************************************************************************	
function gearboxMogli:mrGbMOnSetAllAutoMode( old, new, noEventSend )
	
	if type( new ) ~= "number" then
		if new then
			new = 7
		else
			new = 0
		end
	end
	
	if     self.mrGbMS.DisableManual then
		self.mrGbMS.AllAutoMode = 7
	elseif not self:mrGbMGetHasAllAuto() then
	-- disabled via self:mrGbMGetHasAllAuto()
		self.mrGbMS.AllAutoMode = 7
	elseif new >= 7 then
		self.mrGbMS.AllAutoMode = 7
	elseif new >  0 then
		self.mrGbMS.AllAutoMode = new
	-- set disabled bits because it is easier
		if self.mrGbMS.CountGearsF  <= 1 and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 1 ) <= 0 then
			self.mrGbMS.AllAutoMode = self.mrGbMS.AllAutoMode + 1
		end
		if self.mrGbMS.CountRange1F <= 1 and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 2 ) <= 0 then
			self.mrGbMS.AllAutoMode = self.mrGbMS.AllAutoMode + 2
		end
		if self.mrGbMS.CountRange2F <= 1 and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 3 ) <= 0 then
			self.mrGbMS.AllAutoMode = self.mrGbMS.AllAutoMode + 4
		end
	else
		self.mrGbMS.AllAutoMode = 0
	end 
	
	gearboxMogli.setAutoMinMaxGearSpeed( self, noEventSend )
end

--**********************************************************************************************************	
-- gearboxMogli:setLaunchGear
--**********************************************************************************************************	
function gearboxMogli:setLaunchGear( noEventSend, shuttle )	
	
	local gear      = self.mrGbMS.CurrentGear
	local oldGear   = self.mrGbMS.CurrentGear
	local range     = self.mrGbMS.CurrentRange
	local oldRange  = self.mrGbMS.CurrentRange
	local gearSpeed = self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio * self.mrGbMS.GlobalRatioFactor	
	local maxSpeed  = self.mrGbMS.LaunchGearSpeed
	
	if self.mrGbMS.ConstantRpm then
		maxSpeed      = self.mrGbMS.LaunchPtoSpeed
		if self.mrGbMS.HandThrottle > 0 then
			maxSpeed    = maxSpeed * self.mrGbMS.IdleRpm / ( self.mrGbMS.IdleRpm + self.mrGbMS.HandThrottle * ( self.mrGbMS.MaxTargetRpm - self.mrGbMS.IdleRpm ) )
		end
	end
	
	if self.mrGbMS.ReverseActive then
		gearSpeed = gearSpeed * self.mrGbMS.ReverseRatio 
	end

	local lg, lr, l2 = self.mrGbMS.CurrentGear, self.mrGbMS.CurrentRange, self.mrGbMS.CurrentRange2
	
	if     self:mrGbMGetAutoShiftGears()
			or self.mrGbMS.MatchGears == "true"
			or ( self.mrGbMS.ReverseResetGear and shuttle ) 
			then
		if self.mrGbMS.ReverseActive then
			lg = self.mrGbMS.ResetRevGear
		else
			lg = self.mrGbMS.ResetFwdGear
		end						
	end
	if     self:mrGbMGetAutoShiftRange()
			or self.mrGbMS.MatchRanges == "true"
			or ( self.mrGbMS.ReverseResetRange and shuttle ) 
			then
		if self.mrGbMS.ReverseActive then
			lr = self.mrGbMS.ResetRevRange
		else
			lr = self.mrGbMS.ResetFwdRange
		end			
	end
	if     self:mrGbMGetAutoShiftRange2()
			or ( self.mrGbMS.ReverseResetRange2 and shuttle ) 
			then
		if self.mrGbMS.ReverseActive then
			l2 = self.mrGbMS.ResetRevRange2
		else
			l2 = self.mrGbMS.ResetFwdRange2
		end			
	end
	
	if not ( self.steeringEnabled or ( self.cp ~= nil and self.cp.isDriving ) ) then
		if self.mrGbMS.MaxAIGear   ~= nil then
			lg = math.min( self.mrGbMS.MaxAIGear, lg )
		end
		if self.mrGbMS.MaxAIRange  ~= nil then
			lr = math.min( self.mrGbMS.MaxAIRange, lr ) 	
		end
		if self.mrGbMS.MaxAIRange2 ~= nil then
			l2 = math.min( self.mrGbMS.MaxAIRange2, l2 ) 	
		end
	end
	
	lg = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Gears, self.mrGbMS.CurrentGear, lg, "gear" )
	lr = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges, self.mrGbMS.CurrentRange, lr, "range" )
	l2 = gearboxMogli.mrGbMGetNewEntry( self, self.mrGbMS.Ranges2, self.mrGbMS.CurrentRange2, l2, "range2" )
	
	self:mrGbMSetState( "CurrentGear", lg, noEventSend ) 
	self:mrGbMSetState( "CurrentRange", lr, noEventSend ) 
	self:mrGbMSetState( "CurrentRange2", l2, noEventSend ) 

	gearboxMogli.setLaunchGearSpeed( self, noEventSend )

end

--**********************************************************************************************************	
-- gearboxMogli:setLaunchGearSpeed
--**********************************************************************************************************	
function gearboxMogli:setLaunchGearSpeed( noEventSend )
	if     self.mrGbMS                                    == nil
			or self.mrGbMS.GlobalRatioFactor                  == nil
			or self.mrGbMS.CurrentGear                        == nil
			or self.mrGbMS.Gears                              == nil
			or self.mrGbMS.Gears[self.mrGbMS.CurrentGear]     == nil
			or self.mrGbMS.CurrentRange                       == nil
			or self.mrGbMS.Ranges                             == nil
			or self.mrGbMS.Ranges[self.mrGbMS.CurrentRange]   == nil
			or self.mrGbMS.CurrentRange2                      == nil
			or self.mrGbMS.Ranges2                            == nil
			or self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2] == nil
			then
		return 
	end

	maxSpeed = self.mrGbMS.Gears[self.mrGbMS.CurrentGear].speed
					 * self.mrGbMS.Ranges[self.mrGbMS.CurrentRange].ratio
					 * self.mrGbMS.Ranges2[self.mrGbMS.CurrentRange2].ratio
					 * self.mrGbMS.GlobalRatioFactor

	if self.mrGbMS.ReverseActive then
		maxSpeed = maxSpeed * self.mrGbMS.ReverseRatio 
	end

	self:mrGbMSetState( "LaunchGearSpeed", maxSpeed, noEventSend ) 
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
	
		-- restore last gear of new direction 
		if self.steeringEnabled then
			gearboxMogli.setLaunchGear( self, noEventSend, true )
		end		

		if self.isServer then
			self.mrGbML.lastReverse = Utils.getNoNil( old, false )
			self.mrGbML.DirectionChangeTime = g_currentMission.time
			self.mrGbML.ReverserNeutral     = true		
			gearboxMogli.mrGbMPrepareGearShift( self, self.mrGbMS.GearTimeToShiftReverse, 0, self.mrGbMS.ReverseDoubleClutch, false ) 
			if self.mrGbML.motor ~= nil and ( ( not ( new ) and old ) or ( new and not ( old ) ) ) then
				if self.mrGbMS.Hydrostatic then
					self.motor.hydrostaticFactor = self.mrGbMS.HydrostaticStart
				end
				self.mrGbML.motor.speedLimitS       = 0
				self.mrGbML.motor.motorLoadOverflow = 0
			end
		end	
	end
end 

--**********************************************************************************************************	
-- gearboxMogli:mrGbMGetAutoHold
--**********************************************************************************************************	
function gearboxMogli:mrGbMGetAutoHold( )
	if not ( self.steeringEnabled ) then
		return false
	elseif self.forceIsActive then
		return false
	elseif self:mrGbMGetAutoStartStop() then
		return true
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
	self.mrGbMS.NeutralActive = new 

	if self.mrGbMS.NeutralActive and self.mrGbMS.G27Mode <= 0  then
		self:mrGbMSetLanuchGear( noEventSend )
	end
	
	if self.isServer then
		gearboxMogli.mrGbMPrepareGearShift( self, 0, self.mrGbMS.MinClutchPercent, false, false ) 
		if self.mrGbML.motor ~= nil then
			self.mrGbML.motor.speedLimitS = 0
		end
		
		if self.mrGbMS.NeutralActive then
			if self.mrGbML.motor ~= nil and self.mrGbMS.Hydrostatic then
				self.motor.hydrostaticFactor = self.mrGbMS.HydrostaticStart
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
		if old ~= nil and self.mrGbMS.Ranges[old] ~= nil then
			if old < new and self.mrGbMS.Ranges[old].upShiftMs ~= nil and timeToShift < self.mrGbMS.Ranges[old].upShiftMs then
				timeToShift = self.mrGbMS.Ranges[old].upShiftMs
			end
			if old > new and self.mrGbMS.Ranges[old].downShiftMs ~= nil and timeToShift < self.mrGbMS.Ranges[old].downShiftMs then
				timeToShift = self.mrGbMS.Ranges[old].downShiftMs
			end
		end
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
		if old ~= nil and self.mrGbMS.Ranges2[old] ~= nil then
			if old < new and self.mrGbMS.Ranges2[old].upShiftMs ~= nil and timeToShift < self.mrGbMS.Ranges2[old].upShiftMs then
				timeToShift = self.mrGbMS.Ranges2[old].upShiftMs
			end
			if old > new and self.mrGbMS.Ranges2[old].downShiftMs ~= nil and timeToShift < self.mrGbMS.Ranges2[old].downShiftMs then
				timeToShift = self.mrGbMS.Ranges2[old].downShiftMs
			end
		end
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
	
	--timer to set the gear
	if self.isServer then			
		if old ~= nil and self.mrGbMS.Gears[old] ~= nil then
			if old < new and self.mrGbMS.Gears[old].upShiftMs ~= nil and timeToShift < self.mrGbMS.Gears[old].upShiftMs then
				timeToShift = self.mrGbMS.Gears[old].upShiftMs
			end
			if old > new and self.mrGbMS.Gears[old].downShiftMs ~= nil and timeToShift < self.mrGbMS.Gears[old].downShiftMs then
				timeToShift = self.mrGbMS.Gears[old].downShiftMs
			end
		end
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
			self:mrGbMSetState( "WarningText", string.format( "%s (in: %4.0f / out: %4.0f)",
																												gearboxMogli.getText( "gearboxMogliTEXT_DoubleClutch", "cannot shift gear; RPM" ),
																												self.motor.transmissionInputRpm, w ))
			self.mrGbMS.GrindingGearsVol = 0
			self:mrGbMSetState( "GrindingGearsVol", 1 )
			return false
		elseif v > 0 and v > self.mrGbMS.GrindingGearsVol then
			self:mrGbMSetState( "WarningText", string.format( "%s (in: %4.0f / out: %4.0f)",
																												gearboxMogli.getText( "gearboxMogliTEXT_DoubleClutch", "cannot shift gear; RPM" ),
																												self.motor.transmissionInputRpm, w ))
			self:mrGbMSetState( "GrindingGearsVol", v )
			return true
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

	if new then						
		if self.mrGbML.motor ~= nil then
			gearboxMogliMotor.copyRuntimeValues( self.mrGbMB.motor, self.mrGbML.motor )
			self.motor = self.mrGbML.motor
		end
		if self:mrGbMGetAutoHold() then
			self:mrGbMSetNeutralActive( true, noEventSend, true ) 
			self:mrGbMSetState( "AutoHold", true, noEventSend ) 
		end
		
		self:mrGbMSetLanuchGear( noEventSend )
		self:mrGbMDoGearShift( noEventSend ) 
		
		self.cruiseControl.maxSpeed   = self.mrGbMS.MaxGearSpeed * self.mrGbMS.MaxTargetRpmRatio * 3.6
		if self.mrGbMS.Hydrostatic then
			self.cruiseControl.maxSpeed = self.cruiseControl.maxSpeed * self.mrGbMS.HydrostaticMax
		end
		if self.mrGbMS.MaxSpeedLimiter and self.motor.maxForwardSpeed ~= nil and self.cruiseControl.maxSpeed > self.motor.maxForwardSpeed * 3.6 then
			self.cruiseControl.maxSpeed = self.motor.maxForwardSpeed * 3.6
		end	
		self.cruiseControl.speed = math.min( self.cruiseControl.speed, self.cruiseControl.maxSpeed )
	
		
		if self.mrUseMrTransmission then
			self.mrGbMB.mrUseMrTransmission = true
			self.mrUseMrTransmission        = false
		end
	elseif old then
		if self.mrGbML.motor ~= nil then
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
		
		if self.mrGbMB.mrUseMrTransmission then
			self.mrUseMrTransmission = true
		end
		self.mrGbMB.mrUseMrTransmission = nil
	end		
	
	self.mrGbMS.IsOn = new	
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
	if type( self.motor.mrGbMUpdateMotorRpm ) ~= "function" then
		return superFunc( self, dt, currentSpeed, acc, doHandbrake, requiredDriveMode, ... )
	end
	
	if     self.isHired then
	elseif self.mrGbMS.Handbrake then
		doHandbrake = true
	elseif self.forceIsActive then
		doHandbrake = false
	elseif self.mrGbMS.AutoHold
			or not ( self.isMotorStarted ) 
		  or g_currentMission.time < self.motorStartTime then
		doHandbrake = true
	end
	
	local acceleration        = acc
	local accelerationPedal   = 0
	local brakePedal          = 0
	local brakeLights         = false
	
	local oldHts              = self.lastSpeedReal*1000
	if self.motor.wheelSlipFactor ~= nil and self.motor.wheelSlipFactor > gearboxMogli.eps then 
		oldHts = oldHts / self.motor.wheelSlipFactor
	end
	if self.mrGbML.hydroTargetSpeed ~= nil then
		oldHts = math.min( oldHts, self.mrGbML.hydroTargetSpeed )
		self.mrGbML.hydroTargetSpeed = nil
	end

	if self.steeringEnabled then
	-- driveControl and GPS
		if      self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_ACTIVE
				or  self.cruiseControl.state == Drivable.CRUISECONTROL_STATE_FULL   then
			acceleration = 1
	--elseif  acceleration             > 0.97
	--		and self.mrGbMS.HandThrottle > 0.97 then
	--	-- full power to the "bauer"
		elseif  self.mrGbMS.Hydrostatic 
				and self.mrGbMS.ConstantRpm then 
			-- acceleration pedal controls speed instead of throttle 
			local m = self.motor.maxForwardSpeed
			if self.mrGbMS.ReverseActive then
				m = self.motor.maxBackwardSpeed 
			end
			local hMax = self.mrGbMS.HydrostaticMax
			if self.mrGbMS.ReverseActive and self.mrGbMS.HydrostaticMin < 0 then
				hMax = -self.mrGbMS.HydrostaticMin
			end
			
			local n = self.mrGbMS.AutoMaxGearSpeed * hMax * self.motor.minRequiredRpm / self.mrGbMS.RatedRpm
			
			if self.mrGbMS.MaxSpeedLimiter  then
				m = math.min( m, n )
			else 
				m = n
			end
			if self.mrGbMS.SpeedLimiter or self.cruiseControl.state > 0 then
				m = math.min( m, self.cruiseControl.speed * gearboxMogli.kmhTOms )
			end
			
			oldHts = math.max( 0, oldHts - self.mrGbMG.HydroSpeedIdleRedux * 0.001 * dt * self:mrGbMGetDecelerateToLimit() )
			self.mrGbML.hydroTargetSpeed = Utils.clamp( acceleration * m, oldHts, m )	
			
			if acceleration < -0.2 and self.motor.lastRealMotorRpm < self.motor.minRequiredRpm * gearboxMogli.rpmReduction then 
				acceleration = -0.2
			end
			
		--print(string.format("%3d %%, %3d km/h %3d km/h", acceleration*100, m*3.6, self.mrGbML.hydroTargetSpeed*3.6 ))
		end		
				
		if acceleration < -0.001 then
			brakeLights = true
	--elseif self.isMotorStarted and doHandbrake then
	--	brakeLights = true
		end
	elseif doHandbrake  then
		self.motor.speedLimitS = 0
		self:mrGbMSetNeutralActive( true )
		acceleration = -1
		if self.isMotorStarted and self.isHired then
			brakeLights = true
		end
	elseif self.movingDirection*currentSpeed*acc < -0.0003 then
		acceleration = -( 1 - ( 1 - math.abs( acc ) )^2 )
		self:mrGbMSetNeutralActive( true )
		if self.isMotorStarted and self.isHired then
			brakeLights = true
		end
	elseif math.abs( acc ) > 0.001 then
		acceleration = ( 1 - ( 1 - math.abs( acc ) )^2 )
		self:mrGbMSetReverseActive( acc < 0 )
		self:mrGbMSetNeutralActive( false )
		if currentSpeed * 3600 > self.motor.speedLimit + 1 then
			brakeLights = true
		end			
	else
		acceleration = 0
		self.motor.speedLimitS = 0
		self:mrGbMSetNeutralActive( true )
		if currentSpeed * 3600 > self.motor.speedLimit + 1 then
			brakeLights = true
		end			
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
--self.motor:updateMotorRpm( dt )
	self.motor:mrGbMUpdateMotorRpm( dt )
	local speedLimit = self.motor:updateSpeedLimit( dt, acceleration ) * 3.6
	local ccOn       = self.mrGbMS.MaxSpeedLimiter or self.mrGbMS.SpeedLimiter or ( self.cruiseControl.state > 0 )
	local ccBrake    = self.mrGbMS.CruiseControlBrake or self.mrGbMS.AllAuto
	if self.tempomatMogliV22 ~= nil and self.tempomatMogliV22.keepSpeedLimit ~= nil then
		ccOn    = true
		ccBrake = true
	end
	
	local currentSpeedKmh = currentSpeed * 3600
	
	if     not self.steeringEnabled then
	-- hired worker => limit max RPM
		self.motor.limitMaxRpm = true
	elseif not ccOn then
	-- speed limit off => no limit
		self.motor.limitMaxRpm = false
	elseif currentSpeedKmh <= speedLimit then
	-- below speed limit => limit max RPM
		self.motor.limitMaxRpm = true
	elseif self.motor.usedTransTorque < gearboxMogli.eps then
	-- no torque used => no limit => we can go faster downhill
		self.motor.limitMaxRpm = false
	-- else keep current value !!!
	end
		
	do
		local sl = self:getSpeedLimit(true)
		if      not self.motor.limitMaxRpm 
		    and ccOn
				and ccBrake
				and sl > speedLimit then
			sl = speedLimit
		end
		sl = sl + gearboxMogli.extraSpeedLimit + gearboxMogli.extraSpeedLimit
		local bp = 0
		if currentSpeedKmh >= sl + 1 then
			bp = 1
		elseif currentSpeedKmh > sl then
			bp = currentSpeedKmh - sl
		end
		if bp > gearboxMogli.eps then
			if bp > 0.8 then
				brakeLights  = true
			end
			bp = bp * 0.8
			if bp > brakePedal then
				brakePedal = bp
			end	
		end
	end
	
	local lastRotatedTime = self.mrGbML.lastRotatedTime
	self.mrGbML.lastRotatedTime = nil
	
	if     doHandbrake then
		-- hand brake
		if self.articulatedAxis ~= nil then
			if lastRotatedTime == nil then
				brakePedal = 1
			else
				brakePedal = 1 - 0.5 * ( lastRotatedTime - self.rotatedTime )
			end
			self.mrGbML.lastRotatedTime = self.rotatedTime
		else
			brakePedal = 1
		end
	elseif acceleration < 0 then
		-- braking 
		brakePedal   = -acceleration
	elseif not ( self.isMotorStarted ) 
			or g_currentMission.time < self.motorStartTime then
		accelerationPedal = 0
	elseif self.mrGbMS.ReverseActive then
		-- reverse 
		accelerationPedal = -acceleration
	else                
		-- forward        
		accelerationPedal =  acceleration
	end
	
	do
		local fx, ft = 0, 0
		if self.mrGbMS.ShuttleFactor < 0.999 then 
			local x = self.mrGbMS.ShuttleFactor
			fx = 6 * x * x - 11 * x + 5 -- 0=>5, 0.5=>1, 1=>0
			ft = fx * 1000
		end
			
		if      self.isMotorStarted
				and math.abs( currentSpeed ) > 2.778e-5
				and ( self:mrGbMGetAutoHold() or ( self:mrGbMGetAutoClutch() and acceleration > 0.001 ) )
				and self.mrGbMS.ManualClutch > self.mrGbMS.MinClutchPercent + 0.1
				and ( ( self.movingDirection * currentSpeed > 0 and self.mrGbMS.ReverseActive )
					 or ( self.movingDirection * currentSpeed < 0 and not ( self.mrGbMS.ReverseActive ) ) ) then
			-- wrong direction   
			if self.mrGbML.shuttleBrakeTimer == nil then 
				self.mrGbML.shuttleBrakeTimer = g_currentMission.time 
			end 
			local maxB, maxC = 1, 1
			if g_currentMission.time - self.mrGbML.shuttleBrakeTimer < ft then 
				maxB = Utils.clamp( ( g_currentMission.time - self.mrGbML.shuttleBrakeTimer ) / ft, 0, 1 )
			end
			if math.abs( currentSpeed ) * 3600 < fx then 
				maxC = math.abs( currentSpeed ) * 1800 / fx 
			end 
			local b  = math.min( maxB, maxC  )
			if b >= 0.2 then
				brakeLights = true
			end
			brakePedal = math.max( b, brakePedal )
		elseif self.mrGbML.shuttleBrakeTimer ~= nil then 
			self.mrGbML.shuttleBrakeTimer = nil
		end
		
		ft = math.max( ft-1000, 0 )
		
		if      not ( self.mrGbML.ReverserNeutral )
				and acceleration                    >  0.001
				and ft                              >= 1
				and self.mrGbML.DirectionChangeTime ~= nil 
				and self.mrGbML.DirectionChangeTime <= g_currentMission.time 
				and g_currentMission.time           <  self.mrGbML.DirectionChangeTime + ft then
			acceleration = math.min( acceleration, ( g_currentMission.time - self.mrGbML.DirectionChangeTime ) / ft ) 
		end
	end
	
	self.setBrakeLightsVisibility(self, brakeLights)
	if not ( self.isReverseDriving ) then
		self.setReverseLightsVisibility(self, self.mrGbMS.ReverseActive)
	end
	
	if acceleration > 0 or brakePedal <= 0 then
		local ref = 0
		if self.mrGbML.lastAcceleration ~= nil and self.mrGbML.lastAcceleration > 0 then
			ref = self.mrGbML.lastAcceleration
		end
		local diff = self.mrGbMG.maxDeltaAccPerMs * dt
		acceleration = ref + Utils.clamp( acceleration - ref, -diff, diff )
	end
	
	gearboxMogliMotor.mrGbMUpdateGear( self.motor, acceleration, doHandbrake )	
	
	local absAccelerationPedal = math.abs(accelerationPedal)
	local wheelDriveTorque = 0
	 
	self.mrGbML.lastAcceleration  = acceleration
	self.mrGbML.lastBrakePedal    = brakePedal 
	self.mrGbML.lastDoHandbrake   = doHandbrake 

	
	if next(self.differentials) ~= nil and self.motorizedNode ~= nil then
		local torque,brakePedalM,brakeForce = self.motor:getTorque(accelerationPedal, false) 
		local maxRpm      = self.motor:getCurMaxRpm()
		local ratio       = self.motor:getGearRatio( true )
		local maxRotSpeed = maxRpm * gearboxMogli.factorpi30
		local c           = 0
		
		brakePedal = math.max( brakePedal, brakePedalM, math.min( 1, brakeForce / math.max( gearboxMogli.eps, self.motor:getBrakeForce() ) ) )
			
		if self.mrGbMS.TorqueConverter and self.mrGbMS.ManualClutch > 0.9 then
			c = gearboxMogli.huge
		else
			local cp = self.motor.clutchPercent
			if self.mrGbMS.TorqueConverter then
				cp = self.mrGbMS.ManualClutch
			end

			if cp < gearboxMogli.minClutchPercent then
				c = 0
			else
				c = self.mrGbMG.clutchFactor * self.motor.maxMotorTorque * ( ( 0.5 * ( 1 - math.cos( math.pi * cp )) ) ^ self.mrGbMG.clutchExp )
			end
		end
		
		if self.mrGbMG.debugInfo then
			self.mrGbML.vehiclePropsInfo = string.format( "%4d, %6d, %5.3f, %4d", torque*1000, maxRpm, ratio, c*1000 )
		end
				
		if self.isEntered and Vehicle.debugRendering then
			local t
			if self.motor.torqueMultiplication ~= nil and self.motor.torqueMultiplication > gearboxMogli.eps and self.motor.ratioFactorG ~= nil then
				t = self.motor.ratioFactorG / self.motor.torqueMultiplication
			end
		
			debugInfo = {}
		--table.insert( debugInfo, { component1="motor", component2="idleThrottle",                        format="%3d%%", factor=100 } )
			table.insert( debugInfo, { component1="motor", component2="lastThrottle",                        format="%3d%%", factor=100 } )
			table.insert( debugInfo, { component1="motor", component2="autoClutchPercent",                   format="%3d%%", factor=100 } )
			table.insert( debugInfo, { component1="motor", component2="clutchPercent",                       format="%3d%%", factor=100 } )
			table.insert( debugInfo, { name="torque",                   value=torque,                        format="%3dNm", factor=1000 } )
			table.insert( debugInfo, { component1="motor", component2="lastBrakeForce",                      format="%3dNm", factor=1000 } )
			table.insert( debugInfo, { component1="motor", component2="lastMotorTorque",                     format="%3dNm", factor=1000 } )
			table.insert( debugInfo, { component1="motor", component2="usedTransTorque",                     format="%3dNm", factor=1000 } )
			table.insert( debugInfo, { component1="motor", component2="ptoMotorTorque",                      format="%3dNm", factor=1000 } )
			table.insert( debugInfo, { component1="motor", component2="lastMissingTorque",                   format="%3dNm", factor=1000 } )
			table.insert( debugInfo, { component1="motor", component2="nonClampedMotorRpm",                  format="%4d" } )
		--table.insert( debugInfo, { component1="motor", component2="lastRealMotorRpm",                    format="%4d" } )
			table.insert( debugInfo, { component1="motor", component2="transmissionEfficiency",              format="%3d%%", factor=100 } )
			table.insert( debugInfo, { component1="torque multiplication", value=t,                          format="%7.3f" } )
			table.insert( debugInfo, { name="maxRpm",                   value=maxRpm,                        format="%6d" } )
			table.insert( debugInfo, { name="motor:getCurMaxRpm(true)", value=self.motor:getCurMaxRpm(true), format="%6d" } )
			table.insert( debugInfo, { component1="motor", component2="wheelSpeedRpm",                       format="%7.3f" } )
			table.insert( debugInfo, { component1="motor", component2="gearRatio",                           format="%7.3f" } )
			table.insert( debugInfo, { component1="motor", component2="ratioFactorR",                        format="%7.3f" } )
			table.insert( debugInfo, { component1="motor", component2="hydrostaticFactor",                   format="%7.3f" } )
			table.insert( debugInfo, { component1="mrGbML", component2="fuelUsageRaw",                       format="%7.3f" } )
		
			setTextColor(1, 1, 1, 1) 
			setTextBold(false) 
			
			for col=1,2 do
				drawY = 0.40
				
				if col == 1 then
					setTextAlignment(RenderText.ALIGN_LEFT) 
				else
					setTextAlignment(RenderText.ALIGN_RIGHT) 
				end
		
				for row,info in pairs( debugInfo ) do
					if col == 1 then
						if info.name ~= nil then
							renderText(0.50, drawY, getCorrectTextSize(0.02), info.name)
						elseif info.component1 ~= nil and info.component2 then
							renderText(0.50, drawY, getCorrectTextSize(0.02), info.component1.."."..info.component2)
						elseif info.component1 ~= nil then
							renderText(0.50, drawY, getCorrectTextSize(0.02), info.component1)
						end
					else
						local v = nil
						
						if info.value ~= nil then
							v = info.value 
						elseif info.component1 ~= nil then
							v = self[info.component1]
							if v ~= nil and info.component2 ~= nil then
								v = v[info.component2]
							end
						end
						
						if v  == nil   then
							renderText(0.78, drawY, getCorrectTextSize(0.02), "nil")
						elseif info.format == nil   then
							renderText(0.78, drawY, getCorrectTextSize(0.02), tostring(v))
						elseif type( info.factor ) == "number" then
							renderText(0.78, drawY, getCorrectTextSize(0.02), string.format( info.format, v * info.factor ))
						else
							renderText(0.78, drawY, getCorrectTextSize(0.02), string.format( info.format, v ))
						end
					end
					
					drawY = drawY - 0.02
					if drawY < 0.02 then
						break
					end
				end
			end
			
			setTextAlignment(RenderText.ALIGN_LEFT) 
		end
		
		setVehicleProps(self.motorizedNode, torque, maxRotSpeed, ratio, c, self.motor:getRotInertia(), self.motor:getDampingRate())
		
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
		
		if self.mrIsMrVehicle then
			self.motor.mrLastAxleTorque         = torque * ratio
			self.motor.mrLastEngineOutputTorque = self.motor.lastMotorTorque				
			self.motor.mrLastDummyGearRatio     = ratio
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

	local doBrake = brakePedal > 0 --(brakePedal > 0 and self.lastSpeed > 0.0002) or doHandbrake			  -- ToDo
	for _, implement in pairs(self.attachedImplements) do
		if implement.object ~= nil then
			if doBrake then
				implement.object:onBrake(brakePedal)
			else
				implement.object:onReleaseBrake()
			end
		end
	end
	
	if      self.mrGbMB.mrUseMrTransmission 
			and self.mrGbMG.useMrUWP > 0 
			and type( WheelsUtil.mrUpdateWheelPhysics ) == "function" then
			
		if self.steeringEnabled then
			if self.mrLastBrakePedal == nil then self.mrLastBrakePedal = 0 end		
			--braking is not "ON/OFF" IRL => smooth a little the response time of the braking system (especially useful when playing with a keyboard)
			if brakePedal>self.mrLastBrakePedal then
				brakePedal = math.min(brakePedal, self.mrLastBrakePedal + dt/500) --500ms to be able to fully brake from a "null brake position"  --20170305
			end
		end
		self.mrLastBrakePedal = brakePedal
		--MR : we want to know when the vehicle is braking
		self.mrIsBraking = brakePedal>0
	
		for _, wheel in pairs(self.wheels) do
			local s, m = pcall( WheelsUtil.mrUpdateWheelPhysics, self, wheel, doHandbrake, brakePedal ) 
			if not s then
				print("ERROR in gearboxMogli: "..tostring(m))
				self.mrGbMG.useMrUWP = self.mrGbMG.useMrUWP - 1
				WheelsUtil.updateWheelPhysics(self, wheel, doHandbrake, wheelDriveTorque, brakePedal, requiredDriveMode, dt)
			end
		end
	else
		for _, wheel in pairs(self.wheels) do
			WheelsUtil.updateWheelPhysics(self, wheel, doHandbrake, wheelDriveTorque, brakePedal, requiredDriveMode, dt)
		end
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
-- gearboxMogli:afterLoadMotor
--**********************************************************************************************************	
function gearboxMogli:afterLoadMotor(xmlFile)
	if self.mrGbML ~= nil then 
		self.mrGbML.motor = nil
	end
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
	elseif type( self.motor.mrGbMUpdateMotorRpm ) ~= "function" then
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
				
				local speed = tonumber(string.format("%."..hudItem.precision.."f", displayedValue))
				Utils.setNumberShaderByValue(hudItem.numbers, speed, hudItem.precision, true)
				hudItem.lastValue = value
			end
		end
		
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
				self:setAnimationTime(hudItem.animName, normValue, true)
				hudItem.lastNormValue = normValue
			end
		end
	end
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
		self.motor.lastMotorRpm   = self.mrGbMS.CurMinRpm + streamReadUIntN(streamId, 11) * ( self.mrGbMS.CurMaxRpm - self.mrGbMS.CurMinRpm ) / 2047
		self.motor:setEqualizedMotorRpm( self:mrGbMGetEqualizedRpm( self.motor.lastMotorRpm ) )
		self.actualLoadPercentage = streamReadUIntN(streamId, 7) / 127

		if streamReadBool(streamId) then
			local fuelFillLevel = streamReadUIntN(streamId, 15)/32767*self.fuelCapacity
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
		
		streamWriteUIntN(streamId, Utils.clamp( math.floor( 0.5 + rpm * 2047), 0, 2047 ), 11)
		streamWriteUIntN(streamId, Utils.clamp( math.floor( 0.5 + self.actualLoadPercentage * 127 ), 0, 127 ), 7)

		if streamWriteBool(streamId, bitAND(dirtyMask, self.motorizedDirtyFlag) ~= 0) then
			local percent = 0
			if self.fuelCapacity ~= 0 then
				percent = Utils.clamp(self.fuelFillLevel / self.fuelCapacity, 0, 1)
			end
			streamWriteUIntN(streamId, math.floor(percent*32767), 15)
		end
	end
end

--**********************************************************************************************************			
-- Motorized:setLastRpm
--**********************************************************************************************************			
function gearboxMogli:setLastRpm(lastRpm)
end

function gearboxMogli:afterCylinderedSetDirty( part )
	if not ( part.playSound ) then return end
	if type( self.getRootAttacherVehicle ) ~= "function" then return end
	local rootVehicle = self:getRootAttacherVehicle()
	if rootVehicle.mrGbMS ~= nil and rootVehicle.mrGbMGetIsOn ~= nil and rootVehicle:mrGbMGetIsOn() then
		rootVehicle:mrGbMSetState( "ToolIsDirty2", true )
	end
end

function gearboxMogli:afterUpdateAttacherJointRotation(superFunc, jointDesc, object)
	if type( self.getRootAttacherVehicle ) ~= "function" then return end
	local rootVehicle = self:getRootAttacherVehicle()
	if rootVehicle.mrGbMS ~= nil and rootVehicle.mrGbMGetIsOn ~= nil and rootVehicle:mrGbMGetIsOn() then
		rootVehicle:mrGbMSetState( "ToolIsDirty2", true )
	end
end

--**********************************************************************************************************	
WheelsUtil.updateWheelsPhysics = Utils.overwrittenFunction( WheelsUtil.updateWheelsPhysics,gearboxMogli.newUpdateWheelsPhysics )
VehicleHudUtils.setHudValue = Utils.overwrittenFunction( VehicleHudUtils.setHudValue, gearboxMogli.newSetHudValue )
Motorized.loadMotor = Utils.appendedFunction( Motorized.loadMotor, gearboxMogli.afterLoadMotor )
Motorized.readUpdateStream = Utils.overwrittenFunction( Motorized.readUpdateStream, gearboxMogli.newReadUpdateStream )
Motorized.writeUpdateStream = Utils.overwrittenFunction( Motorized.writeUpdateStream, gearboxMogli.newWriteUpdateStream )
Cylindered.setDirty = Utils.appendedFunction( Cylindered.setDirty, gearboxMogli.afterCylinderedSetDirty )
AttacherJoints.updateAttacherJointRotation = Utils.appendedFunction( AttacherJoints.updateAttacherJointRotation, gearboxMogli.afterUpdateAttacherJointRotation )
--**********************************************************************************************************	

--local oldClamp = Utils.clamp
--function Utils.clamp(value, minVal, maxVal)
--	if value == nil or minVal == nil or maxVal == nil then
--		gearboxMogli.debugEvent( nil, value, minVal, maxVal )
--		return value
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
	print("vehicle.mrGbMGetFuelUsageRate        : "..tostring(vehicle:mrGbMGetFuelUsageRate())) 	
	
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

--**********************************************************************************************************	
-- gearboxMogli:showSettingsUI
--**********************************************************************************************************	
function gearboxMogli:showSettingsUI()
	if g_gui:getIsGuiVisible() then
		return 
	end
	if g_gearboxMogliScreen == nil then
		return
	end

	self.mrGbMUI = {}
	
	self.mrGbMUI.Automatic = {}

	local tab = gearboxMogli.mrGbMUIAutomaticHelper( self )
	for i,v in pairs(tab) do
		if     v == "M" then
			table.insert( self.mrGbMUI.Automatic, gearboxMogli.getText( "gearboxMogliTEXT_MANUAL", "manual" ) )
		elseif v == "A" then
			table.insert( self.mrGbMUI.Automatic, gearboxMogli.getText( "gearboxMogliTEXT_AUTO", "automatic" ) )
		elseif v == "S" then
			table.insert( self.mrGbMUI.Automatic, gearboxMogli.getText( "gearboxMogliTEXT_ALLAUTO", "simple" ) )
		elseif v == "H" then
			table.insert( self.mrGbMUI.Automatic, gearboxMogli.getText( "gearboxMogliTEXT_AI", "hired worker" ) )
		else
			table.insert( self.mrGbMUI.Automatic, "ERROR: "..tostring(v) )
		end
	end
	
	if self:mrGbMGetHasAllAuto() then
		local jj
		if self.mrGbMS.CountGearsF > 1 then
			self.mrGbMUI.AllAutoModeID = { 0, 1 }
			jj = 2
		else
			self.mrGbMUI.AllAutoModeID = { 0 }						
			jj = 1
		end
		
		if self.mrGbMS.CountRange1F > 1 then
			for j=1,jj do
				self.mrGbMUI.AllAutoModeID[j+jj] = self.mrGbMUI.AllAutoModeID[j]+2
			end
			jj = jj+jj
		end
		
		if self.mrGbMS.CountRange2F > 1 then
			for j=1,jj do
				self.mrGbMUI.AllAutoModeID[j+jj] = self.mrGbMUI.AllAutoModeID[j]+4
			end
			jj = jj+jj
		end
		
		self.mrGbMUI.AllAutoMode = {}
		for j=1,jj do
			if     self.mrGbMUI.AllAutoModeID[j] == 0 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_0", "sequential" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 1 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_1", "gears" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 2 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_2", "ranges" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 3 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_3", "gears & ranges" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 4 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_4", "ranges2" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 5 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_5", "gears & ranges2" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 6 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_6", "ranges & ranges2" )
			elseif self.mrGbMUI.AllAutoModeID[j] == 7 then
				self.mrGbMUI.AllAutoMode[j] = gearboxMogli.getText( "gearboxMogliTEXT_AllAutoMode_7", "all" )
			else
				self.mrGbMUI.AllAutoMode[j] = "ERROR" 
			end
		end
	else
		self.mrGbMUI.AllAutoModeID = { 7 }
		self.mrGbMUI.AllAutoMode   = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	end

	local default = self.mrGbMS.EnableAI
	if default == gearboxMogli.AIGearboxOff then
		default = self.mrGbMS.EnableAI0
	end
	if default == gearboxMogli.AIGearboxOff then
		default = gearboxMogli.AIGearboxOn
	end
	
	if     self.mrGbMS.Hydrostatic then
		self.mrGbMUI.EnableAIID = { gearboxMogli.AIGearboxOff, default }
		self.mrGbMUI.EnableAI   = { gearboxMogli.getText( "gearboxMogliTEXT_DISABLED", "off" ), 
																gearboxMogli.getText( "gearboxMogliTEXT_VARIO", "CVT" ) }
	elseif self.mrGbMS.AllAuto     then
		self.mrGbMUI.EnableAIID = { gearboxMogli.AIGearboxOff, default }
		self.mrGbMUI.EnableAI   = { gearboxMogli.getText( "gearboxMogliTEXT_DISABLED", "off" ), 
																gearboxMogli.getText( "gearboxMogliTEXT_ALLAUTO", "simple" ) }
	else
		self.mrGbMUI.EnableAIID = { gearboxMogli.AIGearboxOff, gearboxMogli.AIPowerShift, gearboxMogli.AIAllAuto, gearboxMogli.AIGearboxOn }
		self.mrGbMUI.EnableAI   = { gearboxMogli.getText( "gearboxMogliTEXT_DISABLED", "off" ), 
																gearboxMogli.getText( "gearboxMogliTEXT_POWERSHIFT", "power shift" ), 
																gearboxMogli.getText( "gearboxMogliTEXT_ALLAUTO", "simple" ), 
																gearboxMogli.getText( "gearboxMogliTEXT_MANUAL", "manual" ) }
	end
	
	self.mrGbMUI.GearShifterMode    = { gearboxMogli.getText( "gearboxMogliTEXT_GearShifter_both", "Keyboard & G27" ), 
																			gearboxMogli.getText( "gearboxMogliTEXT_GearShifter_key", "Keyboard" ),
																			gearboxMogli.getText( "gearboxMogliTEXT_GearShifter_G27", "G27" ) }
	self.mrGbMUI.ShuttleShifterMode = { gearboxMogli.getText( "gearboxMogliTEXT_Shuttle_both", "Toggle and Fwd-/Back-Buttons" ), 
																			gearboxMogli.getText( "gearboxMogliTEXT_Shuttle_toggle", "Toggle" ), 
																			gearboxMogli.getText( "gearboxMogliTEXT_Shuttle_back_fwd", "Fwd-/Back-Buttons" ) }
  if self.mrGbMS.CountRange1F > 1 then
		self.mrGbMUI.Range1ShifterMode  = { gearboxMogli.getText( "gearboxMogliTEXT_RangeShifter_toggle", "Toggle button" ), 
																				gearboxMogli.getText( "gearboxMogliTEXT_RangeShifter_high_on", "High if button is pressed" ),
																				gearboxMogli.getText( "gearboxMogliTEXT_RangeShifter_low_on", "Low if button is pressed" ) }
	else 
		self.mrGbMUI.Range1ShifterMode  = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	end
	
  if self.mrGbMS.CountRange2F > 1 then
		self.mrGbMUI.Range2ShifterMode  = { gearboxMogli.getText( "gearboxMogliTEXT_RangeShifter_toggle", "Toggle button" ), 
																				gearboxMogli.getText( "gearboxMogliTEXT_RangeShifter_high_on", "High if button is pressed" ),
																				gearboxMogli.getText( "gearboxMogliTEXT_RangeShifter_low_on", "Low if button is pressed" ) }
	else 
		self.mrGbMUI.Range2ShifterMode  = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	end
	
	if not ( self.mrGbMS.IsOn and self.steeringEnabled ) then
		self.mrGbMUI.DiffLockMiddle = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		self.mrGbMUI.DiffLockFront  = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		self.mrGbMUI.DiffLockBack   = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	elseif  self.mrGbMS.ModifyDifferentials              then
		local function getOpenText( torqueRatio, torqueSense, speedRatio )
			if     torqueSense >  0.81 then
				return gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_open", "open" )
			elseif torqueSense >  gearboxMogli.eps then
				return gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_lsd", "limited slip" )
			elseif torqueSense < -gearboxMogli.eps then
				return gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_auto", "self locking" )
			else
				return gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_fixed", "fxied ratio" )
			end
		end
		
		if     self.mrGbMS.TorqueRatioMiddle < 0 then
			self.mrGbMUI.DiffLockMiddle = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		elseif self.mrGbMS.TorqueRatioMiddle == 0 or self.mrGbMS.TorqueRatioMiddle == 1 then
			self.mrGbMUI.DiffLockMiddle = { gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_2wd", "2wd" ),
																			gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_4wd", "4wd" ) }
		else
			self.mrGbMUI.DiffLockMiddle = { getOpenText( self.mrGbMS.TorqueRatioMiddle, self.mrGbMS.TorqueSenseMiddle, self.mrGbMS.SpeedRatioMiddle ),
																			gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_locked", "locked" ) }
		end
		if self.mrGbMS.TorqueRatioFront < 0 then
			self.mrGbMUI.DiffLockFront  = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		else
			self.mrGbMUI.DiffLockFront  = { getOpenText( self.mrGbMS.TorqueRatioFront, self.mrGbMS.TorqueSenseFront, self.mrGbMS.SpeedRatioFront ),
																			gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_locked", "locked" ) }
		end
		if self.mrGbMS.TorqueRatioBack < 0 then
			self.mrGbMUI.DiffLockBack   = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		else
			self.mrGbMUI.DiffLockBack   = { getOpenText( self.mrGbMS.TorqueRatioBack, self.mrGbMS.TorqueSenseBack, self.mrGbMS.SpeedRatioBack ),
																			gearboxMogli.getText( "gearboxMogliTEXT_DiffLock_locked", "locked" ) }
		end
		
	elseif  self.dCcheckModule ~= nil 
			and self:dCcheckModule("fourWDandDifferentials") then
		self.mrGbMUI.DiffLockMiddle = { "zzzDriveControl" }
		self.mrGbMUI.DiffLockFront  = { "zzzDriveControl" }
		self.mrGbMUI.DiffLockBack   = { "zzzDriveControl" }
	else
		self.mrGbMUI.DiffLockMiddle = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		self.mrGbMUI.DiffLockFront  = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
		self.mrGbMUI.DiffLockBack   = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	end	
	
	self.mrGbMUI.FixedRatioSteps = 1
--if self.mrGbMS.Hydrostatic and not ( self.mrGbMS.ConstantRpm ) then
	if self.mrGbMS.Hydrostatic then
		local _,_,maxSp = self:mrGbMGetGearSpeed()
		local refRpm = self.mrGbMS.RatedRpm
		local limit  = gearboxMogli.huge
		
		if self.mrGbMS.ConstantRpm then
			refRpm = self:mrGbMGetTargetRPM()
			maxSp  = maxSp * refRpm / self.mrGbMS.RatedRpm
		end
		
		if self.mrGbMS.MaxSpeedLimiter then
			if self.mrGbMS.ReverseActive then
				if self.motor.maxBackwardSpeed ~= nil then
					limit = 3.6 * self.motor.maxBackwardSpeed
				end
			else
				if self.motor.maxForwardSpeed ~= nil then
					limit = 3.6 * self.motor.maxForwardSpeed
				end
			end
		end		
		
		self.mrGbMUI.FixedRatio = { gearboxMogli.getText( "gearboxMogliTEXT_DISABLED", "off" ) }
		self.mrGbMUI.FixedRatioSteps = math.max( 1, maxSp / self.mrGbMG.uiFixedRatioStep )
		if math.floor( self.mrGbMUI.FixedRatioSteps ) >= 0.98 * self.mrGbMUI.FixedRatioSteps then
			self.mrGbMUI.FixedRatioSteps = self.mrGbMUI.FixedRatioSteps - 1
		end
		for i=1,math.floor( self.mrGbMUI.FixedRatioSteps ) do
			local kmh = maxSp * i / self.mrGbMUI.FixedRatioSteps
			if kmh <= limit then
				table.insert( self.mrGbMUI.FixedRatio, string.format( "%3d %s @ %4d %s", g_i18n:getSpeed(kmh), gearboxMogli.getSpeedMeasuringUnit(), refRpm, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" ) ) )
			else
				table.insert( self.mrGbMUI.FixedRatio, string.format( "%3d %s @ %4d %s", g_i18n:getSpeed(limit), gearboxMogli.getSpeedMeasuringUnit(), refRpm * limit / kmh, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" ) ) )
			end
		end
		if maxSp <= limit then
			table.insert( self.mrGbMUI.FixedRatio, string.format( "%3d %s @ %4d %s", g_i18n:getSpeed(maxSp), gearboxMogli.getSpeedMeasuringUnit(), refRpm, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" ) ) )
		else
			table.insert( self.mrGbMUI.FixedRatio, string.format( "%3d %s @ %4d %s", g_i18n:getSpeed(limit), gearboxMogli.getSpeedMeasuringUnit(), refRpm * limit / maxSp, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" ) ) )
		end
	else
		self.mrGbMUI.FixedRatio = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	end
	
	self.mrGbMUI.HandThrottle = { gearboxMogli.getText( "gearboxMogliTEXT_DISABLED", "off" ) }
	
	self.mrGbMUI.HandThrottleSteps = math.max( 1, ( self.mrGbMS.MaxTargetRpm - self.mrGbMS.IdleRpm ) / self.mrGbMG.uiHandThrottleStep )
	if math.floor( self.mrGbMUI.HandThrottleSteps ) >= 0.98 * self.mrGbMUI.HandThrottleSteps then
		self.mrGbMUI.HandThrottleSteps = self.mrGbMUI.HandThrottleSteps - 1
	end
	for i=1,math.floor( self.mrGbMUI.HandThrottleSteps ) do
		local handRpm = self.mrGbMS.IdleRpm + ( self.mrGbMS.MaxTargetRpm - self.mrGbMS.IdleRpm ) * i / self.mrGbMUI.HandThrottleSteps
		table.insert( self.mrGbMUI.HandThrottle, string.format("%4.0f %s", math.floor( handRpm * 0.1 +0.5)*10, gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" )))
	end
	table.insert( self.mrGbMUI.HandThrottle, string.format("%4.0f %s", self.mrGbMS.MaxTargetRpm , gearboxMogli.getText("gearboxMogliUNIT_rpm", "rpm" )))
	self.mrGbMUI.MaxTarget = self.mrGbMUI.HandThrottle
	self.mrGbMUI.MinTarget = self.mrGbMUI.HandThrottle
	
	if      self.mrGbMS.MatchGears == "false" 
			and ( self.mrGbMS.DisableManual 
				 or math.max( self.mrGbMS.CountGearsF,  self.mrGbMS.CountGearsR  ) < 2
				 or math.max( self.mrGbMS.CountRange1F, self.mrGbMS.CountRange1R ) < 2
				 or self.mrGbMS.AutoShiftGears ) then
		self.mrGbMUI.MatchGears  = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	else
		self.mrGbMUI.MatchGears  = { gearboxMogli.getText( "gearboxMogliTEXT_MATCH_1", "off" ),
																 gearboxMogli.getText( "gearboxMogliTEXT_MATCH_2", "end" ),
																 gearboxMogli.getText( "gearboxMogliTEXT_MATCH_3", "on" ) }
	end
	if      self.mrGbMS.MatchRanges == "false" 
			and ( self.mrGbMS.DisableManual 
				 or math.max( self.mrGbMS.CountGearsF,  self.mrGbMS.CountGearsR  ) < 2
				 or math.max( self.mrGbMS.CountRange1F, self.mrGbMS.CountRange1R ) < 2
				 or self.mrGbMS.AutoShiftHl ) then
		self.mrGbMUI.MatchRanges = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	else
		self.mrGbMUI.MatchRanges = { gearboxMogli.getText( "gearboxMogliTEXT_MATCH_1", "off" ),
																 gearboxMogli.getText( "gearboxMogliTEXT_MATCH_2", "end" ),
																 gearboxMogli.getText( "gearboxMogliTEXT_MATCH_3", "on" ) }
	end
		
	self.mrGbMUI.AutoGearSpeedID  = { 0 }
	if self.mrGbMS.DisableManual then
		self.mrGbMUI.MinAutoGearSpeed = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	else
		local im = -1
		local gs = {}
		for ig,g in pairs(self.mrGbMS.Gears) do
			for i1,r1 in pairs(self.mrGbMS.Ranges) do
				for i2,r2 in pairs(self.mrGbMS.Ranges2) do
					if      not (  g.reverseOnly )
							and not ( r1.reverseOnly )
							and not ( r2.reverseOnly ) then
						local i = math.floor( 0.5 + 10 * g.speed * r1.ratio * r2.ratio * self.mrGbMS.GlobalRatioFactor * 3.6 )
						if 0.1 * i - 0.05 > self.mrGbMG.minAutoGearSpeed then
							if im < i then im = i end
							local t = gearboxMogli.mrGbMGetGearText2(self, ig, i1, i2)
							if gs[i] == nil then
								gs[i] = t
							else
								gs[i] = gs[i]..", "..t
							end
						end
					end
				end
			end
		end
		
		self.mrGbMUI.MinAutoGearSpeed = { gearboxMogli.getText( "gearboxMogliTEXT_DISABLED", "off" ) }
		for i=1,im do
			if gs[i] ~= nil then
				local s = 0.1 * i
				local v = string.format( "%5.1f %s", g_i18n:getSpeed(s), gearboxMogli.getSpeedMeasuringUnit())
				if gs[i] ~= "" then
					v = v.." ("..gs[i]..")"
				end
				table.insert( self.mrGbMUI.AutoGearSpeedID , s )
				table.insert( self.mrGbMUI.MinAutoGearSpeed, v )
			end
		end
	end
	self.mrGbMUI.MaxAutoGearSpeed = self.mrGbMUI.MinAutoGearSpeed
	
	self.mrGbMUI.AccelerateToLimit = {}
	for i=1,20 do 
		table.insert( self.mrGbMUI.AccelerateToLimit, string.format( "+%2.1f %s/s / -%2.1f %s/s", 
																																 g_i18n:getSpeed(i),
																																 gearboxMogli.getSpeedMeasuringUnit(),
																																 g_i18n:getSpeed(i * self.mrGbMG.decAccToLimitRatio),
																																 gearboxMogli.getSpeedMeasuringUnit() ))
	end
	
	if self.mrGbMS.DisableManual then 
		self.mrGbMUI.ResetFwdGear   = { gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" ) }
	  self.mrGbMUI.ResetFwdRange  = self.mrGbMUI.ResetFwdGear
	  self.mrGbMUI.ResetFwdRange2 = self.mrGbMUI.ResetFwdGear
		self.mrGbMUI.ResetRevGear   = self.mrGbMUI.ResetFwdGear
		self.mrGbMUI.ResetRevRange  = self.mrGbMUI.ResetFwdGear
		self.mrGbMUI.ResetRevRange2 = self.mrGbMUI.ResetFwdGear
	else
		local function appendText( tabName, fwdName, revName )
			self.mrGbMUI[fwdName] = {}
			self.mrGbMUI[revName] = {}
			for _,g in pairs( self.mrGbMS[tabName] ) do 
				if not ( g.reverseOnly ) then	
					local n = g.name 
					if g.name == nil or g.name == "" then
						if table.getn( self.mrGbMS[tabName] ) <= 1 then 
							n = gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" )
						else 
							n = '""' --string.format("(F %d)",1 + table.getn( self.mrGbMUI[fwdName] ))
						end
					end 
					table.insert( self.mrGbMUI[fwdName], n )
				end
				if not ( g.forwardOnly ) then	
					local n = g.name 
					if g.name == nil or g.name == "" then
						if table.getn( self.mrGbMS[tabName] ) <= 1 then 
							n = gearboxMogli.getText( "gearboxMogliTEXT_N_A", "n/a" )
						else 
							n = '""' --string.format("(R %d)",1 + table.getn( self.mrGbMUI[revName] ))
						end
					end 
					table.insert( self.mrGbMUI[revName], n )
				end
			end 
		end
				
		appendText( "Gears",   "ResetFwdGear",   "ResetRevGear"   )
		appendText( "Ranges",  "ResetFwdRange",  "ResetRevRange"  )
		appendText( "Ranges2", "ResetFwdRange2", "ResetRevRange2" )
	end
	
	for n,t in pairs(self.mrGbMUI) do
		if type( t ) == "table" and g_gearboxMogliScreen[n] ~= nil then
			local element = g_gearboxMogliScreen[n]
			if type( element.setDisabled ) == "function" then
				element:setDisabled( table.getn( t ) <= 1 )
			end
		end
	end
	
	g_gearboxMogliScreen:setVehicle( self )
	g_gui:showGui( "gearboxMogliScreen" )
end


function gearboxMogli:mrGbMUISetAllAutoMode( value )
	if self.mrGbMUI ~= nil and self.mrGbMUI.AllAutoModeID ~= nil and self.mrGbMUI.AllAutoModeID[value] ~= nil then
		self:mrGbMSetState( "AllAutoMode", self.mrGbMUI.AllAutoModeID[value] )
	end
end
function gearboxMogli:mrGbMUIGetAllAutoMode()
	if self.mrGbMUI ~= nil and self.mrGbMUI.AllAutoModeID ~= nil then
		if     table.getn( self.mrGbMUI.AllAutoModeID ) == 1 then
			return 1 
		elseif self.mrGbMS.AllAutoMode <= 0 then
			return 1
		elseif self.mrGbMS.AllAutoMode >= 7 then
			return table.getn( self.mrGbMUI.AllAutoModeID )
		end
		
		local m = 0
		if self.mrGbMS.CountGearsF  > 1 and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 1 ) > 0 then
			m = m + 1
		end
		if self.mrGbMS.CountRange1F > 1 and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 2 ) > 0 then
			m = m + 2
		end
		if self.mrGbMS.CountRange2F > 1 and gearboxMogli.getBit3( self.mrGbMS.AllAutoMode, 3 ) > 0 then
			m = m + 4
		end
		
		for j,a in pairs( self.mrGbMUI.AllAutoModeID ) do
			if m <= a then
				return j
			end
		end
	end
	return 1
end

function gearboxMogli:mrGbMUIAutomaticHelper()
	local tab

	if self.steeringEnabled then
		if self.mrGbMS.DisableManual then
			tab = { "A" }
		elseif self.mrGbMS.AutoShiftGears or self.mrGbMS.AutoShiftHl or self.mrGbMS.AutoShiftRange2 then
			tab = { "M", "A" }
		else
			tab = { "M" }
		end
	
		if self:mrGbMGetHasAllAuto() then
			table.insert( tab, "S" )
		end
	else
		tab = { "H", "S" }
	end

	return tab
end

function gearboxMogli:mrGbMUISetAutomatic( value )
	local tab = gearboxMogli.mrGbMUIAutomaticHelper( self )
	
	if tab[value] ~= nil then
		if     tab[value] == "S" then
			self:mrGbMSetState( "AllAuto2", true )
		elseif tab[value] == "H" then
			self:mrGbMSetState( "AllAuto2", false )
		elseif tab[value] == "M" then
			self:mrGbMSetState( "AllAuto2", false )
			self:mrGbMSetState( "Automatic", false )
		elseif tab[value] == "A" then
			self:mrGbMSetState( "AllAuto2", false )
			self:mrGbMSetState( "Automatic", true )
		end
	end
end
function gearboxMogli:mrGbMUIGetAutomatic()
	local tab = gearboxMogli.mrGbMUIAutomaticHelper( self )
	
	local tab2 = {}
	for i,v in pairs( tab ) do
		tab2[v] = i
	end
	
	local value = "M"
	
	if self.mrGbMS.AllAuto then 
		value = "S"
	elseif not self.steeringEnabled then
		value = "H"
	elseif self.mrGbMS.DisableManual or self.mrGbMS.Automatic then
		value = "A"
	end
	
	if tab2[value] == nil then
		return 1 
	end
	return tab2[value]
end

function gearboxMogli:mrGbMUISetDiffLockMiddle( value )
	if self.mrGbMS.ModifyDifferentials and self.mrGbMS.IsOn and self.steeringEnabled then
		self:mrGbMSetState( "DiffLockMiddle", value > 1 )
	end
end
function gearboxMogli:mrGbMUIGetDiffLockMiddle( )
	if self:mrGbMGetDiffLockMiddle() then
		return 2
	end
	return 1
end

function gearboxMogli:mrGbMUISetDiffLockFront( value )
	if self.mrGbMS.ModifyDifferentials and self.mrGbMS.IsOn and self.steeringEnabled then
		self:mrGbMSetState( "DiffLockFront", value > 1 )
	end
end
function gearboxMogli:mrGbMUIGetDiffLockFront( )
	if self:mrGbMGetDiffLockFront() then
		return 2
	end
	return 1
end

function gearboxMogli:mrGbMUISetDiffLockBack( value )
	if self.mrGbMS.ModifyDifferentials and self.mrGbMS.IsOn and self.steeringEnabled then
		self:mrGbMSetState( "DiffLockBack", value > 1 )
	end
end
function gearboxMogli:mrGbMUIGetDiffLockBack( )
	if self:mrGbMGetDiffLockBack() then
		return 2
	end
	return 1
end

function gearboxMogli:mrGbMUISetEnableAI( value )
	if self.mrGbMUI ~= nil and self.mrGbMUI.EnableAIID ~= nil and self.mrGbMUI.EnableAIID[value] ~= nil then
		self:mrGbMSetState( "EnableAI", self.mrGbMUI.EnableAIID[value] )
	end
end
function gearboxMogli:mrGbMUIGetEnableAI( )
	if self.mrGbMUI ~= nil and self.mrGbMUI.EnableAIID ~= nil then
		if table.getn( self.mrGbMUI.EnableAIID ) == 1 then
			return 1 
		end
		for j,e in pairs( self.mrGbMUI.EnableAIID ) do
			if self.mrGbMS.EnableAI == e then
				return j
			end
		end
	end
	return 1
end

function gearboxMogli:mrGbMUISetFixedRatio( value )
	if value <= 1 then
		self:mrGbMSetFixedRatio( 0 )
	elseif value - 1 >= self.mrGbMUI.FixedRatioSteps then
		self:mrGbMSetFixedRatio( 1 )
	else
		self:mrGbMSetFixedRatio( ( value - 1 ) / self.mrGbMUI.FixedRatioSteps )
	end
end
function gearboxMogli:mrGbMUIGetFixedRatio( )
	if     self.mrGbMS.FixedRatio <  gearboxMogli.eps then
		return 1
	elseif self.mrGbMS.FixedRatio >= 1 then
		return 1 + self.mrGbMUI.FixedRatioSteps
	elseif self.mrGbMS.Hydrostatic then
		return 1 + math.floor( 0.5 + self.mrGbMS.FixedRatio * self.mrGbMUI.FixedRatioSteps )
	end
	return 1
end

function gearboxMogli:mrGbMUISetXXThrottle( value, setter )
	if     value <= 1 then
		setter( self, 0 )
	elseif value - 1 >= self.mrGbMUI.HandThrottleSteps then
		setter( self, 1 )
	else
		setter( self, ( value - 1 ) / self.mrGbMUI.HandThrottleSteps )
	end
end
function gearboxMogli:mrGbMUIGetXXThrottle( attr )
	if     self.mrGbMS[attr] <  gearboxMogli.eps then
	elseif self.mrGbMS[attr] >= 1 then
		return 1 + self.mrGbMUI.HandThrottleSteps
	end
	return 1 + math.floor( 0.5 + self.mrGbMS[attr] * self.mrGbMUI.HandThrottleSteps )
end

function gearboxMogli:mrGbMUISetHandThrottle( value )
	gearboxMogli.mrGbMUISetXXThrottle( self, value, gearboxMogli.mrGbMSetHandThrottle )
end
function gearboxMogli:mrGbMUIGetHandThrottle( )
	return gearboxMogli.mrGbMUIGetXXThrottle( self, "HandThrottle" )
end

function gearboxMogli:mrGbMUISetMinTarget( value )
	gearboxMogli.mrGbMUISetXXThrottle( self, value, gearboxMogli.mrGbMSetMinTarget )
end
function gearboxMogli:mrGbMUIGetMinTarget( )
	return gearboxMogli.mrGbMUIGetXXThrottle( self, "MinTarget" )
end

function gearboxMogli:mrGbMUISetMaxTarget( value )
	gearboxMogli.mrGbMUISetXXThrottle( self, value, gearboxMogli.mrGbMSetMaxTarget )
end
function gearboxMogli:mrGbMUIGetMaxTarget( )
	return gearboxMogli.mrGbMUIGetXXThrottle( self, "MaxTarget" )
end

function gearboxMogli:mrGbMUISetMatchGears( value )
	if     value == 2 then
		self:mrGbMSetState( "MatchGears", "end" )
	elseif value == 3 then
		self:mrGbMSetState( "MatchGears", "true" )
	else
		self:mrGbMSetState( "MatchGears", "false" )
	end
end
function gearboxMogli:mrGbMUIGetMatchGears( )
	if     self.mrGbMS.MatchGears == "end"  then
		return 2
	elseif self.mrGbMS.MatchGears == "true" then
		return 3
	end
	return 1
end

function gearboxMogli:mrGbMUISetMatchRanges( value )
	if     value == 2 then
		self:mrGbMSetState( "MatchRanges", "end" )
	elseif value == 3 then
		self:mrGbMSetState( "MatchRanges", "true" )
	else
		self:mrGbMSetState( "MatchRanges", "false" )
	end
end
function gearboxMogli:mrGbMUIGetMatchRanges( )
	if     self.mrGbMS.MatchRanges == "end"  then
		return 2
	elseif self.mrGbMS.MatchRanges == "true" then
		return 3
	end
	return 1
end

function gearboxMogli:mrGbMUISetMinAutoGearSpeed( value )
	if value <= 1 then
		self:mrGbMSetState( "MinAutoGearSpeed", 0 )		
	elseif self.mrGbMUI.AutoGearSpeedID ~= nil and self.mrGbMUI.AutoGearSpeedID[value] ~= nil then
		self:mrGbMSetState( "MinAutoGearSpeed", self.mrGbMUI.AutoGearSpeedID[value]-0.05 )
	end
end
function gearboxMogli:mrGbMUIGetMinAutoGearSpeed( )
	if self.mrGbMS.MinAutoGearSpeed <= self.mrGbMG.minAutoGearSpeed then
		return 1
	end		
	local j = table.getn(self.mrGbMUI.AutoGearSpeedID) 
	for i,v in pairs(self.mrGbMUI.AutoGearSpeedID) do
		if v-0.05 >= self.mrGbMS.MinAutoGearSpeed and j > i then
			j = i
		end
	end
	return j
end
function gearboxMogli:mrGbMUISetMaxAutoGearSpeed( value )
	if value <= 1 then
		self:mrGbMSetState( "MaxAutoGearSpeed", 0 )		
	elseif self.mrGbMUI.AutoGearSpeedID ~= nil and self.mrGbMUI.AutoGearSpeedID[value] ~= nil then
		self:mrGbMSetState( "MaxAutoGearSpeed", self.mrGbMUI.AutoGearSpeedID[value]+0.05 )
	end
end
function gearboxMogli:mrGbMUIGetMaxAutoGearSpeed( )
	if self.mrGbMS.MaxAutoGearSpeed <= self.mrGbMG.minAutoGearSpeed then
		return 1
	end		
	local j = 1
	for i,v in pairs(self.mrGbMUI.AutoGearSpeedID) do
		if v+0.05 <= self.mrGbMS.MaxAutoGearSpeed and j < i then
			j = i
		end
	end
	return j
end

function gearboxMogli:mrGbMUIGetxxxResetxxx( tabName, attrName, checkName )
	if self.mrGbMS.DisableManual then return 1 end
	local i = 1
	for j,g in pairs( self.mrGbMS[tabName] ) do	
		if not g[checkName] then 
			if j == self.mrGbMS[attrName] then 
				return i 
			end
			i = i + 1
		end
	end
	return 1 
end

function gearboxMogli:mrGbMUISetxxxResetxxx( tabName, attrName, checkName, value )
	if self.mrGbMS.DisableManual then return end
	local i = 1
	for j,g in pairs( self.mrGbMS[tabName] ) do	
		if not g[checkName] then 
			if i == value then 
				self:mrGbMSetState( attrName, j )
				break
			end 
			i = i + 1
		end
	end
end

function gearboxMogli:mrGbMUIGetResetFwdGear()
	return gearboxMogli.mrGbMUIGetxxxResetxxx( self, "Gears", "ResetFwdGear", "reverseOnly" )
end 
function gearboxMogli:mrGbMUISetResetFwdGear( value )
	gearboxMogli.mrGbMUISetxxxResetxxx( self, "Gears", "ResetFwdGear", "reverseOnly", value )
end 
function gearboxMogli:mrGbMUIGetResetRevGear()
	return gearboxMogli.mrGbMUIGetxxxResetxxx( self, "Gears", "ResetRevGear", "forwardOnly" )
end 
function gearboxMogli:mrGbMUISetResetRevGear( value )
	gearboxMogli.mrGbMUISetxxxResetxxx( self, "Gears", "ResetRevGear", "forwardOnly", value )
end 
function gearboxMogli:mrGbMUIGetResetFwdRange()
	return gearboxMogli.mrGbMUIGetxxxResetxxx( self, "Ranges", "ResetFwdRange", "reverseOnly" )
end 
function gearboxMogli:mrGbMUISetResetFwdRange( value )
	gearboxMogli.mrGbMUISetxxxResetxxx( self, "Ranges", "ResetFwdRange", "reverseOnly", value )
end 
function gearboxMogli:mrGbMUIGetResetRevRange()
	return gearboxMogli.mrGbMUIGetxxxResetxxx( self, "Ranges", "ResetRevRange", "forwardOnly" )
end 
function gearboxMogli:mrGbMUISetResetRevRange( value )
	gearboxMogli.mrGbMUISetxxxResetxxx( self, "Ranges", "ResetRevRange", "forwardOnly", value )
end 
function gearboxMogli:mrGbMUIGetResetFwdRange2()
	return gearboxMogli.mrGbMUIGetxxxResetxxx( self, "Ranges2", "ResetFwdRange2", "reverseOnly" )
end 
function gearboxMogli:mrGbMUISetResetFwdRange2( value )
	gearboxMogli.mrGbMUISetxxxResetxxx( self, "Ranges2", "ResetFwdRange2", "reverseOnly", value )
end 
function gearboxMogli:mrGbMUIGetResetRevRange2()
	return gearboxMogli.mrGbMUIGetxxxResetxxx( self, "Ranges2", "ResetRevRange2", "forwardOnly" )
end 
function gearboxMogli:mrGbMUISetResetRevRange2( value )
	gearboxMogli.mrGbMUISetxxxResetxxx( self, "Ranges2", "ResetRevRange2", "forwardOnly", value )
end 


if _G[g_currentModName..".gearboxMogliMotor"] == nil then
	source(Utils.getFilename("gearboxMogliMotor.lua", g_currentModDirectory))
end

end