--***************************************************************
mogliBase20.newClass( "GearboxHud" )
--***************************************************************

function GearboxHud:draw()

	if self.mrGbMGetIsOn ~= nil and self:mrGbMGetIsOn() then
		setTextAlignment(RenderText.ALIGN_LEFT) 
		setTextColor(1, 1, 1, 1) 
			
		local text = self:mrGbMGetModeText() 
		text = text .. " / " .. self:mrGbMGetGearText() 
		text = text .. " / " .. string.format("%4.0f U/min", Utils.getNoNil(self.motor.lastMotorRpm,0))
		text = text .. " / " .. string.format("%4.0f PS", Utils.getNoNil(self:mrGbMGetUsedPower(),0))
		
		renderText( 0.37, 0.95, 0.03, text )
	end
end