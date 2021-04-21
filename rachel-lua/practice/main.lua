function love.load()
end

function love.update(dt)
end

function love.draw()
end
-- Include Simple Tiled Implementation into project
local sti = require "sti"

function love.load()
	-- Load map file
	map = sti("map.lua")
end

function love.update(dt)
	-- Update world
	map:update(dt)
end

function love.draw()
	-- Draw world
	map:draw()
end