`include "defines.v"

// ALU模块
module alu (
    input  wire [`DATA_WIDTH-1:0]      operand_a,  // 操作数A
    input  wire [`DATA_WIDTH-1:0]      operand_b,  // 操作数B
    input  wire [3:0]                  alu_op,     // ALU操作码
    output reg  [`DATA_WIDTH-1:0]      result,     // 运算结果
    output wire                        zero        // 零标志
);

    // 零标志
    assign zero = (result == `DATA_WIDTH'h0);
    
    // ALU运算
    always @(*) begin
        case (alu_op)
            `ALU_ADD:  result = operand_a + operand_b;                          // 加法
            `ALU_SUB:  result = operand_a - operand_b;                          // 减法
            `ALU_OR:   result = operand_a | operand_b;                          // 或运算
            `ALU_SLT:  result = ($signed(operand_a) < $signed(operand_b)) ? 32'h1 : 32'h0;  // 有符号比较
            `ALU_SLTU: result = (operand_a < operand_b) ? 32'h1 : 32'h0;       // 无符号比较
            `ALU_LUI:  result = operand_b;                                      // LUI指令，直接输出操作数B
            `ALU_EQ:   result = (operand_a == operand_b) ? 32'h1 : 32'h0;      // 相等比较（用于分支）
            default:   result = `DATA_WIDTH'h0;
        endcase
    end

endmodule