
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

--Clamp value to range [min_val,max_val]
function clamp(value,min_val,max_val)
    if value < min_val then
        return min_val
    elseif value > max_val then
        return max_val
    else
        return value
    end
 end
 
--Produces number in period [period_start, period_end]
function periodicValue(value, period_start, period_end)
   local period = period_end - period_start + 1
   if value > period_end then
       return value - math.ceil((value-period_end)/period)*period
   elseif value < period_start then
       return value - math.floor((value-period_start)/period)*period
   else
       return value
   end
end

function iterate(cur, dim)
  for i=#dim,1,-1 do
    cur[i]=cur[i]+1
    if(cur[i] > dim[i]) then
      cur[i]=1
    else
      return true
    end
  end

  return false
end

function sign(x)
  return x>0 and 1 or x<0 and -1 or 0
end

--Windowing Functions
function HammingWindow(n,N)
  local alpha = 25/46
  local beta = 1 - alpha
  local scale = 46/25
  return (alpha - beta*math.cos(2 * pf.Const.pi * (n - 1) / (N - 1))) * scale
end

function DirichletWindow(n,N)
  return 1
end

function BartlettWindow(n,N)
  local scale = 2
  return (1 - 2*math.abs((n-1)/(N-1) - 0.5)) * scale
end

function BlackmanWindow(n,N)
  local n = (n - 1 - (N-1)/2)/(N-1)
  local scale = 50/21
  return 0.02 * (21 + 25*math.cos(2*pf.Const.pi*n) + 4*math.cos(4*pf.Const.pi*n)) * scale
end

--Less Common Windows 
function NuttallWindow(n,N)
  n = (n - 1 - (N-1)/2)/(N-1)
  return (88942+121849*math.cos(2*pf.Const.pi*n)+36058*math.cos(4*pf.Const.pi*n) + 3151*math.cos(6*pf.Const.pi*n))/250000
end

function BartlettHannWindow(n,N)
  n = (n - 1 - (N-1)/2)/(N-1)
  return 31/50 + 19/50 * math.cos(2*pf.Const.pi*n) - 12*math.abs(n)/50
end

function BlackmanHarrisWindow(n,N)
  n = (n - 1 - (N-1)/2)/(N-1)
  r = 35875+48829*math.cos(2*pf.Const.pi*n)+14128*math.cos(4*pf.Const.pi*n) + 1168*math.cos(6*pf.Const.pi*n)
  return r/100000
end
--Less Common END

function ApplyWindow(t,f)
  local o = {}
  for i=1,#t do
    o[i] = t[i] * f(i, #t)
  end
  return o
end

function ApplyWindowMatrix(m, f ,Nx, Ny)
  local m0 = m:Transpose():Transpose()
  Nx = Nx or m.RowCount
  Ny = Ny or m.ColumnCount
  for x=1,Nx do
    for y=1,Ny do
      m0[x][y] = m[x][y] * f(x, Nx) * f(y, Ny)
    end
  end
  return m0
end

mine = pf.ComplexMatrix.New(3,3,0*j)

for ii=1,3 do
    for jj=1,3 do
        mine[ii][jj] = ii + j*jj
    end
end
function printMatrix(mout)
 for i=1,135 do
    for j=1,135 do
        print(mout[i][j]..",")
        
    end
    print("\n")
 end
end
--Rotate Function
function RotateLeft(m,nx,ny)
    local nx,ny = periodicValue(nx,1,m.RowCount),periodicValue(ny,1,m.ColumnCount)
    print(string.format("nx is %d ny is %d",nx,ny))
    local mout = m:Transpose():Transpose()
    if nx~=m.RowCount then
        local s1 = m:SubMatrix(1,nx,1,m.ColumnCount)
        print(string.format("s1 rowCount is %d,colum is %d",s1.RowCount,s1.ColumnCount))
        local s2 = m:SubMatrix(nx+1,m.RowCount,1,m.ColumnCount)
        print(string.format("s2 rowCount is %d,colum is %d",s2.RowCount,s2.ColumnCount))
        -- printMatrix(mout)
        mout:ReplaceSubMatrix(s2,1,1)
        -- printMatrix(mout)
        mout:ReplaceSubMatrix(s1,s2.RowCount+1,1)
        -- printMatrix(mout)
    end
    if ny~=m.ColumnCount then
        s1 = mout:SubMatrix(1,m.RowCount,1,ny)
        print(string.format("s1 rowCount is %d,colum is %d",s1.RowCount,s1.ColumnCount))
        s2 = mout:SubMatrix(1,m.RowCount,ny+1,m.ColumnCount)
        print(string.format("s2 rowCount is %d,colum is %d",s2.RowCount,s2.ColumnCount))
        mout:ReplaceSubMatrix(s2,1,1)
        mout:ReplaceSubMatrix(s1,1,s2.ColumnCount+1)
    end
    return mout
end

function RotateRight(m,nx,ny)
    print(string.format("nx is %d ny is %d m.RowCount is %d m.ColumnCount is %d",nx,ny,m.RowCount,m.ColumnCount))
    return RotateLeft(m,m.RowCount-nx, m.ColumnCount-ny)
end

