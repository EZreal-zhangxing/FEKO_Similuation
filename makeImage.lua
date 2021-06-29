require 'utils.math_helper'
require 'utils.FT_helper'
require 'utils.file_helper'
require 'utils.local_maximum_minimum'
require 'lfs'
require 'BuildImage'

app = pf.GetApplication()

--Create Form and Items
form  = pf.Form.New("ISAR",pf.Enums.FormLayoutEnum.Grid)
fileSelect = pf.FormDirectoryBrowser.New("")
freSample = pf.FormLineEdit.New("")
angleSample = pf.FormLineEdit.New("")

form:Add(pf.FormLabel.New("File Select"), 1, 1)
form:Add(fileSelect, 1, 2)

form:Add(pf.FormLabel.New("Viewing angle"), 2, 1)
form:Add(freSample, 2, 2)

form:Add(pf.FormLabel.New("Angle Sample"), 3, 1)
form:Add(angleSample, 3, 2)

freSample.Value = "0"
--Run Form
assert(form:Run(), "Cancelled")

filePath = fileSelect.Value

for ifile in lfs.dir(fileSelect.Value) do
    if ifile ~= "." and ifile ~= ".." then
        local absoulteFilepath = filePath.."/"..ifile
        -- local m_file = assert(io.open(absoulteFilepath,"r"),"Could not open file ["..absoulteFilepath.."]")
        -- local read_matrix = m_file:read('*a')
        app:OpenFile(absoulteFilepath)
        -- pf.DataSet.New(absoulteFilepath)
        -- print(pf.Load(read_matrix))
        -- a = pf.FormDataSelector.New("",absoulteFilepath)
        -- print(a.Value:GetDataSet())
    end
end

-- local m_file = assert(io.open(absoulteFilepath,"r"),"Could not open file ["..absoulteFilepath.."]")
-- local read_matrix = pf.FormDataSelector.New(absoulteFilepath, pf.Enums.FormDataSelectorType.FarField)
-- print(read_matrix.Value:GetDataSet())
-- local absoulteFilepath = "D:\PyharmWorkspace\noiceProject\f22_L_100.ffe"
