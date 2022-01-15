inspect = require 'lib.inspect'
tr = require 'tree'
cf = require 'lib.commonfunctions'

dataset = {}

NUMBEROFDATAPOINTS = 50

NUMBEROFFUNCTIONS = 3

local function getDataset()
    -- sets the global variable dataset to random values

    for i = 1, NUMBEROFDATAPOINTS do
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

        -- ** outcomes/states/results **

        -- gear.  1 == down
        local rndnum = love.math.random(1,100)
        if dataset[i][1] == 0 then
            dataset[i][4] = 1
        elseif dataset[i][1] <= 3 and rndnum <= 25 then
            dataset[i][4] = 0
        elseif dataset[i][1] <= 3 and rndnum > 25 then
            dataset[i][4] = 1
        elseif dataset[i][1] <= 6 and rndnum <= 75 then
            dataset[i][4] = 0
        elseif dataset[i][1] <= 6 and rndnum > 75 then
            dataset[i][4] = 1
        else
            dataset[i][4] = 0
        end

        -- ap
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

-- ************************************************************************************************************************************

getDataset()

printDataset(dataset)

-- should gear be down (1)?
numofpositivesamples = getCountOfPositiveSamples(dataset, 1, 1)   -- gear == 1
numofnegativesamples = getCountOfNegativeSamples(dataset, 1, 1)
numofsamples = numofpositivesamples + numofnegativesamples

entropy = getEntropy(numofpositivesamples, numofnegativesamples)

print("Total entropy is " .. cf.round(entropy,4))  -- values close to 100 = impure
print()

-- determine information gain

for i = 1, NUMBEROFFUNCTIONS do

-- for function x
-- get all the positives
positiveSamplesForFunction = {}
positiveSamplesForFunction[1] = getCountOfPositiveSamplesForFunction(dataset, 1, 4)        -- 1 == AGL. 4 == gear

print"ooo - positive samples"
print("value - count")
for e,r in pairs(positiveSamplesForFunction[1]) do
    print(e,r)
end

-- get all the negatives
negativeSamplesForFunction = {}
negativeSamplesForFunction[1] = getCountOfNegativeSamplesForFunction(dataset, 1, 4)

print"*** - negative samples"
print("value - count")
for e,r in pairs(negativeSamplesForFunction[1]) do
    print(e,r)
end

-- determine the superset of possible values for function x
print("---")
superset = {}
superset = getSupersetOfValuesForFunction(positiveSamplesForFunction,negativeSamplesForFunction, 1)

print("superset of values for function is:")
for k,v in pairs(superset) do
    print(k, v)
end

print("+++")
print("Entropy for each value:")
-- get the entropy for each value in the function
ent = {}
for k, v in pairs(superset) do
    -- print(k, positiveSamplesForFunction[1][k], negativeSamplesForFunction[1][k])
    ent[k] = getEntropy(positiveSamplesForFunction[1][k], negativeSamplesForFunction[1][k])
    print(k, ent[k])

end
print("~~~")

-- finally - information gain
local mysum = 0
for k,v in pairs(superset) do
    mysum = mysum +  (v / NUMBEROFDATAPOINTS) * ent[k]
end
local gain = {}
gain[1] = entropy - mysum
print("Gain for this function is: " .. gain[1])
