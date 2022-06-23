/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

//ALU commands
`define ALU_ADD     3'b000
`define ALU_OR      3'b001
`define ALU_SRL     3'b010
`define ALU_SLTU    3'b011
`define ALU_SUB     3'b100

// instruction opcode
`define RVOP_ADDI   7'b0010011
`define RVOP_BEQ    7'b1100011
`define RVOP_LUI    7'b0110111
`define RVOP_BNE    7'b1100011
`define RVOP_ADD    7'b0110011
`define RVOP_OR     7'b0110011
`define RVOP_SRL    7'b0110011
`define RVOP_SLTU   7'b0110011
`define RVOP_SUB    7'b0110011
//`define RVOP_LD   RV64 insturcion
`define RVOP_LW     7'b0000011
`define RVOP_LH     7'b0000011
`define RVOP_LB     7'b0000011
//`define RVOP_LWU  RV64 insturcion
`define RVOP_LHU    7'b0000011
`define RVOP_LBU    7'b0000011
//`define RVOP_SD   RV64 insturcion   
`define RVOP_SW     7'b0100011
`define RVOP_SH     7'b0100011
`define RVOP_SB     7'b0100011

// instruction funct3
`define RVF3_ADDI   3'b000
`define RVF3_BEQ    3'b000
`define RVF3_BNE    3'b001
`define RVF3_ADD    3'b000
`define RVF3_OR     3'b110
`define RVF3_SRL    3'b101
`define RVF3_SLTU   3'b011
`define RVF3_SUB    3'b000
//`define RVF3_LD   RV64 insturcion
`define RVF3_LW     3'b010
`define RVF3_LH     3'b001
`define RVF3_LB     3'b000
//`define RVF3_LWU  RV64 insturcion
`define RVF3_LHU    3'b101
`define RVF3_LBU    3'b100
//`define RVF3_SD   RV64 insturcion
`define RVF3_SW     3'b010
`define RVF3_SH     3'b001
`define RVF3_SB     3'b000
`define RVF3_ANY    3'b???

// instruction funct7
`define RVF7_ADD    7'b0000000
`define RVF7_OR     7'b0000000
`define RVF7_SRL    7'b0000000
`define RVF7_SLTU   7'b0000000
`define RVF7_SUB    7'b0100000
`define RVF7_ANY    7'b???????

