SMODS.Atlas {
  key = "modicon",
  path = "BFDIIcon.png",
  px = 34,
  py = 34
}

local allFolders = { "none", "items" }

local allFiles = { ["none"] = {}, ["items"] = { "BFDI", "BFDIA", "BFB-TPoT", "Misc", "Legendaries", "Decks" } }

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

local ref = Card.start_dissolve
function Card:start_dissolve()
    if self.config.center.bfdi_shatters then
        return self:shatter()
    else
        return ref(self)
    end
end

local igo = Game.init_game_object
function Game:init_game_object()
  local ret = igo(self)
  ret.current_round.book_card = { rank = "Ace", id = 14 }
  ret.current_round.fanny_card = { rank = "Ace", id = 14 }
  return ret
end

function SMODS.current_mod.reset_game_globals(run_start)
  G.GAME.current_round.book_card = { rank = "Ace", id = 14 }
  G.GAME.current_round.fanny_card = { rank = "Ace", id = 14 }
  local valid_cards = {}
  for i, j in ipairs(G.playing_cards) do
    if not SMODS.has_no_rank(j) then
      valid_cards[#valid_cards + 1] = j
    end
  end
  if valid_cards[1] then 
    local book_chosen_card = pseudorandom_element(valid_cards, pseudoseed('book'..G.GAME.round_resets.ante))
    G.GAME.current_round.book_card.rank = book_chosen_card.base.value
    G.GAME.current_round.book_card.id = book_chosen_card.base.id
    
    local fanny_chosen_card = pseudorandom_element(valid_cards, pseudoseed('fanny'..G.GAME.round_resets.ante))
    G.GAME.current_round.fanny_card.rank = fanny_chosen_card.base.value
    G.GAME.current_round.fanny_card.id = fanny_chosen_card.base.id
  end
end