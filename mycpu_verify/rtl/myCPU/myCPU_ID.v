
// This module is ID( Instruction Decode)
// The entity of Register File is also contained in this module

/*

   | INSTRUCTION                    | ALUOp |
   ------------------------------------------
   | ADDU, ADDIU, LW, SW            | 0000  |
   ------------------------------------------
   | SUBU                           | 0001  |
   ------------------------------------------
   | SLT                            | 0010  |
   ------------------------------------------
   | SLTU                           | 0011  |
   ------------------------------------------
   | AND                            | 0100  |
   ------------------------------------------
   | OR, LUI                        | 0101  |
   ------------------------------------------
   | XOR                            | 0110  |
   ------------------------------------------
   | NOR                            | 0111  |
   ------------------------------------------
   | SLLV                           | 1000  |
   ------------------------------------------
   |                                | 1001  |
   ------------------------------------------
   | SRLV                           | 1010  |
   ------------------------------------------
   | SRAV                           | 1011  |
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------
   ------------------------------------------













*/



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
    //output C2,
    output C3,
    //output C4,
    output C5,
    output C6
);

    wire[5:0] op    = instruction[31:26];
    wire[5:0] func  = instruction[5:0];
    wire[4:0] rs    = instruction[25:21];
    wire[4:0] rt    = instruction[20:16];
    wire[4:0] rd    = instruction[15:11];
    wire[4:0] ra    = instruction[10:6];
	
    wire[31:0] signExtedIm = { {17{instruction[15]}}, instruction[14:0] };
    wire[31:0] unsignExtedIm = { 16'd0, instruction[15:0] )};
    wire[31:0] unsignExtedRa = { 27'd0, ra };
    wire[31:0] upperIm = {instruction[15:0],16{0}};

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

    wire inst_addu  = op==6'b0 && func==6'b100001;
	wire inst_subu  = op==6'b0 && func==6'b100010;
	wire inst_slt   = op==6'b0 && func==6'b101010;
	wire inst_sltu  = op==6'b0 && func==6'b101011;
	wire inst_and   = op==6'b0 && func==6'b100100;
	wire inst_or    = op==6'b0 && func==6'b100101;
	wire inst_xor   = op==6'b0 && func==6'b100110;
	wire inst_nor   = op==6'b0 && func==6'b100111;
	wire inst_sllv  = op==6'b0 && func==6'b000100;
	wire inst_sll   = op==6'b0 && func==6'b000000;
	wire inst_srlv  = op==6'b0 && func==6'b000110;
	wire inst_srl   = op==6'b0 && func==6'b000010;
	wire inst_srav 	= op==6'b0 && func==6'b000111;
	wire inst_sra 	= op==6'b0 && func==6'b000011;
	wire inst_addiu = op==6'b001001;
	wire inst_lw    = op==6'b100011;
	wire inst_sw    = op==6'b101011;
	wire inst_beq   = op==6'b000100;
	wire inst_bne   = op==6'b000101;
	wire inst_blez  = op==6'b000110;
	wire inst_bgtz  = op==6'b000111;
    wire inst_lui   = op==6'b001111;

	assign C1 		= ( inst_beq  & (rsCont == rtCont)  )  |
                      ( inst_bne  & ~(rsCont == rtCont) )  |
                      ( inst_blez & (rsCont[31] == 1)   )  | 
                      ( inst_bgtz & ~(rsCont[31] == 1)  )  ; // 1: jump, 0: don't jump
	assign C3 		= inst_lw; // 1: mem->reg 0: alu->reg
	assign C5 		= ~(inst_sw | C1); // reg file wen
	assign C6 		= inst_sw; // mem wen 
	
	wire C4 		= inst_addiu | inst_lw | inst_lui; // target reg: 1: rt, 0: rd
    wire C2 		= inst_addiu | inst_lw | inst_sw;// 1: im-> B; 0: rt->B
    wire C7         = inst_sll | inst_srl | inst_sra; // 1: ra->A 0: rs->A
       
    assign A = C7 ? unsignExtedRa : 
                    rscont        ;
    assign B = C2       ? signExtedIm :
               inst_lui ? upperIm     :
                          rtcont      ;

    assign targetReg = C4 ? rt : rd;
    //assign signedImmediate = signExtedIm;
    assign jmpAddrDisp = signExtedIm << 2 ;
	
    assign aluop[0] = inst_subu | inst_sltu | inst_or | inst_lui | inst_nor | inst_srav | inst_sra;
	assign aluop[1] = inst_slt | inst_sltu | inst_xor | inst_nor | inst_srlv | inst_srl | inst_srav | inst_sra;
	assign aluop[2] = inst_and | inst_or | inst_lui | inst_xor | inst_nor;
	assign aluop[3] = inst_sllv | inst_sll | inst_srlv | inst_srl | inst_srav | inst_sra;


endmodule

// LUI: {32{0}} | upperIm -> rt 









