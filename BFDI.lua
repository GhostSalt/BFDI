SMODS.Atlas {
  -- Key for code to find it with
  key = "BFDI",
  -- The name of the file, for the code to pull the atlas from
  path = "BFDI.png",
  -- Width of each sprite in 1x size
  px = 71,
  -- Height of each sprite in 1x size
  py = 95
}

SMODS.current_mod.optional_features = { cardareas = { unscored = true } }

SMODS.Sound({
	key = "blocky",
	path = "bfdi_blocky.ogg",
  replace = true
})

SMODS.Sound({
	key = "bulleh",
	path = "bfdi_bulleh.ogg",
  replace = true
})

SMODS.Sound({
	key = "david",
	path = "bfdi_david.ogg",
  replace = true
})

SMODS.Sound({
	key = "fling",
	path = "bfdi_fling.ogg",
  replace = true
})

SMODS.Sound({
	key = "pop",
	path = "bfdi_pop.ogg",
  replace = true
})

SMODS.Sound({
	key = "revenge",
	path = "bfdi_revenge.ogg",
  replace = true
})

SMODS.Sound({
	key = "snowball_no",
	path = "bfdi_snowball_no.ogg",
  replace = true
})

SMODS.Sound({
	key = "yoylecake",
	path = "bfdi_yoylecake.ogg",
  replace = true
})

function count_enhancements()
	local enhancement_tally = 0
    for k, v in pairs(G.playing_cards) do
        if v.config.center ~= G.P_CENTERS.c_base then enhancement_tally = enhancement_tally + 1 end
    end
	return enhancement_tally
end

