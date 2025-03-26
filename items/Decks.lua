SMODS.Atlas {
  key = "Decks",
  path = "Decks.png",
  px = 71,
  py = 95
}

SMODS.Back {
  key = 'goiky',
  atlas = 'Decks',
  pos = { x = 0, y = 0 },
  calculate = function(self, back, context)
    if context.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
      G.E_MANAGER:add_event(Event({
        delay = 0.3,
        blockable = false,
        func = function()
          play_sound('timpani')
          local new_card = create_card("Tarot", G.consumables, nil, nil, nil, nil, 'c_chariot', 'goikydeck')
          new_card:set_edition({ negative = true })
          new_card:add_to_deck()
          G.consumeables:emplace(new_card)
          return true
        end
      }))
    end
  end
}

SMODS.Back {
  key = 'yoyle',
  atlas = 'Decks',
  pos = { x = 1, y = 0 },
  config = { extra = { joker_slots = 1 } },
  loc_vars = function(self, info_queue, center)
    return { vars = { self.config.extra.joker_slots } }
  end,
  apply = function(self, back)
    G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots + self.config.extra.joker_slots
    G.E_MANAGER:add_event(Event({
      func = function()
        if G.jokers then
          local candidates = {}
          for i, v in pairs(G.P_CENTER_POOLS.Joker) do
            if v.config and v.config.extra and type(v.config.extra) == "table" and v.config.extra.is_contestant and v.eternal_compat then
              candidates[#candidates+1] = v.key
            end
          end
          local card_to_create = pseudorandom_element(candidates, pseudoseed("yoylerandomjoker")) or "j_joker"
          local card = create_card("Joker", G.jokers, nil, nil, nil, nil, card_to_create)
          card:add_to_deck()
          card:start_materialize()
          card:set_eternal(true)
          G.jokers:emplace(card)
          return true
        end
      end
    }))
  end
}

SMODS.Joker {
  key = 'bagofboogers',
  config = { extra = { given_mult = 20 } },
  rarity = 1,
  atlas = 'Misc',
  pos = { x = 6, y = 3 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.m_lucky
    return { vars = { card.ability.extra.given_mult } }
  end,
	blueprint_compat = true,
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
  rarity = 2,
  atlas = 'Misc',
  pos = { x = 7, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue+1] = G.P_CENTERS.j_bfdi_bubble
    return { }
  end,
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