
local composer = require( "composer" )

local scene = composer.newScene()

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
    	composer.removeScene('game')
    	composer.gotoScene('game')
    end
end


scene:addEventListener( "show", scene )


return scene