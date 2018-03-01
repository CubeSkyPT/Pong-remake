Paddle = Class{}


function Paddle:init(x,y,width,height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    --updates paddle y coordinate, imposing limit to border
    if self.dy < 0 then
        self.y = math.max(1, self.y + self.dy * dt)--moves left paddle up
        --prevents paddles from going above top and bottom border(that is 1px large)


    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height - 1,self.y + self.dy * dt)
    end
end

function Paddle:render(dt)
    love.graphics.rectangle("fill",self.x,self.y,self.width,self.height)
end
