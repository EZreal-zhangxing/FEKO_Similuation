require "lfs"
filePath = "D:/txtAndFFe/far/"
for file in lfs.dir(filePath) do
    if file ~= "." and file ~= ".." then  
        print(file)
    end
end

for f = -90,90 do
print(f)
end

print(lfs.chdir("D:/FFeExportFile1"))
dist= {}
for i=1,5 do
    dist[i] = i
end
inspect(dist)
for key,value in ipairs(dist) do
    print(key)
    print(value)
end


