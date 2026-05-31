SMODS.Atlas {
  key = "WinTokens",
  path = "BFDIWinTokens.png",
  px = 71,
  py = 95
}

SMODS.ConsumableType {
  key = "bfdi_Token",
  primary_colour = HEX("2AAB39"),
  secondary_colour = HEX("2A784D"),
  collection_rows = { 4, 4 },
  shop_rate = 0,
  cost = 4,
  default = "bfdi_token_yellow",
  can_stack = true,
  can_divide = true
}

SMODS.UndiscoveredSprite {
  key = "bfdi_Token",
  atlas = "WinTokens",
  pos = { x = 0, y = 4 },
  pixel_size = { w = 71, h = 67 },
  no_overlay = true
}

G.bfdi_drained_token_extra_anim = { charged = { anim = { { x = 4, y = 4, t = 1 } } }, drained = { anim = { { x = 1, y = 4, t = 3 }, { xrange = { first = 2, last = 3 }, y = 4, t = 0.15 }, { x = 2, y = 4, t = 0.15 } } } }
G.bfdi_token_set_sprites = function(self, card, front)
  if not card.ability or not card.ability.extra then return end
  if card.ability.extra.is_charged then
    card.children.center:set_sprite_pos(self.pos)
    card:flipbook_set_anim_extra_state("charged")
  else
    card.children.center:set_sprite_pos(self.disabled_pos)
    card:flipbook_set_anim_extra_state("drained")
  end
end

function bfdi_drain_token(card)
  card:juice_up(0.3, 0.5)
  card.children.center:set_sprite_pos(card.config.center.disabled_pos)
  card:flipbook_set_anim_extra_state("drained")
  card.ability.extra.is_charged = false
end

function bfdi_recharge_token(card)
  if card.config.center.bfdi_recharge then card.config.center.bfdi_recharge(card) end
  G.E_MANAGER:add_event(Event({
    trigger = 'after',
    delay = 0.4,
    func = function()
      play_sound("coin7", 1.2, 0.8)
      play_sound("chips1", 1.2, 0.8)
      play_sound("chips2", 1.2, 0.8)
      card:flipbook_set_anim_extra_state("charged")
      card.children.center:set_sprite_pos(card.config.center.pos)
      card.ability.extra.is_charged = true
      return true
    end
  }))
  card_eval_status_text(card, "extra", nil, nil, nil, { message = localize("k_bfdi_charged_ex") })
end

-- Thanks, YMA from Cold Beans!
function bfdi_reduce_blind_requirement(mod_add)
  if not G.GAME.blind.original_chips then G.GAME.blind.original_chips = G.GAME.blind.chips end
  local original_chips = G.GAME.blind.original_chips > 0 and G.GAME.blind.original_chips or G.GAME.blind.chips
  mod_add = mod_add or 0
  mod_add = -math.ceil(G.GAME.blind.chips * mod_add / 100)

  local current_mult = G.GAME.blind.chips / (original_chips / G.GAME.blind.mult)
  local final_chips = (original_chips / G.GAME.blind.mult) * (current_mult) + mod_add
  local chip_mod
  if type(G.GAME.blind.chips) ~= 'table' then
    chip_mod = math.ceil(math.abs(final_chips - G.GAME.blind.chips) / 120)
  else
    chip_mod = ((final_chips - G.GAME.blind.chips):abs() / 120):ceil()
  end
  local step = 0
  if G.GAME.blind.chips < final_chips then
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      blocking = true,
      func = function()
        G.GAME.blind.chips = G.GAME.blind.chips + G.SETTINGS.GAMESPEED * chip_mod
        if G.GAME.blind.chips < final_chips then
          G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
          if step % 5 == 0 then
            play_sound('chips1', 0.8 + (step * 0.005))
          end
          step = step + 1
        else
          G.GAME.blind.chips = final_chips
          G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
          G.GAME.blind:wiggle()
          return true
        end
      end
    }))
  else
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      blocking = true,
      func = function()
        G.GAME.blind.chips = G.GAME.blind.chips - G.SETTINGS.GAMESPEED * chip_mod
        if G.GAME.blind.chips > final_chips then
          G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
          if step % 5 == 0 then
            play_sound('chips1', 0.8 + (step * 0.005))
          end
          step = step - 1
        else
          G.GAME.blind.chips = final_chips
          G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
          G.GAME.blind:wiggle()
          return true
        end
      end
    }))
  end
