module if_to_id(
    input rst,
    input [31:0]rd,
    input [31:0]pcf,
    input [31:0]pcplusf,
    input stalld,
    input flushd,
    input clk,
    output reg[31:0]instrd,
    output reg [31:0]pcd,
    output reg[31:0]pcplusd
   // output reg inst_if_to_id  //debug
);
always@(posedge clk )begin
    if(rst)begin
    instrd <= 0;
    pcd <= 0;
    pcplusd <= 0;
    //inst_if_to_id<=0;//debug
    end

    else if(flushd)
    begin
    instrd <= 0;
    pcd <= 0;
    pcplusd <= 0;
    //inst_if_to_id<=0;//debug
    end
    else if(stalld)begin
    instrd <= instrd;
    pcd <= pcd;
    pcplusd <= pcplusd;
   // inst_if_to_id<=inst_if_to_id;//debug
    end
    else begin
    instrd <= rd;
    pcd <= pcf;
    pcplusd <= pcplusf;
    //inst_if_to_id<=1; //debug
    end
end

endmodule