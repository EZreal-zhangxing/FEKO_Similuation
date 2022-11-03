# FEKO_Similuation
the script of FEKO similuation

feko仿真ISAR使用的脚本其中包括批量仿真和批量成像文件
CreateSimiluation_fromPosition.lua 从指定轨迹文件中生成对应的平面波U,V轴 进行仿真 
轨迹文件见trajectory夹 每行为目标所在的$[x,y,z,r_1,r_2,r_3]$坐标

*CreateSimiluation*（已过时） 从目标的球面坐标系中计算U,V轴，轨迹文件参考data.txt
PostMakeImages.lua 用于仿真结束后的成像

具体操作流程可以参考docx文件



### update 2022年11月3日10:22:57

更新了仿真文档，并在轨迹文件夹添加了8条轨迹信息。

注：**在运行脚本之前先确保仿真模型是能进行求解的**。可以参考[知乎专栏](https://www.zhihu.com/column/c_1327016161586741248)

