@REM call run_test.bat 50 50 0 0 case_inc_inc c

@REM call run_test.bat 30 30 0 1 case_inc_rnd c

@REM call run_test.bat 30 30 1 0 case_rnd_inc c

@REM call run_test.bat 30 30 1 1 case_rnd_rnd c

@REM call run_test.bat 30 30 0 2 case_inc_dec c

@REM call run_test.bat 30 30 2 0 case_dec_inc c

@REM call run_test.bat 30 30 2 1 case_dec_rnd c

@REM call run_test.bat 30 30 1 2 case_rnd_dec c

@REM call run_test.bat 30 30 2 2 case_dec_dec c

@REM :: Create regression file and write final report to it

call run_test.bat 50 32 1 1 case1 c 5555
call run_test.bat 50 32 1 1 case2 c 3443
call run_test.bat 50 32 1 1 case3 c 7777
call run_test.bat 50 32 1 1 case4 c 4567
call run_test.bat 50 32 1 1 case5 c 2246
call run_test.bat 50 32 1 1 case6 c 5788
call run_test.bat 50 32 1 1 case7 c 6666
call run_test.bat 50 32 1 1 case8 c 4567
call run_test.bat 50 32 1 1 case9 c 3579
call run_test.bat 50 32 1 1 case10 c 4444
