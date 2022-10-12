--[[
Script Exchange is a value added initiative through which customers can
upload or download scripts that help simplify their processes and reduce the effort of repetitive work.

THE SCRIPT EXCHANGE IS PROVIDED ON AN "AS-IS" BASIS. USE OF THE SCRIPTS AND
RELIANCE ON ANY
RESULTS DERIVED THEREFROM IS SOLELY AND STRICTLY AT THE USER'S DISCRETION.
ALTAIR MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR
IMPLIED, AND EXPRESSLY
DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE.
ALTAIR DOES NOT WARRANT THE OPERATION, ACCURACY, CORRECTNESS OR
COMPLETENESS OF THE SCRIPTS
OR ANY RESULTS DERIVED THEREFROM.
--]]
--Get Next Name
function nextName(name, values)
  local len = name:len()
  local results = {}
  for i=1,#values do
    local tmpLabel = tostring(values[i])
    if tmpLabel:sub(1,len) == name then
      local num = tonumber(tmpLabel:sub(len+1))
      if tmpLabel:len() == len then
        results[1] = true
      elseif num ~= nil then
        results[num] = true
      end
    end
  end

  local count = 0
  for k,v in ipairs(results) do count = k end

  if #results > 0 then
    name = name .. (count + 1)
  end

  return name
end
