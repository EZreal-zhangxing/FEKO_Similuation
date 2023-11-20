require 'lfs'

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

-- build form to input 
function getFileProperty()
    app = cf.GetApplication()
    form  = cf.Form.New("ISAR",cf.Enums.FormLayoutEnum.Grid)
    targetPath = cf.FormFileBrowser.New("")
    savePath = cf.FormDirectoryBrowser.New("")
    FileName = cf.FormLineEdit.New("")
    view_angle_start = cf.FormLineEdit.New("")
    view_angle_end = cf.FormLineEdit.New("")
    view_angle_inc = cf.FormLineEdit.New("")
  
    theta = cf.FormLineEdit.New("")

    form:Add(cf.FormLabel.New("请选取要仿真的文件(*.cfx):"), 1, 1)
    form:Add(targetPath, 1, 2)
    
    form:Add(cf.FormLabel.New("保存的文件夹:"), 2, 1)
    form:Add(savePath, 2, 2)

    form:Add(cf.FormLabel.New("文件名:"), 3, 1)
    form:Add(FileName, 3, 2)

    form:Add(cf.FormLabel.New("view Angle start:"), 4, 1)
    form:Add(view_angle_start, 4, 2)
    
    form:Add(cf.FormLabel.New("view Angle end:"), 5, 1)
    form:Add(view_angle_end, 5, 2)

    form:Add(cf.FormLabel.New("view Angle increment:"), 6, 1)
    form:Add(view_angle_inc, 6, 2)

    form:Add(cf.FormLabel.New("Theta:"), 7, 1)
    form:Add(theta, 7, 2)

    targetPath.Value = {"D:/FEKO/SoftWare/F22/f22.cfx"}
 
    view_angle_start.Value = "0"
    view_angle_end.Value = "180"
    view_angle_inc.Value = "18"
    theta.Value = "100"
    
    assert(form:Run(), "Cancelled")

    -- print(targetPath.Value[1])
    -- print(savePath.Value)
    -- print(dataPath.Value[1])
    -- print(FileName.Value)
    fileNames = string.split(targetPath.Value[1],".")
    assert(fileNames[2] == "cfx","file must be a cfx file!")

    return {["targetFile"] = targetPath.Value[1],["savePath"] = savePath.Value,["fileName"] = FileName.Value,["view_angle_start"] = tonumber(view_angle_start.Value),["view_angle_end"] = tonumber(view_angle_end.Value),["view_angle_inc"] = tonumber(view_angle_inc.Value),["theta"] = tonumber(theta.Value)}
end

parm = getFileProperty()
view_angle_start = parm["view_angle_start"]
view_angle_end = parm["view_angle_end"]
view_angle_inc = parm["view_angle_inc"]
theta = parm["theta"]
targetFile = parm["targetFile"]
savePath = parm["savePath"]
fileName = parm["fileName"]

app = cf.GetApplication()
project = app:NewProject()
project = app:OpenFile(targetFile)
config_source = project.SolutionConfigurations[1].Sources[1]
properties = config_source:GetProperties()

inspect(project.Variables["c0"].Value)

for f = view_angle_start,view_angle_end,view_angle_inc do
    properties.EndPhi = string.format("phi2+%f",f)
    properties.StartPhi = string.format("phi1+%f",f)
    properties.PhiIncrement = "dphi"
    print(string.format("the phi info [start = %s,end = %s,step = %s]",properties.StartPhi,properties.EndPhi,properties.PhiIncrement))
       
    config_source:SetProperties(properties)
    app:Save()
    
    save_dir = savePath.."/"..fileName..string.format("_%d",f)
    file,error = io.open(save_dir)
    if file == nil then
        lfs.mkdir(save_dir)
    end
    
    app:SaveAs(save_dir.."/"..fileName..string.format("_%d.cfx",f))
    
    -- RunFEKO
    project.Launcher:RunFEKO()

    app:Save()
end