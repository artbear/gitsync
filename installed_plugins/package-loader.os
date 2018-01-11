﻿#Использовать "../src/plugins_loader"
// Пояснения по переменным даны в конце модуля

Перем ПоказатьСообщенияЗагрузки;
Перем ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей;

Процедура ПриЗагрузкеБиблиотеки(Путь, СтандартнаяОбработка, Отказ)
	

	КаталогиПлагинов = НайтиФайлы(Путь, ПолучитьМаскуВсеФайлы(), Ложь); 

	Для каждого Каталоги Из КаталогиПлагинов Цикл
		
		Если Не Каталоги.ЭтоКаталог() Тогда
			Продолжить
		КонецЕсли;
		
		ЗагрузитьПлагин(Каталоги.ПолноеИмя, СтандартнаяОбработка, Отказ);

	КонецЦикла;

	
КонецПроцедуры

Процедура ЗагрузитьПлагин(Путь, СтандартнаяОбработка, Отказ)

	//Сообщить("Загружаю плагин");
	Вывести("
	|Загружаю плагин " + Путь);	

	ФайлМанифеста = Новый Файл(ОбъединитьПути(Путь, "lib.config"));
	
	Если ФайлМанифеста.Существует() Тогда
		Вывести("Обрабатываем по манифесту");

		СтандартнаяОбработка = Ложь;
		ОбработатьМанифест(ФайлМанифеста.ПолноеИмя, Путь, Отказ);
	Иначе
		Вывести("Обрабатываем структуру каталогов по соглашению");
		ОбработатьСтруктуруКаталоговПоСоглашению(Путь, СтандартнаяОбработка, Отказ);
	КонецЕсли;

КонецПроцедуры


Процедура ОбработатьМанифест(Знач Файл, Знач Путь, Отказ)
	
	Чтение = Новый ЧтениеXML;
	Чтение.ОткрытьФайл(Файл);
	Чтение.ПерейтиКСодержимому();
	
	Если Чтение.ЛокальноеИмя <> "package-def" Тогда
		Отказ = Истина;
		Чтение.Закрыть();
		Возврат;
	КонецЕсли;
	
	Пока Чтение.Прочитать() Цикл
		
		Если Чтение.ТипУзла = ТипУзлаXML.Комментарий Тогда

			Продолжить;

		КонецЕсли;

		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		
			Если Чтение.ЛокальноеИмя = "class" Тогда
				ФайлКласса = Новый Файл(Путь + "/" + Чтение.ЗначениеАтрибута("file"));
				Если ФайлКласса.Существует() и ФайлКласса.ЭтоФайл() Тогда
					Идентификатор = Чтение.ЗначениеАтрибута("name");
					Если Не ПустаяСтрока(Идентификатор) Тогда
						Вывести(СтрШаблон("	класс %1, файл %2", Идентификатор, ФайлКласса.ПолноеИмя));

						// ДобавитьКласс(ФайлКласса.ПолноеИмя, Идентификатор);
						ДобавитьКлассЕслиРанееНеДобавляли(ФайлКласса.ПолноеИмя, Идентификатор);
					КонецЕсли;
				Иначе
					ВызватьИсключение "Не найден файл " + ФайлКласса.ПолноеИмя + ", указанный в манифесте";
				КонецЕсли;
				
				Чтение.Прочитать(); // в конец элемента
			КонецЕсли;

			Если Чтение.ЛокальноеИмя = "module" Тогда
				ФайлКласса = Новый Файл(Путь + "/" + Чтение.ЗначениеАтрибута("file"));
				Если ФайлКласса.Существует() и ФайлКласса.ЭтоФайл() Тогда
					Идентификатор = Чтение.ЗначениеАтрибута("name");
					Если Не ПустаяСтрока(Идентификатор) Тогда
						Вывести(СтрШаблон("	модуль %1, файл %2", Идентификатор, ФайлКласса.ПолноеИмя));
						Попытка
							ДобавитьМодуль(ФайлКласса.ПолноеИмя, Идентификатор);
						Исключение
							Если ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей Тогда
								ВызватьИсключение;
							КонецЕсли;
							Вывести("Предупреждение:
							|	" + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
						КонецПопытки;
					КонецЕсли;
				Иначе
					ВызватьИсключение "Не найден файл " + ФайлКласса.ПолноеИмя + ", указанный в манифесте";
				КонецЕсли;
				
				Чтение.Прочитать(); // в конец элемента
			КонецЕсли;
		
		КонецЕсли;
		
	КонецЦикла;
	
	Чтение.Закрыть();
	
КонецПроцедуры

Процедура ОбработатьСтруктуруКаталоговПоСоглашению(Путь, СтандартнаяОбработка, Отказ)
	
	КаталогиКлассов = Новый Массив;
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "Классы"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "Classes"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "src", "Классы"));
	КаталогиКлассов.Добавить(ОбъединитьПути(Путь, "src", "Classes"));

	КаталогиМодулей = Новый Массив;
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "Модули"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "Modules"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "src", "Модули"));
	КаталогиМодулей.Добавить(ОбъединитьПути(Путь, "src", "Modules"));


	Для Каждого мКаталог Из КаталогиКлассов Цикл

		ОбработатьКаталогКлассов(мКаталог, СтандартнаяОбработка, Отказ);

	КонецЦикла;

	Для Каждого мКаталог Из КаталогиМодулей Цикл

		ОбработатьКаталогМодулей(мКаталог, СтандартнаяОбработка, Отказ);

	КонецЦикла;

