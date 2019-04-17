-- pico miner
-- by divoolej

-- colors
local black  = 0
local navy   = 1
local purple = 2
local slate  = 3
local brown  = 4
local gray   = 5
local silver = 6
local white  = 7
local red    = 8
local orange = 9
local yellow = 10
local green  = 11
local blue   = 12
local indigo = 13
local pink   = 14
local beige  = 15

-- controls
local left   = 0
local right  = 1
local up     = 2
local down   = 3
local action = 4

-- flags

local flg_flip_h      = 0
local flg_flip_v      = 1
local flg_can_dig     = 2
local flg_can_move    = 3
local flg_can_collect = 4

-- sprites
local spr_coal = 32
local spr_copper = 33
local spr_iron = 34
local spr_silver = 36
local spr_gold = 48
local spr_diamond = 51
local spr_cloud = 25
local spr_sky = 26
local spr_stone = 43
local spr_stone_hit = 44
local spr_bedrock = 45
local spr_empty = 47
local spr_dirt = 27

-- globals
local world_depth = 300
local min_coal_cluster_size = 5
local max_coal_cluster_size = 9
local min_copper_cluster_size = 4
local max_copper_cluster_size = 8
local min_iron_cluster_size = 4
local max_iron_cluster_size = 7
local min_silver_cluster_size = 3
local max_silver_cluster_size = 6
local min_gold_cluster_size = 2
local max_gold_cluster_size = 5
local min_diamond_cluster_size = 1
local max_diamond_cluster_size = 4

local durability_for_sprite = {}
durability_for_sprite[spr_coal] = 1
durability_for_sprite[spr_copper] = 1
durability_for_sprite[spr_iron] = 2
durability_for_sprite[spr_silver] = 2
durability_for_sprite[spr_gold] = 3
durability_for_sprite[spr_diamond] = 3
durability_for_sprite[spr_stone] = 2
durability_for_sprite[spr_stone_hit] = 1
durability_for_sprite[spr_dirt] = 1

-- core functions
function _init()
  save.load_progress()
  menu:init()
end

function _update()
  if game.state == "menu" then
    menu:update()
  elseif game.state == "generating" then
    if costatus(game.map_generation_coroutine) != "dead" then
      coresume(game.map_generation_coroutine)
    else
      game.state = "game"
    end
  elseif game.state == "game" then
    game:update()
  end
end

function _draw()
  if game.state == "menu" then
    menu:draw()
  elseif game.state == "generating" then
    game:draw_generating_status()
  elseif game.state == "summary" then
    game:draw_summary()
  elseif game.state == "game" then
    game:draw()
  end
end
