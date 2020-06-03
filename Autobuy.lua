local client_exec = client.exec
local ui_get = ui.get

local Autobuy = {
    Enabled = ui.new_checkbox('Lua', 'B', 'Autobuy'),
	PrimaryWeapon = ui.new_combobox('Lua', 'B', 'Primary weapon', 'Off', 'MAC-10 | MP9', 'MP7 | MP5-SD', 'UMP-45', 'P90', 'PP-Bizon', 'Galil AR | FAMAS', 'AK-47 | M4A4 | M4A1-S', 'SSG 08', 'AUG', 'AWP', 'G3SG1 | SCAR-20', 'Nova', 'XM1014', 'Sawed-Off | MAG-7', 'M249', 'Negev'),
	SecondaryWeapon = ui.new_combobox('Lua', 'B', 'Secondary weapon', 'Off', 'Glock-18 | P2000 | USP-S', 'Dual Berettas', 'P250', 'CZ75-Auto | Five-SeveN | Tec-9', 'Desert Eagle | R8 Revolver'),
	Armor = ui.new_combobox('Lua', 'B', 'Armor', 'Off', 'Kevlar', 'Kevlar + Helmet'),
	Grenades = ui.new_multiselect('Lua', 'B', 'Grenades', 'HE Grenade', 'Smoke Grenade', 'Molotov', 'Flashbang', 'Decoy'),
	Utility = ui.new_multiselect('Lua', 'B', 'Utility', 'Defuser', 'Taser')
}

local function HandleMenuItems()
	local isEnabled = ui.get(Autobuy.Enabled)
	ui.set_visible(Autobuy.PrimaryWeapon, isEnabled)
	ui.set_visible(Autobuy.SecondaryWeapon, isEnabled)
	ui.set_visible(Autobuy.Armor, isEnabled)
	ui.set_visible(Autobuy.Utility, isEnabled)
	ui.set_visible(Autobuy.Grenades, isEnabled)
end
ui.set_callback(Autobuy.Enabled, HandleMenuItems)
HandleMenuItems()

local BuyCommands = {
	PrimaryWeapon = {
		['MAC-10 | MP9'] = 'buy mac10;',
		['MP7 | MP5-SD'] = 'buy mp7;',
		['UMP-45'] = 'ump45',
		['P90'] = 'buy p90;',
		['PP-Bizon'] = 'buy bizon;',
		['Galil AR | FAMAS'] = 'buy galilar;',
		['AK-47 | M4A4 | M4A1-S'] = 'buy ak47;',
		['SSG 08'] = 'buy ssg08;',
		['AUG'] = 'buy aug;',
		['AWP'] = 'buy awp;',
		['G3SG1 | SCAR-20'] = 'buy g3sg1;',
		['Nova'] = 'buy nova;',
		['XM1014'] = 'buy xm1014;',
		['Sawed-Off | MAG-7'] = 'buy sawedoff;',
		['M249'] = 'buy m249;',
		['Negev'] = 'buy negev;'
	},
	SecondaryWeapon = {
		['Glock-18 | P2000 | USP-S'] = 'buy glock;',
		['Dual Berettas'] = 'buy elite;',
		['P250'] = 'buy p250;',
		['CZ75-Auto | Five-SeveN | Tec-9'] = 'buy tec9;',
		['Desert Eagle | R8 Revolver'] = 'buy deagle;'
	},
	Armor = {
		['Kevlar'] = 'buy vest;',
		['Kevlar + Helmet'] = 'buy vesthelm;'
	}
}

client.set_event_callback('round_prestart', function ()
	if not ui_get(Autobuy.Enabled) then
	    return
	end

		-- Weapons & Armor
	for key, value in pairs(Autobuy) do
		-- Weapon & Armor
		if key == 'PrimaryWeapon' or key == 'SecondaryWeapon' or key == 'Armor' then
			if ui_get(value) ~= 'OFf' or not ui_get(value) then
				client_exec(BuyCommands[key][ui_get(value)])
			end
		end

		-- Grenades
		if key == 'Grenades' then
			local Grenades = ui_get(Autobuy.Grenades)
			for i=1, #Grenades do
				local Grenade = string.lower(tostring(tostring(Grenades[i]):gsub("%s+", "")))
				client_exec('buy ' .. Grenade .. ';')
			end
		end

		-- Utility
		if key == 'Utility' then
			local Utility = ui_get(Autobuy.Utility)
			for i=1, #Utility do
				client_exec('buy ' .. string.lower(Utility[i]) .. ';')
			end
		end
	end
end)