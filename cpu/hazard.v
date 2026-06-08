module hazard(
    input [4:0] rs1d,
    input [4:0] rs2d,

    input [4:0] rde,
    input [4:0] rdm_1,
    input [4:0] rdm_2,

    input       regwritee,
    input       regwritem_1,
    input       regwritem_2,

    input       resultsrce0,
    input       pcsrce,
    input [2:0] resultsrcm_1,
    input [2:0] resultsrcm_2,

    output reg [2:0] forwardad,
    output reg [2:0] forwardbd,

    output      stallf,
    output      stalld,
    output      flushe,
    output      flushd
);

wire lwstall;

// rs1d 的下一拍 forward 选择
always @(*) begin
    if ((rs1d != 5'd0) && regwritee && (rs1d == rde))
        forwardad = 3'b010;   // 当前 EX -> 下一拍 MEM1
    else if ((rs1d != 5'd0) && regwritem_1 && (rs1d == rdm_1))
        forwardad = 3'b011;   // 当前 MEM1 -> 下一拍 MEM2
    else if ((rs1d != 5'd0) && regwritem_2 && (rs1d == rdm_2))
        forwardad = 3'b001;   // 当前 MEM2 -> 下一拍 WB
    else
        forwardad = 3'b000;   // 不前递，使用寄存器堆读出的 rd1d
end

// rs2d 的下一拍 forward 选择
always @(*) begin
    if ((rs2d != 5'd0) && regwritee && (rs2d == rde))
        forwardbd = 3'b010;   // 当前 EX -> 下一拍 MEM1
    else if ((rs2d != 5'd0) && regwritem_1 && (rs2d == rdm_1))
        forwardbd = 3'b011;   // 当前 MEM1 -> 下一拍 MEM2
    else if ((rs2d != 5'd0) && regwritem_2 && (rs2d == rdm_2))
        forwardbd = 3'b001;   // 当前 MEM2 -> 下一拍 WB
    else
        forwardbd = 3'b000;
end

assign lwstall =
    (
        (
            ((rs1d != 5'd0) && (rs1d == rde)) ||
            ((rs2d != 5'd0) && (rs2d == rde))
        ) && resultsrce0
    )
    ||
    (
        !pcsrce &&
        (
            ((rs1d != 5'd0) && (rs1d == rdm_1)) ||
            ((rs2d != 5'd0) && (rs2d == rdm_1))
        ) && resultsrcm_1[0]
    );

assign stallf = lwstall;
assign stalld = lwstall;

assign flushe = lwstall | pcsrce;
assign flushd = pcsrce;

endmodule