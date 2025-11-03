SMODS.Atlas {
  key = "BFB-TPoT",
  path = "BFB-TPoT.png",
  px = 71,
  py = 95
}

to_big = to_big or function(x) return x end

SMODS.Joker {
  key = 'eightball',
  config = { extra = { added_xmult = 0.8, current_xmult = 1, is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and not context.blueprint and context.cardarea == G.play and context.other_card:get_id() == 8 then
      card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
      return { message = localize("k_upgrade_ex"), colour = G.C.FILTER, card = card }
    end

    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return { xmult = card.ability.extra.current_xmult }
    end

    if context.after and not context.blueprint and card.ability.extra.current_xmult > 1 then
      card.ability.extra.current_xmult = 1
      return { message = localize("k_reset"), colour = G.C.RED, card = card }
    end
  end
}

SMODS.Joker {
  key = 'balloony',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 1, y = 0 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and G.GAME.current_round.discards_left > 0 and count_consumables() < G.consumeables.config.card_limit then
      local successes = 0
      for i = 1, G.GAME.current_round.discards_left do
        if count_consumables() < G.consumeables.config.card_limit then
          G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
          successes = successes + 1
          G.E_MANAGER:add_event(Event({
            delay = 0.3,
            blockable = false,
            func = function()
              play_sound("timpani")
              local new_card = create_card("Planet", G.consumables, nil, nil, nil, nil, nil, "balloony")
              new_card:add_to_deck()
              G.consumeables:emplace(new_card)
              G.GAME.consumeable_buffer = 0
              new_card:juice_up(0.3, 0.5)
              return true
            end
          }))
        end
      end
      return {
        message = localize { type = 'variable', key = successes == 1 and 'a_planet' or 'a_planets', vars = { successes } },
        colour = G.C.SECONDARY_SET.Planet
      }
    end
  end
}

SMODS.Joker {
  key = 'barfbag',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 2, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.before then
      local valid = true
      for i = 1, #G.play.cards do
        if G.play.cards[i].ability.name ~= 'Lucky Card' then valid = false end
      end

      if valid and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        return {
          extra = {
            focus = card,
            message = localize('k_plus_tarot'),
            func = function()
              G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                  play_sound("timpani")
                  local new_card = create_card("Tarot", G.consumables, nil, nil, nil, nil, nil, "marker")
                  new_card:add_to_deck()
                  G.consumeables:emplace(new_card)
                  G.GAME.consumeable_buffer = 0
                  new_card:juice_up(0.3, 0.5)
                  return true
                end
              }))
            end
          },
          colour = G.C.SECONDARY_SET.Tarot,
          card = card
        }
      end
    end
  end,
  enhancement_gate = "m_lucky"
}

SMODS.Joker {
  key = 'basketball',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 3, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.repetition and context.cardarea == G.play and context.other_card.ability.name == 'Steel Card' then
      return {
        message = localize("k_again_ex"),
        repetitions = 1,
        card = card
      }
    end
  end,
  enhancement_gate = "m_steel"
}

SMODS.Joker {
  key = 'bell',
  config = { extra = { is_contestant = true, seen_straights = 0, required_straights = 2, current_xmult = 1, added_xmult = 0.25 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.required_straights, card.ability.extra.required_straights - card.ability.extra.seen_straights, card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return { xmult = card.ability.extra.current_xmult }
    end

    if context.before and G.GAME.blind and context.scoring_name == "Straight" and not context.blueprint and card.ability.extra.seen_straights < card.ability.extra.required_straights then
      card.ability.extra.seen_straights = card.ability.extra.seen_straights + 1
      if card.ability.extra.seen_straights >= card.ability.extra.required_straights then
        card.ability.extra.seen_straights = 0
        return { message = localize("k_upgrade_ex"), colour = G.C.FILTER, card = card }
      else
        return {
          message = card.ability.extra.seen_straights .. '/' .. card.ability.extra.required_straights,
          colour = G.C.FILTER
        }
      end
    end

    if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
      card.ability.extra.seen_straights = 0
    end
  end
}

SMODS.Joker {
  key = 'blackhole',
  config = { extra = { levels = 3, is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 5, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.levels } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  add_to_deck = function(self, card, from_debuff)
    G.E_MANAGER:add_event(Event({
      func = function()
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
          { handname = localize('k_all_hands'), chips = '...', mult = '...', level = '' })
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.2,
          func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true
          end
        }))
        update_hand_text({ delay = 0 }, { mult = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.9,
          func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            return true
          end
        }))
        update_hand_text({ delay = 0 }, { chips = '+', StatusText = true })
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.9,
          func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true
          end
        }))
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 },
          { level = '+' .. card.ability.extra.levels })
        delay(1.3)
        for k, v in pairs(G.GAME.hands) do
          level_up_hand(card, k, true, card.ability.extra.levels)
        end
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
          { mult = 0, chips = 0, handname = '', level = '' })
        return true
      end
    }))
  end,
  remove_from_deck = function(self, card, from_debuff)
    G.E_MANAGER:add_event(Event({
      func = function()
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3 },
          { handname = localize('k_all_hands'), chips = '...', mult = '...', level = '' })
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.2,
          func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true
          end
        }))
        update_hand_text({ delay = 0 }, { mult = '-', StatusText = true })
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.9,
          func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            return true
          end
        }))
        update_hand_text({ delay = 0 }, { chips = '-', StatusText = true })
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.9,
          func = function()
            play_sound('tarot1')
            card:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true
          end
        }))
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 },
          { level = '-' .. card.ability.extra.levels })
        delay(1.3)
        for k, v in pairs(G.GAME.hands) do
          level_up_hand(card, k, true, -card.ability.extra.levels)
        end
        update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
          { mult = 0, chips = 0, handname = '', level = '' })
        return true
      end
    }))
  end
}

