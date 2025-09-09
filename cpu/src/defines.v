// CPU常量定义文件
`ifndef DEFINES_V
`define DEFINES_V

// 数据宽度定义
`define DATA_WIDTH      32
`define ADDR_WIDTH      32
`define REG_ADDR_WIDTH  5
`define INST_WIDTH      32

// 寄存器文件参数
`define REG_NUM         32

// 指令操作码定义
`define OP_R_TYPE       7'b0110011  // R型指令
`define OP_I_TYPE       7'b0010011  // I型指令(ori)
`define OP_LOAD         7'b0000011  // 加载指令(lw)
`define OP_STORE        7'b0100011  // 存储指令(sw)
`define OP_BRANCH       7'b1100011  // 分支指令(beq)
`define OP_JAL          7'b1101111  // 跳转指令(jal)
`define OP_LUI          7'b0110111  // 上位立即数指令(lui)

// funct3定义
`define FUNCT3_ADD      3'b000
`define FUNCT3_SLT      3'b010
`define FUNCT3_SLTU     3'b011
`define FUNCT3_ORI      3'b110
`define FUNCT3_LW       3'b010
`define FUNCT3_SW       3'b010
`define FUNCT3_BEQ      3'b000

// funct7定义
`define FUNCT7_ADD      7'b0000000
`define FUNCT7_SLT      7'b0000000
`define FUNCT7_SLTU     7'b0000000

// ALU操作码定义
`define ALU_ADD         4'b0000
`define ALU_SUB         4'b0001
`define ALU_OR          4'b0010
`define ALU_SLT         4'b0011
`define ALU_SLTU        4'b0100
`define ALU_LUI         4'b0101
`define ALU_EQ          4'b0110

// 控制信号定义
`define REG_WRITE_ENABLE    1'b1
`define REG_WRITE_DISABLE   1'b0
`define MEM_READ_ENABLE     1'b1
`define MEM_READ_DISABLE    1'b0
`define MEM_WRITE_ENABLE    1'b1
`define MEM_WRITE_DISABLE   1'b0
`define BRANCH_ENABLE       1'b1
`define BRANCH_DISABLE      1'b0
`define JUMP_ENABLE         1'b1
`define JUMP_DISABLE        1'b0

// ALU源选择
`define ALU_SRC_REG         1'b0
`define ALU_SRC_IMM         1'b1

// 写回数据源选择
`define WB_SRC_ALU          2'b00
`define WB_SRC_MEM          2'b01
`define WB_SRC_PC4          2'b10

// PC源选择
`define PC_SRC_PC4          2'b00
`define PC_SRC_BRANCH       2'b01
`define PC_SRC_JUMP         2'b10

// 流水线控制
`define PIPELINE_STALL      1'b1
`define PIPELINE_NORMAL     1'b0
`define PIPELINE_FLUSH      1'b1
`define PIPELINE_KEEP       1'b0

// 转发控制
`define FORWARD_NO          2'b00
`define FORWARD_EX          2'b01
`define FORWARD_MEM         2'b10

`endif