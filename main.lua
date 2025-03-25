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

G.C.BFDI = {}

G.C.BFDI.MISC_COLOURS = {
    BFDI_GREEN = HEX("076908"),
}

local loc_colour_ref = loc_colour

function loc_colour(_c, default)
    if not G.ARGS.LOC_COLOURS then
        loc_colour_ref(_c, default)
    elseif not G.ARGS.LOC_COLOURS.bfdi_colours then
        G.ARGS.LOC_COLOURS.bfdi_colours = true

        local new_colors = {
            bfdi_green = G.C.BFDI_GREEN,
        }

        for k, v in pairs(new_colors) do
            G.ARGS.LOC_COLOURS[k] = v
        end
    end

    return loc_colour_ref(_c, default)
end