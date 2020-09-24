
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
    output[31:0] A,
    output[31:0] B,
	//output[4:0] rt,
	output[4:0] targetReg,
    //output[31:0] signedImmediate,
    output[31:0] jmpAddrDisp,

    output[3:0] aluop,
    output C1,
    output C2,
    output C3,
    output C4,
    output C5,
    output C6
);

    wire op         = instruction[31:26];
    wire func       = instruction[5:0];
    wire rs       = instruction[:];
    wire rt       = instruction[:];
    wire rd       = instruction[:];
	
    wire signExtedIm = { {17{instruction[15]}}, instruction[14:0] };
    wire unsignExtedIm = { 16'd0, instruction[15:0] )};

    wire[31:0] rscont, rtcont;
	myCPU_regFile regFile(
    	//input
    	.raddr1(rs), // addr of rs
    	.raddr2(rt), // addr of rt
    	.wen(wen),
    	.waddr(waddr),
    	.wdata(wdata), 
    	.rst(rst),
    	.clk(clk),
    	//output
    	.rdata1(rscont),
    	.rdata2(rtcont)
    );

    wire inst_addu  = op==6’b0 && func==6’b100001;
	wire inst_subu  = op==6’b0 && func==6’b100010;
	wire inst_slt   = op==6’b0 && func==6’b101010;
	wire inst_sltu  = op==6’b0 && func==6’b101011;
	wire inst_and   = op==6’b0 && func==6’b100100;
	wire inst_or    = op==6’b0 && func==6’b100101;
	wire inst_xor   = op==6’b0 && func==6’b100110;
	wire inst_nor   = op==6’b0 && func==6’b100111;
	wire inst_sllv  = op==6’b0 && func==6’b000100;
	wire inst_srlv  = op==6’b0 && func==6’b000110;
	wire inst_srav 	= op==6’b0 && func==6’b000111;
	wire inst_addiu = op==6’b001001;
	wire inst_lw    = op==6’b100011;
	wire inst_sw    = op==6’b101011;
	wire inst_beq   = op==6’b000100;
	wire inst_bne   = op==6’b000101;
	wire inst_blez  = op==6’b000110;
	wire inst_bgtz  = op==6’b000111;

	assign C1 		= ( inst_beq  & (rsCont == rtCont)  )  |
                      ( inst_bne  & ~(rsCont == rtCont) )  |
                      ( inst_blez & (rsCont[31] == 1)   )  | 
                      ( inst_bgtz & ~(rsCont[31] == 1)  )  ;
	assign C2 		= inst_addiu | inst_lw | inst_sw;
	assign C3 		= inst_addiu | inst_lw;
	assign C4 		= inst_lw;
	assign C5 		= ~(inst_sw | C1);
	assign C6 		= inst_sw;
       
    assign A = rscont;
    assign B = C2 ?  signExtedIm : rtcont;
    assign targetReg = C4 ? rt : rd;
    //assign signedImmediate = signExtedIm;
    assign jmpAddrDisp = signExtedIm << 2 ;
	
    assign aluop[0] = inst_subu | inst_sltu | inst_or | inst_nor | inst_srav;
	assign aluop[1] = inst_slt | inst_sltu | inst_xor | inst_nor | inst_srlv | inst_srav;
	assign aluop[2] = inst_and | inst_or | inst_xor | inst_nor;
	assign aluop[3] = inst_sllv | inst_srlv | inst_srav;


endmodule







