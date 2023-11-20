require 'utils.math_helper'
require 'utils.FT_helper'
string.split = function(s, p)

    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

local path = "D:/FEKO/SoftWare/F22_100/F22_100_absorb/ISAR_Theta_Hamming_P2C_s1_v0p31_ar140p03.txt"
local readfile = io.open(path,"r")
local line = readfile:read("*a")
lines = string.split(line,"\n")
local freqSamples = 135
local angSamples = 135
local nFreq=135
local nAng=135
local nFreqf=67
local nAngf=67

f0 = (freqStart + freqEnd)/2
fd = (freqEnd - freqStart)/(freqSamples-1)
fRange = fd * freqSamples

c_matrix = pf.ComplexMatrix(freqSamples,angSamples,0*j)
index = 1
for f=1,freqSamples do
    for a=1,angSamples do
       temp_c = string.split(lines[index]," ")
       c_matrix[f][a] = tonumber(temp_c[1])+tonumber(temp_c[2])*j
       index = index+ 1
    end
end
readfile:close()
wf = HammingWindow
m = ApplyWindowMatrix(c_matrix, wf, freqSamples, angSamples)
mOut =FFT2D(m)/(freqSamples*angSamples)
m = RotateRight(mOut, nFreqf, nAngf)

rx = pf.Const.c0/(2*fRange)
ry = pf.Const.c0/(4*f0*math.sin(math.rad(angRange)/2))
--Change delta r values to that of the padded/interpolated range
if iCheckBox then
    dfx = xsd/pf.Const.c0
    dfy = ysd/pf.Const.c0
    
    dr1c = 1/(2 * nFreq*dfx)
    dr2c = 1/(2 * nAng*dfy)

    xRange = 2 * nFreqf * dr1c
    yRange = 2 * nAngf * dr2c
    
    xStart = -xRange/2
    yStart = -yRange/2

    xEnd = dr1c * (nFreq-1) + xStart
    yEnd = dr2c * (nAng-1)  + yStart
else
    drx = freqSamples/ nFreq * rx
    dry = angSamples/ nAng * ry

    yRange = 2 * nAngf * dry
    xRange = 2* nFreqf * drx

    xStart = -xRange/2
    yStart = -yRange/2

    xEnd = drx * (nFreq-1) + xStart
    yEnd = dry * (nAng-1)  + yStart
    
end

--Create new dataset to return ISAR
ds = pf.DataSet.New()
ds.Axes:Add("frequency", "Hz", f0)
ds.Axes:Add("X", "m", xStart, xEnd, nFreq)
ds.Axes:Add("Y", "m", yStart, yEnd, nAng)
ds.Axes:Add("Z","m",zOffset)
ds.Quantities:Add("ISAR_Field", "complex", "V")
ds.Quantities:Add("ISAR_RCS", "scalar", "m^2")
phi0 = math.rad(ang0)

-- Create 3D rotation matrix to rotate phi0 around n-vector
rotMat = pf.Matrix.New(3,3,0)
cphi = math.cos(phi0)
sphi = math.sin(phi0)
cphi1 = 1 - cphi

-- Create matrix of initial u-vector
u1 = ff.MetaData.UVector[1]
u2 = ff.MetaData.UVector[2]
u3 = ff.MetaData.UVector[3]
uVec = pf.Matrix.New(3,1,0)
uVec[1][1] = u1
uVec[2][1] = u2
uVec[3][1] = u3

-- Create matrix of initial v-vector
v1 = ff.MetaData.VVector[1]
v2 = ff.MetaData.VVector[2]
v3 = ff.MetaData.VVector[3]
vVec = pf.Matrix.New(3,1,0)
vVec[1][1] = v1
vVec[2][1] = v2
vVec[3][1] = v3

-- Cross product to get normal vector to rotate around 
n1 = u2*v3 - u3*v2
n2 = u3*v1 - u1*v3
n3 = u1*v2 - u2*v1

-- Angles for view direction
phiv = ang0 + math.deg(math.atan2(n2, n1))
thtv = math.deg(math.atan2(math.sqrt(n1^2 + n2^2), n3))
-- print(phiv, thtv)

-- Row 1 of rotation matrix
rotMat[1][1] = n1^2*cphi1 + cphi
rotMat[1][2] = n1*n2*cphi1 - n3*sphi
rotMat[1][3] = n1*n3*cphi1 + n2*sphi
-- Row 2 of rotation matrix
rotMat[2][1] = n1*n2*cphi1 + n3*sphi
rotMat[2][2] = n2^2*cphi1 + cphi
rotMat[2][3] = n2*n3*cphi1 - n1*sphi
-- Row 3 of rotation matrix
rotMat[3][1] = n1*n3*cphi1 - n2*sphi
rotMat[3][2] = n2*n3*cphi1 + n1*sphi
rotMat[3][3] = n3^2*cphi1 + cphi

-- Rotated u and v vectors
uvec1 = rotMat*uVec
vvec1 = rotMat*vVec

-- Set U- and V-vector of dataset
ds.MetaData.UVector = pf.Point(uvec1[1][1], uvec1[2][1], uvec1[3][1])
ds.MetaData.VVector = pf.Point(vvec1[1][1], vvec1[2][1], vvec1[3][1])
ds.MetaData.Origin = pf.Point(0,0,0)

--Assumed Incident Field Magnitude
--Can be extended to get actual value when the API supports it
magnitude = 1

-- print("Resolution:\n---------------------------------------------------------")
-- print("\t", "Xdr\t\t", "Ycr")
-- print("Base    ", rx, ry)
-- print("Sampling", (xEnd-xStart)/(nFreq-1), (yEnd - yStart)/(nAng-1))
-- print("---------------------------------------------------------")
-- print(string.format("Range: (%f to %f, %f to %f)", xStart, xEnd, yStart, yEnd))

--Populate Dataset
local test = assert(io.open("D:/FEKO/beforeFFT/record_rot_02_output_image/F22_1_afterFFT_gaussian-15.txt", "w"))
for f=1,nFreq do
    for p = 1,nAng do
        ds[1][f][p][1].ISAR_Field = m[f][p]
        ds[1][f][p][1].ISAR_RCS = 4 * pf.Const.pi * Complex.Abs(m[f][p])^2 / magnitude^2
        test:write(string.format("%s %s",m[f][p].re,m[f][p].im).."\n")
    end
end
test:close()
--Store Dataset
resdat = ds:StoreData("Custom")
phi0name = num2name(math.deg(phi0),2)
-- print(phi0name)

--Rename Dataset
DatasetName = "ISAR_" .. "" .. angrName
resdat.Label = nextName(DatasetName, app.StoredData)

if display3DView then
    if (ffSelector.Value.Configuration ~= nil) then
        view = app.Views:Add(ffSelector.Value.Configuration)
        plot = view.Plots:Add(resdat)
        view.WindowTitle = resdat.Label
        plot.Visualisation.Opacity = 60
        plot.Quantity.ValuesScaledToDB = true
        plot.Quantity.Type = "ISAR_RCS"
        -- view:SetViewDirection(pf.Enums.ViewDirectionEnum.Top)
        view.Format.PhiDirection = phiv
        view.Format.ThetaDirection = thtv
        view:ZoomToExtents()
    else
        print("No configuration associated with the RCS data. Please create 3D view and add stored ISAR data manually")
    end
end

function MinMaxSampler(i, j)
    return ds[1][i][j][1].ISAR_RCS
end

function MinMaxMap(i, j)
    return clamp(i, 1, nFreq), clamp(j, 1, nAng)
end


