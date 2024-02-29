--[[

local data = {
	["globalDataStore0"] = {
		["value0"] = 2;
		["value1"] = "a";
		["value2"] = true;
		["value3"] = {};
	};
}

	PLAYER
		|
		|--> datas
				|
				|--> customDatas
				|			|
				|			|--> GDS0
				|			|		|
				|			|		|-> Values
				|			|
				|			|--> GDS1
				|					|
				|					|-> Values
				|
				|--> metaData
							|
							|--> playTime => int
							|
							|--> lastLogin => int - unixEpoch
							|
							|--> firstTimePlay => bool

]]

local __main__ = {
	DONTSAVE = false;
	LOCK = false;
}

--// Services
local datastoreService = game:GetService("DataStoreService")

--// Local Functions
local function typeToInstance(val:any)
	if type(val) == "string" then return "StringValue" end
	if type(val) == "number" then return "NumberValue" end
	if type(val) == "boolean" then return "BoolValue" end
	if type(val) == "table" then return "Folder" end
	return "nil"
end

local function createInstances(table0:{}, parent)
	for i, v in pairs(table0) do
		if typeToInstance(v) ~= "Folder" then
			local val = Instance.new(typeToInstance(v), parent); val.Name = i;
			val.Value = v;
		else
			local _0 = Instance.new("Folder", parent); _0.Name = i;
			createInstances(v, _0)
		end
	end
end

local function assignValues(table0:{}, folder:Folder)
	for i, v in pairs(table0) do
		if type(v) == "table" then
			assignValues(v, folder:FindFirstChild(i))
		else
			folder:FindFirstChild(i).Value = v
		end
	end
end

local function compileValues(folder:Folder)
	local compiled = {}
	
	for i, v in pairs(folder:GetChildren()) do
		if v:IsA("Folder") then
			compiled[v.Name] = compileValues(v);
		else
			compiled[v.Name] = v.Value;
		end
	end
	
	return compiled
end

local function backupSave(gds:GlobalDataStore, key:string, data:{})
	local success, err = pcall(function()
		datastoreService:GetDataStore(gds.Name .. "_"):SetAsync(key, data)
	end)
	
	if success then
		print("datastore || Successfully created backup.")
	elseif err then
		print("datastore || "..err)
	end
end

local function getAsync(gds:GlobalDataStore, key:string, folder:Folder)
	local data = nil
	
	local success, err = pcall(function()
		data = gds:GetAsync(key)
	end)
	
	print(data)
	
	if success then
		if data ~= nil then
			assignValues(data, folder)
			return true, nil
		else
			return false, "No data found in global data store!"
		end
	elseif err then
		__main__.DONTSAVE = true
		getAsync(gds.Name.."_", key, folder)
		return false, err
	end
end

local function setAsync(gds:GlobalDataStore, key:string, folder:Folder)
	local data = compileValues(folder)
	
	print(data)
	
	local success, err = pcall(function()
		gds:SetAsync(key, data)
	end)
	
	if success then
		print("datastore || Successfully saved data for '"..key.."'")
		backupSave(gds, key, data)
	elseif err then
		print("datastore || "..err)
	end
end

--// Lib Functions
__main__.newPlayer = function(plr:Player, data:{})
	local datas = Instance.new("Folder", plr); datas.Name = "datas";
	local customDatas = Instance.new("Folder", datas); customDatas.Name = "customDatas";
	local metaData = Instance.new("Folder", datas); metaData.Name = "metaData";
	
	for i, v in pairs(data) do
		local _0 = Instance.new("Folder", customDatas); _0.Name = i;
		createInstances(v, _0)
		
		local gds = datastoreService:GetDataStore(i)
		local key = tostring(plr.UserId)
		
		local g, c = getAsync(gds, key, _0)
		
		if g and not c then
			print("datastore || Successfully got data and assigned.")
		elseif not g and c then
			if c == "No data found in global data store!" then -- BACKUP DATASTORE?
				print("datastore || No data found in global datastore, using starter values")
			else
				print("datastore || "..c)
			end
		end
	end
end

__main__.playerExit = function(plr:Player)
	for i, v in pairs(plr:WaitForChild("datas"):WaitForChild("customDatas"):GetChildren()) do
		if not v:IsA("Folder") then return end
		
		local gds = datastoreService:GetDataStore(v.Name)
		local key = tostring(plr.UserId)
		
		setAsync(gds, key, v)
	end
end

return __main__