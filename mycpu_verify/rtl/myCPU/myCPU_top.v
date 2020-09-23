

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
        .offset(),
        .jen(),
        .allowIN(),
        // output
        .PC(PC),
        .instRequest(instRequest)
    );

    // connect the PC module with the SRAM module 
    assign inst_sram_en = instRequest;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = PC;
    assign inst_sram_wdata = 32'b0;
    
    // IF/ID pipeline register 
    reg[31:0] IF2ID_INSTRUCTION;
/*
    always @(posedge clk)
    begin
        if(instRequest)
            IF2ID_INSTRUCTION <= inst_sram_rdata;
        else
            IF2ID_INSTRUCTION <= IF2ID_INSTRUCTION; 
    end
*/

    always @(posedge clk)
    begin
        IF2ID_INSTRUCTION <= inst_sram_rdata;
    end

    assign instruction = IF2ID_INSTRUCTION;
 
    wire[31:0] instruction;
    wire[31:0] rsCont, rtCont;
    wire[4:0] rd, rt;
    wire[15:0] immediate;
    wire[3:0] aluop;
    wire C1, C2, C3, C4, C5, C6;
   
    myCPU_ID ID_module(
        // input
        .clk(clk),
        .rst(restn),
        .instruction(instruction),
        .wen(),
        .wdata(),
        .waddr(),

        // output
        .rsCont(rsCont),
        .rtCont(rtCont),
        .rd(rd),
        .rd(rt),
        .immediate(immediate),
        .aluop(aluop),
        .C1(C1),
        .C2(C2),
        .C3(C3),
        .C4(C4),
        .C5(C5),
        .C6(C6),
    );


    // ID/EXE pipeline register 
    reg[31:0] ID2EXE_RSCONT, ID2EXE_RTCONT;
    reg[4:0] ID2EXE_RD, ID2EXE_RT;
    reg[15:0] ID2EXE_IMMEDIATE;
    reg[3:0] ID2EXE_ALUOP;
    reg ID2EXE_C1;
    reg ID2EXE_C2;
    reg ID2EXE_C3;
    reg ID2EXE_C4;
    reg ID2EXE_C5;
    reg ID2EXE_C6;

    always @(posedge clk)
    begin
        ID2EXE_RSCONT    <= rsCont;
        ID2EXE_RTCONT    <= rtCont;
        ID2EXE_RD        <= rd;
        ID2EXE_RT        <= rt;
        ID2EXE_IMMEDIATE <= immediate;
        ID2EXE_ALUOP     <= aluop;
        ID2EXE_C1        <= C1;
        ID2EXE_C2        <= C2;
        ID2EXE_C3        <= C3;
        ID2EXE_C4        <= C4;
        ID2EXE_C5        <= C5;
        ID2EXE_C6        <= C6;
    end












