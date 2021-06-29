-- CADFEKO v2020-372425 (x64)
app = cf.GetApplication()
project = app.Project

-- Modified solution entity: PlaneWaveSource2
StandardConfiguration1 = project.SolutionConfigurations["StandardConfiguration1"]
PlaneWaveSource2 = StandardConfiguration1.Sources["PlaneWaveSource2"]
properties = PlaneWaveSource2:GetProperties()
properties.EndPhi = "phi2+45"
properties.StartPhi = "phi1-45"
PlaneWaveSource2:SetProperties(properties)
