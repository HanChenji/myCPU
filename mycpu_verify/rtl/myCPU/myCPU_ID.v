
// This module is ID( Instruction Decode)
// The entity of Register File is also contained in this module

module myCPU_ID (
    // input
	input clk,
	input rst,

    input[31:0] instruction,

    input wen,
    input[31:0] wdata,
	input[4:0] waddr,

    // output
    output[31:0] rsCont,
    output[31:0] rtCont,
	output[4:0] rd,
    output[15:0] immediate,
    output[5:0] ALUop,
	output[5:0] ALUfunc
);

	wire[31:0] rscont, rtcont;
    
	myCPU_regFile regFile(
    	//input
    	.raddr1(instruction[:]), // addr of rs
    	.raddr2(instruction[:]), // addr of rt
    	.wen(wen),
    	.waddr(waddr),
    	.wdata(wdata), 
    	.rst(rst),
    	.clk(clk),
    	//output
    	.rdata1(rscont),
    	.rdata2(rtcont)
    );

    assign rsCont = rscont;
	assign rtCont = rtcont;
    assign rd = instruction[:];
    assign immediate = instruction[:];
    assign ALUop = instruction[:];
    assign ALUfunc = instruction[:];

endmodule







