

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

    always @(posedge clk)
    begin
        if(instRequest)
            IF2ID_INSTRUCTION <= inst_sram_rdata;
        else
            IF2ID_INSTRUCTION <= IF2ID_INSTRUCTION;
    end

















