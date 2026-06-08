module ex_to_mem1(
    input rst,
    input clk,
    input regwritee,
    input [2:0]resultsrce,
    input memwritee,
    input [31:0]aluresulte,
    input [31:0]writedatae,
    input [4:0]rde,
    input [31:0]pcpluse,
    input [2:0]funct3e,
    input [31:0]pctargete,  
    input [31:0]immexte,
    input [31:0]pce,
   // input inst_id_to_ex,    //debug

    output reg           regwritem_1  ,
    output reg  [2:0]    resultsrcm_1 ,
    output reg           memwritem_1    ,
    output reg  [31:0]   aluresultm_1   ,
    output reg  [31:0]   writedatam_1   ,
    output reg  [4:0]    rdm_1        ,
    output reg  [31:0]   pcplusm_1    ,
    output reg  [2:0]    funct3m_1      ,
    output reg  [31:0]   pctargetm_1  ,
    output reg  [31:0]   immextm_1    ,
    output reg  [31:0]   pcm_1,
    output wire  [31:0] forward_data_m1
  //  output reg inst_ex_to_mem       //debug
);

always@(posedge clk )begin
    if(rst)begin
    regwritem_1 <= 0;
    resultsrcm_1 <=0;
    memwritem_1 <= 0;
    aluresultm_1 <=0;
    writedatam_1 <=0;
    rdm_1 <= 0;
    pcplusm_1 <= 0;
    funct3m_1 <=0;
    pctargetm_1<=0;
    immextm_1<=0;
    pcm_1<=0;
   // inst_ex_to_mem <=0;
    end
    else begin regwritem_1 <= regwritee;
    resultsrcm_1 <= resultsrce;
    memwritem_1 <= memwritee;
    aluresultm_1 <= aluresulte;
    writedatam_1 <= writedatae;
    rdm_1 <= rde;
    pcplusm_1 <= pcpluse;
    funct3m_1 <=funct3e;
    pctargetm_1<=pctargete;
    immextm_1<=immexte;
    pcm_1<=pce;
   // inst_ex_to_mem <=inst_id_to_ex;
    end
end

assign forward_data_m1 =
    (resultsrcm_1 == 3'b100) ? immextm_1 :  // lui
    (resultsrcm_1 == 3'b110) ? pctargetm_1  //auipc
       : aluresultm_1; 
                              

endmodule