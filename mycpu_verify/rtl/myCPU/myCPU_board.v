
module myCPU_board (
    // input
    wire clk,
    wire rst,
    wire[4:0] targetReg,

    //output
    wire[4:0] tRegOfMinus1Inst,
    wire[4:0] tRegOfMinus2Inst,
    wire[4:0] tRegOfMinus3Inst,

);

    reg[4:0] regOfMinus1Inst;
    reg[4:0] regOfMinus2Inst;
    reg[4:0] regOfMinus3Inst;

    always @(posedge clk, posedge rst)
    begin
        if(rst)
        begin
            regOfMinus1Inst <= 5'b00000;
            regOfMinus2Inst <= 5'b00000;
            regOfMinus3Inst <= 5'b00000;
        else
        begin
            regOfMinus1Inst <= targetReg; 
            regOfMinus2Inst <= regOfMinus1Inst;
            regOfMinus3Inst <= regOfMinus2Inst;
        end
    end

    assign tRegOfMinus1Inst = regOfMinus1Inst;
    assign tRegOfMinus2Inst = regOfMinus2Inst;
    assign tRegOfMinus3Inst = regOfMinus3Inst;



endmodule


