
`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module myCPU_regFile(

    input clk,
    input rst,
    
    input wen,
    input [`ADDR_WIDTH - 1:0] waddr,
    input [`DATA_WIDTH - 1:0] wdata,
   
    input [`ADDR_WIDTH - 1:0] raddr1,
    input [`ADDR_WIDTH - 1:0] raddr2,
    
    output [`DATA_WIDTH - 1:0] rdata1,
    output [`DATA_WIDTH - 1:0] rdata2

);

	reg[31:0] rf[31:0];

	// write the register file 
	always @(posedge clk) 
    begin 
        if(wen) 
            rf[waddr] <= wdata;
    end

    // read 1
    assign rdata1 = (raddr1==5'b0) ? 32'b0 : rf[raddr1];

    // read 2
    assign rdata2 = (raddr2==5'b0) ? 32'b0 : rf[raddr2];



endmodule


