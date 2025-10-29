SMODS.Atlas {
  key = "MiscBFDI",
  path = "BFDI.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "MiscBFDIA",
  path = "BFDIA.png",
  px = 71,
  py = 95
}

SMODS.Atlas {
  key = "BFDITags",
  path = "BFDITags.png",
  px = 34,
  py = 34
}

SMODS.Atlas {
  key = "BFDIEnhancements",
  path = "BFDIEnhancements.png",
  px = 71,
  py = 95
}

SMODS.Sound({
  key = "yoylecake",
  path = "bfdi_yoylecake.ogg",
  replace = true
})

to_big = to_big or function(x) return x end

SMODS.Joker {
  key = 'yoylecake',
  config = { extra = { cards_left = 4 } },
  rarity = 2,
  atlas = 'MiscBFDI',
  pos = { x = 5, y = 3 },
  cost = 6,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
    return {
      vars = { card.ability.extra.cards_left, (function()
        if card.ability.extra.cards_left == 1 then
          return ""
        else
          return
          "s"
        end
      end)(), (function() if card.ability.extra.cards_left == 1 then return "s" else return "" end end)() }
    }
  end,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
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
          message = card.ability.extra.cards_left .. "",
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
        return {
          message = localize('k_eaten_ex'),
          colour = G.C.FILTER
        }
      end
    end
  end
}

SMODS.Joker {
  key = 'scoreboard',
  config = { extra = { given_chips = 30 } },
  rarity = 1,
  atlas = 'MiscBFDI',
  pos = { x = 1, y = 4 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.given_chips } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and
    (context.other_card:get_id() == 2 or context.other_card:get_id() == 3 or context.other_card:get_id() == 4 or context.other_card:get_id() == 5) then
      return { chips = card.ability.extra.given_chips }
    end
  end
}

SMODS.Joker {
  key = 'bagofboogers',
  config = { extra = { given_mult = 10 } },
  rarity = 1,
  atlas = 'MiscBFDI',
  pos = { x = 6, y = 3 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
    return { vars = { card.ability.extra.given_mult } }
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
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
  rarity = 3,
  atlas = 'MiscBFDI',
  pos = { x = 7, y = 3 },
  cost = 8,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.j_bfdi_bubble
    return {}
  end,
  blueprint_compat = false,
  eternal_compat = true,
  perishable_compat = true,
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
            end
          }))
          card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
            { message = "+Bubble", colour = G.C.FILTER })
          return true
        end)
      }))
    end
  end
}

SMODS.Joker {
  key = 'magicaldieofjudgment',
  config = { extra = { reroll_seen = false } },
  rarity = 1,
  atlas = 'MiscBFDI',
  pos = { x = 0, y = 4 },
  cost = 4,
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = G.P_CENTERS.tag_d_six
    return {}
  end,
  blueprint_compat = true,
  eternal_compat = true,
  perishable_compat = true,
  calculate = function(self, card, context)
    if context.reroll_shop and not context.blueprint then card.ability.extra.reroll_seen = true end

    if context.ending_shop then
      if not card.ability.extra.reroll_seen then
        G.E_MANAGER:add_event(Event({
          func = (function()
            add_tag(Tag('tag_d_six'))
            play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
            card:juice_up()
            return true
          end)
        }))
        return { message = localize('created_d6_tag'), colour = G.C.GREEN, card = card }
      end
      card.ability.extra.reroll_seen = false
    end
  end
}

SMODS.Joker {
  key = 'yoylite',
  config = { extra = { current_antes = 0, antes_required = 2, antes_backwards = 1 } },
  rarity = 2,
  atlas = 'MiscBFDIA',
  pos = { x = 0, y = 5 },
  cost = 6,
  blueprint_compat = false,
  eternal_compat = false,
  perishable_compat = true,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.current_antes, card.ability.extra.antes_required, card.ability.extra.antes_backwards } }
  end,
  calculate = function(self, card, context)
    if context.end_of_round and G.GAME.last_blind and G.GAME.last_blind.boss and not context.individual and not context.repetition and not context.blueprint then
      card.ability.extra.current_antes = card.ability.extra.current_antes + 1
      if card.ability.extra.current_antes == card.ability.extra.antes_required then
        local eval = function(card) return not card.REMOVED end
        juice_card_until(card, eval, true)
      end
      return {
        message = (card.ability.extra.current_antes < card.ability.extra.antes_required) and
            (card.ability.extra.current_antes .. '/' .. card.ability.extra.antes_required) or localize('k_active_ex'),
        colour = G.C.FILTER
      }
    end

    if context.selling_self and card.ability.extra.current_antes >= card.ability.extra.antes_required then
      ease_ante(-card.ability.extra.antes_backwards)
      if card.ability.extra.antes_backwards == 1 then return { message = localize { type = 'variable', key = 's_ante', vars = { card.ability.extra.antes_backwards } } } end
      return { message = localize { type = 'variable', key = 's_antes', vars = { card.ability.extra.antes_backwards } } }
    end
  end,
  set_ability = function(self, card, initial, delay_sprites)
    card.ability.extra.current_antes = 0
  end
}














SMODS.Tag {
  key = "contestant",
  atlas = "BFDITags",
  pos = { x = 0, y = 0 },
  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { set = "Other", key = "contestant_joker" }
    return {}
  end,
  apply = function(self, tag, context)
    if context.type == 'store_joker_create' then
      local candidates = {}
      for i, v in pairs(G.P_CENTER_POOLS.Joker) do
        if v.config and v.config.extra and type(v.config.extra) == "table" and v.config.extra.is_contestant then
          candidates[#candidates + 1] = v.key
        end
      end
      local card_to_create = pseudorandom_element(candidates, pseudoseed("randomcontestant")) or "j_joker"
      local card = SMODS.create_card({
        set = "Joker",
        area = context.area,
        key = card_to_create,
        key_append =
        "contestanttag"
      })
      create_shop_card_ui(card, 'Joker', context.area)
      card.states.visible = false
      tag:yep('+', G.C.GREEN, function()
        card:start_materialize()
        card.ability.couponed = true
        card:set_cost()
        return true
      end)
      tag.triggered = true
      return card
    end
  end
}

SMODS.Seal {
  key = "naily",
  loc_txt = {
    name = 'Naily Seal',
    text = {
      "{X:mult,C:white}X#1#{} Mult",
      "while this card",
      "stays in hand",
    }
  },
  badge_colour = HEX("929292"),
  atlas = "BFDIEnhancements",
  pos = { x = 0, y = 0 },
  config = { extra = { h_x_mult = 1.5 } },
  loc_vars = function(self, info_queue, center)
    return { vars = { self.config.extra.h_x_mult } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.hand then return { xmult = self.config.extra.h_x_mult } end
  end,
  in_pool = function() return false end
}
