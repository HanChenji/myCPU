

module myCPU_top(
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

    wire[31:0] PC;
    wire instRequest;

    myCPU_IF IF_module(
        // input
        .clk(clk),
        .rst(resetn),
        .offset(jmpAddr),
        .jen(C1),
        .allowIN(allowIN),
        // output
        .inst_sram_en(inst_sram_en),
        .inst_sram_addr(PC),
    );

    // connect the PC module with the SRAM module 
    assign inst_sram_addr = PC;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;
    
    wire[31:0] A, B;
    wire[4:0] targetReg;
    wire[31:0] jmpAddr;
    wire[3:0] aluop;
    wire[31:0] storeCont;
    
    wire[1:0] C1;
    wire C3, C5, C6;
    wire[5:0] lsMode;
    wire allowIN;
  
    myCPU_ID ID_module(
        // input
        .clk(clk),
        .rst(resetn),
        .PC(PC),
        .instruction(inst_sram_rdata),

        .wen(C5_wb),
        .wdata(writeBackData_wb),
        .waddr(targetReg_wb),

        .tRegOfMinus1Inst(tRegOfMinus1Inst),
        .tRegOfMinus2Inst(tRegOfMinus2Inst),
        .tRegOfMinus3Inst(tRegOfMinus3Inst),
   
        .ex2mem_cont(result_ex),
        .mem2wb_cont(writeBackData),
        .wb_cont(writeBackData_wb),

        // output
        .A(A),
        .B(B),
        .targetReg_(targetReg),
        .jmpAddr(jmpAddr),
        .storeCont(storeCont),

        .aluop(aluop),
        .C1_(C1),
        //.C2(C2),
        //.C3(C3),
        //.C4(C4),
        .C5_(C5),
        //.C6(C6),
        .C8_(lsMode),
        .allowIN(allowIN)
    );
 
    wire[5:0] tRegOfMinus1Inst;
    wire[5:0] tRegOfMinus2Inst;
    wire[5:0] tRegOfMinus3Inst;
    
    myCPU_board board(
        // input
        .clk(clk),
        .rst(resetn),
        .targetReg(targetReg),
        .instType(lsMode[5]),
        // output
        .tRegOfMinus1Inst(tRegOfMinus1Inst),
        .tRegOfMinus2Inst(tRegOfMinus2Inst),
        .tRegOfMinus3Inst(tRegOfMinus3Inst)
    );



    // ID/EXE pipeline register 
    reg[31:0] ID2EXE_A, ID2EXE_B;
    reg[4:0] ID2EXE_TARGETREG;
    reg[31:0] ID2EXE_STORECONT;
    reg[3:0] ID2EXE_ALUOP;
    //reg ID2EXE_C3, ID2EXE_C5; // ID2EXE_C6;
    reg ID2EXE_C5; // ID2EXE_C6;
    reg[5:0] ID2EXE_LSMODE;

    always @(posedge clk)
    begin
        ID2EXE_A         <= A;
        ID2EXE_B         <= B;
        ID2EXE_TARGETREG <= targetReg;
        ID2EXE_STORECONT <= storeCont;
        ID2EXE_ALUOP     <= aluop;
        //ID2EXE_C3        <= C3;
        ID2EXE_C5        <= C5;
        //ID2EXE_C6        <= C6;
        ID2EXE_LSMODE    <= lsMode;
    end // bypass ? 

    wire[31:0] A_ex = ID2EXE_A;
    wire[31:0] B_ex = ID2EXE_B;
    wire[4:0]  targetReg_ex = ID2EXE_TARGETREG;
    wire[31:0] sotreCont_ex = ID2EXE_STORECONT;
    wire[3:0]  aluop_ex = ID2EXE_ALUOP;
    wire       C5_ex = ID2EXE_C5;
    wire[5:0]  lsMode_ex = ID2EXE_LSMODE;

    wire[31:0] result_ex;

    myCPU_EX EX_module(
        //input
        .A(A_ex),
        .B(B_ex),
        .aluop(aluop_ex),
        //output
        .result(result_ex)
    );


    // EXE/MEM pipeline register 
    reg[4:0]  EXE2MEM_TARGETREG;
    reg[31:0] EXE2MEM_STORECONT;
    reg       EXE2MEM_C5;
    reg[5:0]  EXE2MEM_LSMODE;
    reg[31:0] EXE2MEM_ALURESULT;
    
    always @(posedge clk)
    begin
        EXE2MEM_TARGETREG   <=  targetReg_ex  ;
        EXE2MEM_STORECONT   <=  sotreCont_ex  ;
        EXE2MEM_C5          <=  C5_ex         ;
        EXE2MEM_LSMODE      <=  lsMode_ex     ;
        EXE2MEM_ALURESULT   <=  result_ex     ;
    end


    wire[4:0]   targetReg_mem = EXE2MEM_TARGETREG;
    wire[31:0]  storeCont_mem = EXE2MEM_STORECONT;
    wire        C5_mem        = EXE2MEM_C5;
    wire[5:0]   lsMode_mem    = EXE2MEM_LSMODE;
    wire[31:0]  aluResult_mem = EXE2MEM_ALURESULT;
    wire[31:0]  dataLoaded;

    assign data_sram_en = lsMode_mem[5] || lsMode_mem[4] ;
    assign data_sram_addr = aluResult_mem;

    myCPU_MEM MEM_module (
        // input 
        .Mode(lsMode_mem[4:0]),
        .data_sram_rdata(data_sram_rdata),
        .wCont(storeCont_mem),

        // output 
        .data_sram_wen(data_sram_wen),
        .data_sram_wdata(data_sram_wdata),
        .dataLoaded(dataLoaded)
    );

    wire[31:0] writeBackData = lsMode_mem[5] ? dataLoaded : aluResult_mem ;

    // MEM/WB pipeline register 
    reg       MEM2WB_C5;
    reg[31:0] MEM2WB_WRITEBACKDATA;
    reg[4:0]  MEM2WB_TARGETREG;

    always @(posedge clk)
    begin
        MEM2WB_C5            <=  C5_mem;
        MEM2WB_WRITEBACKDATA <=  writeBackData;
        MEM2WB_TARGETREG     <=  targetReg_mem;
    end

    wire C5_wb = MEM2WB_C5 ;
    wire[31:0] writeBackData_wb = MEM2WB_WRITEBACKDATA ;
    wire[4:0]  targetReg_wb  = MEM2WB_TARGETREG  ;







endmodule










