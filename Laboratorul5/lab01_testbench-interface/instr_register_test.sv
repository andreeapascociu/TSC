/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  parameter WR_NR = 5;
  parameter RD_NR = 4;
  parameter read_order = 0;         // 0 - for incremental; 1 - for random; 2 - for decremental
  parameter write_order = 0;        // 0 - for incremental; 1 - for random; 2 - for decremental
  parameter seed_val = 999;
  parameter TEST_NAME = "test";
  int seed = seed_val;
  int num_errors = 0;

  instruction_t iw_reg_test [0:31];

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS A SELF-CHECKING TESTBENCH.                 ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    reset_data();
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    
    repeat (WR_NR) begin
      @(posedge clk) randomize_transaction;
      @(negedge clk) print_transaction;  
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    $display("\nReading back the same register locations written...");
    if(read_order==0) begin
      for (int i=0; i<=RD_NR; i++) begin
        @(posedge clk) read_pointer = i;
        @(negedge clk) print_results;
        check_result(); 
      end
    end
    else if(read_order==1) begin
      for (int i=0; i<=RD_NR; i++) begin
        @(posedge clk) read_pointer = $unsigned($random)%32;;
        @(negedge clk) print_results;
        check_result(); 
      end
      end
    else if(read_order==2) begin
      for (int i=0; i<=RD_NR; i++) begin
      static int temp = 31;
        @(posedge clk) read_pointer = temp;
        @(negedge clk) print_results;
        temp--;
        check_result();
      end
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***      THIS IS A SELF-CHECKING TESTBENCH.             ***");
    $display(  "***********************************************************\n");
    final_report();
    write_to_file();
    $finish;

  end

//////////////////////// TRANSACTION RANDOMIZATION ////////////////////////////////////////////////////////
  function void randomize_transaction;
    if(write_order == 0) begin  // this code has incremental write_pointer
      static int temp = 0;
      operand_a     = $random(seed)%16;                 // between -15 and 15
      operand_b     = $unsigned($random)%16;            // between 0 and 15
      opcode        = opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type
      write_pointer = temp++;
    end
    else if(write_order == 1) begin  // this code has random write_pointer
      operand_a     = $random(seed)%16;                 // between -15 and 15
      operand_b     = $unsigned($random)%16;            // between 0 and 15
      opcode        = opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type
      write_pointer = $unsigned($random)%32;
    end
    else if(write_order == 2) begin
      static int temp = 31;
      operand_a     = $random(seed)%16;                 // between -15 and 15
      operand_b     = $unsigned($random)%16;            // between 0 and 15
      opcode        = opcode_t'($unsigned($random)%9);  // between 0 and 7, cast to opcode_t type
      write_pointer = temp--;
    end
    
    $display("Test: opcode=%0d, operand_a=%0d, operand_b=%0d at time %0t.", opcode, operand_a, operand_b, $time);
    iw_reg_test[write_pointer] = '{opcode, operand_a, operand_b, 64'b0};
    //iw_reg_test[0] = '{opcode, operand_a, operand_b, 0};
  endfunction: randomize_transaction

//////////////////////// FUNCTION FOR RESETING THE DATA ////////////////////////////////////////////////////////
  function void reset_data();
    $display("Resetting the signals");
    foreach (iw_reg_test[i])
        iw_reg_test[i] = '{opc:ZERO,default:0};  // reset to all zeros
    endfunction: reset_data

//////////////////////// FINAL REPORT /////////////////////////////////////////////////////////////////////////
   function void final_report;
        $display("\n*******************************************************");
        $display("***                  FINAL REPORT                   ***");
        $display("*******************************************************");
        $display("Total number of errors encountered: %0d", num_errors);
        if (num_errors == 0)
            $display("Congratulations! No errors found.");
        else
            $display("Oops! There were %0d errors detected.", num_errors);
        $display("*******************************************************\n");
    endfunction

//////////////////////// PRINT TRANSACTION /////////////////////////////////////////////////////////////////////
  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

//////////////////////// PRINT RESULTS /////////////////////////////////////////////////////////////////////////
  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d", instruction_word.op_b);
    $display("  result = %0d", instruction_word.res);
  endfunction: print_results

//////////////////////// FUNCTION FOR RESULT CHECKING //////////////////////////////////////////////////////////
  function void check_result();
    //int file;
    if(instruction_word.op_a === iw_reg_test[read_pointer].op_a)
      $display("Value of op_a stored correctly");
    else begin
      $error("Value of opc is incorrect, the values are %0d and %0d predicted", instruction_word.op_a, iw_reg_test[read_pointer].op_a);
       num_errors++;
    end
    if(instruction_word.op_b === iw_reg_test[read_pointer].op_b)
      $display("Value of op_b stored correctly");
    else begin
      $error("Value of opc is incorrect, the values are %0d and %0d predicted", instruction_word.op_b, iw_reg_test[read_pointer].op_b);
       num_errors++;
    end
    if(instruction_word.opc === iw_reg_test[read_pointer].opc)
      $display("Value of opc stored correctly");
    else begin
      $error("Value of opc is incorrect, the values are %0d and %0d predicted", instruction_word.opc, iw_reg_test[read_pointer].opc);
       num_errors++;
    end
    case (iw_reg_test[read_pointer].opc)
      ZERO: iw_reg_test[read_pointer].res = 0;
      PASSA: iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a;
      PASSB: iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_b;
      ADD: iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
      SUB: iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a -  $signed(iw_reg_test[read_pointer].op_b);
      MULT: iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
      DIV: begin
        if(iw_reg_test[read_pointer].op_b === 0)
          iw_reg_test[read_pointer].res = 0;
        else
          iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;
      end
      MOD: begin
        if(iw_reg_test[read_pointer].op_b === 0)
          iw_reg_test[read_pointer].res = 0;
        else
          iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
      end
      POW: begin
         if(iw_reg_test[read_pointer].op_a === 0)
            iw_reg_test[read_pointer].res = 0;
          else
            iw_reg_test[read_pointer].res = iw_reg_test[read_pointer].op_a ** iw_reg_test[read_pointer].op_b;
      end
      default: iw_reg_test[read_pointer].res = 0; 
    endcase
    if(instruction_word.res === iw_reg_test[read_pointer].res)
      $display("The operation between %0d and %0d is correct!\n", iw_reg_test[read_pointer].op_a, iw_reg_test[read_pointer].op_b);
    else begin
      $error("The value is incorrect, %0d and %0d should be %0d predicted!\n",iw_reg_test[read_pointer].op_a, iw_reg_test[read_pointer].op_b, iw_reg_test[read_pointer].res);
       num_errors++;
    end
  endfunction: check_result

//////////////////////// FUNCTION FOR WRITING IN THE REGRESSION REPORT TEXT FILE //////////////////////////////////
   function void write_to_file;
    int file;
    file = $fopen("../reports/regression_report.txt", "a");
    if(num_errors == 0) begin
      $fdisplay(file, "%s : Test passed", TEST_NAME);
    end
    else begin
      $fdisplay(file, "%s : Test failed", TEST_NAME);
    end
    $fclose(file);

  endfunction: write_to_file


endmodule: instr_register_test
