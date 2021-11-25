local playeractionpicker
local playercontroller
local combat
local ThePlayer

local delay = GetModConfigData("Default_delay")
local keyframe = GetModConfigData("Default_keyframe")
local checkanim = GetModConfigData("checkanim")
local anchor = GetModConfigData("anchor")

local G = GLOBAL
local FRAMES = G.FRAMES
local SendRPCToServer = G.SendRPCToServer
local RPC = G.RPC
local ACTIONS = G.ACTIONS
local GetTime = G.GetTime

local function IsDefaultScreen()
    local screen = G.TheFrontEnd:GetActiveScreen()
    local screenName = screen and screen.name or ""
    return screenName:find("HUD") ~= nil
end

local function Say(str)
    if not G.ThePlayer then
        return
    end
    G.ThePlayer.components.talker:Say(str)
end

local function PrintAnim(turn,last_fa_time)
    local str = G.ThePlayer.entity:GetDebugString()
    local anim = str:find("anim")
    local frame = str:find("anim", anim + 1)
    local Frame = str:find("Frame")
    local number = str:find("Facing", Frame + 1)
    print(str:sub(anim, frame - 1), str:sub(Frame, number - 1) .. "turn: ", turn,"AttackTimer: ",GetTime()-last_fa_time)
end

local function CheckPlayerString(string)
    if not G.ThePlayer then
        return
    end
    local debugstring = G.ThePlayer:GetDebugString()
    return debugstring and string.find(debugstring, string)
end

local function GetItemFromPlayerInvAndBack(prefab)
    local invitems = G.ThePlayer.replica.inventory:GetItems()
    local backpack
    if G.EQUIPSLOTS.BACK then
        backpack = G.ThePlayer.replica.inventory:GetEquippedItem(G.EQUIPSLOTS.BACK)
    else
        backpack = G.ThePlayer.replica.inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
    end
    local packitems = backpack and backpack.replica.container and backpack.replica.container:GetItems() or nil
    if invitems then
        for k, v in pairs(invitems) do
            if v.prefab == prefab then
                return v
            end
        end
    end
    if packitems then
        for k, v in pairs(packitems) do
            if v.prefab == prefab then
                return v
            end
        end
    end
end


local function Hit(target, px, pz)
    local function cb()
        local activeitem = G.ThePlayer.replica.inventory:GetActiveItem()
        if not activeitem then
            SendRPCToServer(RPC.LeftClick, ACTIONS.ATTACK.code, px, pz, target, true, 10, true)
        else
            -- SendRPCToServer(RPC.ControllerAttackButton, target, false)
            -- SendRPCToServer(RPC.AttackButton, target, true, true)
            G.ThePlayer.components.playercontroller:DoControllerAttackButton(target)
        end
    end
    local function DoAction()
        if G.ThePlayer.components.playercontroller:CanLocomote() then
            local action = G.BufferedAction(G.ThePlayer, target, G.ACTIONS.ATTACK)
            action.preview_cb = cb()
            G.ThePlayer.components.playercontroller:DoAction(action)
        else
            cb()
        end
    end
    DoAction()
end

-- local function Run(px, pz, tx, tz, distance, tr, pa)
--     local function cb()
--         if G.math.abs(tr - pa) <= 180 and distance <= 2 then
--             SendRPCToServer(RPC.LeftClick, ACTIONS.WALKTO.code, px + (px - tx) / distance / 4,
--                 pz + (pz - tz) / distance / 4)
--         else
--             SendRPCToServer(RPC.LeftClick, ACTIONS.WALKTO.code, px - (px - tx) / distance / 5,
--                 pz - (pz - tz) / distance / 5)
--         end
--     end
--     local function DoAction()
--         if playercontroller:CanLocomote() then
--             local action = G.BufferedAction(G.ThePlayer, nil, ACTIONS.WALKTO, nil,
--                 G.Vector3(px + (px - tx) / distance / 1, 0, pz + (pz - tz) / distance / 1))
--             playercontroller:DoAction(action)
--         else
--             cb()
--         end
--     end
--     DoAction()
-- end

