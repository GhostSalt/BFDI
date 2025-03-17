SMODS.Atlas {
  key = "Puffball",
  path = "Puffball.png",
  px = 71,
  py = 95,
  pos = { x = 0, y = 0 },
  atlas_table = "ANIMATION_ATLAS",
  frames = 19
}

SMODS.Atlas {
  key = "BFDIA",
  path = "BFDIA.png",
  px = 71,
  py = 95
}

SMODS.current_mod.optional_features = { cardareas = { unscored = true } }

SMODS.Joker {
  key = 'bomby',
  loc_txt = {
    name = 'Bomby',
    text = {
      "Earn {C:money}$#1#{} for each",
      "{C:blue}hand{} remaining",
      "at the end of",
      "the {C:attention}round{}"
    }
  },
  config = { extra = { is_contestant = true, given_money = 2 } },
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
  key = 'puffball',
  loc_txt = {
    name = 'Puffball',
    text = {
      "Earn {C:money}$#1#{} for each",
      "{C:blue}hand{} remaining",
      "at the end of",
      "the {C:attention}round{}"
    }
  },
  config = { extra = { is_contestant = true, given_money = 2 } },
  rarity = 2,
  atlas = 'Puffball',
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