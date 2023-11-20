--[[ff = pf.FormDataSelector.New("",pf.Enums.FormDataSelectorType.FarField)
viewAngle = "-5.9952043329758e-14"
angleRange= "3.9168300858879"
require "BuildImage"
buildImage(ff,ff.Value:GetDataSet(),tonumber(viewAngle),tonumber(angleRange),"D:/FEKO/SoftWare/MQ1/MQ1")
]]--

require 'lfs'
file,error = io.open("D:/FEKO/ISARScripts/zx",'rb')
if file == nil then
    lfs.mkdir("D:/FEKO/ISARScripts/zx")
end