script_name('SanTropeHelper')
script_author('Xarlamov')
script_version('1.01')

require 'lib.sampfuncs'
require "lib.moonloader"
local keys = require "vkeys"
local ev = require 'lib.samp.events'
local mem = require "memory"
local imgui = require 'imgui'
local inicfg = require 'inicfg'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local ffi = require'ffi'
local mimgui = require'mimgui'

directIni = "SanTropeHelper.ini"
local mainIni = inicfg.load(
{settings = 
	{
	BindLock = "[18,82]",
    BindSbiv = "[18,83]",
	settings_command = 'sth',
	state_lock = false,
	state_sbiv = false,
	state_repcar = false,
	state_usedrug = false,
	state_skiprep = false,
	state_infrun = false,
	state_dflood = false,
	state_scho = false,
	state_delgovna = false,
	style = 1
	}
}, directIni)
lock = imgui.ImBool(mainIni.settings.state_lock)
sbiv = imgui.ImBool(mainIni.settings.state_sbiv)
repcar = imgui.ImBool(mainIni.settings.state_repcar)
usedrug = imgui.ImBool(mainIni.settings.state_usedrug)
skiprep = imgui.ImBool(mainIni.settings.state_skiprep)
infrun = imgui.ImBool(mainIni.settings.state_infrun)
dflood = imgui.ImBool(mainIni.settings.state_dflood)
scho = imgui.ImBool(mainIni.settings.state_scho)
delgovna = imgui.ImBool(mainIni.settings.state_delgovna)
local style_selected = imgui.ImInt(mainIni.settings.style)
local style_list = {u8"Ò¸ìíî-Îðàíæåâàÿ", u8"Ñèíÿÿ", u8"Ò¸ìíàÿ", u8"Âèøí¸âàÿ", u8"Ò¸ìíî-çåë¸íàÿ", u8"Êðàñíàÿ", u8"Ôèîëåòîâàÿ"}
local rkeys = require 'rkeys'
imgui.HotKey = require('imgui_addons').HotKey
imgui.ToggleButton = require('imgui_addons').ToggleButton
local tLastKeys = {}

local settings_command = imgui.ImBuffer(mainIni.settings.settings_command, 16)

local LockKey = {
	v = decodeJson(mainIni.settings.BindLock)
}
local SbivAnimKey = {
	v = decodeJson(mainIni.settings.BindSbiv)
}

main_window_state = imgui.ImBool(false)
local select = 1

-- àâòî îáíîâà
local dlstatus = require('moonloader').download_status

update_state = false

local script_vers = 2
local script_vers_text = 1.01

local update_url = 'https://raw.githubusercontent.com/xarlamovl/scripts/main/update.ini'
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = 'https://raw.githubusercontent.com/xarlamovl/scripts/main/SanTropeHelper.lua'
local script_path = thisScript().path

local tag = '{00FFFF}[SanTrope Helper]: {FFFFFF}'


function check_update() -- Ñîçäà¸ì ôóíêöèþ êîòîðàÿ áóäåò ïðîâåðÿòü íàëè÷èå îáíîâëåíèé ïðè çàïóñêå ñêðèïòà.
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then -- Ñâåðÿåì âåðñèþ â ñêðèïòå è â ini ôàéëå íà github
                sampAddChatMessage(tag.."Èìååòñÿ {32CD32}íîâàÿ {FFFFFF}âåðñèÿ ñêðèïòà. Âåðñèÿ: {32CD32}"..updateIni.info.vers_text, -1) -- Ñîîáùàåì î íîâîé âåðñèè.
                update_state = true -- åñëè îáíîâëåíèå íàéäåíî, ñòàâèì ïåðåìåííîé çíà÷åíèå true
            end
            os.remove(update_path)
        end
    end)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
	sampAddChatMessage(tag..'Çàãðóæåí! Âåðñèÿ: '..thisScript().version..'. Îòêðûòü ìåíþ: /'..mainIni.settings.settings_command, -1)
    sampRegisterChatCommand(mainIni.settings.settings_command, cmd_sth)
	
    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)
	
    imgui.Process = false
	
	style(style_selected.v)
	
    BindLock = rkeys.registerHotKey(LockKey.v, true, lockFunc)
    BindSbiv = rkeys.registerHotKey(SbivAnimKey.v, true, sbivFunc)
	
	check_update()
	
    while true do wait(0)
	
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(tag.."Ñêðèïò {32CD32}óñïåøíî {FFFFFF}îáíîâë¸í.", -1)
                end
            end)
            break
        end
	
		if delgovna.v then
			delete()
		end
		
		if skiprep.v then
			function ev.onShowDialog(id, style, title, btn1, btn2 , text)
				if id == 772 then
					sampCloseCurrentDialogWithButton(0)
				end
			end
		end
		
    end
