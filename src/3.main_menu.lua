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
