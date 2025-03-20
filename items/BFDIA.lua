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
  key = 'donut',
  loc_txt = {
    name = 'Donut',
    text = {
      "At the end of the round,",
	  "gains {C:mult}+#1#{} Mult for each",
	  "{C:attention}seal{} held in hand",
	  "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 2, y = 0 },
  cost = 7,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then
      return { mult = card.ability.extra.current_mult }
    end
	
	if context.end_of_round and context.other_card and context.other_card.seal and not context.repetition and not context.repetition_only and not context.blueprint then
		card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
		return { message = localize('k_upgrade_ex'), colour = G.C.FILTER, card = card }
	end
  end
}

SMODS.Joker {
  key = 'nickel',
  loc_txt = {
    name = 'Nickel',
    text = {
      "Gives {C:attention}$#1#{} when a",
      "{C:attention}playing card{} is",
      "added to your deck"
    }
  },
  config = { extra = { is_contestant = true, given_money = 5 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 6, y = 0 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
	if context.playing_card_added then
    return
		{
			dollars = card.ability.extra.given_money,
			card = card
		}
    end
  end
}

SMODS.Joker {
  key = 'puffball',
  loc_txt = {
    name = 'Puffball',
    text = {
      "{C:white,X:mult}X#1#{} Mult if",
	  "a {C:attention}Wild{} card",
	  "is held in hand"
    }
  },
  config = { extra = { is_contestant = true, given_xmult = 2, wild_detected = false } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 7, y = 0 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.wild_detected then
		return { xmult = card.ability.extra.given_xmult }
	end
  
	if context.individual and not context.end_of_round and context.cardarea == G.hand and context.other_card.ability.name == 'Wild Card' and not context.other_card.debuff then
		card.ability.extra.wild_detected = true
    end
	
	if context.cardarea == G.jokers and context.before then
		card.ability.extra.wild_detected = false
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
  config = { extra = { is_contestant = true, given_money = 3 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 1, y = 1 },
  cost = 7,
  blueprint_compat = true,
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