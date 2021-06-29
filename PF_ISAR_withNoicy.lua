--[[
Script exchange is a value added initiative through which customers can
upload or download scripts that help simplify their processes and reduce the effort of repetitive work.

THE SCRIPT exCHANGE IS PROVIDED ON AN "AS-IS" BASIS. USE OF THE SCRIPTS AND
RELIANCE ON ANY
RESULTS DERIVED THEREFROM IS SOLELY AND STRICTLY AT THE USER'S DISCRETION.
ALTAIR MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, exPRESS OR
IMPLIED, AND exPRESSLY
DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE.
ALTAIR DOES NOT WARRANT THE OPERATION, ACCURACY, CORRECTNESS OR
COMPLETENESS OF THE SCRIPTS
OR ANY RESULTS DERIVED THEREFROM.
--]]
-- =============================== --
-- ISAR main PF script 
-- =============================== --

-- Version and application checks
if pf == nil then
    cf.Form.Critical("Incorrect application","This plugin is for POSTFEKO.")
end

require 'utils.math_helper'
require 'utils.FT_helper'
require 'utils.file_helper'
require 'utils.local_maximum_minimum'

--Get Scattering Points from RCS DataSet

--Get App Handle
app = pf.GetApplication()

--Create Form and Items
form  = pf.Form.New("ISAR",pf.Enums.FormLayoutEnum.Grid)
ffSelector = pf.FormDataSelector.New("", pf.Enums.FormDataSelectorType.FarField)
wfSelector = pf.FormComboBox.New("", {"Dirichlet Window", "Hamming Window","Bartlett Window", "Blackman Window"})
iCheckBox = pf.FormCheckBox.New("")
osSelector = pf.FormComboBox.New("", {"Theta", "Phi", "RHC", "LHC"})
zOffset = pf.FormDoubleSpinBox.New("")
upsampleFactor = pf.FormDoubleSpinBox.New("")
display3DView = pf.FormCheckBox.New("")
display3DView.Checked = true
iCheckBox.Checked = true
calcMax = pf.FormCheckBox.New("")
calcMax.Checked = true
maxNum = pf.FormIntegerSpinBox.New("")
writeCSV = pf.FormCheckBox.New("")

--Set Defaults
wfSelector.Index = 2  -- Hamming window
zOffset:SetMinimum(-1)
zOffset:SetMaximum(1)
zOffset.Value = 0.2
upsampleFactor:SetMinimum(1)
upsampleFactor.Value = 1
maxNum.Value = 1
maxNum:SetMinimum(1)

--Add Items to form
form:Add(pf.FormLabel.New("Far field request:"), 1, 1)
form:Add(ffSelector, 1, 2)
form:Add(pf.FormLabel.New("Windowing function"), 2, 1)
form:Add(wfSelector, 2, 2)
form:Add(pf.FormLabel.New("Interpolate to Cartesian grid"), 3, 1)
form:Add(iCheckBox, 3, 2)
form:Add(pf.FormLabel.New("Component"), 4, 1)
form:Add(osSelector, 4, 2)
form:Add(pf.FormLabel.New("Image offset (m)"), 5, 1)
form:Add(zOffset, 5, 2)
form:Add(pf.FormLabel.New("Resampling factor"), 6, 1)
form:Add(upsampleFactor, 6, 2)
form:Add(pf.FormLabel.New("Create 3D view"), 7, 1)
form:Add(display3DView, 7, 2)
form:Add(pf.FormLabel.New("Find local maxima"), 8, 1)
form:Add(calcMax, 8, 2)
form:Add(pf.FormLabel.New("Export local maxima to CSV"), 9, 1)
form:Add(writeCSV, 9, 2)
form:Add(pf.FormLabel.New("Number of maxima"), 10, 1)
form:Add(maxNum, 10, 2)

--Run Form
assert(form:Run(), "Cancelled")


--Get Far Field
ff = ffSelector.Value:GetDataSet()
print(ff)

--Make sure it's RCS data
assert(ff.Quantities[3].Name == "RCSFactor", "Far Field does not contain RCS Data")

