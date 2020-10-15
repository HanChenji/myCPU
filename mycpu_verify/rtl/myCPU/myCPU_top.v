

module mycpu_top(
    input            clk,
    input            resetn,            //low active

    output           inst_sram_en,
    output  [ 3:0]   inst_sram_wen,
    output  [31:0]   inst_sram_addr,
    output  [31:0]   inst_sram_wdata,
    input   [31:0]   inst_sram_rdata,

    output           data_sram_en,
    output  [ 3:0]   data_sram_wen,
    output  [31:0]   data_sram_addr,
    output  [31:0]   data_sram_wdata,
    input   [31:0]   data_sram_rdata,

    //debug interface
    output  [31:0]   debug_wb_pc,
    output  [3 :0]   debug_wb_rf_wen,
    output  [4 :0]   debug_wb_rf_wnum,
    output  [31:0]   debug_wb_rf_wdata
);

    wire rst = ~ resetn ;
    wire[31:0] PC;
    wire instRequest;
    wire ifvalid;
 
    wire[31:0] A, B;
    wire[4:0] targetReg;
    wire[31:0] jmpAddr;
    wire[3:0] aluop;
    wire[31:0] storeCont;
    
    wire[1:0] C1;
    wire C3, C5, C6;
    wire[5:0] lsMode;
    wire allowIN;
 
    wire[31:0] A_ex         ;
    wire[31:0] PC_ex        ;
    wire[31:0] B_ex         ;
    wire[4:0]  targetReg_ex ;
    wire[31:0] sotreCont_ex ;
    wire[3:0]  aluop_ex     ;
    wire       C5_ex        ;
    wire[5:0]  lsMode_ex    ;
    wire[31:0] result_ex    ;

    wire[4:0]   targetReg_mem  ;
    wire[31:0]  storeCont_mem  ;
    wire[31:0]  PC_mem         ;
    wire        C5_mem         ;
    wire[5:0]   lsMode_mem     ;
    wire[31:0]  aluResult_mem  ;
    wire[31:0]  data2write     ;
    wire[3:0]   memWen         ;

 
    wire [31:0] PC_wb      ;
    wire C5_wb      ;
    wire[5:0] lsMode_wb  ;
    wire[4:0]  targetReg_wb ;
    wire[31:0] aluResult_wb ;
    wire[31:0] rtCont_wb    ;
    wire[31:0] writeBackData ;



    myCPU_IF IF_module(
        // input
        .clk(clk),
        .rst(rst),
        .offset(jmpAddr),
        .jmp_mode(C1),
        .allow_in(allow_in),
        // output
        .inst_sram_en(inst_sram_en),
        .inst_sram_wen(inst_sram_wen),
        .inst_sram_addr(inst_sram_addr),
        .inst_sram_wdata(inst_sram_wdata),

        .IF2ID_pc()
    );

      
    myCPU_ID ID_module(
        // input
        .clk(clk),
        .rst(rst),
        .IF2ID_pc(),
        .instruction(inst_sram_rdata),

        .wen(C5_wb),
        .wdata(writeBackData),
        .waddr(targetReg_wb),

        .targetRegOfMinus1Inst({ {lsMode_ex [5]}, targetReg_ex  }),
        .targetRegOfMinus2Inst({ {lsMode_mem[5]}, targetReg_mem }),
        .targetRegOfMinus3Inst({ {lsMode_wb [5]}, targetReg_wb  }),

        .ex2mem_cont(result_ex),
        .mem2wb_cont(aluResult_mem),
        .wb_cont(writeBackData),

        // output
        .jmpAddr(jmpAddr),
        .allowIn(allowIn)
        .jmpMode(jmpMode),

        .ID2EXE_op1(),
        .ID2EXE_op2().
        .ID2EXE_pc(),
        .ID2EXE_targetReg(),
        .ID2EXE_storeCont(),
        .ID2EXE_aluOp(),
        .ID2EXE_regfileWen(),
        .ID2EXE_loadStoreMode(),
        .ID2EXE_instValid()
    );

    myCPU_EX EX_module(
        //input
        .A(A_ex),
        .B(B_ex),
        .aluop(aluop_ex),
        //output
        .result(result_ex)
    );

   
    myCPU_MEM MEM_module (
        // input 
        .Mode(lsMode_mem),
        .addrLow2Bit(aluResult_mem[1:0]),
        .storeCont(storeCont_mem),

        // output 
        .memWen(memWen),
        .data2write(data2write)
    );

    myCPU_WB WB_module (
        // input 
        .rtCont(rtCont_wb),
        .aluResult(aluResult_wb),
        .data_sram_rdata(data_sram_rdata),
        .Mode(lsMode_wb),
        //output
        .writeBackData(writeBackData)
    );


endmodule

// by Anlan






