

/* lwl & lwr inst:
 *       join rtCont and data_sram_rdata according to the addrLow2Bit
 */

module myCPU_WB (
    input[31:0] rtCont,
    input[31:0] aluResult,
    input[31:0] data_sram_rdata,
    input[5 :0] Mode,

    output[31:0] writeBackData
);

    wire[1:0] addrLow2Bit = aluResult[1:0] ;

    wire[31:0] lwlRawData = (addrLow2Bit==2'b00) ? {data_sram_rdata[7:0],rtCont[23:0]}  :
                            (addrLow2Bit==2'b01) ? {data_sram_rdata[15:0],rtCont[15:0]} :
                            (addrLow2Bit==2'b10) ? {data_sram_rdata[23:0],rtCont[7:0]}  :
                                                    data_sram_rdata                     ;

    wire[31:0] lwrRawData = (addrLow2Bit==2'b00) ?  data_sram_rdata                       :
                            (addrLow2Bit==2'b01) ? {rtCont[31:24],data_sram_rdata[31:8]}  :
                            (addrLow2Bit==2'b10) ? {rtCont[31:16],data_sram_rdata[31:16]} :
                                                   {rtCont[31:8] ,data_sram_rdata[31:24]} ;
                            
    
    wire[2:0] sizeMode = Mode[3:1];
    wire      signExt  = Mode[0]  ;

    wire[31:0] dataLoaded =    (sizeMode==3'b000 && signExt  ) ? { {24{data_sram_rdata[7]}}, data_sram_rdata[7:0] }   :
                               (sizeMode==3'b000 && ~signExt ) ? { {24'b0}, data_sram_rdata[7:0] }                    :
                               (sizeMode==3'b001 && signExt  ) ? { {16{data_sram_rdata[15]}}, data_sram_rdata[15:0] } :
                               (sizeMode==3'b001 && ~signExt ) ? { {16'b0}, data_sram_rdata[15:0] }                   :
                               (sizeMode==3'b010             ) ? data_sram_rdata                                      :
                               (sizeMode==3'b011             ) ? lwlRawData                                           : //lwl
                               (sizeMode==3'b100             ) ? lwrRawData                                           : // lwr
                                                                 32'b0                                                ; 

    assign writeBackData = Mode[5] ? dataLoaded : aluResult ;

    assign debug_wb_pc = PC_wb ;
    assign debug_wb_rf_wdata = writeBackData ;
    assign debug_wb_rf_wen = {4{C5_wb}} ;
    assign debug_wb_rf_wnum = targetReg_wb ;





endmodule

// by Anlan


