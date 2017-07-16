gearboxMogliScreen = {}

local gearboxMogliScreen_mt = Class(gearboxMogliScreen, ScreenElement)

function gearboxMogliScreen:new(target, custom_mt)
	if custom_mt == nil then
		custom_mt = gearboxMogliScreen_mt
	end	
	local self = ScreenElement:new(target, custom_mt)
	self.returnScreenName = "";
	self.vehicle = nil
	self.gearboxMogliElements = {}
	return self
end

function gearboxMogliScreen:setVehicle( vehicle )
	self.vehicle       = vehicle 
end

function gearboxMogliScreen:update(dt)
end

function gearboxMogliScreen:onOpen()
	g_currentMission.isPlayerFrozen = true
	if self.vehicle == nil then
		print("Error: vehicle is empty")
	else
		for name,s in pairs( self.gearboxMogliElements ) do
			local element = s.element
			
			local struct = nil 
			local getter = nil
			if type( gearboxMogli["mrGbMGet"..name] ) == "function" then
				getter = gearboxMogli["mrGbMGet"..name]
			elseif self.vehicle.mrGbMS[name] ~= nil then
				struct = self.vehicle.mrGbMS
			else
				struct = self.vehicle
			end
			
			if     getter == nil and struct[name] == nil then
				print("Invalid UI element ID: "..tostring(name))
			else
				local value
				if struct == nil then
					value = getter( self.vehicle )
				else
					value = struct[name]
				end
				
				if     element:isa( ToggleButtonElement2 ) then
					local b = value
					if s.parameter then
						b = not b
					end
					element:setIsChecked( b )
				elseif element:isa( MultiTextOptionElement ) then
					local i = 1
					if     s.parameter == "percent10" then
						i = math.floor( value * 10 + 0.5 )
					elseif s.parameter == "percent5" then
						i = math.floor( value * 20 + 0.5 )
					end
				end			
			end
		end
	end
	
	gearboxMogliScreen:superClass().onOpen(self)
end

function gearboxMogliScreen:onClickOk()
	if self.vehicle == nil then
		print("Error: vehicle is empty")
	else
		for name,s in pairs( self.gearboxMogliElements ) do
			local element = s.element
			
			local struct = nil 
			local setter = nil
			if type( gearboxMogli["mrGbMSet"..name] ) == "function" then
				setter = gearboxMogli["mrGbMSet"..name]
			elseif self.vehicle.mrGbMS[name] ~= nil then
				struct = self.vehicle.mrGbMS
			else
				struct = self.vehicle
			end
			
			if setter == nil and struct[name] == nil then
				print("Invalid UI element ID: "..tostring(name))
			else
				if setter == nil then
					setter = function( vehicle, value ) struct[name] = value end
				end
				
				if     element:isa( ToggleButtonElement2 ) then
					local b = element:getIsChecked()
					if s.parameter then
						b = not b
					end
					setter( self.vehicle, b )
				elseif element:isa( MultiTextOptionElement ) then
					local i = element:getState()
					if     s.parameter == "percent10" then
						setter( self.vehicle, i / 10 )
					elseif s.parameter == "percent5" then
						setter( self.vehicle, i / 20 )
					end			
				end
			end
		end
	end
	
	self:onClickBack()
end

function gearboxMogliScreen:onClose()
	g_currentMission.isPlayerFrozen = false
	self.vehicle = nil
	gearboxMogliScreen:superClass().onClose(self);
end

function gearboxMogliScreen:onCreateSubElement( element, parameter )
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
		if     parameter == nil then
			print("Invalid MultiTextOptionElement parameter: <nil>")
			checked = false
		elseif parameter == "percent10" then
			local texts = {}
			for i=1,10 do
				table.insert( texts, string.format("%d%%",i*10) )
			end
			element:setTexts(texts)
		elseif parameter == "percent5" then
			local texts = {}
			for i=1,20 do
				table.insert( texts, string.format("%d%%",i*5) )
			end
			element:setTexts(texts)
		else
			print("Invalid MultiTextOptionElement parameter: "..tostring(parameter))
			checked = false
		end
	end
	if checked then
		self.gearboxMogliElements[element.id] = { element=element, parameter=parameter }
	else	
		print("Error inserting UI element with ID: "..tostring(element.id))
	end
end

