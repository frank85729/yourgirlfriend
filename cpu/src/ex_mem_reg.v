`include "defines.v"

// EX/MEM流水线寄存器
module ex_mem_reg (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         stall,      // 暂停信号
    input  wire                         flush,      // 清空信号
    
    // 输入信号
    input  wire [`ADDR_WIDTH-1:0]      pc_in,      // PC值
    input  wire [`DATA_WIDTH-1:0]      alu_result_in,  // ALU结果
    input  wire [`DATA_WIDTH-1:0]      rs2_data_in,    // 源寄存器2数据（用于存储）
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_addr_in,     // 目标寄存器地址
    input  wire                         branch_taken_in,// 分支是否跳转
    
    // 控制信号输入
    input  wire                         reg_write_in,
    input  wire                         mem_read_in,
    input  wire                         mem_write_in,
    input  wire [1:0]                  wb_src_in,
    
    // 输出信号
    output reg  [`ADDR_WIDTH-1:0]      pc_out,
    output reg  [`DATA_WIDTH-1:0]      alu_result_out,
    output reg  [`DATA_WIDTH-1:0]      rs2_data_out,
    output reg  [`REG_ADDR_WIDTH-1:0]  rd_addr_out,
    output reg                          branch_taken_out,
    
    // 控制信号输出
    output reg                          reg_write_out,
    output reg                          mem_read_out,
    output reg                          mem_write_out,
    output reg  [1:0]                   wb_src_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out           <= `ADDR_WIDTH'h0;
            alu_result_out   <= `DATA_WIDTH'h0;
            rs2_data_out     <= `DATA_WIDTH'h0;
            rd_addr_out      <= `REG_ADDR_WIDTH'h0;
            branch_taken_out <= 1'b0;
            
            reg_write_out    <= `REG_WRITE_DISABLE;
            mem_read_out     <= `MEM_READ_DISABLE;
            mem_write_out    <= `MEM_WRITE_DISABLE;
            wb_src_out       <= `WB_SRC_ALU;
        end else if (!stall) begin
            pc_out           <= pc_in;
            alu_result_out   <= alu_result_in;
            rs2_data_out     <= rs2_data_in;
            rd_addr_out      <= rd_addr_in;
            branch_taken_out <= branch_taken_in;
            
            reg_write_out    <= reg_write_in;
            mem_read_out     <= mem_read_in;
            mem_write_out    <= mem_write_in;
            wb_src_out       <= wb_src_in;
        end
    end

endmodule