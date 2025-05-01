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
          local card = SMODS.create_card({set="Joker", area=G.jokers, key=card_to_create, no_edition=true})
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