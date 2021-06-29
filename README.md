# FEKO_Similuation
the script of FEKO similuation

feko仿真ISAR使用的脚本其中包括批量仿真和批量成像文件
CreateSimiluation_fromPosition.lua 从指定轨迹文件中生成对应的平面波U,V轴 进行仿真 
轨迹文件见log.txt 每行为目标所在的[x,y,z]坐标
CreateSimiluation 从目标的球面坐标系中计算U,V轴，轨迹文件参考data.txt
PostMakeImages.lua 用于仿真玩的成像

具体操作流程可以参考docx文件
