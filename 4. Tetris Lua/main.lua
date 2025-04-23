local cols, rows = 8, 14
local cellSize = 30

local board = {}
local currentPiece = {}
local nextPiece = {}
local fallTimer = 0
local fallInterval = 0.5 

local tetrominoes = {
    {
        shape = {
            {1, 1, 1, 1},
        },
        color = {0, 1, 1}
    }, 
    {
        shape = {
            {1, 1},
            {1, 1},
        },
        color = {1, 1, 0}
    }, 
    {
        shape = {
            {0, 1, 0},
            {1, 1, 1},
        },
        color = {0.6, 0, 0.8}
    }, 
    {
        shape = {
            {1, 1, 0},
            {0, 1, 1},
        },
        color = {0, 1, 0}
    },
    
}

local function deepcopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do copy[k] = deepcopy(v) end
    return copy
end

local function initBoard()
    for y = 1, rows do
        board[y] = {}
        for x = 1, cols do
            board[y][x] = 0
        end
    end
end

local function spawnPiece()
    currentPiece = deepcopy(nextPiece)
    currentPiece.x = math.floor((cols - #currentPiece.shape[1]) / 2) + 1
    currentPiece.y = 1
    nextPiece = deepcopy(tetrominoes[love.math.random(#tetrominoes)])
end

local function checkCollision(shape, nx, ny)
    for sy = 1, #shape do
        for sx = 1, #shape[sy] do
            if shape[sy][sx] == 1 then
                local x = nx + sx - 1
                local y = ny + sy - 1
                if x < 1 or x > cols or y > rows or (y > 0 and board[y][x] ~= 0) then
                    return true
                end
            end
        end
    end
    return false
end

local function lockPiece()
    local shape = currentPiece.shape
    for sy = 1, #shape do
        for sx = 1, #shape[sy] do
            if shape[sy][sx] == 1 then
                local x = currentPiece.x + sx - 1
                local y = currentPiece.y + sy - 1
                if y > 0 then board[y][x] = currentPiece.color end
            end
        end
    end
end

local function clearLines()
    for y = rows, 1, -1 do
        local full = true
        for x = 1, cols do
            if board[y][x] == 0 then full = false; break end
        end
        if full then
            for yy = y, 2, -1 do
                board[yy] = deepcopy(board[yy-1])
            end
            board[1] = {}
            for x = 1, cols do board[1][x] = 0 end
            y = y + 1 
        end
    end
end

local function rotate(shape)
    local newShape = {}
    local h = #shape
    local w = #shape[1]
    for x = 1, w do
        newShape[x] = {}
        for y = h, 1, -1 do
            newShape[x][h-y+1] = shape[y][x]
        end
    end
    return newShape
end

function love.load()
    love.window.setMode(cols * cellSize, rows * cellSize)
    love.window.setTitle("Tetris")
    love.math.setRandomSeed(os.time())
    initBoard()
    nextPiece = deepcopy(tetrominoes[love.math.random(#tetrominoes)])
    spawnPiece()
end

function love.update(dt)
    fallTimer = fallTimer + dt
    if fallTimer >= fallInterval then
        fallTimer = fallTimer - fallInterval
        if not checkCollision(currentPiece.shape, currentPiece.x, currentPiece.y + 1) then
            currentPiece.y = currentPiece.y + 1
        else
            lockPiece()
            clearLines()
            spawnPiece()
            if checkCollision(currentPiece.shape, currentPiece.x, currentPiece.y) then
                initBoard()
            end
        end
    end
end

function love.draw()
    for y = 1, rows do
        for x = 1, cols do
            if board[y][x] ~= 0 then
                love.graphics.setColor(board[y][x])
                love.graphics.rectangle("fill", (x-1)*cellSize, (y-1)*cellSize, cellSize-1, cellSize-1)
            end
        end
    end
    love.graphics.setColor(currentPiece.color)
    for sy = 1, #currentPiece.shape do
        for sx = 1, #currentPiece.shape[sy] do
            if currentPiece.shape[sy][sx] == 1 then
                local x = currentPiece.x + sx - 1
                local y = currentPiece.y + sy - 1
                love.graphics.rectangle("fill", (x-1)*cellSize, (y-1)*cellSize, cellSize-1, cellSize-1)
            end
        end
    end
    love.graphics.setColor(1,1,1)
end

function love.keypressed(key)
    if key == "left" then
        if not checkCollision(currentPiece.shape, currentPiece.x - 1, currentPiece.y) then
            currentPiece.x = currentPiece.x - 1
        end
    elseif key == "right" then
        if not checkCollision(currentPiece.shape, currentPiece.x + 1, currentPiece.y) then
            currentPiece.x = currentPiece.x + 1
        end
    elseif key == "up"  then
        local rotated = rotate(currentPiece.shape)
        if not checkCollision(rotated, currentPiece.x, currentPiece.y) then
            currentPiece.shape = rotated
        end
    elseif key == "down" then
        -- hard drop
        while not checkCollision(currentPiece.shape, currentPiece.x, currentPiece.y + 1) do
            currentPiece.y = currentPiece.y + 1
        end
        fallTimer = fallInterval
    end
end
