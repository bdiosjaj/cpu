module myCPU(
   input            cpu_rst     ,
   input            cpu_clk     , 
   input  [31:0]    irom_data   ,
   input [31:0]     perip_rdata ,
   
   output [31:0]    irom_addr   ,
   output [31:0]    perip_addr  ,
   output           perip_wen   ,
   output [2:0]     perip_mask  ,
   output [31:0]    perip_wdata ,
   output[2:0]      perip_mask_2,
   output[31:0]     perip_addr_2
 
 //  output wire        debug_wb_have_inst,   // WB阶段是否有指令 (对单周期CPU，可在复位后恒为1)
 //  output wire [31:0] debug_wb_pc,          // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
 //  output wire        debug_wb_ena,         // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
 //  output wire [ 4:0] debug_wb_reg,         // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
 //  output wire [31:0] debug_wb_value        // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
);
  

wire inst_if_to_id,inst_id_to_ex,inst_ex_to_mem,inst_mem_to_wb;

//pc_if的输出
wire  [31:0]rd;
wire  [31:0]pcplusf;
wire  [31:0]pcf;

//if_to_id的输出
wire [31:0]instrd;
wire [31:0]pcd;
wire [31:0]pcplusd;

//control的输出
  wire regwrited;   //判断寄存器是否写
  wire [2:0]resultsrcd;  //判断写入寄存器的东西，000时，alu的结果写入寄存器（r-type，beq），001时，内存读出的数据写入寄存器（lw，sw）
  wire memwrited;  //判断是否写内存
  wire jumpd;      //是否为跳转指令
  wire branchd;    //是否为分支指令（目前是beq）
  wire [3:0] alucontrold; //判断alu的操作
  wire alusrcd;    //判断alu的第二个操作数是寄存器还是立即数
  wire [2:0]immsrcd;    //不同指令，立即数的组成和扩展方式不同
//register的输出
 wire [31:0]rd1;        
 wire [31:0]rd2;
 //extend的输出
wire [31:0]immextd;
//id_to_ex的输出

wire   regwritee;    
wire   [2:0]resultsrce;
wire   memwritee;      
wire   jumpe;           
wire   branche;         
wire  [3:0] alucontrole;
wire  alusrce;
wire  [31:0] rd1e;
wire  [31:0] rd2e;
wire  [31:0]pce;
wire  [4:0]rs1e;
wire  [4:0]rs2e;
wire  [4:0]rde;
wire  [31:0]immexte;
wire [31:0]immextm_1;
wire [31:0]immextw;
wire [31:0] pcpluse; 

//alu的输出
 wire [31:0] pctargete;
 wire pcsrce;
 wire [31:0] aluresulte;
 wire [31:0] writedatae; 
//ex_to_mem的输出
 wire regwritem_1;
 wire [2:0]resultsrcm_1;
 wire memwritem_1;
 wire[31:0] aluresultm_1;
 wire [31:0]writedatam_1;
 wire [4:0]rdm_1;
 wire[31:0] pcplusm_1;
//data_memory的输出
 wire [31:0]rd_data;
//mem_to_wb的输出
 wire regwritew;
 wire [2:0]resultsrcw;
 wire [31:0]aluresultw;
 wire [31:0]readdataw;
 wire [4:0]rdw;
 wire[31:0] pcplusw;
//wb的输出
 wire [31:0]resultw;
//hazard的输出
 wire [2:0]forwardad;
 wire [2:0]forwardbd;
 wire [2:0]forwardae;
 wire [2:0]forwardbe;
 wire stallf;
 wire stalld;
 wire flushe;
 wire flushd;

//i型指令字节长度控制
wire [2:0]funct3e;
wire [2:0]funct3d;
wire [2:0]funct3m_1;

//auipc要加的信号
wire [31:0]pctargetm_1;
wire [31:0]pctargetw;


wire jalr_controld;
wire jalr_controle;

wire [31:0]pcm_1;
wire [31:0]pcw;

wire [31:0]pc_next;


