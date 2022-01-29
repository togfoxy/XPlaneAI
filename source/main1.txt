--
--
--

inspect = require 'lib.inspect'
bt = require 'binarytree'

dataset = {}                    -- raw data
solutiontree = {}
functioncategories = {}         -- the unique number of categories for each feature. Determines root

local function getDataset()

    for i = 1, 50 do
        dataset[i] = {}

        -- AGL
        dataset[i][1] = love.math.random(0,9)

        -- pitch
        if dataset[i][1] == 0 then
            dataset[i][2] = 0
        else
            dataset[i][2] = 1
        end

        -- airspeed
        if dataset[i][1] == 0 then
            dataset[i][3] = love.math.random(30, 149)
        else
            dataset[i][3] = love.math.random(135, 199)
        end

        -- gear
        if dataset[i][1] == 0 then
            dataset[i][4] = 1
        elseif dataset[i][1] <= 3 and love.math.random(1,100) <= 25 then
            dataset[i][4] = 0
        elseif dataset[i][1] <= 6 and love.math.random(1,100) <= 75 then
            dataset[i][4] = 0
        else
            dataset[i][4] = 0
        end

        -- app
        if dataset[i][1] <= 3 then
            dataset[i][5] = 0
        elseif dataset[i][1] <= 6 and love.math.random(1,100) <= 50 then
            dataset[i][5] = 1
        else
            dataset[i][5] = 1
        end

        -- flaps
        if dataset[i][1] <= 3 then
            dataset[i][6] = 2
        elseif dataset[i][1] <= 5 and love.math.random(1,100) <= 33 then
            dataset[i][6] = 2
        elseif dataset[i][1] <= 7 and love.math.random(1,100) <= 75 then
            dataset[i][6] = 1
        else
            dataset[i][6] = 0
        end

    end
end

local function getUniqueCategories(feature)
    -- feature is the paremeter/index number e.g feature 1 = AGL, feature 2 = pitch etc

    local uniqueset = {}
    local featurevalue = nil
    local uniquesetcount = 0    -- counts the unique values for this function

    for datasetindex, datasetrow in pairs(dataset) do
        -- print(dataset[datasetindex][feature])
        featurevalue = dataset[datasetindex][feature]       -- this is the actual raw value for this feature

        if uniqueset[featurevalue] == nil then
            -- this is a unique value so count it
            uniqueset[featurevalue] = 1
            uniquesetcount = uniquesetcount + 1
    -- print(uniquesetcount, featurevalue, uniqueset[featurevalue])
        end
    end
    -- print("***")
    -- print(inspect(uniqueset))
    return uniquesetcount
end

local function getLowestCategories(categorycount)

    local lowestvalue = -1
    local lowestindex = nil

    for k, v in pairs(categorycount) do
    -- print(k,v)
        if lowestvalue == -1 or v < lowestvalue then
            lowestvalue = v
            lowestindex = k
        end
    end
    assert(lowestindex ~= nil)
    return lowestindex
end

function love.load()

    getDataset()

    -- print(inspect(dataset))

    -- the root is the one that is the most divisive ie the LEAST categories
    -- functioncategories holds the number of distinct items in each function
    functioncategories[1] = getUniqueCategories(1)
    functioncategories[2] = getUniqueCategories(2)
    functioncategories[3] = getUniqueCategories(3)

    -- print(functioncategories[1], functioncategories[2], functioncategories[3])

    -- determine the function that has the least number of distinct categories
    local bestfunction = getLowestCategories(functioncategories)      -- a number reflecting which function should be the root

    -- make this the root
    solutiontree = bt.newbt(bestfunction)

    -- remove that function from the dataset and determine the next best function
    functioncategories[bestfunction] = nil

    local bestfunction = getLowestCategories(functioncategories)
    bt.insertbt(solutiontree, bt.newbt(bestfunction))
    functioncategories[bestfunction] = nil

    local bestfunction = getLowestCategories(functioncategories)
    bt.insertbt(solutiontree, bt.newbt(bestfunction))
    functioncategories[bestfunction] = nil

    -- print(inspect(solutiontree))
    -- ** tree now complete ** --



end
