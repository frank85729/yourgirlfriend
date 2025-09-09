`include "defines.v"

module debug_tb;
    // 时钟和复位信号
    reg clk;
    reg rst_n;
    
    // 实例化CPU
    cpu_top u_cpu_top (
        .clk    (clk),
        .rst_n  (rst_n)
    );
    
    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 复位信号生成
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
        #20;
    end
    
    // 调试测试程序
    initial begin
        // 在复位之前加载测试程序
        load_debug_program();
        
        // 等待复位完成
        #40;
        
        // 运行测试
        #200;
        
        // 检查结果
        check_debug_results();
        
        $finish;
    end
    
    // 加载调试测试程序
    task load_debug_program;
        begin
            // 简化的测试程序：专注于sltu和分支
            
            // 简化测试：专注于转发问题
            // 指令0: lui x1, 0x12345  // x1 = 0x12345000
            u_cpu_top.u_instruction_memory.inst_mem[0] = 32'h123450B7;
            
            // 指令1: ori x2, x1, 0x678  // x2 = 0x12345678
            u_cpu_top.u_instruction_memory.inst_mem[1] = 32'h6780E113;
            
            // 插入NOP指令来避免数据冒险
            // 指令2: nop (addi x0, x0, 0)
            u_cpu_top.u_instruction_memory.inst_mem[2] = 32'h00000013;
            
            // 指令3: nop (addi x0, x0, 0)
            u_cpu_top.u_instruction_memory.inst_mem[3] = 32'h00000013;
            
            // 指令4: sltu x5, x2, x1  // x5 = (x2 < x1) ? 1 : 0 = 0 (无符号比较)
            u_cpu_top.u_instruction_memory.inst_mem[4] = 32'h001132B3;
            
            $display("Debug program loaded successfully");
        end
    endtask
    
    // 检查调试结果
    task check_debug_results;
        begin
            $display("=== Debug Test Results ===");
            $display("x1 (lui result): 0x%h (expected: 0x12345000)", u_cpu_top.u_register_file.registers[1]);
            $display("x2 (ori result): 0x%h (expected: 0x12345678)", u_cpu_top.u_register_file.registers[2]);
            $display("x5 (sltu result): 0x%h (expected: 0x00000000)", u_cpu_top.u_register_file.registers[5]);
            
            // 验证结果
            if (u_cpu_top.u_register_file.registers[1] == 32'h12345000 &&
                u_cpu_top.u_register_file.registers[2] == 32'h12345678 &&
                u_cpu_top.u_register_file.registers[5] == 32'h00000000) begin
                $display("*** ALL DEBUG TESTS PASSED! ***");
            end else begin
                $display("*** SOME DEBUG TESTS FAILED! ***");
            end
        end
    endtask
    
    // 监控信号变化
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time: %0d, PC: 0x%h, Instruction: 0x%h", 
                     $time, u_cpu_top.pc, u_cpu_top.if_instruction);
            
            // 显示所有流水线阶段的信息
            $display("  Pipeline Status:");
            $display("    EX: rd=%d, reg_write=%d, alu_result=0x%h", 
                     u_cpu_top.ex_rd_addr, u_cpu_top.ex_reg_write, u_cpu_top.alu_result);
            $display("    MEM: rd=%d, reg_write=%d, alu_result=0x%h", 
                     u_cpu_top.mem_rd_addr, u_cpu_top.mem_reg_write, u_cpu_top.mem_alu_result);
            $display("    WB: rd=%d, reg_write=%d, wb_data=0x%h", 
                     u_cpu_top.wb_rd_addr, u_cpu_top.wb_reg_write, u_cpu_top.wb_data);
            
            // 显示寄存器文件状态
            $display("    Registers: x1=0x%h, x2=0x%h, x5=0x%h", 
                     u_cpu_top.u_register_file.registers[1],
                     u_cpu_top.u_register_file.registers[2],
                     u_cpu_top.u_register_file.registers[5]);
            
            // 当执行sltu指令时，显示详细信息
            if (u_cpu_top.ex_alu_op == `ALU_SLTU) begin
                $display("  SLTU Debug:");
                $display("    rs1_addr: %d, rs2_addr: %d", u_cpu_top.ex_rs1_addr, u_cpu_top.ex_rs2_addr);
                $display("    rs1_data: 0x%h, rs2_data: 0x%h", u_cpu_top.ex_rs1_data, u_cpu_top.ex_rs2_data);
                $display("    forwarded_rs1: 0x%h, forwarded_rs2: 0x%h", u_cpu_top.forwarded_rs1_data, u_cpu_top.forwarded_rs2_data);
                $display("    forward_a: %d, forward_b: %d", u_cpu_top.forward_a, u_cpu_top.forward_b);
                $display("    alu_operand_a: 0x%h, alu_operand_b: 0x%h", u_cpu_top.alu_operand_a, u_cpu_top.alu_operand_b);
                $display("    alu_result: 0x%h", u_cpu_top.alu_result);
            end
        end
    end

endmodule