end

function cmd_sth(arg)
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
end

function lockFunc()
	if lock.v and not sampIsDialogActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then 
		sampSendChat("/lock")
	end
end

function sbivFunc()
	if sbiv.v and not sampIsDialogActive() and not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not isCharInAnyCar(1) and not isCharInAnyHeli(1) and not isCharInAnyPlane(1) and not isCharInAnyBoat(1) and not isCharInAnyPoliceVehicle(1) then
		lua_thread.create(function()
			sampSendChat('/anim 3')
			wait(80)
			setVirtualKeyDown(32, true) wait(1) setVirtualKeyDown(32, false)
		end)
	end
end


addEventHandler("onWindowMessage", function (msg, wparam, lparam)
    if wparam == keys.VK_ESCAPE or wparam == keys.VK_TAB then
        if main_window_state.v then main_window_state.v = false consumeWindowMessage(true, true) end
    end
end)

function imgui.OnDrawFrame()
	
    if not main_window_state.v then
        imgui.Process = false
    end
	
    if main_window_state.v then
        local sw, sh = getScreenResolution()
		
		x, y, z = getCharCoordinates(PLAYER_PED)
		
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 350), imgui.Cond.FirstUseEver)
		
        imgui.Begin('SanTrope Helper', main_window_state, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		
		imgui.Text(u8(string.format('Òåêóùàÿ äàòà: %s.', os.date())))
		imgui.Text(u8'Òâîé íèê: '..nick..'['..id..'].')
		imgui.SameLine()
		imgui.Text(u8'Òâîè êîîðäèíàòû: X: '..math.floor(x)..' | Y: '..math.floor(y)..' | Z: '..math.floor(z))
		
		imgui.BeginChild('##1', imgui.ImVec2(150,45), true)
            if imgui.Selectable(u8"Ìåíþ") then
                select = 1
            end
            if imgui.Selectable(u8"Íàñòðîéêè") then
                select = 2 
            end   
       
        imgui.EndChild()
		imgui.SameLine()
		
			imgui.BeginChild('##2', imgui.ImVec2(-1, -1), true)
			
				if select == 1 then
					imgui.Text(u8'Ìåíþ')
				elseif select == 2 then
					imgui.Text(u8'Íàñòðîéêè')
				end
				
				imgui.Separator()
				imgui.Spacing()
				if select == 1 then
				
					if imgui.ToggleButton(u8'##LOCK_KEY', lock) then end
						imgui.SameLine()
						imgui.Text(u8'Çàêðûâàòü ò/ñ íà')
						imgui.SetCursorPos(imgui.ImVec2(126, 30))

							if imgui.HotKey("##LOCK", LockKey, tLastKeys, 30) then
								rkeys.changeHotKey(BindLock, LockKey.v)
							end
						imgui.SameLine()
						imgui.TextQuestion('Îòêðûâàåò/Çàêðûâàåò ëè÷íûé ò/ñ')
					
					if imgui.ToggleButton("##SBIV_ANIM_KEY", sbiv) then end
						imgui.SameLine()
						imgui.Text(u8"Ñáèâ àíèìàöèè íà")
						imgui.SetCursorPos(imgui.ImVec2(147, 50))
						
							if imgui.HotKey("##SBIV_ANIM", SbivAnimKey, tLastKeys, 30) then
								rkeys.changeHotKey(BindSbiv, SbivAnimKey.v)
							end
						imgui.SameLine()
						imgui.TextQuestion('Ñáèâ àíèìàöèè ÷åðåç /anim 3')
					
					if imgui.ToggleButton('##REPCAR', repcar) then end
						imgui.SameLine()
						imgui.Text(u8'Ïî÷èíèòü ò/ñ (/rc)')
						imgui.SameLine()
						imgui.TextQuestion("Ñîêðàùåíèå êîìàíäû /repairkit")
						
					if imgui.ToggleButton('##USEDRUG', usedrug) then end
						imgui.SameLine()
						imgui.Text(u8'Ïðèíÿòèå íàðêîòèêîâ (/us [1-7])')
						imgui.SameLine()
						imgui.TextQuestion("Ñîêðàùåíèå êîìàíäû /usedrugs")
						
					if imgui.ToggleButton('##SKIP_REPORT', skiprep) then end
						imgui.SameLine()
						imgui.Text(u8'Àâòî çàêðûòèå îòâåòà íà ðåïîðò(Ðàçðàáîòêà)')
						imgui.SameLine()
						imgui.TextQuestion("Àâòîìàòè÷åñêè çàêðûâàåò îêíî ñ îòâåòîì àäìèíèñòðàòîðà íà Âàø ðåïîðò")
						
					if imgui.ToggleButton('##INF_RUN', infrun) then end
						imgui.SameLine()
						imgui.Text(u8'Áåñêîíå÷íûé áåã')
						imgui.SameLine()
						imgui.TextQuestion("Ñàìûé îáû÷íûé áåñêîíå÷íûé áåã(maybe not working)")
						
					if imgui.ToggleButton(u8"##DONT_FLOOD", dflood) then end
						imgui.SameLine()
						imgui.Text(u8'Óäàëåíèå "Íå ôëóäèòå."')
						imgui.SameLine()
						imgui.TextQuestion('Óäàëÿåò "* Íå ôëóäèòå." èç ÷àòà')
						
					if imgui.ToggleButton(u8"##SCHO", scho) then end
						imgui.SameLine()
						imgui.Text(u8"×åêåð îíëàéíà(/scho)")
						imgui.SameLine()
						imgui.TextQuestion('Ïîêàçûâàåò îíëàéí íåêîòîðûõ ôðàêöèé')
						
					if imgui.ToggleButton(u8"##DEL_GOVNA", delgovna) then end
						imgui.SameLine()
						imgui.Text(u8"Óäàëåíèå êèëë-ëèñòà ñåðâåðà")
						imgui.SameLine()
						imgui.TextQuestion('Óäàëÿåò êèëë-ëèñò ÑàíÒðîïà è íåêîòîðûå ñåðâåðíûå òåêñòäðàâû')
					
				elseif select == 2 then
					imgui.Text(u8'Êîìàíäà àêòèâàöèè ìåíþ')
					imgui.SetCursorPos(imgui.ImVec2(162, 31))
					imgui.PushItemWidth(70)
					imgui.InputText(u8"##1", settings_command)
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.TextQuestion('Ìîæåòå óñòàíîâèòü ñâîþ êîìàíäó àêòèâàöèè ìåíþ.\nÊîìàíäà äîëæíà áûòü áåç "/".')
					
					imgui.Text(u8'Âûáåðèòå ñòèëü òåìû')
					imgui.SetCursorPos(imgui.ImVec2(140, 52))
					imgui.PushItemWidth(135)
					if imgui.Combo(u8"", style_selected, style_list, style_selected) then
						style(style_selected.v)
					end
					imgui.PopItemWidth()
				end
			imgui.EndChild()
			imgui.SetCursorPos(imgui.ImVec2(8, 110))
			imgui.BeginChild(u8'##3', imgui.ImVec2(150, 58), true)
				if imgui.Button(u8'Ñîõðàíèòü íàñòðîéêè',  imgui.ImVec2(138, 20)) then 
				
					sampUnregisterChatCommand(mainIni.settings.SettingsCommand)
					
					updateSet()
					
					sampRegisterChatCommand(mainIni.settings.SettingsCommand, cmd_sth)
					inicfg.save(mainIni, directIni)
					
				end
				if imgui.Button(u8'Ïåðåçàãðóçèòü ñêðèïò', imgui.ImVec2(138, 20)) then
					thisScript():reload()
				end
			imgui.EndChild()
			imgui.Text(u8'Îá àâòîðå ñêðèïòà:')
			imgui.Text('VK: @bebebrrra')
				if imgui.IsItemClicked(0) then
					os.execute('explorer "https://vk.com/bebebrrra"')
					imgui.Process = not main_window_state
				end
			imgui.SameLine()
			imgui.TextQuestion('*Êëèêàáåëüíî.')
			
			imgui.Text(u8'Ãðóïïà â VK: xarlamsq')
				if imgui.IsItemClicked(0) then
					os.execute('explorer "https://vk.com/xarlamsq"')
					imgui.Process = not main_window_state
				end
			imgui.SameLine()
			imgui.TextQuestion('Ïîäïèøèñü ïæ)')
			
			imgui.Text(u8'Ïîæåðòâîâàíèÿ')
				if imgui.IsItemClicked(0) then
					os.execute('explorer "https://vk.me/moneysend/bebebrrra"')
					imgui.Process = not main_window_state
				end
			imgui.SameLine()
			imgui.TextQuestion('*Êëèêàáåëüíî.')
			

        imgui.End()
    end
end

function updateSet()
	mainIni.settings.BindLock = encodeJson(LockKey.v)
	mainIni.settings.BindSbiv = encodeJson(SbivAnimKey.v)
	mainIni.settings.style = style_selected.v
	mainIni.settings.state_lock = lock.v
	mainIni.settings.state_repcar = repcar.v
	mainIni.settings.state_usedrug = usedrug.v
	mainIni.settings.state_skiprep = skiprep.v
	mainIni.settings.state_dflood = dflood.v
	mainIni.settings.state_sbiv = sbiv.v
	mainIni.settings.state_scho = scho.v
	mainIni.settings.state_delgovna = delgovna.v
	mainIni.settings.settings_command = settings_command.v

	inicfg.save(mainIni, directIni)
end

--del govna
local array = {440,442,444,446,448,450,452,454,456,458,174,175,176,2076,2077,322,323}

function delete()
    for i = 1, #array do
        result = sampTextdrawIsExists(array[i])
        if result == true then
            sampTextdrawDelete(array[i])
        end
    end
    wait (2000)
    delete()
end
--skiprep
function ev.onShowDialog(id, style, title, btn1, btn2 , text)
	if skiprep.v then
		if id == 772 then
			sampCloseCurrentDialogWithButton(0)
		end
	end
end
--dflood and sbiv anim
function ev.onServerMessage(color, text)
	if dflood.v then
		if text:find('{AA3333}%* {828282}Íå ôëóäèòå%.') then
			return false
		end
	end
	
	if sbiv.v then
		if text:find("{4582A1}%* {FFFFFF}Âûêëþ÷èòü àíèìàöèþ ìîæíî êëàâèøåé {4582A1}%'Ïðîáåë%'{FFFFFF}%.") then
			lua_thread.create(function() wait(80)
				setVirtualKeyDown(32, true) wait(1) setVirtualKeyDown(32, false)
			end)
		end
	end
	
end
-- promtp
function imgui.TextQuestion(text)
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.TextUnformatted(u8(text))
        imgui.EndTooltip()
    end
end
--scho
local clists = {
	{
		0xAA009900, -- grove.
		0xAACC00FF, -- ballas.
		0xAAFFFF00, -- vagos.
		0xAA6666FF, -- rifa.
		0xAA00CCFF, -- aztec.
		0xAAFF0000, -- pirus.
		0xFFDDA701, -- lcn.
		0xBB880000, -- yakuza.
		0xBBA1AAAD, -- rm.
		0x800099CC, -- lz.
		0x804B0082, -- ha.
		0x80FF6600, -- cnn.
		0xFF8FBC8F, -- collector.
		0x007A7667, -- masked.
		0x80FFFFFF, -- bomj.
	}
}

local texts_scho = {
	'Grove: {$CLR}$CNT {FFFFFF}| Ballas: {$CLR}$CNT {FFFFFF}| Vagos: {$CLR}$CNT {FFFFFF}| Rifa: {$CLR}$CNT {FFFFFF}| Aztec: {$CLR}$CNT\nPirus: {$CLR}$CNT {FFFFFF}| LCN: {$CLR}$CNT {FFFFFF}| Yakuza: {$CLR}$CNT {FFFFFF}| RM: {$CLR}$CNT {FFFFFF}| LZ: {$CLR}$CNT {FFFFFF}| HA: {$CLR}$CNT\nCNN: {$CLR}$CNT {FFFFFF}| Collector: {$CLR}$CNT {FFFFFF}| Masked: {$CLR}$CNT {FFFFFF}| Bomj: {$CLR}$CNT',
}
--my shit code)
local cmd_rc = mimgui.new.char[128]('rc')
local cmd_us1 = mimgui.new.char[128]('us 1')
local cmd_us2 = mimgui.new.char[128]('us 2')
local cmd_us3 = mimgui.new.char[128]('us 3')
local cmd_us4 = mimgui.new.char[128]('us 4')
local cmd_us5 = mimgui.new.char[128]('us 5')
local cmd_us6 = mimgui.new.char[128]('us 6')
local cmd_us7 = mimgui.new.char[128]('us 7')
local cmd_scho = mimgui.new.char[128]('scho')


