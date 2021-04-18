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

function love.load()
  -- if arg[#arg] == "-debug" then require("mobdebug").start() end
    animation = newAnimation(love.graphics.newImage("Owlet_Monster_Run_6.png"), 32, 32, 1)
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
        oy = 0, -- sprite:getHeight() / 1.35
        direction = "down"
    }
        
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
            self.player.direction = "up"
        end

        --move player down
        if love.keyboard.isDown("s", "down") then
            goalY = self.player.y + speed
            self.player.direction = "down"
        end
        --move player left
        if love.keyboard.isDown("a", "left") then
            goalX = self.player.x - speed
            self.player.direction = "left"
        end
        -- move player right
        if love.keyboard.isDown("d", "right") then
            goalX = self.player.x + speed
            self.player.direction = "right"
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
                    --      for j,w in ipairs(v.layer.data) do
                    --          -- print(inspect(w))
                    --          love.graphics.rectangle('line', world:getRect(w))
                    --          -- os.exit() 
                    --      end
                    --  end
                    
                end
                

                -- love.graphics.rectangle('line', world:getRect(waterA))
                -- love.graphics.rectangle('line', world:getRect(waterB))
                -- love.graphics.rectangle('line', world:getRect(cliffA))
                -- love.graphics.rectangle('line', world:getRect(cliffB))
            end
        end
    end
end

local prev_x, prev_y

function love.update(dt)
   
    local scale = 2
	local screen_width = love.graphics.getWidth()/scale
	local screen_height = love.graphics.getHeight()/scale
    local player = map.layers["Sprites"].player
    prev_x = math.floor(player.x - screen_width/2)
    prev_y = math.floor(player.y - screen_height/2)

    -- Update world
    map:update(dt)
    --update animationanimation.currentTime=animation.currentTime+dt
    if animation.currentTime >= animation.duration then
            animation.currentTime = animation.currentTime - animation.duration
    end
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

    -- drawing my new sprite
    local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) +1
    love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum])
    
    --player coordinates
    font = love.graphics.newFont(28)
    love.graphics.setFont(font)
    love.graphics.print("player coords: (" .. tx ..",".. ty ..")", 10, 25)
    if prev_x == tx and prev_y == ty then
        love.graphics.print("stopped", 10, 50)
    else
        love.graphics.print("moving", 10, 50)
    end
    love.graphics.print(player.direction, 10, 75)
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

        return animation
    end