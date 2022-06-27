/*
 * Data memory for load/store instructions
 */ 

`include "sr_cpu.vh"

module sm_dm    
(   
    input               clk, 
	input  			    we,
	input      [ 1:0]	da, // data alignment
	input      [31:0]   a, wd,
	output reg [31:0]   rd
);
								
	reg [31:0] RAM[63:0];
	
    always @ (*) begin
        case (da)
            default   	: rd = RAM[a[31:2]]; // load word (32 bits) 
            `WORD  		: rd = RAM[a[31:2]]; // load word (32 bits)  
			`HALFWORD	: rd = RAM[a[31:2]][ {a[1], 4'b0000} +: 16]; // load halfword (16 bits) 
            `BYTE  		: rd = RAM[a[31:2]][ {a[1:0], 3'b000} +: 8]; // load byte (8 bits) 
        endcase
    end
	
	always @(posedge clk)
		casez({we, da})
    		{1'b1,  `WORD}:		RAM[a[31:2]] = wd; // store word (32 bits) 
    		{1'b1,  `HALFWORD}:	RAM[a[31:2]][ {a[1], 4'b0000} +: 16] = wd[15:0]; // store halfword (16 bits) 
    		{1'b1,  `BYTE}: 	RAM[a[31:2]][ {a[1:0], 3'b000} +: 8] = wd[7:0]; // store byte (8 bits) 
		endcase
endmodule