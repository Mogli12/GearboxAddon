--
-- mogliBasics
-- This is the specialization for mogliBasics
--
-- change log
-- 1.00 initial version

-- Usage:  source(Utils.getFilename("mogliScreen.lua", g_currentModDirectory));
--         _G[g_currentModDirectory.."mogliScreen"].newClass( "AutoCombine", "acParameters" )

local mogliScreenVersion   = 1.00
local mogliScreenClass     = g_currentModName..".mogliScreen"

if _G[mogliScreenClass] ~= nil and _G[mogliScreenClass].version ~= nil and _G[mogliScreenClass].version >= mogliScreenVersion then
	print("Factory class "..tostring(mogliScreenClass).." already exists in version "..tostring(_G[mogliScreenClass].version))
else
	local mogliScreen10 = {}

	mogliScreen10.version = mogliScreenVersion
		
--=======================================================================================
-- mogliScreen10.newclass
--=======================================================================================
	function mogliScreen10.newClass( _globalClassName_, _refClassName_, _methodPrefix_, _uiPrefix_ )
		if _uiPrefix_     == nil then	_uiPrefix_     = "" end
		if _methodPrefix_ == nil then	_methodPrefix_ = "" end
	
		local _newClass_ = {}
		
		--print("Creating new global class in "..g_currentModDirectory.." with name ".._globalClassName_..". Prefix is: "..tostring(_level0_))

		_newClass_.baseDirectory = g_currentModDirectory
		_newClass_.modsDirectory = g_modsDirectory.."/"
		
		local mogliScreen_mt = Class(_newClass_, ScreenElement)

	--********************************
	-- new
	--********************************
		function _newClass_:new(target, custom_mt)
			if custom_mt == nil then
				custom_mt = mogliScreen_mt
			end	
			local self = ScreenElement:new(target, custom_mt)
			self.returnScreenName = "";
			self.vehicle = nil
			self.mogliScreenElements = {}
			return self
		end

	--********************************
	-- setVehicle
	--********************************
		function _newClass_:setVehicle( vehicle )
			self.vehicle       = vehicle 
			if self.vehicle ~= nil then
				for name,s in pairs( self.mogliScreenElements ) do
					if s.parameter == "list" or s.parameter == "list0" then
						if type( self.vehicle[_uiPrefix_][name] ) == "table" then
							s.element:setTexts(self.vehicle[_uiPrefix_][name])
						else
							s.element:setTexts({"<empty>"})
						end
					end
				end
			end
			if type( _newClass_.postSetVehicle ) == "function" then
				_newClass_.postSetVehicle( self, vehicle )
			end
		end

	--********************************
	-- update
	--********************************
		function _newClass_:update(dt)
			_newClass_:superClass().update(self, dt)
		
			if type( _newClass_.preUpdate ) == "function" then
				_newClass_.postUpdate( self, dt )
			end
			if self.vehicle ~= nil then
				for name,s in pairs( self.mogliScreenElements ) do
					if s.parameter == "callback" then
						local getter = _G[_refClassName_][_uiPrefix_.."Draw"..name]
						local texts  = getter( self.vehicle )
						s.element:setTexts(texts)
					end
				end
			end
			if type( _newClass_.postUpdate ) == "function" then
				_newClass_.postUpdate( self, dt )
			end
		end

	--********************************
	-- onOpen
	--********************************
		function _newClass_:onOpen()
			g_currentMission.isPlayerFrozen = true
			if self.vehicle == nil then
				print("Error: vehicle is empty")
			else
				for name,s in pairs( self.mogliScreenElements ) do
					local element = s.element
					
					local getter = nil					
					local debugPrint = false
					
					if     type( _G[_refClassName_][_uiPrefix_.."Get"..name] ) == "function" then
						if debugPrint then print( _uiPrefix_.."Get"..name ) end
						getter = _G[_refClassName_][_uiPrefix_.."Get"..name]
					elseif type( _G[_refClassName_][_methodPrefix_.."Get"..name] ) == "function" then
						if debugPrint then print( _methodPrefix_.."Get"..name ) end
						getter = _G[_refClassName_][_methodPrefix_.."Get"..name]
					elseif type( _G[_refClassName_].mbGetState ) == "function" then
						if debugPrint then print( 'mbGetState(vehicle, "'..name..'")' ) end
						getter = function( vehicle ) return _G[_refClassName_].mbGetState( vehicle, name ) end
					elseif self.vehicle[name] ~= nil then
						if debugPrint then print( 'self.'..name ) end
						getter = function( vehicle ) return vehicle[name] end
					end		
					
					if     getter == nil then
						print("Invalid UI element ID: "..tostring(name))
					else
						local value = getter( self.vehicle )
						
						if     element:isa( ToggleButtonElement2 ) then
							local b = value
							if s.parameter then
								b = not b
							end
							element:setIsChecked( b )
						elseif element:isa( MultiTextOptionElement ) then
							local i = 1
							if     s.parameter == "percent10" then
								i = math.floor( value * 10 + 0.5 ) + 1
							elseif s.parameter == "percent5" then
								i = math.floor( value * 20 + 0.5 ) + 1
							elseif s.parameter == "list0" then
								i = value + 1
							else
								i = value 
							end
							element:setState( i )
						end
					end
				end
			end
			
			_newClass_:superClass().onOpen(self)
		end

	--********************************
	-- onClickOk
	--********************************
		function _newClass_:onClickOk()
			if self.vehicle == nil then
				print("Error: vehicle is empty")
			else
				for name,s in pairs( self.mogliScreenElements ) do
					local element = s.element
					
					local setter = nil
					if     type( _G[_refClassName_][_uiPrefix_.."Set"..name] ) == "function" then
						setter = _G[_refClassName_][_uiPrefix_.."Set"..name]
					elseif type( _G[_refClassName_][_methodPrefix_.."Set"..name] ) == "function" then
						setter = _G[_refClassName_][_methodPrefix_.."Set"..name]
					elseif type( _G[_refClassName_].mbSetState ) == "function" then
						setter = function( vehicle, value ) _G[_refClassName_].mbSetState( vehicle, name, value ) end
					elseif self.vehicle[name] ~= nil then
						setter = function( vehicle, value ) vehicle[name] = value end
					end
					
					if     setter == nil then
						print("Invalid UI element ID: "..tostring(name))
					elseif element:isa( ToggleButtonElement2 ) then
						local b = element:getIsChecked()
						if s.parameter then
							b = not b
						end
					--print("SET: "..tostring(name)..": '"..tostring(b).."'")
						setter( self.vehicle, b )
					elseif element:isa( MultiTextOptionElement ) then
						local i = element:getState()
						local value = i
						if     s.parameter == "percent10" then
							value = (i-1) * 0.1
						elseif s.parameter == "percent5" then
							value = (i-1) * 0.05
						elseif s.parameter == "list0" then
							value = i - 1
						end
					--print("SET: "..tostring(name)..": '"..tostring(value).."'")
						
						setter( self.vehicle, value )
					end
				end
			end
			
			self:onClickBack()
		end

	--********************************
	-- onClose
	--********************************
		function _newClass_:onClose()
			g_currentMission.isPlayerFrozen = false
			self.vehicle = nil
			_newClass_:superClass().onClose(self);
		end

	--********************************
	-- onCreateSubElement
	--********************************
		function _newClass_:onCreateSubElement( element, parameter )
			local checked = true
			if element.id == nil then
				checked = false
			end
			if     element:isa( ToggleButtonElement2 ) then
				if     parameter == nil then
					parameter = false
				elseif parameter == "inverted" then
					parameter = true
				else
					print("Invalid ToggleButtonElement2 parameter: <nil>")
					checked = false
				end
			elseif element:isa( MultiTextOptionElement ) then
				if parameter == nil then
					print("Invalid MultiTextOptionElement parameter: <nil>")			
					checked = false
				elseif parameter == "list"
						or parameter == "list0" then
					element:setTexts({"vehicle is <nil>"})
				elseif parameter == "percent10" then
					local texts = {}
					for i=0,10 do
						table.insert( texts, string.format("%d%%",i*10) )
					end
					element:setTexts(texts)
				elseif parameter == "percent5" then
					local texts = {}
					for i=0,20 do
						table.insert( texts, string.format("%d%%",i*5) )
					end
					element:setTexts(texts)
				elseif parameter == "callback" then
					if type( _G[_refClassName_][_uiPrefix_.."Draw"..element.id] ) == "function" then
						local getter = _G[_refClassName_][_uiPrefix_.."Draw"..element.id]
						local state, message = pcall( getter, self.vehicle )
						if state then
							element:setTexts(message)
						else
							print("Invalid MultiTextOptionElement callback: ".._uiPrefix_.."Draw"..tostring(element.id)..", '"..tostring(message).."'")
						end
					else
						print("Invalid MultiTextOptionElement callback: ".._uiPrefix_.."Draw"..tostring(element.id))
						checked = false
					end
				else
					print("Invalid MultiTextOptionElement parameter: "..tostring(parameter))
					checked = false
				end
			end
			if checked then
				self.mogliScreenElements[element.id] = { element=element, parameter=parameter }
			else	
				print("Error inserting UI element with ID: "..tostring(element.id))
			end
		end

	--********************************
		_G[_globalClassName_] = _newClass_ 
	--********************************
	end

	--********************************
	_G[mogliScreenClass] = mogliScreen10
	--********************************
		
end