`include "defines.v"

// MEM/WB流水线寄存器
module mem_wb_reg (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         stall,      // 暂停信号
    input  wire                         flush,      // 清空信号
    
    // 输入信号
    input  wire [`ADDR_WIDTH-1:0]      pc_in,      // PC值
    input  wire [`DATA_WIDTH-1:0]      alu_result_in,  // ALU结果
    input  wire [`DATA_WIDTH-1:0]      mem_data_in,    // 内存数据
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_addr_in,     // 目标寄存器地址
    
    // 控制信号输入
    input  wire                         reg_write_in,
    input  wire [1:0]                  wb_src_in,
    
    // 输出信号
    output reg  [`ADDR_WIDTH-1:0]      pc_out,
    output reg  [`DATA_WIDTH-1:0]      alu_result_out,
    output reg  [`DATA_WIDTH-1:0]      mem_data_out,
    output reg  [`REG_ADDR_WIDTH-1:0]  rd_addr_out,
    
    // 控制信号输出
    output reg                          reg_write_out,
    output reg  [1:0]                   wb_src_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out         <= `ADDR_WIDTH'h0;
            alu_result_out <= `DATA_WIDTH'h0;
            mem_data_out   <= `DATA_WIDTH'h0;
            rd_addr_out    <= `REG_ADDR_WIDTH'h0;
            
            reg_write_out  <= `REG_WRITE_DISABLE;
            wb_src_out     <= `WB_SRC_ALU;
        end else if (!stall) begin
            pc_out         <= pc_in;
            alu_result_out <= alu_result_in;
            mem_data_out   <= mem_data_in;
            rd_addr_out    <= rd_addr_in;
            
            reg_write_out  <= reg_write_in;
            wb_src_out     <= wb_src_in;
        end
    end

endmodule