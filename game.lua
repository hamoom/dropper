display.setStatusBar( display.HiddenStatusBar )

local composer = require( "composer" )
local scene = composer.newScene()

local math2d = require 'plugin.math2d'
local phyics = require 'physics'
physics.start()
physics.setGravity( 0, 7 )

local player 
local blocks = {}
local addBlockTimer
local newScene = false

function scene:create( event )

    local sceneGroup = self.view 

    local color = 'red'
    for i = 1, 10 do 
		local block = display.newRect( 0, 0, 60, 2 )
		block.index = i
		block.name = 'block'
		block.isAlive = false
		block.isVisible = false
		physics.addBody( block, 'static' )
		block.collision = onCollision
		block:addEventListener( 'collision', block )
		blocks[i] = block
		block.color = color	
		color = switchColor(block)	
		sceneGroup:insert( block )

    end

	local ceiling = display.newRect(
		display.contentWidth/2, -2, 
		display.contentWidth, 2
	)
	physics.addBody( ceiling, 'static' )
	sceneGroup:insert( ceiling )

	local leftWall = display.newRect(
		0, display.contentHeight/2, 
		2, display.contentHeight 
	)
	physics.addBody( leftWall, 'static' )
	sceneGroup:insert( leftWall )

	local rightWall = display.newRect(
		display.contentWidth, display.contentHeight/2, 
		2, display.contentHeight 
	)
	physics.addBody( rightWall, 'static' )
	sceneGroup:insert( rightWall )

	player = display.newRect( 0, 0, 20, 20 )
	player.name = 'player'
	player.x = display.contentWidth / 2 
	player:setFillColor( 1, 0, 0 )
	player.color = 'red'
	physics.addBody( player, 'dynamic', {friction=1.0})
	player.collision = onCollision
	player:addEventListener( 'collision', player )
	player.isFixedRotation = true  
	sceneGroup:insert( player )
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
		Runtime:addEventListener( 'enterFrame', update )
		Runtime:addEventListener( 'touch', screenTouched )
		addBlockTimer = timer.performWithDelay( 800, addBlock, 0 )
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    	for k, block in pairs(blocks) do
    		block:removeEventListener( 'collision', block )
    	end
		Runtime:removeEventListener( 'enterFrame', update )
		Runtime:removeEventListener( 'touch', screenTouched )
		Runtime:removeEventListener( 'collision', onCollision)
		timer.cancel( addBlockTimer )
    elseif ( phase == "did" ) then
       
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end

-- function sign(num)
-- 	if num >= 0 then return 1 else return -1 end
-- end

-- function distance(x1, y1, x2, y2)
-- 	return math.sqrt( x1*x2 + y1*y2 )
-- end


function switchColor(obj)
	if obj.color == 'red' then
		obj:setFillColor(0, 1, 0)
		obj.color = 'green'
	elseif obj.color == 'green' then
		obj:setFillColor(0, 0, 1)
		obj.color = 'blue'
	elseif obj.color =='blue' then
		obj:setFillColor(1, 0, 0)
		obj.color = 'red'
	end	

	return obj.color
end	

function removeBlock(block)
	block.isAlive = false
	block.x = -1000
	block.y = -1000
end

function addBlock()
	for k, block in pairs(blocks) do
		if block.isAlive ~= true then
			block.contentWidth = 60
			block.contentHeight = 2
			block.isAlive = true
			block.isVisible = true

			block.x = math.random( 
				block.contentWidth/2 + 20, 
				display.contentWidth - block.contentWidth/2 - 20 
			)
			block.y = display.contentHeight
			break
		end
	end
end

function onCollision(self, e)
	if e.phase == 'began' then

		if self.color == e.other.color then

			local block
			if self.name == 'block' then
				block = self
			elseif e.other.name == 'block' then
				block = e.other
			end
			timer.performWithDelay(1, function() 
				switchColor(player)
				removeBlock(block) 
			end )
            
		elseif self.name == 'block' or e.other.name == 'block' then
			if newScene ~= true then
				newScene = true
				composer.gotoScene( 'tryagain' )
			end
		end
	end
end


function screenTouched(e)
	local direction = 1

	if e.x < player.x then
		direction = -1
	end

	player:setLinearVelocity(direction * 100, -100)
end

function update()

	for k, block in pairs(blocks) do
		if block.isAlive then
			block.y = block.y - 2.2
			if block.y < 0 then
				removeBlock(block)
			end
		end
	end

	if player.y > display.contentHeight then
		composer.gotoScene( 'tryagain' )
	end
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene








