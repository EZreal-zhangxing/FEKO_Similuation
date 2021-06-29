function dealSimiluation(theta_1,fi_1,theta_2,fi_2)
require "CalculateAngle"

app = cf.GetApplication()
project = app:NewProject()

project = app:OpenFile([[D:\FEKO\SoftWare\F35\f35.cfx]])
config_source = project.SolutionConfigurations[1].Sources[1]
-- inspect()
config_source.StartPhi = "phi1"
config_source.EndPhi = "phi2"
config_source.PhiIncrement = "dphi"
config_source.StartTheta = 90
config_source.EndTheta = 90
config_source.ThetaIncrement = 10
properties = config_source:GetProperties()
-- inspect(properties)
-- properties.StartPhi

-- theta_1 = 232.9326
-- fi_1 = 6.2522
-- theta_2 = 230.1162
-- fi_2 = 3.9690
U_V = calculateAngle(theta_1,fi_1,theta_2,fi_2)

inspect(U_V)
properties.LocalWorkplane.UVector.X = U_V["U"]["x"]
properties.LocalWorkplane.UVector.Y = U_V["U"]["y"]
properties.LocalWorkplane.UVector.Z = U_V["U"]["z"]

properties.LocalWorkplane.VVector.X = U_V["V"]["x"]
properties.LocalWorkplane.VVector.Y = U_V["V"]["y"]
properties.LocalWorkplane.VVector.Z = U_V["V"]["z"]
config_source:SetProperties(properties)
app:Save()
-- Mesh the model
project.Mesher:Mesh()

-- Save project
app:SaveAs("D:/FEKO/SoftWare/F35/F35_1.cfx")
 -- app:Save()

-- RunFEKO
project.Launcher:RunFEKO()

app:Save()
-- project.Launcher:RunPOSTFEKO()
end

