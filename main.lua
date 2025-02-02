local game_state = require("state.core")
local reducer = require("state.reducer")
local actions = game_state.actions
Logger = require("utils.logger")

local function load_img(file_name)
  return love.graphics.newImage("assets/" .. file_name)
end

local function load_cards(directory)
  local card_assets_dir = love.filesystem.getDirectoryItems(directory)
  CardImages = {}
  for _, card_asset in ipairs(card_assets_dir) do
    CardImages[card_asset] = load_img(card_asset)
  end
end

state = {}
state.menu = require("gamestates.menu")
state.highcard = require("gamestates.highcard")
state.samssupercoolcardstate = require("gamestates.samssupercoolcardstate")

-- initialize overlays
overlay = require("overlays.main")
overlay.menuOptions = require("overlays.menuOptions")
overlay.debug = require("overlays.debug")

function love.load()
  load_cards("assets")
  state.current = state.menu
end

---@param dt number: delta time
function love.update(dt)
  state.current.update(dt)
end

function love.keypressed(key)
  overlay.keypressed(key)
end

function love.mousereleased(x, y, button)
  overlay.mousereleased(x, y, button)
end

function love.draw(t)
  state.current.draw()
  overlay.draw()
end
