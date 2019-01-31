pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
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
local spr_coal = 10
local spr_copper = 11
local spr_iron = 12
local spr_silver = 13
local spr_gold = 14
local spr_diamond = 15
local spr_cloud = 25
local spr_sky = 26
local spr_stone = 43
local spr_stone_hit = 44
local spr_bedrock = 45
local spr_empty = 47
local spr_dirt = 27

-- core functions
function _init()
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
	elseif game.state == "game" then
		game:draw()
	end
end

-->8
-- helpers

function rndi(n)
 return flr(rnd(n))
end

function ore_for_depth(n)
 local depth_factor = flr(n / 20)
 local dice = rnd(100)
 if (dice < 1 + depth_factor) return spr_diamond
 if (dice < 36) return spr_coal
 if (dice < 40 + depth_factor) return spr_gold
 if (dice < 70) return spr_copper
 if (dice < 80 + depth_factor) return spr_silver
 return spr_iron
end

function sprite_for_depth(n)
 local depth_factor = flr(n / 10)
 local dice = rnd(100)
 if (dice < 2) return spr_bedrock
 if (dice < 10 - depth_factor) return spr_empty
 if (dice < 60 - 2 * depth_factor) return spr_dirt + rndi(4)
 if (dice < 80 - depth_factor) return spr_stone
 return ore_for_depth(n)
end

-->8
-- main menu

local options = {
	{
		is_selected = true,
		text = "new run",
		callback = function()
			game:init()
		end,
	},
	{
		is_selected = false,
		text = "exit",
		callback = function()
			cls()
			stop()
		end,
	},
}

function for_selected_option(self, callback)
	local index, option
	for index,option in pairs(self.options) do
		if option.is_selected then
			callback(option, index)
			break
		end
	end
end

function init_menu(self)
	game.state = "menu"
end

