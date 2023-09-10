; interface
;---------------------------------------------------------
(defrule system-start "Message on the start of the script"
    (declare (salience 10))
    =>
    (printout t crlf crlf)
    (printout t "Система подбора языка программирования в соответствии с вашими интересами")
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


; Knowledge base - antecedents
;---------------------------------------------------------
(defrule r1 ""
    (declare (salience 0))
    (not (goal ?))
    =>
    (bind ?response (ask-question-list "Вы предпочитаете КОМПИЛИРУЕМЫЕ (1) или ИНТЕРПРЕТИРУЕМЫЕ (2) языки? (Введите 1 или 2)" 1 2 ))

)