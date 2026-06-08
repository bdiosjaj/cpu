module id_to_ex(
    input rst,
    input  regwrited,        //判断寄存器是否写
    input  [2:0]resultsrcd,  //判断写入寄存器的东西，000时，alu的结果写入寄存器（r-type，beq），001时，内存读出的数据写入寄存器（lw，sw）
    input  memwrited,       //判断是否写内存
    input  jumpd,           //是否为跳转指令
    input  branchd,         //是否为分支指令（目前是beq）
    input [3:0] alucontrold, //判断alu的操作
    input  alusrcd,         //判断alu的第二个操作数是寄存器还是立即数
    input [31:0]rd1,
    input [31:0]rd2,
    input [31:0]pcd,
    input [4:0] rs1d,
    input [4:0] rs2d,
    input [4:0] rdd,
    input [31:0]   immextd,
    input [31:0] pcplusd,
    input flushe,
    input clk,
    input [2:0]funct3d,
    input jalr_controld,
    input [2:0]forwardad,
    input [2:0]forwardbd,
    //input inst_if_to_id,        //debug
    
    output reg  regwritee,       
    output reg  [2:0]resultsrce, 
    output reg  memwritee,       
    output reg  jumpe,           
    output reg  branche,         
    output reg [3:0] alucontrole,
    output reg alusrce,
    output reg [31:0] rd1e,
    output reg [31:0] rd2e,
    output reg [31:0]pce,
    output reg [4:0]rs1e,
    output reg [4:0]rs2e,
    output reg [4:0]rde,
    output reg [31:0]immexte,
    output reg[31:0] pcpluse,
    output reg [2:0]funct3e,
    output reg jalr_controle,
    output  reg[2:0]forwardae,
    output  reg[2:0]forwardbe
   // output reg inst_id_to_ex        //debug
);


always @(posedge clk ) begin
    if (rst) begin
        regwritee <= 0;
        resultsrce <= 0;
        memwritee <= 0;
        jumpe <= 0;
        branche <= 0;
        alucontrole <= 0;
        alusrce <= 0;
        rd1e <= 0;
        rd2e <= 0;
        pce <= 0;
        rs1e <= 0;
        rs2e <= 0;
        rde <= 0;
        immexte <= 0;
        pcpluse <= 0;
        funct3e <= 0;
        jalr_controle <= 0;
        forwardae   <=0;
        forwardbe   <=0;
    end
    else begin
        // 数据类寄存器：不受 flushe 控制，正常进入 EX 级
        rd1e <= rd1;
        rd2e <= rd2;
        pce <= pcd;
        rs1e <= rs1d;
        rs2e <= rs2d;
        immexte <= immextd;
        pcpluse <= pcplusd;
        forwardae <= forwardad;
        forwardbe <= forwardbd;

        if (flushe) begin
            // flush 只清控制信号，制造 bubble
            regwritee <= 0;
            resultsrce <= 0;
            memwritee <= 0;
            jumpe <= 0;
            branche <= 0;
            alucontrole <= 0;
            alusrce <= 0;
            rde <= 0;
            funct3e <= 0;
            jalr_controle <= 0;
        end
        else begin
            regwritee <= regwrited;
            resultsrce <= resultsrcd;
            memwritee <= memwrited;
            jumpe <= jumpd;
            branche <= branchd;
            alucontrole <= alucontrold;
            alusrce <= alusrcd;
            rde <= rdd;
            funct3e <= funct3d;
            jalr_controle <= jalr_controld;
        end
    end
end

endmodule