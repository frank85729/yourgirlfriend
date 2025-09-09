`include "defines.v"

// 转发单元
module forwarding_unit (
    // EX阶段信号
    input  wire [`REG_ADDR_WIDTH-1:0]  ex_rs1_addr,   // EX阶段源寄存器1地址
    input  wire [`REG_ADDR_WIDTH-1:0]  ex_rs2_addr,   // EX阶段源寄存器2地址
    
    // MEM阶段信号
    input  wire [`REG_ADDR_WIDTH-1:0]  mem_rd_addr,   // MEM阶段目标寄存器地址
    input  wire                         mem_reg_write, // MEM阶段寄存器写信号
    
    // WB阶段信号
    input  wire [`REG_ADDR_WIDTH-1:0]  wb_rd_addr,    // WB阶段目标寄存器地址
    input  wire                         wb_reg_write,  // WB阶段寄存器写信号
    
    // 转发控制输出
    output wire [1:0]                   forward_a,     // ALU输入A转发控制
    output wire [1:0]                   forward_b      // ALU输入B转发控制
);

    // 转发A (rs1)
    assign forward_a = 
        // EX-EX转发（MEM阶段到EX阶段）
        (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs1_addr)) ? `FORWARD_EX :
        // MEM-EX转发（WB阶段到EX阶段）
        (wb_reg_write && (wb_rd_addr != 5'b0) && (wb_rd_addr == ex_rs1_addr) &&
         !(mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs1_addr))) ? `FORWARD_MEM :
        // 无转发
        `FORWARD_NO;
    
    // 转发B (rs2)
    assign forward_b = 
        // EX-EX转发（MEM阶段到EX阶段）
        (mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs2_addr)) ? `FORWARD_EX :
        // MEM-EX转发（WB阶段到EX阶段）
        (wb_reg_write && (wb_rd_addr != 5'b0) && (wb_rd_addr == ex_rs2_addr) &&
         !(mem_reg_write && (mem_rd_addr != 5'b0) && (mem_rd_addr == ex_rs2_addr))) ? `FORWARD_MEM :
        // 无转发
        `FORWARD_NO;

endmodule