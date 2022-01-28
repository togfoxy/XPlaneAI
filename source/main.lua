inspect = require 'lib.inspect'
tr = require 'tree'
cf = require 'lib.commonfunctions'

dataset = {}
rawdata = {}
cleandata = {}
solutiontree = {}
emptynode = {}
treejourney = {}
treejourneypointer = 0      -- this points to where in the treejourney the current navigation is. Treejourney is a flat array so this is between 1 and #treejourney inclusive

NUMBEROFDATAPOINTS = 50

local function getDataset1()
    for i = 1, 2 do
        dataset[1] = {}
        dataset[2] = {}

        dataset[1][1] = 0       -- agl
        dataset[1][2] = 0       -- pitch
        dataset[1][3] = 0       -- airspeed
        dataset[1][4] = 0       -- gear

        dataset[2][1] = 1       -- agl
        dataset[2][2] = 1       -- pitch
        dataset[2][3] = 1       -- airspeed
        dataset[1][4] = 1       -- gear
    end
end

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

local function nodeInHistory(history, nodetitle)
    -- scan the history table for the node title
    for i = 1 , #history do
        if history[i] == nodetitle then
            return true
        end
    end
    return false
end

function findEmptyBranch(t)

    local root
    local thisnode = {}

    if t.title == nil then
        -- there is no tree. Return nil.
        -- print("alpha")
        return nil
    else
        -- print("bravo")
        thisnode = cf.deepcopy(t)
        root = t.title
        print("Juliet" , root)
        table.insert(treejourney, thisnode)
        treejourneypointer = treejourneypointer + 1
    end

    -- print("charlie")
    local abort = false
    repeat
        -- thisnode could be:
        --  a leaf (leaf = true)
        --  a balanced branch (#children == 2)
        --  an incomplete branch (#children < 2)

        print("delta", thisnode.title)
        if (thisnode.children == nil or #thisnode.children < 2) and thisnode.leaf == false then
            print("echo")
            -- this node is a branch and has too few children. Bingo.
            abort = true
            return thisnode
        elseif thisnode.leaf == true then
            -- print("hotel")
            -- both children are in history so travel up the tree or
            -- this node is a leaf
            print("Oscar: found a leaf")
            print("Tree journey:")
-- print(inspect(treejourney))
-- error()

            -- move the pointer back by one (to the parent) and then add this navigation backwards to the treejourney history
            treejourneypointer = treejourneypointer - 1
            thisnode = treejourney[treejourneypointer]
            table.insert(treejourney, thisnode)
            if thisnode.title == root and nodeInHistory(treejourney, thisnode.children[1]) and nodeInHistory(treejourney, thisnode.children[2]) then
                abort = true
            end
        elseif thisnode.leaf == false and #thisnode.children >= 2 then
            -- thisnode is a branch and has at least 2 children
            -- print("Kilo")
            if not nodeInHistory(treejourney, thisnode.children[1]) then
                -- print("foxtrot")
                thisnode = thisnode.children[1]
                print("Lima")
                table.insert(treejourney, thisnode)
                treejourneypointer = treejourneypointer + 1
            elseif not nodeInHistory(treejourney, thisnode.children[2]) then
                -- print("golf")
                thisnode = thisnode.children[2]
                print("Mike")
                table.insert(treejourney, thisnode)
                treejourneypointer = treejourneypointer + 1
            else
                -- both children have been visited. Need to move up the tree
                print("Papa: moving up the tree")
                treejourneypointer = treejourneypointer - 1
                thisnode = treejourney[treejourneypointer]
                table.insert(treejourney, thisnode)
                if thisnode.title == root and nodeInHistory(treejourney, thisnode.children[1]) and nodeInHistory(treejourney, thisnode.children[2]) then
                    -- tree fully traversed and returned back to root
                    abort = true
                end
            end
        else
            print("Error:")
            print("if condition: " , thisnode.children == nil or #thisnode.children < 2)
            print("title: " .. thisnode.title)
            print("children is nil: " , thisnode.children == nil)
            -- print(#thisnode.children)
            print("is leaf: " , thisnode.leaf)
            error()
        end
    until (abort == true)
    -- print("indigo")
    return nil      -- effectively a 'fail'
end

getDataset1()

print("@@@")

newnode = {}
newnode.title = "AGL"
newnode.leaf = false
newnode.children = {}
emptynode = findEmptyBranch(solutiontree)
if emptynode == nil then
    -- tree is empty
    solutiontree = tr.newtree(newnode.title, newnode.leaf)
elseif emptynode == 1 then
    -- tree is complete
else
    -- found and empty node
    solutiontree = tr.insertintotree(solutiontree, emptynode.title, newnode)
end
-- print(inspect(solutiontree))
-- print("$$$")
-- print(solutiontree.title)

newnode = {}
newnode.title = "Pitch"
newnode.leaf = false
newnode.children = {}
emptynode = findEmptyBranch(solutiontree)
if emptynode == nil then
    -- tree is empty
    solutiontree = tr.newtree(newnode.title, newnode.leaf)
elseif emptynode == 1 then
    -- tree is complete
else
    -- found and empty node
    solutiontree = tr.insertintotree(solutiontree, emptynode.title, newnode)
end

newnode = {}
newnode.title = "Airspeed"
newnode.leaf = false
newnode.children = {}
emptynode = findEmptyBranch(solutiontree)
if emptynode == nil then
    -- tree is empty
    solutiontree = tr.newtree(newnode.title, newnode.leaf)
elseif emptynode == 1 then
    -- tree is complete
else
    -- found and empty node
    solutiontree = tr.insertintotree(solutiontree, emptynode.title, newnode)
end

newnode = {}
newnode.title = "Landing gear up"
newnode.leaf = true
newnode.children = {}
emptynode = findEmptyBranch(solutiontree)
if emptynode == nil then
    -- tree is empty
    solutiontree = tr.newtree(newnode.title, newnode.leaf)
elseif emptynode == 1 then
    -- tree is complete
else
    solutiontree = tr.insertintotree(solutiontree, emptynode.title, newnode)
end



newnode = {}
newnode.title = "Oxygen"
newnode.leaf = true
newnode.children = {}
emptynode = findEmptyBranch(solutiontree)
if emptynode == nil then
    -- tree is empty
    solutiontree = tr.newtree(newnode.title, newnode.leaf)
elseif emptynode == 1 then
    -- tree is complete
else
    solutiontree = tr.insertintotree(solutiontree, emptynode.title, newnode)
end



print("***")
newnode = {}
newnode.title = "Fuel"
newnode.leaf = false
newnode.children = {}
emptynode = findEmptyBranch(solutiontree)
if emptynode == nil then
    -- tree is empty
    solutiontree = tr.newtree(newnode.title, newnode.leaf)
elseif emptynode == 1 then
    -- tree is complete
else
    solutiontree = tr.insertintotree(solutiontree, emptynode.title, newnode)
end

print("---")
print(inspect(solutiontree))
print("+++")
print(inspect(treejourney))
