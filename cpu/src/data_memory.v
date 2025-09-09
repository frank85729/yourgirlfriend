`include "defines.v"

// 数据存储器模块
module data_memory (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         mem_read,   // 读使能
    input  wire                         mem_write,  // 写使能
    input  wire [`ADDR_WIDTH-1:0]      addr,       // 地址
    input  wire [`DATA_WIDTH-1:0]      write_data, // 写入数据
    output wire [`DATA_WIDTH-1:0]      read_data   // 读出数据
);

    // 数据存储器，使用RAM实现
    reg [`DATA_WIDTH-1:0] data_mem [0:1023];  // 1024个32位数据
    
    // 初始化数据存储器
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_mem[i] = `DATA_WIDTH'h0;
        end
    end
    
    // 写操作（同步）
    always @(posedge clk) begin
        if (mem_write) begin
            data_mem[addr[11:2]] <= write_data;  // 按字对齐
        end
    end
    
    // 读操作（异步）
    assign read_data = mem_read ? data_mem[addr[11:2]] : `DATA_WIDTH'h0;

endmodule