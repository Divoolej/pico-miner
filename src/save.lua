local money_addr = 0x5e00
local player_lvl_addr = money_addr + 4
local pickaxe_lvl_addr = player_lvl_addr + 1

function load_progress()
  cartdata("divoolej_pico-miner_1")
  player_lvl = peek(player_lvl_addr)
  if player_lvl > 0 then
    money = peek4(money_addr)
    pickaxe_lvl = peek(player_lvl_addr)
  end
end

function reset_progress()
  poke(money_addr, 0)
  poke(player_lvl_addr, 0)
  poke(pickaxe_lvl_addr, 0)
end

function save_progress()
  poke4(money_addr, player.money)
  poke(player_lvl_addr, player.level)
  poke(pickaxe_lvl_addr, player.pickaxe_level)
end

save = {
  load_progress = load_progress,
  reset_progress = reset_progress,
  save_progress = save_progress,
}
