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

; Knowledge base - antecedents
;---------------------------------------------------------
(defrule r1 ""
    (declare (salience 0))
    (not (goal ?))
    =>
    (bind ?response (ask-question-list "Вы предпочитаете КОМПИЛИРУЕМЫЕ (1) или ИНТЕРПРЕТИРУЕМЫЕ (2) языки? (Введите 1 или 2): " 1 2 ))

)