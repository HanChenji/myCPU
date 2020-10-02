

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
        .rst(restn),
        .offset(jmpAddr),
        .jen(C1),
        .allowIN(),
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
    wire[31:0] jmpAddrDisp;
    wire[3:0] aluop;
    wire C2, C3, C4, C5, C6;
    wire[1:0] C1;
   
    myCPU_ID ID_module(
        // input
        .clk(clk),
        .rst(restn),
        .PC(PC),
        .instruction(inst_sram_rdata),

        .wen(),
        .wdata(),
        .waddr(),

        // output
        .A(A),
        .B(B),
        .targetReg(targetReg),
        .jmpAddr(jmpAddr),
        .aluop(aluop),
        .C1(C1),
        //.C2(C2),
        .C3(C3),
        //.C4(C4),
        .C5(C5),
        .C6(C6),
    );


    // ID/EXE pipeline register 
    reg[31:0] ID2EXE_A, ID2EXE_B;
    reg[4:0] ID2EXE_TARGETREG;
    reg[3:0] ID2EXE_ALUOP;
    reg ID2EXE_C3, ID2EXE_C5, ID2EXE_C6;

    always @(posedge clk)
    begin
        ID2EXE_A         <= A;
        ID2EXE_B         <= B;
        ID2EXE_TARGETREG <= targetReg;
        ID2EXE_ALUOP     <= aluop;
        ID2EXE_C3        <= C3;
        ID2EXE_C5        <= C5;
        ID2EXE_C6        <= C6;
    end












