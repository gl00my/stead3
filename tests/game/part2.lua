dlg {
	nam = 'main';
	title = '???';
	enter = [[Боль и темнота. Боль и темнота, а еще паника. Паника заполняла меня целиком,
волнами. По мере того как я приходил в себя, я все больше и больше желал снова впасть в забытье.
Но я приходил в себя... Нехотя я открыл глаза.]];
dsc = [[Передо мной сидела та тварь, и что-то говорила. Хрипловатым, угрюмым голосом.
Я попытался вникнуть в то, что она или оно говорит...]];
	phr = { only = true;
		'-- Вадим Владимирович, вы слышите меня?',
		{ 'Да', '-- Очень хорошо, тогда слушайте внимательно.', next = '#да',
		  { '#да', '-- Проводник неверно оценил вашу стоимость. Поэтому у меня есть для вас предложение',
		    onempty = function(s)
			    push '#desc'
		    end;
		    { 'Стоимость?', '-- Да, вашу оценочную стоимость следует поднять раз в 15. Конечно, проводнику будет сделан выговор... Хотя вы -- ценное приобретение.'},
		    { 'Проводник?', '-- Да, тот проводник, благодаря которому мы вас получили. Я не знаю точно, кто это был. Вероятно тот, кого вы встретили первым, когда началась череда передач от одних проводников к другим...'},
		    { 'Предложение?', '-- Да, это предложение очень важно для вас. Сделайте верный выбор...' },
		    { 'Где я?', '-- Вы на моем корабле. Это транспорт, мы только что вышли из туннеля, и скоро прибудем на рынок.',
		      {'Рынок?', '-- Да, рынок. Нелегальный рынок работорговцев.',
		       {'Рабы?', '-- Ха-ха-ха -- вы так ничего не поняли? Да -- вы все -- мои рабы. Вселенная огромна, а рабов всегда не хватает. Особенно сейчас, когда нас захлестнула новая волна колонизаций. Нам нужны рабы, и хотя власти делают вид, что борятся с работорговлей, это только видимость.'},
		      },
		      {'Корабль?', '-- Вам будет понятней, если я назову его зведолетом? Извольте, вы -- на моем звездолете.'},
		    }
		  }
		},
		{ 'Нет', '-- Вы шутите... Это хорошо.', next = '#да' },
		{ only = true, false, '#desc',
		  [[-- Ладно, я вижу у вас слишком много вопросов. Тогда послушайте меня.
Факты просты. Вы -- раб. Лучшее, что вас ждет -- работы на рудниках Ноутса-17. Но для меня вы представляете
некую ценность.. Вы сами -- можете стать проводником...^
Это не даст вам свободу, но спасет от мучительной жизни и, вероятно, скорой кончины.]],
		  {'Никогда', '-- Я бы на вашем месте не принимал бы таких важных решений так поспешно.', next = '#details' },
		  {'Нужны подробности.', '-- Мне это нравится! Слушайте!', next = '#details',
		   { '#details', onempty = function()
			     push '#desc2'
		   end,
		     [[Итак, проводники -- это бывшие особи вашей планеты...]],
		     {'Бывшие?', '-- Да. Прежде, чем стать проводником, вы подвергнетесь гм... процедуре.',
		      {'Процедуре?',
		       [[-- Процедура, которая проводится специальным образом, изменит ваше подсознание, или душу -- если угодно, таким образом, что вы потеряете некие особенности, присущие вашему роду...]],
		       {'Какие особенности?', [[-- Сущий пустяк, у вас не будет колебаний. В каком то смысле,
вы станете сильней. То, что ваш вид называет: совестью, долгом, любовью -- это умрет. Вообще, это давно уже атавизм,
только на недоразви... гм.. планетах, типа вашей Земли -- остались эти нелепости... У вас не будет колебаний... Вы сможете служить нам по совести... Вернее, гм, без колебаний. Не предадите нас. Но при этом, ваша жизнь будет комфортна! Ни это ли вы любите больше всего?]]
		       },
		       {'Зачем вы меня предупреждаете?', [[-- Я бы не предупредил, если бы процедура не требовала от вас
искреннего желания измениться, в противном случае -- вы потеряете рассудок, и мы потеряем деньги, простите за прямоту.]]
		       }
		      },
		     },
		   },
		  },
		  {'Да, легко!', '-- Ваше рвение мне нравится, но есть нюансы...', next = '#details'}
		},
		{
			false, '#desc2',
			onempty = function()
				print "all"
			end;
			[[С этими словами он внимательно посмотрел на меня своими маленькими глазками... Было что-то гипнотическое
в его словах. Они были такими... простыми... Никаких угрызений совести, никаких бытовых проблем... Но в этот момент я почему-то
вспомнил угрюмый взгляд сумасшедшего проводника, который провожал наш поезд... Потом я вспомнил жену, ссору и ту боль,
которую -- я знал! -- я причинил ей. Она думает, что я бросил ее, наверное... Я ушел из дому, сколько меня не было? День или два?]],
			{'Но тогда у меня не будет свободы воли?',
			 [[-- Если вы считаете эту шизофринию -- свободой воли, то ее у вас не будет.]]},
			{'И я не буду чувствовать угрызений совести?', [[-- Никаких!]]},
			{'Я буду счастлив?', [[-- Я не смогу ответить вам на этот вопрос. Это зависит от вас.]]},
			{'Сколько я буду жить?', [[Около 200 лет, так как вы сможете воспользоваться нашей омолаживающей медициной.]]},
			{'А если я откажусь?', [[-- Мне будет жаль, так как вы принесли бы гораздо больше прибыли.
Но тогда вас ждет настоящее рабство.]],
				 {'То-есть, я в любом случае, не увижу свою жену снова?',
				  [[-- Никогда, совершенно точно и абсолютно. Если вас это беспокоит, я бы рекомендовал вам избавиться от угрызений совести тем способом, о котором мы говорим.]]
				 }
			}
		}
	}
}

function start()
	print("START2")
end

function init()
	print("INIT2")
end