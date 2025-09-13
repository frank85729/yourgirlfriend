// 交通信号灯控制器顶层模块
// 通过参数选择不同的工作模式

module traffic_light_top #(
    parameter MODE = 0  // 0: 基本模式, 1: 不等时模式, 2: 左转模式
)(
    input wire clk,              // 时钟信号
    input wire rst_n,            // 复位信号（低电平有效）
    input wire main_car,         // 主道有车信号
    input wire branch_car,       // 支道有车信号
    input wire main_left_car,    // 主道左转有车信号（仅左转模式使用）
    input wire branch_left_car,  // 支道左转有车信号（仅左转模式使用）
    
    // 主道信号灯输出
    output wire main_red,        // 主道红灯
    output wire main_yellow,     // 主道黄灯
    output wire main_green,      // 主道直行绿灯
    output wire main_left_green, // 主道左转绿灯（仅左转模式有效）
    
    // 支道信号灯输出
    output wire branch_red,      // 支道红灯
    output wire branch_yellow,   // 支道黄灯
    output wire branch_green,    // 支道直行绿灯
    output wire branch_left_green // 支道左转绿灯（仅左转模式有效）
);

// 各模式的输出信号
wire basic_main_red, basic_main_yellow, basic_main_green;
wire basic_branch_red, basic_branch_yellow, basic_branch_green;

wire unequal_main_red, unequal_main_yellow, unequal_main_green;
wire unequal_branch_red, unequal_branch_yellow, unequal_branch_green;

wire left_main_red, left_main_yellow, left_main_green, left_main_left_green;
wire left_branch_red, left_branch_yellow, left_branch_green, left_branch_left_green;

// 实例化基本模式控制器
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

// 实例化不等时模式控制器
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

// 实例化左转模式控制器
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

// 根据模式参数选择输出
assign main_red = (MODE == 0) ? basic_main_red :
                  (MODE == 1) ? unequal_main_red : left_main_red;

assign main_yellow = (MODE == 0) ? basic_main_yellow :
                     (MODE == 1) ? unequal_main_yellow : left_main_yellow;

assign main_green = (MODE == 0) ? basic_main_green :
                    (MODE == 1) ? unequal_main_green : left_main_green;

assign main_left_green = (MODE == 2) ? left_main_left_green : 1'b0;

assign branch_red = (MODE == 0) ? basic_branch_red :
                    (MODE == 1) ? unequal_branch_red : left_branch_red;

assign branch_yellow = (MODE == 0) ? basic_branch_yellow :
                       (MODE == 1) ? unequal_branch_yellow : left_branch_yellow;

assign branch_green = (MODE == 0) ? basic_branch_green :
                      (MODE == 1) ? unequal_branch_green : left_branch_green;

assign branch_left_green = (MODE == 2) ? left_branch_left_green : 1'b0;

endmodule