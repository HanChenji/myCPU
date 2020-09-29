
// This module is ID( Instruction Decode)
// The entity of Register File is also contained in this module

/*

   | INSTRUCTION                    | ALUOp |
   ------------------------------------------
   | ADDU, ADDIU, LW, SW, JAL       | 0000  |
   ------------------------------------------
   | SUBU                           | 0001  |
   ------------------------------------------
   | SLT, SLTI                      | 0010  |
   ------------------------------------------
   | SLTU, SLTIU                    | 0011  |
   ------------------------------------------
   | AND, ANDI                      | 0100  |
   ------------------------------------------
   | OR, ORI, LUI                   | 0101  |
   ------------------------------------------
   | XOR, XORI                      | 0110  |
   ------------------------------------------
   | NOR                            | 0111  |
   ------------------------------------------
   | SLLV, SLL                      | 1000  |
   ------------------------------------------
   |                                | 1001  |
   ------------------------------------------
   | SRLV, SRL                      | 1010  |
   ------------------------------------------
   | SRAV, SRA                      | 1011  |
   ------------------------------------------
   | ADD, ADDI                      | 1100  |
   ------------------------------------------
   | SUB                            | 1101  |
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

    input[31:0] PC,
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
    output[31:0] jmpAddr,

    output[3:0] aluop,
    output[1:0] C1,
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
    wire[31:0] zeroExtedIm = {16{0},instruction[15:0]};

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
    wire inst_add   = op==6'b0 && func==6'b100000;
	wire inst_subu  = op==6'b0 && func==6'b100011;
	wire inst_sub   = op==6'b0 && func==6'b100010;
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
    wire inst_jr    = op==6'b0 && func==6'b001000;
    wire inst_ori   = op==6'b001101;
    wire inst_xori  = op==6'b001110;
    wire inst_andi  = op==6'b001100;
	wire inst_sltiu = op==6'b001011;
    wire inst_slti  = op==6'b001010;
	wire inst_addi  = op==6'b001000;
	wire inst_addiu = op==6'b001001;
	wire inst_lw    = op==6'b100011;
	wire inst_sw    = op==6'b101011;
	wire inst_beq   = op==6'b000100;
	wire inst_bne   = op==6'b000101;
	wire inst_blez  = op==6'b000110;
	wire inst_bgtz  = op==6'b000111;
    wire inst_lui   = op==6'b001111;
    wire inst_jal   = op==6'b000011;

	assign C1[0]	= ( inst_beq  & (rsCont == rtCont)  )  |
                      ( inst_bne  & ~(rsCont == rtCont) )  |
                      ( inst_blez & (rsCont[31] == 1)   )  | 
                      ( inst_bgtz & ~(rsCont[31] == 1)  )  |
                        inst_jr                            ; // 1: jump, 0: don't jump
    assign C1[1]    = inst_jal | inst_jr;
    /* C1 == 2'b00 -> no branch
     * C1 == 2'b01 -> branch a offset
     * C1 == 2'b10 -> brach unconditionaly @ {PC[31:28],im,2'b00} // JAL
     * C1 == 2'b11 -> branch @ rtCont // JR
     */

	assign C3 		= inst_lw; // 1: mem->reg 0: alu->reg
	assign C5 		= ~(inst_sw | C1[0]); // reg file wen
	assign C6 		= inst_sw; // mem wen 
	
	wire C4 		= inst_xori | inst_ori | inst_andi | inst_sltiu | inst_slti | inst_addi | inst_addiu | inst_lw | inst_lui; // target reg: 1: rt, 0: rd
    wire C2 		= inst_sltiu | inst_slti | inst_addi | inst_addiu | inst_lw | inst_sw;// 1: im-> B; 0: rt->B
    wire C7         = inst_sll | inst_srl | inst_sra; // 1: ra->A 0: rs->A
       
    assign A = C7       ? unsignExtedRa : 
               inst_jal ? PC            :
                          rscont        ;
    assign B = C2        ? signExtedIm :
               inst_lui  ? upperIm     :
               inst_jal  ? 32'b1000    :
               inst_andi ? zeroExtedIm :
               inst_ori  ? zeroExtedIm :
               inst_xori ? zeroExtedIm :
                           rtcont      ;

    assign targetReg = C4       ? rt       :
                       inst_jal ? 5'b11111 :
                                  rd       ;
    //assign signedImmediate = signExtedIm;
    assign jmpAddr  = C1==2'b01 ? signExtedIm << 2 :
                      C1==2'b10 ? {PC[31:28],instruction[25:0],2'd0} : // JAL
                                  rsCont; // JR

	
    assign aluop[0] = inst_subu | inst_sltu | inst_sltiu | inst_or | inst_ori | inst_lui | inst_nor | inst_srav | inst_sra | inst_sub;
	assign aluop[1] = inst_slti | inst_slt | inst_sltu | inst_sltiu | inst_xor | inst_xori | inst_nor | inst_srlv | inst_srl | inst_srav | inst_sra;
	assign aluop[2] = inst_andi | inst_and | inst_or | inst_ori | inst_lui | inst_xor | inst_xori | inst_nor | inst_add | inst_addi | inst_sub;
	assign aluop[3] = inst_sllv | inst_sll | inst_srlv | inst_srl | inst_srav | inst_sra | inst_add | inst_addi | inst_sub;


endmodule










