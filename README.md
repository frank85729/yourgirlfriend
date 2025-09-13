# 交通信号灯控制器 Verilog 实现

本项目使用 Verilog 语言实现了一个完整的十字路口交通信号灯控制系统，支持多种工作模式。

## 项目结构

```
├── traffic_light_controller.v          # 基本交通信号灯控制器
├── traffic_light_unequal_timing.v      # 不等时控制器（主道30s，支道20s）
├── traffic_light_with_left_turn.v      # 带左转信号灯的控制器
├── traffic_light_top.v                 # 顶层模块（支持模式选择）
├── traffic_light_testbench.v           # 完整测试平台
├── traffic_light_top_testbench.v       # 顶层模块测试平台
├── Makefile                            # 编译和仿真脚本
└── README.md                           # 项目说明文档
```

## 功能特性

### 1. 基本交通信号灯控制器 (`traffic_light_controller.v`)
- 支持主道和支道的红、绿、黄三色信号灯
- 默认状态：主道绿灯，支道红灯
- 智能切换：只有当支道有车且主道计时到时才切换
- 时间配置：绿灯27秒，黄灯3秒，总周期30秒

### 2. 不等时控制器 (`traffic_light_unequal_timing.v`)
- 主道绿灯时间：27秒
- 支道绿灯时间：17秒
- 黄灯时间：3秒
- 主道总周期：30秒，支道总周期：20秒

### 3. 带左转信号灯控制器 (`traffic_light_with_left_turn.v`)
- 主道周期：直行绿灯27s + 黄灯3s + 左转绿灯12s + 黄灯3s = 45s
- 支道周期：直行绿灯17s + 黄灯3s + 左转绿灯7s + 黄灯3s = 30s
- 支持直行和左转独立控制

### 4. 顶层模块 (`traffic_light_top.v`)
- 通过参数选择工作模式：
  - MODE = 0：基本模式
  - MODE = 1：不等时模式
  - MODE = 2：左转模式

## 信号接口

### 输入信号
- `clk`: 时钟信号
- `rst_n`: 复位信号（低电平有效）
- `main_car`: 主道有车信号
- `branch_car`: 支道有车信号
- `main_left_car`: 主道左转有车信号（仅左转模式）
- `branch_left_car`: 支道左转有车信号（仅左转模式）

### 输出信号
- `main_red/yellow/green`: 主道红/黄/绿灯
- `main_left_green`: 主道左转绿灯（仅左转模式）
- `branch_red/yellow/green`: 支道红/黄/绿灯
- `branch_left_green`: 支道左转绿灯（仅左转模式）

## 状态转换逻辑

### 基本模式状态转换
1. **主道绿灯，支道红灯** → 支道有车且时间到 → 主道黄灯
2. **主道黄灯，支道红灯** → 黄灯时间到 → 支道绿灯
3. **主道红灯，支道绿灯** → 主道有车且时间到 → 支道黄灯
4. **主道红灯，支道黄灯** → 黄灯时间到 → 主道绿灯

### 左转模式状态转换
1. **主道直行绿灯** → 时间到 → 主道直行黄灯
2. **主道直行黄灯** → 有左转车 → 主道左转绿灯 / 无左转车 → 支道直行绿灯
3. **主道左转绿灯** → 时间到 → 主道左转黄灯
4. **主道左转黄灯** → 时间到 → 支道直行绿灯
5. **支道直行绿灯** → 时间到 → 支道直行黄灯
6. **支道直行黄灯** → 有左转车 → 支道左转绿灯 / 无左转车 → 主道直行绿灯
7. **支道左转绿灯** → 时间到 → 支道左转黄灯
8. **支道左转黄灯** → 时间到 → 主道直行绿灯

## 编译和仿真

### 前提条件
- 安装 Icarus Verilog (`iverilog`)
- 安装 GTKWave（可选，用于查看波形）

### 使用 Makefile

```bash
# 检查语法
make syntax_check

# 编译所有模块
make all

# 运行顶层模块仿真
make sim_top

# 运行完整测试平台仿真
make sim_full

# 运行所有测试
make test

# 查看波形（需要GTKWave）
make wave_top
make wave_full

# 清理生成的文件
make clean

# 显示帮助信息
make help
```

### 手动编译和运行

```bash
# 编译顶层模块测试
iverilog -o top_test traffic_light_controller.v traffic_light_unequal_timing.v traffic_light_with_left_turn.v traffic_light_top.v traffic_light_top_testbench.v

# 运行仿真
vvp top_test

# 查看波形
gtkwave traffic_light_top_test.vcd
```

## 时间参数配置

所有时间参数都在模块内部定义为参数，可以根据需要修改：

```verilog
// 基本模式时间参数
parameter GREEN_TIME = 27;    // 绿灯时间27秒
parameter YELLOW_TIME = 3;    // 黄灯时间3秒

// 左转模式时间参数
parameter MAIN_STRAIGHT_TIME = 27;    // 主道直行绿灯时间
parameter MAIN_LEFT_TIME = 12;        // 主道左转绿灯时间
parameter BRANCH_STRAIGHT_TIME = 17;  // 支道直行绿灯时间
parameter BRANCH_LEFT_TIME = 7;       // 支道左转绿灯时间
```

## 测试场景

测试平台包含以下测试场景：
1. 默认状态测试
2. 支道有车触发切换
3. 两个方向都有车的情况
4. 左转功能测试
5. 只有左转车的情况

## 注意事项

1. 时钟频率假设为1Hz（1秒一个周期），实际使用时需要根据系统时钟调整
2. 所有时间参数都可以通过修改参数来调整
3. 复位信号为低电平有效
4. 车辆检测信号为高电平有效

## 扩展功能

本设计支持以下扩展：
1. 增加更多的时间模式
2. 添加紧急车辆优先通行功能
3. 增加行人过街信号灯
4. 添加交通流量统计功能
5. 支持多个十字路口的协调控制