local function PredictWalk(px, pz)
    local function cb()
        if not G.ThePlayer:HasTag("moving") then
            SendRPCToServer(RPC.PredictWalking, px, pz)
        end
    end
    -- local function DoAction()
        -- if ThePlayer.components.playercontroller:CanLocomote() then
            -- local action = G.BufferedAction(G.ThePlayer, target, G.ACTIONS.ATTACK)
            -- action.preview_cb = cb()
            -- ThePlayer.components.playercontroller:DoAction(action)

        -- else
            cb()
        -- end
    -- end
    -- DoAction()
end

local Cheatthread
local function Start()
    if not IsDefaultScreen() then
        return
    end
    if G.ThePlayer == nil then
        return
    end
    if G.ThePlayer.Cheatthread ~= nil then
        return
    end
    ThePlayer = G.ThePlayer
    playeractionpicker = ThePlayer.components.playeractionpicker
    playercontroller = ThePlayer.components.playercontroller
    combat = ThePlayer.replica.combat

    local target
    local turn
    local range
    local last_fa_time
    local first_hit
    local first_hit_vector

    last_fa_time = GetTime()

    -- local function UpdateHighLight(target)
    --     if anchor == true then return end
    --     if combat:CanTarget(target) then
    --         if not target.components.highlight then
    --             target:AddComponent("highlight")
    --         end
    --         local highlight = target.components.highlight
    --         highlight:Highlight()
    --     else
    --         if target:IsValid() and target.components.highlight then
    --             target.components.highlight:UnHighlight()
    --         end
    --     end
    -- end

    local function HitAndCancel()
        -- local function Cancel()
        --     local table = {
        --         "player_attacks.zip:atk",
        --         "punch Frame: ",
        --         "wanda_attack.zip:pocketwatch_atk"
        --     }
        --     for k,v in pairs(table) do
        --         if CheckPlayerString(v) then
        --             return v
        --         end
        --     end
        -- end

        if CheckPlayerString("player_attacks.zip:atk") then
            if first_hit_vector then
                first_hit_vector = first_hit_vector + 1
            else
                first_hit_vector = 0
            end
        end

        if target ~= nil and target:IsValid() and target.replica.health ~= nil and not target.replica.health:IsDead() and
            combat:CanTarget(target) then
            local tx, ty, tz = target:GetPosition():Get()
            local px, py, pz = ThePlayer:GetPosition():Get()
            if not turn or turn < delay then
                Hit(target, px, pz)
            end

            local playitemtable = {
                "horn",     --牛角
                "panflute",     --排箫
                "featherfan",       --羽毛扇
                -- "bananafan",        --芭蕉扇
                -- "bookinfo_myth",        --天书
                "cookbook",     --烹饪书
            }
            
            local songtable = {
                "battlesong_healthgain",    --心碎歌谣
                "battlesong_sanitygain",    -- 醍醐灌顶华彩
                "battlesong_durability",    -- 武器化的颤音
                "battlesong_sanityaura",    -- 英勇美声颂
                "battlesong_fireresistance"    -- 防火假声
            }

            local booktable = {
                "book_birds",   --世界鸟类大全
                "book_horticulture",    --应用园艺学，简编
                "book_silviculture",    --应用造林学
                "book_sleep",       --睡前故事
                "book_brimstone",   --末日将至
                "book_tentacles",   --触手的召唤
                "book_harvest",     --季节的收获
                "book_toggleddownfall"      --雨书
            }

            local function PlayItem()
                for k,v in pairs(playitemtable) do
                    if GetItemFromPlayerInvAndBack(v) then
                        return v
                    end
                end
            end
            local playitem = GetItemFromPlayerInvAndBack(PlayItem())

            local function SingSong()
                for k,v in pairs(songtable) do
                    if GetItemFromPlayerInvAndBack(v) then
                        return v
                    end
                end
            end
            local songitem = GetItemFromPlayerInvAndBack(SingSong())

            local function ReadBook()
                for k,v in pairs(booktable) do
                    if GetItemFromPlayerInvAndBack(v) then
                        return v
                    end
                end
            end
            local bookitem = GetItemFromPlayerInvAndBack(ReadBook())

            if playitem or songitem or bookitem then local num = 1 end

            if
            -- not turn and
            -- GetTime() - last_fa_time > (delay + 1) * FRAMES and
            not first_hit and
                (keyframe<8 and CheckPlayerString("player_attacks.zip:atk") and first_hit_vector == keyframe) or      --8 / 0 / 6
                -- (keyframe < 7 and Cancel() and first_hit_vector == keyframe) or
                (keyframe>7 and CheckPlayerString("player_attacks.zip:atk Frame: " .. (keyframe-8) .. ".00")) or      --8 / 0 / 6
                CheckPlayerString("werebeaver_basic.zip:atk_pre Frame:"..(keyframe - 2)..".00") or     --7 / 6
                -- CheckPlayerString("atk Frame: " .. (keyframe - 8) .. ".00") or      --8 / 0
                CheckPlayerString("punch Frame: " .. (keyframe + 2) .. ".00") or    --9 / 10 / 6
                CheckPlayerString("punch_a Frame: " .. (keyframe + 1) .. ".00") or  --8 / 9
                CheckPlayerString("whip Frame: " .. (keyframe + 2) .. ".00") or     --11 / 10 / 3
                CheckPlayerString("pocketwatch_atk: " .. (keyframe - 4) .. ".00") or    --11 / 4
                CheckPlayerString("player_mount.zip:atk Frame: " ..(keyframe - 2)..".00") or    --9 / 6
                turn == delay and first_hit then
                    if ThePlayer:HasTag("battlesinger") and ThePlayer:GetInspiration() > 0.17 and songitem then
                        ThePlayer.replica.inventory:UseItemFromInvTile(songitem)
                        Hit(target, px, pz)
                    elseif ThePlayer:HasTag("reader") and bookitem then
                        ThePlayer.replica.inventory:UseItemFromInvTile(bookitem)
                        Hit(target, px, pz)
                    elseif playitem then
                        ThePlayer.replica.inventory:UseItemFromInvTile(playitem)
                        Hit(target, px, pz)
                    else
                        SendRPCToServer(RPC.PredictWalking, px, pz)
                    end
                if checkanim then
                    PrintAnim(turn,last_fa_time)
                end
                turn = -1
                last_fa_time = GetTime()
                first_hit = 1
                -- if G.ThePlayer:HasTag("battlesinger") and G.ThePlayer:GetInspiration() > 0.17 and song then
                --     G.ThePlayer.replica.inventory:UseItemFromInvTile(song)
                --     if delay < 9 then
                --         Hit(target, px, pz)
                --     end
                
            end
            if CheckPlayerString("player_attacks.zip") or
                -- not CheckPlayerString("run_pre Frame") and
                CheckPlayerString("idle_loop Frame") or
                CheckPlayerString("player_actions_whip.zip") or
                CheckPlayerString("weremoose_attacks.zip") or
                CheckPlayerString("werebeaver_basic.zip") or
                -- CheckPlayerString("player_actions_uniqueitem_pre Frame") and
                CheckPlayerString("player_idles.zip:idle_loop Frame") or
                CheckPlayerString("wanda_attack.zip") or
                CheckPlayerString("dial_loop") or
                CheckPlayerString("player_mount.zip") or
                CheckPlayerString("asa_action.zip") or
                CheckPlayerString("player_basic.zip") then
                if turn then
                    turn = turn + 1
                else
                    turn = -1
                end
            end

        else
            local retarget = combat:GetTarget()
            local isctrlpressed = G.TheInput:IsControlPressed(G.CONTROL_FORCE_ATTACK)
            target = playercontroller:GetAttackTarget(isctrlpressed, retarget, retarget ~= nil)
            if target then
                range = combat:GetAttackRangeWithWeapon() + target:GetPhysicsRadius(0)
            end
            turn = nil
        end
        if G.TheInput:IsControlPressed(G.CONTROL_FORCE_ATTACK) and
            CheckPlayerString("horn Frame: " .. (9) .. ".00") or
            CheckPlayerString("flute Frame: " .. (10) .. ".00") or
            CheckPlayerString("fan Frame: " .. (10) .. ".00") or
            CheckPlayerString("reading_pst Frame: " .. (5) .. ".00") or
            CheckPlayerString("reading_in Frame") then
            -- CheckPlayerString("player_actions_uniqueitem.zip:book Frame" ..(25) ..".00") or
            -- CheckPlayerString("book Frame"..(25)..".00") then
            local px, py, pz = ThePlayer:GetPosition():Get()
            SendRPCToServer(RPC.PredictWalking, px, pz)
        end
    end
    if Cheatthread == nil then
        Cheatthread = ThePlayer:DoPeriodicTask(FRAMES, HitAndCancel)
    end
