

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

    wire[31:0] instruction;
    wire[31:0] rsCont, rtCont;
    wire[4:0] rd;
    wire[15:0] immediate;
    wire[5:0] ALUop, ALUfunc;

    assign instruction = IF2ID_INSTRUCTION;
    
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
        .immediate(immediate),
        .ALUop(ALUop),
        .ALUfunc(ALUfunc)
    );


    // ID/EXE pipeline register 
    reg[31:0] ID2EXE_RSCONT, ID2EXE_RTCONT;
    reg[4:0] ID2EXE_RD;
    reg[15:0] ID2EXE_IMMEDIATE;
    reg[5:0] ID2EXE_ALUOP, ID2EXE_ALUFUNC;

    always @(posedge clk)
    begin
        ID2EXE_RSCONT <= rsCont;
        ID2EXE_RTCONT <= rtCont;
        ID2EXE_RD <= rd;
        ID2EXE_IMMEDIATE <= immediate;
        ID2EXE_ALUOP <= ALUop;
        ID2EXE_FUNC <= AlUfunc;
    end