function ev.onSendCommand(text)
	if repcar.v and text:match('/'..ffi.string(cmd_rc)) then
        sampSendChat('/repairkit')
        return false
    end
	if usedrug.v then 
		if text:match('/'..ffi.string(cmd_us1)) then
			sampSendChat('/usedrugs 1')
			return false
		end
		if text:match('/'..ffi.string(cmd_us2)) then
			sampSendChat('/usedrugs 2')
			return false
		end
		if text:match('/'..ffi.string(cmd_us3)) then
			sampSendChat('/usedrugs 3')
			return false
		end
		if text:match('/'..ffi.string(cmd_us4)) then
			sampSendChat('/usedrugs 4')
			return false
		end
		if text:match('/'..ffi.string(cmd_us5)) then
			sampSendChat('/usedrugs 5')
			return false
		end
		if text:match('/'..ffi.string(cmd_us6)) then
			sampSendChat('/usedrugs 6')
			return false
		end
		if text:match('/'..ffi.string(cmd_us7)) then
			sampSendChat('/usedrugs 7')
			return false
		end
	end
	if scho.v and text:match('/'..ffi.string(cmd_scho)) then
		local text_scho = texts_scho[1]
		for i = 1, #clists[1] do
			local online = 0
			for l = 0, 1004 do
				if sampIsPlayerConnected(l) then
					if sampGetPlayerColor(l) == clists[1][i] then online = online + 1 end
				end
			end
			text_scho = text_scho:gsub('$CLR', ('%06X'):format(bit.band(clists[1][i], 0xFFFFFF)), 1)
			text_scho = text_scho:gsub('$CNT', online, 1)
		end
		for w in text_scho:gmatch('[^\r\n]+') do sampAddChatMessage(w, -1)end
		return false
	end
