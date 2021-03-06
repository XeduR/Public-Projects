--[[
	"Get A Job, Baby!" is a game written by Eetu Rantanen for Ludum Dare 45

	Copyright (C) 2019 - Spyric Entertainment

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]--

-- This template.lua can be copied and used to create new gameModes/jobs with ease.

local composer = require( "composer" )
local screen = require( "scripts.screen" )
local settings = require( "data.settings" )
local physics = physics or require("physics")
local sfx = require( "scripts.sfx" )

local mask = graphics.newMask( "images/mask.png" )
local repeatScene, sceneGroupRef = false
local gameEnd, player, countdown, startTime, updateTimer
local gameScore, rate = 0, 0

local ground

local groupUI = display.newGroup()
local groupGame = display.newGroup()
local groupBG = display.newGroup()

-------------------------------------------------------------------------------

local numberOfFish = 6
local countdownTime = 15000
local fishScoreMultiplier = 0.01
local throwTimeMax = 500

-------------------------------------------------------------------------------

local function gameStart()
	transition.to( sceneGroupRef, { delay=500, time=2000, maskScaleX=composer.scaleMaskTo, maskScaleY=composer.scaleMaskTo, transition=easing.outInBack, onComplete=function()
			G_block.isHitTestable = false
			physics.start()
			gameScore = 0
			sceneGroupRef:setMask( nil )



			startTime = system.getTimer()
			Runtime:addEventListener( "enterFrame", updateTimer )
		end
	})
end

function gameEnd()
	G_block.isHitTestable = true
	physics.pause()
	-- physics.removeBody( ground )

	sceneGroupRef:setMask( mask )
	sceneGroupRef.maskX = player.x
	sceneGroupRef.maskY = player.y
	sceneGroupRef.maskScaleX = composer.scaleMaskTo
	sceneGroupRef.maskScaleY = composer.scaleMaskTo

	transition.to( sceneGroupRef, { delay=settings.mask.hideDelay, time=settings.mask.hideTime, transition=settings.mask.hideEasing, maskScaleX=0.01, maskScaleY=0.01, onComplete=function()
			for i = groupGame.numChildren, 1, -1 do
				display.remove( groupGame[i] )
				groupGame[i] = nil
			end

			if repeatScene then
				gameScore = 0
				G_performance.text = "$0 - 100%"
				gameStart()
			else
				composer.gotoScene( "scenes.calendar", { params = { score=gameScore, rate=rate}} )
			end
		end
	})
end


function updateTimer()
	local ratio = 1 - (system.getTimer() - startTime) / countdownTime

	if ratio > 0 then
		countdown.xScale = ratio
	else
		Runtime:removeEventListener( "enterFrame", updateTimer )
		gameEnd()
	end
end


-------------------------------------------------------------------------------


-------------------------------------------------------------------------------

local scene = composer.newScene()

function scene:create( event )
	local sceneGroup = self.view
	sceneGroupRef = sceneGroup

	if event.params and event.params.repeatScene then
		repeatScene = true
	end

	local sky = display.newRect( groupBG, screen.centreX, screen.centreY, screen.width, screen.height )
	sky:setFillColor( unpack( settings.colours.sky ) )

	ground = display.newRect( groupBG, screen.maxX, screen.maxY, 200, 340 )
	ground:setFillColor( unpack( settings.colours.ground ) )
	ground.anchorX, ground.anchorY = 1, 1

	player = display.newRect( groupBG, ground.x - ground.width + 3, ground.y - ground.height - 10, 20, 20 )
	player:setFillColor( unpack( settings.colours.player ) )

	countdown = display.newRect( groupUI, screen.minX, screen.maxY, screen.width, 24 )
	countdown.anchorX, countdown.anchorY = 0, 1

	local title = display.newText( groupUI, "Simple instructions", screen.centreX, screen.minY + 4, "fonts/Roboto-Black.ttf", 40 )
	title.anchorY = 0
	title:setFillColor( unpack( settings.colours.b ) )

	sceneGroup:setMask( mask )
	sceneGroup.maskX = player.x
	sceneGroup.maskY = player.y
	sceneGroup.maskScaleX = 0.01
	sceneGroup.maskScaleY = 0.01

	sceneGroup:insert( groupBG )
	sceneGroup:insert( groupGame )
	sceneGroup:insert( groupUI )
end


function scene:show( event )
    if event.phase == "did" then
		gameStart()
	end
end

-------------------------------------------------------------------------------

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )

-------------------------------------------------------------------------------

return scene
