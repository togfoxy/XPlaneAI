local binarytree = {}

-- Usage:
-- bt = require 'binarytree'

-- local test = bt.newbt(5)
-- bt.insertbt(test, bt.newbt(8))
-- bt.insertbt(test, bt.newbt(3))
-- bt.insertbt(test, bt.newbt(4))
--
-- print(test.key)
-- print(test.left.key)
-- print(test.right.key)
-- print(test.left.right.key)

function binarytree.newbt(key)
    return {key = key, left = nil, right = nil} -- left and right are NOT empty tables, they don't exist at all.
end

function binarytree.insertbt(tree, node)
    if tree == nil then -- if the tree doesn't exist then set inserted node to be the root
        tree = node
    elseif node.key <= tree.key then
        if not tree.left then
            tree.left = node
        else
            binarytree.insertbt(tree.left, node)
        end
    elseif node.key > tree.key then
        if not tree.right then
            tree.right = node
        else
            binarytree.insertbt(tree.right, node)
        end
    end
    return tree
end

return binarytree
