SMODS.Atlas {
  key = "BFDI",
  path = "BFDI.png",
  px = 71,
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

function count_enhancements()
  if not G.playing_cards then return 0 end
  local enhancement_tally = 0
  for k, v in pairs(G.playing_cards) do
    if next(SMODS.get_enhancements(v)) then enhancement_tally = enhancement_tally + 1 end
  end
  return enhancement_tally
end

to_big = to_big or function(x) return x end

SMODS.Joker {
  key = 'blocky',
  config = { extra = { is_contestant = true, will_play_sound = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 0, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    return {}
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before then
      local wee_cards = {}
      for i, j in ipairs(context.scoring_hand) do
        if j:get_id() > 1 and j:get_id() < 6 then
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
          colour = G.C.RED,
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
      return { remove = true }
    end
  end
}

SMODS.Joker {
  key = 'bubble',
  config = { extra = { is_contestant = true, given_xmult = 3, rounds_remaining = 3 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 1, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return {
      vars = { card.ability.extra.given_xmult, card.ability.extra.rounds_remaining, (function()
        if card.ability.extra.rounds_remaining == 1 then
          return
          ""
        else
          return "s"
        end
      end)() }
    }
  end,
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,
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
            G.E_MANAGER:add_event(Event({
              trigger = "after",
              delay = 0.3,
              blockable = false,
              func = function()
                G.jokers:remove_card(card)
                card:remove()
                card = nil
                return true
              end
            }))
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
          message = card.ability.extra.rounds_remaining .. "",
          colour = G.C.FILTER
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'coiny',
  config = { extra = { is_contestant = true, given_money = 5 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 2, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  config = { extra = { is_contestant = true, odds = 4, added_xmult = 0.5, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 3, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "david")
    return { vars = { num, denom, card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return { xmult = card.ability.extra.current_xmult }
    end

    if context.setting_blind and not context.blueprint and not card.getting_sliced then
      if SMODS.pseudorandom_probability(card, "david", 1, card.ability.extra.odds) then
        card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
        card_eval_status_text(context.blueprint_card or card, "extra", nil, nil, nil, {
          message = localize { type = 'variable', key = 'a_xmult', vars = { number_format(to_big(card.ability.extra.current_xmult)) } }
        })
      else
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.1,
          func = function()
            play_sound("bfdi_david", 1, 0.5)
            return true
          end
        }))
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
  config = { extra = { is_contestant = true, added_xmult = 0.25, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 4, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.remove_playing_cards and not context.blueprint then
      local count = 0
      for k, v in ipairs(context.removed) do
        if v:is_suit("Diamonds") then count = count + 1 end
      end

      if count > 0 then
        card.ability.extra.current_xmult = card.ability.extra.current_xmult + (card.ability.extra.added_xmult * count)
        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
          { message = localize('k_upgrade_ex'), colour = G.C.RED })
      end
    end

    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return { xmult = card.ability.extra.current_xmult }
    end
  end
}

SMODS.Joker {
  key = 'firey',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 5, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.first_hand_drawn and not context.blueprint then
      local eval = function() return G.GAME.current_round.hands_played == 0 end
      juice_card_until(card, eval, true)
    end
    if context.destroying_card and #context.full_hand == 1 and G.GAME.current_round.hands_played == 0 and context.full_hand[1]:is_face() then

      local _card = context.blueprint_card or card
      G.E_MANAGER:add_event(Event({
        func = function()
          local new_card = create_playing_card(
            {
              front = G.P_CARDS[pseudorandom_element({ 'S', 'H', 'D', 'C' }, pseudoseed('fireysu')) .. "_A"],
              center = G.P_CENTERS.m_wild
            }, G.hand, nil, nil, { G.C.SECONDARY_SET.Enhanced })

          G.GAME.blind:debuff_card(new_card)
          G.hand:sort()
          _card:juice_up()
          return true
        end
      }))
      return { remove = true }
    end
  end
}

SMODS.Joker {
  key = 'flower',
  config = { extra = { is_contestant = true, given_chips = 75 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 6, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and (context.cardarea == G.play or (context.cardarea == G.hand and not context.end_of_round)) and context.other_card:get_id() == 12 then
      if context.other_card.debuff then
        return {
          message = localize('k_debuffed'),
          colour = G.C.RED,
          card = card,
        }
      else
        return {
          chips = card.ability.extra.given_chips,
          card = card
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'golfball',
  config = { extra = { is_contestant = true, given_xmult = 2 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 7, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 0, y = 2 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  bfdi_shatters = true,
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
            end
          }))
          G.E_MANAGER:add_event(Event({
            func = function()
              card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                { message = "Revenge!", colour = G.C.SECONDARY_SET.Spectral })
              play_sound("bfdi_revenge", 1, 0.5)
              return true
            end
          }))
          return true
        end
      }))
    end
  end
}

SMODS.Joker {
  key = 'leafy',
  config = { extra = { is_contestant = true, given_money = 2 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 1, y = 2 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
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
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 2, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
    return { vars = { card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
  config = { extra = { is_contestant = true, added_hands = 1, no_of_uses = 3, current_uses = 3, ace_detected = false } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 3, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_hands, card.ability.extra.no_of_uses, card.ability.extra.current_uses } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  config = { extra = { is_contestant = true, money_loss = 1, added_mult = 2, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 4, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.money_loss, card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then
      return { mult = card.ability.extra.current_mult }
    end

    if context.cardarea == G.jokers and context.before and not card.getting_sliced then
      card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
      ease_dollars(-card.ability.extra.money_loss)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) - card.ability.extra.money_loss
      G.E_MANAGER:add_event(Event({
        func = (function()
          G.GAME.dollar_buffer = 0; return true
        end)
      }))
      return {
        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.current_mult } },
        colour = G.C.RED
      }
    end
  end
}

SMODS.Joker {
  key = 'pencil',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 5, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.first_hand_drawn then
      G.E_MANAGER:add_event(Event({
        func = function()
          local _card = create_playing_card(
            { front = pseudorandom_element(G.P_CARDS, pseudoseed('pencilra')), center = G.P_CENTERS.m_wild }, G.hand, nil,
            nil, { G.C.SECONDARY_SET.Enhanced })

          G.GAME.blind:debuff_card(_card)
          G.hand:sort()
          if context.blueprint_card then
            context.blueprint_card:juice_up()
          else
            card:juice_up()
          end
          return true
        end
      }))

      playing_card_joker_effects({ true })
    end
  end
}

SMODS.Joker {
  key = 'pin',
  config = { extra = { is_contestant = true, given_mult = 10, given_xmult = 1.25 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 6, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_mult, card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 7, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
    return {}
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
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
  config = { extra = { is_contestant = true, added_mult = 2 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 0, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.added_mult * count_enhancements() } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and count_enhancements() > 0 then
      return { mult = card.ability.extra.added_mult * count_enhancements() }
    end
  end
}

SMODS.Joker {
  key = 'spongy',
  config = { extra = { is_contestant = true, added_mult = 3 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 1, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, G.GAME.starting_deck_size, math.max(0, card.ability.extra.added_mult * (G.playing_cards and (#G.playing_cards - G.GAME.starting_deck_size) or 0)) } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and #G.playing_cards - G.GAME.starting_deck_size > 0 then
      return { mult = card.ability.extra.added_mult * (#G.playing_cards - G.GAME.starting_deck_size) }
    end
  end
}

SMODS.Joker {
  key = 'teardrop',
  config = { extra = { given_mult = 30, given_xmult = 2, given_chips = 100, given_money = 6, odds = 3 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 2, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "teardrop")
    return { vars = { card.ability.extra.given_mult, card.ability.extra.given_xmult, card.ability.extra.given_chips, card.ability.extra.given_money, num, denom } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      local outcome = {}

      if SMODS.pseudorandom_probability(card, "teardrop", 1, card.ability.extra.odds) then
        outcome.chips = card.ability.extra.given_chips
      end

      if SMODS.pseudorandom_probability(card, "teardrop", 1, card.ability.extra.odds) then
        outcome.mult = card.ability.extra.given_mult
      end

      if SMODS.pseudorandom_probability(card, "teardrop", 1, card.ability.extra.odds) then
        outcome.x_mult = card.ability.extra.given_xmult
      end

      if SMODS.pseudorandom_probability(card, "teardrop", 1, card.ability.extra.odds) then
        ease_dollars(card.ability.extra.given_money)
        outcome.dollars = card.ability.extra.given_money
      end

      return outcome
    end
  end
}

SMODS.Joker {
  key = 'tennisball',
  config = { extra = { is_contestant = true, odds = 5 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 3, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
    local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "tennisball")
    return { vars = { num, denom } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == 'unscored' and SMODS.pseudorandom_probability(card, "tennisball", 1, card.ability.extra.odds) then
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
  config = { extra = { is_contestant = true, added_chips = 10, current_chips = 0 } },
  rarity = 2,
  atlas = 'BFDI',
  pos = { x = 4, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
    return { vars = { card.ability.extra.added_chips, card.ability.extra.current_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
