require "mp-ru"

obj {
	life = 'яблоко лежит';
	-"яблоко,красное яблоко";
	nam = 'яблоко';
}: dict {
--	['яблоко/дт,мн'] = 'кустом слово для объекта';
}
-- lifeon 'яблоко'

game: dict {
--	['красное яблоко/дт,мн'] = 'кустом слово для игры';
}

Verb { "#take", "взять,забрать,схватить,забери,возьми,схвати,бери", "{noun}/вн : take %1" }

room {
	nam = 'main';
}: with { 'яблоко' }

function start()
	print(_'яблоко':noun('дт,мн')) -- даст яблокам
	for k, v in pairs(_'яблоко':gram()) do
		print(k, v)
	end
	print(mp:input("взять красное яблоко"))
end
