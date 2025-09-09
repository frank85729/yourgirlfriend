`include "defines.v"

// 指令存储器模块
module instruction_memory (
    input  wire [`ADDR_WIDTH-1:0]      addr,       // 指令地址
    output wire [`INST_WIDTH-1:0]      inst        // 指令输出
);

    // 指令存储器，使用ROM实现
    reg [`INST_WIDTH-1:0] inst_mem [0:1023];  // 1024个32位指令
    
    // 初始化指令存储器（可以在testbench中加载程序）
    integer i;
    initial begin
        // 默认初始化为NOP指令
        for (i = 0; i < 1024; i = i + 1) begin
            inst_mem[i] = 32'h00000013; // addi x0, x0, 0 (NOP)
        end
    end
    
    // 读取指令，地址按字对齐（除以4）
    assign inst = inst_mem[addr[11:2]];

endmodule