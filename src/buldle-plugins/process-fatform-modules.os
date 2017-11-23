
#Использовать logos
#Использовать gitrunner

Перем ВерсияПлагина;
Перем Лог;
Перем КомандыПлагина;

Перем Обработчик;

Перем КорневойКаталог;
Перем ДополнительнаяТаблицаПереименования;

Функция Информация() Экспорт

	Возврат Новый Структура("Версия, Лог", ВерсияПлагина, Лог)

КонецФункции // Информация() Экспорт

Процедура ПриАктивизацииПлагина(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;

	ДополнительнаяТаблицаПереименования.Очистить();

КонецПроцедуры

Процедура ПриПеремещенииВКаталогРабочейКопии(КаталогРабочейКопии, КаталогВыгрузки, ТаблицаПереименования, ПутьКФайлуПереименования, СтандартнаяОбработка) Экспорт

	КорневойКаталог = КаталогВыгрузки + ПолучитьРазделительПути();

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации, Парсер) Экспорт

	Лог.Отладка("Ищю команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

	//ОписаниеКоманды = Парсер.ПолучитьКоманду(ИмяКоманды);
	//Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-push-every-n-commits", "[PLUGIN] [push] <число> количество коммитов до промежуточной отправки на удаленный сервер");
	//Парсер.ДобавитьПараметрФлагКоманды		 (ОписаниеКоманды, "-push-tags", "[PLUGIN] [push] Флаг отправки установленных меток");

	//арсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры


Процедура ПослеРаспаковкиКонтейнераМетаданных(ФайлРаспаковки, КаталогРаспаковки) Экспорт

	Для Каждого ФайлМодуля Из НайтиФайлы(КаталогРаспаковки, "module", Истина) Цикл

		СтароеИмяФайла = ФайлМодуля.ПолноеИмя;
		НовоеИмяФайла = ОбъединитьПути(ФайлМодуля.Путь, "Module.bsl");
		
		Лог.Отладка("Конвертирую наименование файла <%1> --> <%2>", СтароеИмяФайла, НовоеИмяФайла);
		ПереместитьФайл(СтароеИмяФайла, НовоеИмяФайла);

		ДобавитьПереименование(
			СтрЗаменить(СтароеИмяФайла, КорневойКаталог, ""),
			СтрЗаменить(НовоеИмяФайла, КорневойКаталог, ""));

	КонецЦикла;

КонецПроцедуры

Процедура ПослеПеремещенияВКаталогРабочейКопии(КаталогРабочейКопии, КаталогВыгрузки, ТаблицаПереименования, ПутьКФайлуПереименования) Экспорт

	ТекстовыйДокумент = Новый ЗаписьТекста(ПутьКФайлуПереименования,,,Истина);

	Для Каждого ЭлементСтроки Из ДополнительнаяТаблицаПереименования Цикл
		ТекстовыйДокумент.ЗаписатьСтроку(СтрШаблон("%1-->%2", ЭлементСтроки.Источник, ЭлементСтроки.Приемник));
	КонецЦикла;
	ТекстовыйДокумент.Закрыть();


КонецПроцедуры

Процедура ДобавитьПереименование(Знач Источник, Знач Приемник)

	Приемник = СтрЗаменить(Приемник, "/", "\");
	Источник = СтрЗаменить(Источник, "/", "\");

	Если Не Источник = Приемник Тогда

		СтрокаПереименования = ДополнительнаяТаблицаПереименования.Добавить();
		СтрокаПереименования.Источник = Источник;
		СтрокаПереименования.Приемник = Приемник;
	
	КонецЕсли;

КонецПроцедуры


Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("[PLUGIN] %1: %2 - %3", ИмяПлагина(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

Функция ИмяПлагина()
	возврат "process-fatform-modules";
КонецФункции // ИмяПлагина()

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync.plugins."+ ИмяПлагина());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	КомандыПлагина.Добавить("export");

	КорневойКаталог = Неопределено;
	ДополнительнаяТаблицаПереименования = Новый ТаблицаЗначений;
	ДополнительнаяТаблицаПереименования.Колонки.Добавить("Источник");
	ДополнительнаяТаблицаПереименования.Колонки.Добавить("Приемник");


	Лог.УстановитьРаскладку(ЭтотОбъект);

КонецПроцедуры

Инициализация();
