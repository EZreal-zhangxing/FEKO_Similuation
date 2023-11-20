string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
function getFileProperty()
app = cf.GetApplication()
form  = cf.Form.New("ISAR",cf.Enums.FormLayoutEnum.Grid)
targetPath = cf.FormFileBrowser.New("")
dataPath = cf.FormFileBrowser.New("")
savePath = cf.FormDirectoryBrowser.New("")
FileName = cf.FormLineEdit.New("")
start_index = cf.FormLineEdit.New("")
end_index = cf.FormLineEdit.New("")

form:Add(cf.FormLabel.New("请选取要仿真的文件(*.cfx):"), 1, 1)
form:Add(targetPath, 1, 2)

form:Add(cf.FormLabel.New("轨迹文件(*.txt):"), 2, 1)
form:Add(dataPath, 2, 2)

form:Add(cf.FormLabel.New("保存的文件夹:"), 3, 1)
form:Add(savePath, 3, 2)

form:Add(cf.FormLabel.New("文件名:"), 4, 1)
form:Add(FileName, 4, 2)

form:Add(cf.FormLabel.New("start index:"), 5, 1)
form:Add(start_index, 5, 2)

form:Add(cf.FormLabel.New("end index(-1:对所有行进行生成):"), 6, 1)
form:Add(end_index, 6, 2)

start_index.Value = "1";
end_index.Value = "-1";
-- targetPath.Value = {"D:/FEKO/SoftWare/F22/f22.cfx"}
-- savePath.Value = "D:/FEKO/SoftWare/F22/straight_overhead_02_feko_new"
dataPath.Value = {"D:/FEKO/SoftWare/PathFile/straight_overhead_02_bk.txt"}
-- FileName.Value = "F22"

assert(form:Run(), "Cancelled")
-- print(targetPath.Value[1])
-- print(savePath.Value)
-- print(dataPath.Value[1])
-- print(FileName.Value)
fileNames = string.split(targetPath.Value[1],".")
assert(fileNames[2] == "cfx","file must be a cfx file!")
assert(dataPath.Value ~= nil,"data file can not be nil!")
assert(savePath.Value ~= nil,"savePath can not be nil!")

return {["targetFile"] = targetPath.Value[1],["dataPath"] = dataPath.Value[1],["savePath"] = savePath.Value,["fileName"] = FileName.Value,["startIndex"] = start_index.Value,["endIndex"] = end_index.Value}
end

-- getFileProperty()
