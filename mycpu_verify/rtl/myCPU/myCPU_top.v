

module mycpu_top(
    input            clk,
    input            resetn,            //low active

    output           inst_sram_en,
    output  [ 3:0]   inst_sram_wen,
    output  [31:0]   inst_sram_addr,
    output  [31:0]   inst_sram_wdata,
    input   [31:0]   inst_sram_rdata,

    output           data_sram_en,
    output  [ 3:0]   data_sram_wen,
    output  [31:0]   data_sram_addr,
    output  [31:0]   data_sram_wdata,
    input   [31:0]   data_sram_rdata,

    //debug interface
    output  [31:0]   debug_wb_pc,
    output  [3 :0]   debug_wb_rf_wen,
    output  [4 :0]   debug_wb_rf_wnum,
    output  [31:0]   debug_wb_rf_wdata
);

    wire rst = ~ resetn ;
    wire[31:0] PC;
    wire instRequest;
    wire ifvalid;
 
    wire[31:0] A, B;
    wire[4:0] targetReg;
    wire[31:0] jmpAddr;
    wire[3:0] aluop;
    wire[31:0] storeCont;
    
    wire[1:0] C1;
    wire C3, C5, C6;
    wire[5:0] lsMode;
    wire allowIN;
 
    wire[31:0] A_ex         ;
    wire[31:0] PC_ex        ;
    wire[31:0] B_ex         ;
    wire[4:0]  targetReg_ex ;
    wire[31:0] sotreCont_ex ;
    wire[3:0]  aluop_ex     ;
    wire       C5_ex        ;
    wire[5:0]  lsMode_ex    ;
    wire[31:0] result_ex    ;

    wire[4:0]   targetReg_mem  ;
    wire[31:0]  storeCont_mem  ;
    wire[31:0]  PC_mem         ;
    wire        C5_mem         ;
    wire[5:0]   lsMode_mem     ;
    wire[31:0]  aluResult_mem  ;
    wire[31:0]  data2write     ;
    wire[3:0]   memWen         ;

 
    wire [31:0] PC_wb      ;
    wire C5_wb      ;
    wire[5:0] lsMode_wb  ;
    wire[4:0]  targetReg_wb ;
    wire[31:0] aluResult_wb ;
    wire[31:0] rtCont_wb    ;
    wire[31:0] writeBackData ;



    myCPU_IF IF_module(
        // input
        .clk(clk),
        .rst(rst),
        .offset(jmpAddr),
        .jen(C1),
        .allowIN(allowIN),
        // output
        .inst_sram_en(inst_sram_en),
        .inst_sram_addr(PC),
        .ifvalid(ifvalid)
    );

    // connect the PC module with the SRAM module 
    assign inst_sram_addr = PC;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;
       
    myCPU_ID ID_module(
        // input
        .clk(clk),
        .rst(rst),
        .PC(PC),
        .instruction(inst_sram_rdata),
        .ifvalid(ifvalid),

        .wen(C5_wb),
        .wdata(writeBackData),
        .waddr(targetReg_wb),

        .targetRegOfMinus1Inst({{lsMode_ex[5]} , targetReg_ex  }   ),
        .targetRegOfMinus2Inst({{lsMode_mem[5]}, targetReg_mem }   ),
        .targetRegOfMinus3Inst({{lsMode_wb[5]} , targetReg_wb  }   ),

        .ex2mem_cont(result_ex),
        .mem2wb_cont(aluResult_mem),
        .wb_cont(writeBackData),

        // output
        .A(A),
        .B(B),
        .targetReg_(targetReg),
        .jmpAddr(jmpAddr),
        .storeCont(storeCont),

        .aluop(aluop),
        .C1__(C1),
        .C5__(C5),
        .C8__(lsMode),
        .allowIN(allowIN)
    );
 
    // ID/EXE pipeline register 
    reg[31:0] ID2EXE_A, ID2EXE_B ;
    reg[31:0] ID2EXE_PC          ;
    reg[4:0]  ID2EXE_TARGETREG   ;
    reg[31:0] ID2EXE_STORECONT   ;
    reg[3:0]  ID2EXE_ALUOP       ;
    reg       ID2EXE_C5          ; 
    reg[5:0]  ID2EXE_LSMODE      ;

    always @(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            ID2EXE_A         <= 32'b0   ;
            ID2EXE_PC        <= 32'b0   ;
            ID2EXE_B         <= 32'b0   ;
            ID2EXE_TARGETREG <=  5'b0   ;
            ID2EXE_STORECONT <= 32'b0   ;
            ID2EXE_ALUOP     <=  4'b0   ;
            ID2EXE_C5        <=  1'b0   ;
            ID2EXE_LSMODE    <=  6'b0   ;
        end
        else
        begin
            ID2EXE_PC        <= PC;
            ID2EXE_A         <= A;
            ID2EXE_B         <= B;
            ID2EXE_TARGETREG <= targetReg;
            ID2EXE_STORECONT <= storeCont;
            ID2EXE_ALUOP     <= aluop;
            ID2EXE_C5        <= C5;
            ID2EXE_LSMODE    <= lsMode;
        end
    end  

    assign A_ex = ID2EXE_A                  ;
    assign PC_ex = ID2EXE_PC                ;
    assign B_ex = ID2EXE_B                  ;
    assign targetReg_ex = ID2EXE_TARGETREG  ;
    assign sotreCont_ex = ID2EXE_STORECONT  ;
    assign aluop_ex = ID2EXE_ALUOP          ;
    assign C5_ex = ID2EXE_C5                ;
    assign lsMode_ex = ID2EXE_LSMODE        ;

    myCPU_EX EX_module(
        //input
        .A(A_ex),
        .B(B_ex),
        .aluop(aluop_ex),
        //output
        .result(result_ex)
    );


    // EXE/MEM pipeline register 
    reg[4:0]  EXE2MEM_TARGETREG ;
    reg[31:0] EXE2MEM_STORECONT ;
    reg[31:0] EXE2MEM_PC        ;
    reg       EXE2MEM_C5        ;
    reg[5:0]  EXE2MEM_LSMODE    ;
    reg[31:0] EXE2MEM_ALURESULT ;
    
    always @(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            EXE2MEM_TARGETREG   <=   5'b0 ;
            EXE2MEM_STORECONT   <=  32'b0 ;
            EXE2MEM_PC          <=  32'b0 ;
            EXE2MEM_C5          <=   1'b0 ;
            EXE2MEM_LSMODE      <=   6'b0 ;
            EXE2MEM_ALURESULT   <=   1'b0 ;
        end
        else
        begin
            EXE2MEM_TARGETREG   <=  targetReg_ex  ;
            EXE2MEM_STORECONT   <=  sotreCont_ex  ;
            EXE2MEM_PC          <=  PC_ex  ;
            EXE2MEM_C5          <=  C5_ex         ;
            EXE2MEM_LSMODE      <=  lsMode_ex     ;
            EXE2MEM_ALURESULT   <=  result_ex     ;
        end
    end


    assign targetReg_mem = EXE2MEM_TARGETREG ;
    assign storeCont_mem = EXE2MEM_STORECONT ;
    assign PC_mem        = EXE2MEM_PC        ;
    assign C5_mem        = EXE2MEM_C5        ;
    assign lsMode_mem    = EXE2MEM_LSMODE    ;
    assign aluResult_mem = EXE2MEM_ALURESULT ;

    assign data_sram_en = lsMode_mem[5] || lsMode_mem[4] ;
    assign data_sram_addr = aluResult_mem;

    myCPU_MEM MEM_module (
        // input 
        .Mode(lsMode_mem),
        .addrLow2Bit(aluResult_mem[1:0]),
        .storeCont(storeCont_mem),

        // output 
        .memWen(memWen),
        .data2write(data2write)
    );
    
    assign data_sram_wdata = data2write;
    assign data_sram_wen   = memWen    ;

    // MEM/WB pipeline register 
    reg[31:0] MEM2WB_RTCONT   ;
    reg[31:0] MEM2WB_ALURESULT;
    reg[31:0] MEM2WB_PC;
    reg[5:0]  MEM2WB_LSMODE;
    reg       MEM2WB_C5;
    //reg[31:0] MEM2WB_WRITEBACKDATA;
    reg[4:0]  MEM2WB_TARGETREG;

    always @(posedge clk,posedge rst)
    begin
        if(rst)
        begin
            MEM2WB_RTCONT        <=  32'b0 ;
            MEM2WB_ALURESULT     <=  32'b0 ;
            MEM2WB_PC            <=  32'b0 ;
            MEM2WB_LSMODE        <=   6'b0 ; 
            MEM2WB_C5            <=   1'b0 ;
            MEM2WB_TARGETREG     <=   5'b0 ;
        end
        else
        begin
            MEM2WB_RTCONT        <=  storeCont_mem;
            MEM2WB_ALURESULT     <=  aluResult_mem;
            MEM2WB_PC            <=  PC_mem;
            MEM2WB_LSMODE        <=  lsMode_mem; 
            MEM2WB_C5            <=  C5_mem;
            MEM2WB_TARGETREG     <=  targetReg_mem;
        end
    end

    assign PC_wb = MEM2WB_PC;
    assign lsMode_wb = MEM2WB_LSMODE ;
    assign C5_wb = MEM2WB_C5 ;
    assign targetReg_wb  = MEM2WB_TARGETREG  ;
    assign aluResult_wb = MEM2WB_ALURESULT ;
    assign rtCont_wb = MEM2WB_RTCONT ;

    myCPU_WB WB_module (
        // input 
        .rtCont(rtCont_wb),
        .aluResult(aluResult_wb),
        .data_sram_rdata(data_sram_rdata),
        .Mode(lsMode_wb),
        //output
        .writeBackData(writeBackData)
    );

    assign debug_wb_pc = PC_wb ;
    assign debug_wb_rf_wdata = writeBackData ;
    assign debug_wb_rf_wen = {4{C5_wb}} ;
    assign debug_wb_rf_wnum = targetReg_wb ;




endmodule

// by Anlan






