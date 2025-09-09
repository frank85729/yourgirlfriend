`include "defines.v"

// IF/ID流水线寄存器
module if_id_reg (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         stall,      // 暂停信号
    input  wire                         flush,      // 清空信号
    
    // 输入信号
    input  wire [`ADDR_WIDTH-1:0]      pc_in,      // PC值
    input  wire [`INST_WIDTH-1:0]      inst_in,    // 指令
    
    // 输出信号
    output reg  [`ADDR_WIDTH-1:0]      pc_out,     // PC值
    output reg  [`INST_WIDTH-1:0]      inst_out    // 指令
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out   <= `ADDR_WIDTH'h0;
            inst_out <= `INST_WIDTH'h00000013;  // NOP指令
        end else if (!stall) begin
            pc_out   <= pc_in;
            inst_out <= inst_in;
        end
        // 如果stall为高，寄存器保持不变
    end

endmodule