`include "defines.v"

// 冒险检测单元
module hazard_detection_unit (
    // ID阶段信号
    input  wire [`REG_ADDR_WIDTH-1:0]  id_rs1_addr,   // ID阶段源寄存器1地址
    input  wire [`REG_ADDR_WIDTH-1:0]  id_rs2_addr,   // ID阶段源寄存器2地址
    
    // EX阶段信号
    input  wire [`REG_ADDR_WIDTH-1:0]  ex_rd_addr,    // EX阶段目标寄存器地址
    input  wire                         ex_mem_read,   // EX阶段内存读信号
    input  wire                         ex_reg_write,  // EX阶段寄存器写信号
    
    // MEM阶段信号
    input  wire [`REG_ADDR_WIDTH-1:0]  mem_rd_addr,   // MEM阶段目标寄存器地址
    input  wire                         mem_reg_write, // MEM阶段寄存器写信号
    
    // 控制冒险信号
    input  wire                         branch_taken,  // 分支跳转信号
    input  wire                         jump,          // 跳转信号
    
    // 输出控制信号
    output wire                         pc_stall,      // PC暂停
    output wire                         if_id_stall,   // IF/ID暂停
    output wire                         if_id_flush,   // IF/ID清空
    output wire                         id_ex_flush,   // ID/EX清空
    output wire [1:0]                   forward_a,     // 转发控制A
    output wire [1:0]                   forward_b      // 转发控制B
);

    // Load-Use冒险检测
    wire load_use_hazard = ex_mem_read && ex_reg_write && 
                          (ex_rd_addr != 5'b0) &&
                          ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr));
    
    // 控制冒险处理
    wire control_hazard = branch_taken || jump;
    
    // 暂停和清空信号
    assign pc_stall     = load_use_hazard;
    assign if_id_stall  = load_use_hazard;
    assign if_id_flush  = control_hazard;
    assign id_ex_flush  = load_use_hazard || control_hazard;
    
    // 转发控制逻辑
    // 转发A (rs1)
    assign forward_a = (ex_reg_write && (ex_rd_addr != 5'b0) && (ex_rd_addr == id_rs1_addr)) ? `FORWARD_EX :
                      (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == id_rs1_addr) &&
                       !(ex_reg_write && (ex_rd_addr != 5'b0) && (ex_rd_addr == id_rs1_addr))) ? `FORWARD_MEM :
                      `FORWARD_NO;
    
    // 转发B (rs2)
    assign forward_b = (ex_reg_write && (ex_rd_addr != 5'b0) && (ex_rd_addr == id_rs2_addr)) ? `FORWARD_EX :
                      (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == id_rs2_addr) &&
                       !(ex_reg_write && (ex_rd_addr != 5'b0) && (ex_rd_addr == id_rs2_addr))) ? `FORWARD_MEM :
                      `FORWARD_NO;

endmodule