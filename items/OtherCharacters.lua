SMODS.Atlas {
  key = "Legendaries",
  path = "BFDI.png",
  px = 71,
  py = 95
}

to_big = to_big or function(x) return x end

SMODS.Joker {
  key = 'profily',
  config = { extra = { given_xmult = 3 } },
  rarity = 3,
  atlas = 'BFB-TPoT',
  pos = { x = 4, y = 6 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = "Other", key = "contestant_joker" }
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.joker_main then
      local left_joker = nil
      local right_joker = nil
      for i = 1, #G.jokers.cards do
        if G.jokers.cards[i] == card then left_joker = G.jokers.cards[i - 1]; right_joker = G.jokers.cards[i + 1]; end
      end
      if left_joker and left_joker ~= card and right_joker and right_joker ~= card then
        if left_joker.ability and left_joker.ability.extra and type(left_joker.ability.extra) == "table" and left_joker.ability.extra.is_contestant
        and right_joker.ability and right_joker.ability.extra and type(right_joker.ability.extra) == "table" and right_joker.ability.extra.is_contestant then
          return { xmult = card.ability.extra.given_xmult }
        end
      end
    end
  end
}

SMODS.Joker {
  key = 'speakerbox',
  config = { extra = { added_xmult = 1, current_xmult = 1 } },
  rarity = 4,
  atlas = 'Legendaries',
  pos = { x = 0, y = 0 },
  soul_pos = { x = 1, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = "Other", key = "contestant_joker" }
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
        play_sound("bfdi_fling", 1, 0.25)
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
            message = localize { type = 'variable', key = 'a_xmult', vars = { number_format(to_big(card.ability.extra.current_xmult)) } }
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
  config = { extra = { given_xmult = 1.5 } },
  rarity = 4,
  atlas = 'Legendaries',
  pos = { x = 2, y = 0 },
  soul_pos = { x = 3, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.c_trance
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
            end
          }))
          card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = "+1 Trance", colour = G.C.BLUE })
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
  config = { extra = { added_xmult = 0.2, current_xmult = 1 } },
  rarity = 4,
  atlas = 'Legendaries',
  pos = { x = 4, y = 0 },
  soul_pos = { x = 5, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_xmult, card.ability.extra.current_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
  key = 'three',
  rarity = 3,
  atlas = 'BFB-TPoT',
  pos = { x = 3, y = 6 },
  cost = 8,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == "unscored" then
      local _card = context.other_card
      local selectable_ranks = {}
      for k, v in pairs(SMODS.Ranks) do
        if k ~= _card.base.id then
          selectable_ranks[k] = v
        end
      end
      selectable_ranks[_card.base.id] = nil
      local chosen_rank = (pseudorandom_element(selectable_ranks, pseudoseed('three')) or { key = "Spades" }).key

      G.E_MANAGER:add_event(Event({
        func = function()
          play_sound('tarot1')
          card:juice_up()
          return true
        end
      }))
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
          _card:flip()
          play_sound('card1', 1)
          _card:juice_up(0.3, 0.3)
          delay(0.2)
          return true
        end
      }))
      G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.1,
        func = function()
          SMODS.change_base(_card, nil, chosen_rank)
          return true
        end
      }))
      G.E_MANAGER:add_event(Event({
        delay = 0.1,
        func = function()
          _card:flip()
          play_sound('tarot2', 1)
          _card:juice_up(0.3, 0.3)
          return true
        end
      }))
      delay(0.2)
      return { message = localize(chosen_rank, "ranks"), colour = G.C.FILTER }
    end
  end
}

SMODS.Joker {
  key = 'four',
  config = { extra = { added_hand_size = 4, added_hands = 4 } },
  rarity = 4,
  atlas = 'Legendaries',
  pos = { x = 6, y = 0 },
  soul_pos = { x = 7, y = 0 },
  cost = 20,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.added_hand_size, card.ability.extra.added_hands } }
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
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
