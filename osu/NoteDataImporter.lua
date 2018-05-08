osu.NoteDataImporter = {}
local NoteDataImporter = osu.NoteDataImporter

osu.NoteDataImporter_metatable = {}
local NoteDataImporter_metatable = osu.NoteDataImporter_metatable
NoteDataImporter_metatable.__index = NoteDataImporter

NoteDataImporter.new = function(self)
	local noteDataImporter = {}
	
	setmetatable(noteDataImporter, NoteDataImporter_metatable)
	
	return noteDataImporter
end

NoteDataImporter.inputType = "key"

NoteDataImporter.init = function(self)
	self.lineTable = self.line:split(",")
	self.additionLineTable = self.lineTable[6]:split(":")
	
	self.x = tonumber(self.lineTable[1])
	self.y = tonumber(self.lineTable[2])
	self.startTime = tonumber(self.lineTable[3])
	self.type = tonumber(self.lineTable[4])
	self.hitSoundBitmap = tonumber(self.lineTable[5])
	if bit.band(self.type, 128) == 128 then
		self.endTime = tonumber(self.additionLineTable[1])
		table.remove(self.additionLineTable, 1)
	end
	self.additionSampleSetId = tonumber(self.additionLineTable[1])
	self.additionAdditionalSampleSetId = tonumber(self.additionLineTable[2])
	self.additionCustomSampleSetIndex = tonumber(self.additionLineTable[3])
	self.additionHitSoundVolume = tonumber(self.additionLineTable[4])
	self.additionCustomHitSound = self.additionLineTable[5]
	
	local keymode = self.noteChartImporter.metaData.CircleSize
	local interval = 512 / keymode
	for currentInputIndex = 1, keymode do
		if self.x >= interval * (currentInputIndex - 1) and self.x < currentInputIndex * interval then
			self.inputIndex = currentInputIndex
			break
		end
	end
end

NoteDataImporter.getNoteData = function(self)
	local startTimePoint = self.noteChartImporter.foregroundLayerData:getTimePoint()
	startTimePoint.absoluteTime = self.startTime / 1000
	startTimePoint.velocityData = self.noteChartImporter.foregroundLayerData.velocityDataSequence:getVelocityDataByTimePoint(startTimePoint)
	
	noteData = ncdk.NoteData:new(startTimePoint)
	noteData.inputType = self.inputType
	noteData.inputIndex = self.inputIndex
	
	noteData.zeroClearVisualStartTime = self.noteChartImporter.foregroundLayerData:getVisualTime(startTimePoint, self.noteChartImporter.foregroundLayerData.zeroTimePoint, true)
	noteData.currentVisualStartTime = noteData.zeroClearVisualStartTime
	
	if not self.endTime then
		noteData.noteType = "ShortNote"
	else
		local endTimePoint = self.noteChartImporter.foregroundLayerData:getTimePoint()
		endTimePoint.absoluteTime = self.endTime / 1000
		endTimePoint.velocityData = self.noteChartImporter.foregroundLayerData.velocityDataSequence:getVelocityDataByTimePoint(endTimePoint)
		
		noteData.endTimePoint = endTimePoint
		
		noteData.zeroClearVisualEndTime = self.noteChartImporter.foregroundLayerData:getVisualTime(endTimePoint, self.noteChartImporter.foregroundLayerData.zeroTimePoint, true)
		noteData.currentVisualEndTime = noteData.zeroClearVisualEndTime
	
		noteData.noteType = "LongNote"
	end
	
	return noteData
end