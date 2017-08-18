--***************************************************************
--
-- gearboxMogliScreen
-- 
-- version 2.200 by mogli (biedens)
--
--***************************************************************

local gearboxMogliVersion=2.200

-- allow modders to include this source file together with mogliScreen.lua in their mods
if gearboxMogliScreen == nil or gearboxMogliScreen.version == nil or gearboxMogliScreen.version < gearboxMogliVersion then
	--***************************************************************
	if _G[g_currentModName..".mogliScreen"] == nil then
		source(Utils.getFilename("mogliScreen.lua", g_currentModDirectory))
	end
	_G[g_currentModName..".mogliScreen"].newClass( "gearboxMogliScreen", "gearboxMogli", "mrGbM", "mrGbMUI" )
	--***************************************************************
end