//mem1_to_mem2的输出
wire       regwritem_2; 
wire [31:0]resultsrcm_2;
wire [31:0]aluresultm_2;
wire [31:0]rdm_2;       
wire [31:0]pcplusm_2;   
wire [31:0]pctargetm_2; 
wire [31:0]immextm_2;   
wire [31:0]pcm_2;
wire [2:0]funct3m_2;

wire [31:0]forward_data_m1;
wire [31:0]forward_data_m2;
wire [31:0]forward_data_w;


assign irom_addr     =   pcf        ;
assign rd            =   irom_data     ;     
assign perip_addr    =   aluresultm_1     ;
assign perip_wen     =   memwritem_1      ;
assign perip_mask    =   funct3m_1       ;
assign perip_wdata   =   writedatam_1    ;
assign rd_data       =   perip_rdata   ;

//在dram_driver中要用到的mem2的数据有perip_mask和offset
assign perip_mask_2 = funct3m_2;
assign perip_addr_2 = aluresultm_2;      


//assign debug_wb_pc           =       pcw     ;         // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
//assign debug_wb_ena          =       regwritew;         // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
//assign debug_wb_reg          =       rdw      ;         // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
//assign debug_wb_value        =       resultw  ;         // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)

pc_if pc_if(
    .rst       (cpu_rst) ,
    .pcsrce     (pcsrce) ,
    .pctargete  (pctargete) ,
    .clk        (cpu_clk) ,
    .stallf     (stallf),
    .pcplusf    (pcplusf) ,
    .pcf        (pcf),
    .pc_next    (pc_next)
);

if_to_id if_to_id(
   .rst         (cpu_rst),
   .rd          (rd),
   .pcf         (pcf),
   .pcplusf     (pcplusf),
   .stalld      (stalld ),
   .flushd      (flushd  ),
   .clk         (cpu_clk),
   .instrd      (instrd),
   .pcd         (pcd),
   .pcplusd     (pcplusd)
  // .inst_if_to_id  (inst_if_to_id)      //debug
);


control control(
    .rst           (cpu_rst),
    .op            (instrd[6:0]),
    .funct3        (instrd[14:12]),
    .funct7        (instrd[30]),
    .regwrited     (regwrited),      //判断寄存器是否写
    .resultsrcd    (resultsrcd ),      //判断写入寄存器的东西，0时，alu的结果写入寄存器（r-type，beq），1时，内存读出的数据写入寄存器（lw，sw）
    .memwrited     (memwrited),      //判断是否写内存
    .jumpd         (jumpd ),      //是否为跳转指令
    .branchd       (branchd),      //是否为分支指令（目前是beq）
    .alucontrold   (alucontrold),      //判断alu的操作
    .alusrcd       (alusrcd ),      //判断alu的第二个操作数是寄存器还是立即数
    .immsrcd       (immsrcd),       //不同指令，立即数的组成和扩展方式不同
    .funct3d      (funct3d),
    .jalr_controld   (jalr_controld)
);

register register(
    .a1         (instrd[19:15]),
    .a2         (instrd[24:20]),
    .a3         (rdw),
    .wd3        (resultw),
    .clk        (cpu_clk),
    .we3        (regwritew),
    .rd1        (rd1),
    .rd2        (rd2),
    .rst        (cpu_rst)
);

extend extend(
    .instrd         (instrd[31:7]),
    .immsrcd        (immsrcd),
    .immextd        (immextd)
);

