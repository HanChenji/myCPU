/*
 *      
 *
 *
 *
 */



module myCPU_MEM (

    input[5:0] Mode,
    input[1:0] addrLow2Bit,
    input[31:0] storeCont,

    output[3:0]  memWen,
    output[31:0] data2write

);

    wire[31:0] swlRawData = (addrLow2Bit==2'b00) ? {24{0},storeCont[31:24]} :
                            (addrLow2Bit==2'b01) ? {16{0},storeCont[31:16]} :
                            (addrLow2Bit==2'b10) ? { 8{0},storeCont[31:8]} :
                                                   storeCont ;
    wire[31:0] swrRawData = (addrLow2Bit==2'b00) ? storeCont :
                            (addrLow2Bit==2'b01) ? {storeCont[23:0],8{0}} :
                            (addrLow2Bit==2'b10) ? {storeCont[15:0],16{0}} :
                                                   {storeCont[7:0],24{0}} ;


    wire[2:0] sizeMode = Mode[3:1];

    wire[3:0] swrCtrlBit = (addrLow2Bit==2'b00) ? 4'b1111 :
                           (addrLow2Bit==2'b01) ? 4'b1110 :
                           (addrLow2Bit==2'b10) ? 4'b1100 :
                                                  4'b1000 ;

    wire[3:0] swlCtrlBit = (addrLow2Bit==2'b00) ? 4'b0001 :
                           (addrLow2Bit==2'b01) ? 4'b0011 :
                           (addrLow2Bit==2'b10) ? 4'b0111 :
                                                  4'b1111 ;

    wire[3:0] wen = (sizeMode==3'b000) ? 4'b0001    :
                    (sizeMode==3'b001) ? 4'b0011    :
                    (sizeMode==3'b010) ? 4'b1111    :
                    (sizeMode==3'b011) ? swlCtrlBit : // SWL
                    (sizeMode==3'b100) ? swrCtrlBit : // SWR
                                         4'b0000    ; 

    assign memWen =  {4{Mode[4]}} & wen ; 

    assign data2write = (sizeMode==3'b011) ? swlRawData : //swl 
                        (sizeMode==3'b100) ? swrRawData : //swr
                                             storeCont  ; //others


endmodule

// by Anlan







