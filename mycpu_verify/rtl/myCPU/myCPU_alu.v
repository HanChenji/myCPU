

`define DATA_WIDTH 32

module myCPU_alu(
    input [`DATA_WIDTH - 1:0] A,
    input [`DATA_WIDTH - 1:0] B,
    input [3:0] ALUop,

    output overFlow,
    output carryOut,
    output zero,
    output [`DATA_WIDTH - 1:0] aluResult
);


    wire[32:0] Operand1Bit33, Operand2Bit33;

    assign Operand1Bit33 = (ALUop==4'b0010)            ? {1'b0,~A[31],A[30:0]} : // SLT 
                           (ALUop== || ALUop==4'b****) ? {1'b0, A[31:0]}       : // carryout for ADD and SUB || overflow for ADD and SUB|| carryout for SLTU
                                                                                33'b0;

    assign Operand2Bit33 = (ALUop==4'b0010)                   ? (~{1'b0,~B[31],B[30:0]}+1) : // SLT 
                           (ALUop==4'b____ || ALUop==4'b____) ? {1'b0,B[31:0]}             : // carryout for ADD || overflow for ADD
                           (ALUop==4'b____ || ALUop==4'b____) ? (~{1'b0,B[31:0]}+1)        : // carryout for SUB || overflow for SUB || carryout for SLTU 
                                                                                            33'b0;
    wire[32:0] Bit33Add = Operand1Bit33 + Operand2Bit33 ;
    
    wire[31:0] Operand1Bit32, Operand2Bit32;

    assign Operand1Bit32 = (ALUop==4'b____ || ALUop==4'b____) ? {1'b0,A[30:0]} : // overflow for SUB and ADD 
                                                                                A ;

    assign Operand2Bit32 = (ALUop==4'b____) ? {1'b0,B[30:0]}      : // overflow for ADD 
                           (ALUop==4'b____) ? (~{1'b0,B[30:0]}+1) : // overflow for SUB
                           (ALUop==4'b____) ? (~B+1)              : // SUBU
                                                                   B ; // ADDU

    wire[31:0] Bit32Add = Operand1Bit32 + Operand2Bit32 ;


    assign overFlow = (ALUop==4'b____||ALUop==4'b____) ? Bit33Add[32] ^ Bit32Add[31] : 0 ;
    assign carryout = (ALUop==4'b____||ALUop==4'b____) ? Bit33Add[32] : 0 ;


    wire[4:0] shiftCont = A[4:0] ; // SLL 
    wire[31:0] sra_operand = B[31] ? ~({32{1}}>>shiftCont) :
                                     {32{0}}               ;


    assign aluResult = (ALUop==4'b____||ALUop==4'b____) ? Bit32Add : // ADDU || SUBU
                       (ALUop==4'b____)                 ? Bit33Add[31:0] : // ADD || SUB
                       (ALUop==4'b____)                 ? {31{0},Bit33Add[32]} : // SLT
                       (ALUop==4'b____)                 ? {31{0},carryout} :   // SLTU
                       (ALUop==4'b____)                 ? (A|B) : // OR
                       (ALUop==4'b____)                 ? (A&B) : // AND
                       (ALUop==4'b____)                 ? (A^B) : // XOR
                       (ALUop==4'b____)                 ? ~(A|B) : // NOR
                       (ALUop==4'b____)                 ? B<<shiftCont : // SLL || SLLV
                       (ALUop==4'b____)                 ? B>>shiftCont : // SRL || SRLV
                       (ALUop==4'b____)                 ? (sra_operand | (B>>shiftCont) ) : // SRA || SRAV








endmodule