SMODS.Joker {
  key = 'bottle',
  config = { extra = { is_contestant = true, given_xmult = 2 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 6, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  bfdi_shatters = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card.ability.name == 'Glass Card' then
      return {
        xmult = card.ability.extra.given_xmult,
        card = card
      }
    end
  end,
  enhancement_gate = "m_glass"
}

SMODS.Joker {
  key = 'bracelety',
  config = { extra = { is_contestant = true, xmult = 3, quipped = false } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 7, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult, localize(G.GAME.current_round.bracelety_card.rank, 'ranks') } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not card.ability.extra.quipped and context.other_card:get_id() == G.GAME.current_round.bracelety_card.id then
      card.ability.extra.quipped = true
      return {
        message = localize { type = 'variable', key = 'bfdi_i_love', vars = { localize(G.GAME.current_round.bracelety_card.rank, 'ranks') } },
        colour = G.C.GREEN,
        card = card
      }
    end

    if context.joker_main then
      card.ability.extra.quipped = false
      local wanted_rank = false
      for i = 1, #context.scoring_hand do
        if context.scoring_hand[i]:get_id() == G.GAME.current_round.bracelety_card.id then wanted_rank = true end
      end
      if wanted_rank then
        return { xmult = card.ability.extra.xmult }
      end
    end
  end
}

SMODS.Joker {
  key = 'cake',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 1 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.before and G.GAME.current_round.hands_played == 2 then
      return {
        message = localize('k_level_up_ex'),
        card = card,
        level_up = true
      }
    end

    if context.after and G.GAME.current_round.hands_played == 1 then
      local eval = function() return G.GAME.current_round.hands_played == 1 end
      juice_card_until(card, eval, true)
    end
  end
}

SMODS.Joker {
  key = 'clock',
  config = { extra = { is_contestant = true, xmult = 3, current_antes = 0, antes_required = 2 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 1, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return {
      vars = { card.ability.extra.xmult, card.ability.extra.antes_required,
        (card.ability.extra.current_antes < card.ability.extra.antes_required)
        and (card.ability.extra.current_antes .. '/' .. card.ability.extra.antes_required) or localize('bfdi_active') }
    }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.end_of_round and G.GAME.last_blind and G.GAME.last_blind.boss and not context.individual and not context.repetition and not context.blueprint then
      card.ability.extra.current_antes = card.ability.extra.current_antes + 1
      if card.ability.extra.current_antes <= card.ability.extra.antes_required then
        return {
          message = (card.ability.extra.current_antes < card.ability.extra.antes_required) and
              (card.ability.extra.current_antes .. '/' .. card.ability.extra.antes_required) or localize('k_active_ex'),
          colour = G.C.FILTER
        }
      end
    end

    if context.joker_main and card.ability.extra.current_antes >= card.ability.extra.antes_required then
      return { xmult = card.ability.extra.xmult }
    end
  end
}

SMODS.Joker {
  key = 'cloudy',
  config = { extra = { is_contestant = true, added_xmult = 0.2, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 2, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return {
        xmult = card.ability.extra
            .current_xmult
      }
    end

    if context.before and not context.blueprint then
      local found_no_enhancement = false
      for i = 1, #G.hand.cards do
        if not next(SMODS.get_enhancements(G.hand.cards[i])) then found_no_enhancement = true end
      end

      if not found_no_enhancement then
        card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
        return { message = localize("k_upgrade_ex"), colour = G.C.FILTER, card = card }
      end
    end
  end
}

SMODS.Joker {
  key = 'eggy',
  config = { extra = { is_contestant = true, target_rounding = 8 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 3, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.target_rounding, G.GAME.dollars + card.ability.extra.target_rounding - (G.GAME.dollars % card.ability.extra.target_rounding) } }
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.end_of_round and not context.repetition and not context.repetition_only and not context.blueprint then
      return { dollars = card.ability.extra.target_rounding - (G.GAME.dollars % card.ability.extra.target_rounding) }
    end
  end
}

SMODS.Joker {
  key = 'fanny',
  config = { extra = { is_contestant = true, xmult = 2, quipped = false } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult, localize(G.GAME.current_round.fanny_card.rank, 'ranks') } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and not card.ability.extra.quipped and context.other_card:get_id() == G.GAME.current_round.fanny_card.id then
      card.ability.extra.quipped = true
      return {
        message = localize { type = 'variable', key = 'bfdi_i_hate', vars = { localize(G.GAME.current_round.fanny_card.rank, 'ranks') } },
        colour =
            G.C.RED,
        card = card
      }
    end

    if context.joker_main then
      card.ability.extra.quipped = false
      local banned_rank = false
      for i = 1, #context.scoring_hand do
        if context.scoring_hand[i]:get_id() == G.GAME.current_round.fanny_card.id then banned_rank = true end
      end
      if not banned_rank then
        return { xmult = card.ability.extra.xmult }
      end
    end
  end
}

SMODS.Joker {
  key = 'fireyjr',
  config = { extra = { is_contestant = true, ace_detected = false } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 5, y = 1 },
  display_size = { w = 0.75 * 71, h = 0.75 * 95 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card:get_id() == 14 then
      card.ability.extra.ace_detected = true
    end

    if context.individual and context.cardarea == G.hand and not context.end_of_round and card.ability.extra.ace_detected then
      local temp_ID = 15
      local fireyjr_card = nil
      for i = 1, #G.hand.cards do
        if not SMODS.has_no_rank(G.hand.cards[i]) and temp_ID >= G.hand.cards[i]:get_id() then
          temp_ID = G.hand.cards[i]:get_id()
          fireyjr_card = G.hand.cards[i]
        end
      end

      if context.other_card == fireyjr_card then
        card.ability.extra.ace_detected = false
        context.other_card.fireyjr_marked_for_death = true
      end
    end

    if context.destroy_card and context.cardarea == G.hand and context.destroy_card.fireyjr_marked_for_death then
      context.destroy_card.fireyjr_marked_for_death = false
      return true
    end
  end
}

SMODS.Joker {
  key = 'foldy',
  config = { extra = { is_contestant = true, added_mult = 5, current_mult = 0, scored_cards = 0, scored_card_target = 12 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 6, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.scored_card_target, card.ability.extra.scored_card_target - card.ability.extra.scored_cards, card.ability.extra.current_mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
      card.ability.extra.scored_cards = card.ability.extra.scored_cards + 1
      if card.ability.extra.scored_cards >= card.ability.extra.scored_card_target then
        card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
        card.ability.extra.scored_cards = 0
        return { message = localize("k_upgrade_ex"), colour = G.C.FILTER, card = card }
      end
    end

    if context.joker_main and card.ability.extra.current_mult > 0 then return { mult = card.ability.extra.current_mult } end
  end
}

SMODS.Joker {
  key = 'gaty',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 7, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
    return {}
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.jokers and context.before and G.GAME.current_round.hands_left == 0 then
      G.E_MANAGER:add_event(Event({
        func = function()
          context.full_hand[1]:set_edition('e_polychrome', true, true)
          context.full_hand[1]:juice_up()
          return true
        end
      }))
      return { message = localize("created_polychrome"), colour = G.C.FILTER, card = card }
    end
  end
}

SMODS.Joker {
  key = 'grassy',
  config = { extra = { is_contestant = true, xmult_per_full_house = 0.2 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult_per_full_house, 1 + to_number(G.GAME.hands["Full House"].level * card.ability.extra.xmult_per_full_house) } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      local xmult = 1 + to_number(G.GAME.hands["Full House"].level * card.ability.extra.xmult_per_full_house)
      if xmult > 1 then
        return { xmult = xmult }
      end
    end
  end
}

SMODS.Joker {
  key = 'lightning',
  config = { extra = { is_contestant = true, triggered = false } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 1, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.discard and #context.full_hand == 1 then
      for i = 1, #G.hand.cards do
        if G.hand.cards[i].ability.name == 'Gold Card' then
          card:juice_up()
          return { remove = true }
        end
      end
    end
  end,
  enhancement_gate = "m_gold"
}

SMODS.Joker {
  key = 'liy',
  config = { extra = { is_contestant = true, given_xmult = 2, active = false } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 2, y = 2 },
  super_pos = { x = 2, y = 6 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult, card.ability.extra.active and localize("bfdi_active") or localize("bfdi_inactive") } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.active then
      return { xmult = card.ability.extra.given_xmult }
    end

    if context.selling_card and context.card.config.center.set ~= "Joker" and not card.ability.extra.active and not context.blueprint then
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          card:flip(); play_sound('card1', 1); card:juice_up(0.3, 0.3); return true
        end
      }))
      delay(0.2)
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          card.ability.extra.active = true
          card.children.center:set_sprite_pos(self.super_pos)
          return true
        end
      }))
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          card:flip()
          play_sound('tarot2', 1, 0.6)
          local eval = function() return context.before end
          juice_card_until(card, eval, true)
          return true
        end
      }))
      return { message = localize("k_active_ex"), colour = G.C.BLUE, message_card = card }
    end

    if context.cardarea == G.jokers and context.after and not context.blueprint then
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          card:flip(); play_sound('card1', 1); card:juice_up(0.3, 0.3); return true
        end
      }))
      delay(0.2)
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          card.ability.extra.active = false
          card.children.center:set_sprite_pos(self.pos)
          return true
        end
      }))
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          card:flip()
          play_sound('tarot2', 1, 0.6)
          return true
        end
      }))
    end
  end,
  set_sprites = function(self, card, front)
    if not self.discovered and not card.params.bypass_discovery_center then
      return
    end
    if card and card.children and card.children.center and card.children.center.set_sprite_pos and card.ability and card.ability.extra and card.ability.extra.active then
      card.children.center:set_sprite_pos(self.super_pos)
    else
      card.children.center:set_sprite_pos(self.pos)
    end
  end
}