end
--ïðîâåðêà íà ñåðâåð
function getCurrentServer(name)
	if name:find('SanTrope RP #1') or name:find('SanTrope RP #2') then return 1 end
end

-- themes imgui
function style(id)
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    if id == 0 then -- dark - orange
        colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
		colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
		colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
		colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
		colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)

    elseif id == 1 then -- blue
        colors[clr.FrameBg]                 = ImVec4(0.16, 0.29, 0.48, 0.54)
        colors[clr.FrameBgHovered]          = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.FrameBgActive]           = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.TitleBg]                 = ImVec4(0.04, 0.04, 0.04, 1.00)
        colors[clr.TitleBgActive]           = ImVec4(0.16, 0.29, 0.48, 1.00)
        colors[clr.TitleBgCollapsed]        = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.CheckMark]               = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.SliderGrab]              = ImVec4(0.24, 0.52, 0.88, 1.00)
        colors[clr.SliderGrabActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Button]                  = ImVec4(0.26, 0.59, 0.98, 0.40)
        colors[clr.ButtonHovered]           = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ButtonActive]            = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[clr.Header]                  = ImVec4(0.26, 0.59, 0.98, 0.31)
        colors[clr.HeaderHovered]           = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[clr.HeaderActive]            = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.Separator]               = colors[clr.Border]
        colors[clr.SeparatorHovered]        = ImVec4(0.26, 0.59, 0.98, 0.78)
        colors[clr.SeparatorActive]         = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ResizeGrip]              = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[clr.ResizeGripHovered]       = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.ResizeGripActive]        = ImVec4(0.26, 0.59, 0.98, 0.95)
        colors[clr.TextSelectedBg]          = ImVec4(0.26, 0.59, 0.98, 0.35)
        colors[clr.Text]                    = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]            = ImVec4(0.50, 0.50, 0.50, 1.00)
        colors[clr.WindowBg]                = ImVec4(0.06, 0.06, 0.06, 0.94)
        colors[clr.ChildWindowBg]           = ImVec4(1.00, 1.00, 1.00, 0.00)
        colors[clr.PopupBg]                 = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.ComboBg]                 = colors[clr.PopupBg]
        colors[clr.Border]                  = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]            = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.MenuBarBg]               = ImVec4(0.14, 0.14, 0.14, 1.00)
        colors[clr.ScrollbarBg]             = ImVec4(0.02, 0.02, 0.02, 0.53)
        colors[clr.ScrollbarGrab]           = ImVec4(0.31, 0.31, 0.31, 1.00)
        colors[clr.ScrollbarGrabHovered]    = ImVec4(0.41, 0.41, 0.41, 1.00)
        colors[clr.ScrollbarGrabActive]     = ImVec4(0.51, 0.51, 0.51, 1.00)
        colors[clr.CloseButton]             = ImVec4(0.41, 0.41, 0.41, 0.50)
        colors[clr.CloseButtonHovered]      = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.CloseButtonActive]       = ImVec4(0.98, 0.39, 0.36, 1.00)
        colors[clr.PlotLines]               = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered]        = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram]           = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]    = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.ModalWindowDarkening]    = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 2 then -- dark
        colors[clr.Text]                    = ImVec4(0.80, 0.80, 0.83, 1.00)
        colors[clr.TextDisabled]            = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.WindowBg]                = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ChildWindowBg]           = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.PopupBg]                 = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border]                  = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]            = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.FrameBgHovered]          = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive]           = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg]                 = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.TitleBgCollapsed]        = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive]           = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.MenuBarBg]               = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg]             = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab]           = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered]    = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ComboBg]                 = ImVec4(0.19, 0.18, 0.21, 1.00)
        colors[clr.CheckMark]               = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrab]              = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.SliderGrabActive]        = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.Button]                  = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered]           = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive]            = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header]                  = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered]           = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive]            = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip]              = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered]       = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive]        = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CloseButton]             = ImVec4(0.40, 0.39, 0.38, 0.16)
        colors[clr.CloseButtonHovered]      = ImVec4(0.40, 0.39, 0.38, 0.39)
        colors[clr.CloseButtonActive]       = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines]               = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered]        = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram]           = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered]    = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg]          = ImVec4(0.25, 1.00, 0.00, 0.43)
        colors[clr.ModalWindowDarkening]    = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif id == 3 then -- cherry
        colors[clr.Text]                    = ImVec4(0.860, 0.930, 0.890, 0.78)
        colors[clr.TextDisabled]            = ImVec4(0.860, 0.930, 0.890, 0.28)
        colors[clr.WindowBg]                = ImVec4(0.13, 0.14, 0.17, 1.00)
        colors[clr.ChildWindowBg]           = ImVec4(0.200, 0.220, 0.270, 0.58)
        colors[clr.PopupBg]                 = ImVec4(0.200, 0.220, 0.270, 0.9)
        colors[clr.Border]                  = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow]            = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                 = ImVec4(0.200, 0.220, 0.270, 1.00)
        colors[clr.FrameBgHovered]          = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[clr.FrameBgActive]           = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.TitleBg]                 = ImVec4(0.232, 0.201, 0.271, 1.00)
        colors[clr.TitleBgActive]           = ImVec4(0.502, 0.075, 0.256, 1.00)
        colors[clr.TitleBgCollapsed]        = ImVec4(0.200, 0.220, 0.270, 0.75)
        colors[clr.MenuBarBg]               = ImVec4(0.200, 0.220, 0.270, 0.47)
        colors[clr.ScrollbarBg]             = ImVec4(0.200, 0.220, 0.270, 1.00)
        colors[clr.ScrollbarGrab]           = ImVec4(0.09, 0.15, 0.1, 1.00)
        colors[clr.ScrollbarGrabHovered]    = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[clr.ScrollbarGrabActive]     = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.CheckMark]               = ImVec4(0.71, 0.22, 0.27, 1.00)
        colors[clr.SliderGrab]              = ImVec4(0.47, 0.77, 0.83, 0.14)
        colors[clr.SliderGrabActive]        = ImVec4(0.71, 0.22, 0.27, 1.00)
        colors[clr.Button]                  = ImVec4(0.47, 0.77, 0.83, 0.14)
        colors[clr.ButtonHovered]           = ImVec4(0.455, 0.198, 0.301, 0.86)
        colors[clr.ButtonActive]            = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.Header]                  = ImVec4(0.455, 0.198, 0.301, 0.76)
        colors[clr.HeaderHovered]           = ImVec4(0.455, 0.198, 0.301, 0.86)
        colors[clr.HeaderActive]            = ImVec4(0.502, 0.075, 0.256, 1.00)
        colors[clr.ResizeGrip]              = ImVec4(0.47, 0.77, 0.83, 0.04)
        colors[clr.ResizeGripHovered]       = ImVec4(0.455, 0.198, 0.301, 0.78)
        colors[clr.ResizeGripActive]        = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.PlotLines]               = ImVec4(0.860, 0.930, 0.890, 0.63)
        colors[clr.PlotLinesHovered]        = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.PlotHistogram]           = ImVec4(0.860, 0.930, 0.890, 0.63)
        colors[clr.PlotHistogramHovered]    = ImVec4(0.455, 0.198, 0.301, 1.00)
        colors[clr.TextSelectedBg]          = ImVec4(0.455, 0.198, 0.301, 0.43)
        colors[clr.ModalWindowDarkening]    = ImVec4(0.200, 0.220, 0.270, 0.73)
    elseif id == 4 then -- dark green
		colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
		colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
		colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
	elseif id == 5 then --red
		colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
		colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
		colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
		colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
		colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Separator]              = colors[clr.Border]
		colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
		colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
		colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
		colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = colors[clr.PopupBg]
		colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
	elseif id == 6 then --violet
		colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
		colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
		colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
		colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
		colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
		colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
		colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
		colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
		colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
		colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
		colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
		colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
		colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
		colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
		colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
		colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
		colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
		colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
		colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
		colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
		colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
		colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
		colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
		colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
		colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
    end
end
