`include "defines.v"

// 五级流水线CPU顶层模块
module cpu_top (
    input  wire                         clk,
    input  wire                         rst_n
);

    // ========== 信号声明 ==========
    
    // PC相关信号
    wire [`ADDR_WIDTH-1:0]      pc;
    wire [`ADDR_WIDTH-1:0]      pc_plus4;
    wire [`ADDR_WIDTH-1:0]      pc_next;
    
    // IF阶段信号
    wire [`INST_WIDTH-1:0]      if_instruction;
    
    // IF/ID流水线寄存器信号
    wire [`ADDR_WIDTH-1:0]      id_pc;
    wire [`INST_WIDTH-1:0]      id_instruction;
    
    // ID阶段信号
    wire [6:0]                  opcode;
    wire [2:0]                  funct3;
    wire [6:0]                  funct7;
    wire [`REG_ADDR_WIDTH-1:0]  rs1_addr;
    wire [`REG_ADDR_WIDTH-1:0]  rs2_addr;
    wire [`REG_ADDR_WIDTH-1:0]  rd_addr;
    wire [`DATA_WIDTH-1:0]      rs1_data;
    wire [`DATA_WIDTH-1:0]      rs2_data;
    wire [`DATA_WIDTH-1:0]      immediate;
    
    // 控制信号
    wire                        reg_write;
    wire                        mem_read;
    wire                        mem_write;
    wire                        branch;
    wire                        jump;
    wire                        alu_src;
    wire [1:0]                  wb_src;
    wire [3:0]                  alu_op;
    
    // ID/EX流水线寄存器信号
    wire [`ADDR_WIDTH-1:0]      ex_pc;
    wire [`DATA_WIDTH-1:0]      ex_rs1_data;
    wire [`DATA_WIDTH-1:0]      ex_rs2_data;
    wire [`DATA_WIDTH-1:0]      ex_immediate;
    wire [`REG_ADDR_WIDTH-1:0]  ex_rs1_addr;
    wire [`REG_ADDR_WIDTH-1:0]  ex_rs2_addr;
    wire [`REG_ADDR_WIDTH-1:0]  ex_rd_addr;
    wire                        ex_reg_write;
    wire                        ex_mem_read;
    wire                        ex_mem_write;
    wire                        ex_branch;
    wire                        ex_jump;
    wire                        ex_alu_src;
    wire [1:0]                  ex_wb_src;
    wire [3:0]                  ex_alu_op;
    wire [2:0]                  ex_funct3;
    
    // EX阶段信号
    wire [`DATA_WIDTH-1:0]      alu_operand_a;
    wire [`DATA_WIDTH-1:0]      alu_operand_b;
    wire [`DATA_WIDTH-1:0]      alu_result;
    wire                        alu_zero;
    wire                        branch_taken;
    wire [`ADDR_WIDTH-1:0]      branch_target;
    wire [`DATA_WIDTH-1:0]      forwarded_rs1_data;
    wire [`DATA_WIDTH-1:0]      forwarded_rs2_data;
    
    // EX/MEM流水线寄存器信号
    wire [`ADDR_WIDTH-1:0]      mem_pc;
    wire [`DATA_WIDTH-1:0]      mem_alu_result;
    wire [`DATA_WIDTH-1:0]      mem_rs2_data;
    wire [`REG_ADDR_WIDTH-1:0]  mem_rd_addr;
    wire                        mem_branch_taken;
    wire                        mem_reg_write;
    wire                        mem_mem_read;
    wire                        mem_mem_write;
    wire [1:0]                  mem_wb_src;
    
    // MEM阶段信号
    wire [`DATA_WIDTH-1:0]      mem_read_data;
    
    // MEM/WB流水线寄存器信号
    wire [`ADDR_WIDTH-1:0]      wb_pc;
    wire [`DATA_WIDTH-1:0]      wb_alu_result;
    wire [`DATA_WIDTH-1:0]      wb_mem_data;
    wire [`REG_ADDR_WIDTH-1:0]  wb_rd_addr;
    wire                        wb_reg_write;
    wire [1:0]                  wb_wb_src;
    
    // WB阶段信号
    wire [`DATA_WIDTH-1:0]      wb_data;
    
    // 冒险检测和转发信号
    wire                        pc_stall;
    wire                        if_id_stall;
    wire                        if_id_flush;
    wire                        id_ex_flush;
    wire [1:0]                  forward_a;
    wire [1:0]                  forward_b;
    
    // ========== 模块实例化 ==========
    
    // PC寄存器
    assign pc_plus4 = pc + 4;
    
    pc_reg u_pc_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .stall      (pc_stall),
        .pc_next    (pc_next),
        .pc         (pc)
    );
    
    // PC多路选择器
    pc_mux u_pc_mux (
        .pc_plus4       (pc_plus4),
        .branch_target  (branch_target),
        .branch_taken   (branch_taken),
        .jump           (ex_jump),
        .pc_next        (pc_next)
    );
    
    // 指令存储器
    instruction_memory u_instruction_memory (
        .addr   (pc),
        .inst   (if_instruction)
    );
    
    // IF/ID流水线寄存器
    if_id_reg u_if_id_reg (
        .clk        (clk),
        .rst_n      (rst_n),
        .stall      (if_id_stall),
        .flush      (if_id_flush),
        .pc_in      (pc),
        .inst_in    (if_instruction),
        .pc_out     (id_pc),
        .inst_out   (id_instruction)
    );
    
    // 指令解码
    assign opcode   = id_instruction[6:0];
    assign funct3   = id_instruction[14:12];
    assign funct7   = id_instruction[31:25];
    assign rs1_addr = id_instruction[19:15];
    assign rs2_addr = id_instruction[24:20];
    assign rd_addr  = id_instruction[11:7];
    
    // 寄存器文件
    register_file u_register_file (
        .clk        (clk),
        .rst_n      (rst_n),
        .rs1_addr   (rs1_addr),
        .rs1_data   (rs1_data),
        .rs2_addr   (rs2_addr),
        .rs2_data   (rs2_data),
        .reg_write  (wb_reg_write),
        .rd_addr    (wb_rd_addr),
        .rd_data    (wb_data)
    );
    
    // 立即数生成器
    immediate_generator u_immediate_generator (
        .instruction    (id_instruction),
        .immediate      (immediate)
    );
    
    // 控制单元
    control_unit u_control_unit (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .branch     (branch),
        .jump       (jump),
        .alu_src    (alu_src),
        .wb_src     (wb_src),
        .alu_op     (alu_op)
    );
    
    // ID/EX流水线寄存器
    id_ex_reg u_id_ex_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (1'b0),
        .flush          (id_ex_flush),
        .pc_in          (id_pc),
        .rs1_data_in    (rs1_data),
        .rs2_data_in    (rs2_data),
        .immediate_in   (immediate),
        .rs1_addr_in    (rs1_addr),
        .rs2_addr_in    (rs2_addr),
        .rd_addr_in     (rd_addr),
        .reg_write_in   (reg_write),
        .mem_read_in    (mem_read),
        .mem_write_in   (mem_write),
        .branch_in      (branch),
        .jump_in        (jump),
        .alu_src_in     (alu_src),
        .wb_src_in      (wb_src),
        .alu_op_in      (alu_op),
        .funct3_in      (id_instruction[14:12]),
        .pc_out         (ex_pc),
        .rs1_data_out   (ex_rs1_data),
        .rs2_data_out   (ex_rs2_data),
        .immediate_out  (ex_immediate),
        .rs1_addr_out   (ex_rs1_addr),
        .rs2_addr_out   (ex_rs2_addr),
        .rd_addr_out    (ex_rd_addr),
        .reg_write_out  (ex_reg_write),
        .mem_read_out   (ex_mem_read),
        .mem_write_out  (ex_mem_write),
        .branch_out     (ex_branch),
        .jump_out       (ex_jump),
        .alu_src_out    (ex_alu_src),
        .wb_src_out     (ex_wb_src),
        .alu_op_out     (ex_alu_op),
        .funct3_out     (ex_funct3)
    );
    
    // 转发单元
    forwarding_unit u_forwarding_unit (
        .ex_rs1_addr    (ex_rs1_addr),
        .ex_rs2_addr    (ex_rs2_addr),
        .mem_rd_addr    (mem_rd_addr),
        .mem_reg_write  (mem_reg_write),
        .wb_rd_addr     (wb_rd_addr),
        .wb_reg_write   (wb_reg_write),
        .forward_a      (forward_a),
        .forward_b      (forward_b)
    );
    
    // 转发多路选择器
    assign forwarded_rs1_data = (forward_a == `FORWARD_EX)  ? mem_alu_result :
                               (forward_a == `FORWARD_MEM) ? wb_data :
                               ex_rs1_data;
    
    assign forwarded_rs2_data = (forward_b == `FORWARD_EX)  ? mem_alu_result :
                               (forward_b == `FORWARD_MEM) ? wb_data :
                               ex_rs2_data;
    
    // ALU输入选择
    assign alu_operand_a = forwarded_rs1_data;
    assign alu_operand_b = ex_alu_src ? ex_immediate : forwarded_rs2_data;
    
    // ALU
    alu u_alu (
        .operand_a  (alu_operand_a),
        .operand_b  (alu_operand_b),
        .alu_op     (ex_alu_op),
        .result     (alu_result),
        .zero       (alu_zero)
    );
    
    // 分支单元
    branch_unit u_branch_unit (
        .rs1_data       (forwarded_rs1_data),
        .rs2_data       (forwarded_rs2_data),
        .pc             (ex_pc),
        .immediate      (ex_immediate),
        .branch         (ex_branch),
        .jump           (ex_jump),
        .funct3         (ex_funct3),
        .branch_taken   (branch_taken),
        .branch_target  (branch_target)
    );
    
    // EX/MEM流水线寄存器
    ex_mem_reg u_ex_mem_reg (
        .clk                (clk),
        .rst_n              (rst_n),
        .stall              (1'b0),
        .flush              (1'b0),
        .pc_in              (ex_pc),
        .alu_result_in      (alu_result),
        .rs2_data_in        (forwarded_rs2_data),
        .rd_addr_in         (ex_rd_addr),
        .branch_taken_in    (branch_taken),
        .reg_write_in       (ex_reg_write),
        .mem_read_in        (ex_mem_read),
        .mem_write_in       (ex_mem_write),
        .wb_src_in          (ex_wb_src),
        .pc_out             (mem_pc),
        .alu_result_out     (mem_alu_result),
        .rs2_data_out       (mem_rs2_data),
        .rd_addr_out        (mem_rd_addr),
        .branch_taken_out   (mem_branch_taken),
        .reg_write_out      (mem_reg_write),
        .mem_read_out       (mem_mem_read),
        .mem_write_out      (mem_mem_write),
        .wb_src_out         (mem_wb_src)
    );
    
    // 数据存储器
    data_memory u_data_memory (
        .clk        (clk),
        .rst_n      (rst_n),
        .mem_read   (mem_mem_read),
        .mem_write  (mem_mem_write),
        .addr       (mem_alu_result),
        .write_data (mem_rs2_data),
        .read_data  (mem_read_data)
    );
    
    // MEM/WB流水线寄存器
    mem_wb_reg u_mem_wb_reg (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (1'b0),
        .flush          (1'b0),
        .pc_in          (mem_pc),
        .alu_result_in  (mem_alu_result),
        .mem_data_in    (mem_read_data),
        .rd_addr_in     (mem_rd_addr),
        .reg_write_in   (mem_reg_write),
        .wb_src_in      (mem_wb_src),
        .pc_out         (wb_pc),
        .alu_result_out (wb_alu_result),
        .mem_data_out   (wb_mem_data),
        .rd_addr_out    (wb_rd_addr),
        .reg_write_out  (wb_reg_write),
        .wb_src_out     (wb_wb_src)
    );
    
    // 写回多路选择器
    writeback_mux u_writeback_mux (
        .alu_result (wb_alu_result),
        .mem_data   (wb_mem_data),
        .pc_plus4   (wb_pc + 4),
        .wb_src     (wb_wb_src),
        .wb_data    (wb_data)
    );
    
    // 冒险检测单元
    hazard_detection_unit u_hazard_detection_unit (
        .id_rs1_addr    (rs1_addr),
        .id_rs2_addr    (rs2_addr),
        .ex_rd_addr     (ex_rd_addr),
        .ex_mem_read    (ex_mem_read),
        .ex_reg_write   (ex_reg_write),
        .mem_rd_addr    (mem_rd_addr),
        .mem_reg_write  (mem_reg_write),
        .branch_taken   (branch_taken),
        .jump           (ex_jump),
        .pc_stall       (pc_stall),
        .if_id_stall    (if_id_stall),
        .if_id_flush    (if_id_flush),
        .id_ex_flush    (id_ex_flush),
        .forward_a      (),  // 未使用，由转发单元处理
        .forward_b      ()   // 未使用，由转发单元处理
    );

endmodule