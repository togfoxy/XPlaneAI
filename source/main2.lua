inspect = require 'lib.inspect'
tr = require 'tree'

solutiontree = {}

solutiontree = tr.newtree("root", nil)
-- print(inspect(solutiontree))

local subtree = tr.newtree("AGL", 0)
-- print(inspect(subtree))

solutiontree = tr.insertintotree(solutiontree, "root", subtree)

local subtree = tr.newtree("Airspeed", 2)
solutiontree = tr.insertintotree(solutiontree, "AGL", subtree)

local subtree = tr.newtree("pitch", 20)
solutiontree = tr.insertintotree(solutiontree, "AGL", subtree)

local subtree = tr.newtree("autopilot", 0)
solutiontree = tr.insertintotree(solutiontree, "root", subtree)
print("---")
print(inspect(solutiontree))
