-->8
-- game

function make_visible(self, x, y)
  local tile = self.world[y][x]
  if tile then
    if not tile.is_visible then
      tile.is_visible = true
      if tile.type == spr_empty then
        self:make_visible(x + 1, y)
        self:make_visible(x - 1, y)
        self:make_visible(x, y + 1)
        self:make_visible(x, y - 1)
      end
    end
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
  -- generate top ground layer and flowers
  game.generation_status = "generating ground layer..."
  yield()
  self.world[8] = {}
  self.world[9] = {}
  for j=1,16 do
    self.world[8][j] = make_tile(40 + rndi(3), j - 1, 7, true)
    self.world[9][j] = make_tile(27 + rndi(4), j - 1, 8, true)
  end
  -- generate underground
  for i=10,world_depth do self.world[i] = {} end
  generate_resource("coal", spr_coal, self.coal_amount, coal_probability, min_coal_cluster_size, max_coal_cluster_size)
  generate_resource("copper", spr_copper, self.copper_amount, copper_probability, min_copper_cluster_size, max_copper_cluster_size)
  generate_resource("iron", spr_iron, self.iron_amount, iron_probability, min_iron_cluster_size, max_iron_cluster_size)
  generate_resource("silver", spr_silver, self.silver_amount, silver_probability, min_silver_cluster_size, max_silver_cluster_size)
  generate_resource("gold", spr_gold, self.gold_amount, gold_probability, min_gold_cluster_size, max_gold_cluster_size)
  generate_resource("diamonds", spr_diamond, self.diamond_amount, diamond_probability, min_diamond_cluster_size, max_diamond_cluster_size)
  game.generation_status = "generating dirt..."
  yield()
  for i=10,world_depth do
    for j=1,16 do
      if not self.world[i][j] then
        self.world[i][j] = make_tile(spr_dirt + rndi(4), j - 1, i - 1)
      end
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
  elseif direction == up then
    return self.world[player.y_grid][player.x_grid + 1].can_dig
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
  if (direction == up) return self.world[y][x + 1]:dig()
end

function finish_run(self)
  self.state = "summary"
end

function update_game(self)
  player:update()
end

function draw_generating_status(self)
  cls()
  print(game.generation_status, 20, 20, blue)
end

function draw_summary(self)
  local coal = (player.resources[spr_coal] or 0)
  local copper = (player.resources[spr_copper] or 0)
  local iron = (player.resources[spr_iron] or 0)
  local silver = (player.resources[spr_silver] or 0)
  local gold = (player.resources[spr_gold] or 0)
  local diamond = (player.resources[spr_diamond] or 0)
  local total = coal + copper * 2 + iron * 3 + silver * 4 + gold * 5 + diamond * 6
  cls()
  print("run completed!", 20, 5, green)
  print("coal: " .. coal .. " x 1 = $" .. coal, 20, 20, red)
  print("copper: " .. copper .. " x 2 = $" .. copper, 20, 30, red)
  print("iron: " .. iron .. " x 3 = $" .. iron, 20, 40, red)
  print("silver: " .. silver .. " x 4 = $" .. silver, 20, 50, red)
  print("gold: " .. gold .. " x 5 = $" .. gold, 20, 60, red)
  print("diamond: " .. diamond .. " x 6 = $" .. diamond, 20, 70, red)
  print("total money earned: $" .. total, 20, 85, pink)
  player.money += total
end

function update_summary(self)
  if btnp(action) then
    game.state = "menu"
  end
end

function draw_game(self)
  cls()
  camera(0, player.camera_offset)
  for i,row in pairs(self.world) do
    for j,column in pairs(self.world[i]) do
      self.world[i][j]:draw()
    end
  end
  player:draw()
  camera(0, 0)
  hud:draw()
end

game = {
  coal_amount = 300,
  copper_amount = 250,
  iron_amount = 200,
  silver_amount = 150,
  gold_amount = 100,
  diamond_amount = 50,
  world = {},
  is_loading = true,
  generate_map = generate_map,
  draw_generating_status = draw_generating_status,
  can_move = can_move,
  can_dig = can_dig,
  has_floor = has_floor,
  dig = process_dig,
  init = init_game,
  finish_run = finish_run,
  update = update_game,
  draw = draw_game,
  draw_summary = draw_summary,
  update_summary = update_summary,
  make_visible = make_visible,
}
