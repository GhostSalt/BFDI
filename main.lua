SMODS.Atlas {
  key = "modicon",
  path = "BFDIIcon.png",
  px = 34,
  py = 34
}

SMODS.current_mod.optional_features = { cardareas = { unscored = true } }

to_big = to_big or function(x) return x end
to_number = to_number or function(x) return x end

local allFolders = { "none", "items" }

local allFiles = { ["none"] = {}, ["items"] = { "BFDI", "BFDIA", "BFB-TPoT", "OtherCharacters", "Misc", "Decks" } }

for i = 1, #allFolders do
  if allFolders[i] == "none" then
    for j = 1, #allFiles[allFolders[i]] do
      assert(SMODS.load_file(allFiles[allFolders[i]][j] .. ".lua"))()
    end
  else
    for j = 1, #allFiles[allFolders[i]] do
      assert(SMODS.load_file(allFolders[i] .. "/" .. allFiles[allFolders[i]][j] .. ".lua"))()
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
  ret.current_round.bracelety_card = { rank = "Ace", id = 14 }
  return ret
end

function SMODS.current_mod.reset_game_globals(run_start)
  G.GAME.current_round.book_card = { rank = "Ace", id = 14 }
  G.GAME.current_round.fanny_card = { rank = "Ace", id = 14 }
  G.GAME.current_round.bracelety_card = { rank = "Ace", id = 14 }
  local valid_cards = {}
  for i, j in ipairs(G.playing_cards) do
    if not SMODS.has_no_rank(j) then
      valid_cards[#valid_cards + 1] = j
    end
  end
  if valid_cards[1] then
    local book_chosen_card = pseudorandom_element(valid_cards, pseudoseed('book' .. G.GAME.round_resets.ante))
    G.GAME.current_round.book_card.rank = book_chosen_card.base.value
    G.GAME.current_round.book_card.id = book_chosen_card.base.id

    local fanny_chosen_card = pseudorandom_element(valid_cards, pseudoseed('fanny' .. G.GAME.round_resets.ante))
    G.GAME.current_round.fanny_card.rank = fanny_chosen_card.base.value
    G.GAME.current_round.fanny_card.id = fanny_chosen_card.base.id

    local bracelety_chosen_card = pseudorandom_element(valid_cards, pseudoseed('bracelety' .. G.GAME.round_resets.ante))
    G.GAME.current_round.bracelety_card.rank = bracelety_chosen_card.base.value
    G.GAME.current_round.bracelety_card.id = bracelety_chosen_card.base.id
  end
end

local update_ref = Game.update
function Game:update(dt)
  for k, v in pairs(G.P_CENTERS) do
    if v.bfdi_anim then
      if not v.bfdi_anim.t then v.bfdi_anim.t = 0 end
      if not v.bfdi_anim.length then
        v.bfdi_anim.length = 0
        for _, frame in ipairs(v.bfdi_anim) do
          v.bfdi_anim.length = v.bfdi_anim.length + (frame.t or 0)
        end
      end
      v.bfdi_anim.t = (v.bfdi_anim.t + dt) % v.bfdi_anim.length
      local ix = 0
      local t_tally = 0
      for _, frame in ipairs(v.bfdi_anim) do
        ix = ix + 1
        t_tally = t_tally + frame.t
        if t_tally > v.bfdi_anim.t then break end
      end
      v.pos.x = v.bfdi_anim[ix].x
      v.pos.y = v.bfdi_anim[ix].y
    end
  end


  return update_ref(self, dt)
end

local ref = Game.main_menu
function Game:main_menu(change_context)
  for k, v in pairs(G.P_CENTERS) do
    if v.config and v.config.extra and type(v.config.extra) == "table" and v.config.extra.is_contestant then
      v.set_badges = function(self, card, badges)
        badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN,
          G.C.WHITE, 1)
      end
    end
  end
  ref(self, change_context)
end
