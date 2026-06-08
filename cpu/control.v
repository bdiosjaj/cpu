module control(
    input rst,
    input [6:0]op,
    input [2:0]funct3,
    input funct7,
    output reg regwrited,    //判断寄存器是否写
    output reg [2:0]resultsrcd,  //判断写入寄存器的东西，0时，alu的结果写入寄存器（r-type，beq），1时，内存读出的数据写入寄存器（lw，sw），10时，pc+4写入（jal）,11时，pc+Imm（anipc）,100:lui
    output reg memwrited,   //判断是否写内存
    output reg jumpd,       //是否为跳转指令
    output reg branchd,     //是否为分支指令（目前是beq）
    output reg[3:0] alucontrold, //判断alu的操作
    output reg alusrcd,     //判断alu的第二个操作数是寄存器（0）还是立即数（1）
    output reg [2:0]immsrcd,    //不同指令，立即数的组成和扩展方式不同，000：I型，001：S型，010：B型，011：j型,100：U型
    output [2:0]funct3d,
    output reg jalr_controld     //判断imm + rd1e(1)还是pce(0)
);
reg [2:0]aluop;

assign  funct3d = funct3;
always@(*)begin
    if(rst)begin
        regwrited = 1'b0;            
        immsrcd = 3'b000;
        alusrcd = 1'b0;
        memwrited = 1'b0;
        resultsrcd = 3'b000;
        branchd = 1'b0;
        aluop = 3'b000;
        jumpd = 1'b0;
        jalr_controld = 1'b0;

    end
    else case(op) 
        7'b0000011:                       //lb,lh,lw,lbu,lhu指令
        begin   
                regwrited = 1'b1;          
                immsrcd = 3'b000;
                alusrcd = 1'b1;
                memwrited = 1'b0;
                resultsrcd = 3'b001;
                branchd = 1'b0;
                aluop = 3'b000;
                jumpd = 1'b0;
                jalr_controld = 1'b0;
        end
        7'b0010011:                     //addi,slli,slti,sltiu,xori,srli,srai,ori,andi指令
                begin   
                regwrited = 1'b1;          
                immsrcd = 3'b000;
                alusrcd = 1'b1;
                memwrited = 1'b0;
                resultsrcd = 3'b000;
                branchd = 1'b0;
                aluop = 3'b011;
                jumpd = 1'b0;
                jalr_controld = 1'b0;

        end

            7'b1100111:                     //jalr
                begin   
                regwrited = 1'b1;          
                immsrcd = 3'b000;
                alusrcd = 1'b1;         //x
                memwrited = 1'b0;
                resultsrcd = 3'b010;    
                branchd = 1'b0;
                aluop = 3'b011;
                jumpd = 1'b1;
                jalr_controld = 1'b1;

        end

        7'b0010111:                      //auipc
        begin
                regwrited = 1'b1;          
                immsrcd = 3'b100;
                alusrcd = 1'b0;     //x
                memwrited = 1'b0;
                resultsrcd =3'b110; 
                branchd = 1'b0;
                aluop = 3'b000;      //xx
                jumpd = 1'b0;
                jalr_controld = 1'b0;
        end

        7'b0110111:                      //lui
        begin
                regwrited = 1'b1;          
                immsrcd = 3'b100;
                alusrcd = 1'b0;     //x
                memwrited = 1'b0;
                resultsrcd =3'b100; 
                branchd = 1'b0;
                aluop = 3'b000;      //xx
                jumpd = 1'b0;
                jalr_controld = 1'b0;
        end


        7'b0100011:
         begin
                regwrited = 1'b0;            //sw指令
                immsrcd = 3'b001;
                alusrcd = 1'b1;
                memwrited = 1'b1;
                resultsrcd = 3'b000;      
                branchd = 1'b0;
                aluop = 3'b000;
                jumpd = 1'b0;
                jalr_controld = 1'b0;
            
        end
        7'b0110011:
         begin
                regwrited = 1'b1;            //r_type指令
                immsrcd = 3'b000; //xx
                alusrcd = 1'b0;
                memwrited = 1'b0;
                resultsrcd = 3'b000;
                branchd = 1'b0;
                aluop = 3'b010;
                jumpd = 1'b0;
                jalr_controld = 1'b0;
               
        end
        7'b1100011:
        begin
                regwrited = 1'b0;            //beq,bne,blt,bge,bltu,bgeu指令
                immsrcd = 3'b010; 
                alusrcd = 1'b0;
                memwrited = 1'b0;
                resultsrcd = 3'b000;//x
                branchd = 1'b1;
                aluop = 3'b100;
                jumpd = 1'b0;
                jalr_controld = 1'b0;
            
        end
        7'b1101111:
        begin                           //jal指令
            regwrited = 1'b1;           
            immsrcd = 3'b011; 
            alusrcd = 1'b0;     //x
            memwrited = 1'b0;
            resultsrcd = 3'b010;      
            branchd = 1'b0;
            aluop = 3'b001;      //xx
            jumpd = 1'b1;
            jalr_controld = 1'b0;
         
        end


        default:begin
                regwrited = 1'b0;           
                immsrcd = 3'b000;
                alusrcd = 1'b0;
                memwrited = 1'b0;
                resultsrcd = 3'b000;
                branchd = 1'b0;
                aluop = 3'b000;
                jumpd = 1'b0;
                jalr_controld = 1'b0;
               
        end

    endcase

