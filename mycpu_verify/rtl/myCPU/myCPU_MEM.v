/*
 * if Load :
 *      we need to deal with the data_sram_rdata according to the 
 *      Mode and signExt, 
 *      the output would be the dataLoaded
 * if Sore :
 *      
 *
 *
 *
 */



module myCPU_MEM (

    input[31:0]  aluResult_mem,
    input[5:0]   Mode,
    input[31:0]  data_sram_rdata,
    
    input[31:0]  wCont,

    output[ 3:0] data_sram_wen,
    output[31:0] data_sram_wdata,

    output[31:0] writeBackData


);

    wire[2:0] sizeMode = Mode[3:1];
    wire      signExt  = Mode[0]  ;

    wire[31:0] dataLWL = ;
    wire[31:0] dataLWR = ;

    wire[31:0] dataLoaded =    (sizeMode==3'b000 && signExt  ) ? {24{data_sram_rdata[7]},data_sram_rdata[7:0]}   :
                               (sizeMode==3'b000 && ~signExt ) ? {24{0},data_sram_rdata[7:0]}                    :
                               (sizeMode==3'b001 && signExt  ) ? {16{data_sram_rdata[15]},data_sram_rdata[15:0]} :
                               (sizeMode==3'b001 && ~signExt ) ? {16{0},data_sram_rdata[15:0]}                   :
                               (sizeMode==3'b010             ) ? data_sram_rdata                                 :
                               (sizeMode==3'b011             ) ? dataLWL :
                               (sizeMode==3'b100             ) ? dataLWR ;



    wire[31:0] data2writtenWL = ;
    wire[31:0] data2writtenWR = ;

    assign data_sram_wdata = (sizeMode==3'b011) ? data2writtenWL :
                             (sizeMode==3'b100) ? data2writtenWR :
                                                  wCont;
   
    wire[3:0] wen = (sizeMode==3'b000) ? 4'b0001 :
                    (sizeMode==3'b001) ? 4'b0011 :
                    (sizeMode==3'b010) ? 4'b1111 :
                    (sizeMode==3'b011) ?         : // SWL
                    (sizeMode==3'b100) ?         : // SWR
                                         4'b0000 ; 
    assign data_sram_wen =  {4{Mode[4]}} & wen ; 
                                
    assign writeBackData = Mode[5] ? dataLoaded : aluResult_mem ;



endmodule

// by Anlan