SMODS.Joker {
  key = 'lollipop',
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 3, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then return { mult = card.ability.extra.current_mult } end

    if context.selling_card and context.card.config.center.consumeable and not context.blueprint then
      card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
      return { message = localize('k_upgrade_ex'), colour = G.C.FILTER, card = card }
    end
  end
}

SMODS.Joker {
  key = 'loser',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 2 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  in_pool = function()
    return not next(SMODS.find_mod('NotJustYet')) -- If you have NotJustYet, this Joker is useless.
  end
}

SMODS.Joker {
  key = 'marker',
  config = { extra = { is_contestant = true, counted_rerolls = 0 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 5, y = 2 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.reroll_shop then
      if not context.blueprint then card.ability.extra.counted_rerolls = card.ability.extra.counted_rerolls + 1 end
      if card.ability.extra.counted_rerolls < 3 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        local rerolls = card.ability.extra.counted_rerolls
        return {
          extra = {
            focus = card,
            message = localize(rerolls == 1 and 'k_plus_tarot' or 'k_plus_planet'),
            func = function()
              G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                  play_sound("timpani")
                  local new_card = create_card(rerolls == 1 and "Tarot" or "Planet", G.consumables, nil, nil, nil, nil,
                    nil, "marker")
                  new_card:add_to_deck()
                  G.consumeables:emplace(new_card)
                  G.GAME.consumeable_buffer = 0
                  new_card:juice_up(0.3, 0.5)
                  return true
                end
              }))
            end
          },
          colour = rerolls == 1 and G.C.SECONDARY_SET.Tarot or G.C.SECONDARY_SET.Planet,
          card = card
        }
      end
    end

    if context.ending_shop and not context.blueprint then
      card.ability.extra.counted_rerolls = 0
    end
  end,
  add_to_deck = function(self, card, from_debuff)
    if not G.PROFILES[G.SETTINGS.profile].bfdi_marker_no_of_encounters then G.PROFILES[G.SETTINGS.profile].bfdi_marker_no_of_encounters = 0 end
    G.PROFILES[G.SETTINGS.profile].bfdi_marker_no_of_encounters = G.PROFILES[G.SETTINGS.profile]
        .bfdi_marker_no_of_encounters + 1
    G:save_settings()
  end,
  set_sprites = function(self, card, front)
    local no_encounters = G.PROFILES[G.SETTINGS.profile].bfdi_marker_no_of_encounters
    if no_encounters and no_encounters >= 3 then
      card.children.center:set_sprite_pos({
        x = 1,
        y = 6
      })
    end
  end
}

