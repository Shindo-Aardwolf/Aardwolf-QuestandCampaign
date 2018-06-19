Plugin_Dir = "/Shindo_lua"
dofile(GetPluginInstallDirectory()..Plugin_Dir.."/Name_Cleanup.lua")
dofile(GetPluginInstallDirectory()..Plugin_Dir.."/AreasArray.lua")

-- Quest Related Tables
local QuestInfo = {}
QuestInfo.action = ""
QuestInfo.target = ""
QuestInfo.room = ""
QuestInfo.area = ""
QuestInfo.timer = ""
QuestInfo.wait = ""
QuestInfo.status = ""

-- Captured and Building info Quest related Tables
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

RegisterSpecialCommand("QST","SetTarget")
RegisterSpecialCommand("QRep","QuestReport")
RegisterSpecialCommand("UIDLookUp"," LookUpAreaUID")

function OnBackgroundStartup()
end

Note("Auto Quest & Campaign helper installed.\n")
