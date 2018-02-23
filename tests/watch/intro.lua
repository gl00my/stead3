function keys:filter(press, key)
	return press and (key == '0' or key == '1')
end

declare 'deco_cursor' (function(v)
	local w, h = 8, theme.get('win.fnt.size')
	local s = sprite.new(w * 2, h)
	s:fill(theme.get('win.col.bg'))
	s:fill(0, 0, w, h, 'gray')
	return s
end)
global 'inpnr' (0)
global 'randoms' ({})

local beep = snd.new 'snd/beep.ogg'
function decor.beep(v)
	beep:play(1);
end

local function inp(n)
	local d = D'input'
	table.insert(randoms, instead.ticks() % 2)
	d[3] = d[3] .. n
	d.w = nil
	d.h = nil
	D(d)
	d.x = (theme.scr.w() - d.w ) / 2
	local c = D'cursor'
	c.x = d.x + d.w - 4
	inpnr = inpnr + 1
	local t = D'intro'
	local len = 24
	local w = std.tostr(math.floor(inpnr * t.w / len))
	D { "line", "img", "box:"..w.."x4,red", x = t.x - t.xc, y = c.y + c.h + 8 }
	if inpnr == len then
		D'cursor'.hidden = true
		remove 'zero'
		remove 'one'
		local text = [[Анализирую последовательность... [pause] [pause] [pause]
[b]Плохое качество энтропии![/b] [pause]
В качестве данных беру нулевые биты
от времени нажатия клавиш... [pause] [pause]
]];
		for _, v in ipairs(randoms) do
			text = text .. std.tostr(v)
		end
		D { "analys", "txt", text, xc = true, x = theme.scr.w()/2, y = c.y + c.h + 16, align = 'center',
		typewriter = true, z = 1 }
	else
		beep:play();
	end
end

menu {
	nam = 'zero';
	disp = '0';
	act = function() inp '0' end;
}

menu {
	nam = 'one';
	disp = '1';
	act = function() inp '1' end;
}
local delay = 0
room {
	nam = 'intro';
	title = false;
	onkey = function(s, a, b)
		if have 'zero' then
			inp(b)
		end
	end;
	timer = function()
		if D'intro' and not D'intro'.finished or
			D'analys' and not D'analys'.finished then
		end
		if D'analys' and D'analys'.finished then
			delay = delay + 1
			if delay < 50 then
			    return false
			end
			fading.set { 'fadeblack', max = 300 }
			D{'analys'}
			D{'cursor'}
			D{'input'}
			D{'intro'}
			D{'line'}
			walk 'snow'
			return
		end
		if not D'intro'.started and not D 'cursor' then
			local d = D'intro'
			D {"cursor", "img", deco_cursor, xc = false, frames = 2, w = 8, delay = 300, x = d.x, y = d.y + d.h - d.yc + 1 }
			D {"input", "txt", "", align = 'left', xc = false, x = d.x, y = d.y + d.h - d.yc }
			take 'zero'
			take 'one'
			return
		end
		return false
	end;
	enter = function()
		local x, y, w, h = theme.get 'win.x', theme.get 'win.y', theme.get 'win.w', theme.get 'win.h'
		x, y, w, h = std.tonum(x),  std.tonum(y),  std.tonum(w),  std.tonum(h)
		local text = [[Представьте себе, что вы бросаете монетку. [pause] [pause] [pause]
Ноль - это орел. Один - решка.
Запишите последовательность из нулей и единиц...]]
		timer:set(20)
		D {"intro", "txt", text, xc = true, yc = true, x = theme.scr.w()/2, y = theme.scr.h()/3, align = 'center', typewriter = true, z = 1 }
	end
}

function snow_theme()
	theme.set('win.col.fg', 'black')
	theme.set('win.col.link','black')
	theme.set('win.col.alink', 'black')

	theme.set('inv.col.fg', 'black')
	theme.set('inv.col.link','black')
	theme.set('inv.col.alink', 'black')
end

function dark_theme()
	theme.reset('win.col.fg')
	theme.reset('win.col.link')
	theme.reset('win.col.alink')

	theme.reset('inv.col.fg')
	theme.reset('inv.col.link')
	theme.reset('inv.col.alink')
end
function theme_select()
	if D'snow' then
		snow_theme()
	else
		dark_theme()
	end
end
--dict.add("ребенок", "Мне пять лет. Это все, что я знаю о себе.")

function pp(str)
	p("{#recurse|"..str.."}")
end

