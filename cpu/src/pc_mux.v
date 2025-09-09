`include "defines.v"

// PC多路选择器
module pc_mux (
    input  wire [`ADDR_WIDTH-1:0]      pc_plus4,      // PC+4
    input  wire [`ADDR_WIDTH-1:0]      branch_target, // 分支目标地址
    input  wire                         branch_taken,  // 分支跳转信号
    input  wire                         jump,          // 跳转信号
    
    output wire [`ADDR_WIDTH-1:0]      pc_next        // 下一个PC值
);

    // PC选择逻辑
    assign pc_next = (branch_taken || jump) ? branch_target : pc_plus4;

endmodule