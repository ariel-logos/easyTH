addon.author = 'Arielfy';
addon.name = 'EasyTH';
addon.version = '0.4';
addon.desc = 'Tracks Treasure Hunter procs'
addon.link = 'https://github.com/ariel-logos/easyTH'
addon.commands = {'/easyth anyjob'}

require 'common'

local imgui = require('imgui'); 
local parser = require('parser');
local ffi = require("ffi");

local default_config = 
{
	 window = {x = 200, y = 100},
};

local enemyName = ""
local currentTH = 0
local defeatCD = 0
local currentPacket
local currentEnemy = 0
local playerJob = -1
local partyIDs = {}
local enemies = {}
local anyJob = false
local enemyCount = 0

ashita.events.register("load", "load_cb", function ()
end);


ashita.events.register("unload", "unload_cb", function ()
end);


ashita.events.register("d3d_present", "present_cb", function()

	local player = AshitaCore:GetMemoryManager():GetPlayer();
	local loggedin = player:GetLoginStatus()
	if loggedin ~= 2 then
		currentEnemy = 0
		enemyName = ""
		currentTH = 0
		enemies = {}
		enemyCount = 0
	end

	playerJob = AshitaCore:GetMemoryManager():GetPlayer():GetMainJob();
	if playerJob == 6 or anyJob then
		
		imgui.SetNextWindowPos({default_config.window.y, default_config.window.x}, ImGuiCond_FirstUseEver);
		local windowFlags = bit.bor(
		ImGuiWindowFlags_NoDecoration, 
		ImGuiWindowFlags_AlwaysAutoResize, 
		ImGuiWindowFlags_NoFocusOnAppearing, 
		ImGuiWindowFlags_NoNav, 
		--ImGuiWindowFlags_NoBackground, 
		ImGuiWindowFlags_NoBringToFrontOnFocus);
	
	   if (enemyCount > 0 and imgui.Begin('Treasure Hunter Tracker', true, windowFlags)) then
			
    		if enemyName == "" then
    			imgui.Text('EasyTH')
				imgui.Separator();
				imgui.Text('------')
    		else
	    		imgui.Text(enemyName)
				imgui.Separator();
				imgui.Text('TH Lvl: '..currentTH)
			end

			imgui.End();
  		end
  	end
end)

ashita.events.register('command', 'easyth_command', function(e)
	local args = e.command:args();
	
	if #args == 0 then return end
	
	if not args[1]:any('/easyth') then
		return false;
	end
	
	e.blocked = true
	
	if #args == 2 and args[2]:any('anyjob') then
		anyJob = not anyJob
		if anyJob then print('[EasyTH] TH is now tracked on any Job.')
		else print('[EasyTH] TH is now tracked on THF.') end
	end
	
	if #args == 2 and args[2]:any('reset') then
		enemyName = ""
		currentTH = 0
		defeatCD = 0
		currentEnemy = 0
		partyIDs = {}
		enemies = {}
		enemyCount = 0
		print('[EasyTH] Tracking has been reset.')
	end
end);


ashita.events.register('packet_in', 'packet_in_cb', function(e)

	if e.injected == true then
        return;
    end
	if playerJob == 6 or anyJob then
		if (e.id == 0x0029) then
			
			local message_id = struct.unpack('H', e.data, 0x19)%2^15
			local target_id = struct.unpack('I', e.data, 0x09)
			if (message_id == 6 or message_id == 20) then
				if target_id == currentEnemy then
					currentEnemy = 0
					currentTH = 0
					enemyName = ''			
				end
				if enemies[tostring(target_id)] then
					enemies[tostring(target_id)] = nil
					enemyCount = enemyCount - 1
				end
			end
		end
		if (e.id == 0x0028) then
			
			local m_uID = UnpackData(e.data_raw, e.size, 40, 32)
			local a_type = UnpackData(e.data_raw, e.size, 82, 4)

			if (a_type ~= 1 and a_type ~= 3) then return end
			
			if #partyIDs == 0 then GetPartyIDs() end
						
			local found = false
			for _, p in ipairs(partyIDs) do
			
				if m_uID == p then
					found = true
					break
				end
			end
			if not found then return end
			
			currentPacket = parser.parse(e.data);
			
			if currentEnemy ~= currentPacket.target[1].m_uID then
				GetPartyIDs()
				if partyIDs[1] == m_uID then currentEnemy = currentPacket.target[1].m_uID end
				enemyStr = tostring(currentPacket.target[1].m_uID)
				if enemies[enemyStr] then
					if partyIDs[1] == m_uID then
						enemyName = enemies[enemyStr][1]
						currentTH = enemies[enemyStr][2]
					end
				else
					if partyIDs[1] == m_uID then
						enemyName = currentPacket.target[1].target_name
						currentTH = 0
					end
					enemies[enemyStr] = {currentPacket.target[1].target_name, currentTH}
					enemyCount = enemyCount + 1
				end	
			end
			
			local target = currentPacket.target[1]		
			target.result:each(function (v, k)
				if v.proc_kind == 7 and v.proc_message == 603 then
					if partyIDs[1] == m_uID then currentTH = v.proc_value end
					if enemies[tostring(currentPacket.target[1].m_uID)] then enemies[tostring(currentPacket.target[1].m_uID)][2] = v.proc_value end
				end
			end)
		end
	end

end);

function GetPartyIDs()

	partyIDs = {}
	local thfFound = false
	local partyID = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(0)
	local partyJob = AshitaCore:GetMemoryManager():GetParty():GetMemberMainJob(0)
	table.insert(partyIDs, partyID)
	if partyJob == 6 then thfFound = true end
	for i = 1, 15 do
		partyID = AshitaCore:GetMemoryManager():GetParty():GetMemberServerId(i)
		partyJob = AshitaCore:GetMemoryManager():GetParty():GetMemberMainJob(i)
		if partyID > 0 and partyJob == 6 then
			table.insert(partyIDs, partyID)
			thfFound = true
		end
	end
	if not thfFound then partyIDs = {} end
end

function UnpackData(e_data_raw, e_size, offset, length)
	if offset + length >= e_size * 8 then return 0 end
	return ashita.bits.unpack_be(e_data_raw, 0, offset, length);
end