local M = {}

local stack = {}

function M.draw()
  for i = 1, #stack do
    stack[i].draw() -- the stack is draw oldest to newest (in this case index 1 to #stack)
  end
end

function M.pop()
  stack[#stack] = nil
end

function M.popAll()
  stack = {}
end

function M.push(layer)
  stack[#stack + 1] = layer
end

function M.keypressed(key)
  for i = #stack, 1, -1 do
    if not stack[i].keypressed(key) then
      return
    end -- consume the keypress
  end
  state.current.keypressed(key)
end

function M.update(dt)
  for i = 1, #stack do
    stack[i].update(dt)
  end
  state.current.update(dt)
end

function M.mousereleased(x, y, button)
  
end

return M
