// 交通信号灯顶层模块测试平台
// 测试不同模式的切换

`timescale 1ns/1ps

module traffic_light_top_testbench;

// 测试信号
reg clk;
reg rst_n;
reg main_car;
reg branch_car;
reg main_left_car;
reg branch_left_car;

// 输出信号
wire main_red, main_yellow, main_green, main_left_green;
wire branch_red, branch_yellow, branch_green, branch_left_green;

// 实例化顶层模块 - 左转模式
traffic_light_top #(.MODE(2)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .main_car(main_car),
    .branch_car(branch_car),
    .main_left_car(main_left_car),
    .branch_left_car(branch_left_car),
    .main_red(main_red),
    .main_yellow(main_yellow),
    .main_green(main_green),
    .main_left_green(main_left_green),
    .branch_red(branch_red),
    .branch_yellow(branch_yellow),
    .branch_green(branch_green),
    .branch_left_green(branch_left_green)
);

// 时钟生成 - 更快的时钟用于仿真
initial begin
    clk = 0;
    forever #50 clk = ~clk; // 10MHz时钟，用于快速仿真
end

// 测试序列
initial begin
    // 初始化
    rst_n = 0;
    main_car = 0;
    branch_car = 0;
    main_left_car = 0;
    branch_left_car = 0;
    
    // 复位
    #100;
    rst_n = 1;
    
    $display("=== 交通信号灯顶层模块测试开始 ===");
    $display("模式：左转信号灯模式");
    
    // 测试场景1：默认状态
    $display("\n--- 场景1：默认状态（主道直行绿灯）---");
    #3000; // 等待30个时钟周期
    
    // 测试场景2：支道有车和左转车
    $display("\n--- 场景2：支道有车和左转车 ---");
    branch_car = 1;
    branch_left_car = 1;
    #5000; // 等待50个时钟周期
    
    // 测试场景3：主道有左转车
    $display("\n--- 场景3：主道有左转车 ---");
    main_car = 1;
    main_left_car = 1;
    #5000; // 等待50个时钟周期
    
    // 测试场景4：清除所有车辆信号
    $display("\n--- 场景4：清除所有车辆 ---");
    main_car = 0;
    branch_car = 0;
    main_left_car = 0;
    branch_left_car = 0;
    #3000; // 等待30个时钟周期
    
    $display("\n=== 测试完成 ===");
    $finish;
end

// 状态监控
reg [3:0] prev_state;
reg [3:0] curr_state;

always @(*) begin
    curr_state = {main_red, main_yellow, main_green, main_left_green};
end

always @(posedge clk) begin
    if (rst_n && (curr_state != prev_state)) begin
        case (curr_state)
            4'b0010: $display("[%0t] 主道直行绿灯，支道红灯", $time);
            4'b0100: $display("[%0t] 主道黄灯，支道红灯", $time);
            4'b0001: $display("[%0t] 主道左转绿灯，支道红灯", $time);
            4'b1000: begin
                if (branch_green)
                    $display("[%0t] 主道红灯，支道直行绿灯", $time);
                else if (branch_yellow)
                    $display("[%0t] 主道红灯，支道黄灯", $time);
                else if (branch_left_green)
                    $display("[%0t] 主道红灯，支道左转绿灯", $time);
            end
            default: $display("[%0t] 未知状态: %b", $time, curr_state);
        endcase
        prev_state = curr_state;
    end
end

// 生成VCD文件
initial begin
    $dumpfile("traffic_light_top_test.vcd");
    $dumpvars(0, traffic_light_top_testbench);
end

endmodule