; interface
;---------------------------------------------------------
(defrule system-start "Message on the start of the script"
    (declare (salience 10))
    =>
    (printout t crlf crlf)
    (printout t "Система подбора языка программирования в соответствии с вашими интересами.")
    (printout t crlf crlf)
)

(defrule system-finish "Message on the end of the script"
    (declare (salience -20))
    => 
    (printout t crlf)
    (printout t "Благодарим за использование экспертной системы.")
    (printout t crlf crlf)
)


; functions
;---------------------------------------------------------
; Function, allowing to choose an answer from a proposed list 
(deffunction ask-question-list (?question $?allowed-values)
    (printout t ?question)
    (bind ?answer (read))
    (if (lexemep ?answer)
        then (bind ?answer (lowcase ?answer)))
    (while (not (member$ ?answer ?allowed-values)) do
        (printout t ?question)
        (bind ?answer (read))
        (if (lexemep ?answer)
            then (bind ?answer (lowcase ?answer))))
    ?answer
)

; Function accepting "yes" or "no"
(deffunction ask-question-binary (?question)
    (bind ?response (ask-question-list ?question true yes y да д false no n нет н))
    (if (or (eq ?response true)(eq ?response yes)(eq ?response y)(eq ?response да)(eq ?response д))
        then TRUE
        else FALSE
    )
)

; results
;---------------------------------------------------------
; Result found
(defrule print-goal ""
    (declare (salience 10))
    (goal ?item)
    =>
    (printout t crlf crlf)
    (printout t "Вам рекомендуется следующий язык программирования: ")
    (format t "%n%s%n%n" ?item)
)

; Result not found
(defrule no-goal ""
    (declare (salience -10))
    (not (goal ?))
    =>
    (assert (goal "Подходящий именно вам язык программирования не может быть подобран. Учите все."))
)

; Knowledge base: antecedents
;---------------------------------------------------------
(defrule r1 "Compiled or interpreted"
    (declare (salience 0))
    (not (goal ?))
    =>
    (bind ?response (ask-question-list "Вы предпочитаете КОМПИЛИРУЕМЫЕ (1) или ИНТЕРПРЕТИРУЕМЫЕ (2) языки? (Введите 1 или 2): " 1 2 ))
    (if (eq ?response 1) then
        (assert (paradigm compiled)))
    (if (eq ?response 2) then
        (assert (paradigm interpreted)))
)

(defrule r2 "Language level: high or low"
    (declare (salience 0))
    (not (goal ?))
    =>
    (bind ?response (ask-question-list "Вы предпочитаете языки  НИЗКОГО (1) уровня или ВЫСОКОГО (2)? (Введите 1 или 2): " 1 2))
    (if (eq ?response 1) then
        (assert (level low)))
    (if (eq ?response 2) then
        (assert (level high)))
)

(defrule r3 "Is language object oriented"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете объектно-ориентированные языки? ") then
        (assert (object-oriented yes))
    else
        (assert (object-oriented no))
    )
)

(defrule r4 "Is language created by Microsoft"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете языки разработки Microsoft? ") then
        (assert (microsoft yes))
    else
        (assert (microsoft no))
    )
)

(defrule r5 "Interactive mode"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете когда язык подерживает интерактивный режим работы? ") then
        (assert (interactive yes))
    else
        (assert (interactive no))
    )
)

(defrule r6 "Web development"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете язык для web-разработки? ") then
        (assert (webdevelopment yes))
    else
        (assert (webdevelopment no))
    )
)

(defrule r7 "Code teaching"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете языки, используемые для начального обучения программированию? ") then
        (assert (codeteaching yes))
    else
        (assert (codeteaching no))
    )
)

(defrule r8 "Indentation"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете обозначение блоков кода при помощи отступов? ") then
        (assert (indentation yes))
    else
        (assert (indentation no))
    )
)

(defrule r9 "Short commands"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете короткие команды в виде аббревиатур? ") then
        (assert (shortcommands yes))
    else
        (assert (shortcommands no))
    )
)

(defrule r10 "Only ABCDEF letters"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете использовать только цифры и следующие буквы: ABCDEF? ") then
        (assert (abcdeflettersonly yes))
    else
        (assert (abcdeflettersonly no))
    )
)

(defrule r11 "Short commands"
    (declare (salience 0))
    (not (goal ?))
    =>
    (if (ask-question-binary "Вы предпочитаете языки, в которых много круглых скобок? ") then
        (assert (lotofparentheses yes))
    else
        (assert (lotofparentheses no))
    )
)

; Knowledge base: consequents
;---------------------------------------------------------
(defrule g1 "C"
    (not (goal ?))
    (paradigm compiled)
    (level low)
    (object-oriented no)
    (microsoft no)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "C"))
)

(defrule g2 "C++"
    (not (goal ?))
    (paradigm compiled)
    (level low)
    (object-oriented yes)
    (microsoft no)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "C++"))
)

(defrule g3 "C#"
    (not (goal ?))
    (paradigm compiled)
    (level high)
    (object-oriented yes)
    (microsoft yes)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "C#"))
)

(defrule g4 "PowerShell"
    (not (goal ?))
    (paradigm interpreted)
    (level high)
    (object-oriented yes)
    (microsoft yes)
    (interactive yes)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "PowerShell"))
)

(defrule g5 "Visual Basic Script"
    (not (goal ?))
    (paradigm interpreted)
    (level high)
    (object-oriented no)
    (microsoft yes)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "Visual Basic Script"))
)

(defrule g6 "BASH"
    (not (goal ?))
    (paradigm interpreted)
    (level high)
    (object-oriented no)
    (microsoft no)
    (interactive yes)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "BASH"))
)

(defrule g7 "JavaScript"
    (not (goal ?))
    (paradigm interpreted)
    (level high)
    (object-oriented yes)
    (microsoft no)
    (interactive no)
    (webdevelopment yes)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "JavaScript"))
)

(defrule g8 "Machine Code"
    (not (goal ?))
    (paradigm ?)
    (level low)
    (object-oriented no)
    (microsoft no)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly yes)
    (lotofparentheses no)
    =>
    (assert (goal "Machine code"))
)

(defrule g9 "Assembler"
    (not (goal ?))
    (paradigm compiled)
    (level low)
    (object-oriented no)
    (microsoft no)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands yes)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "Assembler"))
)

(defrule g10 "Pascal"
    (not (goal ?))
    (paradigm compiled)
    (level high)
    (object-oriented no)
    (microsoft no)
    (interactive no)
    (webdevelopment no)
    (codeteaching yes)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "Pascal"))
)

(defrule g11 "Python"
    (not (goal ?))
    (paradigm interpreted)
    (level high)
    (object-oriented yes)
    (microsoft no)
    (interactive yes)
    (webdevelopment yes)
    (codeteaching yes)
    (indentation yes)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses no)
    =>
    (assert (goal "Python"))
)

(defrule g12 "Lisp"
    (not (goal ?))
    (paradigm compiled)
    (level high)
    (object-oriented no)
    (microsoft no)
    (interactive no)
    (webdevelopment no)
    (codeteaching no)
    (indentation no)
    (shortcommands no)
    (abcdeflettersonly no)
    (lotofparentheses yes)
    =>
    (assert (goal "Lisp"))
)
