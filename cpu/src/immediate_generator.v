`include "defines.v"

// 立即数生成器模块
module immediate_generator (
    input  wire [`INST_WIDTH-1:0]      instruction,    // 指令
    output reg  [`DATA_WIDTH-1:0]      immediate       // 生成的立即数
);

    wire [6:0] opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            // I型指令 (ori, lw)
            `OP_I_TYPE, `OP_LOAD: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};  // 符号扩展
            end
            
            // U型指令 (lui)
            `OP_LUI: begin
                immediate = {instruction[31:12], 12'h0};  // 高20位，低12位补0
            end
            
            // S型指令 (sw)
            `OP_STORE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  // 符号扩展
            end
            
            // B型指令 (beq)
            `OP_BRANCH: begin
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                           instruction[30:25], instruction[11:8], 1'b0};  // 符号扩展，最低位为0
            end
            
            // J型指令 (jal)
            `OP_JAL: begin
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
                           instruction[20], instruction[30:21], 1'b0};  // 符号扩展，最低位为0
            end
            
            default: begin
                immediate = `DATA_WIDTH'h0;
            end
        endcase
    end

endmodule