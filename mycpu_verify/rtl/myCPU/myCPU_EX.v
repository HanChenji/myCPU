


module myCPU_EX(
    input[31:0] rsCont,
    input[31:0] rtCont,
    input[4:0]  rd,
    input[4:0]  rt,
    input[15:0] immediate,
    input[3:0]  aluop,

    output , // ?


);

    
    wire overFlow, carryOut, zero;
    wire[31:0] aluResult;
    myCPU_alu ALU(
        // input
        .A(rsCont),
        .B(rtCont),
        .ALUop(aluop),
        //output
        .overFlow(overFlow),
        .carryOut(carryOut),
        .zero(zero),
        .aluResult(aluResult)
    );























endmodule