end

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_win",
  pos = { x = 0, y = 0 },
  disabled_pos = { x = 4, y = 0 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, current_hcs = 0, target_hcs = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.target_hcs, card.ability.extra.target_hcs - card.ability.extra.current_hcs } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.GAME.blind and G.GAME.blind.in_blind
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound("timpani")
        bfdi_reduce_blind_requirement(50)

        bfdi_drain_token(card)
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.before and context.scoring_name == "High Card" and not card.ability.extra.is_charged then
      card.ability.extra.current_hcs = card.ability.extra.current_hcs + 1
      if card.ability.extra.current_hcs >= card.ability.extra.target_hcs then
        bfdi_recharge_token(card)
      else
        return { message = "" .. card.ability.extra.current_hcs .. "/" .. card.ability.extra.target_hcs }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_hcs = 0
  end,
  keep_on_use = function(self, card) return true end
}



SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_swap",
  pos = { x = 1, y = 0 },
  disabled_pos = { x = 5, y = 0 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, cards_scored = 5 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.cards_scored } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.GAME.current_round.discards_left >= 1 and G.GAME.blind and G.GAME.blind.in_blind
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound("timpani")
        local hands = G.GAME.current_round.hands_left
        local discards = G.GAME.current_round.discards_left
        if hands == discards then
          play_sound("bfdi_yellow_face", 1, 0.5)
        else
          ease_hands_played(discards - hands)
          ease_discard(hands - discards)
        end

        bfdi_drain_token(card)
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.before and #context.scoring_hand >= 5 and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}




SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_disbandment",
  pos = { x = 2, y = 0 },
  disabled_pos = { x = 6, y = 0 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, max_highlighted = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.max_highlighted } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.max_highlighted
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound('tarot1')
        bfdi_drain_token(card)
        return true
      end
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      func = function()
        SMODS.destroy_cards(G.hand.highlighted)
        return true
      end
    }))
    delay(0.3)
  end,
  calculate = function(self, card, context)
    if context.playing_card_added and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_postpone",
  pos = { x = 3, y = 0 },
  disabled_pos = { x = 7, y = 0 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, hands = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.hands } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.GAME.blind and G.GAME.blind.in_blind
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound('timpani')
        ease_hands_played(card.ability.extra.hands)
        bfdi_drain_token(card)
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.before and G.GAME.current_round.hands_left == 0 and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}



SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_gratitude",
  pos = { x = 0, y = 1 },
  disabled_pos = { x = 4, y = 1 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, money_lost = 10, current_earned = 0, target_earned = 25 } },
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_TAGS.tag_investment
    return { vars = { card.ability.extra.money_lost, card.ability.extra.target_earned, card.ability.extra.target_earned - card.ability.extra.current_earned } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      func = (function()
        add_tag(Tag('tag_investment'))
        play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
        card:juice_up(0.3, 0.5)
        return true
      end)
    }))
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        ease_dollars(-card.ability.extra.money_lost)
        bfdi_drain_token(card)
        return true
      end
    }))
    delay(0.5)
  end,
  calculate = function(self, card, context)
    if context.bfdi_money_earned and not card.ability.extra.is_charged and not card.getting_sliced then
      card.ability.extra.current_earned = card.ability.extra.current_earned + context.bfdi_money_earned
      if card.ability.extra.current_earned >= card.ability.extra.target_earned then
        bfdi_recharge_token(card)
      else
        return { message = "$" .. card.ability.extra.current_earned .. "/$" .. card.ability.extra.target_earned }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_earned = 0
  end,
  keep_on_use = function(self, card) return true end
}



