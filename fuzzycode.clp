(deftemplate Patient
   (slot id (type INTEGER))
   (slot sex (type NUMBER))
   (slot chest_pain_type (type NUMBER))
   (slot serum_cholestoral (type NUMBER))
   (slot exercise_angina(type NUMBER))
   (slot slope_ST(type NUMBER))
   (slot vessels_flourosopy(type NUMBER))
   (slot thal (type NUMBER))
   (slot class (type INTEGER) (range 1 2))
)

(deftemplate chest_pain_type_fuzzy
1.0 4.0
((low (1.0 1) (2.0 1))
(high (3.0 1) (4.0 1)))
)

(deftemplate vessels_flourosopy_fuzzy
0.0 3.0
((few (0.0 1))
(many (1.0 1) (2.0 1) (3.0 1)))
)
 
(deftemplate Patient_fuzzy
   (slot id (type INTEGER))
   (slot sex (type NUMBER))
   (slot chest_pain_type-fuzzy (type FUZZY-VALUE chest_pain_type_fuzzy))
   (slot serum_cholestoral (type NUMBER))
   (slot exercise_angina(type NUMBER))
   (slot slope_ST (type NUMBER))
   (slot vessels_flourosopy-fuzzy(type FUZZY-VALUE vessels_flourosopy_fuzzy))
   (slot thal (type NUMBER))
   (slot class (type INTEGER) (range 1 2))
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
(open "C:/Users/giota/Desktop/heart-data-analysis-expert-system-main/clips/input/input-training-set.clp" inputfile "r")
(printout t "Training set loaded" crlf crlf)
else
(open "C:/Users/giota/Desktop/heart-data-analysis-expert-system-main/clips/input/input-test-set.clp" inputfile "r")
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

(defrule fuzzify-fact
  (declare (salience 65))
  (Patient (id ?id) (sex ?sex) (chest_pain_type ?chest_pain_type) 
               (exercise_angina ?exercise_angina)(slope_ST ?slope_ST)
               (vessels_flourosopy ?vessels_flourosopy) (thal ?thal) (class ?class))
 =>
  (assert (Patient_fuzzy (id ?id) (sex ?sex) (chest_pain_type-fuzzy (?chest_pain_type 0) (?chest_pain_type 1)) 
               (exercise_angina ?exercise_angina)(slope_ST ?slope_ST)
               (vessels_flourosopy-fuzzy (?vessels_flourosopy 0) (?vessels_flourosopy 1) (?vessels_flourosopy 0)) (thal ?thal) (class ?class)))
)

; thal!=7 and vessels_flourosopy = 3 then 2
(defrule r1
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy many) (class ?class))
   (test (<> ?th 7))
;  (test (= ?vf 3))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (retract ?f))
   
 ; thal!=7 και vessels_flourosopy !=3 !=0 and sex=0 and chest_pain !=4 then 1
(defrule r2
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy many) (chest_pain_type-fuzzy low) (sex ?sex) (class ?class))
   (test (<> ?th 7))
;  (test (<> ?vf 0))
;  (test (<> ?vf 3))
;  (test (< ?chp 3))
   (test (= ?sex 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (retract ?f))


; thal!=7 και vessels_flourosopy !=3 !=0 and sex!=0 and chest_pain =4 then 2
(defrule r3
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy many) (chest_pain_type-fuzzy high) (sex ?sex) (class ?class))
   (test (<> ?th 7))
;  (test (<> ?vf 0))
;  (test (<> ?vf 3))
;  (test (>= ?chp 3))
   (test (= ?sex 1))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (retract ?f))


; thal!=7 και vessels_flourosopy !=3 !=0 and sex=0 then 1
(defrule r4
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy many) (sex ?sex) (class ?class))
   (test (<> ?th 7))   
;  (test (<> ?vf 0))
;  (test (<> ?vf 3))
   (test (= ?sex 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (retract ?f))


; thal!=7 and vessels_flourosopy = 0 then 1
(defrule r5
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy few) (class ?class))
   (test (<> ?th 7))   
;  (test (= ?vf 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (retract ?f))


; thal=7 and vessels_flourosopy != 0 then 2
(defrule r6
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy many) (class ?class))
   (test (= ?th 7))   
;  (test (<> ?vf 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (retract ?f))


; thal=7 and vessels_flourosopy = 0 and slope_ST > 1.0 and exercise_angina !=0 then 2
(defrule r7
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy few) (slope_ST ?slope_ST) (exercise_angina ?exang) (class ?class))
   (test (= ?th 7))
;  (test (= ?vf 0))
   (test (<> ?exang 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 2) (realClass ?class)))
   (retract ?f))


; thal=7 and vessels_flourosopy = 0 and slope_ST > 1.0 and exercise_angina=0 then 1
(defrule r8
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy few) (slope_ST ?slope_ST) (exercise_angina ?exang) (class ?class))
   (test (= ?th 7))
;  (test (= ?vf 0))
   (test (= ?exang 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (retract ?f))


; thal=7 and vessels_flourosopy = 0 and slope_ST <=1.0 and exercise_angina=0 then 1
(defrule r9
   (declare (salience 80))
   ?f <- (Patient_fuzzy (id ?id) (thal ?th) (vessels_flourosopy-fuzzy few) (slope_ST ?slope_ST) (exercise_angina ?exang) (class ?class))
   (test (= ?th 7))
;  (test (= ?vf 0))
   =>
   (assert (Diagnosis (id ?id) (diagnosis 1) (realClass ?class)))
   (retract ?f))
   

(defrule metrics
     =>
     (load "C:/Users/giota/Desktop/heart-data-analysis-expert-system-main/clips/metrics.clp")