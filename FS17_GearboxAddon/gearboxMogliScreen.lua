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
	if self.vehicle ~= nil then
		for name,s in pairs( self.gearboxMogliElements ) do
			if s.parameter == "list" or s.parameter == "list0" then
				if type( self.vehicle.mrGbMU[name] ) == "table" then
					s.element:setTexts(self.vehicle.mrGbMU[name])
				else
					s.element:setTexts({"<empty>"})
				end
			end
		end
	end
end

function gearboxMogliScreen:update(dt)
	if self.vehicle ~= nil then
		for name,s in pairs( self.gearboxMogliElements ) do
			if s.parameter == "callback" then
				local getter = gearboxMogli["mrGbMUIDraw"..name]
				local texts  = getter( self.vehicle )
				s.element:setTexts(texts)
			end
		end
	end
end

function gearboxMogliScreen:onOpen()
	g_currentMission.isPlayerFrozen = true
	if self.vehicle == nil then
		print("Error: vehicle is empty")
	else
		for name,s in pairs( self.gearboxMogliElements ) do
			local element = s.element
			
			local getter = nil
			if type( gearboxMogli["mrGbMUIGet"..name] ) == "function" then
				getter = gearboxMogli["mrGbMUIGet"..name]
			elseif type( gearboxMogli["mrGbMGet"..name] ) == "function" then
				getter = gearboxMogli["mrGbMGet"..name]
			end
			
			if     getter == nil and self.vehicle.mrGbMS[name] == nil then
				print("Invalid UI element ID: "..tostring(name))
			else
				local value
				if getter ~= nil then
					value = getter( self.vehicle )
				else
					value = self.vehicle.mrGbMS[name]
				end
				
			--print("GET: "..tostring(name)..": '"..tostring(value).."'")
				
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
	
	gearboxMogliScreen:superClass().onOpen(self)
end

function gearboxMogliScreen:onClickOk()
	if self.vehicle == nil then
		print("Error: vehicle is empty")
	else
		for name,s in pairs( self.gearboxMogliElements ) do
			local element = s.element
			
			local setter = nil
			if     type( gearboxMogli["mrGbMUISet"..name] ) == "function" then
				setter = gearboxMogli["mrGbMUISet"..name]
			elseif type( gearboxMogli["mrGbMSet"..name] ) == "function" then
				setter = gearboxMogli["mrGbMSet"..name]
			elseif self.vehicle.mrGbMS[name] ~= nil then
				setter = function( vehicle, value ) gearboxMogli.mbSetState( vehicle, name, value ) end
			end
			
			if setter == nil then
				print("Invalid UI element ID: "..tostring(name))
			else
				if     element:isa( ToggleButtonElement2 ) then
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
			if type( gearboxMogli["mrGbMUIDraw"..element.id] ) == "function" then
				local getter = gearboxMogli["mrGbMUIDraw"..element.id]
				local state, message = pcall( getter, self.vehicle )
				if state then
					element:setTexts(message)
				else
					print("Invalid MultiTextOptionElement callback: mrGbMUIDraw"..tostring(element.id)..", '"..tostring(message).."'")
				end
			else
				print("Invalid MultiTextOptionElement callback: mrGbMUIDraw"..tostring(element.id))
				checked = false
			end
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