function is_boss_active()
  return G and G.GAME and G.GAME.blind and ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
end

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_immunity",
  pos = { x = 1, y = 1 },
  disabled_pos = { x = 5, y = 1 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, money_limit = 5 } },
  loc_vars = function(self, info_queue, card)
    return {
      vars = { card.ability.extra.money_limit },
      main_end = { { n = G.UIT.C, config = { align = "bm", minh = 0.4 }, nodes = { { n = G.UIT.C, config = { ref_table = self, align = "m", colour = is_boss_active() and G.C.GREEN or G.C.RED, r = 0.05, padding = 0.06 }, nodes = { { n = G.UIT.T, config = { text = ' ' .. localize(is_boss_active() and 'k_active' or 'ph_no_boss_active') .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.9 } } } } } } }
    }
  end,
  can_use = function(self, card)
    return is_boss_active() and card.ability.extra.is_charged
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        if is_boss_active() then
          play_sound("timpani")
          G.GAME.blind:disable()
          bfdi_drain_token(card)
        end
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.bfdi_money_spent and context.bfdi_money_spent < card.ability.extra.money_limit and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}

local ease_dollars_ref = ease_dollars
function ease_dollars(mod, instant)
  local total_money = G.GAME.dollars + mod
  ease_dollars_ref(mod, instant)
  if mod < 0 then
    SMODS.calculate_context({ bfdi_money_spent = total_money })
  else
    SMODS.calculate_context({ bfdi_money_earned = mod })
  end
