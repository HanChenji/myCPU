


module myCPU_EX(
    input[31:0] A,
    input[31:0] B,
    input[3:0]  aluop,
    input C5,

    output[31:0] result,
    output C5I
);

    
    wire overFlow, carryOut, zero;
    myCPU_alu ALU(
        // input
        .A(A),
        .B(B),
        .ALUop(aluop),
        //output
        .overFlow(overFlow),
        .carryOut(carryOut),
        .zero(zero),
        .aluResult(result)
    );

    assign C5I = C5 ? ~overFlow :
                      0         ;


endmodule







