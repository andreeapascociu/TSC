/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/

module instr_register
import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
(input  logic          clk,
 input  logic          load_en,
 input  logic          reset_n,
 input  operand_t      operand_a,
 input  operand_t      operand_b,
 input  opcode_t       opcode,
 input  address_t      write_pointer,
 input  address_t      read_pointer,
 output result         rez,
 output instruction_t  instruction_word
);
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures

  // write to the register
  always@(posedge clk, negedge reset_n)   // write into register
    if (!reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
        // default:0 -- celelalte variabile care raman sunt puse in zero
    end
    else if (load_en) begin
      //iw_reg[write_pointer] = '{opcode,operand_a,operand_b};
      instruction_t new_instr;
      new_instr.opc = opcode;
      new_instr.op_a = operand_a;
      new_instr.op_b = operand_b;
      new_instr.res = calc_result(opcode, operand_a, operand_b);
      
      iw_reg[write_pointer] = new_instr;
    end

  // read from the register
  assign instruction_word = iw_reg[read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force operand_b = operand_a; // cause wrong value to be loaded into operand_b
end
`endif

// tema de adaugat logica pentru utilizarea 
function result calc_result(opcode_t opcode, operand_t op_a, operand_t op_b);
    case (opcode)
      ZERO: calc_result = 0;
      PASSA: calc_result = op_a;
      PASSB: calc_result = op_b;
      ADD: calc_result = op_a + op_b;
      SUB: calc_result = op_a - op_b;
      MULT: calc_result = op_a * op_b;
      DIV: calc_result = op_a / op_b;
      MOD: calc_result = op_a % op_b;

      // TEMA: RIDIVARE LA PUTERE **
      default: calc_result = 0; // Handle unsupported opcodes
    endcase
  endfunction: calc_result

endmodule: instr_register
