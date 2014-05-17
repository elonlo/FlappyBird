--AtlasLoader 

AtlasLoader = class("AtlasLoader")
AtlasLoader.__index = AtlasLoader
AtlasLoader._sharedAtlasLoader = nil


function AtlasLoader:ctor()

end

function AtlasLoader:getInstance()
	if AtlasLoader._sharedAtlasLoader == nil then
		AtlasLoader._sharedAtlasLoader = AtlasLoader.new()
		AtlasLoader._sharedAtlasLoader._spriteFrames = {}
	end
	return AtlasLoader._sharedAtlasLoader
end

function AtlasLoader:loadAtlas(filename, texture)
	local data = cc.FileUtils:getInstance():getStringFromFile(filename)
	local pos = string.find(data, "\n")
	local line = string.sub(data, 1, pos-1)
	data = string.sub(data, pos+1)
	while line ~= "" do
		local t = {}
		for k, v in string.gmatch(line, "%S*") do
			if 0 ~= string.len(k) then
				t[#t+1] = k
			end	
		end
		local name = t[1]
		local width = tonumber(t[2])
		local height = tonumber(t[3])
		local start_x = 1024 * tonumber(t[4])
		local start_y = 1024 * tonumber(t[5])
		local end_x = 1024 * tonumber(t[6])
		local end_y = 1024 * tonumber(t[7])
		--bug
		if name == "land" then
			start_x = start_x + 1
		end
		local rect = cc.rect(start_x, start_y, width, height)
		local frame = cc.SpriteFrame:createWithTexture(texture, rect)
		frame:retain()
		self._spriteFrames[name] = frame
		-- cclog(name .. "   frame: " .. tostring(frame))
		
		pos = string.find(data, "\n")
		if nil == pos then
			break
		end
		line = string.sub(data, 1, pos-1)
		data = string.sub(data, pos+1)
	end
end

function AtlasLoader:getSpriteFrameByName(name)
	local frame = self._spriteFrames[name]
	assert(frame ~= nil, "sprite frame with nil")
	return frame
end
