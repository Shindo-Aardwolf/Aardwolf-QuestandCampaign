Plugin_Dir = "/Shindo_lua"
dofile(GetPluginInstallDirectory()..Plugin_Dir.."/Name_Cleanup.lua")
dofile(GetPluginInstallDirectory()..Plugin_Dir.."/AreasArray.lua")

local Max_Areas = 0
local CP_Mobs_In_Area = 0
local Current_CP_Area_Name = ""
local Current_CP_Room_Name = ""
local Current_CP_Area_Number = 1
local version = "0.1.2"

local ansi = "\27["
local dred = "\27[0;31m"
local dgreen = "\27[0;32m"
local dyellow = "\27[0;33m"
local dblue = "\27[0;34m"
local dmagenta = "\27[0;35m"
local dcyan = "\27[0;36m"
local dwhite = "\27[0;37m"
local bred = "\27[31;1m"
local bgreen = "\27[32;1m"
local byellow = "\27[33;1m"
local bblue = "\27[34;1m"
local bmagenta = "\27[35;1m"
local bcyan = "\27[36;1m"
local bwhite = "\27[37;1m"

--HELPER FUNCTIONS
function tprint (t, indent, done)
	-- show strings differently to distinguish them from numbers
	local function show (val)
		if type (val) == "string" then
			return '"' .. val .. '"'
		else
			return tostring (val)
		end -- if
	end -- show
	if type (t) ~= "table" then
		Note("tprint got " .. type (t))
		return
	end -- not table
	-- entry point here
	done = done or {}
	indent = indent or 0
	for key, value in pairs (t) do
		Note(string.rep (" ", indent)) -- indent it
		if type (value) == "table" and not done [value] then
			done [value] = true
			Note(show (key).. " : \n");
			tprint (value, indent + 2, done)
		else
			Note(show (key).. " = ".. show (value).."\n")
		end
	end
end

function LookUpArea(keyword)
	local AreaData = {}
	AreaData = AreaByLongName[keyword]
	Note(keyword.. " " ..AreaData[1].. " " ..AreaData[2].. " ".. AreaData[3]..
	" "..  AreaData[4].. "\n")
	--  for keyword,areas in pairs(KeywordLookUpTable) do
	--    Note(keyword.. " " ..areas[1].. " " ..areas[2].. " ".. areas[3].. " "..  areas[4].. "\n")
	--  end
	Note("done\n")
end

-- this function returns the uid of the area, for use with the map_goto function
function LookUpAreaUID(keyword)
	local AreaData = AreaByLongName[keyword]
	local uid = tonumber(AreaData[5]) or 0
	return uid
end

-- Quest Related Tables
local QuestInfo = {}
QuestInfo.action = ""
QuestInfo.target = ""
QuestInfo.room = ""
QuestInfo.area = ""
QuestInfo.timer = ""
QuestInfo.wait = ""
QuestInfo.status = ""

-- QUEST RELATED FUNCTIONS
function updateQStatus(newStatus) 
	QuestInfo.action = assert(newStatus.action,"FAILED action")

	if QuestInfo.action == "start" then
		QuestInfo.target = assert(newStatus.targ,"FAILED target")
		QuestInfo.room = assert(newStatus.room,"FAILED room")
		QuestInfo.area = assert(newStatus.area,"FAILED area")
		QuestInfo.timer = assert(newStatus.timer,"FAILED timer")
	elseif QuestInfo.action == "comp" then
		QuestInfo.action = ""
		QuestInfo.target = ""
		QuestInfo.room = ""
		QuestInfo.area = ""
		QuestInfo.timer = ""
		QuestInfo.wait = ""
		QuestInfo.status = ""
	end 
	Note("QUEST status updated.\n") 
end 

function QuestReport()
	if QuestInfo.action == "start" then
		Note("Target is: "..QuestInfo.target.." and they are in a room called "..QuestInfo.room..".\n")
		Note("This is in the area called: "..QuestInfo.area..".\n")
	else
		Note("You are not on a quest.\n")
	end
end

