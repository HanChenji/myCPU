

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

    input            clk,
    input            rst,
    input   [31:0]   offset,
    input   [ 1:0]   jmp_mode,
    input            allow_in,

    output           inst_sram_en,
    output  [ 3:0]   inst_sram_wen,
    output  [31:0]   inst_sram_addr,
    output  [31:0]   inst_sram_wdata,
    
    output  [31:0]   IF2ID_pc

);

    wire[31:0] pc          ; 
    reg [31:0] pc_reg      ;
    reg        inst_en_reg ;

    always @(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            pc_reg      <= 32'hbfc00000 ;
            inst_en_reg <= 1'b0         ;
        end
        else 
        begin 
            if(allow_in)
            begin
                inst_en_reg <= 1'b1;
                if(jmp_mode==2'b01) // NPC = PC + offset 
                    pc_reg <= IF2ID_pc + offset;
                else if (jmp_mode==2'b10||jmp_mode==2'b11)
                    pc_reg <= offset;
                else // NPC = PC +4
                    pc_reg <= PC + 4;
            end
            else
            begin
                inst_en_reg <= 1'b0;
            end
        end
    end

    assign pc = pc_reg ;

 
    reg [31:0] IF2ID_pc_reg ;
   
    always @(posedge clk, posedge rst) 
    begin
        if(rst) 
        begin
            IF2ID_pc_reg <= 32'b0 ;
        end
        else
        begin
            if(allow_in)
            begin
                IF2ID_pc_reg <= pc    ;
            end
        end
    end

    assign IF2ID_pc = IF2ID_pc_reg ;
    // connect the PC module with the SRAM module 
    assign inst_sram_addr = pc_reg;
    assign inst_sram_en = inst_en_reg ;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;


endmodule


// by Anlan





