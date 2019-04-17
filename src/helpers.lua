-->8
-- helpers

function rndi(n)
  return flr(rnd(n))
end

function coal_probability(y)
  return (-1/250)*(y-100)*(y-100)+75
end

function copper_probability(y)
  return (-1/275)*(y-125)*(y-125)+75
end

function iron_probability(y)
  return (-1/225)*(y-150)*(y-150)+80
end

function silver_probability(y)
  return (-1/225)*(y-200)*(y-200)+90
end

function gold_probability(y)
  return (-1/500)*(y-250)*(y-250)+75
end

function diamond_probability(y)
  return (-1/600)*(y-300)*(y-300)+75
end

function valid_position(row, column)
  return (
    column >= 1 and column <= 16 and
    row > 10 and row <= world_depth and
    not game.world[row][column]
  )
end

function make_tile(sprite, x, y, is_visible)
  return {
    type = sprite,
    frame = sprite,
    x = x * 8,
    y = y * 8,
    is_visible = is_visible,
    durability = durability_for_sprite[sprite] or 0,
    can_move = fget(sprite, flg_can_move),
    can_dig = fget(sprite, flg_can_dig),
    flip_h = fget(sprite, flg_flip_h) and rndi(2) == 1,
    flip_v = fget(sprite, flg_flip_v) and rndi(2) == 1,
    can_collect = fget(sprite, flg_can_collect),
    draw = function(self)
      if (self.is_visible) spr(self.frame, self.x, self.y, 1, 1, self.flip_h, self.flip_v)
    end,
    dig = function(self)
      self.durability -= 1
      self.frame += 1
      if self.durability <= 0 then
        if (self.can_collect) player:collect(self.type)
        self.type = spr_empty
        self.frame = spr_empty
        self.can_move = true
        self.can_dig = false
        self.is_visible = false -- Dirty hack to fix the first call to game:make_visible
        game:make_visible(self.x / 8 + 1, self.y / 8 + 1)
      end
    end,
  }
end

function generate_cluster(row, column, sprite, cluster_size)
  local n = 0
  if valid_position(row, column) then
    game.world[row][column] = make_tile(sprite, column - 1, row - 1, false)
    n += 1
  end
  local current_x_offset = rndi(3)
  local target_x_offset = (current_x_offset - 1) % 3
  while (current_x_offset != target_x_offset) do
    local current_y_offset = rndi(3)
    local target_y_offset = (current_y_offset - 1) % 3
    while (current_y_offset != target_y_offset) do
      if (n == cluster_size) return n
      if valid_position(row + (current_y_offset - 1), column + (current_x_offset - 1)) then
        n += generate_cluster(row + (current_y_offset - 1), column + (current_x_offset - 1), sprite, cluster_size - n)
      end
      current_y_offset = (current_y_offset + 1) % 3
    end
    current_x_offset = (current_x_offset + 1) % 3
  end
  return n
end

function check_cluster_availability(row, column, cluster_size)
  local n = 0
  if (valid_position(row - 1, column - 1)) n += 1
  if (valid_position(row - 1, column)) n += 1
  if (valid_position(row, column - 1)) n += 1
  if (valid_position(row, column)) n += 1
  if (valid_position(row, column + 1)) n += 1
  if (valid_position(row + 1, column - 1)) n += 1
  if (valid_position(row + 1, column)) n += 1
  if (valid_position(row + 1, column + 1)) n += 1
  return n >= cluster_size
end

function generate_resource(name, sprite, amount, probability_function, min_cluster_size, max_cluster_size)
  game.generation_status = "generating " .. name .. "..."
  yield()
  local n = 0
  while n < amount do
    i = rndi(world_depth - 9) + 10
    if rnd(100) < probability_function(i) then
      j = rndi(16) + 1
      local cluster_size = rndi(
        max_cluster_size - min_cluster_size + 1
      ) + min_cluster_size
      if check_cluster_availability(i, j, cluster_size) then
        n += generate_cluster(i, j, sprite, cluster_size)
      end
    end
  end
end
