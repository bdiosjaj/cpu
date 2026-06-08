module mem2_to_wb(

    input clk,
    input rst,
    input regwritem_2,          
    input [2:0]resultsrcm_2,
    input [31:0]aluresultm_2,
    input [31:0]rd,                 //来自bram
    input [4:0]rdm_2,
    input [31:0]pcplusm_2,
    input [31:0]pctargetm_2,
    input [31:0]immextm_2,
    input [31:0]pcm_2,
   // input inst_ex_to_mem,    //debug   

    output reg regwritew,
    output reg [2:0]resultsrcw,
    output reg [31:0]aluresultw,
    output reg [31:0]readdataw,
    output reg [4:0]rdw,
    output reg [31:0]pcplusw,
    output reg[31:0] pctargetw,
    output reg[31:0]immextw,
    output reg[31:0]pcw
    //output reg inst_mem_to_wb     //debug  

);

always@(posedge clk)begin
    if(rst) begin
    regwritew <= 0;
    resultsrcw <=0;
    aluresultw <=0;
    rdw <= 0;
    pcplusw <= 0;
    readdataw<=0;
    pctargetw<=0;
    immextw<=0;
    pcw<=0;
   // inst_mem_to_wb<=0;      //debug  
    end

    else begin
    regwritew       <= regwritem_2      ;
    resultsrcw      <= resultsrcm_2     ;
    aluresultw      <= aluresultm_2     ;
    rdw             <= rdm_2            ;
    pcplusw         <= pcplusm_2        ;
    readdataw       <= rd               ;
    pctargetw       <= pctargetm_2      ;
    immextw         <= immextm_2        ;
    pcw             <= pcm_2            ;
   // inst_mem_to_wb<=inst_ex_to_mem;     //debug  
    end
end


endmodule