SMODS.Joker {
  key = 'naily',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 6, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = "Other", key = "bfdi_naily_seal", vars = {} }
    return {}
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.first_hand_drawn then
      local eval = function() return G.GAME.current_round.hands_played == 0 end
      juice_card_until(card, eval, true)
    end

    if context.cardarea == G.jokers and context.before and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 then
      G.E_MANAGER:add_event(Event({
        func = function()
          context.full_hand[1]:set_seal("bfdi_naily")
          context.full_hand[1]:juice_up()
          return true
        end
      }))
      return { message = "Naily Seal", colour = G.C.FILTER, card = card }
    end
  end
}

SMODS.Joker {
  key = 'pie',
  config = { extra = { xmult = 1.5, is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 7, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card.seal and not context.repetition then
      return { xmult = card.ability.extra.xmult }
    end
  end,
  in_pool = function()
    for _, v in ipairs(G.playing_cards) do
      if v.seal then return true end
    end
    return false
  end
}

SMODS.Joker {
  key = 'pillow',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_TAGS.tag_phanta_contestant
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if G.GAME.blind and context.selling_card and context.card.config.center.rarity == 1 then
      G.E_MANAGER:add_event(Event({
        func = (function()
          add_tag(Tag('tag_bfdi_contestant'))
          play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
          play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
          card:juice_up()
          return true
        end)
      }))
      return { message = localize('created_contestant_tag'), colour = G.C.FILTER, card = card }
    end
  end
}

SMODS.Joker {
  key = 'remote',
  config = { extra = { is_contestant = true, gained_chips = 10, bfj_mechanical_mind = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 1, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.gained_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.discard and context.other_card:get_id() <= 10 and
        context.other_card:get_id() >= 0 and
        context.other_card:get_id() % 2 == 0 then
      context.other_card.ability.perma_bonus = (context.other_card.ability.perma_bonus or 0) + card.ability.extra.gained_chips
      return { message = localize('k_upgrade_ex'), colour = G.C.CHIPS }
    end
  end
}

SMODS.Joker {
  key = 'robotflower',
  config = { extra = { is_contestant = true, given_chips = 101, bfj_mechanical_mind = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 2, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
    return { vars = { card.ability.extra.given_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and (context.cardarea == G.play or (context.cardarea == G.hand and not context.end_of_round)) and context.other_card.ability.name == 'Steel Card' then
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
  end,
  enhancement_gate = "m_steel"
}

SMODS.Joker {
  key = 'roboty',
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0, bfj_mechanical_mind = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 3, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.current_mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then
      return { mult = card.ability.extra.current_mult }
    end

    if context.individual and context.cardarea == G.play and context.other_card:get_id() == 10 and not context.blueprint then
      card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
      return { message = localize('k_upgrade_ex'), colour = G.C.FILTER, card = card }
    end
  end
}

SMODS.Joker {
  key = 'saw',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 3 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.before then
      contains_eight = false
      for _, v in ipairs(context.scoring_hand) do
        if not SMODS.has_no_rank(v) and v:get_id() == 8 then contains_eight = true end
      end

      if contains_eight then context.scoring_hand[#context.scoring_hand].bfdi_saw_marked_for_death = true end
    end

    if context.destroying_card and context.destroying_card.bfdi_saw_marked_for_death then
      return { remove = true }
    end
  end
}

SMODS.Joker {
  key = 'stapy',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 5, y = 3 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.evaluate_poker_hand and context.scoring_name == "High Card" then
      return { replace_scoring_name = "Pair" }
    end
    if context.evaluate_poker_hand and context.scoring_name == "Three of a Kind" then
      return { replace_scoring_name = "Four of a Kind" }
    end
  end
}

SMODS.Joker {
  key = 'taco',
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0, required_suits = 4 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 6, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_mult, card.ability.extra.current_mult, card.ability.extra.required_suits } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_mult > 0 then
      return { mult = card.ability.extra.current_mult }
    end

    if not context.blueprint and context.pre_discard then card.ability.extra.active = true end

    if not context.blueprint and context.hand_drawn and card.ability.extra.active then
      card.ability.extra.active = false

      local detected_suits = {}
      local wilds = 0
      for i = 1, #G.hand.cards do
        if G.hand.cards[i].ability.name ~= 'Wild Card' and not SMODS.has_no_suit(G.hand.cards[i]) then
          local is_new = true
          local current_suit = G.hand.cards[i].base.suit
          for _, suit in ipairs(detected_suits) do
            if suit == current_suit then is_new = false end
          end
          if is_new then detected_suits[#detected_suits + 1] = current_suit end
        end
      end

      for i = 1, #G.hand.cards do if G.hand.cards[i].ability.name == 'Wild Card' then wilds = wilds + 1 end end

      if #detected_suits + wilds >= card.ability.extra.required_suits then
        card.ability.extra.current_mult = card.ability.extra.current_mult + card.ability.extra.added_mult
        return { message = localize('k_upgrade_ex'), colour = G.C.FILTER, card = card }
      end
    end
  end
}

SMODS.Joker {
  key = 'tree',
  config = { extra = { is_contestant = true, added_chips = 7, current_chips = 0 } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 7, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_chips, card.ability.extra.current_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_chips > 0 then
      return { chips = card.ability.extra.current_chips }
    end

    if context.cardarea == G.jokers and context.end_of_round and G.GAME.current_round.discards_left > 0 and not context.repetition and not context.repetition_only and not context.blueprint then
      card.ability.extra.current_chips = card.ability.extra.current_chips +
          (card.ability.extra.added_chips * G.GAME.current_round.discards_left)
      return { message = localize('k_upgrade_ex'), colour = G.C.FILTER, card = card }
    end
  end
}

SMODS.Joker {
  key = 'tv',
  config = { extra = { is_contestant = true, given_xmult = 1.5, bfj_mechanical_mind = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 4 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = "Other", key = "contestant_joker" }
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.other_joker and context.other_joker.ability and context.other_joker.ability.extra and type(context.other_joker.ability.extra) == "table" and context.other_joker.ability.extra.is_contestant and card ~= context.other_joker then
      G.E_MANAGER:add_event(Event({
        func = function()
          context.other_joker:juice_up(0.5, 0.5)
          return true
        end
      }))
      return { xmult = card.ability.extra.given_xmult }
    end
  end,
  set_sprites = function(self, card, front)
    if not self.discovered and not card.params.bypass_discovery_center then
      return
    end
    local c = card or {}
    c.ability = c.ability or {}
    c.ability.tv_x = c.ability.tv_x or pseudorandom(pseudoseed("tvx"), 0, 7)
    if card and card.children and card.children.center and card.children.center.set_sprite_pos then
      card.children.center:set_sprite_pos({
        x = c.ability.tv_x,
        y = c.config.center.pos.y
      })
    end
  end
}

SMODS.Joker {
  key = 'pricetag',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 5 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_TAGS.tag_voucher
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and G.GAME.last_blind and G.GAME.last_blind.boss then
      G.E_MANAGER:add_event(Event({
        func = (function()
          add_tag(Tag('tag_voucher'))
          play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
          play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
          card:juice_up()
          return true
        end)
      }))
      return { message = localize('created_voucher_tag'), colour = G.C.RED, card = card }
    end
  end,
  set_sprites = function(self, card, front)
    if not self.discovered and not card.params.bypass_discovery_center then
      return
    end
    local c = card or {}
    c.ability = c.ability or {}
    c.ability.price_tag_x = c.ability.price_tag_x or pseudorandom(pseudoseed("pricetagx"), 0, 7)
    if card and card.children and card.children.center and card.children.center.set_sprite_pos then
      card.children.center:set_sprite_pos({
        x = c.ability.price_tag_x,
        y = c.config.center.pos.y
      })
    end
  end
}

SMODS.Joker {
  key = 'winner',
  config = { extra = { added_xmult = 0.25, current_xmult = 1, is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 0, y = 6 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then return { xmult = card.ability.extra.current_xmult } end

    if context.before and G.GAME.current_round.hands_left == 0 then
      card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
      return { message = localize("k_upgrade_ex"), colour = G.C.FILTER }
    end
  end
}
