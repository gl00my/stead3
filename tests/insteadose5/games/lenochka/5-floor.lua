global {
    gift = 0;
};

obj{
    nam="Посылка";
    inv=[[Презент из будущего.]];
};

room {
    nam = "5-floor";
    disp = "Этаж Nr.5";

    decor=function(s)
        if have "Термос с кофе" and not have "Посылка" and gift<4 then
            p[[Не смотря в сторону вечно сломанного лифта, девушка направилась к лестнице.^
 Благо, идти ей было не далеко, а всего лишь на следующий этаж.^
 Коридор пятого этажа был почему-то {#пустота|пуст}.]];

        elseif have "Посылка" or ( have "Термос с кофе" and not have "Посылка" and gift>4 ) then
            p[[Оказавшись снова в коридоре она столкнулась лицом к лицу с {#PG|профессором}.]];

        elseif have "Термос с кофе" or ( have "Посылка" and not have "Термос с кофе" and gift>4 ) then
            p[[Оказавшись снова в коридоре она столкнулась лицом к лицу с {#PG|профессором}.]];

        elseif not have "Термос с кофе" and gift<4 then
            p[[У меня есть дела поважней, чем бродить без толку по зданию.]];
            walkin ("couloir1");

        else
            p[[Вложив коробку и термос в руки Петра Геннадиевича она поспешно {#the_end|удалилась}.]];

        end;
    end;

}:with
{
    obj{
        nam="#PG";
        used=function(s,w)
            if w^"Посылка" then
                p[["Вам посылка от Валерки.- произнесла побледнев Елена. И почти шепотом добавила,- Из будущего."]];
                remove(w);

            elseif w^"Термос с кофе" then
                p[["Свежий кофе, по просьбе генерала."- Почти машинально произнесла девушка.]];
                remove(w);

            else
                return false
            end;
        end;
    };

    obj{
        nam="#пустота";
        act=function(s,w)
            p[["Ребята наверное покурить отошли. Совсем их этот генерал замучил."- Промелькнула мысль о причине отсутствия охраны.]];
            walkin ("lab");
        end;
    };

    obj{
        nam="#the_end";
        act=function(w)
            if funny > 1 and not prefs.lena.funny1 then
                prefs.lena.points=prefs.lena.points+1;
                prefs.lena.funny1 = true;
            end;
            if bisquit > 1 and not prefs.lena.bisquit1 then
                prefs.lena.points=prefs.lena.points+1;
                prefs.lena.bisquit1 = true;
            end;
            if futurama >= 4  and not prefs.lena.futurama1 then
                prefs.lena.futurama1 = true
                prefs.lena.points = prefs.lena.points + 1;
            end;
            prefs:store()
            walkin ("ende");
        end;
    };
};

room {
    nam = "lab";
    disp = "Лаборатория П. Г.";
    dsc= function(s,w)
        if have "Термос с кофе" then
            p[["Вечно тут кто-то дежурит."- Бубнила Лена себе под нос открывая {#дверь|дверь лабораторий}, когда она услышала, как кто-то окликнул её, но уже было поздно.]];
        end;
    end;
}:with
{
    obj{
        nam="#дверь";
        act=function(s,w)
            walkin ("future");
        end;
    };
};

room {
    nam = "future";
    disp = "Лаборатория П. Г. - Будущее";
    dsc=function(s)
        if not have "Посылка" and gift<4 then
            p[[Портал, который открылся в дверном проёме лабораторий, затянул девушку внутрь.]];

        end;
    end;

    decor=function(s,w)
        if not have "Посылка" and gift<4 then
            p[[Помещение выглядело знакомо, но, всё же, совершенно не так, как она его помнила.
Странные {#прибор|приборы} стояли на {#стол|столах}, рядом со столами находились не менее странные {#стул|стулья}.
Леночка подняла голову, чтобы посмотреть на потолок, и увидела небо - {#небо|голубое чистое небо}.
Но за {#окно|окном} было видно, что солнце уже почти зашло и смеркалось.]];


        elseif have "Посылка" then
            p[["Леночка, вы как никогда вовремя! - произнёс мужчина,- Я вас ждал, чтобы передать профессору небольшую посылку в прошлое.^
Здесь несколько приборов, которые упростят исследования. Будьте добры, передайте это профессору. Никому кроме профессора не говорите что видели меня."^
Мужчина быстро развернул девушку лицом к порталу и осторожно выпроводил её {#прошлое|обратно в прошлое}.
]];
        end;
    end;

}:with
{
    obj{
        nam="#окно";
        act=function(s)
            p[[На фоне заходящего солнца виднелся силуэт зданий. Многие из них казались многоэтажными великанами.]];
            if s:actions() == 0 then
                futurama = futurama + 1;
            end
        end;
    };

    obj{
        nam="#небо";
        act=function(s)
            p[[Потолок - полностью состоит из ламп с иллюзией неба.^
Местами даже виднелись легкие, медленно парящие облака.]];
            if s:actions() == 0 then
                futurama=futurama + 1;
            end
        end;
    };

    obj{
        nam="#стул";
        act=function(s)
            p[[Стулья с кожаным покрытием, на ножках имеются колёсики.^
Высота стула и положение спинки каждого стула индивидуальны.]];
            if s:actions() == 0 then
                futurama=futurama + 1;
            end
        end;
    };

    obj{
        nam="#прибор";
        act=function(s)
            p[[Плоские "ракушки", стоявшие на каждом столе, походили на печатные машинки с подключенными к ним экранчиками.]];
            if s:actions() == 0 then
                futurama=futurama + 1;
            end
        end;
    };

    obj{
        nam="#стол";
        act=function(s,w)
            p[[Возле одного из столов, спиной к девушке, стоял мужчина и что-то поспешно собирал в коробку.]];
            walkin ("post");
        end;
    };

    obj{
        nam="#прошлое";
        act=function(s,w)
            walkin ("5-floor");
        end;
    };
};
room {
    nam = "post2";
    disp = "Лаборатория П. Г. - Посылка";
    decor=[[Пока девушка не успела опомниться, он сунул ей в руки только что запакованную {#короб|коробку}.]];
}:with
{
    obj{
        nam="#короб";
        act=function(s,w)
            take ("Посылка");
            walkin ("future");
        end;
    };

      };

room {
    nam = "post";
    disp = "Лаборатория П. Г. - Посылка";
    decor=[[На столе перед мужчиной находились разные предметы:
{#phone|два спутниковых телефона}; набор инструментов; {#fo|старый плёночный фотоаппарат};
{#заряд|универсальное зарядное устройство}; {#HC|коробочка с "вертолётиком" странной формы};
фляжка коньяка; {#mail|письмо в конверте} и {#box|пустая коробка}.]];

}:with
{
    obj{
        nam="#box";
        act=function(s,w)
            if gift<4 then
                p[["Так, чтобы отправить? Самое необходимое собрал... Теперь только сложить в неё всё надо."- Бубнил мужчина перебирая вещи на столе.]];
            else
                p[["Простите, Пётр Геннадиевич?!- Неуверенно произнесла она, сомневаясь в том что это именно он,- Генерал попросил занести вам кофе, куда поставить термос?"^
Мужчина быстро заклеил коробку и повернулся.^
"Валерка?!"- от удивления девушка чуть не выронила термос из рук.^
Перед ней стоял и улыбался, немного постаревший, бывший лаборант Валерка.]];
                    walkin ("post2");
            end;
        end;
    };

    obj{
        nam="#phone";
        act=function(s,w)
            if gift<4 then
                p[[Два идентичных предмета. Похожи на рации.]];
                if s:actions() == 0 then
                    gift=gift+1;
                end
            else
                p[[Вроде всё самое необходимое собрано.]];
            end;
        end;
    };

    obj{
        nam="#fo";
        act=function(s)
            if gift<4 then
                p[[Фотоаппарат лишним не бывает.]];
                if s:actions() == 0 then
                    gift=gift+1;
                end
            else
                p[[Вроде всё самое необходимое собрано.]];
            end;
        end;
    };

    obj{
        nam="#заряд";
        act=function(s)
            if gift<4 then
                p[[Зарядное устройство - подходит как для телефонов, так и для дрона. ]];
                if s:actions() == 0 then
                    gift=gift+1;
                end
            else
                p[[Вроде всё самое необходимое собрано.]];
            end;
        end;
    };

    obj{
        nam="#HC";
        act=function(s)
            if gift<4 then
                p[[Маленький дрон.]];
                if s:actions() == 0 then
                    gift=gift+1;
                end
            else
                p[[Вроде всё самое необходимое собрано.]];
            end;
        end;
    };

    obj{
        nam="#mail";
        act=function(s)
            if gift<4 then
                p[[Неприлично читать чужие письма. Конверт с пометкой - Лично Петру Геннадиевичу.]];
                if s:actions() then
                    gift=gift+1;
                end
            else
                p[[Вроде всё самое необходимое собрано.]];
            end;
        end;
    };
};
