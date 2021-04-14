-- Include Simple Tiled Implementation into project
local inspect = require('inspect')
local bump = require('bump')
local world = bump.newWorld()
local sti = require "sti"

-- require "debug"

function love.conf(t)
	t.console = true
end

player = nil

function love.load()
  -- if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  love._openConsole()
    -- Load map file
    map = sti("newMap.lua", {"bump"})
    map:bump_init(world)
    -- Create new dynamic data layer called "Sprites" as the 8th layer
    local layer = map:addCustomLayer("Sprites", 6)
    -- get player spawn object
    for k, object in pairs(map.objects) do
        if object.name == "Player" then
                print("PLAYER IS DEFINED")
                player_init = true
                player = object
                world:add(player, player.x, player.y, player.width, player.height) -- x,y,width, height
                print("ADDED" .. inspect(player))
            break
        end
    end


    -- create player object
    local sprite = love.graphics.newImage("sprite.png")
    layer.player = {
        sprite = sprite,
        x = player.x,
        y = player.y,
        ox = sprite:getWidth() / 2,
        oy = sprite:getHeight() / 1.35
        }
        

-- stuff i put in because i dunno where it should go ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	

 -- love.graphics.setColor(255,255,255)
--[[
    local waterA = {type="water"}
    local waterB = {type="water"}

    world:add(waterA, 8*32, 0, 3*32, 9*32)
    world:add(waterB, 7*32, 11*32, 4*32, 8*32)
]]--
    local playerFilter = function (item, other)
        print("collide!@")
    	if other.type == "water" then return 'touch'
    	end
    end	

    -- world:update(player, player.x,player.y, 1, 1)
    -- local actualX, actualY, cols, len = world:move(player, player.x, player.y, playerFilter)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --add controls to player
    layer.update = function(self, dt) 
        -- 96 px per sec
        local speed = 96 * dt
        
        local goalX = self.player.x
        local goalY = self.player.y

        -- move player update
        if love.keyboard.isDown("w", "up") then
            goalY = self.player.y - speed
        end

        --move player down
        if love.keyboard.isDown("s", "down") then
            goalY = self.player.y + speed
        end
        --move player left
        if love.keyboard.isDown("a", "left") then
            goalX = self.player.x - speed
        end
        -- move player right
        if love.keyboard.isDown("d", "right") then
            goalX = self.player.x + speed
        end

        local actualX, actualY, cols, len = world:move(player, goalX, goalY, playerFilter)

        self.player.y = actualY
        self.player.x = actualX

        -- draw player
        layer.draw = function(self)
            love.graphics.draw(
                self.player.sprite,
                math.floor(self.player.x),
                math.floor(self.player.y),
                0,
                1,
                1,
                self.player.ox,
                self.player.oy
            )

            -- temp draw pt on map for sprite
            love.graphics.setPointSize(5)
            love.graphics.points(math.floor(self.player.x), math.floor(self.player.y))
            --map:removeLayer("Spawn Point")
        end
    end
end

function love.update(dt)
    -- Update world
    map:update(dt)
end

function love.draw()
	--scale world
	local scale = 2
	local screen_width = love.graphics.getWidth()/scale
	local screen_height = love.graphics.getHeight()/scale
    --trans world so player is centered
    local player = map.layers["Sprites"].player
    local tx = math.floor(player.x - screen_width/2)
    local ty = math.floor(player.y - screen_height/2)

    -- Draw world
    map:draw(-tx, -ty, scale)

    if world:hasItem(player) then
        love.graphics.setColor(255,0,0)
        print("PLAYER IS BEING USED")
        love.graphics.rectangle('line', world:getRect(player))
    end
end

--[[
function love.keypressed(key, u)
   --Debug
   if key == "lctrl" then --set to whatever key you want to use
      debug.debug()
   end
end
]]--