id_to_ex id_to_ex(
    .rst                (cpu_rst        ),
    .clk                (cpu_clk        ),
    .regwrited          (regwrited      ),        //判断寄存器是否写
    .resultsrcd         (resultsrcd     ),  //判断写入寄存器的东西，0时，alu的结果写入寄存器（r-type，beq），1时，内存读出的数据写入寄存器（lw，sw）
    .memwrited          (memwrited      ),       //判断是否写内存
    .jumpd              (jumpd          ),           //是否为跳转指令
    .branchd            (branchd        ),         //是否为分支指令（目前是beq）
    .alucontrold        (alucontrold    ), //判断alu的操作
    .alusrcd            (alusrcd        ),         //判断alu的第二个操作数是寄存器还是立即数
    .rd1                (rd1            ),
    .rd2                (rd2            ),
    .pcd                (pcd            ),
    .rs1d               (instrd[19:15]  ),
    .rs2d               (instrd[24:20]  ),
    .rdd                (instrd[11:7]   ),
    .immextd            (immextd        ),   
    .pcplusd            (pcplusd        ),
    .flushe             (flushe         ),
    .regwritee          (regwritee      ),       
    .resultsrce         (resultsrce     ), 
    .memwritee          (memwritee      ),       
    .jumpe              (jumpe          ),           
    .branche            (branche        ),         
    .alucontrole        (alucontrole    ),
    .alusrce            (alusrce        ),
    .rd1e               (rd1e           ),
    .rd2e               (rd2e           ),
    .pce                (pce            ),
    .rs1e               (rs1e           ),
    .rs2e               (rs2e           ),
    .rde                (rde            ),
    .immexte            (immexte        ),
    .pcpluse            (pcpluse        ),
    .funct3d            (funct3d        ),
    .funct3e            (funct3e        ),
    .jalr_controld      (jalr_controld  ),
    .jalr_controle      (jalr_controle  ),
    .forwardae          (forwardae),
    .forwardbe          (forwardbe),
    .forwardad          (forwardad),
    .forwardbd          (forwardbd)
   // .inst_if_to_id      (inst_if_to_id ),
   // .inst_id_to_ex      (inst_id_to_ex )
);


alu  alu(
    .rd1e               (rd1e           ), //连接srcae的选择器
    //.resultw            (resultw        ),
    //.aluresultm_1       (aluresultm_1   ),
   // .aluresultm_2       (aluresultm_2   ),
    .forwardae          (forwardae      ),
    .rd2e               (rd2e           ),
    .forwardbe          (forwardbe      ),    //下面那个选择器
    .alusrce            (alusrce        ),      //srcb前面的选择器
    .immexte            (immexte        ),
    .pce                (pce            ),   
    .jumpe              (jumpe          ),
    .branche            (branche        ),
    .alucontrole        (alucontrole    ),
    .pctargete          (pctargete      ),
    .pcsrce             (pcsrce         ),
    .aluresulte         (aluresulte     ),
    .writedatae         (writedatae     ),
    .funct3e            (funct3e        ),
   //.pctargetm_1        (pctargetm_1    ),
    //.pctargetm_2        (pctargetm_2    ),
    //.immextm_1          (immextm_1      ),
    //.immextm_2          (immextm_2      ),
    .jalr_controle      (jalr_controle),
    .forward_data_m1    (forward_data_m1),
    .forward_data_m2    (forward_data_m2),
    .forward_data_w    (forward_data_w)

);

ex_to_mem1 ex_to_mem1(
    .rst                      (cpu_rst        ),
    .clk                      (cpu_clk        ),
    .regwritee                (regwritee      ),
    .resultsrce               (resultsrce     ),
    .memwritee                (memwritee      ),
    .aluresulte               (aluresulte     ),
    .writedatae               (writedatae     ),
    .rde                      (rde            ),
    .pcpluse                  (pcpluse        ),  
    .regwritem_1              (regwritem_1    ),
    .resultsrcm_1             (resultsrcm_1   ),
    .memwritem_1              (memwritem_1    ),
    .aluresultm_1             (aluresultm_1   ),
    .writedatam_1             (writedatam_1   ),
    .rdm_1                    (rdm_1          ),
    .pcplusm_1                (pcplusm_1      ),
    .funct3e                  (funct3e        ),
    .funct3m_1                (funct3m_1      ),
    .pctargete                (pctargete      ),
    .pctargetm_1              (pctargetm_1    ),
    .immexte                  (immexte        ),
    .immextm_1                (immextm_1      ),
    .pce                      (pce            ),
    .pcm_1                    (pcm_1          ),
    .forward_data_m1            (forward_data_m1)
   // .inst_id_to_ex          (inst_id_to_ex  ),
   // .inst_ex_to_mem         (inst_ex_to_mem )
);


