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
	key = "bomby",
	path = "bfdi_bomby.ogg",
  replace = true
})

SMODS.Sound({
	key = "fries",
	path = "bfdi_fries.ogg",
  replace = true
})

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
  config = { extra = { is_contestant = true, is_destroyed = false } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 0, y = 0 },
  cost = 7,
  blueprint_compat = false,
  calculate = function(self, card, context)
    if context.destroy_card and context.cardarea == G.hand and context.scoring_name == "High Card" then
	    return { remove = true }
	  end
	
	  if context.destroy_card and not card.ability.extra.is_destroyed then
      card.ability.extra.is_destroyed = true
	    G.E_MANAGER:add_event(Event({
        func = function()
          play_sound('bfdi_bomby', 1, 0.75)
          card.T.r = -0.2
          card:juice_up(0.3, 0.4)
          card.states.drag.is = true
          card.children.center.pinch.x = true
          G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
            func = function()
              G.jokers:remove_card(card)
              card:remove()
              card = nil
            return true; end})) 
          return true
        end
      }))
      card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Kaboom!", colour = G.C.RED, card = card})
	  end
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'book',
  loc_txt = {
    name = 'Book',
    text = {
      "Gains {C:chips}+#1#{} Chips when",
      "each played {C:attention}#2#{} is scored,",
      "rank changes every round",
      "{C:inactive}(Currently {C:chips}+#3#{C:inactive} Chips){}"
    }
  },
  config = { extra = { is_contestant = true, added_chips = 6, current_chips = 0 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 1, y = 0 },
  cost = 7,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_chips, localize(G.GAME.current_round.book_card.rank, 'ranks'), card.ability.extra.current_chips } }
  end,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_chips > 0 then
      return { chips = card.ability.extra.current_chips }
    end
	
	  if context.individual and context.cardarea == G.play and context.other_card:get_id() == G.GAME.current_round.book_card.id and not context.blueprint then
      card.ability.extra.current_chips = card.ability.extra.current_chips + card.ability.extra.added_chips
      return {
        message = localize('k_upgrade_ex'),
        colour = G.C.FILTER,
        card = card
      }
    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'dora',
  loc_txt = {
    name = 'Dora',
    text = {
      "When {C:attention}Blind{} is selected,",
    "destroys 1 {C:planet}Planet{} card",
    "and gains {C:white,X:mult}X#1#{} Mult",
    "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, added_xmult = 0.25, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 3, y = 0 },
  cost = 7,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  calculate = function(self, card, context)
    if context.joker_main then
      return { xmult = card.ability.extra.current_xmult }
    end

    if context.setting_blind and not context.blueprint and not card.getting_sliced then
      local destructable_planet = {}
			for i = 1, #G.consumeables.cards do
				if G.consumeables.cards[i].ability.set == "Planet" and not G.consumeables.cards[i].getting_sliced and not G.consumeables.cards[i].ability.eternal then
					destructable_planet[#destructable_planet + 1] = G.consumeables.cards[i]
				end
			end
			local planet_to_destroy = #destructable_planet > 0 and pseudorandom_element(destructable_planet, pseudoseed("dora")) or nil

			if planet_to_destroy then
				planet_to_destroy.getting_sliced = true
				card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
				G.E_MANAGER:add_event(Event({
					func = function()
						(context.blueprint_card or card):juice_up(0.8, 0.8)
						planet_to_destroy:start_dissolve({ G.C.RED }, nil, 1.6)
						return true
					end
				}))
        card_eval_status_text(context.blueprint_card or card, "extra", nil, nil, nil, {
          message = localize{ type='variable', key='a_xmult', vars={card.ability.extra.current_xmult}}})
				return nil, true
			end
    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'fries',
  loc_txt = {
    name = 'Fries',
    text = {
      "Creates a copy of {C:planet}#1#{} at",
      "the end of the round, {C:planet}Planet{}",
      "card changes every {C:red}discard{}",
      "{C:inactive}(Must have room){}"
    }
  },
  config = { extra = { is_contestant = true, chosen_planet_name = "Pluto", chosen_planet = "c_pluto" } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 4, y = 0 },
  cost = 7,
  blueprint_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.chosen_planet_name } }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      G.E_MANAGER:add_event(Event({
        func = function()
          G.E_MANAGER:add_event(Event({
            func = function()
              local new_card = create_card("Planet", G.consumables, nil, nil, nil, nil, card.ability.extra.chosen_planet, 'friesplanet')
              new_card:add_to_deck()
              G.consumeables:emplace(new_card)
              G.GAME.consumeable_buffer = 0
              new_card:juice_up(0.3, 0.5)
              return true
            end}))
          card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = '+1 '..card.ability.extra.chosen_planet_name, colour = G.C.BLUE})
          return true
        end
      }))
    end

    if context.pre_discard then
      local candidates = {}
      play_sound('bfdi_fries', 1, 0.35)
      for k, v in pairs(G.P_CENTERS) do
        if v.set == "Planet" and v.config and v.config.hand_type and v.key ~= card.ability.extra.chosen_planet and (not v.config.softlock or G.GAME.hands[v.config.hand_type].played > 0) then
          candidates[#candidates + 1] = { key = v.key, name = v.name }
        end
      end

      local selected_card = (candidates and pseudorandom_element(candidates, pseudoseed("friesrandomplanet"))) or { key = "c_pluto", name = "Pluto" }
      card.ability.extra.chosen_planet = selected_card.key
      card.ability.extra.chosen_planet_name = selected_card.name

      return
      {
        message = card.ability.extra.chosen_planet_name,
        colour = G.C.BLUE,
        card = card
      }
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    local candidates = {}
    for k, v in pairs(G.P_CENTERS) do
      if v.set == "Planet" and v.config and v.config.hand_type and v.key ~= card.ability.extra.chosen_planet and (not v.config.softlock or G.GAME.hands[v.config.hand_type].played > 0) then
        candidates[#candidates + 1] = { key = v.key, name = v.name }
      end
    end

    local selected_card = (candidates and pseudorandom_element(candidates, pseudoseed("friesrandomplanet"))) or { key = "c_pluto", name = "Pluto" }
    card.ability.extra.chosen_planet = selected_card.key
    card.ability.extra.chosen_planet_name = selected_card.name
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'gelatin',
  loc_txt = {
    name = 'Gelatin',
    text = {
      "{C:white,X:mult}X#1#{} Mult for",
	  "each played hand",
	  "except the {C:attention}first{}"
    }
  },
  config = { extra = { is_contestant = true, given_xmult = 2, duhed = false } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 5, y = 0 },
  duh_pos = { x = 2, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and not card.ability.extra.duhed then
		  return { xmult = card.ability.extra.given_xmult }
	  end

    if context.setting_blind and not context.blueprint and not (context.blueprint_card or card).getting_sliced then
      card.ability.extra.duhed = true
      card.children.center:set_sprite_pos(self.duh_pos)
      card_eval_status_text(card, 'extra', nil, nil, nil, { message = "...", colour = G.C.GREEN, card = card })
    end

    if context.cardarea == G.jokers and context.after and not context.blueprint and card.ability.extra.duhed then
      card.ability.extra.duhed = false
      G.E_MANAGER:add_event(Event({
        func = function()
          card.children.center:set_sprite_pos(self.pos)
          card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Oh yeah.", colour = G.C.GREEN, card = card })
          return true
        end
      }))
    end
  end,
  set_sprites = function(self, card, front)
    if card and card.children and card.children.center and card.children.center.set_sprite_pos and card.ability and card.ability.extra and card.ability.extra.duhed then
      card.children.center:set_sprite_pos(self.duh_pos)
    else
      card.children.center:set_sprite_pos(self.pos)
    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'ruby',
  loc_txt = {
    name = 'Ruby',
    text = {
      "Each played {C:diamonds}Diamond{}",
      "card has a {C:green}#1# in #2#{}",
      "chance to become",
      "{C:attention}Glass{} when scored"
    }
  },
  config = { extra = { is_contestant = true, odds = 2 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 0, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card:is_suit("Diamonds") and pseudorandom('ruby') < G.GAME.probabilities.normal / card.ability.extra.odds then
      local card_temp = context.other_card
      card_temp:set_ability(G.P_CENTERS.m_glass, nil, true)
      G.E_MANAGER:add_event(Event({
        func = function()
          card_temp:juice_up()
          return true
        end
      })) 
      return {
        message = "Glass",
        colour = G.C.RED,
        card = card
      }
    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

local igo = Game.init_game_object
function Game:init_game_object()
  local ret = igo(self)
  ret.current_round.book_card = { rank = "Ace" }
  return ret
end

function SMODS.current_mod.reset_game_globals(run_start)
  G.GAME.current_round.book_card = { rank = "Ace" }
  local valid_cards = {}
  for i, j in ipairs(G.playing_cards) do
    if not SMODS.has_no_rank(j) then
      valid_cards[#valid_cards + 1] = j
    end
  end
  if valid_cards[1] then 
    local chosen_card = pseudorandom_element(valid_cards, pseudoseed('book'..G.GAME.round_resets.ante))
    G.GAME.current_round.book_card.rank = chosen_card.base.value
    G.GAME.current_round.book_card.id = chosen_card.base.id
  end
end