function computedvalue = F(whileprogram, inputvariables)
## Mathematical function computed by a WHILE program
##
## In case of error in the WHILE code, it raises the wrong Octave code.
##
## example
##   >> F("(1, X2≔X1; while X2≠0 do X1≔X1+1; X2≔X2-1 od)", [10])
##   (1,10,0) ⊢ (2,10,10) ⊢ (3,10,10) ⊢ (4,11,10) ⊢ (5,11,9) ⊢ (2,11,9) ⊢
##   (3,11,9) ⊢ (4,12,9) ⊢ (5,12,8) ⊢ (2,12,8) ⊢ (3,12,8) ⊢ (4,13,8) ⊢
##   (5,13,7) ⊢ (2,13,7) ⊢ (3,13,7) ⊢ (4,14,7) ⊢ (5,14,6) ⊢ (2,14,6) ⊢
##   (3,14,6) ⊢ (4,15,6) ⊢ (5,15,5) ⊢ (2,15,5) ⊢ (3,15,5) ⊢ (4,16,5) ⊢
##   (5,16,4) ⊢ (2,16,4) ⊢ (3,16,4) ⊢ (4,17,4) ⊢ (5,17,3) ⊢ (2,17,3) ⊢
##   (3,17,3) ⊢ (4,18,3) ⊢ (5,18,2) ⊢ (2,18,2) ⊢ (3,18,2) ⊢ (4,19,2) ⊢
##   (5,19,1) ⊢ (2,19,1) ⊢ (3,19,1) ⊢ (4,20,1) ⊢ (5,20,0) ⊢ (2,20,0) ⊢
##   (6,20,0)
##   ans =  20
##
##  fjv 20211214 GNU GPL v3.0

  computedvalue = Cal(whileprogram, inputvariables, T(whileprogram, inputvariables))(2);

  fprintf(stderr, "\n");

end
