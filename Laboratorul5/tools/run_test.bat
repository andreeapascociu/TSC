::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
:: parametru nou %6 - 0 inseamna terminal, - 1 inseamna gui -c saum -gui
::REGRESIE DIN LINIA DE COMANDA CU 9 TESTE IN FISIERUL REGRESSION STATUS- FIECARE LINIE UN TEST
:: NUME_TEST SI STATUS DIN FINAL REPORT
:: Din functie final report scriem in fisier cu fopen() fwrite()/ fdisplay() + fclose()..
::echo %1 %2 %3 %4 %5
vsim -%6 -do "do run.do %1 %2 %3 %4 %5 %6 %7" 
::call final_report >> ../reports/regression_report.txt

cd ../tools
::vsim -gui -do "do run.do %1 %2 %3 %4 %5" 
::vsim -gui -do run.do
::vsim -c -do run.do
