SMODS.Atlas {
  key = "BFB-TPoT",
  path = "BFB-TPoT.png",
  px = 71,
  py = 95
}

to_big = to_big or function(x) return x end

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
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'bottle',
  config = { extra = { is_contestant = true, given_xmult = 1.5 } },
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
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'fanny',
  config = { extra = { is_contestant = true, given_xmult = 3, quipped = false } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult, localize(G.GAME.current_round.fanny_card.rank, 'ranks') } }
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
        return { xmult = card.ability.extra.given_xmult }
      end
    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
    if context.destroy_card and not context.blueprint and context.cardarea == G.play and context.destroying_card.ability.name == 'Gold Card' then
      card.ability.extra.triggered = true
      return { remove = true }
    end

    if context.remove_playing_cards and card.ability.extra.triggered then
      card.ability.extra.triggered = false
      G.E_MANAGER:add_event(Event({
        func = function()
          local _card = create_playing_card(
            { front = pseudorandom_element(G.P_CARDS, pseudoseed('lightningra')), center = G.P_CENTERS.m_gold }, G.hand,
            nil,
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

--[[
SMODS.Joker {
  key = 'loser',
  config = { extra = { added_xmult = 0.25, current_xmult = 1, is_contestant = true } },
  rarity = 2,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 2 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
	blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if G.GAME.current_round.hands_left ~= 0 then

    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges+1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}
]] --

SMODS.Joker {
  key = 'roboty',
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0 } },
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'tree',
  config = { extra = { is_contestant = true, added_chips = 6, current_chips = 0 } },
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
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}

SMODS.Joker {
  key = 'tv',
  config = { extra = { given_xmult = 1.5, is_contestant = true } },
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
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
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
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return {
        xmult = card.ability.extra
            .current_xmult
      }
    end

    if context.before and G.GAME.current_round.hands_left == 0 then
      card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
      return { message = localize("k_upgrade_ex"), colour = G.C.FILTER }
    end
  end,
  set_badges = function(self, card, badges)
    badges[#badges + 1] = create_badge(localize('contestant_joker_badge'), G.C.BFDI.MISC_COLOURS.BFDI_GREEN, G.C.WHITE, 1)
  end
}
