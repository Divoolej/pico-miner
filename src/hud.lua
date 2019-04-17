function draw_hud(self)
  rectfill(0, 0, 128, 8, black)
  local depth = "depth: " .. (player.y_grid - 7)
  local durability = "pickaxe: " .. player.pickaxe
  print(depth .. " " .. durability, 8, 2, red)
end

hud = {
  draw = draw_hud,
}
