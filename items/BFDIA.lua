SMODS.Atlas {
  key = "Puffball",
  path = "Puffball.png",
  px = 71,
  py = 95,
  pos = { x = 0, y = 0 }--[[,
  atlas_table = "ANIMATION_ATLAS",
  frames = 19]]--
}

SMODS.Atlas {
  key = "BFDIA",
  path = "BFDIA.png",
  px = 71,
  py = 95
}

SMODS.current_mod.optional_features = { cardareas = { unscored = true } }

SMODS.Sound({
	key = "yellow_face",
	path = "bfdi_yellow_face.ogg",
  replace = true
})

SMODS.Joker {
  key = 'bomby',
  loc_txt = {
    name = 'Bomby',
    text = {
      "If played hand is a",
      "{C:attention}High Card{}, destroys all",
      "cards held in hand",
      "{C:red,E:2}self destructs{}"
    }
  },
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 0, y = 0 },
  cost = 7,
  blueprint_compat = false,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money } }
  end,
  calc_dollar_bonus = function(self, card)
    if G.GAME.current_round.hands_left > 0 then
      return card.ability.extra.given_money * G.GAME.current_round.hands_left
    end
  end
}

SMODS.Joker {
  key = 'yellowface',
  loc_txt = {
    name = 'Yellow Face',
    text = {
      "Gives {C:money}$#1#{} when a",
      "consumable is sold"
    }
  },
  config = { extra = { is_contestant = true, given_money = 2 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 1, y = 1 },
  cost = 7,
  blueprint_compat = false,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money } }
  end,
  calculate = function(self, card, context)
    if context.selling_card and context.card.config.center.set ~= "Joker" then
      play_sound("bfdi_yellow_face", 1, 0.5)
      return { dollars = card.ability.extra.given_money }
    end
  end
}