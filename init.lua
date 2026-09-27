local mod_storage = minetest.get_mod_storage()

local RANKS = {
    { name = "normal player", key = "normal_player", color = "#D3D3D3" },
    { name = "helper", key = "helper", color = "#55FFFF" },
    { name = "moderator", key = "moderator", color = "#55FF55" },
    { name = "vip", key = "vip", color = "#FFFF55" },
    { name = "millionaire", key = "millionaire", color = "#FFAA00" },
    { name = "billionaire", key = "billionaire", color = "#FF55FF" },
    { name = "trillionaire", key = "trillionaire", color = "#AA55FF" },
    { name = "admin", key = "admin", color = "#FF5555" },
    { name = "owner", key = "owner", color = "#FF0000" },
}

local rank_by_key = {}
for _, rank in ipairs(RANKS) do
    rank_by_key[rank.key] = rank
end

local function normalize_rank(value)
    value = value:lower():gsub("^%s+", ""):gsub("%s+$", "")
    value = value:gsub("%s+", "_")
    return value
end

local function get_rank(player_name)
    local key = mod_storage:get_string("rank:" .. player_name)
    return rank_by_key[key] or rank_by_key.normal_player
end

local function set_rank(player_name, rank_key)
    if rank_key == "normal_player" then
        mod_storage:set_string("rank:" .. player_name, "")
    else
        mod_storage:set_string("rank:" .. player_name, rank_key)
    end
end

local function can_manage(name)
    if name == "" then
        return true
    end
    local rank = get_rank(name).key
    return rank == "owner" or rank == "admin"
end

local function require_manager(name)
    if can_manage(name) then
        return true
    end
    minetest.chat_send_player(name, minetest.colorize("#FF5555",
        "You must be an Owner or Admin to use this command."))
    return false
end

local function target_exists(name)
    if name == "" or not minetest.player_exists(name) then
        return false
    end
    return true
end

minetest.register_chatcommand("rank_list", {
    description = "List all available ranks",
    func = function(name)
        local entries = {}
        for _, rank in ipairs(RANKS) do
            entries[#entries + 1] = minetest.colorize(rank.color, rank.name)
        end
        return true, "Ranks: " .. table.concat(entries, ", ")
    end,
})

minetest.register_chatcommand("rank_set", {
    params = "<player> <rank>",
    description = "Set a player's rank",
    privs = {},
    func = function(name, param)
        if not require_manager(name) then return false end
        local target, rank_text = param:match("^(%S+)%s+(.+)$")
        if not target or not rank_text then
            return false, "Usage: /rank_set <player> <rank>"
        end
        if not target_exists(target) then
            return false, "That player has never joined this server."
        end
        local rank_key = normalize_rank(rank_text)
        local rank = rank_by_key[rank_key]
        if not rank then
            return false, "Unknown rank. Use /rank_list."
        end
        set_rank(target, rank.key)
        minetest.chat_send_all(minetest.colorize(rank.color,
            target .. " is now " .. rank.name .. "."))
        return true
    end,
})

minetest.register_chatcommand("clear_rank", {
    params = "<player>",
    description = "Reset a player to Normal Player",
    privs = {},
    func = function(name, target)
        if not require_manager(name) then return false end
        target = target:match("^%s*(.-)%s*$")
        if not target_exists(target) then
            return false, "That player has never joined this server."
        end
        set_rank(target, "normal_player")
        minetest.chat_send_all(minetest.colorize("#D3D3D3",
            target .. " is now a Normal Player."))
        return true
    end,
})

minetest.register_chatcommand("promote", {
    params = "<player>",
    description = "Promote a player to Helper",
    privs = {},
    func = function(name, target)
        if not require_manager(name) then return false end
        target = target:match("^%s*(.-)%s*$")
        if not target_exists(target) then
            return false, "That player has never joined this server."
        end
        set_rank(target, "helper")
        minetest.chat_send_all(minetest.colorize("#55FFFF",
            target .. " has been promoted to Helper."))
        return true
    end,
})

-- Replace the default chat line so the rank prefix appears before the name.
minetest.register_on_chat_message(function(name, message)
    local rank = get_rank(name)
    local prefix = minetest.colorize(rank.color, "[" .. rank.name .. "]")
    minetest.chat_send_all(prefix .. " " .. name .. ": " .. message)
    return true
end)

minetest.log("action", "[luanti_ranks] Loaded " .. #RANKS .. " ranks")