function draw_menu(self)
	cls()
	-- draw background
	map(16, 0, 0, 0, 16, 16)
	-- draw logo
	rectfill(38, 22, 80, 30, black)
	print("pico miner", 40, 24, blue)
	-- draw options
	rectfill(38, 48, 80, 50 + #options * 8, black)
	local index, option
	for index, option in pairs(self.options) do
		if option.is_selected then
			print("➡️ "..option.text, 40, 43 + index * 8, green)
		else
			print(option.text, 52, 43 + index * 8, blue)
		end
	end
end

function update_menu(self)
	if btnp(action) then
		self:for_selected_option(function(option)
			option.callback()
		end)
	end
	if btnp(down) then
		self:for_selected_option(function(option, index)
			option.is_selected = false
			self.options[index % #self.options + 1].is_selected = true
		end)
	elseif btnp(up) then
		self:for_selected_option(function(option, index)
			option.is_selected = false
			self.options[(index - 2) % #self.options + 1].is_selected = true
		end)
	end
end

menu = {
	options = options,
	for_selected_option = for_selected_option,
	init = init_menu,
	draw = draw_menu,
	update = update_menu,
}
-->8
-- game

function make_tile(sprite, x, y, is_visible)
 return {
  sprite = sprite,
  x = x * 8,
  y = y * 8,
  is_visible = is_visible,
  can_move = fget(sprite, flg_can_move),
  can_dig = fget(sprite, flg_can_dig),
  flip_h = fget(sprite, flg_flip_h) and rndi(2) == 1,
  flip_v = fget(sprite, flg_flip_v) and rndi(2) == 1,
  draw = function(self)
   if (true) spr(self.sprite, self.x, self.y, 1, 1, self.flip_h, self.flip_v)
  end,
  dig = function(self)
   self.sprite = 47
   self.can_move = true
   self.can_dig = false
  end
 }
end

function expensive()
 local i, b
 for i=1,9999,0.1 do
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
  b=123*23/104*108/99*34/99*87*123*23/104*108/99*34/99*87
 end
end

function generate_map(self)
 local i, j
 -- generate sky
 for i=1,7 do
  self.world[i] = {}
  for j=1,16 do
   self.world[i][j] = make_tile(spr_sky, j - 1, i - 1, true)
  end
 end
 for i=1,16 do
  local x = rndi(16) + 1
  local y = rndi(6) + 1
  self.world[y][x] = make_tile(spr_cloud, x - 1, y - 1, true)
 end
 game.generation_status = "generating ground layer..."
 yield()
 -- generate top ground layer and flowers
 self.world[8] = {}
 self.world[9] = {}
 for j=1,16 do
  self.world[8][j] = make_tile(40 + rndi(3), j - 1, 7, true)
  self.world[9][j] = make_tile(27 + rndi(4), j - 1, 8, true)
 end
 game.generation_status = "generating underground..."
 yield()
 -- generate underground
 for i=10,30 do
  self.world[i] = {}
  for j=1,16 do
   self.world[i][j] = make_tile(sprite_for_depth(i), j - 1, i - 1)
  end
 end
end

function init_game(self)
	self.state = "generating"
 game.generation_status = "generating sky..."
 self.map_generation_coroutine = cocreate(function() self:generate_map() end)
	player:init()
end

function can_move(self, direction)
 if direction == left and player.x_grid > 0 then
  return self.world[player.y_grid + 1][player.x_grid].can_move
 elseif direction == right and player.x_grid < 15 then
  return self.world[player.y_grid + 1][player.x_grid + 2].can_move
 else
  return false
 end
end

function can_dig(self, direction)
 if direction == left and player.x_grid > 0 then
  return self.world[player.y_grid + 1][player.x_grid].can_dig
 elseif direction == right and player.x_grid < 15 then
  return self.world[player.y_grid + 1][player.x_grid + 2].can_dig
 elseif direction == down then
  return self.world[player.y_grid + 2][player.x_grid + 1].can_dig
 else
  return false
 end
end

function has_floor(self, x, y)
 return not self.world[y + 2][x + 1].can_move
end

function process_dig(self, x, y, direction)
 if (direction == left) return self.world[y + 1][x]:dig()
 if (direction == right) return self.world[y + 1][x + 2]:dig()
 if (direction == down) return self.world[y + 2][x + 1]:dig()
end

function update_game(self)
 player:update()
end

function draw_generating_status(self)
 cls()
 print(game.generation_status, 20, 20, blue)
end

function draw_game(self)
	cls()
 for i,row in pairs(self.world) do
  for j,column in pairs(self.world[i]) do
   self.world[i][j]:draw()
  end
 end
 player:draw()
end

game = {
 world = {},
 is_loading = true,
 generate_map = generate_map,
 draw_generating_status = draw_generating_status,
	can_move = can_move,
	can_dig = can_dig,
 has_floor = has_floor,
 dig = process_dig,
	init = init_game,
	update = update_game,
	draw = draw_game,
}
-->8
-- player

function init_player(self)
	self.x = self.x_grid * 8
	self.y = self.y_grid * 8
 self.is_facing_left = self.direction == left
end

function start_digging(self)
 self.state = "dig"
 self.current_sprite = 16
end

function start_moving(self)
 self.state = "move"
 self.current_sprite = 0
end

function start_falling(self)
 self.state = "fall"
 self.animation_frame = 0
 self.current_sprite = 6
end

function stop_player(self)
	self.animation_frame = 0
 self.current_sprite = 0
	self.state = "idle"
end

function move_or_dig(self)
 self.animation_frame = 0
	if game:can_move(self.direction) then
		self:start_moving()
	elseif game:can_dig(self.direction) then
		self:start_digging()
	end
end

function idle(self)
 if (self.animation_frame == 0) self.current_sprite = 0
 if (self.animation_frame == 15) self.current_sprite = 4
 if (self.animation_frame == 30) self.current_sprite = 0
 if (self.animation_frame == 45) self.current_sprite = 5
 if self.animation_frame >= 55 then
  self.animation_frame = 0
 else
  self.animation_frame += 1
 end
end

function check_position(self)
 self.animation_frame = 0
 if game:has_floor(self.x_grid, self.y_grid) then
  self:stop()
 else
  self:start_falling()
 end
end

function move(self)
 if self.direction == left then
		self.x -= 1
	else
		self.x += 1
	end
 if (self.animation_frame % 2 == 0) self.current_sprite += 1
	if self.animation_frame >= 7 then
  if self.direction == left then
   self.x_grid -= 1
  else
   self.x_grid += 1
  end
  self:check_position()
 else
  self.animation_frame += 1
 end
end

function dig(self)
 if (self.animation_frame % 2 == 0) self.current_sprite += 1
 if self.animation_frame >= 10 then
  game:dig(self.x_grid, self.y_grid, self.direction)
  self:check_position()
 else
  self.animation_frame += 1
 end
end

function fall(self)
 if (self.animation_frame == 0) self.current_sprite = 6
 if (self.animation_frame == 2) self.current_sprite = 7
 if self.animation_frame == 4 then
  self.y_grid += 1
  self:check_position()
 else
  self.y += 2
  self.animation_frame += 1
 end
end

function handle_controls(self)
	if btn(left) then
  self.is_facing_left = true
  self.direction = left
		self:move_or_dig()
	elseif btn(right) then
  self.is_facing_left = false
  self.direction = right
		self:move_or_dig()
	elseif btn(down) then
  self.direction = down
		self:move_or_dig()
	end
end

function handle_controls_when_moving(self)
 if (self.animation_frame == 0) return
 if btnp(left) and self.is_facing_left == false then
  self.is_facing_left = true
  self.direction = left
  self.animation_frame = 8 - self.animation_frame
  self.current_sprite = self.animation_frame / 2
  self.x_grid += 1
 elseif btnp(right) and self.is_facing_left == true then
  self.is_facing_left = false
  self.direction = right
  self.animation_frame = 8 - self.animation_frame
  self.current_sprite = self.animation_frame / 2
  self.x_grid -= 1
 end
end

function update_player(self)
	if (self.state == "idle") then
  self:idle()
  self:handle_controls()
 end
 if (self.state == "move") then
  self:handle_controls_when_moving()
  self:move()
 end
 if (self.state == "dig") self:dig()
 if (self.state == "fall") self:fall()
end

function draw_player(self)
	spr(self.current_sprite, self.x, self.y, 1, 1, self.is_facing_left)
end

player = {
	x_grid = 8,
	y_grid = 0,
	current_sprite = 0,
	animation_frame = 0,
	state = "fall",
	direction = left,
	start_moving = start_moving,
	start_digging = start_digging,
 start_falling = start_falling,
 idle = idle,
	move = move,
 dig = dig,
 fall = fall,
	stop = stop_player,
 check_position = check_position,
 move_or_dig = move_or_dig,
	handle_controls = handle_controls,
 handle_controls_when_moving = handle_controls_when_moving,
 init = init_player,
	update = update_player,
	draw = draw_player,
}
__gfx__
00330000003300000033000000330000003300000033000000330000003300000000000000000000440444014454445944544456445444574494449a44d444dc
03aa000003aa000003aa000003aa000003aa000003aa000003aa066003aa06600000000000000000400140004559459546264562476745764afa49af4c7c4dc6
00aa066000aa066000aa066000aa066000aa066000aa0660a0aa004600aa004600000000000000004010440445954454456544244575446449a944f44dcd4464
0d55d0460d55d0460d55d0460d55d0460d55d0460d55d0460d55da06ad55da060000000000000000440044444455444444544444445444444494444444d44444
0a550a060a550a0600a50a06a0550a06a0550a0600a50a0600554000005540000000000000000000444401444444594444442644444467444444fa4444447c44
0055400000554000005540000055400000554000005540000055000000550000000000000000000040401044454595444542654445467544494fa9444d47cd44
0a00a00000a0a00000a0a00000a0a0000a00a0000a00a0000a00a0000a00a000000000000000000001400444954954446246544476475444af4a9444c74cd444
02002000020020000200200002002000020020000200200002002000020020000000000000000000400444444954444446244444476444444af444444c744444
003300000033000000330660003300100330010000330000000000000000000000000000cccccccccccccccc4444444444444444444444444444444400000000
03aa000003aa000003aa004603aa10013aa0000103aa0000000000000000000000000000c7cccccccccccccc444444444444444444444444444444f400000000
00aa066000aa006000aa040600aa01600aa0000000aa0060000000000000000000000000cccc7ccccccccccc4444444446444444444444444d44444400000000
00d5d04600d5d00600d5a00000d5d006055d00100555d006000000000000000000000000cc7777cccccccccc4444444444444444444744444444444400000000
005a0a06005a4a46005a0001005a4a460550a0000a554a46000000000000000000000000c7777ccccccccccc44444444444444d4444444444444444400000000
005540000055000600550010005500060550040600550006000000000000000000000000cc7ccc7ccccccccc4444444444444444444444444444446400000000
0a00a0000a00a0600a00a0000a00a060a00a00460a00a060000000000000000000000000ccccc777cccccccc44444444444d4444444444144544444400000000
020020000200200002002000020020002002066002002000000000000000000000000000cccccccccccccccc4444444444444444444444444444444400000000
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccc4454444444544544540550540000000000000000
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccc451515d4401505d0505555550000000000005000
0000000000000000000000000000000000000000000000000000000000000000cccccccccccccccccccccccc44551d5605001d06055055550445544004000000
0000000000000000000000000000000000000000000000000000000000000000cc3cccccccccccacccccc3cc4551555540510555550550550f4554f000500040
0000000000000000000000000000000000000000000000000000000000000000c3388ccccc3cc3cccc7ccc3c55d0545555d050050555555004ff4ff000000000
0000000000000000000000000000000000000000000000000000000000000000c3c8ccfcc3cecc3ccc3cc3cc5115555450150550550550550ff4ff4000005000
0000000000000000000000000000000000000000000000000000000000000000c3cccc3cc3ccc3cccc3ccc3c4651555446015004555555500f4ff4f004000000
00000000000000000000000000000000000000000000000000000000000000003333333333333333333333334444454444055444450550451111111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004404440100000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004001400000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004010440400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400444400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444014400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040104400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000140044400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000004004444400000000000000000000000000000000
__gff__
00000000000000000000070707070707000000000000000000080b04070707000000000000000000090909070703100b0000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1a1a1a1a1a1a1a1a1a1a1a1a1a1a191a0b0b0b0b0b0d0d0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a191a1a1a191a1a1a1a1a1a1a191a1a0b0c0d0c0c0d0d0d0e0e0d0d0f0d0f0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a1a1a191a1a1a1a1a1a1a1a1a0b0b0c0c0f0f0f0c0d0f0f0c0f0d0d0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a1a1a1a1a1a1a191a1a1a1a1a0b0c0b0d0d0b0b0b0b0a0d0c0f0d0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a1a191a1a1a1a1a1a1a191a1a0b0d0d0d0b0b0c0f0a0e0d0d0f0f0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a191a1a1a1a1a1a1a1a1a1a1a1a1a0b0d0d0b0b0d0f0f0e0e0e0d0d0f0c0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a0b0c0b0b0e0a0e0b0b0e0e0f0e0f0f0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c1c0b0c0d0b0e0e0b0f0e0e0e0f0a0b0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b1b0b0e0b0a0a0b0c0e0f0e0e0c0b0d0c0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0e0b0f0d0d0f0e0e0a0c0e0f0a0d0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0e0b0e0f0c0e0e0a0e0a0b0e0b0e0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0e0e0f0c0f0d0e0d0a0e0e0c0b0e0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0a0e0e0d0c0c0b0e0e0a0a0b0f0e0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0c0b0e0e0d0d0a0f0d0d0b0f0e0e0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0c0e0c0a0a0a0a0f0f0d0f0d0d0e0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000b0b0b0e0a0e0b0b0d0e0e0e0e0e0e0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d6500f6500d650000000d6500f650126502465012650146500d6500d6500f65012650016502925001650016500265003650046500465005650056500565005650056502465005650162501425025050
