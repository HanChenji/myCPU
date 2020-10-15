


module myCPU_EX(
    input[31:0] A,
    input[31:0] B,
    input[3:0]  aluop,
    //input C5,

    output[31:0] result
    //output C5I
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

    // deal with some exceptions, like overflow errir
    //assign C5I = C5 ? ~overFlow :
    //                  0         ;

    // EXE/MEM pipeline register 
    reg[4:0]  EXE2MEM_targetReg_reg ;
    reg[31:0] EXE2MEM_storeCont_reg ;
    reg[31:0] EXE2MEM_pc_reg        ;
    reg       EXE2MEM_regfileWen_reg        ;
    reg[5:0]  EXE2MEM_loadStoreMode_reg    ;
    reg[31:0] EXE2MEM_aluResult_reg ;
    reg       EXE2MEM_instValid_reg ;
    
    always @(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            EXE2MEM_targetReg_reg   <=   5'b0 ;
            EXE2MEM_storeCont_reg   <=  32'b0 ;
            EXE2MEM_pc_reg          <=  32'b0 ;
            EXE2MEM_regfileWen_reg  <=   1'b0 ;
            EXE2MEM_loadStoreMode   <=   6'b0 ;
            EXE2MEM_aluResult_reg   <=   1'b0 ;
            EXE2MEM_instValid_reg   <=  1'b0  ;
        end
        else
        begin
            EXE2MEM_targetReg_reg   <=  targetReg_ex  ;
            EXE2MEM_storeCont_reg   <=  sotreCont_ex  ;
            EXE2MEM_pc_reg          <=  PC_ex  ;
            EXE2MEM_regfileWen_reg          <=  C5_ex         ;
            EXE2MEM_loadStoreMode_reg      <=  lsMode_ex     ;
            EXE2MEM_aluResult_reg   <=  result_ex     ;
            EXE2MEM_instValid_reg       <= ;
        end
    end

    assign EXE2MEM_targetReg = EXE2MEM_targetReg_reg ;
    assign EXE2MEM_storeCont = EXE2MEM_storeCont_reg ;
    assign EXE2MEM_pc        = EXE2MEM_pc_reg        ;
    assign EXE2MEM_regfileWen  = EXE2MEM_regfileWen_reg ;
    assign EXE2MEM_loadStoreMode = EXE2MEM_loadStoreMode_reg ;
    assign EXE2MEM_aluResult   = EXE2MEM_aluResult_reg ;
    assign EXE2MEM_instValid   = EXE2MEM_instValid_reg ;

endmodule

// by Anlan





