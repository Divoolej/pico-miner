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
    self.pickaxe -= 1
    if (self.pickaxe <= 0) game:finish_run()
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
    if self.y > 80 then
      self.camera_offset += 2
    end
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
  elseif btn(up) then
    self.direction = up
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

function collect(self, collectible_type)
  self.resources[collectible_type] = (self.resources[collectible_type] or 0) + 1
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
  camera_offset = 0,
  resources = {},
  collect = collect,
  pickaxe = 24,
  x_grid = 8,
  y_grid = 7,
  current_sprite = 0,
  animation_frame = 0,
  state = "idle",
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
