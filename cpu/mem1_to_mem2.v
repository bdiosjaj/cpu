module mem1_to_mem2(
input clk,
input rst,
input           regwritem_1  ,
input  [2:0]    resultsrcm_1 ,
//input           memwritem  ,
input  [31:0]   aluresultm_1 ,
//input  [31:0]   writedatam ,
input  [4:0]    rdm_1        ,
input  [31:0]   pcplusm_1    ,
input  [2:0]    funct3m_1   ,           //dram_driver中的信号后处理部分要用。
input  [31:0]   pctargetm_1  ,
input  [31:0]   immextm_1    ,
input  [31:0]   pcm_1        ,

output reg regwritem_2,
output reg [2:0]resultsrcm_2,
output reg [31:0]aluresultm_2,
//output reg [31:0]rd,
output reg [4:0]rdm_2,
output reg [31:0]pcplusm_2,
output reg [31:0]pctargetm_2,
output reg [31:0]immextm_2,
output reg [31:0]pcm_2,
output reg [2:0]funct3m_2,
output wire [31:0] forward_data_m2

);

always@(posedge clk)
begin
if(rst) begin
regwritem_2    <=        0 ;
resultsrcm_2   <=        0 ;
aluresultm_2   <=        0 ;
rdm_2          <=        0 ;
pcplusm_2      <=        0 ;
pctargetm_2    <=        0 ;
immextm_2      <=        0 ;
pcm_2          <=        0 ;
funct3m_2      <=        0 ;
end
else begin
regwritem_2    <=        regwritem_1  ;
resultsrcm_2   <=        resultsrcm_1 ;
aluresultm_2   <=        aluresultm_1 ;
rdm_2          <=        rdm_1        ;
pcplusm_2      <=        pcplusm_1    ;
pctargetm_2    <=        pctargetm_1  ;
immextm_2      <=        immextm_1    ;
pcm_2          <=        pcm_1        ;
funct3m_2      <=        funct3m_1     ;
end

end
assign forward_data_m2=
    (resultsrcm_2 == 3'b100) ? immextm_2 :  // lui
    (resultsrcm_2 == 3'b110) ? pctargetm_2  //auipc
       : aluresultm_2; 
endmodule