function SetTarget()
	if QuestInfo.action == "start" then
		SendToServer(".TARGET "..stripname(QuestInfo.target))
		local AreaData = {}
		AreaData = AreaByLongName[QuestInfo.area]
		if AreaData[5] == "" then
			SendToServer("rt "..AreaData[1])
			SendToServer(".loadset default")
		else
			SendToServer(".MapperGoto "..tonumber(AreaData[5]))
			SendToServer(".loadset default")
		end
		SendToServer(".MapperPopulateRoomListArea "..AreaData[1].." "..QuestInfo.room)
	else
		SendToServer("echo You are not on a quest.")
		SendToServer(".loadset default")
	end
end

-- CAMPAIGN RELATED FUNCTIONS
local buffer = luajava.newInstance("com.offsetnull.bt.window.TextTree")

local area_exists = {}
local areas = {}
local mobs = {}

local token = GetWindowTokenByName(GetPluginID().."campaign_target_window")

function processTargetCP(name,line,map)
	--Note("\nprocessing line\n")
	local name = map["1"]
	local area = map["2"]
	local dead = false
	if area:find(" - Dead",-7) then
		dead = true
		--zone = zone:sub(1,-7)
	end

	--deal with dead later
	if(not area_exists[area]) then
		table.insert(areas,area)
		area_exists[area] = true
	end

	if(not mobs[area]) then
		mobs[area] = {}
	end
	table.insert(mobs[area],name)

	if PluginSupports("Campaign Tracker", "processTarget") then
		--[[
		PluginSupports("Campaign Tracker", "processTarget", name, line, map)
		Note("Processing Target.\n")
		]]
	end
end

function resetTrackerCP()
	--Note("\nresetting tracker\n")
	areas = {}
	area_exists = {}
	mobs = {}
	if PluginSupports("Campaign Tracker","resetTracker") then
		CallPlugin("Campaign Tracker","resetTracker")
		--[[
		buffer:empty()
		token:setBuffer(buffer)
		--]]
	else
		--Note("Firing the else.\n")
		SendToServer("campaign check")
	end -- PluginSupports
	---[[
	DeleteTriggerGroup("hl_mobs")
	--]]
	EnableTrigger("grabberCP",true)
	EnableTrigger("end1",true)
	EnableTrigger("end2",true)
	EnableTrigger("end3",true)
end

function endCaptureCP(name,line,map)
	EnableTrigger("end1",false)
	EnableTrigger("end2",false)
	EnableTrigger("end3",false)
	EnableTrigger("grabberCP",false)
	--[[
	if PluginSupports("Campaign Tracker", "endCapture") then
	--build the string, add it to the tree and send it off to be drawn
	for i,area in ipairs(areas) do
	--get the mobs and load them up
	buffer:addString(string.format("%s%s%s\n",bwhite,dcyan,area))
	local list = mobs[area]
	for i,mob in ipairs(list) do
	buffer:addString(string.format("%s  %s\n",dgreen,mob))
	end
	end
	token:setBuffer(buffer)
	InvalidateWindowText(token:getName())
	WindowXCallS(token:getName(),"requestLayout","now")
	end -- PluginSupports
	--]]
	--[[
	--create a new trigger with a background highlight mod for each mob in the list.
	local name = "mob_%d"
	local format = string.format
	local count = 1
	for i,area in ipairs(areas) do
	local list = mobs[area]
	for i,mob in ipairs(list) do
	if(mob:find("^a ") or mob:find("^an ") or mob:find("^the ")) then
	mob = mob:gsub("^%l", string.upper)
	end
	NewTrigger(format(name, count),
	mob,
	{regexp=false, group="hl_mobs"},
	{type="color", background=18, foreground=247, fire="always"})
	count = count + 1
	end
	end -- create trigger loop
	--]]
	for i,area in ipairs(areas) do
		Max_Areas = i
		Note(string.format("%s - %s%s%s\n", i, dcyan, area, dwhite))
		local list = mobs[area]
		for j, mob in ipairs(list) do
			Note(string.format("  %.2s - %s%s%s\n", j, dgreen, mob, dwhite))
		end
	end
end

