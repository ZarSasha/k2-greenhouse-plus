---------------------------------------------------------------------------------------------------
--  ┏┓┳┳┳┓┏┓┏┳┓┳┏┓┳┓┏┓
--  ┣ ┃┃┃┃┃  ┃ ┃┃┃┃┃┗┓
--  ┻ ┗┛┛┗┗┛ ┻ ┻┗┛┛┗┗┛
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- STANDARD FUNCTIONS
---------------------------------------------------------------------------------------------------

-- Checks whether a value exists within a table. Returns true or false.
function TableContainsValue(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------------------------------------
-- FACTORIO-SPECIFIC FUNCTIONS
---------------------------------------------------------------------------------------------------

-- Checks for presence of item, returns error in log if missing.
function ItemExists(ModName, Item)
    if data.raw.item[Item] ~= nil then
        return true
    else
        log("item with ID \""..Item.."\" from the mod \""..ModName.."\" does not exist!")
        return false
    end
end

---------------------------------------------------------------------------------------------------
