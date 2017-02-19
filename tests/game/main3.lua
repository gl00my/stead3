require "format"
require "noinv"
format.para = true
std.debug_xref = false
--std.debug_output = true
--std.debug_input = true

game.inv = [[Зачем мне это?]];
-- nouse
game.use = function(s, w, ww)
	local r, v
	if w.nouse then
		r, v = std.call(w, 'nouse', ww)
	end
	if v == true then
		return r, v
	end
	if w.noused then
		r, v = std.call(ww, 'noused', w)
	end
	if v == true then
		return r, v
	end
	p [[Гм... Мне кажется, здесь это не поможет.]]
end

game.act = 'Ничего не произошло...'

local function exclusive(s)
	return function()
		return not closed(s)
	end
end

function human(v)
	v.human = true
	if not v.female then
		v.female = false
	end
	v.noused = function(s)
		if s.female then
			p [[Ей это не понравится.]]
		else
			p [[Ему это не понравится.]]
		end
	end
	return obj(v)
end

-- create own class container
cont = std.class({
	display = function(s)
		local d = std.obj.display(s)
		if s:closed() or #s.obj == 0 then
			return d
		end
		local c = s.cont or 'Здесь есть: '
		local empty = true
		for i = 1, #s.obj do
			local o = s.obj[i]
			if o:visible() then
				empty = false
				if c > 1 then c = c .. ', ' end
				c = c..std.dispof(o)
			end
		end
		if empty then
			return d
		end
		c = c .. '.'
		return std.par(std.space_delim, d, c)
	end
		 }, std.obj)
for_all(take,
	obj {
		nam = 'мобильник';
		use = function(s)
			p [[Это бесполезный прибор.]]
		end;
		inv = function()
			if here()/'main' then
				p [[Я хочу позвонить своей жене и попросить прощения, но почему-то не делаю этого...]]
			else
				if door_try then
					p [[Я попробовал сделать звонок. Нет сигнала.]]
				else
					p [[Меня мучает совесть перед женой, но звонить я не буду.]]
				end
			end
		end
	},
	obj {
		nam = 'таблетки';
		to = 0;
		inv = function(s)
			if live(s) then
				if have 'стакан' and _'стакан'.water then
					p [[Я выпил таблетки и запил их водой из стакана.]]
					_'стакан'.water = false
					remove(s)
					s.to = 5
					return
				else
					if here()/'гостиная' or here()/'За столом' then
						p [[Я не вижу тут воды, только спиртное. Нельзя смешивать таблетки с алкоголем.]]
					else
						p [[Мне нужна вода, чтобы запить таблетки.]]
					end
					return
				end
			end
			p [[Это мои таблетки от приступов мигрени. Их не так просто достать, так как
в них содержится кодеин, а врачи боятся выдавать рецепты на наркотики. Так что я их берегу, осталось две...]];
			if door_closed then
				p [[Между-прочим, я чувстсвую, как у меня начинается приступ мигрени.]]
			end
		end;
		life = function(s)
			if s.to > 0 then
				s.to = s.to - 1
				if s.to == 0 then
					if _'колбаса'.eaten then
						p [[Голова прошла!]]
						lifeoff(s)
						return
					end
					s.to = 5
				end
			end
			if visited 'myroom' then
				p [[Я чувствую как раскалывается моя голова. Приступ мигрени лишает меня сил и желания жить.]]
			else
				p [[Я чувствую, как у меня начинается приступ мигрени.]]
			end
		end;
		use = function(s, w)
			p [[Эти таблетки мне нужны.]]
		end;
	}
)

