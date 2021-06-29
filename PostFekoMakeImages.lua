app = pf.GetApplication()
string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
local file = assert(io.open("D:/FEKO/SoftWare/ISARScripts/data2.txt", "r" ), "Could not create the file for writing. Ensure that you have write access.")
local read_matrix = file:read('*a')
local mat_list = string.split(read_matrix, "\n")
for f=1,33 do
-- for f=1,#mat_list-1 do
    project = app:NewProject()
    app:OpenFile(string.format("D:/FEKO/SoftWare/F35/Data3MakeFile/F35%d/F35_%d.cfx",f,f))
    ff = pf.FormDataSelector.New("",pf.Enums.FormDataSelectorType.FarField)

    require "BuildImage"
    buildImage(ff,ff.Value:GetDataSet(),0,140)
    graph = app.CartesianSurfaceGraphs:Add()
    -- inspect(app.StoredData[1])
    farFieldPlot = graph.Plots:Add(app.StoredData[1])
    inspect(farFieldPlot.Quantity)
    -- farFieldPlot.Quantity.DB = true 
    -- set db = true
    farFieldPlot.Quantity.ValuesScaledToDB = true
    
    farFieldPlot.Legend.LogarithmicRange.Type = pf.Enums.LogScaleRangeTypeEnum.Fixed
    farFieldPlot.Legend.LogarithmicRange.FixedRangeMin = -50
    farFieldPlot.Legend.LogarithmicRange.FixedRangeMax = -10
    -- Export an image at a specific aspect ratio
    
    graph:Restore()
    graph:SetSize(1000,800)
    graph:ExportImage(string.format("F35_%d",f), "png",1223,831)
end

