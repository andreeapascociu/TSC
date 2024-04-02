#source ../lab01_testbench-interface/shared_variables.sv
# Deschideți fișierul pentru adăugare (append) sau creați-l dacă nu există
set file_handle [open "../reports/regression_report.txt" "a"]

# Verifică dacă s-a deschis corect fișierul
if {$file_handle == ""} {
    puts "Eroare la deschiderea fișierului pentru scriere"
    exit
}
source ../lab01_testbench-interface/shared_variables.sv
# Scrieți numărul total de erori în fișier
puts $file_handle "Total number of errors encountered: $num_errors"

# Verificați dacă testul a trecut sau a eșuat și scrieți rezultatul în fișier
if {$num_errors == 0} {
    puts $file_handle "TEST PASSED!"
} else {
    puts $file_handle "TEST FAILED!"
}

# Închideți fișierul
close $file_handle
