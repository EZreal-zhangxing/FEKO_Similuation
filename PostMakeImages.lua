-- 读取文件夹 并生成图像
app = pf.GetApplication()
require "lfs"
form  = pf.Form.New("ISAR",pf.Enums.FormLayoutEnum.Grid)

makeImagePath = pf.FormDirectoryBrowser.New("")
viewAngle = pf.FormLineEdit.New("")
angleRange = pf.FormLineEdit.New("")
dbMax = pf.FormLineEdit.New("")
dbMin = pf.FormLineEdit.New("")

dbMax.Value = "-10"
dbMin.Value = "-50"
form:Add(pf.FormLabel.New("选择要成像的文件夹:"), 1, 1)
form:Add(makeImagePath, 1, 2)

form:Add(pf.FormLabel.New("View Angle:"), 2, 1)
form:Add(viewAngle, 2, 2)

form:Add(pf.FormLabel.New("Angle Range:"), 3, 1)
form:Add(angleRange, 3, 2)

form:Add(pf.FormLabel.New("Max DB:"), 4, 1)
form:Add(dbMax, 4, 2)

form:Add(pf.FormLabel.New("Min DB:"), 5, 1)
form:Add(dbMin, 5, 2)
assert(form:Run(), "Cancelled")
assert(makeImagePath.Value ~= nil,"directory can not be nil!")

imagePath = makeImagePath.Value

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

for file in lfs.dir(imagePath) do
    if file ~= "." and file ~= ".." then  
        dirnames = string.split(file,"_")
        inspect(dirnames)
        project = app:NewProject()
        app:OpenFile(imagePath.."/"..file.."/"..dirnames[1]..string.format("_%s.cfx",dirnames[2]))
        ff = pf.FormDataSelector.New("",pf.Enums.FormDataSelectorType.FarField)

        require "BuildImage"
        -- print(tonumber(viewAngle.Value))
        -- print(tonumber(angleRange.Value))
        buildImage(ff,ff.Value:GetDataSet(),tonumber(viewAngle.Value),tonumber(angleRange.Value),file)
        graph = app.CartesianSurfaceGraphs:Add()
        -- inspect(app.StoredData[1])
        farFieldPlot = graph.Plots:Add(app.StoredData[1])
        -- inspect(farFieldPlot.Quantity)
        -- farFieldPlot.Quantity.DB = true 
        -- set db = true
        farFieldPlot.Quantity.ValuesScaledToDB = true
        
        farFieldPlot.Legend.LogarithmicRange.Type = pf.Enums.LogScaleRangeTypeEnum.Fixed
        farFieldPlot.Legend.LogarithmicRange.FixedRangeMin = tonumber(dbMin.Value)
        farFieldPlot.Legend.LogarithmicRange.FixedRangeMax = tonumber(dbMax.Value)
        -- Export an image at a specific aspect ratio
        
        graph:Restore()
        graph:SetSize(1000,800)
        graph:ExportImage(dirnames[1]..string.format("_%s",dirnames[2]), "png",1223,831)
    end
end

