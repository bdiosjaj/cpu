module extend(
    input [31:7]instrd,
    input [2:0]immsrcd,
    output reg[31:0]immextd
);

always@(*)begin
    
    case(immsrcd)
        3'b000: immextd = {{20{instrd[31]}},instrd[31:20]}; //I-type
        3'b001: immextd = {{20{instrd[31]}},instrd[31:25],instrd[11:7]}; //S-type
        3'b010: immextd = {{20{instrd[31]}},instrd[7],instrd[30:25],instrd[11:8],1'b0}; //B-type
        3'b011: immextd = {{12{instrd[31]}},instrd[19:12],instrd[20],instrd[30:21],1'b0};   //J-type
        3'b100: immextd = {instrd[31:12],12'b0}; //U-type
        default:immextd =32'b0;
    endcase

end


endmodule