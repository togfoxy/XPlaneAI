local entropyfunctions = {}

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

function entropyfunctions.getTotalEntropy(ds)
    print("hi")
    -- ds = dataset
    numofpositivesamples = getCountOfPositiveSamples(ds)   -- gear == 1
    numofnegativesamples = getCountOfNegativeSamples(ds)

    local result = getEntropy(numofpositivesamples, numofnegativesamples)
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

function entropyfunctions.getBestFeature(ds, totalentropy)
    -- total entropy is the entropy for the whole dataset (ds)
    -- determine totalEntropy by calling getTotalEntropy

    -- determine information gain
    local bestfeature = -1
    local bestfeaturegain = 0
    local gain = {}

    local NUMBEROFFUNCTIONS = #ds[1] - 1
    for i = 1, (NUMBEROFFUNCTIONS) do
        -- for function x
        -- get all the positives
        positiveSamplesForFunction = {}
        positiveSamplesForFunction[i] = getCountOfPositiveSamplesForFunction(ds, i, 4)        -- 1 == AGL. 4 == gear

        -- get all the negatives
        negativeSamplesForFunction = {}
        negativeSamplesForFunction[i] = getCountOfNegativeSamplesForFunction(ds, i, 4)

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
         gain[i] = totalentropy - mysum
         print("Gain for function " .. i .. " is: " .. gain[i])

         if gain[i] > bestfeaturegain then
             -- this is a potential branch
             bestfeaturegain = gain[i]
             bestfeature = i
         end

    end
    return bestfeature
end

return entropyfunctions
