SMODS.Atlas {
  key = "modicon",
  path = "BFDIIcon.png",
  px = 34,
  py = 34
}

local allFolders = { "none", "items" }

local allFiles = { ["none"] = {}, ["items"] = { "BFDI", "BFDIA" } }

for i = 1, #allFolders do
    if allFolders[i] == "none" then
        for j = 1, #allFiles[allFolders[i]] do
            assert(SMODS.load_file(allFiles[allFolders[i]][j]..".lua"))()
        end
    else
        for j = 1, #allFiles[allFolders[i]] do
            assert(SMODS.load_file(allFolders[i].."/"..allFiles[allFolders[i]][j]..".lua"))()
        end
    end
end