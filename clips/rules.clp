(deftemplate Patient
   (slot id (type INTEGER))
   (slot sex)
   (slot chest_pain_type)
   (slot serum_cholestoral)
   (slot exercise_angina)
   (slot slope_ST)
   (slot vessels_flourosopy)
   (slot thal)
   (slot class)
)


(deftemplate Diagnosis
 (slot id (type INTEGER))
 (slot diagnosis (type INTEGER) (range 1 2))
 (slot realClass (type INTEGER) (range 1 2))
)


(defrule Menu
(declare (salience 90))
=>
(printout t "Selection 1: Load training set" crlf "Selection 2: Load test set" crlf)
(bind ?response (read))
(if (= ?response 1) then
(open "C:/Users/mariak/heart-data-analysis-expert-system/clips/input/input-training-set.clp" inputfile "r")
(printout t "Training set loaded" crlf crlf)
else
(open "C:/Users/mariak/heart-data-analysis-expert-system/clips/input/input-test-set.clp" inputfile "r")
(printout t "Test set loaded" crlf crlf)
)

(bind ?id 1)
(while (stringp(bind ?x(readline inputfile)))
do
(bind ?sex(nth$ 2 (explode$ ?x))) 
(bind ?chest_pain_type(nth$ 3 (explode$ ?x))) 
(bind ?exercise_angina(nth$ 9 (explode$ ?x)))
(bind ?slope_ST(nth$ 11 (explode$ ?x)))
(bind ?vessels_flourosopy(nth$ 12 (explode$ ?x)))
(bind ?thal(nth$ 13 (explode$ ?x)))
(bind ?class(nth$ 14 (explode$ ?x)))

(assert (Patient (id ?id) (sex ?sex) (chest_pain_type ?chest_pain_type) 
               (exercise_angina ?exercise_angina)(slope_ST ?slope_ST)
               (vessels_flourosopy ?vessels_flourosopy) (thal ?thal) (class ?class)))              
(bind ?id (+ ?id 1))
)
(close inputfile)
)


; thal!=7 and vessels_flourosopy = 3 then 2
(defrule r1
   (declare (salience 80))
   (Patient (id ?id)(thal ?th)(vessels_flourosopy ?vf)(class ?class))
   (test (and (<> ?th 7) (= ?vf 3)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (printout t "2" crlf))


; thal!=7 και vessels_flourosopy !=3 !=0 and sex=1 and chest_pain !=4 then 1
(defrule r2
   (declare (salience 80))
   (Patient (id ?id)(thal ?th)(vessels_flourosopy ?vf)(chest_pain_type ?chp)(sex ?sex)(class ?class))
   (and (test (<> ?th 7))
        (test (and (<> ?vf 0) (<> ?vf 3))))
   (and (test (<> ?chp 4))
        (test (= ?sex 1)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (printout t "1" crlf))


; thal!=7 και vessels_flourosopy !=3 !=0 and sex!=0 and chest_pain =4 then 2
(defrule r3
   (declare (salience 80))
   (Patient (id ?id)(thal ?th)(vessels_flourosopy ?vf)(chest_pain_type ?chp)(sex ?sex)(class ?class))
   (and (test (<> ?th 7))
        (test (and (<> ?vf 0) (<> ?vf 3))))
   (and (test (= ?chp 4))
        (test (= ?sex 1)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (printout t "2" crlf))


; thal!=7 και vessels_flourosopy !=3 !=0 and sex=0 then 1
(defrule r4
   (declare (salience 80))
   (Patient (id ?id)(thal ?th) (vessels_flourosopy ?vf)(chest_pain_type ?chp)(sex ?sex)(class ?class))
   (and (test (<> ?th 7))
        (test (<> ?vf 0)))
   (and (test (<> ?vf 3))
        (test (= ?sex 0)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (printout t "1" crlf))


; thal!=7 and vessels_flourosopy=0 then 1
(defrule r5
   (declare (salience 80))
   (Patient (id ?id)(thal ?th)(vessels_flourosopy ?vf)(class ?class))
   (test (and (<> ?th 7) (= ?vf 0)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (printout t "1" crlf))


; thal=7 and vessels_flourosopy != 0 then 2
(defrule r6
   (declare (salience 80))
   (Patient (id ?id)(thal ?th) (vessels_flourosopy ?vf)(class ?class))
   (test (and (= ?th 7) (<> ?vf 0)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (printout t "2" crlf))


; thal=7 and vessels_flourosopy = 0 and slope_ST > 1.0 and exercise_angina !=0 then 2
(defrule r7
   (declare (salience 80))
   (Patient (id ?id)(thal ?th) (vessels_flourosopy ?vf)(slope_ST ?slope)(exercise_angina ?exang)(class ?class))
   (and (test (= ?th 7))
        (test (= ?vf 0)))
   (and (test (> ?slope 1.0))
        (test (<> ?exang 0)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (printout t "2" crlf))


; thal=7 and vessels_flourosopy = 0 and slope_ST > 1.0 and exercise_angina=0 then 1
(defrule r8
   (declare (salience 80))
   (Patient (id ?id)(thal ?th) (vessels_flourosopy ?vf)(slope_ST ?slope)(exercise_angina ?exang)(class ?class))
   (and (test (= ?th 7))
        (test (= ?vf 0)))
   (and (test (> ?slope 1.0))
        (test (= ?exang 0)))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (printout t "1" crlf))


; thal=7 and vessels_flourosopy = 0 and slope_ST <= 1.0 and exercise_angina=0 then 1
(defrule r9
   (declare (salience 80))
   (Patient (id ?id)(thal ?th) (vessels_flourosopy ?vf)(slope_ST ?slope)(exercise_angina ?exang)(class ?class))
   (and (test (= ?th 7))
        (test (= ?vf 0)))
   (test (<= ?slope 1.0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (printout t "1" crlf))


(defrule metrics
     =>
     (load "C:/Users/mariak/heart-data-analysis-expert-system/clips/metrics.clp")
)