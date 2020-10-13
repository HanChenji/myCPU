



module myCPU_WB (
    input[31:0] aluResult,
    input[31:0] data_sram_rdata,
    input[5 :0] Mode,
    input       C5,

    output[31:0] writeBackData,
    output[3:0]  rfWen
);

    wire[2:0] sizeMode = Mode[3:1];
    wire      signExt  = Mode[0]  ;


    wire[31:0] dataLoaded =    (sizeMode==3'b000 && signExt  ) ? {24{data_sram_rdata[7]},data_sram_rdata[7:0]}   :
                               (sizeMode==3'b000 && ~signExt ) ? {24{0},data_sram_rdata[7:0]}                    :
                               (sizeMode==3'b001 && signExt  ) ? {16{data_sram_rdata[15]},data_sram_rdata[15:0]} :
                               (sizeMode==3'b001 && ~signExt ) ? {16{0},data_sram_rdata[15:0]}                   :
                               (sizeMode==3'b010             ) ? data_sram_rdata                                 :
                               (sizeMode==3'b011             ) ? data_sram_rdata                                 :
                               (sizeMode==3'b100             ) ? data_sram_rdata                                 :
                                                                 {32{0}}                                         ; 

    assign writeBackData = Mode[5] ? dataLoaded : aluResult ;


    wire[3:0] wen = (sizeMode==3'b000) ? 4'b0001 :
                    (sizeMode==3'b001) ? 4'b0011 :
                    (sizeMode==3'b010) ? 4'b1111 :
                    (sizeMode==3'b011) ?         : // SWL
                    (sizeMode==3'b100) ?         : // SWR
                                         4'b0000 ; 
    assign rfWen =  {4{C5}} & wen ; 
 



endmodule

// by Anlan


