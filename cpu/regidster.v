module register(
    input         rst,      // 补上复位端口
    input  [4:0]  a1,
    input  [4:0]  a2,
    input  [4:0]  a3,
    input  [31:0] wd3,
    input         clk,
    input         we3,
    output  [31:0] rd1,
    output  [31:0] rd2
);

reg [31:0] regfile [31:0];


always @(posedge clk ) begin
    if (rst) begin
            regfile[0] <= 32'b0;  // 正确初始化数组
    end
    else if (we3 && a3 != 5'd0) begin
        regfile[a3] <= wd3;
    end
end


assign  rd1 = ((a1==a3)&we3&(a3!=0))?wd3:regfile[a1];
assign  rd2 = ((a2==a3)&we3&(a3!=0))?wd3:regfile[a2];

endmodule