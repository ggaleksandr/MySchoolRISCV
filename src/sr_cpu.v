/*
 * schoolRISCV - small RISC-V CPU 
 *
 * originally based on Sarah L. Harris MIPS CPU 
 *                   & schoolMIPS project
 * 
 * Copyright(c) 2017-2020 Stanislav Zhelnio 
 *                        Aleksandr Romanov 
 */ 

`include "sr_cpu.vh"

module sr_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,     // instruction memory data

    output          dmWe,       // data memory write enable
    output  [ 1:0]	dmAlign,         // data alignment
    output  [31:0]  dmA,        // data memory address
    output  [31:0]  dmWd,       // data memory write data
    input   [31:0]  dmRd        // data memory read data
);
    //control wires
    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        memWrite;
    wire        dmAlign;
    wire        resultSrc;
    wire        immSrc;
    wire        aluSrc;
    wire        wdSrc;
    wire        opType;
    wire        extType;
    wire  [1:0] bSize;
    wire  [2:0] aluControl;
    wire [31:0] dataOutExt;
    wire [31:0] dataInExt;

    //instruction decode wires
    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immS;

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch = pc + immB;
    wire [31:0] pcPlus4  = pc + 4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;
    sm_register r_pc(clk ,rst_n, pcNext, pc);

    //program memory access
    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;

    //instruction decode
    sr_decode id (
        .instr      ( instr        ),
        .cmdOp      ( cmdOp        ),
        .rd         ( rd           ),
        .cmdF3      ( cmdF3        ),
        .rs1        ( rs1          ),
        .rs2        ( rs2          ),
        .cmdF7      ( cmdF7        ),
        .immI       ( immI         ),
        .immB       ( immB         ),
        .immU       ( immU         ),
        .immS       ( immS         )  
    );

    //register file
    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sm_register_file rf (
        .clk        ( clk          ),
        .a0         ( regAddr      ),
        .a1         ( rs1          ),
        .a2         ( rs2          ),
        .a3         ( rd           ),
        .rd0        ( rd0          ),
        .rd1        ( rd1          ),
        .rd2        ( rd2          ),
        .wd3        ( wd3          ),
        .we3        ( regWrite     )
    );

    //debug register access
    assign regData = (regAddr != 0) ? rd0 : pc;

    //alu
    wire [31:0] immIS = immSrc ? immS : immI;
    wire [31:0] srcB = aluSrc ? immIS : rd2;
    wire [31:0] aluResult;
    wire [31:0] ReadData;

    sr_alu alu (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );

    wire [31:0] Result = resultSrc ? dataOutExt : aluResult;
    assign wd3 = wdSrc ? immU : Result;

    //control
    sr_control sm_control (
        .cmdOp      ( cmdOp        ),
        .cmdF3      ( cmdF3        ),
        .cmdF7      ( cmdF7        ),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ),
        .regWrite   ( regWrite     ),
        .aluSrc     ( aluSrc       ),
        .wdSrc      ( wdSrc        ),
        .aluControl ( aluControl   ),
        .immSrc     ( immSrc       ),
        .dmAlign    ( dmAlign      ),
        .memWrite   ( memWrite     ),
        .resultSrc  ( resultSrc    ),
        .opType     ( opType       ),
        .extType    ( extType      ),
        .bSize      ( bSize        )
    );

    //data memory access
    sr_extend sm_extend (
        .extType    ( extType       ),
        .bSize      ( bSize         ),
        .dataInExt  ( dataInExt     ),
        .dataOutExt ( dataOutExt    )
    );

    assign dataInExt = opType ? rd2 : dmRd;

    assign dmWe = memWrite;
    assign dmA = aluResult;
    assign dmWd = dataOutExt;
    assign ReadData = dmRd;

endmodule

module sr_decode
(
    input      [31:0] instr,
    output     [ 6:0] cmdOp,
    output     [ 4:0] rd,
    output     [ 2:0] cmdF3,
    output     [ 4:0] rs1,
    output     [ 4:0] rs2,
    output     [ 6:0] cmdF7,
    output reg [31:0] immI,
    output reg [31:0] immB,
    output reg [31:0] immU,
    output reg [31:0] immS  
);
    assign cmdOp = instr[ 6: 0];
    assign rd    = instr[11: 7];
    assign cmdF3 = instr[14:12];
    assign rs1   = instr[19:15];
    assign rs2   = instr[24:20];
    assign cmdF7 = instr[31:25];

    // I-immediate
    always @ (*) begin
        immI[10: 0] = instr[30:20];
        immI[31:11] = { 21 {instr[31]} };
    end

    // B-immediate
    always @ (*) begin
        immB[    0] = 1'b0;
        immB[ 4: 1] = instr[11:8];
        immB[10: 5] = instr[30:25];
        immB[   11] = instr[7];
        immB[31:12] = { 20 {instr[31]} };
    end

    // U-immediate
    always @ (*) begin
        immU[11: 0] = 12'b0;
        immU[31:12] = instr[31:12];
    end

    // S-immediate
    always @ (*) begin
        immS[ 4: 0] = instr[11:7];
        immS[10: 5] = instr[30:25];
        immS[31:11] = { 20 {instr[31]} };
    end

endmodule

module sr_control
(
    input      [ 6:0] cmdOp,
    input      [ 2:0] cmdF3,
    input      [ 6:0] cmdF7,
    input             aluZero,
    output            pcSrc, 
    output reg        regWrite, 
    output reg        aluSrc,
    output reg        wdSrc,
    output reg [ 2:0] aluControl,
    output reg        immSrc,
    output reg        memWrite,
    output reg [ 1:0] dmAlign,
    output reg        resultSrc,
    output reg        opType,
    output reg        extType,
    output reg [ 1:0] bSize
);
    reg          branch;
    reg          condZero;
    assign pcSrc = branch & (aluZero == condZero);

    always @ (*) begin
        branch          = 1'b0;
        condZero        = 1'b0;
        regWrite        = 1'b0;
        aluSrc          = 1'b0;
        wdSrc           = 1'b0;
        aluControl      = `ALU_ADD;
        immSrc          = 1'b0;
        memWrite        = 1'b0;
        dmAlign         = `WORD;
        resultSrc       = 1'b0;
        opType          = 1'b0;
        extType         = 1'b0;
        bSize           = `EXT32BITS;

        casez( {cmdF7, cmdF3, cmdOp} )
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc  = 1'b1; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; end

            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW   } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; resultSrc = 1'b1; dmAlign = `WORD; end
            { `RVF7_ANY,  `RVF3_LH,   `RVOP_LH   } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; resultSrc = 1'b1; dmAlign = `HALFWORD; bSize = `EXT16BITS; end
            { `RVF7_ANY,  `RVF3_LB,   `RVOP_LB   } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; resultSrc = 1'b1; dmAlign = `BYTE; bSize = `EXT8BITS;  end

            { `RVF7_ANY,  `RVF3_LHU,  `RVOP_LHU  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; resultSrc = 1'b1; dmAlign = `HALFWORD;    extType = 1'b1; bSize = `EXT16BITS; end
            { `RVF7_ANY,  `RVF3_LBU,  `RVOP_LBU  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; resultSrc = 1'b1; dmAlign = `BYTE;        extType = 1'b1; bSize = `EXT8BITS; end

            { `RVF7_ANY,  `RVF3_SW,   `RVOP_SW   } : begin aluSrc = 1'b1; aluControl = `ALU_ADD; immSrc  = 1'b1;  dmAlign = `WORD;      memWrite = 1'b1; opType = 1'b1; extType = 1'b1; end
            { `RVF7_ANY,  `RVF3_SH,   `RVOP_SH   } : begin aluSrc = 1'b1; aluControl = `ALU_ADD; immSrc  = 1'b1;  dmAlign = `HALFWORD;  memWrite = 1'b1; opType = 1'b1; extType = 1'b1; bSize = `EXT16BITS; end
            { `RVF7_ANY,  `RVF3_SB,   `RVOP_SB   } : begin aluSrc = 1'b1; aluControl = `ALU_ADD; immSrc  = 1'b1;  dmAlign = `BYTE;      memWrite = 1'b1; opType = 1'b1; extType = 1'b1; bSize = `EXT8BITS; end
        endcase
    end
endmodule

module sr_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 2:0] oper,
    output        zero,
    output reg [31:0] result
);
    always @ (*) begin
        case (oper)
            default   : result = srcA + srcB;
            `ALU_ADD  : result = srcA + srcB;
            `ALU_OR   : result = srcA | srcB;
            `ALU_SRL  : result = srcA >> srcB [4:0];
            `ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUB : result = srcA - srcB;
        endcase
    end

    assign zero   = (result == 0);
endmodule

module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd0,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule

module sr_extend
(
    input               extType,    //control that defines bit extention mode: zero-ext(1) or sign-ext(0)  
    input       [ 1:0]  bSize,      //controls how much bits must be extended: word (32 bits), halfword (16 bits), byte (8 bits)
    input       [31:0]  dataInExt,
    output reg  [31:0]  dataOutExt
);
    reg [31:0]  mask;

    always @ (*) begin
        case (bSize)
            default     : dataOutExt = dataInExt;

            `EXT8BITS   :   begin 
                mask = {{24{1'b0}},{8{1'b1}}};
                dataOutExt = extType ? (dataInExt & mask) : ({{24{dataInExt[7]}}, dataInExt[7:0]}); 
            end
            
            `EXT16BITS  :   begin 
                mask = {{16{1'b0}},{16{1'b1}}};
                dataOutExt = extType ? (dataInExt & mask) : ({{16{dataInExt[15]}}, dataInExt[15:0]}); 
            end
            
            `EXT32BITS  : dataOutExt = dataInExt;
        endcase
    end
endmodule