end

local function Stop()
    if IsDefaultScreen() and Cheatthread ~= nil then
        Cheatthread:Cancel()
        Cheatthread = nil
    end
end

local function GetKeyFromConfig(config)
    local key = GetModConfigData(config, true)
    if type(key) == "string" and G:rawget(key) then
        key = G[key]
    end
    return type(key) == "number" and key or -1
end

if GetKeyFromConfig("Adddelay_key") then
    G.TheInput:AddKeyUpHandler(GetKeyFromConfig("Adddelay_key"), function()
        if IsDefaultScreen() then
            delay = delay + 1
            if delay > 12 then
                delay = 12
            end
            if anchor then
                G.print("delay=" .. G.tostring(delay) .. "FRAMES")
            else
                Say("当前攻击间隔: " .. delay .. "帧 约" .. (delay / 30) .. "秒")
            end
        end
    end)
end
if GetKeyFromConfig("Reducedelay_key") then
    G.TheInput:AddKeyUpHandler(GetKeyFromConfig("Reducedelay_key"), function()
        if IsDefaultScreen() then
            delay = delay - 1
            if delay < 1 then
                delay = 1
            end
            if anchor then
                G.print("delay=" .. G.tostring(delay) .. "FRAMES")
            else
                Say("当前攻击间隔: " .. delay .. "帧 约" .. (delay / 30) .. "秒")
            end
        end
    end)
