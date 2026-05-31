SMODS.Atlas {
  key = "Boosters",
  path = "BFDIBoosters.png",
  px = 71,
  py = 95
}

SMODS.Booster {
  key = "token_normal1",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 0, y = 0 },
  config = { extra = 3, choose = 1 },
  cost = 4,
  weight = 0.64,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_normal1" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_normal2",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 1, y = 0 },
  config = { extra = 3, choose = 1 },
  cost = 4,
  weight = 0.64,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_normal2" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_normal3",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 2, y = 0 },
  config = { extra = 3, choose = 1 },
  cost = 4,
  weight = 0.64,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_normal3" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_normal4",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 3, y = 0 },
  config = { extra = 3, choose = 1 },
  cost = 4,
  weight = 0.64,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_normal4" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_jumbo1",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 0, y = 1 },
  config = { extra = 5, choose = 1 },
  cost = 6,
  weight = 0.32,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_jumbo1" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_jumbo2",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 1, y = 1 },
  config = { extra = 5, choose = 1 },
  cost = 6,
  weight = 0.32,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_jumbo2" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_mega1",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 2, y = 1 },
  config = { extra = 5, choose = 2 },
  cost = 8,
  weight = 0.16,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_mega1" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}

SMODS.Booster {
  key = "token_mega2",
  kind = "bfdi_Token",
  atlas = "Boosters",
  pos = { x = 3, y = 1 },
  config = { extra = 5, choose = 2 },
  cost = 8,
  weight = 0.16,
  create_card = function(self, card)
    return SMODS.create_card { set = "bfdi_Token", area = G.pack_cards, skip_materialize = true, soulable = true, key_append = "token_mega2" }
  end,
  ease_background_colour = function(self)
    ease_colour(G.C.DYN_UI.MAIN, G.C.BFDI.MISC_COLOURS.TOKEN)
    ease_background_colour({ new_colour = G.C.BFDI.MISC_COLOURS.TOKEN, special_colour = G.C.BFDI.MISC_COLOURS.TOKEN_ALT, contrast = 2 })
  end,
  loc_vars = function(self, info_queue, card)
    return { vars = { card.config.center.config.choose, card.ability.extra } }
  end,
  group_key = "k_bfdi_token_pack",
  select_card = "consumeables"
}