module alu(
    input[31:0] rd1e, //连接srcae的选择器

    input [2:0]forwardae,

    input [31:0] rd2e,
    input [2:0]forwardbe,    //下面那个选择器

    input alusrce,      //srcb前面的选择器
    input [31:0] immexte,

    input [31:0] pce,

    input jumpe,
    input branche,
    input [3:0]alucontrole,
    input [2:0]funct3e,
    input jalr_controle,

    input [31:0]forward_data_m1, 
    input [31:0]forward_data_m2, 
    input [31:0]forward_data_w, 

    output [31:0] pctargete,
    output pcsrce,
    output reg [31:0] aluresulte,
    output reg [31:0] writedatae  

);

wire [31:0]pc;

reg [31:0]srcae;
wire [31:0]srcbe;
//reg  zeroe;
reg branch_taken;

always @(*) begin
    case (forwardae)
        3'b010: srcae = forward_data_m1;
        3'b011: srcae = forward_data_m2;
        3'b001: srcae = forward_data_w;
        default: srcae = rd1e;
    endcase
end

always @(*) begin
    case (forwardbe)
        3'b010: writedatae = forward_data_m1;
        3'b011: writedatae = forward_data_m2;
        3'b001: writedatae = forward_data_w;
        default: writedatae = rd2e;
    endcase
end

    

assign srcbe = alusrce ? immexte : writedatae ; //第三个选择器

assign pc = jalr_controle ? srcae : pce;        //由rd1e改为了srcae

assign pctargete = pc + immexte; //加法器


//funct3e        000：等于，001：不等于，100：小于（有符号），101：大于等于（有符号），110：小于（无符号），111：大于等于（无符号）


always @(*) begin
    case (funct3e)
        3'b000: branch_taken = (srcae == writedatae);                    // BEQ
        3'b001: branch_taken = (srcae != writedatae);                    // BNE
        3'b100: branch_taken = ($signed(srcae) < $signed(writedatae));    // BLT
        3'b101: branch_taken = ($signed(srcae) >= $signed(writedatae));   // BGE
        3'b110: branch_taken = (srcae < writedatae);                     // BLTU
        3'b111: branch_taken = (srcae >= writedatae);                    // BGEU
        default: branch_taken = 1'b0;
    endcase
end

assign pcsrce = jumpe | (branche & branch_taken);



always@(*)begin

case(alucontrole)
    4'b0000: aluresulte = srcae + srcbe;                         //加法
    4'b0001: aluresulte = srcae - srcbe;                         //减法
    4'b0010: aluresulte = srcae & srcbe;                         //按位与
    4'b0011: aluresulte = srcae | srcbe;                         //按位或
    4'b0100:                            
        if(srcae<srcbe)begin                
            aluresulte = 32'b1;                                  //小于置位(无符号)
        end             
        else begin              
            aluresulte = 32'b0;             
        end             
    4'b0101:                
        if($signed(srcae)<$signed(srcbe))begin              
            aluresulte = 32'b1;                                  //小于置位（有符号）
        end             
        else begin              
            aluresulte = 32'b0;             
        end             
    4'b0110: aluresulte = srcae<<srcbe[4:0];                     //左移
    4'b0111: aluresulte = srcae ^ srcbe;                         //按位异或
    4'b1000: aluresulte = $signed(srcae)>>>srcbe[4:0];            //算数右移
    4'b1001: aluresulte = srcae >> srcbe[4:0];                   //逻辑右移
    
    default: aluresulte = 32'b0;
endcase
end




endmodule