end
if GetKeyFromConfig("Addkeyframe_key") then
    G.TheInput:AddKeyUpHandler(GetKeyFromConfig("Addkeyframe_key"), function()
        if IsDefaultScreen() then
            keyframe = keyframe + 1
            if keyframe > 15 then
                keyframe = 15
            end
            if anchor then
                G.print("keyframe:the " .. G.tostring(keyframe) .. " frame")
            else
                Say("当前第一刀步长: " .. keyframe .. "帧")
            end
        end
    end)
end
if GetKeyFromConfig("Reducekeyframe_key") then
    G.TheInput:AddKeyUpHandler(GetKeyFromConfig("Reducekeyframe_key"), function()
        if IsDefaultScreen() then
            keyframe = keyframe - 1
            if keyframe < 0 then
                keyframe = 0
            end
            if anchor then
                G.print("keyframe:the " .. G.tostring(keyframe) .. " frame")
            else
                Say("当前第一刀步长: " .. keyframe .. "帧")
            end
        end
    end)
end
-- if GetKeyFromConfig("Auto_Attack_key") then
--     G.TheInput:AddKeyDownHandler(GetKeyFromConfig("Attack_key"), Start)
--         -- G.Networking_Announcement("自动攻击已开启")
--     G.TheInput:AddKeyUpHandler(GetKeyFromConfig("Attack_key"), Stop)
--         -- G.Networking_Announcement("自动攻击已关闭")
-- end