--Get Data 

--Get Angles
rForm = pf.Form.New("Angle selection",pf.Enums.FormLayoutEnum.Grid)

-- Assume single fixed theta cut (variation over phi only)
angIndex = 3

--Viewing Angle
local lang0sel = {}
for i = 2, #ff.Axes[angIndex] - 1 do
    lang0sel[i-1] = ff.Axes[angIndex].Values[i]
end
ang0sel = pf.FormComboBox.New("", lang0sel)
ang0sel.Index = math.ceil(#lang0sel/2)
local dphi = ff.Axes[angIndex][2] - ff.Axes[angIndex][1]

rForm:Add(pf.FormLabel.New("Viewing angle:"), 1, 1)

rForm:Add(ang0sel, 1, 2)

assert(rForm:Run(), "Cancelled")

--Viewing Range
local nphi = math.min(ang0sel.Index,#ff.Axes[angIndex]-ang0sel.Index-1)
local lRanges = {}
for i=1,nphi do
    lRanges[i] = i*2*dphi
end
angrsel = pf.FormComboBox.New("", lRanges)
angrsel.Index = #lRanges

rForm = pf.Form.New("Angle selection",pf.Enums.FormLayoutEnum.Grid)
rForm:Add(pf.FormLabel.New("Angle range:"), 1, 1)
rForm:Add(angrsel, 1, 2)

assert(rForm:Run(), "Cancelled")

--Get Data from forms

freqStart = ff.Axes[1][1]
freqEnd = ff.Axes[1][#ff.Axes[1]]
freqSamples = #ff.Axes[1]

ang1Index = ang0sel.Index - angrsel.Index + 1
ang2Index = ang0sel.Index + angrsel.Index + 1

ang1 = ff.Axes[angIndex][ang1Index]
ang2 = ff.Axes[angIndex][ang2Index]
ang0 = tonumber(ang0sel.Value)
print(ang0)
print(angrsel.Index)
angStart = ang1 - ang0
angEnd = ang2 - ang0
angSamples = ang2Index - ang1Index + 1

-- Function to generate valid dataset names from view angle and angular range 
function num2name(num, idp)
    if math.abs(num) < tonumber("1e-"..idp) then num = 0. end
    return string.gsub(string.gsub(string.format("%." .. (idp or 0) .. "f", num),"[.]","p"),"-","m")
end

-- Angle range for dataset name
angrName = num2name(math.abs(ang2-ang1),2)

print("Dataset input:")
print(ff)
--Variables end

--Take into account that FFT's data is periodic thus N samples mean N intervals
f0 = (freqStart + freqEnd)/2
fd = (freqEnd - freqStart)/(freqSamples-1)
fRange = fd * freqSamples

ad = (angEnd - angStart)/(angSamples-1)
angRange = ad * angSamples

--Up Sample to get "smooth" interpolated results
nFreq = math.floor(freqSamples * upsampleFactor.Value + 0.5)
nAng = math.floor(angSamples * upsampleFactor.Value + 0.5)

--Work out deltas
rx = pf.Const.c0/(2*fRange)
ry = pf.Const.c0/(4*f0*math.sin(math.rad(angRange)/2))

--Floored Readings
nFreqf = math.floor(nFreq/2)
nAngf = math.floor(nAng/2)

--Constants
c2pm0_5 = 1/math.sqrt(2)

--Orientation
function ThetaSampler(f, a) 
return ff[f][1][a].EFieldTheta
end
function PhiSampler(f, a) 
return ff[f][1][a].EFieldPhi
end
function RHCSampler(f, a)
return c2pm0_5*(ff[f][1][a].EFieldPhi - j*ff[f][1][a].EFieldTheta)
end
function LHCSampler(f, a) 
return c2pm0_5*(ff[f][1][a].EFieldPhi + j*ff[f][1][a].EFieldTheta) 
end

--Set Sampler Accordingly
if osSelector.Value == "Theta" then Sampler = ThetaSampler
elseif osSelector.Value == "Phi" then Sampler = PhiSampler
elseif osSelector.Value == "RHC" then Sampler = RHCSampler
elseif osSelector.Value == "LHC" then Sampler = LHCSampler end

function SamplerXY(x, y)
    --Get what frequency and angle the given coordinate should be at
    local freq = math.sqrt(x^2 + y^2)
    local ang = math.deg(math.atan2(y, x))
    --print(freq, ang)
    
    --Bilinear Interpolation
    local freqSample = clamp((freq-freqStart)/fRange*freqSamples, 0, freqSamples-1) + 1
    local angSample = clamp((ang-angStart)/angRange*angSamples, 0, angSamples-1) + 1 
         + ang1Index - 1 -- Anglular Offset
    
    local freqSampleL = math.floor(freqSample)
    local freqSampleU = math.ceil(freqSample)
    local freqSampleD = freqSample - freqSampleL
    local angSampleL = math.floor(angSample)
    local angSampleU = math.ceil(angSample)
    local angSampleD = angSample - angSampleL
    
    local ll = freqSampleD * angSampleD
    local ul = (1 - freqSampleD) * angSampleD
    local uu = (1 - freqSampleD) * (1 - angSampleD)
    local lu = freqSampleD * (1 - angSampleD)
    
    return uu*Sampler(freqSampleL, angSampleL) + ul*Sampler(freqSampleL, angSampleU) +
           lu*Sampler(freqSampleU, angSampleL) + ll*Sampler(freqSampleU, angSampleU)
end

--Populate Matrix with 0's
m = pf.ComplexMatrix.New(nFreq, nAng, 0*j)

-- fx is downrange
-- fy is crossrange
fxStart = freqStart
fyStart = math.tan(math.rad(angStart))*fxStart
fyEnd = math.tan(math.rad(angEnd))*fxStart
fxEnd = math.sqrt(freqEnd^2-fyStart^2)

--Sample Density
ysd = (fyEnd - fyStart)/(angSamples-1)
xsd = (fxEnd - fxStart)/(freqSamples-1)

--If Interpolated to Cartesian Grid sample according
if iCheckBox.Checked then
    for f=1,freqSamples do
        for a=1,angSamples do
            m[f][a] = SamplerXY(fxStart + (f-1)*xsd, fyStart + (a-1)*ysd)
        end
    end
--Else sample normally
else
    local f1s = 1
    local f2s = #ff.Axes[1]
    local a1s = ang1Index
    local a2s = ang2Index
    for f=f1s,f2s do
        for a=a1s, a2s do
            m[f - f1s + 1][a - a1s + 1] = Sampler(f, a)
        end
    end
end

--Get Appropriate Window Function
if     wfSelector.Value == "Dirichlet Window" then 
    wf = DirichletWindow
elseif wfSelector.Value == "Hamming Window" then
    wf = HammingWindow
elseif wfSelector.Value == "Bartlett Window" then
    wf = BartlettWindow
elseif wfSelector.Value == "Blackman Window" then
    wf = BlackmanWindow 
end



--Apply Windowing Function to get rid of riples
m = ApplyWindowMatrix(m, wf, freqSamples, angSamples)

--Fourier Transform
mOut =FFT2D(m)/(freqSamples*angSamples)
--Rotate Right
m = RotateRight(mOut, nFreqf, nAngf)

string.split = function(s, p)

    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt

end
local mfile = assert(io.open( "D:\\PyharmWorkspace\\noiceProject\\noisy.txt", "r" ), "Could not create the file for writing. Ensure that you have write access.")
local read_matrix = mfile:read('*a')
local mat_list = string.split(read_matrix, ",")
print(#mat_list)
local index = 1
local complex = require 'utils.complex'
print(freqSamples)
print(angSamples)
c_matrix = pf.ComplexMatrix(freqSamples,angSamples,0*j)
for f=1,freqSamples do
    for a=1,angSamples do
       temp_c = complex(mat_list[index])
       c_matrix[f][a] = temp_c[1]+temp_c[2]*j
       index = index+ 1
    end
end
mfile:close()
--Get Dimensions
m = m + c_matrix
-- m = m


--Change delta r values to that of the padded/interpolated range
if iCheckBox.Checked then
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
ds.Axes:Add("Z","m",zOffset.Value)
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

--Print Info about Our New Dataset
print("Dataset output:")
print(ds)

--Assumed Incident Field Magnitude
--Can be extended to get actual value when the API supports it
magnitude = 1

print("Resolution:\n---------------------------------------------------------")
print("\t", "Xdr\t\t", "Ycr")
print("Base    ", rx, ry)
print("Sampling", (xEnd-xStart)/(nFreq-1), (yEnd - yStart)/(nAng-1))
print("---------------------------------------------------------")
print(string.format("Range: (%f to %f, %f to %f)", xStart, xEnd, yStart, yEnd))

--Populate Dataset
for f=1,nFreq do
    for p = 1,nAng do
        ds[1][f][p][1].ISAR_Field = m[f][p]
        ds[1][f][p][1].ISAR_RCS = 4 * pf.Const.pi * Complex.Abs(m[f][p])^2 / magnitude^2
    end
end

-- local m_matrix_file = assert(io.open( "D:\\PyharmWorkspace\\noiceProject\\nonoicy.txt", "w" ), "Could not create the file for writing. Ensure that you have write access.")
-- for f=1,nFreq do
    --for a=1,nAng do
    --    m_matrix_file:write(tostring(ds[1][f][a][1].ISAR_RCS))
    --    m_matrix_file:write(tostring("\n"))
    -- end
-- end
-- m_matrix_file:close()

--Store Dataset
resdat = ds:StoreData("Custom")
phi0name = num2name(math.deg(phi0),2)
-- print(phi0name)

--Rename Dataset
DatasetName = "ISAR_" .. osSelector.Value .. "_" .. wfSelector.Value:sub(1,wfSelector.Value:find(" ")-1) .. (iCheckBox.Checked and "_P2C" or "").. "_s".. upsampleFactor.Value .. "_v" ..  phi0name.. "_ar" .. angrName
resdat.Label = nextName(DatasetName, app.StoredData)

if display3DView.Checked then
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

if calcMax.Checked then
    print("\nMaxima")
    maxs = localExtrema(MinMaxSampler, 1, nFreq, 1, nAng, nil, 0, 1000000, MinMaxMap)

    for i=1,maxNum.Value do
        if maxs[i] then
            print(string.format("Max %s: Value = %s, Xdr = %s, Ycr = %s", i, maxs[i].value, ds.Axes[2][maxs[i].region[1].x], ds.Axes[3][maxs[i].region[1].y]))
        end
    end
end

filename = resdat.Label .. ".csv"

if writeCSV.Checked then
    assert(calcMax.Checked, "Did not calcualte Maximums. Nothing to write to CSV!")
    
    print("\nWriting to File : " .. filename)
    local file = assert(io.open( filename, "w" ), "Could not create the file for writing. Ensure that you have write access.")
    
    file:write("ISAR")
    -- file:write("\nModel, " .. ffSelector.Value.Configuration.Model.Label .. "." .. ffSelector.Value.Configuration.Label .. "." .. ffSelector.Value.Label)
    file:write("\nComponent, " .. osSelector.Value)
    file:write("\nWindowing function, " .. wfSelector.Value)
    file:write("\nInterpolated, " .. ( iCheckBox.Checked and "Yes" or "No"))
    -- file:write("\nView angle [deg], " .. phi0deg)
    -- file:write("\nAngle range [deg], " .. angrdeg)
    file:write("\n\nMaximums\nIndex, Value, X, Y\n")
    for i=1,maxNum.Value do
        if maxs[i] then
            file:write(string.format("%s, %s, %s, %s\n", i, maxs[i].value, ds.Axes[2][maxs[i].region[1].x], ds.Axes[3][maxs[i].region[1].y]))
        end
    end
    
    file:close()
end
