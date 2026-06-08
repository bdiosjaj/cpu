module pc_if(
    input rst,
    input clk,
    input pcsrce,
    input [31:0]pctargete,
    input stallf,
    output [31:0]pcplusf,
    output reg [31:0]pcf,
    output [31:0]pc_next

);


assign pc_next = pcsrce?pctargete:pcplusf;   
assign pcplusf = pcf + 4;   



always@(posedge clk)
begin
    if(rst)
    pcf <= 32'h8000_0000;
    else if(stallf)
    pcf <=pcf;  
    else
    pcf <= pc_next; 
end




endmodule