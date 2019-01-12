local TimePoint = {}

local TimePoint_metatable = {}
TimePoint_metatable.__index = TimePoint

TimePoint.new = function(self)
	local timePoint = {}
	
	setmetatable(timePoint, TimePoint_metatable)
	
	return timePoint
end

TimePoint.compute = function(self)
	self.absoluteTime = self.timeData:getAbsoluteTime(self.measureTime, self.side)
end

TimePoint.getAbsoluteTime = function(self)
	return self.absoluteTime
end

TimePoint_metatable.__eq = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime == tpb.measureTime and tpa.side == tpb.side
	else
		return tpa.absoluteTime == tpb.absoluteTime and tpa.side == tpb.side
	end
end

TimePoint_metatable.__lt = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime < tpb.measureTime or (tpa.measureTime == tpb.measureTime and tpa.side < tpb.side)
	else
		return tpa.absoluteTime < tpb.absoluteTime or (tpa.absoluteTime == tpb.absoluteTime and tpa.side < tpb.side)
	end
end

TimePoint_metatable.__le = function(tpa, tpb)
	if tpa.measureTime and tpb.measureTime then
		return tpa.measureTime < tpb.measureTime or (tpa.measureTime == tpb.measureTime and tpa.side == tpb.side)
	else
		return tpa.absoluteTime < tpb.absoluteTime or (tpa.absoluteTime == tpb.absoluteTime and tpa.side == tpb.side)
	end
end

return TimePoint
