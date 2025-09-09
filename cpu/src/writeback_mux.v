`include "defines.v"

// 写回多路选择器
module writeback_mux (
    input  wire [`DATA_WIDTH-1:0]      alu_result,    // ALU结果
    input  wire [`DATA_WIDTH-1:0]      mem_data,      // 内存数据
    input  wire [`ADDR_WIDTH-1:0]      pc_plus4,      // PC+4
    input  wire [1:0]                  wb_src,        // 写回源选择
    
    output reg  [`DATA_WIDTH-1:0]      wb_data        // 写回数据
);

    always @(*) begin
        case (wb_src)
            `WB_SRC_ALU:  wb_data = alu_result;
            `WB_SRC_MEM:  wb_data = mem_data;
            `WB_SRC_PC4:  wb_data = pc_plus4;
            default:      wb_data = alu_result;
        endcase
    end

endmodule