/*
 * Data memory for load/store instructions
 *
 * size -- 32 bits x 64 words
 */ 

module sm_dm    
(   
    input           clk, we,
	input  [31:0]   a, wd,
	output [31:0]   rd
);
								
	reg [31:0] RAM[63:0];
	
	//assign rd = RAM[a[31:2]]; // word aligned
	assign rd = RAM[a[31:0]]; // not word aligned
	
	always @(posedge clk)
	//	if(we) RAM [a[31:2]] <= wd;
		if(we) RAM [a[31:0]] <= wd; // not word aligned
endmodule

//    initial begin
//        $readmemh ("program.hex", rom);
//    end
//https://www.chipverify.com/systemverilog/systemverilog-file-io


//todo 
//1. add partitian data support, not only 32 bits
//2. use a txt file for writing data



