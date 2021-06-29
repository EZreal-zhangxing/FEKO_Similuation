require "CalculateAngle"
require 'lfs'
require "MakeForm"

paths = getFileProperty()
targetFile = paths["targetFile"]
savePath = paths["savePath"]
dataPath = paths["dataPath"]
fileName = paths["fileName"]
print(targetFile)
print(savePath)
print(dataPath)
print(fileName)
app = cf.GetApplication()
project = app:NewProject()

-- project = app:OpenFile([[D:\FEKO\SoftWare\F35\f35.cfx]])
project = app:OpenFile(targetFile)
config_source = project.SolutionConfigurations[1].Sources[1]
-- inspect()
config_source.StartPhi = "phi1"
config_source.EndPhi = "phi2"
config_source.PhiIncrement = "dphi"
config_source.StartTheta = 90
config_source.EndTheta = 90
config_source.ThetaIncrement = 10
properties = config_source:GetProperties()
-- inspect(properties)
-- properties.StartPhi
string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
-- local file = assert(io.open("D:/FEKO/SoftWare/ISARScripts/log.txt", "r" ), "Could not create the file for writing. Ensure that you have write access.")
local file = assert(io.open(dataPath, "r" ), "Could not create the file for writing. Ensure that you have write access.")
local read_matrix = file:read('*a')
local mat_list = string.split(read_matrix, "\n")
-- for f=1,5 do
for f=1,#mat_list-1 do
    anglenow = string.split(mat_list[f],",")
    anglenext = string.split(mat_list[f+1],",")
    U_V = calculateAngleWithCoordation(anglenow[1],anglenow[3],anglenow[2],anglenext[1],anglenext[3],anglenext[2])
    
    properties.LocalWorkplane.UVector.X = U_V["U"]["x"]
    properties.LocalWorkplane.UVector.Y = U_V["U"]["y"]
    properties.LocalWorkplane.UVector.Z = U_V["U"]["z"]

    properties.LocalWorkplane.VVector.X = U_V["V"]["x"]
    properties.LocalWorkplane.VVector.Y = U_V["V"]["y"]
    properties.LocalWorkplane.VVector.Z = U_V["V"]["z"]

    config_source:SetProperties(properties)
    app:Save()
    -- Mesh the model
    project.Mesher:Mesh()

    -- Save project
    -- lfs.mkdir(string.format("D:/FEKO/SoftWare/F35/Data3MakeFile/F35%d",f))
    -- app:SaveAs(string.format("D:/FEKO/SoftWare/F35/Data3MakeFile/F35%d/F35_%d.cfx",f,f))
    lfs.mkdir(savePath.."/"..fileName..string.format("_%d",f))
    app:SaveAs(savePath.."/"..fileName..string.format("_%d",f).."/"..fileName..string.format("_%d.cfx",f))
     -- app:Save()

    -- RunFEKO
    project.Launcher:RunFEKO()

    app:Save()
    -- project.Launcher:RunPOSTFEKO()
end
