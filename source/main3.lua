inspect = require 'lib.inspect'
tr = require 'tree'
cf = require 'lib.commonfunctions'

dataset = {}
rawdata = {}
cleandata = {}
solutiontree = {}

NUMBEROFDATAPOINTS = 50

NUMBEROFFUNCTIONS = 3       -- function = state or environment variable (e.g AGL, pitch, airspeed)

local function getDataset()
    -- sets the global variable dataset to random values

    for i = 1, NUMBEROFDATAPOINTS do
        dataset[i] = {}

        -- AGL
        dataset[i][1] = love.math.random(1,2) - 1

        -- pitch
        if dataset[i][1] == 0 then
            if love.math.random(1,100) <= 85 then
                dataset[i][2] = 0
            else
                dataset[i][2] = 1
            end
        else
            dataset[i][2] = 1
        end

        -- airspeed
        if dataset[i][1] == 0 then      -- AGL
            if love.math.random(1,100) < 90 then
                dataset[i][3] = 0
            else
                dataset[i][3] = 1
            end
        else

            if love.math.random(1,100) <= 75 then
                dataset[i][3] = 1
            else
                dataset[i][3] = 0
            end

        end

        -- ** outcomes/states/results **

        -- gear.  1 == down
        local rndnum = love.math.random(1,100)
        if dataset[i][1] == 0 then  -- agl
            if love.math.random(1,100) <= 75 then
                dataset[i][4] = 0
            else
                dataset[i][4] = 1
            end
        else
            if love.math.random(1,100) <= 75 then
                dataset[i][4] = 1
            else
                dataset[i][4] = 0
            end
        end

        -- -- ap
        -- if dataset[i][1] <= 3 then
        --     dataset[i][5] = 0
        -- elseif dataset[i][1] <= 6 and love.math.random(1,100) <= 50 then
        --     dataset[i][5] = 1
        -- else
        --     dataset[i][5] = 1
        -- end
        --
        -- -- flaps
        -- if dataset[i][1] <= 3 then
        --     dataset[i][6] = 2
        -- elseif dataset[i][1] <= 5 and love.math.random(1,100) <= 33 then
        --     dataset[i][6] = 2
        -- elseif dataset[i][1] <= 7 and love.math.random(1,100) <= 75 then
        --     dataset[i][6] = 1
        -- else
        --     dataset[i][6] = 0
        -- end

    end
end

local function getCountOfPositiveSamples(ds)
    -- ds = dataset
    local result = 0

    for k, v in pairs(ds) do
        if ds[k][4] == 1 then
            result = result + 1
        end
    end
    return result
end

local function getCountOfNegativeSamples(ds)
    -- ds = dataset
    local result = 0

    for k, v in pairs(ds) do
        if ds[k][4] == 0 then
            result = result + 1
        end
    end
    return result
end

local function getCountOfPositiveSamplesForFunction(ds, functionnumber, testnumber)
    -- for functionnumber, determine how many times gear (testnumber) is down for each category of functionnumber
    -- testnumber is the thing we're testing for a positive outcome (eg. is gear down means testnumber = 4)
    local result = {}
    for i = 1 , #ds do
        if ds[i][testnumber] == 1 then      -- testnumber == 4 for landing gear
            -- found a positive case
            -- get the actual value for this function
            local val = ds[i][functionnumber]   -- this is the AGL value (e.g 500 feet)
            if result[val] == nil then
                result[val] = 1
            else
                result[val] = result[val] + 1
            end
        end
    end
    return result
end

local function getCountOfNegativeSamplesForFunction(ds, functionnumber, testnumber)
    -- for functionnumber, determine how many times gear (testnumber) is down for each category of functionnumber
    -- testnumber is the thing we're testing for a positive outcome (eg. is gear down means testnumber = 4)
    local result = {}
    for i = 1 , #ds do
        if ds[i][testnumber] == 0 then      -- testnumber == 4 for landing gear
            -- found a positive case
            -- get the actual value for this function
            local val = ds[i][functionnumber]   -- this is the AGL value (e.g 500 feet)
            if result[val] == nil then
                result[val] = 1
            else
                result[val] = result[val] + 1
            end
        end
    end
    return result
end

local function printDataset(ds)
    print("index", "AGL", "pitch","air s", "gear", "autop", "flaps")
    for i = 1, #ds do
        print(i, ds[i][1], ds[i][2], ds[i][3], ds[i][4], ds[i][5], ds[i][6] )
    end
end

local function getSupersetOfValuesForFunction(parray, narray, functionnumber)
    -- return the union of values from positive array and negative array
    -- for given function number

    -- positive array
    local result = {}
    for k, v in pairs(parray[functionnumber]) do
        if result[k] == nil then
            result[k] = v
        else
            result[k] = result[k] + v
        end
    end

    -- negative array
    for k, v in pairs(narray[functionnumber]) do
        if result[k] == nil then
            result[k] = v
        else
            result[k] = result[k] + v
        end
    end
    return result
end

local function getEntropy(posvalue, negvalue)
    -- posvalue = number of positive instances in the sample
    -- negative = number of positive instances in the sample
    -- totalvalue = number of samples

    if posvalue == nil or tostring(posvalue) == 'nan' then posvalue = 0 end
    if negvalue == nil or tostring(negvalue) == 'nan' then negvalue = 0 end

    totalvalue = posvalue + negvalue

    -- print("psvalue: ".. posvalue, "negvalue: " .. negvalue)

    local posbit, negbit
    if posvalue > 0 then
        posbit = ((posvalue/totalvalue) * math.log(posvalue/totalvalue,2))
    else
        posbit = 0
    end
    if negvalue > 0 then
        negbit = ((negvalue/totalvalue) * math.log(negvalue/totalvalue,2))
    else
        negbit = 0
    end

    -- print("Posbit: " .. posbit, "Negbit: " .. negbit)
    -- return -1 * (((posvalue/totalvalue) * math.log(posvalue/totalvalue,2)) + ( (negvalue/totalvalue) * math.log(negvalue/totalvalue,2) ))
    return -1 * (posbit + negbit)
