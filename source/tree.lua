local tree = {}

function tree.newtree(string,val)
    -- title is the name of the node
    -- value is some threshold value
    -- children are ... well ... children
    return {title = string, leaf = val, children = {}}
end

function tree.insertintotree(t, parenttitle, newnode)
    -- t = tree

    -- print(inspect(t))
    if t == nil then
    -- print("alpha")
        t = newnode
    elseif t.title == parenttitle then
    -- print("beta")
        table.insert(t.children, newnode)
    else
    -- print("charlie")
        for k, v in pairs(t.children) do
            tree.insertintotree(v, parenttitle, newnode)

        end
    end
    return t
end

return tree
