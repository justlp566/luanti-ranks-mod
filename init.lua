local config = dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/config.lua")

local RANKS = config.RANKS
local RANK_BY_KEY = config.RANK_BY_KEY
local DEFAULT_RANK_KEY = config.DEFAULT_RANK_KEY
local storage = minetest.get_mod_storage()

local function normalize_rank(value)
    if type(value) ~= "string" then
        return DEFAULT_RANK_KEY
    end

    value = value:lower():gsub("^%s+", ""):gsub("%s+$", "")
    value = value:gsub("[%c%p%s]+", "_")
    value = value:gsub("_+", "_")
    value = value:gsub("^_+", ""):gsub("_+$", "")

    if value == "" then
        return DEFAULT_RANK_KEY
    end

    if RANK_BY_KEY[value] then
        return value
    end

    local fallback = value:gsub("_", " ")
    for _, rank in ipairs(RANKS) do
        if rank.name:lower() == fallback then
            return rank.key
        end
    end

    return DEFAULT_RANK_KEY
end

local function get_rank_key(player_name)
    if not player_name or player_name == "" then
        return DEFAULT_RANK_KEY
    end

    local key = storage:get_string("rank:" .. player_name)
    if key ~= "" and RANK_BY_KEY[key] then
        return key
    end

    return DEFAULT_RANK_KEY
end

local function get_rank(player_name)
    return RANK_BY_KEY[get_rank_key(player_name)] or RANK_BY_KEY[DEFAULT_RANK_KEY]
end

local function set_rank(player_name, rank_key)
    if not player_name or player_name == "" then
        return false
    end

    local resolved = RANK_BY_KEY[rank_key] and rank_key or DEFAULT_RANK_KEY
    if resolved == DEFAULT_RANK_KEY then
        storage:set_string("rank:" .. player_name, "")
    else
        storage:set_string("rank:" .. player_name, resolved)
    end
    return true
end

local function is_rank_manager(player_name)
    if not player_name or player_name == "" then
        return false
    end

    if minetest.check_player_privs(player_name, { rank_admin = true }) then
        return true
    end

    if minetest.check_player_privs(player_name, { server = true }) then
        return true
    end

    local rank = get_rank(player_name)
    return rank.key == "admin" or rank.key == "owner"
end

local function show_rank_list(player_name)
    local output = {}
    for _, rank in ipairs(RANKS) do
        output[#output + 1] = minetest.colorize(rank.color, rank.name)
    end
    return table.concat(output, ", ")
end

local function update_player_rank_tags(player)
    if not player or not player.get_player_name then
        return
    end

    local name = player:get_player_name()
    local rank = get_rank(name)
    local prefix = minetest.colorize(rank.color, "[" .. rank.name .. "]")

    player:set_nametag_attributes({
        color = rank.color,
    })

    player:set_properties({
        nametag = prefix .. " " .. name,
    })
end

minetest.register_privilege("rank_admin", {
    description = "Allows use of rank management commands.",
    give_to_singleplayer = false,
})

minetest.register_on_joinplayer(function(player, last_login)
    update_player_rank_tags(player)
    local player_name = player:get_player_name()
    local rank = get_rank(player_name)
    if rank.key == DEFAULT_RANK_KEY then
        return
    end
    minetest.chat_send_player(player_name, minetest.colorize(rank.color,
        "Your current rank is " .. rank.name .. "."))
end)

minetest.register_chatcommand("rank_list", {
    description = "List all available ranks and colors.",
    func = function(name)
        return true, "Ranks: " .. show_rank_list(name)
    end,
})

minetest.register_chatcommand("rank_set", {
    params = "<player> <rank>",
    description = "Set a player's rank.",
    func = function(name, param)
        if not is_rank_manager(name) then
            return false, "Only Owner, Admin, or players with rank_admin privilege may use this command."
        end

        local target, rank_text = param:match("^(%S+)%s+(.+)$")
        if not target or not rank_text then
            return false, "Usage: /rank_set <player> <rank>"
        end

        local resolve_rank = normalize_rank(rank_text)
        if not RANK_BY_KEY[resolve_rank] then
            return false, "Unknown rank. Use /rank_list for valid names."
        end

        if not set_rank(target, resolve_rank) then
            return false, "Failed to set rank."
        end

        local assigned = RANK_BY_KEY[resolve_rank]
        minetest.chat_send_all(minetest.colorize(assigned.color,
            target .. " is now " .. assigned.name .. "."))

        local player = minetest.get_player_by_name(target)
        if player then
            update_player_rank_tags(player)
        end

        return true, target .. " is now " .. assigned.name .. "."
    end,
})

minetest.register_chatcommand("clear_rank", {
    params = "<player>",
    description = "Reset a player's rank to Normal Player.",
    func = function(name, param)
        if not is_rank_manager(name) then
            return false, "Only Owner, Admin, or players with rank_admin privilege may use this command."
        end

        local target = (param or ""):match("^%s*(.-)%s*$")
        if target == "" then
            return false, "Usage: /clear_rank <player>"
        end

        set_rank(target, DEFAULT_RANK_KEY)
        minetest.chat_send_all(minetest.colorize("#D3D3D3",
            target .. " is now a Normal Player."))

        local player = minetest.get_player_by_name(target)
        if player then
            update_player_rank_tags(player)
        end

        return true, target .. " was reset to Normal Player."
    end,
})

minetest.register_chatcommand("promote", {
    params = "<player>",
    description = "Promote a player to Helper.",
    func = function(name, param)
        if not is_rank_manager(name) then
            return false, "Only Owner, Admin, or players with rank_admin privilege may use this command."
        end

        local target = (param or ""):match("^%s*(.-)%s*$")
        if target == "" then
            return false, "Usage: /promote <player>"
        end

        set_rank(target, "helper")
        minetest.chat_send_all(minetest.colorize("#55FFFF",
            target .. " has been promoted to Helper."))

        local player = minetest.get_player_by_name(target)
        if player then
            update_player_rank_tags(player)
        end

        return true, target .. " was promoted to Helper."
    end,
})

minetest.register_on_chat_message(function(name, message)
    if minetest.settings:get_bool("ranks_chat_override", true) == false then
        return false
    end

    local rank = get_rank(name)
    local prefix = minetest.colorize(rank.color, "[" .. rank.name .. "]")
    minetest.chat_send_all(prefix .. " " .. name .. ": " .. message)
    return true
end)

minetest.register_globalstep(function(dtime)
    for _, player in ipairs(minetest.get_connected_players()) do
        update_player_rank_tags(player)
    end
end)

minetest.log("action", "[luanti_ranks] Loaded " .. #RANKS .. " ranks")