end

local function DetermineTotalEntropy()
    -- should gear be down (1)?
    numofpositivesamples = getCountOfPositiveSamples(dataset, 1, 1)   -- gear == 1
    numofnegativesamples = getCountOfNegativeSamples(dataset, 1, 1)
    numofsamples = numofpositivesamples + numofnegativesamples

    entropy = getEntropy(numofpositivesamples, numofnegativesamples)
end

-- ************************************************************************************************************************************

getDataset()

printDataset(dataset)

DetermineTotalEntropy()

print("Total entropy is " .. cf.round(entropy,4))  -- values close to 100 = impure
print()

-- determine information gain
local bestfeature = -1
local bestfeaturegain = 0
local gain = {}
for i = 1, NUMBEROFFUNCTIONS do

    -- for function x
    -- get all the positives
    positiveSamplesForFunction = {}
    positiveSamplesForFunction[i] = getCountOfPositiveSamplesForFunction(dataset, i, 4)        -- 1 == AGL. 4 == gear
    --print"ooo - positive samples"
    --print("value - count")
    for e,r in pairs(positiveSamplesForFunction[i]) do
        --print(e,r)
    end

    -- get all the negatives
    negativeSamplesForFunction = {}
    negativeSamplesForFunction[i] = getCountOfNegativeSamplesForFunction(dataset, i, 4)
    --print"*** - negative samples"
    --print("value - count")
    for e,r in pairs(negativeSamplesForFunction[i]) do
        --print(e,r)
    end

    -- determine the superset of possible values for function x
    --print("---")
    superset = {}
    superset = getSupersetOfValuesForFunction(positiveSamplesForFunction,negativeSamplesForFunction, i)
      -- print("superset of values for function " .. i .. " is:")
    for k,v in pairs(superset) do
        -- print(k, v)
    end

    --print("+++")
    --print("Entropy for each value:")
    -- get the entropy for each value in the function
    ent = {}
    for k, v in pairs(superset) do
        -- print(k, positiveSamplesForFunction[i][k], negativeSamplesForFunction[i][k])
        ent[k] = getEntropy(positiveSamplesForFunction[i][k], negativeSamplesForFunction[i][k])
        --print(k, ent[k])
     end
    --print("~~~")

    -- finally - information gain
    local mysum = 0
    for k,v in pairs(superset) do
        mysum = mysum +  (v / NUMBEROFDATAPOINTS) * ent[k]
    end
    gain[i] = entropy - mysum
    print("Gain for function " .. i .. " is: " .. gain[i])

    if gain[i] > bestfeaturegain then
        -- this is a potential branch
        bestfeaturegain = gain[i]
        bestfeature = i
    end
end

print("---")
print("Best feature is " .. bestfeature)

if #solutiontree == 0 then
    solutiontree = tr.newtree(bestfeature, 1)
    print(inspect(solutiontree))
end

-- get adjusted data
local subset = {}
for i = 1, #dataset do
    if dataset[i][bestfeature] == 0 then
        -- add this to our adustesd subset
        local myset = {}
        myset[1] = {}
        if bestfeature ~= 1 then table.insert(myset[1], dataset[i][1]) end
        if bestfeature ~= 2 then table.insert(myset[1], dataset[i][2]) end
        if bestfeature ~= 3 then table.insert(myset[1], dataset[i][3]) end
        if bestfeature ~= 4 then table.insert(myset[1], dataset[i][4]) end

        table.insert(subset, myset[1])
    end
end

print("~~~")
print("New subset:")
printDataset(subset)

-- determine information gain
bestfeature = -1
bestfeaturegain = 0
gain = {}
for i = 1, (NUMBEROFFUNCTIONS - 1) do
    -- for function x
    -- get all the positives
    positiveSamplesForFunction = {}
    positiveSamplesForFunction[i] = getCountOfPositiveSamplesForFunction(dataset, i, 4)        -- 1 == AGL. 4 == gear

    -- get all the negatives
    negativeSamplesForFunction = {}
    negativeSamplesForFunction[i] = getCountOfNegativeSamplesForFunction(dataset, i, 4)

    -- determine the superset of possible values for function x
    --print("---")
    superset = {}
    superset = getSupersetOfValuesForFunction(positiveSamplesForFunction,negativeSamplesForFunction, i)

    -- get the entropy for each value in the function
    ent = {}
    for k, v in pairs(superset) do
        -- print(k, positiveSamplesForFunction[i][k], negativeSamplesForFunction[i][k])
        ent[k] = getEntropy(positiveSamplesForFunction[i][k], negativeSamplesForFunction[i][k])
        --print(k, ent[k])
     end

     -- finally - information gain
     local mysum = 0
     for k,v in pairs(superset) do
         mysum = mysum +  (v / NUMBEROFDATAPOINTS) * ent[k]
     end
     gain[i] = entropy - mysum
     print("Gain for function " .. i .. " is: " .. gain[i])

     if gain[i] > bestfeaturegain then
         -- this is a potential branch
         bestfeaturegain = gain[i]
         bestfeature = i
     end

end
