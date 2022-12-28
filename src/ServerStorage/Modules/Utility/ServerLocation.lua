
local Module = {host = 'NA', longitude=-100}

task.defer(function()
	local HttpService = game:GetService('HttpService')
	local longitude = HttpService:JSONDecode(HttpService:GetAsync('http://ip-api.com/json/')).lon
	Module.longitude = longitude
	if (longitude>-180 and longitude<=-105) then
		Module.host = "US West"
	elseif (longitude>-105 and longitude<=-90) then
		Module.host = "US Central"
	elseif (longitude>-90 and longitude<=0) then
		Module.host = "US East"
	elseif (longitude<=75 and longitude>0) then
		Module.host = "Europe"
	elseif (longitude<=180 and longitude>75) then
		Module.host = "Australia"
	else
		Module.host = "Unknown"
	end
end)

return Module
