--The name of the mod displayed in the 'mods' screen.
name = "Happy Predict Cheating"

--A description of the mod.
description = [[
1.推荐设置：
    Delay：攻击间隔 keyframe:第一刀时间
 (1)玩家手持武器攻击：delay = 9  【有排箫可-1】  keyframe = 8
 (2)吴迪河狸状态攻击：delay = 7    keyframe = 6
 (3)玩家空手(拳头)：delay = 9  【有排箫可-1】 keyframe = 10
 (4)吴迪麋鹿状态攻击：delay = 8    keyframe = 9
 (5)玩家鞭子攻击：delay(攻击间隔) = 11  【有排箫可-1】  keyframe(第一刀出刀) = 10
 (6)旺达警告表攻击：delay(攻击间隔) = 11 【有排箫可-1】  keyframe(第一刀出刀) = 4
 (7)骑牛攻击：delay(攻击间隔) = 9 【有排箫可-1】  keyframe(第一刀出刀) = 6
 (8)义体人攻击：delay(攻击间隔) = 9  【有排箫可-1】  keyframe(第一刀出刀) = 8
2.Delay是每次攻击的间隔，8帧是最快的，9帧可以做到原地
keyframe是决定第一刀出刀的时间，默认是8帧，（最稳最快)
无排箫的情况下使用8帧会空刀
(现在支持排箫、牛角、扇子、烹饪书、女武歌曲、奶奶的书)
3.此版本为阉割版，因版权问题，部分功能不加入
4.！！！一定要关闭延迟补偿！！！
  ！！！一定要关闭延迟补偿！！！
  ！！！一定要关闭延迟补偿！！！
]]
author = "07x23 白狼（改）"

--A version number so you can ask people if they are running an old version of your mod.
version = "2.4"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.
api_version = 6
api_version_dst = 10
priority = 0

--Compatible with both the base game and Reign of Giants
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

--This lets clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = false

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = true

--This lets people search for servers with this mod by these tags
server_filter_tags = {}

icon_atlas = "modicon.xml"
icon = "modicon.tex"
local string = ""
local keys = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","LALT","RALT","LCTRL","RCTRL","LSHIFT","RSHIFT","TAB","CAPSLOCK","SPACE","MINUS","EQUALS","BACKSPACE","INSERT","HOME","DELETE","END","PAGEUP","PAGEDOWN","PRINT","SCROLLOCK","PAUSE","PERIOD","SLASH","SEMICOLON","LEFTBRACKET","RIGHTBRACKET","BACKSLASH","UP","DOWN","LEFT","RIGHT","NUM0","NUM1","NUM2","NUM3","NUM4","NUM5","NUM6","NUM7","NUM8","NUM9","NUM.","NUM/","NUM*","NUM-","NUM+","0","1","2","3","4","5","6","7","8","9"}
local keylist = {}
for i = 1, #keys do
  keylist[i] = {description = keys[i], data = "KEY_"..string.upper(keys[i])}
end
keylist[#keylist + 1] = {description = "Disabled", data = false}
local function AddConfig(label, name, options, default, hover)
  return {label = label, name = name, options = options, default = default, hover = hover or ""}
end
configuration_options =
{
  AddConfig("启动热键（默认R）", "Attack_key", keylist, "KEY_R","发动攻击"),
  -- AddConfig("开启/关闭 自动攻击的热键", "Auto_Attack_key", keylist, "KEY_DELETE","相当于一直按住启动热键（默认Delete）"),
  AddConfig("[游戏内调整的热键]增加攻击持续帧数（11帧最慢）", "Adddelay_key", keylist, "KEY_UP","增加攻击后摇"),
  AddConfig("[游戏内调整的热键]减少攻击持续帧数（8帧最快）", "Reducedelay_key", keylist, "KEY_DOWN","降低攻击后摇"),
  AddConfig("[游戏内调整的热键]增加发包的帧数（11帧最慢）", "Addkeyframe_key", keylist, "KEY_RIGHT","延后启动关键帧"),
  AddConfig("[游戏内调整的热键]减少发包的帧数（8帧最快）", "Reducekeyframe_key", keylist, "KEY_LEFT","提前启动关键帧"),
  {
    name = "Default_delay",
    label = "默认攻击频率",
    hover = "调节每次攻击帧的步长",
    options = {
      {description = "1帧", data = 1},
      {description = "2帧", data = 2},
      {description = "3帧", data = 3},
      {description = "4帧", data = 4},
      {description = "5帧", data = 5},
      {description = "6帧", data = 6},
      {description = "7帧", data = 7},
      {description = "8帧", data = 8},
      {description = "9帧", data = 9},
      {description = "10帧", data = 10},
      {description = "11帧", data = 11},
    },
    default = 8,
  }, 
  {
    name = "Default_keyframe",
    label = "默认关键帧",
    hover = "调节攻击的顺序帧",
    options = {
      {description = "第0'th 帧", data = 0},
      {description = "第1'st 帧", data = 1},
      {description = "第2'nd 帧", data = 2},
      {description = "第3'th 帧", data = 3},
      {description = "第4'th 帧", data = 4},
      {description = "第5'th 帧", data = 5},
      {description = "第6'th 帧", data = 6},
      {description = "第7'th 帧", data = 7},
      {description = "第8'th 帧", data = 8},
      {description = "第9'th 帧", data = 9},
      {description = "第10'th 帧", data = 10},
      {description = "第11'th 帧", data = 11},
    },
    default = 8,
  },
  {
    name = "anchor",
    hover = "主播模式只会在控制台print出来信息，不会说出来",
    label = "主播模式",
    options = {
        {description = "Off", data = false, hover = "Disabled"},
        {description = "On", data = true, hover = "Enabled"},
    },
    default = true
  },
  {
    name = "checkanim",
    hover = "是否打印每一次攻击发包的信息（会很乱）",
    label = "打印动画",
    options = {
        {description = "Off", data = false, hover = "Disabled"},
        {description = "On", data = true, hover = "Enabled"},
    },
    default = false
  },
}
