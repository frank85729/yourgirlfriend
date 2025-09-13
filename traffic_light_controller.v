// 交通信号灯控制器 - 基本版本
// 支持基本的红绿黄灯控制，两个方向同时有车时30秒周期

module traffic_light_controller (
    input wire clk,           // 时钟信号
    input wire rst_n,         // 复位信号（低电平有效）
    input wire main_car,      // 主道有车信号
    input wire branch_car,    // 支道有车信号
    
    // 主道信号灯输出
    output reg main_red,      // 主道红灯
    output reg main_yellow,   // 主道黄灯
    output reg main_green,    // 主道绿灯
    
    // 支道信号灯输出
    output reg branch_red,    // 支道红灯
    output reg branch_yellow, // 支道黄灯
    output reg branch_green   // 支道绿灯
);

// 状态定义
parameter MAIN_GREEN_BRANCH_RED = 3'b000;    // 主道绿灯，支道红灯
parameter MAIN_YELLOW_BRANCH_RED = 3'b001;   // 主道黄灯，支道红灯
parameter MAIN_RED_BRANCH_GREEN = 3'b010;    // 主道红灯，支道绿灯
parameter MAIN_RED_BRANCH_YELLOW = 3'b011;   // 主道红灯，支道黄灯

// 时间参数（假设时钟频率为1Hz，即1秒一个时钟周期）
parameter GREEN_TIME = 27;    // 绿灯时间27秒
parameter YELLOW_TIME = 3;    // 黄灯时间3秒

// 内部信号
reg [2:0] current_state, next_state;
reg [5:0] timer;              // 计时器，最大63秒
reg [5:0] timer_next;

// 状态寄存器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= MAIN_GREEN_BRANCH_RED;
        timer <= 0;
    end else begin
        current_state <= next_state;
        timer <= timer_next;
    end
end

// 状态转换逻辑
always @(*) begin
    next_state = current_state;
    timer_next = timer + 1;
    
    case (current_state)
        MAIN_GREEN_BRANCH_RED: begin
            // 主道绿灯，支道红灯
            if (branch_car && timer >= GREEN_TIME) begin
                // 支道有车且主道绿灯时间到，切换到主道黄灯
                next_state = MAIN_YELLOW_BRANCH_RED;
                timer_next = 0;
            end else if (!main_car && !branch_car) begin
                // 两个方向都没车，保持当前状态，重置计时器
                timer_next = 0;
            end else if (!branch_car && timer >= GREEN_TIME) begin
                // 支道没车但主道时间到，重置计时器继续绿灯
                timer_next = 0;
            end
        end
        
        MAIN_YELLOW_BRANCH_RED: begin
            // 主道黄灯，支道红灯
            if (timer >= YELLOW_TIME) begin
                next_state = MAIN_RED_BRANCH_GREEN;
                timer_next = 0;
            end
        end
        
        MAIN_RED_BRANCH_GREEN: begin
            // 主道红灯，支道绿灯
            if (main_car && timer >= GREEN_TIME) begin
                // 主道有车且支道绿灯时间到，切换到支道黄灯
                next_state = MAIN_RED_BRANCH_YELLOW;
                timer_next = 0;
            end else if (!main_car && !branch_car) begin
                // 两个方向都没车，切换回主道绿灯
                next_state = MAIN_GREEN_BRANCH_RED;
                timer_next = 0;
            end else if (!main_car && timer >= GREEN_TIME) begin
                // 主道没车但支道时间到，重置计时器继续绿灯
                timer_next = 0;
            end
        end
        
        MAIN_RED_BRANCH_YELLOW: begin
            // 主道红灯，支道黄灯
            if (timer >= YELLOW_TIME) begin
                next_state = MAIN_GREEN_BRANCH_RED;
                timer_next = 0;
            end
        end
        
        default: begin
            next_state = MAIN_GREEN_BRANCH_RED;
            timer_next = 0;
        end
    endcase
end

// 输出逻辑
always @(*) begin
    // 默认所有灯都关闭
    main_red = 0;
    main_yellow = 0;
    main_green = 0;
    branch_red = 0;
    branch_yellow = 0;
    branch_green = 0;
    
    case (current_state)
        MAIN_GREEN_BRANCH_RED: begin
            main_green = 1;
            branch_red = 1;
        end
        
        MAIN_YELLOW_BRANCH_RED: begin
            main_yellow = 1;
            branch_red = 1;
        end
        
        MAIN_RED_BRANCH_GREEN: begin
            main_red = 1;
            branch_green = 1;
        end
        
        MAIN_RED_BRANCH_YELLOW: begin
            main_red = 1;
            branch_yellow = 1;
        end
        
        default: begin
            main_green = 1;
            branch_red = 1;
        end
    endcase
end

endmodule