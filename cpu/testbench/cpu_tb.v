`include "../src/defines.v"
`timescale 1ns/1ps

// CPU测试平台
module cpu_tb;

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
        forever #5 clk = ~clk;  // 10ns周期，100MHz
    end
    
    // 复位序列
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
        #20;
    end
    
    // 测试程序加载
    initial begin
        // 在复位之前加载测试程序
        load_test_program();
        
        // 等待复位完成
        #40;
        
        // 运行测试
        #2000;
        
        // 检查结果
        check_results();
        
        $finish;
    end
    
    // 加载测试程序
    task load_test_program;
        begin
            // 测试程序：验证所有9条指令
            
            // 指令0: lui x1, 0x12345  // x1 = 0x12345000
            u_cpu_top.u_instruction_memory.inst_mem[0] = 32'h123450B7;
            
            // 指令1: ori x2, x1, 0x678  // x2 = x1 | 0x678 = 0x12345678
            u_cpu_top.u_instruction_memory.inst_mem[1] = 32'h6780E113;
            
            // 指令2: add x3, x1, x2  // x3 = x1 + x2 = 0x24689678
            u_cpu_top.u_instruction_memory.inst_mem[2] = 32'h002081B3;
            
            // 指令3: slt x4, x1, x2  // x4 = (x1 < x2) ? 1 : 0 = 1
            u_cpu_top.u_instruction_memory.inst_mem[3] = 32'h0020A233;
            
            // 指令4: sltu x5, x2, x1  // x5 = (x2 < x1) ? 1 : 0 = 0 (无符号比较)
            u_cpu_top.u_instruction_memory.inst_mem[4] = 32'h001132B3;
            
            // 指令5: sw x2, 0(x0)  // mem[0] = x2
            u_cpu_top.u_instruction_memory.inst_mem[5] = 32'h00202023;
            
            // 指令6: lw x6, 0(x0)  // x6 = mem[0] = x2
            u_cpu_top.u_instruction_memory.inst_mem[6] = 32'h00002303;
            
            // 指令7: beq x2, x6, 8  // if (x2 == x6) pc = pc + 8 (跳转到指令9)
            u_cpu_top.u_instruction_memory.inst_mem[7] = 32'h00610463;
            
            // 指令8: add x7, x0, x0  // x7 = 0 (这条指令应该被跳过)
            u_cpu_top.u_instruction_memory.inst_mem[8] = 32'h000003B3;
            
            // 指令9: jal x8, 8  // x8 = pc + 4, pc = pc + 8 (跳转到指令11)
            u_cpu_top.u_instruction_memory.inst_mem[9] = 32'h0080046F;
            
            // 指令10: add x9, x0, x0  // x9 = 0 (这条指令应该被跳过)
            u_cpu_top.u_instruction_memory.inst_mem[10] = 32'h000004B3;
            
            // 指令11: add x10, x8, x0  // x10 = x8 (保存返回地址)
            u_cpu_top.u_instruction_memory.inst_mem[11] = 32'h00040533;
            
            $display("Test program loaded successfully");
        end
    endtask
    
    // 检查测试结果
    task check_results;
        begin
            $display("=== CPU Test Results ===");
            $display("x1 (lui result): 0x%h (expected: 0x12345000)", u_cpu_top.u_register_file.registers[1]);
            $display("x2 (ori result): 0x%h (expected: 0x12345678)", u_cpu_top.u_register_file.registers[2]);
            $display("x3 (add result): 0x%h (expected: 0x2468a678)", u_cpu_top.u_register_file.registers[3]);
            $display("x4 (slt result): 0x%h (expected: 0x00000001)", u_cpu_top.u_register_file.registers[4]);
            $display("x5 (sltu result): 0x%h (expected: 0x00000000)", u_cpu_top.u_register_file.registers[5]);
            $display("x6 (lw result): 0x%h (expected: 0x12345678)", u_cpu_top.u_register_file.registers[6]);
            $display("x7 (should be 0): 0x%h (expected: 0x00000000)", u_cpu_top.u_register_file.registers[7]);
            $display("x8 (jal result): 0x%h (expected: 0x00000028)", u_cpu_top.u_register_file.registers[8]);
            $display("x9 (should be 0): 0x%h (expected: 0x00000000)", u_cpu_top.u_register_file.registers[9]);
            $display("x10 (return addr): 0x%h (expected: 0x00000028)", u_cpu_top.u_register_file.registers[10]);
            $display("Memory[0]: 0x%h (expected: 0x12345678)", u_cpu_top.u_data_memory.data_mem[0]);
            
            // 验证结果
            if (u_cpu_top.u_register_file.registers[1] == 32'h12345000 &&
                u_cpu_top.u_register_file.registers[2] == 32'h12345678 &&
                u_cpu_top.u_register_file.registers[3] == 32'h2468a678 &&
                u_cpu_top.u_register_file.registers[4] == 32'h00000001 &&
                u_cpu_top.u_register_file.registers[5] == 32'h00000000 &&
                u_cpu_top.u_register_file.registers[6] == 32'h12345678 &&
                u_cpu_top.u_register_file.registers[7] == 32'h00000000 &&
                u_cpu_top.u_register_file.registers[8] == 32'h00000028 &&
                u_cpu_top.u_register_file.registers[9] == 32'h00000000 &&
                u_cpu_top.u_register_file.registers[10] == 32'h00000028 &&
                u_cpu_top.u_data_memory.data_mem[0] == 32'h12345678) begin
                $display("*** ALL TESTS PASSED! ***");
            end else begin
                $display("*** SOME TESTS FAILED! ***");
            end
        end
    endtask
    
    // 监控信号变化
    initial begin
        $monitor("Time: %0t, PC: 0x%h, Instruction: 0x%h", 
                 $time, u_cpu_top.pc, u_cpu_top.if_instruction);
    end
    
    // 生成波形文件
    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        
        // 显式添加关键信号到波形（确保可见性）
        $dumpvars(1, u_cpu_top.clk);
        $dumpvars(1, u_cpu_top.rst_n);
        $dumpvars(1, u_cpu_top.pc);
        $dumpvars(1, u_cpu_top.if_instruction);
        $dumpvars(1, u_cpu_top.id_instruction);
        $dumpvars(1, u_cpu_top.ex_alu_op);
        $dumpvars(1, u_cpu_top.alu_result);
        $dumpvars(1, u_cpu_top.mem_alu_result);
        $dumpvars(1, u_cpu_top.wb_data);
        $dumpvars(1, u_cpu_top.wb_reg_write);
        $dumpvars(1, u_cpu_top.wb_rd_addr);
        
        // 寄存器文件状态
        $dumpvars(1, u_cpu_top.u_register_file.registers[1]);
        $dumpvars(1, u_cpu_top.u_register_file.registers[2]);
        $dumpvars(1, u_cpu_top.u_register_file.registers[3]);
        $dumpvars(1, u_cpu_top.u_register_file.registers[4]);
        $dumpvars(1, u_cpu_top.u_register_file.registers[5]);
        
        // 转发信号
        $dumpvars(1, u_cpu_top.forward_a);
        $dumpvars(1, u_cpu_top.forward_b);
        $dumpvars(1, u_cpu_top.forwarded_rs1_data);
        $dumpvars(1, u_cpu_top.forwarded_rs2_data);
        
        // 分支和跳转信号
        $dumpvars(1, u_cpu_top.branch_taken);
        $dumpvars(1, u_cpu_top.jump);
        $dumpvars(1, u_cpu_top.pc_stall);
        
        $display("VCD波形文件配置完成，包含关键流水线信号");
    end

endmodule