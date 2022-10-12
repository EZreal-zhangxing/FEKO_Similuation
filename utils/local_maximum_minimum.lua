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

--[[
    Calculate local maxima and minama from data sets that takes two parameters to do sampling
--]]

--require 'MathHelper'

--Create Checked Values
local checkedmax = {}
local checkedmin = {}

--Check if it's part of a maximum region
--This function is called by localExtrema
local function localMaximumRegion(sampler, checked, region, i, j, map, param)
    --If the block has already been checked return true
    x, y = map(i, j, param)
    if checked[x][y] then
      return true
    end
    
    --Mark current as checked
    checked[x][y] = true;
    
    --Check if it is a possible maximum region
    local valid = (sampler(map(i,j,param)) >= sampler(map(i+1,j+1, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i+1,j+0, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i+1,j-1, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i+0,j+1, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i+0,j-1, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i-1,j+1, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i-1,j+0, param))) and
                  (sampler(map(i,j,param)) >= sampler(map(i-1,j-1, param)));
    
    --Check adjacent equals to make sure that they are all maximum
    if valid then
        --Add to existing region
        region[#region+1] = {["x"]=x,["y"]=y}
        
        function checkNext(i,j,i2,j2)
          x, y = map(i, j, param)
          if (not checked[x][y] and
             sampler(map(i,j,param)) == sampler(map(i2, j2, param))) then
            return localMaximumRegion(sampler, checked, region, i2, j2, map, param)
          else 
            return true
          end
        end --checkNext
        
        --Check if adjacent regions are valid
        valid = checkNext(i,j,i+1,j+1) and
                checkNext(i,j,i+1,j+0) and
                checkNext(i,j,i+1,j-1) and
                checkNext(i,j,i+0,j+1) and
                checkNext(i,j,i+0,j-1) and
                checkNext(i,j,i-1,j+1) and
                checkNext(i,j,i-1,j+0) and
                checkNext(i,j,i-1,j-1);

        --Fixes possibilaty of incorrectly identifying terraces as max regions
        --TODO this makes create a problem making it O( (xRange * yRange)^2 )!
        --worst case unsolveble withing reasonable amount of time
        --worst case will never happen in real application ! O( xRange * yRange ) is still possible
        if not valid then
          x, y = map(i, j, param)
          checked[x][y] = false
        end
    end --valid
    
    --return wether this is a valid region
    return valid
end --function

--Check if it's part of a minimum region
--This function is called by localExtrema
local function localMinimumRegion(sampler, checked, region, i, j, map, param)
    --If the block has already been checked return true
    x1, y1 = map(i, j, param)
    if checked[x1][y1] then
      return true
    end
    
    --Mark current as checked
    x, y = map(i, j, param)
    checked[x][y] = true;
    
    --Check if it is a possible minimum region
    local valid = (sampler(map(i,j,param)) <= sampler(map(i+1,j+1, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i+1,j+0, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i+1,j-1, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i+0,j+1, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i+0,j-1, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i-1,j+1, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i-1,j+0, param))) and
                  (sampler(map(i,j,param)) <= sampler(map(i-1,j-1, param)));
    
    --Check adjacent equals to make sure that they are all maximum
    if valid then
        --Add to existing region
        x2, y2 = map(i, j, param)
        region[#region+1] = {["x"]=x2,["y"]=y2}
        
        function checkNext(i,j,i2,j2)
          x3, y3 = map(i2,j2,param)
          if(not checked[x3][y3] and 
             sampler(map(i,j,param)) == sampler(map(i2,j2,param))) then
            return localMinimumRegion(sampler, checked, region, i2, j2, map, param)
          else
            return true
          end
        end --checkNext
        
        --Check if adjacent regions are valid
        valid = checkNext(i,j,i+1,j+1) and
                checkNext(i,j,i+1,j+0) and
                checkNext(i,j,i+1,j-1) and
                checkNext(i,j,i+0,j+1) and
                checkNext(i,j,i+0,j-1) and
                checkNext(i,j,i-1,j+1) and
                checkNext(i,j,i-1,j+0) and
                checkNext(i,j,i-1,j-1);
        
        
        --Fixes possibilaty of incorrectly identifying terraces as max regions
        --TODO this makes create a problem making it O( (xRange * yRange)^2 )!
        --worst case unsolveble withing reasonable amount of time
        --worst case will never happen in real application ! O( xRange * yRange ) is still possible
        if not valid then
          x4, y4 = map(i,j,param)
          checked[x4][y4] = false
        end
          
    else
      return false end
    
    --return wether this is a valid region
    return valid
end --function

--Calculate local Maxima and Minima
--Parameters
-- map      - Can probably be removed
-- width    - how many samples are there in width
-- height   - how many samples are there in height
--  sampler - a function that gets the data based on 
--Complexity: O(height*width) * O(sample)
function localExtrema (sampler, xStart, xEnd, yStart, yEnd, param, thresholdMin, thresholdMax, map)
  local maxima = {}
  local minima = {}

  for i=xStart,xEnd do
    checkedmax[i] = {}
    checkedmin[i] = {}
    for j=yStart,yEnd do
      if(sampler(i,j, param) == nil) then
        checkedmax[i][j] = true
        checkedmin[i][j] = true
      else
        checkedmax[i][j] = false
        checkedmin[i][j] = false
      end -- Is valid map
    end --j
  end --i

  --Loop over all values and check
  for i=xStart,xEnd do
    for j=yStart,yEnd do
      if sampler(i,j, param) > thresholdMin and sampler(i,j, param) < thresholdMax then
        i2, j2 = map(i,j,param)
        if not checkedmax[i2][j2] then --Maxima
          local validMaxima = false
          local regionMaxima = {}
        
          --Check if it's going to be maximum
          validMaxima = localMaximumRegion(sampler, checkedmax, regionMaxima, i, j, map, param)
          --If it's valid add it to the list of maxima
          if validMaxima == true then
            maxima[#maxima+1] = {["value"]=sampler(map(i,j,param)), ["region"]=regionMaxima}
          end --valid
        end --Maximum check
        if not checkedmin[i2][j2] then --Minima
          local validMinima = false
          local regionMinima = {}
          
          --Check if it's going to be minimum
          validMinima = localMinimumRegion(sampler, checkedmin, regionMinima, i, j, map, param)
          
          if validMinima then
            minima[#minima+1] = {["value"]=sampler(map(i,j,param)), ["region"]=regionMinima}
          end --valid
        end --Minimum check
      end --Is in range
    end --j
  end --i
  
  --Sort to maxima and minima
  table.sort(maxima, function(a,b) return a.value > b.value end)
  table.sort(minima, function(a,b) return a.value > b.value end)
  
  return maxima,minima
end --function

function ExportFFMinMaxToFile(filename, max, min, ff, freq_start, freq_end, header, num)
  --Open file
  print("Writing to File : " .. filename)
  local file = assert(io.open( filename, "w" ), "Could not create the file for writing. Ensure that you have write access.")
  
  --If not a table of min's and max's
  assert(type(max) ~= "table", "MAX IS NOT A TABLE!")
  assert(type(min) ~= "table", "MIN IS NOT A TABLE!")

  --Get number of max points to display
  local nmax = 1
  local nmin = 1
  
  for i=freq_start,freq_end do
    nmax = math.max(#max[i],nmax)
  end
  
  for i=freq_start,freq_end do
    nmin = math.max(#min[i],nmin)
  end
  
  nmin = math.min(nmin,num)
  nmax = math.min(nmax,num)
  
  file:write(header .."\nMaximum\nFrequency,Maximum 1,,");
  
  for i=2,nmax do
    file:write(string.format(",Maximum %d,,",i)) 
  end
  
  file:write("\n")
  
  for i=1,nmax do
    file:write(",theta, phi, magnitude")
  end
  
  file:write("\n")
  
  for i=freq_start,freq_end do
    file:write(ff.axes[1][i]*1e-9 .. " GHz")
    
    for j=1,nmax do
      if max[i][j] then
        file:write(string.format(",%.3f,%.3f,%.3f",ff.axes[2][max[i][j].region[1].x],ff.axes[3][max[i][j].region[1].y],max[i][j].value))
      end
    end
    
    file:write("\n")
  end
  
    file:write("\nMinimum\nFrequency,Minimum 1,,");
  
  for i=2,nmin do
    file:write(string.format(",Minimum %d,,",i)) 
  end
  
  file:write("\n")
  
  for i=1,nmax do
    file:write(",theta, phi, magnitude")
  end
  
   file:write("\n")
  
  for i=freq_start,freq_end do
    file:write(ff.axes[1][i]*1e-9 .. " GHz")
    
    for j=1,nmin do
      if min[i][j] then
        file:write(string.format(",%.3f,%.3f,%.3f",ff.axes[2][min[i][j].region[1].x],ff.axes[3][min[i][j].region[1].y],min[i][j].value))
      end
    end
    
    file:write("\n")
  end
  
  file:close()
  return true
end

function ExportNFMinMaxToFile(filename, max, min, nf, freq_start, freq_end, header, axis_f, axis1, axis2, const_start, const_end, num)
  --Open file
  print("Writing to File : " .. filename)
  local file = assert(io.open( filename, "w" ), "Could not create the file for writing. Ensure that you have write access.")
  
  --If not a table of min's and max's
  if(type(max) ~= "table") then
    assert(false, "MAX IS NOT A TABLE!")
  end
  
  if(type(min) ~= "table") then
    assert(false, "MIN IS NOT A TABLE!")
  end
  
  file:write(header .."\nMaximum\n")
  for c=const_start,const_end do
  
      --Get number of max points to display
      local nmax = 1
      
      for i=freq_start,freq_end do
        nmax = math.max(#max[i][c],nmax)
      end
      
      nmax = math.min(nmax,num)
      
      file:write(axis_f .. "-Plane : " .. nf.axes[axis_f][c] .. ",")
      file:write("\nFrequency,Maximum 1,,");
      
      for i=2,nmax do
        file:write(string.format(",Maximum %d,,",i)) 
      end
      
      file:write("\n")
      
      for i=1,nmax do
        local a1 = axis1==2 and "X" or "Y"
        local a2 = axis2==3 and "Y" or "Z"
        file:write("," .. a1 .. "," .. a2 ..", magnitude")
      end
      
      file:write("\n")
      
      for i=freq_start,freq_end do
        file:write(nf.axes[1][i]*1e-9 .. " GHz")
        
        for j=1,nmax do
          if max[i][c][j] then
            file:write(string.format(",%.3f,%.3f,%.3f",nf.axes[axis1][max[i][c][j].region[1].x],nf.axes[axis2][max[i][c][j].region[1].y],max[i][c][j].value))
          end
        end
        
        file:write("\n")
      end
  end
  
  file:write("\nMinimum\n")
  for c=const_start,const_end do
  
      --Get number of max points to display
      local nmin = 1
      
      for i=freq_start,freq_end do
        nmin = math.max(#min[i][c],nmin)
      end
      
      nmin = math.min(nmin,num)
      
      file:write(axis_f .. "-Plane : " .. nf.axes[axis_f][c] .. ",")
      file:write("\nFrequency,Minimum 1,,");
      
      for i=2,nmin do
        file:write(string.format(",Minimum %d,,",i)) 
      end
      
      file:write("\n")
      
      for i=1,nmin do
        local a1 = axis1==2 and "X" or "Y"
        local a2 = axis2==3 and "Y" or "Z"
        file:write("," .. a1 .. "," .. a2 ..", magnitude")
      end
      
      file:write("\n")
      
      for i=freq_start,freq_end do
        file:write(nf.axes[1][i]*1e-9 .. " GHz")
        
        for j=1,nmin do
          if min[i][c][j] then
            file:write(string.format(",%.3f,%.3f,%.3f",nf.axes[axis1][min[i][c][j].region[1].x],nf.axes[axis2][min[i][c][j].region[1].y],min[i][c][j].value))
          end
        end
        
        file:write("\n")
      end
  end
  
  file:close()
  return true
end

function ExportFFMinMaxToDataSet(max, min, ff, freq_start, freq_end)
  local mindata = pf.DataSet.New()
  local maxdata = pf.DataSet.New()
  
  mindata.Axes:Add(pf.Enums.DataSetAxisEnum.Frequency, "GHz", ff.axes[1][freq_start]*1e-9, ff.axes[1][freq_end]*1e-9, freq_end - freq_start + 1)
  mindata.Axes:Add(pf.Enums.DataSetAxisEnum.Index, "", 1,5,5)
  
  mindata.Quantities:Add("Magnitude", pf.Enums.DataSetQuantityTypeEnum.Scalar, unit)
  mindata.Quantities:Add("Phi", pf.Enums.DataSetQuantityTypeEnum.Scalar, "deg")
  mindata.Quantities:Add("Theta", pf.Enums.DataSetQuantityTypeEnum.Scalar, "deg")
  
  maxdata.Axes:Add(pf.Enums.DataSetAxisEnum.Frequency, "GHz", ff.axes[1][freq_start]*1e-9, ff.axes[1][freq_end]*1e-9, freq_end - freq_start + 1)
  maxdata.Axes:Add(pf.Enums.DataSetAxisEnum.Index, "", 1,5,5)
  
  maxdata.Quantities:Add("Magnitude", pf.Enums.DataSetQuantityTypeEnum.Scalar, unit)
  maxdata.Quantities:Add("Phi", pf.Enums.DataSetQuantityTypeEnum.Scalar, "deg")
  maxdata.Quantities:Add("Theta", pf.Enums.DataSetQuantityTypeEnum.Scalar, "deg")
  
  for i=freq_start,#maxdata.axes[1]+freq_start-1 do
    local last = 0
    local index = i - freq_start + 1
    for j=1,#maxdata.axes[2] do
      if max[i][j] then
        maxdata[index][j].Magnitude  = max[i][j].value
        maxdata[index][j].Phi   = ff.axes[3][max[i][j].region[1].y]
        maxdata[index][j].Theta = ff.axes[2][max[i][j].region[1].x]
      else
        maxdata[index][j].Magnitude  = nil
        maxdata[index][j].Phi   = nil
        maxdata[index][j].Theta = nil
      end
    end
  end
  
  for i=freq_start,#mindata.axes[1]+freq_start-1 do
    local last = 0
    local index = i - freq_start + 1
    for j=1,#mindata.axes[2] do
      if min[i][j] then
        last = min[i][j]
        mindata[index][j].Magnitude  = min[i][j].value
        mindata[index][j].Phi   = ff.axes[3][min[i][j].region[1].y]
        mindata[index][j].Theta = ff.axes[2][min[i][j].region[1].x]
      else
        mindata[index][j].Magnitude  = nil
        mindata[index][j].Phi   = nil
        mindata[index][j].Theta = nil
      end
    end
  end
  
  return maxdata, mindata
end

function ExportNFMinMaxToDataSet(max, min, nf, freq_start, freq_end, const, const_start, const_end,const_axis, unit)
  local mindata = pf.DataSet.New()
  local maxdata = pf.DataSet.New()
  
  --MinData
  mindata.Axes:Add(pf.Enums.DataSetAxisEnum.Frequency, "GHz", nf.axes[1][freq_start]*1e-9, nf.axes[1][freq_end]*1e-9, freq_end - freq_start + 1)
  mindata.Axes:Add(const, "m", nf.axes[const_axis][const_start],nf.axes[const_axis][const_end],const_end - const_start + 1)
  mindata.Axes:Add(pf.Enums.DataSetAxisEnum.Index, "", 1, 5, 5)
  
  mindata.Quantities:Add("Magnitude", pf.Enums.DataSetQuantityTypeEnum.Scalar, unit)
  if const ~= "X" then mindata.Quantities:Add("X", pf.Enums.DataSetQuantityTypeEnum.Scalar, "m") end
  if const ~= "Y" then mindata.Quantities:Add("Y", pf.Enums.DataSetQuantityTypeEnum.Scalar, "m") end
  if const ~= "Z" then mindata.Quantities:Add("Z", pf.Enums.DataSetQuantityTypeEnum.Scalar, "m") end
  
  --MaxData
  maxdata.Axes:Add(pf.Enums.DataSetAxisEnum.Frequency, "GHz", nf.axes[1][freq_start]*1e-9, nf.axes[1][freq_end]*1e-9, freq_end - freq_start + 1)
  maxdata.Axes:Add(const, "m", nf.axes[const_axis][const_start],nf.axes[const_axis][const_end],const_end - const_start + 1)
  maxdata.Axes:Add(pf.Enums.DataSetAxisEnum.Index, "", 1, 5, 5)
  
  maxdata.Quantities:Add("Magnitude", pf.Enums.DataSetQuantityTypeEnum.Scalar, unit)
  if const ~= "X" then maxdata.Quantities:Add("X", pf.Enums.DataSetQuantityTypeEnum.Scalar, "m") end
  if const ~= "Y" then maxdata.Quantities:Add("Y", pf.Enums.DataSetQuantityTypeEnum.Scalar, "m") end
  if const ~= "Z" then maxdata.Quantities:Add("Z", pf.Enums.DataSetQuantityTypeEnum.Scalar, "m") end
  
  for i=freq_start,freq_end do
    local iindex = i - freq_start + 1
    for c=const_start,const_end do
      local cindex = c - const_start + 1
      for j=1,#maxdata.axes[3] do
        if max[i][c][j] then
          maxdata[iindex][cindex][j].Magnitude = max[i][c][j].value
          if const == "X" then
            maxdata[iindex][cindex][j].Y = nf.axes[3][max[i][c][j].region[1].x]
            maxdata[iindex][cindex][j].Z = nf.axes[4][max[i][c][j].region[1].y]
          elseif const == "Y" then
            maxdata[iindex][cindex][j].X = nf.axes[2][max[i][c][j].region[1].x]
            maxdata[iindex][cindex][j].Z = nf.axes[4][max[i][c][j].region[1].y]
          elseif const == "Z" then
            maxdata[iindex][cindex][j].X = nf.axes[2][max[i][c][j].region[1].x]
            maxdata[iindex][cindex][j].Y = nf.axes[3][max[i][c][j].region[1].y]
          else assert(false, "BAD const field") end
        else
          mindata[iindex][cindex][j].Magnitude = nil
          if const ~= "X" then maxdata[iindex][cindex][j].X = nil end
          if const ~= "Y" then maxdata[iindex][cindex][j].Y = nil end
          if const ~= "Z" then maxdata[iindex][cindex][j].Z = nil end
        end
      end
    end
  end
  
  for i=freq_start,freq_end do
    local iindex = i - freq_start + 1
    for c=const_start,const_end do
      local cindex = c - const_start + 1
      for j=1,#mindata.axes[3] do
        if min[i][c][j] then
          mindata[iindex][cindex][j].Magnitude = min[i][c][j].value
          if const == "X" then
            mindata[iindex][cindex][j].Y = nf.axes[3][min[i][c][j].region[1].x]
            mindata[iindex][cindex][j].Z = nf.axes[4][min[i][c][j].region[1].y]
          elseif const == "Y" then
            mindata[iindex][cindex][j].X = nf.axes[2][min[i][c][j].region[1].x]
            mindata[iindex][cindex][j].Z = nf.axes[4][min[i][c][j].region[1].y]
          elseif const == "Z" then
            mindata[iindex][cindex][j].X = nf.axes[2][min[i][c][j].region[1].x]
            mindata[iindex][cindex][j].Y = nf.axes[3][min[i][c][j].region[1].y]
          else assert(false, "BAD const field") end
        else
          mindata[iindex][cindex][j].Magnitude = nil
          if const ~= "X" then mindata[iindex][cindex][j].X = nil end
          if const ~= "Y" then mindata[iindex][cindex][j].Y = nil end
          if const ~= "Z" then mindata[iindex][cindex][j].Z = nil end
        end
      end
    end
  end
  
  return maxdata, mindata
end