function goto_campaign_area(areanumber)
	local CP_Area = nil
	if string.lower(areanumber) == "first" then
		CP_Area = 1
	elseif string.lower(areanumber) == "last" then
		CP_Area = Max_Areas
	else
		CP_Area = tonumber(areanumber) or 1
	end
	if CP_Area and (CP_Area > 0) and (CP_Area < Max_Areas + 1) then
		Current_CP_Area_Number = CP_Area
		Current_CP_Area_Name = areas[CP_Area]
		Note(string.format("You wish to go to %s%s%s.\n", bwhite, Current_CP_Area_Name, dwhite))
		AreaData = AreaByLongName[Current_CP_Area_Name]
		Note("Target mobs in that area are:\n")
		local list = mobs[areas[CP_Area]]
		for i, mob in ipairs(list) do
			Note(string.format("%s - %s%s%s\n", i, dgreen, mob, dwhite))
			CP_Mobs_In_Area = i
			if i == 1 then SendToServer(".TARGET "..stripname(mob)) end
		end
		if AreaData[5] == "" then
			SendToServer("rt "..AreaData[1])
		else
			SendToServer(".MapperGoto "..tonumber(AreaData[5]))
		end
	elseif CP_Area == nil then
		Note("This function requires a number as input.\n")
	elseif (CP_Area < 1) or (CP_Area > Max_Areas) then
		Note(string.format("Please use a number between 1 and %s.\n", Max_Areas))
	end
end

function goto_campaign_room(areanumber)
	local CP_Area = nil
	if string.lower(areanumber) == "first" then
		CP_Area = 1
	elseif string.lower(areanumber) == "last" then
		CP_Area = Max_Areas
	else
		CP_Area = tonumber(areanumber) or 1
	end
	if CP_Area and (CP_Area > 0) and (CP_Area < Max_Areas + 1) then
		Current_CP_Area_Number = CP_Area
		Current_CP_Room_Name = areas[CP_Area]
		Note(string.format("You wish to find a room called %s%s%s.\n",dcyan, Current_CP_Room_Name, dwhite))
		Note("Target mobs in that room are:\n")
		local list = mobs[areas[CP_Area]]
		for i, mob in ipairs(list) do
			Note(string.format("%s - %s%s%s\n", i, dgreen, mob, dwhite))
			if i == 1 then SendToServer(".TARGET "..stripname(mob)) end
			CP_Mobs_In_Area = i
		end
		SendToServer(string.format(".MapperPopulateRoomList %s",Current_CP_Room_Name))
	elseif CP_Area == nil then
		Note("This function requires a number as input.\n")
	elseif (CP_Area < 1) or (CP_Area > Max_Areas) then
		Note(string.format("Please use a number between 1 and %s.\n", Max_Areas))
	end
end

function set_campaign_area_target(targetnumber)
	local TNumber = tonumber(targetnumber)
	local list = mobs[areas[Current_CP_Area_Number]]
	if TNumber == nil then
		Note("This function requires a number as input.\n")
	elseif (TNumber > 0) and (TNumber < CP_Mobs_In_Area + 1) then
		SendToServer(string.format(".TARGET %s",stripname(list[TNumber],Current_CP_Area_Name)))
		Note(string.format("Setting TARGET to %s%s%s",dgreen, stripname(list[TNumber],Current_CP_Area_Name), dwhite))
		SendToServer(string.format("ht %s",stripname(list[TNumber],Current_CP_Area_Name)))
	elseif (TNumber < 1) or (TNumber > CP_Mobs_In_Area ) then
		Note(string.format("Please use a number between 1 and %s.\n", CP_Mobs_In_Area))
	end
end

RegisterSpecialCommand("QST","SetTarget")
RegisterSpecialCommand("QRep","QuestReport")
RegisterSpecialCommand("UIDLookUp","LookUpAreaUID")
RegisterSpecialCommand("CPGoto","goto_campaign_area")
RegisterSpecialCommand("CPAT","set_campaign_area_target")
RegisterSpecialCommand("CPRGoto","goto_campaign_room")

function OnBackgroundStartup()
	Note(string.format("%sShindo's %sQuest & Campaign helper%s version: %s\n", bgreen, dgreen, dblue, version, dwhite))
	DeleteTriggerGroup("hl_mobs")
	EnableTrigger("end1",false)
	EnableTrigger("end2",false)
	EnableTrigger("end3",false)
	EnableTrigger("grabberCP",false)
end

Note(string.format("%sShindo's %sQuest & Campaign helper%s\n", bgreen, dgreen, dwhite))
