local memory = require 'memory'
local font = renderCreateFont('Calibri', 12) -- ñòàíäàðòíûé øðèôò è ñòàíäàðòíûé ðàçìåð

local notify_data = {}
local notify_x_size = 250
local notify_x_pos = 500
local notify_y_pos = 500

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	initializateNotfPos()
	while true do
		wait(0)
		for k, v in ipairs(notify_data) do
			if (v['timeclose'] + 1) < os.clock() then
				table.remove(notify_data, k)
			end
		end
	end
end

function onD3DPresent()
	if isSampAvailable() then
		DrawRender()
	end
end

function EXPORTS.addNotification(text --[[str]], time --[[int]], style --[[int]], curve --[[int]])
	if not time then
		time = 5
	end
	if not style then
		style = 127
	end
	if not curve then
		curve = 8
	end
	table.insert(notify_data,
		{ text = text, style = style, curve = curve, timeopen = os.clock(), timeclose = os.clock() + time })
end

function DrawRender()
	local y_pos = notify_y_pos -- íà÷àëüíàÿ âåðòèêàëüíàÿ êîîðäèíàòà.
	for key, val in ipairs(notify_data) do
		local show_notify = true -- íàäî ëè ðèñîâàòü óâåäîìëåíèå?
		local x_pos = notify_x_pos -- êîîðäèíàòà ïî ãîðèçîíàòàëè
		local str = 0        -- êîëè÷åñòâî ñòðîê â óâåäîìëåíèè
		local last_symb = 0
		local prelast_symb = 1
		local text_len = {}                                          -- ìàññèâ äëèíû òåêñòà â ïèêñåëÿõ
		for line in val['text']:gmatch("[^\r\n]+") do
			text_len[#text_len + 1] = renderGetFontDrawTextLength(font, line) -- ñ÷èòàåì äëèíó òåêñòà
			str = str + 1
		end
		local y_size = 20 + str * renderGetFontDrawHeight(font) +
			3 *
			(str - 1) -- 20 – âûñîòà "áîðòèêîâ" (äî òåêñòà + ïîñëå òåêñòà), 3 – äîï. âûñîòà (îòñòóï ìåæäó ñòðîêàìè)
		local big_len = 0
		for key2, val2 in ipairs(text_len) do
			if big_len < val2 then
				big_len = val2
			end
		end
		local notify_x_size = big_len + 20
		local timerdur = os.clock() - val['timeopen'] -- âðåìÿ ñ ìîìåíòà äîáàâëåíèÿ óâåäîìëåíèÿ
		if timerdur < 0.3 then                  -- 0.3 – âðåìÿ "ðàñêðûâàíèÿ" (àíèìàöèÿ äâèæåíèÿ âïðàâî)
			x_pos = timerdur / 0.3 * (notify_x_pos + notify_x_size) - notify_x_size
		else
			timerdur = val['timeclose'] - os.clock() -- âðåìÿ äî çàêðûâàíèÿ
			if timerdur > 0 and timerdur < 0.3 then -- 0.3 – âðåìÿ "ñêðûâàíèÿ" (àíèìàöèÿ âëåâî)
				x_pos = timerdur / 0.3 * (notify_x_pos + notify_x_size) - notify_x_size
			elseif timerdur > -0.2 and timerdur <= 0 then -- âåðõíèå óâåäîìëåíèÿ ñúåçæàþò âíèç. 0.2 – âðåìÿ ñúåçæàíèÿ
				local new_y_pos = y_pos - y_size - 20 -- 20 – ðàññòîÿíèå ìåæäó ñîñåäíèìè óâåäîìëåíèÿìè
				y_pos = new_y_pos - timerdur / 0.2 * (y_pos - new_y_pos)
				show_notify = false              -- ãîâîðèì, ÷òî óâåäîìëåíèå ïîêàçûâàòü óæå íå íàäî
			elseif timerdur <= -0.2 then         -- óâåäîìëåíèå îêîí÷åíî. óäàëÿåì. 0.2 – âðåìÿ ñúåçæàíèÿ
				show_notify = false              -- ãîâîðèì, ÷òî óâåäîìëåíèå ïîêàçûâàòü óæå íå íàäî
				--table.remove(notify_data, k)
			end
		end
		if show_notify then
			y_pos = y_pos - y_size -
				20                                                                    -- 20 – ðàññòîÿíèå ìåæäó ñîñåäíèìè óâåäîìëåíèÿìè
			if val.style == 0 then                                                    --êðàñíûé
				renderDrawCircleBox(notify_x_size, y_size, x_pos, y_pos, val.curve, 0xCDBD2F00)
			elseif val.style == 1 then                                                --îðàíæåâûé
				renderDrawCircleBox(notify_x_size, y_size, x_pos, y_pos, val.curve, 0xCDD66000)
			elseif val.style == 2 then                                                --æ¸ëòûé
				renderDrawCircleBox(notify_x_size, y_size, x_pos, y_pos, val.curve, 0xCDDBB002)
			elseif val.style == 3 then                                                --çåë¸íûé
				renderDrawCircleBox(notify_x_size, y_size, x_pos, y_pos, val.curve, 0xCD2B9900)
			elseif val.style == 4 then                                                --ãîëóáîé
				renderDrawCircleBox(notify_x_size, y_size, x_pos, y_pos, val.curve, 0xCD005699)
			else                                                                      --standart
				renderDrawCircleBox(notify_x_size, y_size, x_pos, y_pos, val.curve, 0xBD000000) -- 8 – ðàäèóñ çàêðóãëåíèÿ
			end
			local text_y = y_pos + 10                                                 -- 10 – âûñîòà "áîðòèêà" äî òåêñòà
			last_symb = 1
			local tcolor = 0xFFFFFF                                                   -- òåêóùèé öâåò
			local u = 1
			local text_x = x_pos + (notify_x_size - text_len[u]) / 2                  -- ïîçèöèÿ òåêñòà ïî X êîîðäèíàòå
			local current_str_st = 1                                                  -- íà÷àëî òåêóùåé ñòðîêè (äî ïåðåíîñà / äî ñëåäóþùåãî öâåòà)
			while last_symb <= val.text:len() do
				if last_symb == val.text:len() then                                   -- åñëè ïîñëåäíèé ñèìâîë
					local current_str = val.text:sub(current_str_st, last_symb)
					renderFontDrawText(font, current_str, text_x, text_y, 0xFF000000 + tcolor, true) -- ðèñóåì ñòðîêó òåêñòà óâåäîìëåíèÿ
				elseif val.text:sub(last_symb, last_symb) == '\n' then
					u = u + 1
					local current_str = val.text:sub(current_str_st, last_symb - 1)
					renderFontDrawText(font, current_str, text_x, text_y, 0xFF000000 + tcolor, true) -- ðèñóåì ñòðîêó òåêñòà óâåäîìëåíèÿ
					current_str_st = last_symb + 1
					text_x = x_pos + (notify_x_size - text_len[u]) / 2
					text_y = text_y +
						(renderGetFontDrawHeight(font) + 3)                                                                                      -- 3 – îòñòóï ìåæäó ñòðîêàìè
				else                                                                                                                             -- åñëè îáû÷íûé ñèìâîë (íå ïåðåíîñ è íå ïîñëåäíèé)
					local hex_color = true
					local hex_number = 0                                                                                                         -- ñàì íîâûé öâåò
					if last_symb <= val.text:len() - 7 and val.text:sub(last_symb, last_symb) == '{' and val.text:sub(last_symb + 7, last_symb + 7) == '}' then -- åñëè ôîðìàò: {......}
						local symbs = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' }
						local symbs2 = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }
						for k = last_symb + 1, last_symb + 6 do -- îáõîäèì âñå 6 âíóòðåííèõ (ìåæäó ñêîáî÷êàìè) ñèìâîëîâ
							local correct_symb = false
							for numb, hex_symb in pairs(symbs) do -- îáõîäèì âñå ÷èñëà HEX ñèñòåìû
								if val.text:sub(k, k) == hex_symb or val.text:sub(k, k) == symbs2[numb] then
									correct_symb = true
									hex_number = hex_number * 0x10 + (numb - 1)
									break
								end
							end
							if not correct_symb then -- åñëè íåêîððåòíûé ñèìâîë, òî âûêèäûâàåì èç öèêëà è íå îáðàùàåì âíèìàíèå
								hex_color = false
								break
							end
						end
					else
						hex_color = false -- ãîâîðèì, ÷òî íåòó èçìåíåíèÿ öâåòà
					end
					if hex_color then
						local current_str = val.text:sub(current_str_st, last_symb - 1) -- çàïèñûâàåì "òåêóùóþ" ñòðîêó
						renderFontDrawText(font, current_str, text_x, text_y, 0xFF000000 + tcolor, true) -- ðèñóåì ñòðîêó òåêñòà óâåäîìëåíèÿ
						text_x = text_x + renderGetFontDrawTextLength(font, current_str)
						last_symb = last_symb + 7                                      -- âñå ýëåìåíòè {......} ñêèïàåì
						current_str_st = last_symb + 1
						tcolor = hex_number
					end
				end
				last_symb = last_symb + 1
			end
		end
	end
