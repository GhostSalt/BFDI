SMODS.Atlas {
  key = "BFDIA",
  path = "BFDIA.png",
  px = 71,
  py = 95
}

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

to_big = to_big or function(x) return x end

SMODS.Joker {
  key = 'bomby',
  config = { extra = { is_contestant = true, is_destroyed = false } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 0, y = 0 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.destroy_card and context.cardarea == G.hand and context.scoring_name == "High Card" then
      return { remove = true }
    end

    if context.destroy_card and context.scoring_name == "High Card" and not card.ability.extra.is_destroyed then
      card.ability.extra.is_destroyed = true
      G.E_MANAGER:add_event(Event({
        func = function()
          play_sound('bfdi_bomby', 1, 0.75)
          card.T.r = -0.2
          card:juice_up(0.3, 0.4)
          card.states.drag.is = true
          card.children.center.pinch.x = true
          G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            blockable = false,
            func = function()
              G.jokers:remove_card(card)
              card:remove()
              card = nil
              return true;
            end
          }))
          return true
        end
      }))
      card_eval_status_text(card, 'extra', nil, nil, nil, { message = "Kaboom!", colour = G.C.RED, card = card })
    end
  end
}

SMODS.Joker {
  key = 'book',
  config = { extra = { is_contestant = true, added_chips = 6, current_chips = 0 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 1, y = 0 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
  end
}

SMODS.Joker {
  key = 'donut',
  config = { extra = { is_contestant = true, added_mult = 1, current_mult = 0 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 2, y = 0 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
  key = 'dora',
  config = { extra = { is_contestant = true, added_xmult = 0.25, current_xmult = 1 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 3, y = 0 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = false,
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
      local planet_to_destroy = #destructable_planet > 0 and
      pseudorandom_element(destructable_planet, pseudoseed("dora")) or nil

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
          message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.current_xmult } } })
        return nil, true
      end
    end
  end
}

SMODS.Joker {
  key = 'fries',
  config = { extra = { is_contestant = true, chosen_planet_name = "Pluto", chosen_planet = "c_pluto" } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 4, y = 0 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS[card.ability.extra.chosen_planet]
    return { vars = { card.ability.extra.chosen_planet_name } }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and not context.individual and not context.repetition and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
      G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
      G.E_MANAGER:add_event(Event({
        func = function()
          G.E_MANAGER:add_event(Event({
            func = function()
              local new_card = create_card("Planet", G.consumables, nil, nil, nil, nil, card.ability.extra.chosen_planet,
                'friesplanet')
              new_card:add_to_deck()
              G.consumeables:emplace(new_card)
              G.GAME.consumeable_buffer = 0
              new_card:juice_up(0.3, 0.5)
              return true
            end
          }))
          card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
            { message = '+1 ' .. card.ability.extra.chosen_planet_name, colour = G.C.BLUE })
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

      local selected_card = (candidates and pseudorandom_element(candidates, pseudoseed("friesrandomplanet"))) or
      { key = "c_pluto", name = "Pluto" }
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

    local selected_card = (candidates and pseudorandom_element(candidates, pseudoseed("friesrandomplanet"))) or
    { key = "c_pluto", name = "Pluto" }
    card.ability.extra.chosen_planet = selected_card.key
    card.ability.extra.chosen_planet_name = selected_card.name
  end
}

SMODS.Joker {
  key = 'gelatin',
  config = { extra = { is_contestant = true, given_xmult = 2, duhed = false } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 5, y = 0 },
  duh_pos = { x = 2, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
    if not self.discovered and not card.params.bypass_discovery_center then
      return
    end
    if card and card.children and card.children.center and card.children.center.set_sprite_pos and card.ability and card.ability.extra and card.ability.extra.duhed then
      card.children.center:set_sprite_pos(self.duh_pos)
    else
      card.children.center:set_sprite_pos(self.pos)
    end
  end
}

SMODS.Joker {
  key = 'nickel',
  config = { extra = { is_contestant = true, given_money = 5 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 6, y = 0 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_money } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.playing_card_added then
      return
      {
        dollars = #context.cards * card.ability.extra.given_money,
        card = card
      }
    end
  end
}

SMODS.Joker {
  key = 'puffball',
  config = { extra = { is_contestant = true, given_xmult = 2, wild_detected = false } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 7, y = 0 },
  bfdi_anim = {
    { x = 0, y = 2, t = 0.06 },
    { x = 1, y = 2, t = 0.06 },
    { x = 2, y = 2, t = 0.06 },
    { x = 3, y = 2, t = 0.06 },
    { x = 4, y = 2, t = 0.06 },
    { x = 5, y = 2, t = 0.06 },
    { x = 6, y = 2, t = 0.06 },
    { x = 7, y = 2, t = 0.06 },
    { x = 0, y = 3, t = 0.06 },
    { x = 1, y = 3, t = 0.06 },
    { x = 2, y = 3, t = 0.06 },
    { x = 3, y = 3, t = 0.06 },
    { x = 4, y = 3, t = 0.06 },
    { x = 5, y = 3, t = 0.06 },
    { x = 6, y = 3, t = 0.06 },
    { x = 7, y = 3, t = 0.06 },
    { x = 0, y = 4, t = 0.06 },
    { x = 1, y = 4, t = 0.06 },
    { x = 2, y = 4, t = 0.06 }
  },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
    return { vars = { card.ability.extra.given_xmult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  key = 'ruby',
  config = { extra = { is_contestant = true, odds = 2 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 0, y = 1 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, "ruby")
    return { vars = { num, denom } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card:is_suit("Diamonds") and SMODS.pseudorandom_probability(card, "ruby", 1, card.ability.extra.odds) then
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
  end
}

SMODS.Joker {
  key = 'yellowface',
  config = { extra = { is_contestant = true, given_money = 3 } },
  rarity = 2,
  atlas = 'BFDIA',
  pos = { x = 1, y = 1 },
  cost = 6,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
