`include "defines.v"

// ID/EX流水线寄存器
module id_ex_reg (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         stall,      // 暂停信号
    input  wire                         flush,      // 清空信号
    
    // 输入信号
    input  wire [`ADDR_WIDTH-1:0]      pc_in,      // PC值
    input  wire [`DATA_WIDTH-1:0]      rs1_data_in,// 源寄存器1数据
    input  wire [`DATA_WIDTH-1:0]      rs2_data_in,// 源寄存器2数据
    input  wire [`DATA_WIDTH-1:0]      immediate_in,// 立即数
    input  wire [`REG_ADDR_WIDTH-1:0]  rs1_addr_in,// 源寄存器1地址
    input  wire [`REG_ADDR_WIDTH-1:0]  rs2_addr_in,// 源寄存器2地址
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_addr_in, // 目标寄存器地址
    
    // 控制信号输入
    input  wire                         reg_write_in,
    input  wire                         mem_read_in,
    input  wire                         mem_write_in,
    input  wire                         branch_in,
    input  wire                         jump_in,
    input  wire                         alu_src_in,
    input  wire [1:0]                  wb_src_in,
    input  wire [3:0]                  alu_op_in,
    input  wire [2:0]                  funct3_in,
    
    // 输出信号
    output reg  [`ADDR_WIDTH-1:0]      pc_out,
    output reg  [`DATA_WIDTH-1:0]      rs1_data_out,
    output reg  [`DATA_WIDTH-1:0]      rs2_data_out,
    output reg  [`DATA_WIDTH-1:0]      immediate_out,
    output reg  [`REG_ADDR_WIDTH-1:0]  rs1_addr_out,
    output reg  [`REG_ADDR_WIDTH-1:0]  rs2_addr_out,
    output reg  [`REG_ADDR_WIDTH-1:0]  rd_addr_out,
    
    // 控制信号输出
    output reg                          reg_write_out,
    output reg                          mem_read_out,
    output reg                          mem_write_out,
    output reg                          branch_out,
    output reg                          jump_out,
    output reg                          alu_src_out,
    output reg  [1:0]                   wb_src_out,
    output reg  [3:0]                   alu_op_out,
    output reg  [2:0]                   funct3_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            pc_out         <= `ADDR_WIDTH'h0;
            rs1_data_out   <= `DATA_WIDTH'h0;
            rs2_data_out   <= `DATA_WIDTH'h0;
            immediate_out  <= `DATA_WIDTH'h0;
            rs1_addr_out   <= `REG_ADDR_WIDTH'h0;
            rs2_addr_out   <= `REG_ADDR_WIDTH'h0;
            rd_addr_out    <= `REG_ADDR_WIDTH'h0;
            
            reg_write_out  <= `REG_WRITE_DISABLE;
            mem_read_out   <= `MEM_READ_DISABLE;
            mem_write_out  <= `MEM_WRITE_DISABLE;
            branch_out     <= `BRANCH_DISABLE;
            jump_out       <= `JUMP_DISABLE;
            alu_src_out    <= `ALU_SRC_REG;
            wb_src_out     <= `WB_SRC_ALU;
            alu_op_out     <= `ALU_ADD;
            funct3_out     <= 3'b000;
        end else if (!stall) begin
            pc_out         <= pc_in;
            rs1_data_out   <= rs1_data_in;
            rs2_data_out   <= rs2_data_in;
            immediate_out  <= immediate_in;
            rs1_addr_out   <= rs1_addr_in;
            rs2_addr_out   <= rs2_addr_in;
            rd_addr_out    <= rd_addr_in;
            
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            branch_out     <= branch_in;
            jump_out       <= jump_in;
            alu_src_out    <= alu_src_in;
            wb_src_out     <= wb_src_in;
            alu_op_out     <= alu_op_in;
            funct3_out     <= funct3_in;
        end
    end

endmodule