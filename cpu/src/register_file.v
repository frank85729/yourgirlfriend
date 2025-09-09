`include "defines.v"

// 寄存器文件模块
module register_file (
    input  wire                         clk,
    input  wire                         rst_n,
    
    // 读端口1
    input  wire [`REG_ADDR_WIDTH-1:0]  rs1_addr,   // 源寄存器1地址
    output wire [`DATA_WIDTH-1:0]      rs1_data,   // 源寄存器1数据
    
    // 读端口2
    input  wire [`REG_ADDR_WIDTH-1:0]  rs2_addr,   // 源寄存器2地址
    output wire [`DATA_WIDTH-1:0]      rs2_data,   // 源寄存器2数据
    
    // 写端口
    input  wire                         reg_write,  // 写使能
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_addr,    // 目标寄存器地址
    input  wire [`DATA_WIDTH-1:0]      rd_data     // 写入数据
);

    // 32个32位寄存器
    reg [`DATA_WIDTH-1:0] registers [0:`REG_NUM-1];
    
    // 初始化寄存器
    integer i;
    initial begin
        for (i = 0; i < `REG_NUM; i = i + 1) begin
            registers[i] = `DATA_WIDTH'h0;
        end
    end
    
    // 写操作（同步）
    always @(posedge clk) begin
        if (reg_write && rd_addr != 5'b0) begin  // x0寄存器始终为0，不能写入
            registers[rd_addr] <= rd_data;
        end
    end
    
    // 读操作（异步，支持内部转发）
    assign rs1_data = (rs1_addr == 5'b0) ? `DATA_WIDTH'h0 : 
                     (reg_write && (rd_addr == rs1_addr) && (rd_addr != 5'b0)) ? rd_data : 
                     registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? `DATA_WIDTH'h0 : 
                     (reg_write && (rd_addr == rs2_addr) && (rd_addr != 5'b0)) ? rd_data : 
                     registers[rs2_addr];

endmodule