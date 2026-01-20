SMODS.Atlas {
  key = "BFDIE",
  path = "BFDIE.png",
  px = 71,
  py = 95
}

SMODS.Sound({
  key = "burst",
  path = "bfdi_burst.ogg"
})



SMODS.Joker {
  key = 'beachball',
  config = { extra = { is_contestant = true, given_xmult = 3 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 0, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = false,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      return { xmult = card.ability.extra.given_xmult }
    end

    if context.after and not context.blueprint then
      for _, v in ipairs(context.scoring_hand) do
        if not SMODS.has_enhancement(v, "m_wild") and v:is_suit("Spades") then
          G.E_MANAGER:add_event(Event({
            func = function()
              play_sound("bfdi_burst", 1, 0.5)
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
        end
      end
    end
  end
}

SMODS.Joker {
  key = 'fern',
  config = { extra = { is_contestant = true, given_money = 8, used_hands = 1, used_discards = 1 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 1, y = 0 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money, card.ability.extra.used_hands, card.ability.extra.used_discards } }
  end,
  calc_dollar_bonus = function(self, card)
    if G.GAME.current_round.hands_played == card.ability.extra.used_hands and G.GAME.current_round.discards_used == card.ability.extra.used_discards then
      return card.ability.extra.given_money
    end
  end
}

SMODS.Joker {
  key = 'hotdog',
  config = { extra = { is_contestant = true, added_xmult = 0.25, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 2, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_xmult > 1 then
      return { xmult = card.ability.extra.current_xmult }
    end

    if context.discard and #context.full_hand == 1 and G.GAME.blind and G.GAME.blind:get_type() == 'Boss' and not context.blueprint then
      card.ability.extra.current_xmult = card.ability.extra.current_xmult + card.ability.extra.added_xmult
      return { message = localize("k_upgrade_ex") }
    end
  end
}

SMODS.Joker {
  key = 'jammy',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 3, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    return {}
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.playing_card_added then
      for _, v in ipairs(context.cards) do v:set_ability("m_glass") end
      return { message = "Glass" }
    end
  end,
  bfdi_shatters = true
}

SMODS.Joker {
  key = 'money',
  config = { extra = { is_contestant = true, cards_required = 5, money = 1 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 4, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    return { vars = { card.ability.extra.cards_required, card.ability.extra.money } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and #context.scoring_hand >= card.ability.extra.cards_required then
      return { dollars = card.ability.extra.money }
    end
  end
}

SMODS.Joker {
  key = 'needy',
  config = { extra = { is_contestant = true, hands_per_tarot = 1, max_hands = 2 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 5, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.hands_per_tarot, card.ability.extra.max_hands } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.setting_blind and count_tarots() > 0 then
      local given_hands = math.min(card.ability.extra.hands_per_tarot * count_tarots(), 2)
      G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.5,
        func = function()
          ease_hands_played(given_hands, true)
          return true
        end
      }))
      return { message = localize { type = "variable", key = (given_hands == 1 and "a_hand" or "a_hands"), vars = { given_hands } }, colour = G.C.BLUE }
    end
  end,
  bfdi_shatters = true
}

SMODS.Joker {
  key = 'rose',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 6, y = 0 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.cardarea == G.play and context.repetition and G.GAME.current_round.discards_used <= 0 then
      return { repetitions = 1 }
    end
  end
}

SMODS.Joker {
  key = 'ruler',
  config = { extra = { is_contestant = true, mult = 15 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 7, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.other_joker and context.other_joker.ability and context.other_joker.ability.extra and type(context.other_joker.ability.extra) == "table" and context.other_joker.ability.extra.is_contestant and card ~= context.other_joker
        and next(get_straight(context.scoring_hand)) then
      return { mult = card.ability.extra.mult }
    end
  end
}

SMODS.Joker {
  key = 'sidewalky',
  config = { extra = { is_contestant = true, xmult = 0.2 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 0, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_stone

    local stone_tally = 0
    if G.playing_cards then
      for _, playing_card in ipairs(G.playing_cards) do
        if SMODS.has_enhancement(playing_card, 'm_stone') then stone_tally = stone_tally + 1 end
      end
    end
    return { vars = { card.ability.extra.xmult, 1 + (card.ability.extra.xmult * stone_tally) } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      local stone_tally = 0
      for _, playing_card in ipairs(G.playing_cards) do
        if SMODS.has_enhancement(playing_card, 'm_stone') then stone_tally = stone_tally + 1 end
      end
      return { xmult = 1 + (card.ability.extra.xmult * stone_tally) }
    end
  end,
  enhancement_gate = "m_stone"
}

SMODS.Joker {
  key = 'sticker',
  config = { extra = { is_contestant = true } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 1, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = "bfdi_stickersticker", set = "Other", vars = { } }
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.first_hand_drawn then
      local candidates = {}
      for i = 1, #G.hand.cards do
        if not (G.hand.cards[i].ability and G.hand.cards[i].ability.bfdi_stickersticker ~= nil) then
          candidates[#candidates + 1] = G.hand.cards[i]
        end
      end
      if #candidates > 0 then
        local chosen_card = pseudorandom_element(candidates, pseudoseed("bfdiesticker"))
        chosen_card:add_sticker("bfdi_stickersticker", true)
        play_sound("gold_seal", 1.5, 1)
        chosen_card:juice_up()
        card:juice_up()
        return { message = localize("bfdi_stickersticker", "labels"), colour = G.C.FILTER }
      end
    end
  end
}

SMODS.Joker {
  key = 'toothpaste',
  config = { extra = { is_contestant = true, added_chips = 20, current_chips = 0 } },
  rarity = 2,
  atlas = 'BFDIE',
  pos = { x = 2, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_chips, card.ability.extra.current_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
  calculate = function(self, card, context)
    if context.joker_main and card.ability.extra.current_chips > 0 then return { chips = card.ability.extra.current_chips } end

    if context.remove_playing_cards and not context.blueprint then
      local count = 0
      for k, v in ipairs(context.removed) do
        if not next(SMODS.get_enhancements(v)) then count = count + 1 end
      end

      if count > 0 then
        card.ability.extra.current_chips = card.ability.extra.current_chips + (card.ability.extra.added_chips * count)
        return { message = localize('k_upgrade_ex') }
      end
    end
  end
}
