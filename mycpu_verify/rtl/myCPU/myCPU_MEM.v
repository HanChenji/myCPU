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

    input[5:0]   Mode,

    output[3:0] data_sram_wen,

);

    wire[2:0] sizeMode = Mode[3:1];

    wire[3:0] wen = (sizeMode==3'b000) ? 4'b0001 :
                    (sizeMode==3'b001) ? 4'b0011 :
                    (sizeMode==3'b010) ? 4'b1111 :
                    (sizeMode==3'b011) ?         : // SWL
                    (sizeMode==3'b100) ?         : // SWR
                                         4'b0000 ; 
    assign data_sram_wen =  {4{Mode[4]}} & wen ; 


endmodule

// by Anlan







