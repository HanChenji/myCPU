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

    input        Load,
    input        Store,
    input        signExt,
    input[2:0]   Mode,

    input[31:0]  data_sram_rdata,
    
    input[31:0]  wCont,

    output[ 3:0] data_sram_wen,

    output[31:0] data_sram_wdata,
    output[31:0] dataLoaded


);

    wire[31:0] dataLWL = ;
    wire[31:0] dataLWR = ;

    assign dataLoaded =    (Mode==3'b000 && signExt)  ? {24{data_sram_rdata[7]},data_sram_rdata[7:0]}   :
                           (Mode==3'b000 && ~signExt) ? {24{0},data_sram_rdata[7:0]}                    :
                           (Mode==3'b001 && signExt)  ? {16{data_sram_rdata[15]},data_sram_rdata[15:0]} :
                           (Mode==3'b001 && ~signExt) ? {16{0},data_sram_rdata[15:0]}                   :
                           (Mode==3'b010           )  ? data_sram_rdata                                 :
                           (Mode==3'b011           )  ? dataLWL :
                           (Mode==3'b100           )  ? dataLWR ;



    wire[31:0] data2writtenWL = ;
    wire[31:0] data2writtenWR = ;

    assign data_sram_wdata = (Mode==3'b011) ? data2writtenWL :
                             (Mode==3'b100) ? data2writtenWR :
                                              wCont;
   
    wire[3:0] wen = (Mode==3'b000) ? 4'b0001 :
                    (Mode==3'b001) ? 4'b0011 :
                    (Mode==3'b010) ? 4'b1111 :
                    (Mode==3'b011) ?         : // SWL
                    (Mode==3'b100) ?         : // SWR
                                     4'b0000 ; 
    assign data_sram_wen = Store ? wen : 4'b0000 ; 
                                          
                                




endmodule









