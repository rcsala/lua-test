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

local TILE_HEIGHT = 32
local TILE_WIDTH = 32

local SCALE = 2
local SCREEN_WIDTH = love.graphics.getWidth()/SCALE
local SCREEN_HEIGHT = love.graphics.getHeight()/SCALE

function get_player()
    return map.layers["Sprites"].player
end 

function love.conf(t)
	t.console = true
end

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

    layer.player = {
        animation = newAnimation(love.graphics.newImage("pipo-nekonin001.png"), 32, 32 , .5),
        spriteNum = -1,
        px = player.x,
        py = player.y,
        ox = 0, -- sprite:getWidth() / 2,
        oy = 0, -- sprite:getHeight() / 1.35
        direction = "down",
        prev_x = 0,
        prev_y = 0,
        cameraPX = function() -- this calculates the pixel-wise x of the top-left corner of the current screen 
            return math.floor(layer.player.px - SCREEN_WIDTH/2)
        end,
        cameraPY = function() -- this calculates the pixel-wise Y of the top-left corner of the current screen 
            return math.floor(layer.player.py - SCREEN_WIDTH/2)
        end,
        tx = function() -- this calculates the tile-wise x of the player on the tilemap 
            return math.floor(layer.player.px / TILE_HEIGHT)
        end,
        ty = function() -- this calculates the tile-wise y of the player on the tilemap 
            return math.floor(layer.player.py / TILE_WIDTH)
        end
    }

    layer.player.is_moving = function()
        return not (layer.player.prev_x == layer.player.px and layer.player.prev_y == layer.player.py)
    end
        
    local playerFilter = function (item, other)
    	if other.layer.properties.collidable then return 'touch'
    	end
    end	

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --add controls to player
    layer.update = function(self, dt) 
        -- 96 px per sec
        local speed = 96 * dt
        
        local goalX = self.player.px
        local goalY = self.player.py

        -- move player update
        if love.keyboard.isDown("w", "up") then
            goalY = self.player.py - speed
            self.player.direction = "up"
        end

        --move player down
        if love.keyboard.isDown("s", "down") then
            goalY = self.player.py + speed
            self.player.direction = "down"
        end
        --move player left
        if love.keyboard.isDown("a", "left") then
            goalX = self.player.px - speed
            self.player.direction = "left"
        end
        -- move player right
        if love.keyboard.isDown("d", "right") then
            goalX = self.player.px + speed
            self.player.direction = "right"
        end

        local actualX, actualY, cols, len = world:move(player, goalX, goalY, playerFilter)

        self.player.py = actualY
        self.player.px = actualX

        -- draw player
        layer.draw = function(self)
           
            love.graphics.draw(
                self.player.animation.spriteSheet, 
                self.player.animation.get_frame(self.player.direction, self.player.is_moving()),
                math.floor(self.player.px),
                math.floor(self.player.py),
                0,
                1,
                1,
                self.player.ox,
                self.player.oy
            )

            -- temp draw pt on map for sprite
            love.graphics.setPointSize(5)
            love.graphics.points(math.floor(self.player.px), math.floor(self.player.py))
            --map:removeLayer("Spawn Point")
            
            if world:hasItem(player) then
                love.graphics.setColor(255,0,0)
                love.graphics.rectangle('line', world:getRect(player)) --red rect around player

                for i,v in ipairs(map.bump_collidables) do --red rect around collideables
                    love.graphics.rectangle('line', world:getRect(v))                   
                end
            end
            if world:hasItem(player) and self.player.is_moving() 
                then 
                love.graphics.setColor(0, 255, 0)
                love.graphics.rectangle('line', world:getRect(player))
            end 
            
        end
    end
end

function love.update(dt)
   

    local player = map.layers["Sprites"].player
    player.prev_x = player.cameraPX()
    player.prev_y = player.cameraPY()

    -- Update world
    map:update(dt)
    

    local player = map.layers["Sprites"].player

    player.animation.currentTime = player.animation.currentTime + dt
    if player.animation.currentTime >= player.animation.duration then
            player.animation.currentTime = player.animation.currentTime - player.animation.duration
    end
end

function love.draw()
    --translate world so player is centered
    local player = get_player()

    -- Draw world
    map:draw(-player.cameraPX(), -player.cameraPY(), SCALE)
    
    --player coordinates
    font = love.graphics.newFont(28)
    love.graphics.setFont(font)
    love.graphics.print("player coords: (" .. player.cameraPX() ..",".. player.cameraPY() ..")", 10, 25)
    if player.is_moving() then
        love.graphics.print("moving", 10, 50)
    else
        love.graphics.print("stopped", 10, 50)
    end
    love.graphics.print(player.direction, 10, 75)
    love.graphics.print("drawing frame: " .. player.animation.curFrame, 10, 100)
    love.graphics.print("x coord:" .. player.tx(), 10, 125)
    love.graphics.print("y coord:" .. player.ty(), 10, 150)
    
end


--[[
function love.keypressed(key, u)
   --Debug
   if key == "lctrl" then --set to whatever key you want to use
      debug.debug()
   end
end
]]--

function newAnimation(image, width, height, duration)
   
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {}

    for y=0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad (x,y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    animation.get_frame = function( direction, isMoving )

        -- animation.curFrame = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1

        if not isMoving then
            if     direction == "up" then animation.curFrame = 11
            elseif direction == "down" then animation.curFrame = 2
            elseif direction == "left" then animation.curFrame = 5
            elseif direction == "right" then animation.curFrame = 8
            else 
                error("invalid direction: " .. direction)
            end
        else
            local firstFrameOfDirection = nil
            if     direction == "up" then firstFrameOfDirection = 10
            elseif direction == "down" then firstFrameOfDirection = 1
            elseif direction == "left" then firstFrameOfDirection = 4
            elseif direction == "right" then firstFrameOfDirection = 7
            else 
                error("invalid direction: " .. direction)
            end

            animation.curFrame = math.floor(animation.currentTime / animation.duration * 3) + firstFrameOfDirection
        end

        return animation.quads[animation.curFrame]
    end

    return animation
end