
-- delta 视角方向与Z轴的夹角
-- fi 视角方向与X轴的夹角
function vectorCrossProduct(x1,x2)
x = x1["y"]*x2["z"] - x1["z"]*x2["y"]
y = x1["z"]*x2["x"] - x1["x"]*x2["z"]
z = x1["x"]*x2["y"] - x1["y"]*x2["x"]
return {["x"] = x,["y"] = y,["z"] = z}
end

function calculateAngle(theta_1,fi_1,theta_2,fi_2)
r = 10
theta_1 = theta_1 / 360 *2*math.pi
fi_1 = fi_1 / 360 *2*math.pi
theta_2 = theta_2 / 360 *2*math.pi
fi_2 = fi_2 / 360 *2*math.pi
x_1 = r*math.sin(theta_1)*math.cos(fi_1)
y_1 = r*math.sin(theta_1)*math.sin(fi_1)
z_1 = r*math.cos(theta_1)
vector_1 = {["x"] = x_1,["y"] = y_1,["z"] = z_1}
x_2 = r*math.sin(theta_2)*math.cos(fi_2)
y_2 = r*math.sin(theta_2)*math.sin(fi_2)
z_2 = r*math.cos(theta_2)
vector_2 = {["x"] = x_2,["y"] = y_2,["z"] = z_2}

temp = vectorCrossProduct(vector_1,vector_2)
u = vector_1
v = vectorCrossProduct(temp,u)
return {["U"] = u,["V"] = v}
end

function calculateAngleWithCoordation(x_1,y_1,z_1,x_2,y_2,z_2)
vector_1 = {["x"] = x_1,["y"] = y_1,["z"] = z_1}
vector_2 = {["x"] = x_2,["y"] = y_2,["z"] = z_2}
temp = vectorCrossProduct(vector_1,vector_2)
u = vector_1
v = vectorCrossProduct(temp,u)
return {["U"] = u,["V"] = v}
end

-- theta_1 = 2.3833314e+01
-- fi_1 = -1.2165939e+02
-- theta_2 = 2.5402095e+01
-- fi_2 = -1.1902152e+02
-- x_1,y_1,z_1 = -0.3071004,-0.1525,0.4218997
-- x_2,y_2,z_2 = -0.3071003,-0.1525,0.4018996
-- U_V = calculateAngleWithCoordation(x_1,y_1,z_1,x_2,y_2,z_2)
-- inspect(U_V)
-- U_V = calculateAngle(theta_1,fi_1,theta_2,fi_2)
-- inspect(U_V)
-- r = 10
-- temp = vectorCrossProduct(U_V["U"],U_V["V"])
-- inspect(temp)
-- theta = math.acos(temp["z"]/math.sqrt(math.pow(temp["x"],2)+math.pow(temp["y"],2)+math.pow(temp["z"],2)))
-- phi = math.atan(temp["y"]/temp["x"])
-- print(theta/math.pi * 180)
-- print(phi/math.pi * 180)
