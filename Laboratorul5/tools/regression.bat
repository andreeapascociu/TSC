call run_test.bat 50 50 0 0 case_inc_inc c

call run_test.bat 30 30 0 1 case_inc_rnd c

call run_test.bat 30 30 1 0 case_rnd_inc c

call run_test.bat 30 30 1 1 case_rnd_rnd c

call run_test.bat 30 30 0 2 case_inc_dec c

call run_test.bat 30 30 2 0 case_dec_inc c

call run_test.bat 30 30 2 1 case_dec_rnd c

call run_test.bat 30 30 1 2 case_rnd_dec c

call run_test.bat 30 30 2 2 case_dec_dec c

:: Create regression file and write final report to it
echo *** Regression Report *** > ../reports/regression_report.txt