/*data_memory data_memory(
     .clk				    (clk),

     .perip_addr			(aluresultm[17:0]),       //a                                    
     .perip_wdata		    (writedatam),       //wd
	 .perip_mask			(funct3m[1:0]),     
     .dram_wen              (memwritem),  //we
     .perip_rdata		    (rd_data)      //rd
);*/

mem1_to_mem2 mem1_to_mem2(
.clk                       (cpu_clk       )     ,
.rst                       (cpu_rst       )     ,
.regwritem_1               (regwritem_1   )     ,
.resultsrcm_1              (resultsrcm_1  )     ,
.aluresultm_1              (aluresultm_1  )     ,
.rdm_1                     (rdm_1         )     ,
.pcplusm_1                 (pcplusm_1     )     , 
.pctargetm_1               (pctargetm_1   )     ,
.immextm_1                 (immextm_1     )     ,
.pcm_1                     (pcm_1         )     ,
.regwritem_2               (regwritem_2   )     ,
.resultsrcm_2              (resultsrcm_2  )     ,
.aluresultm_2              (aluresultm_2  )     ,
.rdm_2                     (rdm_2         )     ,
.pcplusm_2                 (pcplusm_2     )     ,
.pctargetm_2               (pctargetm_2   )     ,
.immextm_2                 (immextm_2     )     ,
.pcm_2                     (pcm_2         )     ,
.funct3m_1                 (funct3m_1     )     ,
.funct3m_2                 (funct3m_2     )     ,
.forward_data_m2            (forward_data_m2)   
);

mem2_to_wb mem2_to_wb(

    .clk               (cpu_clk       ),
    .rst               (cpu_rst       ),
    .regwritem_2       (regwritem_2   ),
    .resultsrcm_2      (resultsrcm_2  ),
    .aluresultm_2      (aluresultm_2  ),
    .rd                (rd_data       ),
    .rdm_2             (rdm_2         ),
    .pcplusm_2         (pcplusm_2     ),
    .regwritew         (regwritew     ),
    .resultsrcw        (resultsrcw    ),
    .aluresultw        (aluresultw    ),
    .readdataw         (readdataw     ),
    .rdw               (rdw           ),
    .pcplusw           (pcplusw       ),
    .pctargetw         (pctargetw     ),
    .pctargetm_2       (pctargetm_2   ),
    .immextm_2         (immextm_2     ),
    .immextw           (immextw       ),
    .pcm_2             (pcm_2         ),
    .pcw               (pcw           )
    // .inst_ex_to_mem     (inst_ex_to_mem ),
    //.inst_mem_to_wb     (debug_wb_have_inst )

);




wb wb(
    .resultsrcw         (resultsrcw),
    .aluresultw         (aluresultw),
    .readdataw          (readdataw ),
    .pcplusw            (pcplusw   ),
    .resultw            (resultw   ),
    .pctargetw          (pctargetw ),
    .immextw            (immextw   ),
    .forward_data_w     (forward_data_w)
);

hazard hazard(
    //.rs1e           (rs1e           ),
    // .rs2e           (rs2e           ),
    .rs1d           (instrd[19:15]  ),
    .rs2d           (instrd[24:20]  ),
    .rdm_1          (rdm_1          ),
    .rdm_2          (rdm_2          ),
    //.rdw            (rdw            ),
    .rde            (rde            ),
    .regwritem_1    (regwritem_1    ),
    .regwritem_2    (regwritem_2    ),
    .regwritee      (regwritee      ),
    .resultsrce0    (resultsrce[0]  ),
    .pcsrce         (pcsrce         ),
    .forwardad      (forwardad      ),
    .forwardbd      (forwardbd      ),
    .stallf         (stallf         ),
    .stalld         (stalld         ),
    .flushe         (flushe         ),
    .flushd         (flushd         ),
    .resultsrcm_1   (resultsrcm_1   ),
    .resultsrcm_2   (resultsrcm_2   )

);


endmodule