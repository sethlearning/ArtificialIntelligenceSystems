:-include('facts.pl').

%language('C','Компилируемый').
%language('C++','Компилируемый').
%language('C#','Компилируемый').

binary('yes',true).
binary('y',true).
binary('да',true).
binary('д',true).
binary('no',false).
binary('n',false).
binary('нет',false).
binary('н',false).

getlanguage:-
    write('Компилируемый (1) или Интерпретируемый (2): '),read(Type),
    write('Низкого (1) или Высокого (2) уровня '),read(Level),
    write('Объектно-ориентированный '),read(ObjectOrientedAnswer),binary(ObjectOrientedAnswer,ObjectOriented),
    write('Разработки Microsoft '),read(MicrosoftAnswer),binary(MicrosoftAnswer,Microsoft),
    write('Интерактивный режим '),read(InteractiveModeAnswer),binary(InteractiveModeAnswer,InteractiveMode),
    write('Web-разработка '),read(WebDevelopmentAnswer),binary(WebDevelopmentAnswer,WebDevelopment),
    write('Начальное обучение '),read(ProgrammingLearningAnswer),binary(ProgrammingLearningAnswer,ProgrammingLearning),
    write('Обозначение блоков кода при помощи отступов '),read(IndentationAnswer),binary(IndentationAnswer,Indentation),
    write('Короткие команды в виде аббревиатур '),read(AbbreviationsAnswer),binary(AbbreviationsAnswer,Abbreviations),
    write('Использование только цифр и букв ABCDEF '),read(ABCDEFAnswer),binary(ABCDEFAnswer,ABCDEF),
    write('Много круглых скобок '),read(ParenthesesAnswer),binary(ParenthesesAnswer,Parentheses),
          language(Language, Type, Level,
                   ObjectOriented, Microsoft, InteractiveMode,
                   WebDevelopment, ProgrammingLearning, Indentation,
                   Abbreviations, ABCDEF, Parentheses),nl,
          write('Выбранный язык: '),write(Language).