SMODS.Joker {
  key = 'yoylecake',
  loc_txt = {
    name = 'Yoylecake',
    text = {
      "The next {C:attention}#1#{} played",
      "card#2# become#3# {C:attention}Steel{}",
      "when scored"
    }
  },
  config = { extra = { cards_left = 4 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 5, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.cards_left, (function () if card.ability.extra.cards_left == 1 then return "" else return "s" end end )(), (function () if card.ability.extra.cards_left == 1 then return "s" else return "" end end )() } }
  end,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and card.ability.extra.cards_left > 0 then
      local target = context.other_card
      target:set_ability(G.P_CENTERS.m_steel, nil, true)
      G.E_MANAGER:add_event(Event({
        func = function()
          target:juice_up()
          return true
        end
      })) 
    G.E_MANAGER:add_event(Event({
      func = function()
        play_sound("bfdi_yoylecake", 1, 0.5)
        return true
      end
    }))
    card.ability.extra.cards_left = card.ability.extra.cards_left - 1
    if card.ability.extra.cards_left > 0 then
    return {
      message = card.ability.extra.cards_left.."",
      colour = G.C.RED,
      card = card
    }
  else
    G.E_MANAGER:add_event(Event({
      func = function()
          play_sound('tarot1')
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
  return {
      message = localize('k_eaten_ex'),
      colour = G.C.FILTER
  }
    end
  end
  end
}

SMODS.Joker {
  key = 'bagofboogers',
  loc_txt = {
    name = 'Bag of Boogers',
    text = {
      "Played {C:attention}Lucky{} cards give",
      "{C:mult}+#1#{} Mult when scored"
    }
  },
  config = { extra = { given_mult = 20 } },
  rarity = 1,
  atlas = 'BFDI',
  pos = { x = 6, y = 3 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_mult } }
  end,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card.ability.name == 'Lucky Card' then
      return {
        mult = card.ability.extra.given_mult,
        card = card
      }
    end
  end
}

SMODS.Joker {
  key = 'bubblerecoverycenter',
  loc_txt = {
    name = 'Bubble Recovery Center',
    text = {
      "When {C:attention}Blind{} is selected,",
      "creates a copy of {C:attention}Bubble{}",
      "if you don't have one"
    }
  },
  rarity = 1,
  atlas = 'BFDI',
  pos = { x = 7, y = 3 },
  cost = 5,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.setting_blind and not card.getting_sliced and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit and not next(SMODS.find_card("j_bfdi_bubble")) then
      G.GAME.joker_buffer = G.GAME.joker_buffer + 1
      G.E_MANAGER:add_event(Event({
        func = (function()
          G.E_MANAGER:add_event(Event({
            func = function() 
              local joker = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_bfdi_bubble", "bubblerecoverycenter")
              G.jokers:emplace(joker)
              joker:start_materialize()
              G.GAME.joker_buffer = 0
              return true
            end}))   
          card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+Bubble", colour = G.C.FILTER})                       
        return true
      end)}))
    end
  end
}

SMODS.Joker {
  key = 'blocky',
  loc_txt = {
    name = 'Blocky',
    text = {
      "All played {C:attention}2s{}-{C:attention}5s{} become",
      "{C:attention}Glass{} cards when scored",
      "Destroys all played and",
      "scored {C:attention}Glass{} cards"
    }
  },
  config = { extra = { is_contestant = true, will_play_sound = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 0, y = 1 },
  cost = 7,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before then
      local wee_cards = {}
      for i, j in ipairs(context.scoring_hand) do
        if j:get_id() > 1  and j:get_id() < 6 then 
          wee_cards[#wee_cards + 1] = j
          j:set_ability(G.P_CENTERS.m_glass, nil, true)
          G.E_MANAGER:add_event(Event({
            func = function()
              j:juice_up()
              return true
            end
          })) 
        end
      end
      if #wee_cards > 0 then
        card.ability.extra.will_play_sound = true
        return {
          message = "Glass",
          colour = G.C.FILTER,
          card = card
        }
      end
    end

    if context.individual and context.cardarea == G.play and context.other_card.ability.name == "Glass Card" then
      card.ability.extra.will_play_sound = true
    end

    if context.destroying_card and context.destroying_card.ability.name == 'Glass Card' then
      G.E_MANAGER:add_event(Event({
        func = function()
          if card.ability.extra.will_play_sound then
            play_sound("bfdi_blocky", 1, 0.75)
            card.ability.extra.will_play_sound = false
          end
          return true
        end
      }))
      return {remove = true}
    end
  end
}

SMODS.Joker {
  key = 'bubble',
  loc_txt = {
    name = 'Bubble',
    text = {
      "{C:white,X:mult}X#1#{} Mult",
      "for {C:attention}#2#{} round#3#"
    }
  },
  config = { extra = { is_contestant = true, given_xmult = 3, rounds_remaining = 3 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 1, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult, card.ability.extra.rounds_remaining, (function () if card.ability.extra.rounds_remaining == 1 then return "" else return "s" end end )() } }
  end,
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main then
      return { x_mult = card.ability.extra.given_xmult }
    end

    if context.end_of_round and context.main_eval and not context.blueprint then
      if card.ability.extra.rounds_remaining <= 1 then 
          G.E_MANAGER:add_event(Event({
              func = function()
                  play_sound("bfdi_pop", 1, 0.5)
                  card.T.r = -0.2
                  card:juice_up(0.3, 0.4)
                  card.states.drag.is = true
                  card.children.center.pinch.x = true
                  G.E_MANAGER:add_event(Event({trigger = "after", delay = 0.3, blockable = false,
                    func = function()
                      G.jokers:remove_card(card)
                      card:remove()
                      card = nil
                    return true
                  end})) 
                  return true
              end
          })) 
          return {
            message = "Popped!",
            colour = G.C.FILTER
          }
      else
        card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining - 1
        return {
          message = card.ability.extra.rounds_remaining.."",
          colour = G.C.FILTER
        }
      end
  end

  end
}

SMODS.Joker {
  key = 'coiny',
  loc_txt = {
    name = 'Coiny',
    text = {
      "Gives {C:attention}$#1#{} when a",
      "{C:attention}playing card{}",
      "is destroyed"
    }
  },
  config = { extra = { is_contestant = true, given_money = 5 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 2, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
	if context.remove_playing_cards then
    return
		{
			dollars = card.ability.extra.given_money * #context.removed,
			card = card
		}
    end
  end
}

SMODS.Joker {
  key = 'david',
  loc_txt = {
    name = 'David',
    text = {
      "When {C:attention}Blind{} is selected,",
      "{C:green}#1# in #2#{} chance to",
      "gain {C:white,X:mult}X#3#{} Mult",
      "{C:inactive}(Currently {C:white,X:mult}X#4#{C:inactive} Mult)"
    }
  },
  config = { extra = { is_contestant = true, odds = 4, added_xmult = 0.5, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 3, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds, card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return { xmult = card.ability.extra.current_xmult }
    end

    if context.setting_blind and not context.blueprint and not card.getting_sliced then
      if pseudorandom('david') < G.GAME.probabilities.normal / card.ability.extra.odds then
        card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
        card_eval_status_text(context.blueprint_card or card, "extra", nil, nil, nil, {
          message = localize{ type='variable', key='a_xmult', vars={number_format(to_big(card.ability.extra.current_xmult))}}
        })
      else
        G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
          play_sound("bfdi_david", 1, 0.5)
        return true end }))
        card_eval_status_text(context.blueprint_card or card, "extra", nil, nil, nil, {
          message = "Nope!",
          colour = G.C.FILTER
        })
      end
    end
  end
}

SMODS.Joker {
  key = 'eraser',
  loc_txt = {
    name = 'Eraser',
    text = {
      "Gains {C:white,X:mult}X#1#{} Mult for",
	  "each destroyed {C:diamonds}Diamond{}",
	  "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, added_xmult = 0.2, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 4, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
	
    if context.remove_playing_cards and not context.blueprint then
      local count = 0
      for k, v in ipairs(context.removed) do
        if v:is_suit("Diamonds") then count = count + 1 end
      end
      
      if count > 0 then
        card.ability.extra.current_xmult = card.ability.extra.current_xmult + (card.ability.extra.added_xmult * count)
        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.RED})
      end
      end

	if context.joker_main and card.ability.extra.current_xmult > 1 then
		return { xmult = card.ability.extra.current_xmult }
	end
	
  end
}

SMODS.Joker {
  key = 'firey',
  loc_txt = {
    name = 'Firey',
    text = {
      "If played hand has",
      "exactly {C:attention}1{} card, and it",
      "is a {C:attention}face{} card, destroy",
      "it and create a {C:attention}Wild Ace{}"
    }
  },
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 5, y = 1 },
  cost = 7,
    blueprint_compat = false,
  calculate = function(self, card, context)
    if context.destroying_card and #context.full_hand == 1 and context.full_hand[1]:is_face() then
      G.E_MANAGER:add_event(Event({
        func = function()
          local _card = create_playing_card({front = G.P_CARDS[pseudorandom_element({'S','H','D','C'}, pseudoseed('fireysu')).."_A"], center = G.P_CENTERS.m_wild}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                  
          G.GAME.blind:debuff_card(_card)
          G.hand:sort()
          if context.blueprint_card then
            context.blueprint_card:juice_up()
          else
            card:juice_up()
          end
          return true
        end}))
      return true
    end
  end
}

SMODS.Joker {
  key = 'flower',
  loc_txt = {
    name = 'Flower',
    text = {
      "{C:attention}Queens{} held in hand",
      "or played and scored",
      "give {C:chips}+#1#{} Chips"
    }
  },
  config = { extra = { is_contestant = true, given_chips = 100 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 6, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_chips } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.individual and (context.cardarea == G.play or (context.cardarea == G.hand and not context.end_of_round)) and context.other_card:get_id() == 12 then
      return {
        chips = card.ability.extra.given_chips,
        card = card
      }
    end
  end
}

SMODS.Joker {
  key = 'golfball',
  loc_txt = {
    name = 'Golf Ball',
    text = {
      "Played {C:attention}Steel{} cards",
      "give {C:white,X:mult}X#1#{} Mult",
      "when scored"
    }
  },
  config = { extra = { is_contestant = true, given_xmult = 2 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 7, y = 1 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card.ability.name == 'Steel Card' then
      return {
        xmult = card.ability.extra.given_xmult,
        card = card
      }
    end
  end
}

SMODS.Joker {
  key = 'icecube',
  loc_txt = {
    name = 'Ice Cube',
    text = {
      "On {C:attention}final hand{} of",
      "round, creates a",
      "{C:spectral}Spectral{} card",
      "{C:inactive}(Must have room){}"
    }
  },
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 0, y = 2 },
  cost = 7,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and G.GAME.current_round.hands_left == 0 and not (context.blueprint_card or card).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      G.E_MANAGER:add_event(Event({
        func = function()
          G.E_MANAGER:add_event(Event({
            func = function()
              local new_card = create_card("Spectral", G.consumables, nil, nil, nil, nil, nil, 'icecube')
              new_card:add_to_deck()
              G.consumeables:emplace(new_card)
              G.GAME.consumeable_buffer = 0
              new_card:juice_up(0.3, 0.5)
              return true
            end}))
            G.E_MANAGER:add_event(Event({
              func = function()
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "Revenge!", colour = G.C.SECONDARY_SET.Spectral})
                play_sound("bfdi_revenge", 1, 0.5)
              return true
            end}))
          return true
        end
      }))
    end
  end
}

SMODS.Joker {
  key = 'leafy',
  loc_txt = {
    name = 'Leafy',
    text = {
      "Earn {C:money}$#1#{} for each",
      "{C:blue}hand{} remaining",
      "at the end of",
      "the {C:attention}round{}"
    }
  },
  config = { extra = { is_contestant = true, given_money = 2 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 1, y = 2 },
  cost = 7,
	blueprint_compat = true,
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
  key = 'match',
  loc_txt = {
    name = 'Match',
    text = {
      "Gains {C:mult}+#1#{} Mult for",
      "each played and",
      "scored {C:attention}Wild{} card",
      "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, added_mult = 3, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 2, y = 2 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then
      return { mult = card.ability.extra.current_mult }
    end

    if context.individual and context.cardarea == G.play and not context.blueprint and context.other_card.ability.name == 'Wild Card' then
      card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
      return {
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.current_mult } },
        colour = G.C.RED
      }
    end
  end
}

SMODS.Joker {
  key = 'needle',
  loc_txt = {
    name = 'Needle',
    text = {
      "{C:blue}+#1#{} hand if played hand",
	  "contains an {C:attention}unscoring Ace{}",
	  "{C:inactive}({C:attention}#2#{C:inactive} [#3#] uses each round){}"
    }
  },
  config = { extra = { is_contestant = true, added_hands = 1, no_of_uses = 3, current_uses = 3, ace_detected = false } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 3, y = 2 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_hands, card.ability.extra.no_of_uses, card.ability.extra.current_uses } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == 'unscored' and not context.blueprint and context.other_card:get_id() == 14 then
		card.ability.extra.ace_detected = true
    end
	
	if context.joker_main and card.ability.extra.ace_detected and card.ability.extra.current_uses > 0 then
		card.ability.extra.ace_detected = false
		ease_hands_played(card.ability.extra.added_hands)
		
		card.ability.extra.current_uses = card.ability.extra.current_uses - 1
		
		return {
			message = "+1 Hand",
			colour = G.C.BLUE,
			card = card
		}
	end
	
	if context.end_of_round and not context.blueprint and not context.repetition then
		card.ability.extra.current_uses = card.ability.extra.no_of_uses
	end
  end
}

SMODS.Joker {
  key = 'pen',
  loc_txt = {
    name = 'Pen',
    text = {
      "Lose {C:money}$#1#{},",
      "gains {C:mult}+#2#{} Mult",
      "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, money_loss = 1, added_mult = 2, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 4, y = 2 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money_loss, card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then
      return { mult = card.ability.extra.current_mult }
    end

    if context.cardarea == G.jokers and context.before and not card.getting_sliced then
      card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
      ease_dollars(-card.ability.extra.money_loss)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) - card.ability.extra.money_loss
      G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
      return {
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.current_mult } },
        colour = G.C.RED
      }
    end
  end
}

SMODS.Joker {
  key = 'pencil',
  loc_txt = {
    name = 'Pencil',
    text = {
      "When {C:attention}Blind{} is selected,",
	    "add a random {C:attention}Wild{}",
      "{C:attention}playing card{} to",
	    "your hand"
    }
  },
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 5, y = 2 },
  cost = 7,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.first_hand_drawn then
      G.E_MANAGER:add_event(Event({
        func = function()
          local _card = create_playing_card({front = pseudorandom_element(G.P_CARDS, pseudoseed('pencilra')), center = G.P_CENTERS.m_wild}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                  
          G.GAME.blind:debuff_card(_card)
          G.hand:sort()
          if context.blueprint_card then
            context.blueprint_card:juice_up()
          else
            card:juice_up()
          end
          return true
        end}))
  
      playing_card_joker_effects({true})
    end
  end
}

SMODS.Joker {
  key = 'pin',
  loc_txt = {
    name = 'Pin',
    text = {
      "Each {C:spades}Spade{} held in",
      "hand gives {C:mult}+#1#{} Mult,",
      "each {C:attention}Ace{} held in",
      "hand gives {C:white,X:mult}X#2#{} Mult"
    }
  },
  config = { extra = { is_contestant = true, given_mult = 10, given_xmult = 1.25 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 6, y = 2 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_mult, card.ability.extra.given_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    local return_value = {}
    if context.individual and not context.end_of_round and context.cardarea == G.hand and context.other_card:is_suit("Spades") then
      if context.other_card.debuff then
        return {
          message = localize('k_debuffed'),
          colour = G.C.RED,
          card = card,
        }
      else
        return_value.mult = card.ability.extra.given_mult
        return_value.card = card
      end
    end

    if context.individual and not context.end_of_round and context.cardarea == G.hand and context.other_card:get_id() == 14 then
      if context.other_card.debuff then
        return {
          message = localize('k_debuffed'),
          colour = G.C.RED,
          card = card,
        }
      else
        return_value.xmult = card.ability.extra.given_xmult
        return_value.card = card
      end
    end

    if return_value.card then
      return return_value
    end
  end
}

SMODS.Joker {
  key = 'rocky',
  loc_txt = {
    name = 'Rocky',
    text = {
      "All played {C:attention}face{} cards",
      "become {C:attention}Lucky{} cards",
      "when scored"
    }
  },
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 7, y = 2 },
  cost = 7,
	blueprint_compat = false,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before then
      local faces = {}
      for i, j in ipairs(context.scoring_hand) do
        if j:is_face() then 
          faces[#faces + 1] = j
          j:set_ability(G.P_CENTERS.m_lucky, nil, true)
          G.E_MANAGER:add_event(Event({
            func = function()
              j:juice_up()
              return true
            end
          })) 
        end
      end
      if #faces > 0 then
        G.E_MANAGER:add_event(Event({
          func = function()
            play_sound("bfdi_bulleh", 1, 0.5)
            return true
          end
        }))
        return {
          message = "Bulleh!",
          colour = G.C.FILTER,
          card = card
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'snowball',
  loc_txt = {
    name = 'Snowball',
    text = {
      "{C:mult}+#1#{} Mult for each",
	  "{C:attention}enhanced{} card in",
	  "your full deck",
	  "{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, added_mult = 4 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 0, y = 3 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.added_mult * count_enhancements() } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and count_enhancements() > 0 then
      return { mult = card.ability.extra.added_mult * count_enhancements() }
    end
  end
}

SMODS.Joker {
  key = 'spongy',
  loc_txt = {
    name = 'Spongy',
    text = {
      "{C:mult}+#1#{} Mult for each",
      "card above {C:attention}#2#{}",
      "in your full deck",
      "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult){}"
    }
  },
  config = { extra = { is_contestant = true, added_mult = 3 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 1, y = 3 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, G.GAME.starting_deck_size, math.max(0, card.ability.extra.added_mult * (G.playing_cards and (#G.playing_cards - G.GAME.starting_deck_size) or 0)) } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and #G.playing_cards - G.GAME.starting_deck_size > 0 then
      return { mult = card.ability.extra.added_mult * (#G.playing_cards - G.GAME.starting_deck_size) }
    end
  end
}

SMODS.Joker {
  key = 'teardrop',
  loc_txt = {
    name = 'Teardrop',
    text = {
      "{C:chips}+#3#{} Chips? {C:mult}+#1#{} Mult?",
      "{C:white,X:mult}X#2#{} Mult? {C:money}+$#4#{}?",
      "{C:inactive}({C:green}#5# in #6#{C:inactive} chance each)"
    }
  },
  config = { extra = { given_mult = 30, given_xmult = 2, given_chips = 100, given_money = 6, odds = 3 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 2, y = 3 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_mult, card.ability.extra.given_xmult, card.ability.extra.given_chips, card.ability.extra.given_money, (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      local outcome = {}
      
      if pseudorandom('teardrop') < G.GAME.probabilities.normal / card.ability.extra.odds then
        outcome.chips = card.ability.extra.given_chips
      end

      if pseudorandom('teardrop') < G.GAME.probabilities.normal / card.ability.extra.odds then
        outcome.mult = card.ability.extra.given_mult
      end
      
      if pseudorandom('teardrop') < G.GAME.probabilities.normal / card.ability.extra.odds then
        outcome.x_mult = card.ability.extra.given_xmult
      end
      
      if pseudorandom('teardrop') < G.GAME.probabilities.normal / card.ability.extra.odds then
        ease_dollars(card.ability.extra.given_money)
        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.given_money
        outcome.dollars = G.GAME.dollar_buffer
        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
      end

      return outcome
    end
  end
}

SMODS.Joker {
  key = 'tennisball',
  loc_txt = {
    name = 'Tennis Ball',
    text = {
      "Each played card that",
	  "{C:attention}doesn't score{} has a {C:green}#1# in #2#{}",
	  "chance to become {C:attention}Steel{}"
    }
  },
  config = { extra = { is_contestant = true, odds = 5 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 3, y = 3 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == 'unscored' and pseudorandom('tennisball') < G.GAME.probabilities.normal / card.ability.extra.odds then
		local target = context.other_card
		target:set_ability(G.P_CENTERS.m_steel, nil, true)
		G.E_MANAGER:add_event(Event({
			func = function()
				target:juice_up()
				return true
			end
		})) 
		G.E_MANAGER:add_event(Event({
		func = function()
			play_sound("tarot1", 1, 0.5)
			return true
		end
		}))
		return {
			message = "Steel",
			colour = G.C.FILTER,
			card = card
		}
    end
  end
}

SMODS.Joker {
  key = 'woody',
  loc_txt = {
    name = 'Woody',
    text = {
      "Gains {C:chips}+#1#{} Chips for each",
      "{C:attention}Stone{} card discarded",
      "{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips){}"
    }
  },
  config = { extra = { is_contestant = true, added_chips = 10, current_chips = 0 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 4, y = 3 },
  cost = 7,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_chips, card.ability.extra.current_chips } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_chips > 0 then
      return { chips = card.ability.extra.current_chips }
    end

    if context.discard and not context.blueprint and context.other_card.ability.name == 'Stone Card' then
      card.ability.extra.current_chips = card.ability.extra.current_chips + card.ability.extra.added_chips
                  
      return {
        message = localize('k_upgrade_ex'),
        colour = G.C.CHIPS,
        card = card
      }
    end
  end
}

SMODS.Joker {
  key = 'speakerbox',
  loc_txt = {
    name = 'Speaker Box',
    text = {
      "When {C:attention}Blind{} is selected,",
      "destroys 1 {C:attention}contestant{} Joker",
      "and gains {C:white,X:mult}X#1#{} Mult",
      "{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult)"
    }
  },
  config = { extra = { added_xmult = 1, current_xmult = 1 } },
  rarity = 4,
  atlas = 'BFDI',
  pos = { x = 0, y = 0 },
  soul_pos = { x = 1, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.current_xmult } },
        Xmult_mod = card.ability.extra.current_xmult
      }
    end

    if context.setting_blind and not (context.blueprint_card or self).getting_sliced then
    local destructable_joker = {}
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].ability.extra and type(G.jokers.cards[i].ability.extra) == "table" and G.jokers.cards[i].ability.extra.is_contestant and not G.jokers.cards[i].getting_sliced and not G.jokers.cards[i].ability.eternal then
					destructable_joker[#destructable_joker + 1] = G.jokers.cards[i]
				end
			end
			local joker_to_destroy = #destructable_joker > 0 and pseudorandom_element(destructable_joker, pseudoseed("speakerbox")) or nil

			if joker_to_destroy then
        play_sound("bfdi_fling", 1, 0.5)
				joker_to_destroy.getting_sliced = true
				card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
				G.E_MANAGER:add_event(Event({
					func = function()
						(context.blueprint_card or card):juice_up(0.8, 0.8)
						joker_to_destroy:start_dissolve({ G.C.RED }, nil, 1.6)
						return true
					end,
				}))
				if not (context.blueprint_card or card).getting_sliced then
					card_eval_status_text(context.blueprint_card or card, "extra", nil, nil, nil, {
							message = localize{ type='variable', key='a_xmult', vars={number_format(to_big(card.ability.extra.current_xmult))}}
						}
					)
				end
				return nil, true
			end
    end
  end
}

SMODS.Joker {
  key = 'one',
  loc_txt = {
    name = 'One',
    text = {
      "When {C:attention}Blind{} is selected,",
      "creates a copy of {C:spectral}Trance{}",
      "{C:inactive}(Must have room){}",
      "Each {C:planet}Blue{} seal held",
      "in hand gives {C:white,X:mult}X#1#{} Mult"
    }
  },
  config = { extra = { given_xmult = 1.5 } },
  rarity = 4,
  atlas = 'BFDI',
  pos = { x = 2, y = 0 },
  soul_pos = { x = 3, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.setting_blind and not (context.blueprint_card or self).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      G.E_MANAGER:add_event(Event({
        func = function()
          G.E_MANAGER:add_event(Event({
            func = function()
              local new_card = create_card("Spectral", G.consumables, nil, nil, nil, nil, "c_trance", "one")
              new_card:add_to_deck()
              G.consumeables:emplace(new_card)
              G.GAME.consumeable_buffer = 0
              new_card:juice_up(0.3, 0.5)
              return true
            end}))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "+1 Trance", colour = G.C.BLUE})
          return true
        end
      }))
    end

    if context.individual and context.cardarea == G.hand and context.other_card.seal and context.other_card.seal == "Blue" and not context.end_of_round then
      if context.other_card.debuff then
        return {
          message = localize('k_debuffed'),
          colour = G.C.RED,
          card = card,
        }
      else
        return {
          x_mult = card.ability.extra.given_xmult,
          card = card
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'two',
  loc_txt = {
    name = 'Two',
    text = {
      "Gains {C:white,X:mult}X#1#{} Mult if",
      "played hand is a",
      "{C:attention}Two Pair{}",
      "{C:inactive}(Currently {C:white,X:mult}X#2#{} Mult{})"
    }
  },
  config = { extra = { added_xmult = 0.2, current_xmult = 1 } },
  rarity = 4,
  atlas = 'BFDI',
  pos = { x = 4, y = 0 },
  soul_pos = { x = 5, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
	blueprint_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return {
        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.current_xmult } },
        Xmult_mod = card.ability.extra.current_xmult
      }
    end

    if context.cardarea == G.jokers and context.before and next(context.poker_hands['Two Pair']) and not context.blueprint then
      card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
      return {
          message = localize('k_upgrade_ex'),
          colour = G.C.RED,
          card = card
      }
    end
  end
}

SMODS.Joker {
  key = 'four',
  loc_txt = {
    name = 'Four',
    text = {
      "{C:blue}+#1#{} hand size,",
      "{C:blue}+#2#{} hands"
    }
  },
  config = { extra = { added_hand_size = 4, added_hands = 4 } },
  rarity = 4,
  atlas = 'BFDI',
  pos = { x = 6, y = 0 },
  soul_pos = { x = 7, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_hand_size, card.ability.extra.added_hands } }
  end,
	blueprint_compat = false,
  add_to_deck = function(self, card, from_debuff)
    G.hand:change_size(card.ability.extra.added_hand_size)
      G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.added_hands
      ease_hands_played(card.ability.extra.added_hands)
	end,
	remove_from_deck = function(self, card, from_debuff)
    G.hand:change_size(-card.ability.extra.added_hand_size)
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.added_hands
        ease_hands_played(-card.ability.extra.added_hands)
  end
}