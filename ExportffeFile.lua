-- 从fek文件导出 ffe文件
app = pf.GetApplication()
string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
local file = assert(io.open("D:/FEKO/SoftWare/ISARScripts/data2.txt", "r" ), "Could not create the file for writing. Ensure that you have write access.")
local read_matrix = file:read('*a')
local mat_list = string.split(read_matrix, "\n")
for f=1,#mat_list-1 do
    project = app:NewProject()
    app:OpenFile(string.format("D:/FEKO/SoftWare/F35/Data2MakeFile/F35%d/F35_%d.fek",f,f))
    farFieldData = app.Models[1].Configurations[1].FarFields[1]
    farFieldData:ExportData(string.format("F35_%d",f),pf.Enums.FarFieldsExportTypeEnum.RCS,141)
end
