local tree = {}

function tree.newtree(string,val)
    return {title = string, value = val, children = {}}
end

function tree.insertintotree(t, parenttitle, node)
    -- t = tree

-- print(inspect(t))
    if t == nil then
    print("alpha")
        t = node
    elseif t.title == parenttitle then
    print("beta")
        table.insert(t.children, node)
    else
    print("charlie")
        for k, v in pairs(t.children) do
            tree.insertintotree(v, parenttitle, node)

        end
    end
    return t
end

return tree
