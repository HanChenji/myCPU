

/*  This module is the PC unit
 *  the next PC is determined in two ways:
 *      1. PC = PC + 4 
 *      2. PC = PC + offset in the jump instruction
 *  allowIN suggests whether the pipeline stalls or not, i.e. whether allowing the next instuction in or not
 *  jen suggests whether the jump condition satisfied or not 
 *  offset is the relative offset in the jump instruction
 *
 */
 

module myCPU_IF (

    input clk,
    input rst,
    input [31:0] offset,
    input jen,
    input allowIN,

    output reg[31:0] PC,
    output reg instRequest;
);

    always @(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            PC <= 32'b0;
            instRequest <= 1'b0;
        end
        else if(allowIN)
            instRequest <= 1'b1;
            if(jen) // NPC = PC + offset
                PC <= PC + offset;
            else // NPC = PC +4
                PC <= PC + 4;
    end

endmodule













