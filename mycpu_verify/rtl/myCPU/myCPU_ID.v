
// This module is ID( Instruction Decode)
// The entity of Register File is also contained in this module

/*

   ------------------------------------------
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

for the branch instructions:

    C1:
        01: PC <- PC + signExted(offset||00)
        10: PC <- PC[31:28]||inst[25:0]||00
        11: PC <- csCont

   ------------------------------------------
   | insturction                    | C1    |
   ------------------------------------------
   | BEQ,BNE,BGEZ,BGTZ,BLEZ,BLTZ,   |
   | BGEZAL,BLTZAL                  | 01    |
   ------------------------------------------
   | J, JAL                         | 10    |
   ------------------------------------------
   | JR,JALR                        | 11    |
   ------------------------------------------

for the store instructions:    

    C8:     
        C8[0]==1 <- signExted
        C8[0]==0 <- zeroExted 
        C8[3:1]:
                000  ->  Byte
                001  ->  Half Word 
                010  ->  Word
                011  ->  WL
                100  ->  WR
        C8[4]: Store?
        C8[5]: Load?

*/



module myCPU_ID (
    // input
    input clk,
    input rst,

    input[31:0] IF2ID_pc,
    input[31:0] instruction,

    input wen,
    input[31:0] wdata,
    input[4:0] waddr,

    input[5:0] targetRegOfMinus1Inst,
    input[5:0] targetRegOfMinus2Inst,
    input[5:0] targetRegOfMinus3Inst,

    input[31:0] ex2mem_cont,
    input[31:0] mem2wb_cont,
    input[31:0] wb_cont,
   
    // output
    output[31:0] jmpAddr,
    output [1:0] jmp_mode,
    output allowIn,

    output [31:0] ID2EXE_op1,
    output [31:0] ID2EXE_op2,
    output [31:0] ID2EXE_pc,
    output [ 4:0] ID2EXE_targetReg,
    output [31:0] ID2EXE_storeCont,
    output [ 3:0] ID2EXE_aluOp,
    output        ID2EXE_regfileWen,
    output [ 5:0] ID2EXE_loadStoreMode,
    output        ID2EXE_instValid
  );

    wire[31:0] A;
    wire[31:0] B;
    wire[4:0] targetReg;
    wire[31:0] storeCont;
    wire [3:0] aluop;
    wire  regfileWen;
    wire [5:0] loadStoreMode;



    wire[5:0] op    = instruction[31:26];
    wire[5:0] func  = instruction[5:0];
    wire[4:0] rs    = instruction[25:21];
    wire[4:0] rt    = instruction[20:16];
    wire[4:0] rd    = instruction[15:11];
    wire[4:0] ra    = instruction[10:6];
    
    wire[31:0] signExtedIm = { {17{instruction[15]}}, instruction[14:0] };
    wire[31:0] unsignExtedIm = { {16{1'b0}}, instruction[15:0] };
    wire[31:0] unsignExtedRa = { {27{1'b0}}, ra };
    wire[31:0] upperIm = {instruction[15:0], {16{1'b0}} };
    wire[31:0] zeroExtedIm = { {16{1'b0}} ,instruction[15:0] };

    wire[31:0] rsCont_, rtCont_;
    wire[31:0] rsCont, rtCont;
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
        .rdata1(rsCont_),
        .rdata2(rtCont_)
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
    wire inst_srav  = op==6'b0 && func==6'b000111;
    wire inst_sra   = op==6'b0 && func==6'b000011;
    wire inst_ori   = op==6'b001101;
    wire inst_xori  = op==6'b001110;
    wire inst_andi  = op==6'b001100;
    wire inst_sltiu = op==6'b001011;
    wire inst_slti  = op==6'b001010;
    wire inst_addi  = op==6'b001000;
    wire inst_addiu = op==6'b001001;
    wire inst_lui   = op==6'b001111;

    wire inst_lb    = op==6'b100000;
    wire inst_lbu   = op==6'b100100;
    wire inst_lh    = op==6'b100001;
    wire inst_lhu   = op==6'b100101;
    wire inst_lw    = op==6'b100011;
    wire inst_lwl   = op==6'b100010;
    wire inst_lwr   = op==6'b100010;

    wire inst_sb    = op==6'b101000;
    wire inst_sh    = op==6'b101001;
    wire inst_sw    = op==6'b101011;
    wire inst_swl   = op==6'b101010;
    wire inst_swr   = op==6'b101110;
    
    
    wire inst_beq_    = op==6'b000100 ;
    wire inst_bne_    = op==6'b000101 ;
    wire inst_bgez_   = op==6'b000001 && rt==5'b00001 ;
    wire inst_bgtz_   = op==6'b000111 && rt==5'b00000 ;
    wire inst_blez_   = op==6'b000110 && rt==5'b00000 ;
    wire inst_bltz_   = op==6'b000001 && rt==5'b00000 ;
    wire inst_bgezal_ = op==6'b000001 && rt==5'b10001 ;
    wire inst_bltzal_ = op==6'b000001 && rt==5'b10000 ;

    wire inst_j     = op==6'b000010;
    wire inst_jal   = op==6'b000011;
    wire inst_jr    = op==6'b000000 && instruction[20:0]=={ {17{1'b0}}, {4'b1000} };
    wire inst_jalr  = op==6'b000000 && rt==5'b00000 && ra==5'b00000 && func==5'b001001;


    wire rsValid = ~(inst_lui||inst_sll||inst_sra||inst_srl||inst_j||inst_jal);
    wire rtValid = ~(inst_addi||inst_addiu||inst_slti||inst_sltiu||inst_andi||inst_lui||inst_ori||inst_xori||inst_bgez_||inst_bgtz_||inst_blez_||inst_bltz_||inst_bgezal_||inst_bltzal_||inst_j||inst_jal||inst_jr||inst_jalr||inst_lb||inst_lbu||inst_lh||inst_lhu||inst_lw||inst_lwl||inst_lwr);

   // next codes are for the bypass 
   wire PAUSE1 = ( rs==targetRegOfMinus1Inst[4:0]   && rsValid && targetRegOfMinus1Inst[5] ) || ( rt==targetRegOfMinus1Inst[4:0] && rtValid && targetRegOfMinus1Inst[5] ) ;
   wire PAUSE2 = ( rs==targetRegOfMinus2Inst[4:0]   && rsValid && targetRegOfMinus2Inst[5] ) || ( rt==targetRegOfMinus2Inst[4:0] && rtValid && targetRegOfMinus2Inst[5] ) ;
   wire PAUSE = PAUSE1 || PAUSE2 ;

   assign rsCont = (PAUSE                                                                  ) ? {32{1'b0}}  : // stall
                   (rs==targetRegOfMinus1Inst[4:0] && rsValid && ~targetRegOfMinus1Inst[5] ) ? ex2mem_cont :
                   (rs==targetRegOfMinus2Inst[4:0] && rsValid && ~targetRegOfMinus2Inst[5] ) ? mem2wb_cont :
                   (rs==targetRegOfMinus3Inst[4:0] && rsValid                              ) ? wb_cont     :
                                                                                               rsCont_     ;

   assign rtCont = (PAUSE                                                                  ) ? {32{1'b0}}  : // stall
                   (rt==targetRegOfMinus1Inst[4:0] && rtValid && ~targetRegOfMinus1Inst[5] ) ? ex2mem_cont :
                   (rt==targetRegOfMinus2Inst[4:0] && rtValid && ~targetRegOfMinus2Inst[5] ) ? mem2wb_cont :
                   (rt==targetRegOfMinus3Inst[4:0] && rtValid                              ) ? wb_cont     :
                                                                                               rtCont_     ;
 
    wire inst_beq    = inst_beq_    && (rsCont==rtCont);
    wire inst_bne    = inst_bne_    && ~(rsCont==rtCont);
    wire inst_bgez   = inst_bgez_   && ~(rsCont[31]==1);
    wire inst_bgtz   = inst_bgtz_   && (rsCont[31]==0&&(~(rsCont==0)));
    wire inst_blez   = inst_blez_   && (rsCont==0||rsCont[31]==1);
    wire inst_bltz   = inst_bltz_   && rsCont[31]==1;
    wire inst_bgezal = inst_bgezal_ && (~(rsCont[31]==1));
    wire inst_bltzal = inst_bltzal_ && rsCont[31]==1;



/***********************************************************************/



    wire CLoad  = inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_lwl | inst_lwr ;
    wire CStore = inst_sb | inst_sh  | inst_sw | inst_swl | inst_swr ; 

    assign loadStoreMode[0] = inst_lb  | inst_lh  ;

    assign loadStoreMode[1] = inst_lh  | inst_lhu | 
                                inst_lwl |          
                                inst_sh  | inst_swl ; 

    assign loadStoreMode[2] = inst_lw  | inst_lwl |
                                inst_sw  | inst_swl ;

    assign loadStoreMode[3] = inst_lwr | inst_swr ;

    assign loadStoreMode[4] = CStore;
    assign loadStoreMode[5] = CLoad;

    assign jmp_mode[0] = inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal |
                   inst_jr  | inst_jalr ; 
    assign jmp_mode[1] = inst_j | inst_jal | inst_jr | inst_jalr;


    //assign C3         = CLoad; // 1: mem->reg 0: alu->reg
    assign regfileWen  = ~(CStore | inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_j | inst_jr ); // reg file wen
    //assign C6         = CStore; // mem wen 
    
    wire C4         = inst_xori | inst_ori | inst_andi | inst_sltiu | inst_slti | inst_addi | inst_addiu | CLoad | inst_lui; // target reg: 1: rt, 0: rd
    wire C2         = inst_sltiu | inst_slti | inst_addi | inst_addiu | CLoad | CStore;// 1: im-> B; 0: rt->B
    wire C7         = inst_sll | inst_srl | inst_sra; // 1: ra->A 0: rs->A

    wire branchL31 = inst_bgezal | inst_bltzal |  inst_jal ;
    wire branchLRd = inst_jalr ;
       
    assign A = C7        ? unsignExtedRa : 
               branchL31 ? PC            :
               branchLRd ? PC            :
                           rsCont        ;
    assign B = C2        ? signExtedIm :
               inst_lui  ? upperIm     :
               branchL31 ? { {28{1'b0}}, {4'b1000} } :
               branchLRd ? { {28{1'b0}}, {4'b1000} } :
               inst_andi ? zeroExtedIm :
               inst_ori  ? zeroExtedIm :
               inst_xori ? zeroExtedIm :
                           rtCont      ;

    wire[4:0] targetReg;
    assign targetReg = C4        ? rt       :
                       branchL31 ? 5'b11111 :
                       branchLRd ? rd       :
                                   rd       ;
    //assign signedImmediate = signExtedIm;
    assign jmpAddr  = C1==2'b01 ? signExtedIm << 2 :
                      C1==2'b10 ? { PC[31:28],instruction[25:0],{2'b00} } : 
                      C1==2'b11 ? rsCont :
                                  {32{1'b0}};

    
    assign aluop[0] = inst_subu | inst_sltu | inst_sltiu | inst_or | inst_ori | inst_lui | inst_nor | inst_srav | inst_sra | inst_sub;
    assign aluop[1] = inst_slti | inst_slt | inst_sltu | inst_sltiu | inst_xor | inst_xori | inst_nor | inst_srlv | inst_srl | inst_srav | inst_sra;
    assign aluop[2] = inst_andi | inst_and | inst_or | inst_ori | inst_lui | inst_xor | inst_xori | inst_nor | inst_add | inst_addi | inst_sub;
    assign aluop[3] = inst_sllv | inst_sll | inst_srlv | inst_srl | inst_srav | inst_sra | inst_add | inst_addi | inst_sub;

    assign storeCont = rtCont;

    assign allowIn = ~PAUSE ; 

    wire readGo = ~PAUSE ;
 
    // ID/EXE pipeline register 
    reg [31:0] ID2EXE_a_reg, ID2EXE_b_reg;
    reg [31:0] ID2EXE_pc_reg             ;
    reg [ 4:0] ID2EXE_targetReg_reg      ;
    reg [31:0] ID2EXE_storeCont_reg      ;
    reg [ 3:0] ID2EXE_aluOp_reg          ;
    reg        ID2EXE_regfileWen_reg     ;
    reg [ 5:0] ID2EXE_loadStoreMode_reg  ;
    reg        ID2EXE_instValid_reg      ;

    always @(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            ID2EXE_pc_reg             <= 32'b0   ;
            ID2EXE_a_reg              <= 32'b0   ;
            ID2EXE_b_reg              <= 32'b0   ;
            ID2EXE_targetReg_reg      <=  5'b0   ;
            ID2EXE_storeCont_reg      <= 32'b0   ;
            ID2EXE_aluOp_reg          <=  4'b0   ;
            ID2EXE_regfileWen_reg     <=  1'b0   ;
            ID2EXE_loadStoreMode_reg  <=  6'b0   ;
            ID2EXE_instValid_reg      <=  1'b0   ;
        end
        else
        begin
            if(readyGo)
            begin
                ID2EXE_pc_reg             <= PC         ;
                ID2EXE_a_reg              <= A          ;
                ID2EXE_b_reg              <= B          ;
                ID2EXE_targetReg_reg      <= targetReg  ;
                ID2EXE_storeCont_reg      <= storeCont  ;
                ID2EXE_aluOp_reg          <= aluop      ;
                ID2EXE_loadStoreMode_reg  <= loadStoreMode;
                ID2EXE_regfileWen_reg     <= regfileWen ;
            end
            ID2EXE_instValid_reg          <= ~PAUSE   ;
        end
    end  

    assign ID2EXE_op1 = ID2EXE_a_reg;
    assign ID2EXE_op2 = ID2EXE_b_reg;
    assign ID2EXE_pc  = ID2EXE_pc_reg   ;
    assign ID2EXE_targetReg = ID2EXE_targetReg_reg      ;
    assign ID2EXE_storeCont = ID2EXE_storeCont_reg      ;
    assign ID2EXE_aluOp = ID2EXE_aluOp_reg          ;
    assign ID2EXE_regfileWen = ID2EXE_regfileWen_reg      ;
    assign ID2EXE_loadStoreMode = ID2EXE_loadStoreMode_reg  ;
    assign ID2EXE_instValid = ID2EXE_instValid_reg ;




endmodule

// by Anlan