end

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_yellow",
  pos = { x = 2, y = 1 },
  disabled_pos = { x = 6, y = 1 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, current_jokers = 0, target_jokers = 2, max_highlighted = 1 } },
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
    return { vars = { card.ability.extra.max_highlighted, card.ability.extra.target_jokers, card.ability.extra.target_jokers - card.ability.extra.current_jokers } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.max_highlighted
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound('tarot1')
        bfdi_drain_token(card)
        return true
      end
    }))
    for i = 1, #G.hand.highlighted do
      local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          G.hand.highlighted[i]:flip()
          play_sound('card1', percent)
          G.hand.highlighted[i]:juice_up(0.3, 0.3)
          return true
        end
      }))
    end
    delay(0.2)
    for i = 1, #G.hand.highlighted do
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          G.hand.highlighted[i]:set_ability("m_gold")
          return true
        end
      }))
    end
    for i = 1, #G.hand.highlighted do
      local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          G.hand.highlighted[i]:flip()
          play_sound('tarot2', percent, 0.6)
          G.hand.highlighted[i]:juice_up(0.3, 0.3)
          return true
        end
      }))
    end
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      func = function()
        G.hand:unhighlight_all()
        return true
      end
    }))
    delay(0.5)
  end,
  calculate = function(self, card, context)
    if context.selling_card and context.card ~= card and context.card.config.center.set == "Joker" and not card.ability.extra.is_charged then
      card.ability.extra.current_jokers = card.ability.extra.current_jokers + 1
      if card.ability.extra.current_jokers >= card.ability.extra.target_jokers then
        bfdi_recharge_token(card)
      else
        return { message = card.ability.extra.current_jokers .. "/" .. card.ability.extra.target_jokers }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_jokers = 0
  end,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_yoyle",
  pos = { x = 3, y = 1 },
  disabled_pos = { x = 7, y = 1 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, current_consumables = 0, target_consumables = 3, max_highlighted = 1 } },
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
    return { vars = { card.ability.extra.max_highlighted, card.ability.extra.target_consumables, card.ability.extra.target_consumables - card.ability.extra.current_consumables } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.max_highlighted
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound('tarot1')
        bfdi_drain_token(card)
        return true
      end
    }))
    for i = 1, #G.hand.highlighted do
      local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          G.hand.highlighted[i]:flip()
          play_sound('card1', percent)
          G.hand.highlighted[i]:juice_up(0.3, 0.3)
          return true
        end
      }))
    end
    delay(0.2)
    for i = 1, #G.hand.highlighted do
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          G.hand.highlighted[i]:set_ability("m_steel")
          play_sound("bfdi_yoylecake", 1, 0.5)
          return true
        end
      }))
    end
    for i = 1, #G.hand.highlighted do
      local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          G.hand.highlighted[i]:flip()
          play_sound('tarot2', percent, 0.6)
          G.hand.highlighted[i]:juice_up(0.3, 0.3)
          return true
        end
      }))
    end
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      func = function()
        G.hand:unhighlight_all()
        return true
      end
    }))
    delay(0.5)
  end,
  calculate = function(self, card, context)
    if context.selling_card and context.card ~= card and context.card.ability.consumeable and not card.ability.extra.is_charged then
      card.ability.extra.current_consumables = card.ability.extra.current_consumables + 1
      if card.ability.extra.current_consumables >= card.ability.extra.target_consumables then
        bfdi_recharge_token(card)
      else
        return { message = card.ability.extra.current_consumables .. "/" .. card.ability.extra.target_consumables }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_consumables = 0
  end,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_acquire",
  pos = { x = 0, y = 2 },
  disabled_pos = { x = 4, y = 2 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, current_discards = 0, target_discards = 20 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.target_discards, card.ability.extra.target_discards - card.ability.extra.current_discards } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.consumeables.config.card_limit > #G.consumeables.cards
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        if G.consumeables.config.card_limit > #G.consumeables.cards then
          play_sound("timpani")
          SMODS.add_card({ set = "Tarot", key_append = "bfdi_token_acquire" })
          bfdi_drain_token(card)
        end
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.discard and not card.ability.extra.is_charged then
      card.ability.extra.current_discards = card.ability.extra.current_discards + 1
      if card.ability.extra.current_discards >= card.ability.extra.target_discards then
        card.ability.extra.current_discards = 0
        card.ability.extra.is_charged = true -- Putting this here fixes it not being detected.
        bfdi_recharge_token(card)
      elseif context.other_card == context.full_hand[#context.full_hand] then
        return { message = card.ability.extra.current_discards .. "/" .. card.ability.extra.target_discards }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_discards = 0
  end,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_cooperation",
  pos = { x = 1, y = 2 },
  disabled_pos = { x = 5, y = 2 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, current_consumables = 0, target_consumables = 4, max_highlighted = 2, min_highlighted = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.max_highlighted, card.ability.extra.target_consumables, card.ability.extra.target_consumables - card.ability.extra.current_consumables } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.hand and G.hand.highlighted and #G.hand.highlighted >= card.ability.extra.min_highlighted and #G.hand.highlighted <= card.ability.extra.max_highlighted
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound('tarot1')
        bfdi_drain_token(card)
        return true
      end
    }))
    for i = 1, #G.hand.highlighted do
      local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          G.hand.highlighted[i]:flip()
          play_sound('card1', percent)
          G.hand.highlighted[i]:juice_up(0.3, 0.3)
          return true
        end
      }))
    end
    delay(0.2)
    local rightmost = G.hand.highlighted[1]
    for i = 1, #G.hand.highlighted do
      if G.hand.highlighted[i].T.x > rightmost.T.x then
        rightmost = G.hand.highlighted[i]
      end
    end
    for i = 1, #G.hand.highlighted do
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          if G.hand.highlighted[i] ~= rightmost then
            copy_card(rightmost, G.hand.highlighted[i])
          end
          return true
        end
      }))
    end
    for i = 1, #G.hand.highlighted do
      local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          G.hand.highlighted[i]:flip()
          play_sound('tarot2', percent, 0.6)
          G.hand.highlighted[i]:juice_up(0.3, 0.3)
          return true
        end
      }))
    end
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.2,
      func = function()
        G.hand:unhighlight_all()
        return true
      end
    }))
    delay(0.5)
  end,
  calculate = function(self, card, context)
    if context.using_consumeable and not card.ability.extra.is_charged then
      card.ability.extra.current_consumables = card.ability.extra.current_consumables + 1
      if card.ability.extra.current_consumables >= card.ability.extra.target_consumables then
        bfdi_recharge_token(card)
      else
        return { message = card.ability.extra.current_consumables .. "/" .. card.ability.extra.target_consumables }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_consumables = 0
  end,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_first",
  pos = { x = 2, y = 2 },
  disabled_pos = { x = 6, y = 2 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, sell_value = 2 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.sell_value } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.jokers.cards and #G.jokers.cards > 0
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        local other_card = G.jokers.cards[1]
        if other_card and other_card.set_cost then
          play_sound('timpani')
          other_card:juice_up()
          other_card.ability.extra_value = (other_card.ability.extra_value or 0) + card.ability.extra.sell_value
          other_card:set_cost()
        end
        bfdi_drain_token(card)
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.before and context.scoring_name and G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].order <= G.GAME.hands["Full House"].order and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_guess",
  pos = { x = 3, y = 2 },
  disabled_pos = { x = 7, y = 2 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, odds = 3, levels = 1 } },
  loc_vars = function(self, info_queue, card)
    local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "bfdi_token_guess")
    return { vars = { num, denom, card.ability.extra.levels } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged
  end,
  use = function(self, card, area, copier)
    if SMODS.pseudorandom_probability(card, 'bfdi_token_guess', 1, card.ability.extra.odds) then
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
          card.children.center:set_sprite_pos(self.disabled_pos)
          card:flipbook_set_anim_extra_state("drained")
          card.ability.extra.is_charged = false
          G.TAROT_INTERRUPT_PULSE = nil
          return true
        end
      }))
      update_hand_text({ sound = 'button', volume = 0.7, pitch = 0.9, delay = 0 }, { level = '+' .. card.ability.extra.levels })
      delay(1.3)
      SMODS.upgrade_poker_hands({ instant = true, level_up = card.ability.extra.levels })
      update_hand_text({ sound = 'button', volume = 0.7, pitch = 1.1, delay = 0 },
        { mult = 0, chips = 0, handname = '', level = '' })
    else
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
          attention_text({
            text = localize('k_nope_ex'),
            scale = 1.3,
            hold = 1.4,
            major = card,
            backdrop_colour = G.C.SECONDARY_SET.Tarot,
            align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
                'tm' or 'cm',
            offset = { x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0 },
            silent = true
          })
          G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.06 * G.SETTINGS.GAMESPEED,
            blockable = false,
            blocking = false,
            func = function()
              play_sound('tarot2', 0.76, 0.4)
              return true
            end
          }))
          play_sound('tarot2', 1, 0.4)
          bfdi_drain_token(card)
          return true
        end
      }))
    end
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and not context.game_over and G.GAME.current_round.discards_left > 0 and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_multi",
  pos = { x = 0, y = 3 },
  disabled_pos = { x = 4, y = 3 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, added_choices = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_choices } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.STATE == G.STATES.SMODS_BOOSTER_OPENED
  end,
  use = function(self, card, area, copier)
    if G.STATE == G.STATES.SMODS_BOOSTER_OPENED then
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
          play_sound("timpani")
          G.GAME.pack_choices = G.GAME.pack_choices + card.ability.extra.added_choices
          bfdi_drain_token(card)
          return true
        end
      }))
      delay(0.6)
    end
  end,
  calculate = function(self, card, context)
    if context.skipping_booster and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_preserve",
  pos = { x = 1, y = 3 },
  disabled_pos = { x = 5, y = 3 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, dollars = 8 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.dollars } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        play_sound("timpani")
        ease_dollars(card.ability.extra.dollars)

        for _, v in ipairs(G.consumeables.cards) do
          if v.config.center.set == "bfdi_Token" and v.ability and v.ability.extra and not v.ability.extra.is_charged and v.config.center.key ~= "c_bfdi_token_preserve" then
            bfdi_recharge_token(v)
          end
        end

        bfdi_drain_token(card)
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and not context.game_over and G.GAME.blind:get_type() == "Boss" and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_revenge",
  pos = { x = 2, y = 3 },
  disabled_pos = { x = 6, y = 3 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true, current_unscored = 0, target_unscored = 13, max_highlighted = 1 } },
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = "Other", key = "debuffed_playing_card" }
    info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
    return { vars = { card.ability.extra.max_highlighted, card.ability.extra.target_unscored, card.ability.extra.target_unscored - card.ability.extra.current_unscored } }
  end,
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.hand and G.hand.highlighted and #G.hand.highlighted > 0 and #G.hand.highlighted <= card.ability.extra.max_highlighted
  end,
  use = function(self, card, area, copier)
    local conv_card = G.hand.highlighted[1]
    G.E_MANAGER:add_event(Event({
      func = function()
        play_sound('tarot1')
        bfdi_drain_token(card)
        return true
      end
    }))

    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.1,
      func = function()
        conv_card:set_seal(SMODS.poll_seal({ key = "bfdi_token_revenge_seal", guaranteed = true }), nil, true)
        return true
      end
    }))

    delay(0.5)

    local _card = SMODS.create_card { set = "Enhanced", enhancement = "m_stone", area = G.discard, key_append = "bfdi_token_revenge_stone" }
    SMODS.debuff_card(_card, true, "bfdi_token_revenge")
    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
    _card.playing_card = G.playing_card
    table.insert(G.playing_cards, _card)

    G.E_MANAGER:add_event(Event({
      func = function()
        G.hand:unhighlight_all()

        G.hand:emplace(_card)
        _card:start_materialize()
        G.GAME.blind:debuff_card(_card)
        G.hand:sort()
        SMODS.calculate_context({ playing_card_added = true, cards = { _card } })
        save_run()
        return true
      end
    }))
  end,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == "unscored" and not card.ability.extra.is_charged then
      card.ability.extra.current_unscored = card.ability.extra.current_unscored + 1
      if card.ability.extra.current_unscored >= card.ability.extra.target_unscored then
        bfdi_recharge_token(card)
      else
        return { message = card.ability.extra.current_unscored .. "/" .. card.ability.extra.target_unscored, message_card = card }
      end
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  bfdi_recharge = function(card)
    card.ability.extra.current_unscored = 0
  end,
  keep_on_use = function(self, card) return true end
}

SMODS.Consumable {
  set = "bfdi_Token",
  key = "token_theft",
  pos = { x = 3, y = 3 },
  disabled_pos = { x = 7, y = 3 },
  flipbook_anim_extra_states = G.bfdi_drained_token_extra_anim,
  flipbook_anim_extra_initial_state = "charged",
  pixel_size = { w = 71, h = 67 },
  atlas = "WinTokens",
  config = { extra = { is_charged = true } },
  can_use = function(self, card)
    return card.ability.extra.is_charged and G.consumeables.config.card_limit > #G.consumeables.cards
  end,
  use = function(self, card, area, copier)
    G.E_MANAGER:add_event(Event({
      trigger = 'after',
      delay = 0.4,
      func = function()
        if G.consumeables.config.card_limit > #G.consumeables.cards then
          play_sound("timpani")
          SMODS.add_card({ set = "bfdi_Token", key_append = "bfdi_token_theft" })
          bfdi_drain_token(card)
        end
        return true
      end
    }))
    delay(0.6)
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and not context.game_over and not card.ability.extra.is_charged then
      bfdi_recharge_token(card)
    end
  end,
  set_sprites = G.bfdi_token_set_sprites,
  keep_on_use = function(self, card) return true end
}
