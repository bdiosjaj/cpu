module wb(
    input [2:0]resultsrcw ,
    input [31:0]aluresultw ,
    input [31:0]readdataw  ,
    input [31:0]pcplusw    ,
    input [31:0]pctargetw,
    input [31:0]immextw,
    output reg [31:0] resultw ,
    output wire [31:0] forward_data_w 
);

always@(*)begin
    case(resultsrcw)
    3'b000:resultw = aluresultw;
    3'b001:resultw = readdataw;
    3'b010:resultw = pcplusw;
    3'b110:resultw = pctargetw;     //auipc    那么在hazrd中，resultsrcw的最低位是否=1,判断是否有loar_use
    3'b100:resultw = immextw;       //lui
    default:resultw = 0; 
    
    endcase
end

assign forward_data_w = resultw;

endmodule