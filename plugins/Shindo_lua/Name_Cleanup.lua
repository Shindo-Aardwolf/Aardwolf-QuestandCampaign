function stripname(nametostrip, CurrentZone)
  --dirty_string = dirty_string:gsub("", "")

  local dirty_string = nametostrip

  --example of using CurrentZone to change a string
  if CurrentZone =="Takeda's Warcamp" then
    dirty_string = dirty_string:gsub("a proud archer", "archer")
  end
  --common words that need to be removed from names
  dirty_string = dirty_string:gsub("^[aA] ", "")
  dirty_string = dirty_string:gsub("^[Aa]n ", "")
  dirty_string = dirty_string:gsub("^[Tt]he ", "")
  dirty_string = dirty_string:gsub("[Ff]rom ", "")
  dirty_string = dirty_string:gsub(" on ", " ")
  dirty_string = dirty_string:gsub(" in ", " ")
  dirty_string = dirty_string:gsub(" a ", " ")
  dirty_string = dirty_string:gsub(" an ", " ")
  dirty_string = dirty_string:gsub(" with ", " ")
  dirty_string = dirty_string:gsub(" and ", " ")
  dirty_string = dirty_string:gsub(" of ", " ")
  dirty_string = dirty_string:gsub(" [Tt]he ", " ")
  dirty_string = dirty_string:gsub("'s ", " ")
  dirty_string = dirty_string:gsub(", ", " ")
  dirty_string = dirty_string:gsub("%?%?%?%!%!%!", "")
  dirty_string = dirty_string:gsub("%?%?%!%!", "")
  dirty_string = dirty_string:gsub("%. ", " ")
  local CleanTarget = dirty_string
  return CleanTarget
end
