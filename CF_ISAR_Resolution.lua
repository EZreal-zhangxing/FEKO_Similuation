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
-- ISAR main CF script 
-- =============================== --

-- Version and application checks
if cf == nil then
    pf.Form.Critical("Incorrect application","This plugin is for CADFEKO.")
end
--Get App
app = cf.GetApplication()
project = app.Project

--Create Form
local form = cf.Form.New("ISAR Resolution and Range")
local xRange = cf.FormDoubleSpinBox.New("")
local yRange = cf.FormDoubleSpinBox.New("")
local xResolution = cf.FormDoubleSpinBox.New("")
local yResolution = cf.FormDoubleSpinBox.New("")
local frequencyBase = cf.FormDoubleSpinBox.New("")

--Create Groups
local resolutionGroup = cf.FormGroupBox.New("Resolution", cf.Enums.FormLayoutEnum.Grid)
local rangeGroup = cf.FormGroupBox.New("Range", cf.Enums.FormLayoutEnum.Grid)
local frequencyGroup = cf.FormGroupBox.New("Frequency", cf.Enums.FormLayoutEnum.Horizontal)

--Set Max/Min/Default
xResolution.Value = 0.05
xResolution:SetSingleStep(0.01)
yResolution.Value = 0.05
yResolution:SetSingleStep(0.01)
xRange.Value = 3
xRange:SetSingleStep(0.1)
yRange.Value = 3
yRange:SetSingleStep(0.1)
frequencyBase:SetMaximum(10^11) --100 GHz
frequencyBase.Value = 10^10 --10 Ghz

--Populate Groups
resolutionGroup:Add(cf.FormLabel.New("X"), 1, 1)
resolutionGroup:Add(xResolution, 1, 2)

resolutionGroup:Add(cf.FormLabel.New("Y"), 2, 1)
resolutionGroup:Add(yResolution, 2, 2)

rangeGroup:Add(cf.FormLabel.New("X"), 1, 1)
rangeGroup:Add(xRange, 1, 2)
rangeGroup:Add(cf.FormLabel.New("Y"), 2, 1)
rangeGroup:Add(yRange, 2, 2)

frequencyGroup:Add(cf.FormLabel.New("F0"))
frequencyGroup:Add(frequencyBase)

--Design Form
form:Add(resolutionGroup)
form:Add(rangeGroup)
form:Add(frequencyGroup)

--Run Form
assert(form:Run(), "Cancelled")

local xr = xRange.Value
local yr = yRange.Value
local dx = xResolution.Value
local dy = yResolution.Value

local f0 = frequencyBase.Value

local f0n = f0/cf.Const.c0

local nx = 2*math.ceil(xr/(2*dx))+1
local ny = 2*math.ceil(yr/(2*dy))+1


local fxrp = 0.5/dx
local fyrp = 0.5/dy

local fxr = fxrp*(nx-1)/nx
local fyr = fyrp*(ny-1)/ny

local f1n = f0n - fxr/2
local phi1r = math.deg(2 * math.atan2(fyr, 2*f1n))

local f2n = math.sqrt((fxr+f1n)^2 + (fyr/2)^2)

local f2 = f2n*cf.Const.c0
local f1 = f1n*cf.Const.c0

print("\t", "Start\t\t", "End\t", "\tIntervals")
print("Bandwidth", " " .. f1, f2, "\t" .. nx)
print("Angle    ", "-" .. phi1r/2, phi1r/2, "\t" .. ny)

--Get Variables
vf1 = ({pcall(function () return nil,project.Variables["f1"] end)})[3] or project.Variables:Add("f1",0)
vf2 = ({pcall(function () return nil,project.Variables["f2"] end)})[3] or project.Variables:Add("f2",0)
vnf = ({pcall(function () return nil,project.Variables["nf"] end)})[3] or project.Variables:Add("nf",0)
vdf = ({pcall(function () return nil,project.Variables["df"] end)})[3] or project.Variables:Add("df",0)
vRange = ({pcall(function () return nil,project.Variables["range"] end)})[3] or project.Variables:Add("range",0)

vt1 = ({pcall(function () return nil,project.Variables["phi1"] end)})[3] or project.Variables:Add("phi1",0)
vt2 = ({pcall(function () return nil,project.Variables["phi2"] end)})[3] or project.Variables:Add("phi2",0)
-- vnt = ({pcall(function () return nil,project.Variables["nphi"] end)})[3] or project.Variables:Add("nphi",0)
vdt = ({pcall(function () return nil,project.Variables["dphi"] end)})[3] or project.Variables:Add("dphi",0)

vf = ({pcall(function () return nil,project.Variables["f0"] end)})[3] or project.Variables:Add("f0",0)
vrx = ({pcall(function () return nil,project.Variables["xRange"] end)})[3] or project.Variables:Add("xRange",0)
vry = ({pcall(function () return nil,project.Variables["yRange"] end)})[3] or project.Variables:Add("yRange",0)
vdx = ({pcall(function () return nil,project.Variables["xres"] end)})[3] or project.Variables:Add("xres",0)
vdy = ({pcall(function () return nil,project.Variables["yres"] end)})[3] or project.Variables:Add("yres",0)

--Set Variables
vf1.Expression = f1
vf2.Expression = f2
vnf.Expression = nx
vdf.Expression = "(f2-f1)/(nf-1)"
vRange.Expression = "c0/(2*df)"

vt1.Expression = "-" .. phi1r/2
vt2.Expression = phi1r/2
-- vnt.Expression = ny
vdt.Expression = phi1r/(ny-1)

vf.Expression = f0
vrx.Expression = xr
vry.Expression = yr
vdx.Expression = dx
vdy.Expression = dy

--Set Comments
vf1.Description = "Frequency Start"
vf2.Description = "Frequency End"
vnf.Description = "Frequency Samples"
vdf.Description = "Frequency Increment"
vRange.Description = "Unique range window"

vt1.Description = "Angle Start"
vt2.Description = "Angle End"
-- vnt.Description = "Angle Samples"
vdt.Description = "Angle Increment"

vf.Description = "Base Frequency"
vrx.Description = "X Range"
vry.Description = "Y Range"
vdx.Description = "X Resolution"
vdy.Description = "Y Resolution"
