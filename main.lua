-- Include Simple Tiled Implementation into project
local inspect = require('inspect')
--local world = bump.newWorld()
--local map = sti("map.lua", {"bump"})
local sti = require "sti"
local bump = require 'bump'
local world = bump.newWorld()

local map = sti('newMap.lua', {"bump"})
map: bump_init(world)

-- require "debug"

function love.conf(t)
	t.console = true
end

--player = nil

function love.load()
  -- if arg[#arg] == "-debug" then require("mobdebug").start() end
  
    love._openConsole()
    -- Load map file ~~~~~~~~~~ remove these
    --map = sti("newMap.lua", {"bump"})
    --map:bump_init(world)
    -- Create new dynamic data layer called "Sprites" as the 8th layer
    local layer = map:addCustomLayer("Sprites", 6)
    -- get player spawn object
    for k, object in pairs(map.objects) do
        if object.name == "Player" then
                player_init = true
                player = object
                world:add(player, player.x-0, player.y-0, player.width, player.height) -- x,y,width, height
            break
        end
    end


    -- create player object
    local sprite = love.graphics.newImage("sprite.png")
    layer.player = {
        sprite = sprite,
        x = player.x,
        y = player.y,
        ox = 0, -- sprite:getWidth() / 2,
        oy = 0 -- sprite:getHeight() / 1.35
        }
        

-- stuff i put in because i dunno where it should go ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
    -- local waterA = {type="water"}
    -- local waterB = {type="water"}
    -- local cliffA = {type="cliff"}
    -- local cliffB = {type="cliff"}

    -- world:add(waterA, 7*32, 0, 5*32, 10*32)
    -- world:add(waterB, 7*32, 11*32, 5*32, 8*32)
    -- world:add(cliffA)
    -- world:add(cliffB)

    local playerFilter = function (item, other)
    	if other.layer.properties.collidable then return 'touch'
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

            if world:hasItem(player) then
                love.graphics.setColor(255,0,0)
                love.graphics.rectangle('line', world:getRect(player))

                for i,v in ipairs(map.bump_collidables) do 
                    love.graphics.rectangle('line', world:getRect(v))
                        -- if v.layer ~= nil then
--                         for j,w in ipairs(v.layer.data) do
-- -- print(inspect(w))
--                             love.graphics.rectangle('line', world:getRect(w))
--                             -- os.exit() 
--                         end
--                     end
                    
                end
                

                -- love.graphics.rectangle('line', world:getRect(waterA))
                -- love.graphics.rectangle('line', world:getRect(waterB))
                -- love.graphics.rectangle('line', world:getRect(cliffA))
                -- love.graphics.rectangle('line', world:getRect(cliffB))
            end
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
end


--[[
function love.keypressed(key, u)
   --Debug
   if key == "lctrl" then --set to whatever key you want to use
      debug.debug()
   end
end
]]--