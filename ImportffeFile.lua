-- 读取FFE文件夹的内容 并成像
app = pf.GetApplication()
require "lfs"
package.path = package.path..";D:/FEKO/SoftWare/ISARScripts/?.lua"
require "BuildImage"
-- filePath = "D:/txtAndFFe/far/"
filePath = "D:/txtAndFFeTemp/"
exportPath = "D:/FFeExportFile/"

string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

function makeImages(filename,filePath,viewanglestart,viewangleend)
    project = app:NewProject()
    importFF = app:ImportResults(filePath,pf.Enums.ImportFileTypeEnum.FEKOFarField)
    ff = pf.FormDataSelector.New("",pf.Enums.FormDataSelectorType.FarField)
    for f = viewanglestart,viewangleend do
        buildImage(ff,ff.Value:GetDataSet(),f,140)
        graph = app.CartesianSurfaceGraphs:Add()
        -- inspect(app.StoredData[1])
        farFieldPlot = graph.Plots:Add(app.StoredData[1])
        -- inspect(farFieldPlot.Quantity)
        -- farFieldPlot.Quantity.DB = true 
        -- set db = true
        farFieldPlot.Quantity.ValuesScaledToDB = true
        -- set 展示类型 为RCS图
        farFieldPlot.Quantity.Type = "ISAR_RCS"
        farFieldPlot.Legend.LogarithmicRange.Type = pf.Enums.LogScaleRangeTypeEnum.Fixed
        farFieldPlot.Legend.LogarithmicRange.FixedRangeMin = -40
        farFieldPlot.Legend.LogarithmicRange.FixedRangeMax = -10
        -- Export an image at a specific aspect ratio

        graph:Restore()
        graph:SetSize(1000,800)
        print("save file ["..string.format(exportPath..filename[1].."/"..filename[1].."_%d.png]",f))
        graph:ExportImage(string.format(exportPath..filename[1].."/"..filename[1].."_%d",f), "png",1223,831)
        app.StoredData[1]:Delete()
    end
    
end

for file in lfs.dir(filePath) do
    if file ~= "." and file ~= ".." then
        filename = string.split(file,".")
        if lfs.chdir(exportPath..filename[1]) then
            lfs.rmdir(exportPath..filename[1])
            lfs.mkdir(exportPath..filename[1])
        else
            lfs.mkdir(exportPath..filename[1])
        end
        makeImages(filename,filePath..file,-90,89)
    end
end
