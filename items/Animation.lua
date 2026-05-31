if not next(SMODS.find_mod("Flipbook")) then
  local mod_name = "BFDI"

  G.FUNCS.run_flipbook_failsafe_menu = function()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
      definition = create_flipbook_failsafe_menu()
    }
  end

  function create_flipbook_failsafe_menu()
    local dontshowagain = create_toggle({
      label = localize("flipbook_dontshowagain"),
      active_colour = HEX("40c76d"),
      ref_table = G,
      ref_value = "flipbook_did_player_no_show_again",
      callback = function()
      end,
    })

    local description_nodes = {}

    description_nodes[#description_nodes + 1] = {}
    local loc_vars = { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.4 }
    localize { type = 'descriptions', key = "flipbook_disabled_headsup", set = 'Other', nodes = description_nodes[#description_nodes], vars = loc_vars.vars, scale = loc_vars.scale, text_colour = loc_vars.text_colour, shadow = loc_vars.shadow }
    description_nodes[#description_nodes] = desc_from_rows(description_nodes[#description_nodes])
    description_nodes[#description_nodes].config.colour = loc_vars.background_colour or description_nodes[#description_nodes].config.colour
    description_nodes[#description_nodes + 1] = {
      n = G.UIT.R,
      config = { align = "cm" },
      nodes = {
        {
          n = G.UIT.B,
          config = { align = "cm", w = 1, h = 0.2 },
          nodes = {}
        }
      }
    }
    description_nodes[#description_nodes + 1] = {
      n = G.UIT.R,
      config = { align = "cm", button = "flipbook_browser_link" },
      nodes = {
        {
          n = G.UIT.T,
          config = {
            align = "cm",
            text = localize("flipbook_disabled_headsup_link"),
            colour = G.C.BLUE,
            scale = 0.4
          }
        }
      }
    }

    local t = create_UIBox_generic_options({
      contents = {
        {
          n = G.UIT.R,
          config = { align = "cm", padding = 0.1 },
          nodes = {
            {
              n = G.UIT.T,
              config = {
                align = "tm",
                text = mod_name,
                colour = G.C.UI.TEXT_LIGHT,
                scale = 1
              }
            }
          }
        },
        {
          n = G.UIT.R,
          config = { align = "cm", minw = 7, minh = 5, colour = G.C.BLACK, emboss = 0.05, r = 0.1 },
          nodes = {
            {
              n = G.UIT.C,
              config = { align = "cm" },
              nodes = description_nodes
            }
          }
        },
        {
          n = G.UIT.R,
          config = { align = "cm" },
          nodes = { dontshowagain }
        }
      },
      back_label = localize("b_continue"),
      back_func = "exit_flipbook_failsafe_overlay_menu"
    })
    return t
  end

  G.FUNCS.exit_flipbook_failsafe_overlay_menu = function()
    if not G.OVERLAY_MENU then return end

    G.CONTROLLER.locks.frame_set = true
    G.CONTROLLER.locks.frame = true
    G.CONTROLLER:mod_cursor_context_layer(-1000)
    G.OVERLAY_MENU:remove()
    G.OVERLAY_MENU = nil
    G.VIEWING_DECK = nil
    G.SETTINGS.paused = false

    G:save_settings()

    G.flipbook_has_seen_failsafe_this_session = true
    G.PROFILES[G.SETTINGS.profile].flipbook_has_seen_failsafe_headsup = G.flipbook_did_player_no_show_again
    G:save_settings()
  end

  local main_menu_ref = Game.main_menu
  Game.main_menu = function(change_context)
    local ret = main_menu_ref(change_context)

    if not G.flipbook_has_seen_failsafe_this_session
        and not G.PROFILES[G.SETTINGS.profile].flipbook_has_seen_failsafe_headsup then
      G.FUNCS.run_flipbook_failsafe_menu()
    end

    return ret
  end

  G.FUNCS.flipbook_browser_link = function()
    love.system.openURL( "https://github.com/GhostSalt/Flipbook" )
  end







  function Card:flipbook_set_anim_state(state, dont_reset_t) return end

  function Card:flipbook_set_anim_extra_state(state, layer, dont_reset_t) return end

  function SMODS.Center:flipbook_set_anim_state(state, dont_reset_t) return end

  function SMODS.Center:flipbook_set_anim_extra_state(state, layer, dont_reset_t) return end

  function flipbook_set_anim_state(center, state, dont_reset_t) return end

  function flipbook_set_anim_extra_state(center, state, layer, dont_reset_t) return end

  get_pos_from_flipbook_table = function(pos)
    return pos and (pos.pos or (pos.x and pos.y and pos)) or { x = 0, y = 0 }
  end

  SMODS.DrawStep {
    key = 'extra',
    order = 21,
    func = function(self, layer)
      if not self.flipbook_extra and self.config.center.flipbook_pos_extra then
        self.flipbook_extra = {}
        local fpe = self.config.center.flipbook_pos_extra
        if fpe.x and fpe.y then -- flipbook_pos_extra = { x = ?, y = ?, atlas = "ExampleAtlas" }
          local atlas = G.ASSET_ATLAS[fpe.atlas or self.config.center.atlas]
          self.flipbook_extra.extra = Sprite(0, 0, atlas.px, atlas.py, atlas, { x = fpe.x, y = fpe.y })
        else -- flipbook_pos_extra = { example = { x = ?, y = ? }, example2 = { x = ?, y = ?, atlas = "ExampleAtlas" } }
          for k, v in pairs(fpe) do
            local atlas = G.ASSET_ATLAS[v and v.atlas or self.config.center.atlas]
            self.flipbook_extra[k] = Sprite(0, 0, atlas.px, atlas.py, atlas, get_pos_from_flipbook_table(v))
          end
        end
      end
      if self.flipbook_extra then
        if self.config.center.discovered or (self.params and self.params.bypass_discovery_center) then
          local fpe = self.config.center.flipbook_pos_extra
          if fpe.x and fpe.y then
            fpe = { extra = self.config.center.flipbook_pos_extra }
          end
          for k, v in pairs(fpe) do
            self.flipbook_extra[k]:set_sprite_pos(get_pos_from_flipbook_table(v))
            self.flipbook_extra[k].role.draw_major = self
            if (self.edition and self.edition.negative and (not self.delay_edition or self.delay_edition.negative)) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
              self.flipbook_extra[k]:draw_shader('negative', nil, self.ARGS.send_to_shader, nil, self.children.center)
            elseif not self:should_draw_base_shader() then
            elseif not self.greyed then
              self.flipbook_extra[k]:draw_shader('dissolve', nil, nil, nil, self.children.center)
            end

            if self.ability.name == 'Invisible Joker' and (self.config.center.discovered or self.bypass_discovery_center) then
              if self:should_draw_base_shader() then
                self.flipbook_extra[k]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
              end
            end

            local center = self.config.center
            if center.flipbook_draw_extra and type(center.flipbook_draw_extra) == "function" then
              center:flipbook_draw_extra(self, layer)
            end
            if center.flipbook_draw_extra and type(center.flipbook_draw_extra) == "table"
                and center.flipbook_draw_extra[k] and type(center.flipbook_draw_extra[k]) == "function" then
              (center.flipbook_draw_extra[k])(self, layer)
            end

            local edition = self.delay_edition or self.edition
            if edition then
              for kk, vv in pairs(G.P_CENTER_POOLS.Edition) do
                if edition[vv.key:sub(3)] and vv.shader then
                  if type(v.draw) == 'function' then
                    vv:draw(self, layer)
                  else
                    self.flipbook_extra[k]:draw_shader(vv.shader, nil, self.ARGS.send_to_shader, nil, self.children.center)
                  end
                end
              end
            end
            if (edition and edition.negative) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
              self.flipbook_extra[k]:draw_shader('negative_shine', nil, self.ARGS.send_to_shader, nil, self.children.center)
            end
          end
        end
      end
    end,
    conditions = { vortex = false, facing = 'front' }
  }






























  --[[SMODS.DrawStep {
  key = 'extra',
  order = 21,
  func = function(self, layer)
    if not self.bfdi_extra and self.config.center.pos_extra then
      local atlas = G.ASSET_ATLAS[self.config.center.atlas_extra or self.config.center.atlas]
      self.bfdi_extra = Sprite(0, 0, atlas.px, atlas.py,
        atlas, self.config.center.pos_extra)
    end
    if self.bfdi_extra then
      if self.config.center.discovered or (self.params and self.params.bypass_discovery_center) then
        self.bfdi_extra:set_sprite_pos(self.config.center.pos_extra)
        self.bfdi_extra.role.draw_major = self
        if (self.edition and self.edition.negative and (not self.delay_edition or self.delay_edition.negative)) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
          self.bfdi_extra:draw_shader('negative', nil, self.ARGS.send_to_shader, nil, self.children.center)
        elseif not self:should_draw_base_shader() then
        elseif not self.greyed then
          self.bfdi_extra:draw_shader('dissolve', nil, nil, nil, self.children.center)
        end

        if self.ability.name == 'Invisible Joker' and (self.config.center.discovered or self.bypass_discovery_center) then
          if self:should_draw_base_shader() then
            self.bfdi_extra:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
          end
        end

        local center = self.config.center
        if center.draw_extra and type(center.draw_extra) == 'function' then
          center:draw_extra(self, layer)
        end

        local edition = self.delay_edition or self.edition
        if edition then
          for k, v in pairs(G.P_CENTER_POOLS.Edition) do
            if edition[v.key:sub(3)] and v.shader then
              if type(v.draw) == 'function' then
                v:draw(self, layer)
              else
                self.bfdi_extra:draw_shader(v.shader, nil, self.ARGS.send_to_shader, nil, self.children.center)
              end
            end
          end
        end
        if (edition and edition.negative) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
          self.bfdi_extra:draw_shader('negative_shine', nil, self.ARGS.send_to_shader, nil, self.children.center)
        end
      end
    end
  end,
  conditions = { vortex = false, facing = 'front' }
}

BFDI = { config = { animations_disabled = false } }

local update_ref = Game.update
function Game:update(dt)
  if not BFDI.config["animations_disabled"] then
    for k, v in pairs(G.P_CENTERS) do
      if not v.default_pos then v.default_pos = v.pos end
      if not v.default_pos_extra then v.default_pos_extra = v.pos_extra end

      handle_bfdi_anim(v, dt)
      handle_bfdi_anim_extra(v, dt)
    end
  else
    for k, v in pairs(G.P_CENTERS) do
      if not v.default_pos then v.default_pos = v.pos end
      if not v.default_pos_extra then v.default_pos_extra = v.pos_extra end
      v.pos = v.default_pos
      v.pos_extra = v.default_pos_extra
    end
  end

  return update_ref(self, dt)
end

function handle_bfdi_anim(v, dt)
  if v.bfdi_anim_states or v.bfdi_anim then
    v.bfdi_anim = format_bfdi_anim(v.bfdi_anim_states and v.bfdi_anim_current_state and
      v.bfdi_anim_states[v.bfdi_anim_current_state] and v.bfdi_anim_states[v.bfdi_anim_current_state].anim or
      v.bfdi_anim)
    if v.bfdi_anim == nil then
      v.pos = v.default_pos
    else
      local loop = v.bfdi_anim_states and v.bfdi_anim_current_state and
          v.bfdi_anim_states[v.bfdi_anim_current_state] and v.bfdi_anim_states[v.bfdi_anim_current_state].loop
      if loop == nil then loop = true end
      if not v.bfdi_anim_t then v.bfdi_anim_t = 0 end
      if not v.bfdi_anim.length then
        v.bfdi_anim.length = 0
        for _, frame in ipairs(v.bfdi_anim) do
          v.bfdi_anim.length = v.bfdi_anim.length + (frame.t or 0)
        end
      end
      v.bfdi_anim_t = v.bfdi_anim_t + dt
      if not loop and v.bfdi_anim_t >= v.bfdi_anim.length then
        local continuation = v.bfdi_anim_states[v.bfdi_anim_current_state].continuation
        if continuation then
          v.bfdi_anim_current_state = continuation
          v.bfdi_anim_t = 0
          handle_bfdi_anim(v, dt)
          return
        else
          v.bfdi_anim_t = v.bfdi_anim.length
        end
      elseif loop then
        v.bfdi_anim_t = v.bfdi_anim_t % v.bfdi_anim.length
      end
      local ix = 0
      local t_tally = 0
      for _, frame in ipairs(v.bfdi_anim) do
        ix = ix + 1
        t_tally = t_tally + frame.t
        if t_tally > v.bfdi_anim_t then break end
      end
      v.pos.x = v.bfdi_anim[ix].x
      v.pos.y = v.bfdi_anim[ix].y
    end
  end
end

function handle_bfdi_anim_extra(v, dt)
  if v.bfdi_anim_extra_states or v.bfdi_anim_extra then
    v.bfdi_anim_extra = format_bfdi_anim(v.bfdi_anim_extra_states and v.bfdi_anim_extra_current_state and
      v.bfdi_anim_extra_states[v.bfdi_anim_extra_current_state] and
      v.bfdi_anim_extra_states[v.bfdi_anim_extra_current_state].anim or
      v.bfdi_anim_extra)
    if v.bfdi_anim_extra == nil then
      v.pos_extra = v.default_pos_extra
    else
      local loop = v.bfdi_anim_extra_states and v.bfdi_anim_extra_current_state and
          v.bfdi_anim_extra_states[v.bfdi_anim_extra_current_state] and
          v.bfdi_anim_extra_states[v.bfdi_anim_extra_current_state].loop
      if loop == nil then loop = true end
      if not v.bfdi_anim_extra_t then v.bfdi_anim_extra_t = 0 end
      if not v.bfdi_anim_extra.length then
        v.bfdi_anim_extra.length = 0
        for _, frame in ipairs(v.bfdi_anim_extra) do
          v.bfdi_anim_extra.length = v.bfdi_anim_extra.length + (frame.t or 0)
        end
      end
      v.bfdi_anim_extra_t = v.bfdi_anim_extra_t + dt
      if not loop and v.bfdi_anim_extra_t >= v.bfdi_anim_extra.length then
        local continuation = v.bfdi_anim_extra_states[v.bfdi_anim_extra_current_state].continuation
        if continuation then
          v.bfdi_anim_extra_current_state = continuation
          v.bfdi_anim_extra_t = 0
          handle_bfdi_anim_extra(v, dt)
        else
          v.bfdi_anim_extra_t = v.bfdi_anim_extra.length
        end
      elseif loop then
        v.bfdi_anim_extra_t = v.bfdi_anim_extra_t % v.bfdi_anim_extra.length
      end
      local ix = 0
      local t_tally = 0
      for _, frame in ipairs(v.bfdi_anim_extra) do
        ix = ix + 1
        t_tally = t_tally + frame.t
        if t_tally > v.bfdi_anim_extra_t then break end
      end
      if not v.pos_extra then v.pos_extra = {} end
      v.pos_extra.x = v.bfdi_anim_extra[ix].x
      v.pos_extra.y = v.bfdi_anim_extra[ix].y
    end
  end
end

function format_bfdi_anim(anim)
  if not anim then return nil end
  local new_anim = {}
  for _, frame in ipairs(anim) do
    if frame and (frame.x or (frame.xrange and frame.xrange.first and frame.xrange.last)) and (frame.y or (frame.yrange and frame.yrange.first and frame.yrange.last)) then
      local firsty = frame.y or frame.yrange.first
      local lasty = frame.y or frame.yrange.last
      for y = firsty, lasty, firsty <= lasty and 1 or -1 do
        local firstx = frame.x or frame.xrange.first
        local lastx = frame.x or frame.xrange.last
        for x = firstx, lastx, firstx <= lastx and 1 or -1 do
          new_anim[#new_anim + 1] = { x = x, y = y, t = frame.t or 0 }
        end
      end
    end
  end
  new_anim.t = anim.t
  return new_anim
end]] --
end
