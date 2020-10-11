

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
    input[1:0] jen,
    input allowIN,

    output inst_sram_en,
    output[31:0] inst_sram_addr

);

    reg[31:0] PC,
    reg instRequest;
    always @(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            PC <= 0xbfc00000;
            instRequest <= 1'b1;
        end
        else 
        begin 
            if(allowIN)
            begin
                instRequest <= 1'b1;
                if(jen==2'b01) // NPC = PC + 4 + offset ? why +4 ?
                    PC <= PC + offset;
                else if (jen==2'b10||jen==2'b11)
                    PC <= offset;
                else // NPC = PC +4
                    PC <= PC + 4;
            end
            else
            begin
                instRequest <= 1'b0;
                PC <= PC;
            end
        end
    end

    assign inst_sram_en = instRequest;
    assign inst_sram_addr = PC;

endmodule













