local RANKS = {
    { key = "normal_player", name = "Normal Player", color = "#D3D3D3" },
    { key = "helper", name = "Helper", color = "#55FFFF" },
    { key = "moderator", name = "Moderator", color = "#55FF55" },
    { key = "vip", name = "VIP", color = "#FFFF55" },
    { key = "millionaire", name = "Millionaire", color = "#FFAA00" },
    { key = "billionaire", name = "Billionaire", color = "#FF55FF" },
    { key = "trillionaire", name = "Trillionaire", color = "#AA55FF" },
    { key = "admin", name = "Admin", color = "#FF5555" },
    { key = "owner", name = "Owner", color = "#FF0000" },
}

local DEFAULT_RANK_KEY = "normal_player"
local RANK_BY_KEY = {}
for _, rank in ipairs(RANKS) do
    RANK_BY_KEY[rank.key] = rank
end

return {
    RANKS = RANKS,
    RANK_BY_KEY = RANK_BY_KEY,
    DEFAULT_RANK_KEY = DEFAULT_RANK_KEY,
}
