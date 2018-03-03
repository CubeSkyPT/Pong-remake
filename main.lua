push = require "push"

Class = require "class"
require "Paddle"
require "Ball"

WINDOW_WIDTH = 1920
WINDOW_HEIGHT= 1080

VIRTUAL_WIDTH = 432 -- Virtual resolution used by push so we can archieve a retro render style to Pong
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 250

PLAYER1 = "PLAYER1"
PLAYER2 = "PLAYER2"

--[[
-- Initialization
--]]

function love.load()

    love.graphics.setDefaultFilter("nearest","nearest") --Sets default filter for all images and fonts

    love.window.setTitle("Pong!")

    math.randomseed(os.time())

    servingPlayer = math.random(2) and 1 or 2

    smallFont = love.graphics.newFont("font.ttf", 8) --Creates a more retro font for small text
    mediumFont = love.graphics.newFont("font.ttf", 16) --Creates a larger font to display score
    scoreFont = love.graphics.newFont("font.ttf", 48) --Creates a larger font to display score
    love.graphics.setFont(smallFont)                 --and sets it by default


    sounds = { --simple sounds for ball colision and score
        ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static")
    }

    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = true,
        resizable = false,
        vsync = false
    })

    player1Score = 0
    player2Score = 0


    player1 = Paddle(5,30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-50, 5,20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gamestate = "start"

end

--[[
--INPUT DETECTION
--]]

function love.keypressed(key)

    if key == "escape" then
        love.event.quit()

    elseif key == "enter" or key == "return" then
        if gamestate == "start" then
            gamestate = "serve"
        elseif gamestate == "serve" then
            gamestate = "play"
        elseif gamestate == "gameover" then
            servingPlayer = math.random(2) and 1 or 2
            player1Score = 0
            player2Score = 0
            gamestate = "serve"
        end
    end
end

--[[
--UPDATE
--]]

function love.update(dt)

    if gamestate == "serve" then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    end
    --Player 1 movement

    -- AI CONTROL
    PLAYER1 = "AI" --IF AI is running, updates the bottom text to match it.
    PLAYER2 = "PLAYER1"
    if gamestate == "play" then
        if ball.x < VIRTUAL_WIDTH / 2 + 100 then  --Tries to follow the ball

            if player1.y + 10 > ball.y + 2 + 2  then
                player1.dy = -PADDLE_SPEED * 0.5
            elseif player1.y + 10 < ball.y + 2 - 2  then
                player1.dy = PADDLE_SPEED * 0.5
            else
                player1.dy = 0
            end

        elseif player1.y + 10 > VIRTUAL_HEIGHT / 2 + 10 then
            player1.dy = -PADDLE_SPEED * 0.6
        elseif player1.y + 10 < VIRTUAL_HEIGHT / 2 - 10 then
            player1.dy = PADDLE_SPEED * 0.6
        else
            player1.dy = 0;
        end
    end
    -- PLAYER CONTROL
    -- if love.keyboard.isDown("w") then
    --     player1.dy = -PADDLE_SPEED
    -- elseif love.keyboard.isDown("s") then
    --     player1.dy = PADDLE_SPEED
    -- else
    --     player1.dy = 0
    -- end

    --Player 2 movement
    if love.keyboard.isDown("up") then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gamestate == "play" then
        if ball:colides(player1) then
            ball.dx = -ball.dx * 1.06
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end

            sounds["paddle_hit"]:play()
        end

        if ball:colides(player2) then
            ball.dx = -ball.dx * 1.06 --if ball colides, reverses X velocity and makes ball faster
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end

            sounds["paddle_hit"]:play()
        end


        if ball.y <= 0 then  --checks colission with upper and bottom boundaries
            ball.y = 0
            ball.dy = -ball.dy
            sounds["wall_hit"]:play()
        end

        if ball.y >= VIRTUAL_HEIGHT-4 then
            ball.y = VIRTUAL_HEIGHT-4
            ball.dy = -ball.dy
            sounds["wall_hit"]:play()
        end

        if ball.x < 1 then  --Checks ball X to left and right boundaries, update scores and reset the ball
            servingPlayer = 1
             player2Score = player2Score + 1
             player1.dy = 0
             player2.dy = 0
             sounds["score"]:play()
             ball:reset()
             if player2Score >= 10 then
                 winningPlayer = 2
                 gamestate = "gameover"
             else
                 gamestate = "serve"
             end
        end

        if ball.x + 4 > VIRTUAL_WIDTH - 1 then
            servingPlayer = 2
            player1Score = player1Score + 1
            player1.dy = 0
            player2.dy = 0
            sounds["score"]:play()
            ball:reset()
            if player1Score >= 10 then
                winningPlayer = 1
                gamestate = "gameover"
            else
                gamestate = "serve"
            end
        end

        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

end




--[[
--DRAW
--]]

function love.draw()
    push:apply("start") -- starts rendering with virtual res

    love.graphics.clear(40,45,55,255) --Clears screen to a solid background color before rendering everything else
    love.graphics.setColor(255,255,255,210)


    love.graphics.rectangle("fill",0,0,VIRTUAL_WIDTH,1)
    love.graphics.rectangle("fill",0,VIRTUAL_HEIGHT-1,VIRTUAL_WIDTH,1)
    love.graphics.rectangle("fill",0,0,1,VIRTUAL_HEIGHT)
    love.graphics.rectangle("fill",VIRTUAL_WIDTH-1,0,1,VIRTUAL_HEIGHT)

    player1:render()
    player2:render()
    ball:render()
    displayFPS()

    love.graphics.setColor(255,255,255,230) --Sets opacity for score
    if gamestate == "start" then

        love.graphics.setFont(smallFont)
        love.graphics.printf( --prints to screen
            "Hello pong!",  --Text to render
            0,              --X coordinate
            4, --Y coordinate to center fullscreen
            VIRTUAL_WIDTH,   --alignment width so its centered
            "center")       --alignment mode

    elseif gamestate == "serve" then
        love.graphics.setFont(mediumFont)
        love.graphics.printf( --prints to screen
            "Serving Player: " .. tostring(servingPlayer),  --Text to render
            0,              --X coordinate
            4, --Y coordinate to center fullscreen
            VIRTUAL_WIDTH,   --alignment width so its centered
            "center")       --alignment mode

    elseif gamestate == "gameover" then
        love.graphics.printf( --prints to screen
            "Player " .. tostring(winningPlayer) .. " wins!",  --Text to render
            0,              --X coordinate
            15, --Y coordinate to center fullscreen
            VIRTUAL_WIDTH,   --alignment width so its centered
            "center")

            love.graphics.printf( --prints to screen
                "Press enter to restart.",  --Text to render
                0,              --X coordinate
                90, --Y coordinate to center fullscreen
                VIRTUAL_WIDTH,   --alignment width so its centered
                "center")
    end

    love.graphics.setColor(255,255,255,60) --Sets opacity for score
    love.graphics.setFont(smallFont)
    love.graphics.printf( --prints to screen
        PLAYER1,  --Text to render
        60,              --X coordinate
        220, --Y coordinate to center fullscreen
        VIRTUAL_WIDTH ,   --alignment width so its centered
        "left")

    love.graphics.printf( --prints to screen
        PLAYER2,  --Text to render
        -60,              --X coordinate
        220, --Y coordinate to center fullscreen
        VIRTUAL_WIDTH ,   --alignment width so its centered
        "right")

    --Score print
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(255,255,255,60) --Sets opacity for score

    love.graphics.printf(
    tostring(player1Score),
    -35,
    VIRTUAL_HEIGHT / 2 - 105,
    VIRTUAL_WIDTH,
    "center")

    love.graphics.printf(
    "-",
    0,
    VIRTUAL_HEIGHT / 2 - 105 ,
    VIRTUAL_WIDTH,
    "center")

    love.graphics.printf(
    tostring(player2Score),
    35,
    VIRTUAL_HEIGHT / 2 - 105,
    VIRTUAL_WIDTH,
    "center")

    love.graphics.setColor(255,255,255,255) --sets opacity back to 255

    --
    -- love.graphics.printf(
    -- tostring(player1Score),
    -- VIRTUAL_WIDTH / 2 - 50,
    -- VIRTUAL_HEIGHT / 3)



    push:apply("end") -- stops rendering with virtual res
end


function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,255,0,255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),10,10)
end
