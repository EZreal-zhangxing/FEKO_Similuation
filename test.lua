app = pf.GetApplication()


ff = pf.FormDataSelector.New("",pf.Enums.FormDataSelectorType.FarField)

require "BuildImage"
buildImage(ff,ff.Value:GetDataSet(),-89,140)
graph = app.CartesianSurfaceGraphs:Add()
-- inspect(app.StoredData[1])
farFieldPlot = graph.Plots:Add(app.StoredData[1])
-- inspect(farFieldPlot.Quantity)
-- farFieldPlot.Quantity.DB = true 
-- set db = true
farFieldPlot.Quantity.ValuesScaledToDB = true
-- set Quantity 图的类型 ISAR_RCS 不设置默认为 ISAR_Field
farFieldPlot.Quantity.Type = "ISAR_RCS"

farFieldPlot.Legend.LogarithmicRange.Type = pf.Enums.LogScaleRangeTypeEnum.Fixed
farFieldPlot.Legend.LogarithmicRange.FixedRangeMin = -40
farFieldPlot.Legend.LogarithmicRange.FixedRangeMax = -10

-- Export an image at a specific aspect ratio

graph:Restore()
graph:SetSize(1000,800)
graph:ExportImage(string.format("F35_1"), "png",1223,831)