room {
	nam = 'main';
	title = 'Улица';
	disp = 'На улицу';
	enter = [[Была середина Февраля. Редкие, но колючие снежинки кружились в темноте улиц.
Тусклый свет фонарей разливался по асфальту причудливыми пятнами. Я шел быстрым шагом,
укутавшись в пальто и рассеяно рассматривая пустынные переулки. На душе было мерзко, свежие воспоминания о ссоре с женой
жгли мою совесть и погружали мое сознание в беспросветную темноту февральской ночи. В этот момент меня кто-то окликнул.^^
-- Дай на хлеб, дружок!]];
	decor = [[Я нахожусь на пустынной, слабо-освещенной {#улица|улице}. Справа от себя я вижу коричневую стену старого {#здание|здания}. На улице стоит {#бомж|нищий}, который довольно бесцеремонно меня разглядывает.]];
	obj = {
		obj {
			nam = '#улица';
			act = 'Улица тускло освещена бледным светом уличных фонарей.';
		};
		obj {
			nam = '#здание';
			act = [[Здание выглядит старым. Я хожу по этой улице почти каждый день, но совершенно
не знаю, что это за постройка. Здесь мог бы располагаться театр или банк.]];
		};
		obj {
			nam = '#бомж';
			act = function()
				if not visited 'dlg1' then walkin 'dlg1'; return; end;
				p [[Надо сходить в это здание... Странный тип.]]
			end;
		}
	};
	onexit = function(s, t)
		if t/'здание' then
			return
		end
		p [[Я хотел пройти мимо нищего, но тот нагло загородил мне путь.]];
		return false
	end;
	way = {
		room { disp = 'Уйти' };
		'здание';
	}
}

dlg {
	nam = 'dlg1';
	title = 'Разговор';
	enter = [[-- Дай на хлеб, родной! -- хриплый голос нищего вызывал раздражение.]];
	dsc = [[Одет он, вроде бы, тепло. Хотя пальто, конечно, драное. На лице -- щетина. Глаз не разглядеть в темноте.]];
}:with {
{
	{ 'У меня нет денег.', '-- Ха, ха, ха - тебе самому не смешно?' };
	{ 'На, держи немного...', '-- Ух ты! Хотя, знаешь, лучше не давай мне денег.',
		{ 'Почему?', '-- Потому что я их пропью, но у меня есть идея!', next = '#идея' };
		{ 'Ну я пошел...', '-- Подожди, у меня есть идея!', next = '#идея'; };
	};
	{ 'Ты же все пропьешь...',
	'-- Если честно, ты прав, прав, как же ты прав... Но знаешь, у меня есть идея!',
	next = '#идея';
	};
	{ 'Я не хочу с тобой разговаривать..',
	[[-- Откровенно говоря, я тоже не хочу с тобой разговаривать. Но мне нужны деньги!]]
	}
},
{ '#идея',
	{ 'Ну, и что за идея?', next = '#идея2' },
	{ 'Не хочу слушать никаких идей!', next = '#идея2' },
};
{ '#идея2', [[-- Вот, послушай! Сходи в магазин, и купи мне хлеба! Что тебе стоит? Мне так хочется есть...]],
	{ '#согласен',
	'Ну хорошо, я схожу.', [[-- Спасибо, брат! Ходить далеко не придется. Вот здесь есть магазин на первом этаже.]],
	next = '#идея3' };
	{ 'Да здесь магазина нет!', [[-- А вот и есть! Вот прямо здесь, видишь?]], next = '#идея3' };
	{ 'Слушай, возьми лучше денег!', [[-- Ты хочешь, что бы я умер от цирроза печени?]],
		{ 'Да', pop '-- Но я этого не хочу!' };
		{ 'Нет', pop '-- Вот видишь?'};
	};
};
{ '#идея3', [[С этими словами он показал своим скрюченным пальцем в сторону ближайшего массивного здания.]],
	{ cond = function()
		return not  closed '#согласен'
	end;
	'Ну хорошо, я схожу и куплю тебе еды.',
	function() p '-- Спасибо! Давай, скорее, он скоро закроется!';
		walkout(); enable 'здание' end
	};
	{ 'Что то я не вижу вывески.', '-- Но магазин то там есть! Я точно знаю, я часто клянчу там вып... гм.. еду.' };
	onempty = function()
		walkout(); enable 'здание'
		p [[Да, похоже придется сходить и купить ему еды.]]
	end;
};
};

floor = function()
	return cont {
		nam = '#пол';
	}
end

room {
	nam = 'здание';
	disp = 'В здание';
	title = 'Коридор';
	enter = function(s, f)
		if not visited() then
			p [[Я открыл массивную деревянную дверь и очутился в темном коридоре. Было
темно и тихо.]]
			lifeon 'зал'
		end
	end;
	decor = [[Я нахожусь в темном длинном коридоре.]];
	onexit = function(s, t)
		if t/'main' then
			if door_closed then
				p [[Я попробовал открыть дверь... Она не поддавалась!
Я налег на нее со всей силой, но ничего не добился! Что за чертовщина?]];
				door_try = true
				return false
			end
			p [[Я должен купить хлеба для нищего.]]
			return false
		end
	end;
	obj = { floor(),
		obj {
			nam = 'монета';
			name = false;
			readed = false;
			dsc = [[На полу я вижу что-то {блестящее}.]];
			tak = [[Я поднял с пола предмет. Гм, похоже это золотая монета! Или подделка?]];
			nouse = [[Деньги не всегда решают проблемы.]];
			inv = function(s)
				p [[Какая красивая вещица!]];
				if s.name then
					s.readed = true
					pn [[Я внимательно повертел ее перед глазами. О нет! На обратной стороне я прочитал:]]
					pn [["Вадим Владимирович, 1977 года рождения. UID: 510317. Оценочная стоимость: 230. Возмущение причинности: 0.00001%.]];
					p "Что за?..."
				end
			end;
			use = function(s, w)
				if w/'#люди' then
					p [[Я сунул монету какому-то толстому мужчине. -- У меня такая-же -- промычал он мне и отвернулся.]]
					return
				end
				if w.human then
					if w.female then
						p [[Я сунул ей монету.]]
					else
						p [[Я попытался сунуть ему монету.]]
					end
					p [[Никакой реакции.]]
					return
				end
				return false
			end;
		}
	};
	way = { 'main', path {'В конец коридора', 'зал' } }
}:disable()

room {
	nam = 'зал';
	title = 'Холл';
	enter = function(s, f)
		p [[Я очутился в довольно просторном холле.]];
		local t = lookup '#часы'
		if transport then
			t.time1 = 0
			t.time2 = 0;
			return
		end
		if t.time1 == 0 and t.time2 < 15 then
			return
		end
		t.time2 = t.time2 - 1
		if t.time2 == 0 then
			t.time1 = 0
			t.time2 = 59
		end
	end;
	life = function(s)
		if here()/'здание' then
			p [[Мне кажется, я слышу какой-то шум, который доносится с конца коридора.]]
		elseif here() == s then
			p [[Я слышу шум голосов и звон посуды справа.]]
		else

		end
		return
	end;
	decor = [[Неяркий свет освещает {#лестница|лестницу}. На стене возле лестницы я вижу электронное {#часы|табло}. Справа находится двустворчатая {#дверь|дверь}.]];
	obj = {
		obj {
			time1 = 1;
			time2 = 40;
			nam = '#часы';
			act = function(s)
				p [[На табло красным горят цифры: ]]
				p (s.time1, ":", s.time2)
			end;
		};
		obj {
			nam = '#лестница';
			act = function(s)
				p [[Лестница ведет на второй этаж.]];
				open '#наверх'
			end;
		};
		obj {
			nam = '#дверь';
			act = function(s)
				if s:closed() then
					s:open()
					p [[Я взялся за массивную ручку и потянул на себя.
Скрип открывающейся двери раздался в пустом холле.]];
					open '#двери'
				end
				p [[Двери открыты.]]
			end;
		}:close();
	};
	onexit = function(s, t)
		if t/'2-й этаж' then
			if not visited 'гостиная' then
				p [[Мне кажется, сначала нужно поискать магазин на 1-м этаже...]]
				return false
			end
			if not was('еда', 'take') then
				p [[Может, взять еду из гостиной?]]
				return false
			end
		end
	end;
	way = { path{'В коридор', 'здание'},
		path{'#двери', 'В дверь', after = 'В гостиную', 'гостиная'}:close(),
		path{'#наверх', 'Наверх', '2-й этаж'}:close(),
		path{'#подвал', 'Вниз', after = 'Подвал', 'Подвал'}:disable(),
	};
}

global 'transport' (false)

room {
	nam = '2-й этаж';
	enter = function(s, f)
		if f/'3-й этаж' then
			p [[Я спустился на второй этаж.]]
		elseif f/'зал' then
			p [[Я осторожно поднялся на второй этаж.]]
		end
	end;
	decor = [[Я вижу коридор, уходящий по обе стороны от лестницы. Вдоль коридора расположены {#двери|дверные проемы}. Странно, но в концах коридора я не вижу окон.]];
	obj = {
		obj {
			nam = '#двери';
			try = 0;
			used = function(s, w)
				if w/'монета' and w.readed and trap then
					p [[Я сверил номер на монете с номерами на дверях. Нет совпадений.]]
					return
				end
				return false
			end;
			act = function(s)
				if transport then
					p [[Я стучался в разные двери, но никто не открыл.]]
					return
				end
				s.try = s.try + 1
				if s.try ~= 5 then
					p [[Я выбрал одну из дверей и постучался.]]
				end
				if s.try == 1 then
					walkin 'разговор1';
				elseif s.try == 2 then
					walkin 'разговор2';
				elseif s.try == 3 then
					walkin 'разговор3';
				elseif s.try == 4 then
					p [[За дверью -- тишина.]]
				else
					p [[Гм, на каждой из дверей я вижу табличку с номером.]]
					trap = true
					s.try = 0
				end
			end;
		};
	};
	onexit = function(s, t)
	end;
	way = { path{'Вниз', 'зал'}, path{'Наверх', '3-й этаж'} };
}

global 'door_closed' (false)
global 'door_try' (false)

dlg {
	nam = 'разговор1';
	title = 'Разговор со стариком';
	enter = function(s)
		if not visited() then
			p [[Через некоторое время за дверью послышалось шевеление и я услышал, как кто-то тихо подошел с той стороны. Дверь приоткрылась, и за щелью я увидел сонное лицо старика.^-- Что вам нужно?]]
		else
			p [[Дверь открыл старик, с которым я уже разговаривал.^-- Снова вы? Не спится?]];
		end
	end;
}: with {{
		{"Здравствуйте, не подскажете, что это за место?",
		 "-- Гм, новенький? Никто не знает, кроме проводника. Мы просто ждем своей участи.",
		 {"Какой участи?", "-- Откуда я знаю, я жду ее так же как и все."},
		 {"А когда решится наша участь.", "-- Я не знаю, посмотри на часы в холле, они идут в обратную сторону. Многие считают, что это таймер отсчета."},
		 {"Что вы знаете о проводнике?", "-- Да, он утверждает, что он здесь очень давно и у него нет монеты.",
		  {"Монеты, что за монета?", "-- У вас должна быть монета, у каждого из нас она есть."},
		 };
		 {cond = function() return not door_try end; "Почему вы просто не уйдете отсюда?", function(s) door_closed = true; p "-- Хех. А ты попробуй!" end};
		 {cond = function() return door_try end; "Почему вы просто не выломаете дверь?", "-- Хех. А ты попробуй! И ты заметил? В здании нет окон."};
		},
		{"Вы не в курсе, здесь есть магазин?",
		 "-- Зачем вам магазин? Здесь есть пища и она бесплатна.",
		 { "Но где ее взять?", "-- Хватит шутить надо мной, молодой человек! Идите спать!" },
		 {  "А вы не могли бы мне дать немного еды?", "-- Ха ха ха ха! Лучше иди спать!" },
		},
		{"Что вы здесь делаете?", "-- С тобой разговариваю, кретин!"},
		{cond = function(s) return door_closed end, true, "Простите за беспокойство.", function() p [[Старик, ничего не сказав, захлопнул передо мной дверь.]]; walkout() end };
}}
dlg {
	nam = 'разговор2';
	title = 'Разговор с мальчиком';
	enter = function(s)
		if not visited() then
			p [[Дверь открыл худой мальчик, лет четырнадцати. Он выглядел довольно напуганным.]]
		else
			p [[Дверь снова открыл худой мальчик, лет четырнадцати. Он выглядел довольно напуганным.]]
		end
	end;
}:with {{
		{"Послушай, что здесь происходит?", "-- А что здесь происходит? Здесь ничего не происходит."},
		{"Это гостиница? Как она называется?", "Парень покачал головой. -- Я не знаю."},
		{"Как ты здесь оказался?", "-- Я просто зашел сюда, когда услышал крик о помощи...",
		 { "Крик?", "-- Да, крик о помощи. Но оказалось, что помогать не кому."},
		};
		{true, "Извини, я ошибся дверью.", function() p [[Парень пожал плечами и закрыл дверь.]]; walkout(); end };
       }}

dlg {
	nam = 'разговор3';
	title = "Разговор с мужчиной";
	onenter = function(s)
		if not visited(s) then
			p [[Дверь резко открылась едва я успел в нее поступать. -- Что нужно? Кто ты? -- здоровый детина смотрел на меня с неприязнью.]]
		else
			p [[-- Иди к черту! -- послышалось из за двери.]]
			return false
		end
	end;
}:with {{
		{'#1', "Я тут случайно.", "-- Ты в этом уверен?",
		 {"Да, я просто зашел купить хлеба...", "-- Хлеба, значит? А ты не думал, что это не случайность?",
		  {'#да', cond = function() return not closed '#нет' end; "Да", "-- Молодец, пятерка за наблюдательность. Знаешь, что я думаю?", next = '#что?' },
		  {'#нет', cond = function() return not closed '#да' end;"Нет", "-- Ну и дурак! Все это не случайно. Знаешь, что я думаю?", next = '#что?' },
		  {'#что?',
		   {'#что2', "Что ты думаешь?", "-- Я думаю, что мы -- избранные! И нас ждет что-то особенное! Мы все -- избранные! Ты со мной согласен?",
		    { "Да, я согласен с тобой.", pop "-- Да! По другому и быть не может! Мы все избранные, нас ждет что-то грандиозное!"};
		    { "Нет, я так не думаю.", pop "-- Ты просто глупец. Я сразу это понял, как увидел тебя."};
		   };
		   {cond = function() return not closed '#что2'; end; "Мне не интересно, что ты думаешь.", "-- Потому что ты, кретин!"},
		  }
		 },
		},
		{cond = function() return not closed '#1'; end;"А ты сам кто?", "-- Я первый спросил! -- рявкнул мужчина."},
		onempty = function() p [[С этими словами он закрыл дверь.]] walkout() end;
       }}

obj {
	nam = 'люди';
	dsc = [[В холле толпятся собирающиеся {люди}.]];
	act = function(s)
		p [[Я вижу, как они спускаются вниз, в какую-то дверь под лестницей.]]
		enable '#подвал';
	end;
}
:with
{
	obj {
		nam = 'проводник';
		dsc = [[В центре зала стоит уже знакомый мне {"проводник"} и усиленно размахивает руками.]];
		act = [[-- Проходите, проходите!!! Время настало! Не задерживайтесь!!!]];
	}
}
global 'trap' (false)
room {
	nam = '3-й этаж';
	enter = function(s, f)
		if f/'2-й этаж' then
			p [[Я поднялся на последний -- 3-й этаж.]]
			if have 'таблетки' then
				p [[С ужасом я чувствую, как у меня начинается приступ мигрени.]]
				lifeon 'таблетки'
			end
		end
	end;
	decor = [[Я вижу коридор, уходящий по обе стороны от лестницы. Вдоль коридора расположены {#двери|дверные проемы}. Здесь так же нет окон.]];
	obj = {
		obj {
			nam = '#двери';
			try = 0;
			used = function(s, w)
				if w/'монета' and w.readed and trap then
					p [[Я сверил номер на монете с номерами на дверях. Гм... 510317... Есть!]]
					enable '#510317'
					return
				end
				return false
			end;
			act = function(s)
				if transport then
					p [[Я стучался в разные двери, но никто не открыл.]]
					return
				end
				s.try = s.try + 1
				if s.try ~= 4 then
					p [[Я выбрал одну из дверей и постучался.]]
				end
				if s.try == 1 then
					walkin 'разговор4';
				elseif s.try == 2 then
					walkin 'разговор5';
				elseif s.try == 3 then
					p [[За дверью -- тишина.]]
				else
					p [[Гм, на каждой из дверей я вижу табличку с номером.]]
					s.try = 0
					trap = true
				end
			end;
		};
	};
	onexit = function(s, t)
		if t/'2-й этаж' and have 'шланг' and not transport and door_try then
			p [[Когда я спускался на второй этаж, по зданию раздался громкий сигнал и женский голос произнес:^]]
			p [[-- ВНИМАНИЕ! ГОТОВНОСТЬ К ТРАНСПОРТИРОВКЕ! ВСТРЕЧА В ХОЛЛЕ ПЕРВОГО ЭТАЖА!]];
			transport = true
			lifeoff 'зал'
			place ('люди', 'зал')
		end
	end;
	way = { path {'#510317', 'Дверь 510317', 'myroom'}:disable(), path{'Вниз', '2-й этаж'} };
}


dlg {
	nam = 'разговор4';
	title = 'Разговор с девушкой';
	enter = function(s)
		if not visited() then
			p [[Дверь открыла молодая девушка.]]
		else
			p [[Дверь снова открыла молодая девушка.]]
		end
	end;
}:with {{
		{cond = function(s) return _'монета'.readed end;
		 "Простите, а что написано на вашей монете?",
		 "-- Мое имя, как и у всех, странный вопрос..."},
		{"Впустите меня?", "-- С какой это стати?",
		 {"Поговорить.", pop "-- Если вы хотите что-то сказать, говорите здесь"};
		 {"Выпить чаю?", pop "-- Я не хочу пить с вами чай -- сказала девушка, бросив взгляд на мое обручальное кольцо."};
		};
		{"Как вы сюда попали?", "-- Я думала здесь находится косметический магазин."},
		{true, "Извините, я ухожу.", function() p [[-- Ничего страшного -- девушка закрыла дверь.]]; walkout(); end };
       }}

dlg {
	nam = 'разговор5';
	title = 'Разговор с мужчиной';
	enter = function(s)
		if not visited() then
			p [[Дверь открыл мужчина в смокинге. Он выглядел так, как будто собирался в дрогу. В его руке был чемодан.]]
		else
			p [[Это снова был мужчина в смокинге. Увидев меня, он, кажется, расстроился.]]
		end
		p [[^-- Началось?]];
	end;
}:with {{
		{cond = exclusive '#началось','#что',
		 "Что началось?", "-- Нулевое время. Часы показывали, что осталось совсем немного.",
		 {"Нулевое время?", "-- Да, часы на первом этаже!"},
		 {"А что будет в нулевое время?", "-- Я не знаю, но что-то произойдет!"},
		},
		{cond = exclusive '#что', '#началось', "Началось!", "-- Тогда не отвлекайте меня, я должен собраться!"},
		{true, "Извините, что побеспокоил.", function() p [[-- Время собираться в путь -- с этими словами он закрыл дверь.]]; walkout(); end };
       }}

obj {
	nam = 'колбаса';
	eaten = false;
	inv = function(s)
		if live 'таблетки' then
			remove(s)
			p [[Я подкрепился колбасой.]]
			s.eaten = true
			return
		end
		p [[Предательский запах!]];
	end;
}

room {
	nam = 'myroom';
	title = 'Комната';
	enter = function(s, f)
		if f/'3-й этаж' then
			p [[Я оказался в небольшой, но уютной комнате. Очень странно, но в комнате не оказалось окон!]];
		end
	end;
	onexit = function(s, t)
		if t/'3-й этаж' then
			if live 'таблетки' then
				p [[Я не могу ходить с приступом мигрени. Нужно что-то сделать.]]
				return false
			end
		end
	end;
	decor = [[Здесь есть {#кровать|кровать} и {#холодильник|холодильник}. А также {#стол|стол}. Приоткрытая дверь ведет в ванную комнату.]];
	way = {
		path {'В коридор', '3-й этаж'},
		room {
			nam = 'Ванная';
			dsc = [[Ванная комната совсем маленькая. Совмещенная с туалетом.]];
			decor = [[Здесь есть {#ванная|ванная} и {#унитаз|унитаз}. Небольшой {#шкафчик|шкафчик} с ванными принадлежностями
завершает картину.]];
			way = { path {'Выйти', 'myroom'} };
		}:with
		{
			obj {
				nam = 'шланг';
				dsc = [[Мое внимание привлекает блестящий {шланг}.]];
				tak = [[Я открутил шланг от смесителя и забрал его с собой.]];
				inv = [[Какая изящная и прочная штука.]];
			}:disable();
			obj {
				nam = '#ванная';
				act = function(s)
					if not have 'шланг' then
						enable 'шланг'
						p [[В ванной меня привлек внимание блестящий шланг от душа.]]
					else
						p [[Больше ничего интересного. Разве что пробочка от ванны? Нет. Не нужно.]]
					end
				end;
			};
			obj {
				nam = '#унитаз';
				act = function(s)
					if actions(s) > 0 then
						p [[Я не стал пользоваться унитазом.]]
					else
						p [[Я воспользовался унитазом.]]
					end
				end
			};
			obj {
				nam = '#шкафчик';
			}
		}
	}
}:with
{
	obj {
		nam = '#кровать';
		act = [[Я лег на кровать прямо в одежде и немного расслабился. Но напряжение не дало мне уснуть.]];
	};
	obj {
		nam = '#стол';
		act = function(s)
			p [[На столе ничего нет.]];
			if lookup('стакан', s) then
				p [[Кроме стакана.]]
				enable 'стакан'
			end
		end;
		obj = {
			obj {
				nam = 'стакан';
				water = false;
				dsc = [[На столе стоит {стакан}.]];
				tak = [[Я забрал стакан с собой.]];
				inv = function(s)
					p [[Стеклянный стакан.]]
					if s.water then
						p [[С водопроводной водой.]]
					end
				end;
				use = function(s, w)
					if w/'#стол' then
						place(s, w)
						p [[Я поставил стакан на стол.]]
						return
					end
					if w/'#ванная' then
						p [[Я набрал немного воды в стакан.]]
						s.water = true
						return
					end
					p [[Стаканом? Нет...]]
				end;
			}:disable()
		}
	};
	obj {
		nam = '#холодильник';
		act = function()
			p [[Холодильник ломится от еды. Правда, хлеба я не нашел.]]
			if not have 'колбаса' then
				take 'колбаса'
				p [[Я сунул в карман колбасу.]]
				if not door_closed then
					p [[Может, нищему подойдет вместо хлеба?]]
				end
				door_closed = true
			end
		end;
	};
}

room {
	nam = 'гостиная';
	title = 'Гостиная';
	enter = function(s, f)
		if transport then
			p [[Я зашел в гостиную, на этот раз она была пуста.]]
			return
		end
		if not visited() then
			p [[Не без трепета я вошел в залитую светом гостиную. Свет и шум застолья взбудоражил и застал меня врасплох.
Гостиная была великолепна! В ее центре был расположен стол, за которым сидели люди.]]
		end
	end;
	decor = function(s)
		p [[Я нахожусь в просторной, залитой светом гостиной. Посреди гостиной стоит {#стол|стол}, заправленный
красной скатертью, которую, впрочем, едва заметна за обилием {#еда|еды и выпивки}.]];
		if transport then
			for_all(disable, '#люди', '#стул')
		else
			p [[За столом сидят несколько {#люди|людей}. Слышен звон бокалов, голоса и женский смех. На меня, кажется, никто не обращает внимания.]];
		end
	end;
	way = { path {'В холл', 'зал' }};
}: with {
obj {
	nam = '#стол';
		act = [[Красная скатерть едва видна из-за обилия блюд.]];
};
obj {
	nam = '#еда';
	act = [[Я вижу как стол ломится от выпивки и закуски.]];
};
obj {
	nam = '#люди';
	act = function(s)
		if s:actions() == 0 then
			pn [[-- Извините, вы не знаете, здесь есть магазин? -- неуверенно спросил я у компании.]]
			pn [[Речь за столом стихла -- они смотрели на меня. -- Новенький -- послышался мне чей-то
шепот..]]
			pn [[Затем раздался громкий, неприятный смех. И гостиная снова наполнилась звуками.]]
		else
			pn [[Мне не нравятся эти люди. И, похоже, я им тоже не нравлюсь.]]
		end
		p [[Я вижу, что один из стульев пустует.]]
		enable '#стул'
	end;
};
obj {
	nam = '#стул';
	dsc = [[Рядом со столом есть один свободный {стул}.]];
	act = function(s)
		walkin "За столом"
	end
}:disable()}

obj {
	nam = 'еда';
	inv = [[Пара бутербродов с маслом и красной икрой.]];
	use = function(s, w)
		if w.human then
			p [[Покормить? Ну уж нет...]]
			return
		end
		p [[Бутерброды испачкаются.]]
	end;
}

room {
	nam = 'За столом';
	enter = [[Я подошел к столу и нагло сел на свободный стул. Кажется, никто не обратил на это ни малейшего внимания.]];
	decor = [[Напротив себя я вижу полного {#мужчина|мужчину}, который о чем-то разговаривает с {#женщина|женщиной},
которая сидит справа от него. Рядом со мной сидит {#парень|молодой парень}, лет 20 и что-то пишет на клочке бумаги. На другом
конце стола я вижу очень худого {#странный|человека} неопределенного возраста, который мрачно смотрит перед собой. На столе полно {#еда|еды}.]];
	way = { room {nam = "Встать из-за стола", onenter = function() walkout "гостиная" end} };
	onexit = function(s, t)
		if t/'гостиная' and have 'еда' then
			p [[Я уже собрался встать из-за стола, когда глухой, но властный голос окликнул меня.
-- Куда вы собрались, милейший? Это был худой, угрюмый человек, который находился на другом конце стола.]];
			walkin 'председатель'
		end
	end;
}:with {
	obj {
		nam = '#еда';
		act = function(s)
			p [[Может, вина? Гм.. Нет. Я вообще тут задержался.]]
			if not have 'еда'  then
				if visited 'председатель' then
					p [[Движимой непонятной силой я снова взял пару бутербродов.]]
					take 'еда'
					return
				else
					pn [[Интересно, а что если вместо хлеба взять пару бутербродов с икрой? Я думаю, нищему это понравится.]]
				end
				take 'еда'
				p [[Я взял немного еды со стола.]]
			end
		end;
	};
	human {
		nam = "#мужчина";
		act = function(s)
			if door_try then
				walkin 'диалог7'
			else
				p [[-- Простите, вы не подскажете, где тут магазин?^]]
				p [[-- Зачем тебе магазин? Пей и ешь, пока можешь! -- При этих словах дама рядом с ним
громко и неприятно засмеялась.]]
			end
		end;
	};
	human {
		nam = "#женщина";
		female = true;
		act = function(s)
			pn [[-- Простите, вы не подскажете...]]
			if door_try then
				p [[^-- Просто расслабься, это пойдет тебе на пользу. Как делаем это мы с Максиком.^]]
				p [[-- Милая! Скажи ему, что ты занята! -- отозвался толстяк рядом.]]
			else
				walkin 'диалог8'
			end
		end;
	};
	human {
		nam = "#парень";
		used = function(s, w)
			if w/'монета' then
				if w.readed then
					p [[Парень только отмахнулся от меня. -- Не мешай, у меня расчеты...]];
					return
				end
				w.name = true
				pn [[Я сунул монету парню под нос. Он рассеяно посмотрел на нее.]]
				pn [[-- Гм, Вадим Владимирович, не отвлекайте меня, мне нужно найти решение! Я раскодирую, я смогу!]]
				p [[Как он узнал мое имя?!!!]]
				return
			end
			return false
		end;
		act = function(s)
			pn [[-- Послушайте...]]
			p [[-- Ох, не мешайте мне! -- отмахнулся он от меня. Я заметил, что в левой руке блеснула золотая монета.]];
		end;
	};
	human {
		nam = "#странный";
		act = function(s)
			p [[-- Ммм.. Любезный ... -- я запнулся, когда мужчина окинул меня своим холодным взглядом.]]
		end;
		used = function(s, w)
			p [[Он слишком далеко от меня.]]
		end;
	};
}
dlg {
	title = 'Разговор с толстяком';
	nam = 'диалог7';
	enter = "Хотя мне он не нравится, я решил обратиться к толстяку с вопросом.";
}:with {{
		{"Как отсюда выбраться?", "-- А что тебя не устраивает?"},
		{"Дверь закрыта! Мы в плену!", "-- А не все ли равно? Там -- толстяк кивнул головой -- разве там ты не был в плену?",
		 {"Что вы имеете в виду?", "-- То, что здесь у нас есть все, что нужно. И даже больше."},
		 {"Гм, действительно...", "-- Так что расслабься, пей и ешь!"},
		 onempty = function(s)
			 walkout()
		 end;
		},
       }}

dlg {
	nam = 'диалог8';
	enter = [[Женщина не была склонна к разговорам со мной, но я все-таки решил обратиться к ней.]];
}:with {{
		{"Вы не в курсе, здесь есть магазин?", "-- Магазин? Ха-ха-ха, никогда не слышала. -- Максик, ты слышал? -- с этими словами она толкнула толстяка в бок."};
		{"А что это за здание?", "-- Это замечательное место! Оставайся, и не задавай лишних вопросов."};
       }}

dlg {
	nam = 'председатель';
	title = [[Разговор с угрюмым человеком]];
	enter = function(s)
		if visited() then
			s:push '#снова'
			disable '#омонете'
			p [[-- Как я погляжу, наш воришка снова украл!^]]
			p [[-- Вы, умалишенный, отстаньте от меня!^]]
			p [[-- Я проводник!]]
		else
			p [[-- Как я заметил, вы что-то украли? -- в его голосе слышалась угроза.]];
		end
	end;
}: with {{
		{"Да я просто взял пару бутербродов!", "-- Вот именно! Извольте объясниться!", next = '#кража',
		 cond = function(s) return not closed '#кража' end };
		{'#кража', "Украл? Я ничего не крал!", "-- А бутерброды, которые вы бережно держите в руке?",
		 {"Разве это кража?", "-- А что по вашему тогда называется кражей? Молчите, это риторический вопрос!"},
		 {"Хорошо, я положу их назад.", "-- Вам придется их съесть!",
		  {'#бред', "Что? Что за бред! Я могу их съесть?", [[-- Вам придется их съесть! Так как за этим столом едят.]]},
		  {"А можно их съесть потом?", function() close '#бред'; p [[-- Вы можете их съесть потом, но только за этим столом!.]] end},
		  {"Что за бредовые правила?", [[-- Это не вашего ума дела! Я здесь проводник и слежу за порядком!]],
		   { '#снова', "Проводник?", [[-- Да, я проводник!]],
		     { '#a', "Проводник чего?", [[-- Общества, в котором вы находитесь!]],
		       {"Я не состою в вашем обществе!", function()
				if have 'монета' then push '#омонете'; return "-- Вас обличает золотая монета!" end
				p [[-- Вы сидите за нашим столом!]];
		       end }
		     },
		     { false, '#омонете',
		       { "Что вы знаете о монете?", "-- У каждого пассажира своя монета. Свой долг.",
			 { "И у вас есть монета?", "-- НЕ ЛЕЗЬТЕ НЕ В СВОЕ ДЕЛО! Моя монета не нужна! Я проводник! Кто-то должен за всеми следить! И это я! Я! Я взял на себя эту обязанность! Какое дело вам, вору, до моей монеты?"}
		       },
		       { "Я не крал монету!", "Умалишенный громко засмеялся. -- Конечно, вы не крали ее." },
		       onempty = function() p "-- Ладно, вернемся к вашей краже!"; pop() end;
		     };
		     { '#b', "Да вы сумасшедший!",
		       [[Это не относится к делу. Может быть и вы сумасшедший, но важно не это, важно -- что вы вор!]],
		     };
		     { cond = function() return closed '#a' and closed '#b' end;
		       [[Ладно, я сдаюсь.]], function(s) remove 'еда'; p [[С этими словами я затолкал бутерброды в рот и съел их. -- Так то лучше! -- одобрил мой поступок проводник. И больше никаких нарушений!]]; walkout() end;
		     }
		   },
		  },
		 },
		 {"Мне они нужны, чтобы покормить нищего.", "-- Это не относится к делу."},
		}
	}}
room {
	nam = 'Подвал';
	enter = [[Вместе с людьми я спустился вниз.]];
	decor = [[Подвал был огромен. С удивлением, я увидел что-то вроде {#платформа|платформы} метро!
На платформе стоял небольшой, причудливо выглядящий {#состав|состав}. {#люди|Люди} вереницей скрывались за дверьми вагонов, предварительно
пройдя через сооружение, напоминающее {#ворота|ворота}.]];
	onexit = function(s, t)
		if t/'Вагон' then
			if not _'#ворота'.opened then
				p [[Я попробовал пройти к вагону, но когда я подошел к воротам, они, издав неприятный звук,
выбросили из своих торцов металлические поручни, которые загородили мне проход.^
-- Пожалуйста, опустите монету в прорезь! -- услышал я вежливо-безжизненный женский голос.]]
				enable '#прорезь'
				return false
			else
				p [[Я прошел через ворота и направился к вагону...]]
			end
		end
	end;
	way = { path {'Наверх', 'зал'}, path {'В вагон', 'Вагон'}};
}:with
{
	obj {
		nam = '#состав';
		act = [[Я таких вагонов никогда не видел.]];
	};
	obj {
		nam = '#платформа';
		act = [[Неожиданная архитектура для старого здания!]];
	};
	obj {
		nam = '#ворота';
		opened = false;
		act = function(s)
			p [[Люди проходят через ворота по одному. И каждый раз ворота мерцают сине-зеленым цветом.]]
		end;
		obj = {
			obj {
				nam = '#прорезь';
				dsc = [[В воротах на правой стороне я вижу {прорезь}.]];
				act = [[Это какой-то феерический бред!]];
				used = function(s, w)
					if w/'монета' then
						where(s).opened = true
						remove(w)
						p [[С лязгом монета исчезла в недрах ворот.^
-- Вы распознаны! Прошу на поезд! -- сказал женский голос-автомат.]]
						return
					end
					if w/'колбаса' then
						p [[Колбаса не пролезла.]]
						return
					end
					return false
				end;
			}:disable()
		}
	};
	obj {
		nam = '#люди';
		act = [[Кто они? И кто я среди них? Что нас ждет? И что делать мне?]];
	};
}

xact.walk = walk

room {
	nam = 'Вагон';
	decor = [[Я оказался в вагоне. От непривычно яркого света слепило глаза.
Все места были заняты, и все, что мне оставалось делать -- {@ walk ship1|ждать}...]];
}

room {
	nam = 'ship1';
	title = false;
	noinv = true;
	dsc = [[Я не говорил с людьми вокруг. По их взгляду я понял, что никто не знает, что с
ними будет. Здесь были совсем разные лица: совсем молодые и пожилые, суровые и мягкие, умные и глупые...^
И все эти люди так или иначе -- со страхом или надеждой, с тоской или жаждой перемен, ждали грядущего...^
Вот, двери вагона закрылись и поезд тронулся... Я провожал глазами станцию, когда увидел, как на платформу
выбежал человек.^
Это был "проводник". Он провожал нас взглядом и в этот раз, при ярком свете платформы, мне показалось, что я разглядел их.
Они были полны угрюмой тоски.^
Я подошел к задней стороне вагона и долго еще смотрел на исчезающий огонек станции.^
Что ждало нас? Я не знал, но не это беспокоило сейчас меня больше всего. Меня заполнял жгучий стыд за произошедшую ссору с женой. И я
не знал, увижу ли я ее когда-нибудь снова или эта рана, которую я ей нанес, останется в ее душе навсегда?^^
{@ walk ship2|Дальше}]];
}

room {
	nam = 'ship2';
	title = false;
	noinv = true;
	dsc = [[ Прошло около часа, и поезд начал останавливаться. Здесь была платформа, вроде той, что мы покинули.
И на этой платформе нас уже ждали.^
Это были люди в синей униформе, вооруженные и не сильно разговорчивые.^
Они дождались, когда все выйдут из вагонов, а затем привели нас в нечто, напоминающее зал ожидания.^
-- ПРОСИМ ВАС ЗАНЯТЬ СВОИ МЕСТА! НА ВСЕ ВОПРОСЫ БУДУТ ДАНЫ ОТВЕТЫ! САДИТЕСЬ ВСЕ НА СВОИ МЕСТА!^
Зал был заполнен этими непрекращающимися уговорами, и они подействовали.^
Люди, неуверенно переговариваясь, занимали места. Я тоже сел и стали ждать. Кресло было удобным и мягким.
Прошло несколько минут, когда я едва успел понять, что теряю сознание...
]];
}


function start()
end