end

function initializateNotfPos()
	local radar_x_left = memory.getfloat(memory.getuint32(0x58A79B, true), true)
	local radar_y = memory.getfloat(memory.getuint32(0x58A7C7, true), true)
	radar_x_left, radar_y = convertGameScreenCoordsToWindowScreenCoords(radar_x_left, radar_y)
	radar_y = select(2, getScreenResolution()) - radar_y
	local radar_x_right = memory.getfloat(memory.getuint32(0x58A79B, true), true) +
		memory.getfloat(memory.getuint32(0x5834C2, true), true)
	radar_x_right, _ = convertGameScreenCoordsToWindowScreenCoords(radar_x_right, radar_y)
	notify_x_size = radar_x_right - radar_x_left
	notify_x_pos = radar_x_left - 100
	notify_y_pos = radar_y + 20 -
		200 -- 20 – ðàññòîÿíèå ìåæäó ñîñåäíèìè óâåäîìëåíèÿìè; 30 – âûñîòà óâåäîìëåíèÿ íàä ðàäàðîì
end

function renderDrawCircleBox(sizex, sizey, posx, posy, radius, color)
	sizex = sizex - 2 * radius
	sizey = sizey - 2 * radius
	posx = posx + radius
	posy = posy + radius
	renderDrawBox(posx - radius, posy, radius, sizey, color)
	renderDrawBox(posx + sizex, posy, radius, sizey, color)
	renderDrawBox(posx, posy - radius, sizex, sizey + 2 * radius, color)
	for i = posx + sizex, posx + sizex + radius - 1 do
		local dist = math.sqrt(radius * radius - (i - (posx + sizex)) * (i - (posx + sizex)))
		renderDrawBox(i, posy - dist, 1, dist, color)
	end
	for i = posx - radius, posx - 1 do
		local dist = math.sqrt(radius * radius - (i - (posx - 1)) * (i - (posx - 1)))
		renderDrawBox(i, posy - dist, 1, dist, color)
	end
	for i = posx + sizex, posx + sizex + radius - 1 do
		local dist = math.sqrt(radius * radius - (i - (posx + sizex)) * (i - (posx + sizex)))
		renderDrawBox(i, posy + sizey, 1, dist, color)
	end
	for i = posx - radius, posx - 1 do
		local dist = math.sqrt(radius * radius - (i - (posx - 1)) * (i - (posx - 1)))
		renderDrawBox(i, posy + sizey, 1, dist, color)
	end
end
