require 'lfs'

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
function getFileProperty()
app = cf.GetApplication()
form  = cf.Form.New("ISAR",cf.Enums.FormLayoutEnum.Grid)
targetPath = cf.FormFileBrowser.New("")
savePath = cf.FormDirectoryBrowser.New("")
FileName = cf.FormLineEdit.New("")

form:Add(cf.FormLabel.New("请选取要仿真的文件(*.cfx):"), 1, 1)
form:Add(targetPath, 1, 2)

form:Add(cf.FormLabel.New("保存的文件夹:"), 2, 1)
form:Add(savePath, 2, 2)

assert(form:Run(), "Cancelled")
-- print(targetPath.Value[1])
-- print(savePath.Value)
-- print(dataPath.Value[1])
-- print(FileName.Value)
fileNames = string.split(targetPath.Value[1],".")
assert(fileNames[2] == "cfx","file must be a cfx file!")
assert(savePath.Value ~= nil,"savePath can not be nil!")

return {["targetFile"] = targetPath.Value[1],["savePath"] = savePath.Value}
end

paths = getFileProperty()

targetFile = paths["targetFile"]
savePath = paths["savePath"]
print(targetFile)
print(savePath)
file_names = string.split(targetFile,"/")
fileName = file_names[#file_names]
fileName = string.split(fileName,".")[1]

app = cf.GetApplication()
project = app:NewProject()
-- project = app:OpenFile([[D:\FEKO\SoftWare\F35\f35.cfx]])
project = app:OpenFile(targetFile)
config_source = project.SolutionConfigurations[1].Sources[1]
for f=1,5 do
    theta = 110 + (f-1)*10
    config_source.StartPhi = -160
    config_source.EndPhi = 160
    config_source.PhiIncrement = 1
   
    config_source.EndTheta = tonumber(theta)
    config_source.StartTheta = tonumber(theta)
    print(config_source.StartTheta)
    print(config_source.EndTheta)
    config_source.ThetaIncrement = 10
    app:Save()
    -- Mesh the model
    -- project.Mesher:Mesh()

    -- Save project
    -- lfs.mkdir(string.format("D:/FEKO/SoftWare/F35/Data2MakeFile/F35%d",f))
    -- app:SaveAs(string.format("D:/FEKO/SoftWare/F35/Data2MakeFile/F35%d/F35_%d.cfx",f,f))
    lfs.mkdir(savePath.."/"..fileName..string.format("_%d",theta))
    app:SaveAs(savePath.."/"..fileName..string.format("_%d",theta).."/"..fileName..string.format("_%d.cfx",f))
     -- app:Save()

    -- RunFEKO
    project.Launcher:RunFEKO()

    app:Save()
    -- project.Launcher:RunPOSTFEKO()
end
