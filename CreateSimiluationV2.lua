require "CalculateAngle"
require 'lfs'
require "MakeForm"
require "math"

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

function calcul_theta(x,y,z)
    distance = math.sqrt(math.pow(x,2)+math.pow(y,2)+math.pow(z,2))
    theta = math.asin(y/distance) / math.pi *180
    if y > 0 then
        return math.abs(theta) + 90
    else
        return 90 - math.abs(theta)
    end
end

function calcul_vector(x,y,z,rotation_x,rotation_y,rotation_z)
    u = {["x"] = 1,["y"] = 0,["z"] = 0}
    v = {["x"] = 0,["y"] = 1,["z"] = 0}
    -- 绕模型x轴转只动模型的V轴的y,z
    v["y"] = math.cos(rotation_x)
    v["z"] = math.sin(rotation_x)
    -- 绕模型z轴转只动模型的u轴的x,z
    u["x"] = math.cos(rotation_z)
    u["z"] = math.sin(rotation_z)
    -- 绕模型y轴转只动模型的phi
    local phi = math.atan(z/x) / math.pi * 180
    local rotation_b = 90 - rotation_y
    local phi_bias = 0
    if (x > 0 and z > 0) then
        phi_bias = (rotation_y + 90 + phi)
    elseif (x < 0 and z > 0) then
        phi_bias = (math.abs(phi) + rotation_b)
    elseif (x < 0 and z < 0) then
        phi_bias = (phi - rotation_b)
    elseif (x > 0 and z < 0) then
        phi_bias = ( 90 - math.abs(phi) + rotation_y)
    else
        if x == 0 then
            if z > 0 then
                phi_bias = 90
            else
                phi_bias = 270
            end
        else
            if x > 0 then
                phi_bias = 0
            else
                phi_bias = 180
            end
        end
    end
    
    return {["U"] = u,["V"] = v,["phi"] = phi_bias}
end

paths = getFileProperty()
targetFile = paths["targetFile"]
savePath = paths["savePath"]
dataPath = paths["dataPath"]
fileName = paths["fileName"]
start_index = tonumber(paths["startIndex"])
end_index = tonumber(paths["endIndex"])
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
-- inspect(project.Variables)
properties = config_source:GetProperties()
-- inspect(properties)
-- properties.StartPhi

-- local file = assert(io.open("D:/FEKO/SoftWare/ISARScripts/log.txt", "r" ), "Could not create the file for writing. Ensure that you have write access.")
local file = assert(io.open(dataPath, "r" ), "Could not create the file for writing. Ensure that you have write access.")
local read_matrix = file:read('*a')
local mat_list = string.split(read_matrix, "\n")

--[[
for f = 1,#mat_list do
    cooperation_info = string.split(mat_list[f],",")
    x=tonumber(cooperation_info[1])
    y=tonumber(cooperation_info[2])
    z=tonumber(cooperation_info[3])
   
    rotation_x=tonumber(cooperation_info[4])
    rotation_y=tonumber(cooperation_info[5])
    rotation_z=tonumber(cooperation_info[6])
    vector = calcul_vector(x,y,z,rotation_x,rotation_y,rotation_z)
    print(vector["phi"])
end
]]--
-- for f=39,39 do
if(tonumber(end_index) == -1) then
    end_index = #mat_list;
end

for f=start_index,end_index do
    cooperation_info = string.split(mat_list[f],",")
    x=tonumber(cooperation_info[1])
    y=tonumber(cooperation_info[2])
    z=tonumber(cooperation_info[3])
   
    rotation_x=tonumber(cooperation_info[4])
    rotation_y=tonumber(cooperation_info[5])
    rotation_z=tonumber(cooperation_info[6])
    
    -- 设置theta角
    theta = calcul_theta(x,y,z)
    properties.EndTheta = theta
    properties.StartTheta = theta
    properties.ThetaIncrement = 10
    -- 设置phi角
   
    vector = calcul_vector(x,y,z,rotation_x,rotation_y,rotation_z)
    
    properties.LocalWorkplane.UVector.X = vector["U"]["x"]
    properties.LocalWorkplane.UVector.Y = vector["U"]["y"]
    properties.LocalWorkplane.UVector.Z = vector["U"]["z"]

    properties.LocalWorkplane.VVector.X = vector["V"]["x"]
    properties.LocalWorkplane.VVector.Y = vector["V"]["y"]
    properties.LocalWorkplane.VVector.Z = vector["V"]["z"]

    properties.EndPhi = project.Variables["phi2"].Value+ vector["phi"]
    properties.StartPhi = project.Variables["phi1"].Value + vector["phi"]
    properties.PhiIncrement = project.Variables["dphi"].Value
    
    properties.EndPhi = "phi2+"..vector["phi"]
    properties.StartPhi = "phi1+"..vector["phi"]
    properties.PhiIncrement = "dphi"
    
    config_source:SetProperties(properties)

    app:Save()
    
    print("-----------Theta--------------") 
    print(config_source.EndTheta)
    print(config_source.StartTheta)
    print(config_source.ThetaIncrement)
    print("------------phi---------------") 
    print(config_source.EndPhi)
    print(config_source.StartPhi)
    print(config_source.PhiIncrement)
    print("------------------------------")
    
    
    -- Mesh the model
    -- project.Mesher:Mesh()

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
