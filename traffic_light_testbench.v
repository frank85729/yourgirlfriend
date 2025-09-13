// 交通信号灯控制器测试平台
// 测试基本版本、不等时版本和带左转版本

`timescale 1ns/1ps

module traffic_light_testbench;

// 测试信号
reg clk;
reg rst_n;
reg main_car;
reg branch_car;
reg main_left_car;
reg branch_left_car;

// 基本版本输出
wire basic_main_red, basic_main_yellow, basic_main_green;
wire basic_branch_red, basic_branch_yellow, basic_branch_green;

// 不等时版本输出
wire unequal_main_red, unequal_main_yellow, unequal_main_green;
wire unequal_branch_red, unequal_branch_yellow, unequal_branch_green;

// 左转版本输出
wire left_main_red, left_main_yellow, left_main_green, left_main_left_green;
wire left_branch_red, left_branch_yellow, left_branch_green, left_branch_left_green;

// 实例化被测试模块
traffic_light_controller basic_controller (
    .clk(clk),
    .rst_n(rst_n),
    .main_car(main_car),
    .branch_car(branch_car),
    .main_red(basic_main_red),
    .main_yellow(basic_main_yellow),
    .main_green(basic_main_green),
    .branch_red(basic_branch_red),
    .branch_yellow(basic_branch_yellow),
    .branch_green(basic_branch_green)
);

traffic_light_unequal_timing unequal_controller (
    .clk(clk),
    .rst_n(rst_n),
    .main_car(main_car),
    .branch_car(branch_car),
    .main_red(unequal_main_red),
    .main_yellow(unequal_main_yellow),
    .main_green(unequal_main_green),
    .branch_red(unequal_branch_red),
    .branch_yellow(unequal_branch_yellow),
    .branch_green(unequal_branch_green)
);

traffic_light_with_left_turn left_turn_controller (
    .clk(clk),
    .rst_n(rst_n),
    .main_car(main_car),
    .branch_car(branch_car),
    .main_left_car(main_left_car),
    .branch_left_car(branch_left_car),
    .main_red(left_main_red),
    .main_yellow(left_main_yellow),
    .main_green(left_main_green),
    .main_left_green(left_main_left_green),
    .branch_red(left_branch_red),
    .branch_yellow(left_branch_yellow),
    .branch_green(left_branch_green),
    .branch_left_green(left_branch_left_green)
);

// 时钟生成
initial begin
    clk = 0;
    forever #500000000 clk = ~clk; // 1Hz时钟，周期1秒
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
    #1000000000; // 等待1秒
    rst_n = 1;
    
    $display("=== 交通信号灯控制器测试开始 ===");
    $display("时间格式：时间(ns) - 状态描述");
    
    // 测试场景1：默认状态（主道绿灯，支道红灯）
    $display("\n--- 测试场景1：默认状态 ---");
    #5000000000; // 等待5秒
    
    // 测试场景2：支道有车，触发切换
    $display("\n--- 测试场景2：支道有车触发切换 ---");
    branch_car = 1;
    #35000000000; // 等待35秒观察完整周期
    branch_car = 0;
    
    // 测试场景3：两个方向都有车
    $display("\n--- 测试场景3：两个方向都有车 ---");
    main_car = 1;
    branch_car = 1;
    #70000000000; // 等待70秒观察两个完整周期
    
    // 测试场景4：测试左转功能
    $display("\n--- 测试场景4：测试左转功能 ---");
    main_left_car = 1;
    branch_left_car = 1;
    #100000000000; // 等待100秒观察左转周期
    
    // 测试场景5：只有左转车
    $display("\n--- 测试场景5：只有左转车 ---");
    main_car = 0;
    branch_car = 0;
    main_left_car = 1;
    branch_left_car = 0;
    #50000000000; // 等待50秒
    
    $display("\n=== 测试完成 ===");
    $finish;
end

// 监控基本版本状态变化
always @(posedge clk) begin
    if (rst_n) begin
        $display("[%0t] 基本版本 - 主道: R=%b Y=%b G=%b, 支道: R=%b Y=%b G=%b", 
                 $time, basic_main_red, basic_main_yellow, basic_main_green,
                 basic_branch_red, basic_branch_yellow, basic_branch_green);
    end
end

// 监控不等时版本状态变化
always @(posedge clk) begin
    if (rst_n) begin
        $display("[%0t] 不等时版本 - 主道: R=%b Y=%b G=%b, 支道: R=%b Y=%b G=%b", 
                 $time, unequal_main_red, unequal_main_yellow, unequal_main_green,
                 unequal_branch_red, unequal_branch_yellow, unequal_branch_green);
    end
end

// 监控左转版本状态变化
always @(posedge clk) begin
    if (rst_n) begin
        $display("[%0t] 左转版本 - 主道: R=%b Y=%b G=%b LG=%b, 支道: R=%b Y=%b G=%b LG=%b", 
                 $time, left_main_red, left_main_yellow, left_main_green, left_main_left_green,
                 left_branch_red, left_branch_yellow, left_branch_green, left_branch_left_green);
    end
end

// 生成VCD文件用于波形查看
initial begin
    $dumpfile("traffic_light_test.vcd");
    $dumpvars(0, traffic_light_testbench);
end

endmodule