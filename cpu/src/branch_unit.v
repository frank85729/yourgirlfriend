`include "defines.v"

// 分支单元
module branch_unit (
    input  wire [`DATA_WIDTH-1:0]      rs1_data,      // 源寄存器1数据
    input  wire [`DATA_WIDTH-1:0]      rs2_data,      // 源寄存器2数据
    input  wire [`ADDR_WIDTH-1:0]      pc,            // 当前PC
    input  wire [`DATA_WIDTH-1:0]      immediate,     // 立即数
    input  wire                         branch,        // 分支信号
    input  wire                         jump,          // 跳转信号
    input  wire [2:0]                  funct3,        // funct3字段
    
    output wire                         branch_taken,  // 分支是否跳转
    output wire [`ADDR_WIDTH-1:0]      branch_target  // 分支目标地址
);

    // 分支条件判断
    reg branch_condition;
    always @(*) begin
        case (funct3)
            `FUNCT3_BEQ: branch_condition = (rs1_data == rs2_data);  // beq
            default:     branch_condition = 1'b0;
        endcase
    end
    
    // 分支跳转判断
    assign branch_taken = (branch && branch_condition) || jump;
    
    // 分支目标地址计算
    assign branch_target = pc + immediate;

endmodule