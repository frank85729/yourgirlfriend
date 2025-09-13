// 交通信号灯控制器 - 带左转信号灯版本
// 主道：直行27s + 黄灯3s + 左转12s + 黄灯3s = 45s周期
// 支道：直行17s + 黄灯3s + 左转7s + 黄灯3s = 30s周期

module traffic_light_with_left_turn (
    input wire clk,              // 时钟信号
    input wire rst_n,            // 复位信号（低电平有效）
    input wire main_car,         // 主道有车信号
    input wire branch_car,       // 支道有车信号
    input wire main_left_car,    // 主道左转有车信号
    input wire branch_left_car,  // 支道左转有车信号
    
    // 主道信号灯输出
    output reg main_red,         // 主道红灯
    output reg main_yellow,      // 主道黄灯
    output reg main_green,       // 主道直行绿灯
    output reg main_left_green,  // 主道左转绿灯
    
    // 支道信号灯输出
    output reg branch_red,       // 支道红灯
    output reg branch_yellow,    // 支道黄灯
    output reg branch_green,     // 支道直行绿灯
    output reg branch_left_green // 支道左转绿灯
);

// 状态定义
parameter MAIN_STRAIGHT_GREEN = 4'b0000;     // 主道直行绿灯，支道红灯
parameter MAIN_STRAIGHT_YELLOW = 4'b0001;    // 主道直行黄灯，支道红灯
parameter MAIN_LEFT_GREEN = 4'b0010;         // 主道左转绿灯，支道红灯
parameter MAIN_LEFT_YELLOW = 4'b0011;        // 主道左转黄灯，支道红灯
parameter BRANCH_STRAIGHT_GREEN = 4'b0100;   // 支道直行绿灯，主道红灯
parameter BRANCH_STRAIGHT_YELLOW = 4'b0101;  // 支道直行黄灯，主道红灯
parameter BRANCH_LEFT_GREEN = 4'b0110;       // 支道左转绿灯，主道红灯
parameter BRANCH_LEFT_YELLOW = 4'b0111;      // 支道左转黄灯，主道红灯

// 时间参数（假设时钟频率为1Hz）
parameter MAIN_STRAIGHT_TIME = 27;    // 主道直行绿灯时间27秒
parameter MAIN_LEFT_TIME = 12;        // 主道左转绿灯时间12秒
parameter BRANCH_STRAIGHT_TIME = 17;  // 支道直行绿灯时间17秒
parameter BRANCH_LEFT_TIME = 7;       // 支道左转绿灯时间7秒
parameter YELLOW_TIME = 3;            // 黄灯时间3秒

// 内部信号
reg [3:0] current_state, next_state;
reg [5:0] timer;              // 计时器
reg [5:0] timer_next;
reg [5:0] time_limit;         // 当前状态的时间限制

// 状态寄存器
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        current_state <= MAIN_STRAIGHT_GREEN;
        timer <= 0;
    end else begin
        current_state <= next_state;
        timer <= timer_next;
    end
end

// 根据当前状态设置时间限制
always @(*) begin
    case (current_state)
        MAIN_STRAIGHT_GREEN: time_limit = MAIN_STRAIGHT_TIME;
        MAIN_LEFT_GREEN: time_limit = MAIN_LEFT_TIME;
        BRANCH_STRAIGHT_GREEN: time_limit = BRANCH_STRAIGHT_TIME;
        BRANCH_LEFT_GREEN: time_limit = BRANCH_LEFT_TIME;
        default: time_limit = YELLOW_TIME;  // 黄灯状态
    endcase
end

// 状态转换逻辑
always @(*) begin
    next_state = current_state;
    timer_next = timer + 1;
    
    case (current_state)
        MAIN_STRAIGHT_GREEN: begin
            // 主道直行绿灯
            if (timer >= time_limit) begin
                if ((branch_car || branch_left_car) || (main_car || main_left_car)) begin
                    // 有车需要通行，进入黄灯阶段
                    next_state = MAIN_STRAIGHT_YELLOW;
                    timer_next = 0;
                end else begin
                    // 没有车，重置计时器继续绿灯
                    timer_next = 0;
                end
            end
        end
        
        MAIN_STRAIGHT_YELLOW: begin
            // 主道直行黄灯
            if (timer >= time_limit) begin
                if (main_left_car) begin
                    // 主道有左转车，进入主道左转绿灯
                    next_state = MAIN_LEFT_GREEN;
                    timer_next = 0;
                end else begin
                    // 主道没有左转车，直接切换到支道直行绿灯
                    next_state = BRANCH_STRAIGHT_GREEN;
                    timer_next = 0;
                end
            end
        end
        
        MAIN_LEFT_GREEN: begin
            // 主道左转绿灯
            if (timer >= time_limit) begin
                next_state = MAIN_LEFT_YELLOW;
                timer_next = 0;
            end
        end
        
        MAIN_LEFT_YELLOW: begin
            // 主道左转黄灯
            if (timer >= time_limit) begin
                next_state = BRANCH_STRAIGHT_GREEN;
                timer_next = 0;
            end
        end
        
        BRANCH_STRAIGHT_GREEN: begin
            // 支道直行绿灯
            if (timer >= time_limit) begin
                if ((main_car || main_left_car) || (branch_car || branch_left_car)) begin
                    // 有车需要通行，进入黄灯阶段
                    next_state = BRANCH_STRAIGHT_YELLOW;
                    timer_next = 0;
                end else begin
                    // 没有车，切换回主道直行绿灯
                    next_state = MAIN_STRAIGHT_GREEN;
                    timer_next = 0;
                end
            end
        end
        
        BRANCH_STRAIGHT_YELLOW: begin
            // 支道直行黄灯
            if (timer >= time_limit) begin
                if (branch_left_car) begin
                    // 支道有左转车，进入支道左转绿灯
                    next_state = BRANCH_LEFT_GREEN;
                    timer_next = 0;
                end else begin
                    // 支道没有左转车，直接切换到主道直行绿灯
                    next_state = MAIN_STRAIGHT_GREEN;
                    timer_next = 0;
                end
            end
        end
        
        BRANCH_LEFT_GREEN: begin
            // 支道左转绿灯
            if (timer >= time_limit) begin
                next_state = BRANCH_LEFT_YELLOW;
                timer_next = 0;
            end
        end
        
        BRANCH_LEFT_YELLOW: begin
            // 支道左转黄灯
            if (timer >= time_limit) begin
                next_state = MAIN_STRAIGHT_GREEN;
                timer_next = 0;
            end
        end
        
        default: begin
            next_state = MAIN_STRAIGHT_GREEN;
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
    main_left_green = 0;
    branch_red = 0;
    branch_yellow = 0;
    branch_green = 0;
    branch_left_green = 0;
    
    case (current_state)
        MAIN_STRAIGHT_GREEN: begin
            main_green = 1;
            branch_red = 1;
        end
        
        MAIN_STRAIGHT_YELLOW: begin
            main_yellow = 1;
            branch_red = 1;
        end
        
        MAIN_LEFT_GREEN: begin
            main_left_green = 1;
            branch_red = 1;
        end
        
        MAIN_LEFT_YELLOW: begin
            main_yellow = 1;
            branch_red = 1;
        end
        
        BRANCH_STRAIGHT_GREEN: begin
            main_red = 1;
            branch_green = 1;
        end
        
        BRANCH_STRAIGHT_YELLOW: begin
            main_red = 1;
            branch_yellow = 1;
        end
        
        BRANCH_LEFT_GREEN: begin
            main_red = 1;
            branch_left_green = 1;
        end
        
        BRANCH_LEFT_YELLOW: begin
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