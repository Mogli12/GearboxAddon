--***************************************************************
--
-- gearboxMogliScreen
-- 
-- version 2.200 by mogli (biedens)
--
--***************************************************************

local gearboxMogliVersion=2.201

-- allow modders to include this source file together with mogliScreen.lua in their mods
if gearboxMogliScreen == nil or gearboxMogliScreen.version == nil or gearboxMogliScreen.version < gearboxMogliVersion then
	--***************************************************************
	if _G[g_currentModName..".mogliScreen"] == nil then
		source(Utils.getFilename("mogliScreen.lua", g_currentModDirectory))
	end
	_G[g_currentModName..".mogliScreen"].newClass( "gearboxMogliScreen", "gearboxMogli", "mrGbM", "mrGbMUI" )
	--***************************************************************
	
	function gearboxMogliScreen:mogliScreenOnCreate(element)
		self.controlsActionGuiElements = {}
		self.controlsActions = {}
		self:setupControlsList()
		self.settingsControlsHeaderBox:invalidateLayout(true);
	end
	
	function gearboxMogliScreen:mogliScreenOnOpen()
    -- update strings of all input sets
		for _, actionData in pairs(self.controlsActions) do
			SettingsScreen.updateInputStrings(self, actionData);
		end
		
	--if self.lastMouseCursorState then
	--	local mr = FS17_moreRealistic
	--	if moreRealistic ~= nil then
	--		mr = moreRealistic
	--	end
	--	if mr ~= nil and mr.RealisticGui ~= nil and mr.RealisticGui.stopMouse then
	--		self.lastMouseCursorState = false
	--	end
	--end
	end
	
	function gearboxMogliScreen:mogliScreenIsPageDisabled(element)
		return false
	end
	
	function gearboxMogliScreen:mogliScreenGetPageFocus(element)
		if element.name == "ALL" then
			return "11", "35"
		end
		return gearboxMogliScreen.buttonBackFocusId, gearboxMogliScreen.buttonLeftFocusId
	end
	
	function gearboxMogliScreen:setupControlsList()
	
		-- remove first row inside the list which is the xml template
		self.controlsList.elements = {};
		self.controlsList.listItems = {};
		self.controlsActions = {}

		-- load bindings and prepare each list line
		-- the lines itself get filled when the screen is openend
		local controlsDigitalActions, controlsAnalogActions = InputBinding.getBindings(true);
		local listIndex = 0;
		local elements = {}
		for _, actionData in ipairs(controlsDigitalActions) do if string.sub( actionData.name, 1, 12 ) == "gearboxMogli" then
			listIndex = listIndex + 1;
			self.currentActionData = actionData;
			self.currentListIndex = listIndex;
			self.controlsActionGuiElements[actionData.id] = {};
			self.controlsActions[listIndex] = actionData
			local newInputGuiElementSet = self.controlsListTemplate:clone(nil)
			newInputGuiElementSet:invalidateLayout(true);
			--newInputGuiElementSet:updateAbsolutePosition();
			table.insert(elements, newInputGuiElementSet);
		end end;
		for _, actionData in ipairs(controlsAnalogActions) do if string.sub( actionData.name, 1, 12 ) == "gearboxMogli" then
			listIndex = listIndex + 1;
			self.currentActionData = actionData;
			self.currentListIndex = listIndex;
			self.controlsActionGuiElements[actionData.id] = {};
			self.controlsActions[listIndex] = actionData
			local newInputGuiElementSet = self.controlsListTemplate:clone(nil)
			newInputGuiElementSet:invalidateLayout(true);
			--newInputGuiElementSet:updateAbsolutePosition();
			table.insert(elements, newInputGuiElementSet);
		end end;
		self.controlsListTemplate.parent:addElements(elements);
		self.currentActionData = nil;
		self.currentListIndex = nil;

		self.minColumn = gearboxMogliScreen.COLUMN_KEY1;
		self.maxColumn = gearboxMogliScreen.COLUMN_GAMEPAD;
		self.minRow = 1;
		self.maxRow = listIndex;

		self.controlsListSlider:setValue(self.controlsListSlider.maxValue)
	end

	function gearboxMogliScreen:onCreateControlsListTemplate(element)
		element:invalidateLayout(true);
	end	
	function gearboxMogliScreen:onCreateListItem(element)
		if self.currentListIndex ~= nil then
			if self.currentListIndex % 2 ~= 0 then
				element:applyProfile("controlsListItemOdd")
			end
		end;
	end;
	function gearboxMogliScreen:onCreateListItem2(element)
		if self.currentListIndex ~= nil then
			if self.currentListIndex % 2 ~= 0 then
				element:applyProfile("controlsListItem2Odd")
			end
		end;
	end;
	function gearboxMogliScreen:onCreateItem(element,parameter)
		if self.currentActionData ~= nil and parameter ~= nil then
			self.controlsActionGuiElements[self.currentActionData.id][parameter] = element;
		end;
	end;	
end