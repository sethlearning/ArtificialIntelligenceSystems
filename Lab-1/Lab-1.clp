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
    (printout t crlf crlf)
    (printout t "Благодарим за использование экспертной системы")
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


; Knowledge base: consequents
;---------------------------------------------------------
(defrule g1 "C"
    (not (goal ?))
    (paradigm compiled)
    =>
    (assert (goal "C"))
)

(defrule g2 "C++"
    (not (goal ?))
    (paradigm compiled)
    =>
    (assert (goal "C++"))
)

(defrule g3 "C#"
    (not (goal ?))
    (paradigm compiled)
    =>
)

(defrule g4 "PowerShell"
    (not (goal ?))
    (paradigm interpreted)
    =>
)

(defrule g5 "Visual Basic Script"
    (not (goal ?))
    (paradigm interpreted)
    =>
)

(defrule g6 "BASH"
    (not (goal ?))
    (paradigm interpreted)
    =>
)

(defrule g7 "JavaScript"
    (not (goal ?))
    (paradigm interpreted)
    =>
)

(defrule g8 "Machine Code"
    (not (goal ?))
    =>
)

(defrule g9 "Assembler"
    (not (goal ?))
    (paradigm compiled)
    =>
)

(defrule g10 "Pascal"
    (not (goal ?))
    (paradigm compiled)
    =>
)

(defrule g11 "Python"
    (not (goal ?))
    (paradigm interpreted)
    =>
)

(defrule g12 "Lisp"
    (not (goal ?))
    (paradigm compiled)
    =>
)
