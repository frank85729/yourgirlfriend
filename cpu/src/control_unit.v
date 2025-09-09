`include "defines.v"

// 控制单元模块
module control_unit (
    input  wire [6:0]                  opcode,      // 操作码
    input  wire [2:0]                  funct3,      // funct3字段
    input  wire [6:0]                  funct7,      // funct7字段
    
    // 控制信号输出
    output reg                         reg_write,   // 寄存器写使能
    output reg                         mem_read,    // 内存读使能
    output reg                         mem_write,   // 内存写使能
    output reg                         branch,      // 分支信号
    output reg                         jump,        // 跳转信号
    output reg                         alu_src,     // ALU源选择
    output reg  [1:0]                  wb_src,      // 写回数据源选择
    output reg  [3:0]                  alu_op       // ALU操作码
);

    always @(*) begin
        // 默认值
        reg_write = `REG_WRITE_DISABLE;
        mem_read  = `MEM_READ_DISABLE;
        mem_write = `MEM_WRITE_DISABLE;
        branch    = `BRANCH_DISABLE;
        jump      = `JUMP_DISABLE;
        alu_src   = `ALU_SRC_REG;
        wb_src    = `WB_SRC_ALU;
        alu_op    = `ALU_ADD;
        
        case (opcode)
            // R型指令
            `OP_R_TYPE: begin
                reg_write = `REG_WRITE_ENABLE;
                alu_src   = `ALU_SRC_REG;
                wb_src    = `WB_SRC_ALU;
                
                case ({funct7, funct3})
                    {`FUNCT7_ADD, `FUNCT3_ADD}:   alu_op = `ALU_ADD;
                    {`FUNCT7_SLT, `FUNCT3_SLT}:   alu_op = `ALU_SLT;
                    {`FUNCT7_SLTU, `FUNCT3_SLTU}: alu_op = `ALU_SLTU;
                    default: alu_op = `ALU_ADD;
                endcase
            end
            
            // I型指令 (ori)
            `OP_I_TYPE: begin
                reg_write = `REG_WRITE_ENABLE;
                alu_src   = `ALU_SRC_IMM;
                wb_src    = `WB_SRC_ALU;
                
                case (funct3)
                    `FUNCT3_ORI: alu_op = `ALU_OR;
                    default: alu_op = `ALU_ADD;
                endcase
            end
            
            // 加载指令 (lw)
            `OP_LOAD: begin
                reg_write = `REG_WRITE_ENABLE;
                mem_read  = `MEM_READ_ENABLE;
                alu_src   = `ALU_SRC_IMM;
                wb_src    = `WB_SRC_MEM;
                alu_op    = `ALU_ADD;  // 地址计算
            end
            
            // 存储指令 (sw)
            `OP_STORE: begin
                mem_write = `MEM_WRITE_ENABLE;
                alu_src   = `ALU_SRC_IMM;
                alu_op    = `ALU_ADD;  // 地址计算
            end
            
            // 分支指令 (beq)
            `OP_BRANCH: begin
                branch    = `BRANCH_ENABLE;
                alu_src   = `ALU_SRC_REG;
                alu_op    = `ALU_EQ;   // 相等比较
            end
            
            // 跳转指令 (jal)
            `OP_JAL: begin
                reg_write = `REG_WRITE_ENABLE;
                jump      = `JUMP_ENABLE;
                wb_src    = `WB_SRC_PC4;
            end
            
            // LUI指令
            `OP_LUI: begin
                reg_write = `REG_WRITE_ENABLE;
                alu_src   = `ALU_SRC_IMM;
                wb_src    = `WB_SRC_ALU;
                alu_op    = `ALU_LUI;
            end
            
            default: begin
                // 保持默认值
            end
        endcase
    end

endmodule