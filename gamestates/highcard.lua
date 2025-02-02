local M = {}
local game_state = require("state.core")
local og_reducer = require("state.reducer")
local meta_reducer = require("state.metareducer")

local reducer = meta_reducer.reduce(og_reducer.reduce)
local actions = game_state.actions
local buttonBoi = require("gameAssets.button")

local windowWidth, windowHeight = love.graphics.getDimensions()

local playerWidth = math.floor(windowWidth * 0.7)
local playerHeight = math.floor(windowHeight * 0.25)

local draggablex = 0
local draggabley = 0
local offsetx = 0
local offsety = 0
local PlayerCardLocations = {}
local GameState = game_state.initial_state
HANDLING_CARD = false
HANDLE_INDEX = nil
TRACK_INDEX = nil
WIDTH_OFFSET = 0.15

local buttons = {}

local function get_card_locations()
  if PlayerCardLocations then
    PlayerCardLocations = {}
  end
  if #GameState.game_state.hand.cards > 0 then
    for i, card in ipairs(GameState.game_state.hand.cards) do
      table.insert(PlayerCardLocations, i, card)
      PlayerCardLocations[i].x = playerWidth / (1 + #GameState.game_state.hand.cards) * i
        - (35 / 2)
        + windowWidth * WIDTH_OFFSET
      PlayerCardLocations[i].y = windowHeight * 0.85
    end
  end
end

local function get_hovering_details()
  --Card.x <= mouseX <= Card.x + 35
  --Card.y <= mouseY <= Card.y + 53
  local mouseX, mouseY = love.mouse.getPosition()
  for i, card in ipairs(PlayerCardLocations) do
    if mouseX - card.x <= 35 and mouseX - card.x >= 0 and mouseY - card.y <= 53 and mouseY - card.y >= 0 then
      return i, true
    end
  end
  return 0, false
end

---@param dt number: delta time
function M.update(dt)
  --check if mouse is hovering over card
  if love.mouse.isDown(1) then
    local cardIndex, isHovering = get_hovering_details()
    local totalCards = #PlayerCardLocations
    if isHovering and not HANDLING_CARD then --grab first card selected
      HANDLING_CARD = true
      HANDLE_INDEX = cardIndex
      TRACK_INDEX = cardIndex
      GameState = reducer(
        GameState,
        actions.GRAB_CARD({
          cardIndex = HANDLE_INDEX,
        })
      )
      draggablex, draggabley = love.mouse.getPosition()
      offsetx, offsety =
        PlayerCardLocations[HANDLE_INDEX].x - draggablex, PlayerCardLocations[HANDLE_INDEX].y - draggabley
      table.remove(PlayerCardLocations, HANDLE_INDEX)
    elseif isHovering and HANDLING_CARD then --only grab one card at a time, check if passed over new card
      draggablex, draggabley = love.mouse.getPosition()
    elseif not isHovering and HANDLING_CARD then --allows card to be dragged anywhere on screen
      --check x, y coordinates compared to other card Indecies
      draggablex, draggabley = love.mouse.getPosition()
      for i, loc in pairs(PlayerCardLocations) do
        if draggablex + offsetx > loc.x and i >= TRACK_INDEX then
          TRACK_INDEX = i + 1
        elseif draggablex + offsetx < loc.x and i < TRACK_INDEX then
          if i == 1 then
            TRACK_INDEX = i
          else
            TRACK_INDEX = i - 1
          end
        end
      end
    end
  else
    offsetx = 0
    offsety = 0
  end
end

function M.mousereleased(x, y, button)
  for i, v in pairs(buttons) do
    if button == 1 and buttonBoi.contains(v.x, v.y, v.width, v.height, x, y) then
      -- change state
    end
  end
  if button == 1 and HANDLING_CARD then
    GameState = reducer(
      GameState,
      actions.RELEASE_CARD({
        cardIndex = HANDLE_INDEX,
        trackIndex = TRACK_INDEX,
      })
    )
    get_card_locations()
    HANDLING_CARD = false
    HANDLE_INDEX = nil
  
  end

end

local function draw_stationary_card(imageName, index)
  love.graphics.draw(
    CardImages[imageName],
    playerWidth / (1 + #GameState.game_state.hand.cards) * index - (35 / 2) + windowWidth * WIDTH_OFFSET,
    windowHeight * 0.85
  )
end

local function draw_dragging_card(imageName)
  love.graphics.draw(CardImages[imageName], draggablex + offsetx, draggabley + offsety)
end

local function draw_debug_axis()
  local x = windowWidth / 2 - 2
  local y = 0
  local width = 4
  local height = windowHeight
  buttonBoi.create(x, y, width, height)
  buttonBoi.create(0, windowHeight / 2 - 2, windowWidth, 4)
end

function M.draw(t)
  -- center lines
  draw_debug_axis()
  local width = 200
  local height = 100
  local x = windowWidth - width
  local y = windowHeight / 2 - 2 - height / 2
  
  buttonBoi.create(x, y, width, height, { text = "bing bop boom boom boom bop bam" })
  table.insert(buttons, { x = x, y = y, width = width, height = height })

  -- player card area
  love.graphics.rectangle(
    "fill",
    math.floor(windowWidth * WIDTH_OFFSET),
    math.floor(windowHeight * 0.75),
    playerWidth,
    playerHeight
  )

  for i, card in ipairs(GameState.game_state.hand.cards) do
    local imageName = card.suit .. "-" .. card.rank .. ".png"
    if card.isStationary then
      draw_stationary_card(imageName, i)
    else
      draw_dragging_card(imageName)
    end
  end
end

function M.keypressed(k)
  if k == "f2" then
    overlay.push(overlay.debug)
  end
  if k == "escape" then
    state.current = state.menu
  end
  if k == "d" then
    GameState = reducer(GameState, actions.DRAW_CARD())
    get_card_locations()
  end
  if k == "n" then
    GameState = reducer(GameState, actions.NEW_GAME())
  end
end

return M
