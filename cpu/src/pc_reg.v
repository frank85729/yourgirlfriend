`include "defines.v"

// PC寄存器模块
module pc_reg (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         stall,      // 流水线暂停信号
    input  wire [`ADDR_WIDTH-1:0]      pc_next,    // 下一个PC值
    output reg  [`ADDR_WIDTH-1:0]      pc          // 当前PC值
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= `ADDR_WIDTH'h0;
        end else if (!stall) begin
            pc <= pc_next;
        end
        // 如果stall为高，PC保持不变
    end

endmodule