КонецПроцедуры

Процедура ОбработатьКаталогКлассов(Знач Путь, СтандартнаяОбработка, Отказ)

	КаталогКлассов = Новый Файл(Путь);
	
	Если КаталогКлассов.Существует() Тогда
		Файлы = НайтиФайлы(КаталогКлассов.ПолноеИмя, "*.os");
		Для Каждого Файл Из Файлы Цикл
			Вывести(СтрШаблон("	класс (по соглашению) %1, файл %2", Файл.ИмяБезРасширения, Файл.ПолноеИмя));
			СтандартнаяОбработка = Ложь;
			// ДобавитьКласс(Файл.ПолноеИмя, Файл.ИмяБезРасширения);
			ДобавитьКлассЕслиРанееНеДобавляли(Файл.ПолноеИмя, Файл.ИмяБезРасширения);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработатьКаталогМодулей(Знач Путь, СтандартнаяОбработка, Отказ)

	КаталогМодулей = Новый Файл(Путь);

	Если КаталогМодулей.Существует() Тогда
		Файлы = НайтиФайлы(КаталогМодулей.ПолноеИмя, "*.os");
		Для Каждого Файл Из Файлы Цикл
			Вывести(СтрШаблон("	модуль (по соглашению) %1, файл %2", Файл.ИмяБезРасширения, Файл.ПолноеИмя));
			СтандартнаяОбработка = Ложь;
			Попытка
				ДобавитьМодуль(Файл.ПолноеИмя, Файл.ИмяБезРасширения);				
			Исключение
				Если ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей Тогда
					ВызватьИсключение;
				КонецЕсли;
				СтандартнаяОбработка = Истина;
				Вывести("Предупреждение:
				|" + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			КонецПопытки;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКлассЕслиРанееНеДобавляли(ПутьФайла, ИмяКласса)
	Вывести("Добавляю класс, если ранее не добавляли " + ИмяКласса);
	Если ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей Тогда
		Вывести("Добавляю класс " + ИмяКласса);
		ДобавитьКласс(ПутьФайла, ИмяКласса);
		ЗагруженныеПлагины.ДобавитьПлагин(ИмяКласса);
		Возврат;
	КонецЕсли;
	
	КлассУжеЕсть = Ложь;
	Попытка
		Объект = Новый(ИмяКласса);
		КлассУжеЕсть = Истина;
	Исключение
		СообщениеОшибки = ОписаниеОшибки();
		ИскомаяОшибка = СтрШаблон("Конструктор не найден (%1)", ИмяКласса);
		КлассУжеЕсть = СтрНайти(СообщениеОшибки, ИскомаяОшибка) = 0;
	КонецПопытки;
	Если Не КлассУжеЕсть Тогда
		
		Вывести("Добавляю класс, т.к. он не найден - " + ИмяКласса);
		ДобавитьКласс(ПутьФайла, ИмяКласса);
	
	Иначе
		Вывести("Пропускаю загрузку класса " + ИмяКласса);

	КонецЕсли;

	ЗагруженныеПлагины.ДобавитьПлагин(ИмяКласса);

КонецПроцедуры

Процедура Вывести(Знач Сообщение)
	Если ПоказатьСообщенияЗагрузки Тогда
		Сообщить(Сообщение);
	КонецЕсли;
КонецПроцедуры

Функция ПолучитьБулевоИзПеременнойСреды(Знач ИмяПеременнойСреды, Знач ЗначениеПоУмолчанию)
	Рез = ЗначениеПоУмолчанию;
	РезИзСреды = ПолучитьПеременнуюСреды(ИмяПеременнойСреды);
	Если ЗначениеЗаполнено(РезИзСреды) Тогда
		РезИзСреды = СокрЛП(РезИзСреды);
		Попытка
			Рез = Число(РезИзСреды) <> 0 ;
		Исключение
			Рез = ЗначениеПоУмолчанию;
			Сообщить(СтрШаблон("Неверный формат переменной среды %1. Ожидали 1 или 0, а получили %2", ИмяПеременнойСреды, РезИзСреды));
		КонецПопытки;
	КонецЕсли;

	Возврат Рез;
КонецФункции

// Если Истина, то выдаются подробные сообщения о порядке загрузке пакетов, классов, модулей, что помогает при анализе проблем
// очень полезно при анализе ошибок загрузки
// Переменная среды может принимать значение 0 (выключено) или 1 (включено)
// Значение флага по умолчанию - Ложь
ПоказатьСообщенияЗагрузки = ПолучитьБулевоИзПеременнойСреды(
		"OSLIB_LOADER_TRACE", Ложь);
			
// Если Ложь, то пропускаются ошибки повторной загрузки классов/модулей, 
//что важно при разработке/тестировании стандартных библиотек
// Если Истина, то выдается ошибка при повторной загрузке классов библиотек из движка
// Переменная среды может принимать значение 0 (выключено) или 1 (включено)
// Значение флага по умолчанию - Истина
ВыдаватьОшибкуПриЗагрузкеУжеСуществующихКлассовМодулей = ПолучитьБулевоИзПеременнойСреды(
	"OSLIB_LOADER_DUPLICATES", Ложь);

// для установки других значений переменных среды и запуска скриптов можно юзать следующую командную строку
// (set OSLIB_LOADER_TRACE=1) && (oscript .\tasks\test.os)