end
//0000：加法
//0001：减法
//0010：与
//0011：或
//0100：小于置位（无符号）
//0101：小于置位（有符号）
//0110：左移
//0111：按位异或
//1000：算数右移
//1001：逻辑右移

always@(*)begin         
    if(rst) begin
        alucontrold = 4'b0000;
    end
    else if(aluop ==3'b000)
    alucontrold = 4'b0000;    //加法，lw，sw
    else if(aluop == 3'b001)    
    alucontrold = 4'b0001;    //减法，beq
    else if(aluop ==3'b010)
        case(funct3)
            3'b000:begin
                 if(funct7==1'b1)
                 alucontrold = 4'b0001;      //减法，sub
                 else
                 alucontrold = 4'b0000;      //加法，add
                   end
            3'b001:alucontrold = 4'b0110;    //逻辑左移，sll
            3'b010:alucontrold = 4'b0101;      //小于置位，slt
            3'b011:alucontrold = 4'b0100;       //小于置位（无符号）,sltu
            3'b100:alucontrold = 4'b0111;       //异或,xor
            3'b101:begin
            if(funct7 == 1'b0)
            alucontrold = 4'b1001;          //逻辑右移,srl
            else
            alucontrold = 4'b1000;           //算数右移,sra
            end
            3'b110:alucontrold = 4'b0011;      //或，or
            3'b111:alucontrold = 4'b0010;      //与，and
            default:alucontrold = 4'b0000;
        endcase
    else if(aluop == 3'b011)             //addi,slli,slti,sltiu,xori,srli,srai,ori,andi       
    case(funct3)
    3'b000:     alucontrold = 4'b0000;          //加法，addi
    3'b001:     alucontrold = 4'b0110;          //左移，slli      
    3'b010:     alucontrold = 4'b0101;          //小于置位（有符号），slti
    3'b011:     alucontrold = 4'b0100;          //小于置位(无符号)，sltiu
    3'b100:     alucontrold = 4'b0111;          //异或，xori
    3'b101: if(funct7 == 1'b0)
                alucontrold = 4'b1001;          //逻辑右移,srli
            else   
                alucontrold = 4'b1000;          //算数右移,srai

    3'b110:     alucontrold = 4'b0011;          //或,ori
    3'b111:     alucontrold = 4'b0010;          //与,andi
    default:alucontrold = 4'b0000;
    endcase
    else if(aluop == 3'b100)
    case(funct3)
    3'b000:     alucontrold = 4'b0001;//beq,减法
    3'b001:     alucontrold = 4'b0001;//bne，减法
    3'b100:     alucontrold = 4'b0101;//blt，小于置位(有符号)，
    3'b101:     alucontrold = 4'b0101;//bge，小于置位(有符号)，
    3'b110:     alucontrold = 4'b0100;//bltu,小于置位（无符号）
    3'b111:     alucontrold = 4'b0100;//bgeu,小于置位（无符号）
    default:alucontrold = 4'b0000;

    endcase
    else alucontrold = 4'b0000;

end

/*根据funct3判断从数据内存中读取的是几位，RISC-V加载指令opcode均为7'b0000011，
由funct3区分功能：lb（000，Load Byte）读取1字节并符号扩展至32位，
lh（001，Load Halfword）读取2字节并符号扩展至32位，
lw（010，Load Word）读取4字节直接存入寄存器，lbu（100，Load Byte Unsigned）读取1字节并零扩展至32位，
lhu（101，Load Halfword Unsigned）读取2字节并零扩展至32位。*/



endmodule