declare 'flake' (function(v)
	local sp = v.speed + rnd(2)
	local sp2 = v.speed + rnd(4)
	v.x = v.x + sp;
	v.y = v.y + sp2 / 2;
	if v.x > theme.scr.w() then 
		v.x = 0 
		v.speed = rnd(5)
	end
	if v.y > theme.scr.h() then 
		v.y = 0 
		v.speed = rnd(5)
	end
end)
declare 'flake_spr' (function(v)
	local p = pixels.new(7, 7)
	local x, y = 3, 3
	p:val(x, y, 255,255,255,255)
	for i = 1, rnd(5) do
		local w = rnd(3)
		p:fill(x, y, w, w, 255, 255, 255, 255)
		x = x + rnd(2) - 1
		y = y + rnd(2) - 1
	end
	local w, h = 7, 7
	local cell = function(x, y)
		if x < 0 or x >= w or y < 0 or y >= h then
			return 0
		end
		local r, g, b, a = p:val(x, y)
		return a
	end
	for y = 0, h  do
		for x = 0, w do
			local c1, c2, c3, c4, c5, c6, c7, c8, c9 =
				cell(x - 1, y - 1),
				cell(x, y - 1),
				cell(x + 1, y - 1),
				cell(x - 1, y),
				cell(x, y),
				cell(x + 1, y),
				cell(x - 1, y + 1),
				cell(x, y + 1),
				cell(x + 1, y + 1)
			local c = (c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9) / 9
			p:val(x, y, 255, 255, 255, math.floor(c))
		end
	end
	return p:sprite()
end)
global 'snow_state' (0)
obj {
	nam = 'снежок';
	inv = [[Я покрепче слепил снежок.]];
	try = false;
	shoot = false;
	use = function(s, w)
		if w ^ '#отец' then
			p [[Я бросил снежок.]]
			remove(s)
			if not s.try then
				p [[Бросок был слабым, комок снега не долетел до цели.]]
				s.try = true
			else
				s.shoot = true
				p [[Попал! Я слышу смех отца. Он идет ко мне.]]
			end
		else
			p [[Я хочу бросить снежком в отца.]]
		end
	end
}
room {
	nam = 'snow';
	title = false;
--	fading = true;
	enter = function()
--		fading.change {'crossfade', max = 20 }
		timer:set(25)
		D {"snow", "img", background = true, "gfx/snow.jpg", z = 2 };
		for i = 1, 50 do
			D {"flake"..tostring(i), 'img', flake_spr, process = flake, x = rnd(theme.scr.w()), y = rnd(theme.scr.h()), speed = rnd(5), z = 1 }
		end
		snow_theme()
		lifeon '#голос'
	end;
	onexit = function()
		lifeoff '#голос'
--		D()
--		decor.bgcol = 'white'
		fading.set { 'fadeblack', max = 1 }
	end;
	decor = function()
		p [[{#снег|Снег. Кругом белый снег.} ]]
		if snow_state < 5 then
			p [[{#ребенок|Я стою}, {#сугроб|провалившись в сугроб}.]];
		else
			p [[{#ребенок|Я стою по колено} {#снег|в снегу.}]];
		end
	end;
	exit = function()
--		dark_theme()
	end;
}: with {
	obj {
		nam = '#снег';
		act = function()
			if snow_state == 5 and not have 'снежок' then
				p [[Я слепил из снега снежок.]]
				take 'снежок'
				return
			end
			p "Снег ослепительно белый. Снежинки роем кружатся у моего лица."
		end;
	};
	obj {
		nam = '#ребенок';
		act = "Мне пять лет. Это все, что я знаю о себе.";
	};
	obj {
		nam = '#сугроб';
		act = function(s)
			if seen '#отец' then
				if snow_state == 1 or snow_state == 2 then
					p [[Я изо всех сил пытаюсь пройти сквозь глубокий снег. Но мне не удается преодолеть его сопротивление.]];
					snow_state = 2
					return
				end
				if snow_state == 3 then
					snow_state = 4
					p [[Я пробиваюсь сквозь снег молотя руками и ногами. Снег вокруг меня.]];
					return
				end
				if snow_state == 4 then
					p [[Кажется, снег поддается! Он уже не сковывает моих движений. Я выбрался!]]
					snow_state = 5
					return
				end
				pn [[Я снова пытаюсь вылезти из сугроба. Но он глубокий. Мне становится страшно.]]
				p [[-- Папа! -- но отец только смеется и зовет меня к себе.]]
				if actions '#отец' > 0 then
					if snow_state == 0 then snow_state = 1 end
				end
				return
			end
			p [[Я пытаюсь вылезти из сугроба, но только глубже проваливаюсь в податливый снег.]]
		end;
	};
	obj {
		nam = '#голос';
		n = 1;
		act = function(s)
			p [[Это голос отца! За стеной снега я вижу его фигуру.]]
			enable '#отец';
		end;
		life = function(s)
			s.n = s.n + 1
			if s.n > 4 then
				if seen '#отец' then
					return
				else
					p [[{#голос|Я слышу как чей то голос зовет меня.}]]
				end
				return
			end
		end
	};
	obj {
		nam = '#отец';
		dsc = function(s)
			p [[{#ребенок|Я вижу} {#снег|за стеной снега} {#отец|фигуру отца}.]];
		end;
		act = function(s)
			if snow_state == 5 then
				if _'снежок'.shoot then
					walk 'комок'
					return
				end
				p [[Я злюсь на отца. Зачем он бросил меня в сугроб?]];
				return
			end
			if snow_state == 1 then
				p [[Он смеется и зовет меня к себе. Но я не могу выбраться!]];
			elseif snow_state > 1 then
				if snow_state < 3 then
					p [[За снежной пеленой мне кажется, что отец уходит... ^-- Папа! Помоги!]];
					snow_state = 3
				else
					p [[-- Папа, подожди!]]
				end
			else
				p [[Отец зовет меня к себе. Почему он не поможет мне?]];
			end
		end;
	}:disable();
}
room {
	nam = 'комок';
	title = false;
	time = 0;
	decor = fmt.y("50%")..fmt.c("СНЕЖОК ЛЕТИТ МНЕ ПРЯМО В ЛИЦО");
	timer = function(s)
		if instead.ticks() - s.time > 500 then
			fading.set {"fadeblack", max = 200 }
			walk 'main'
		end
	end;
	enter = function(s)
		snd.play 'snd/snowball.ogg'
		s.time = instead.ticks()
		quake.start()
	end;
	exit = function()
		D()
		dark_theme();
	end;
}
