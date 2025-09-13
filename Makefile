# Makefile for Traffic Light Controller Verilog Project

# 编译器设置
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# 源文件
BASIC_SRC = traffic_light_controller.v
UNEQUAL_SRC = traffic_light_unequal_timing.v
LEFT_TURN_SRC = traffic_light_with_left_turn.v
TOP_SRC = traffic_light_top.v
TB_SRC = traffic_light_testbench.v
TOP_TB_SRC = traffic_light_top_testbench.v

# 所有源文件
ALL_SRC = $(BASIC_SRC) $(UNEQUAL_SRC) $(LEFT_TURN_SRC) $(TOP_SRC)

# 目标文件
BASIC_OUT = basic_test
UNEQUAL_OUT = unequal_test
LEFT_TURN_OUT = left_turn_test
TOP_OUT = top_test
FULL_OUT = full_test

# VCD文件
BASIC_VCD = basic_test.vcd
UNEQUAL_VCD = unequal_test.vcd
LEFT_TURN_VCD = left_turn_test.vcd
TOP_VCD = traffic_light_top_test.vcd
FULL_VCD = traffic_light_test.vcd

# 默认目标
all: compile_all

# 编译所有模块
compile_all: $(BASIC_OUT) $(UNEQUAL_OUT) $(LEFT_TURN_OUT) $(TOP_OUT) $(FULL_OUT)

# 编译基本版本
$(BASIC_OUT): $(BASIC_SRC)
	$(IVERILOG) -o $(BASIC_OUT) $(BASIC_SRC)

# 编译不等时版本
$(UNEQUAL_OUT): $(UNEQUAL_SRC)
	$(IVERILOG) -o $(UNEQUAL_OUT) $(UNEQUAL_SRC)

# 编译左转版本
$(LEFT_TURN_OUT): $(LEFT_TURN_SRC)
	$(IVERILOG) -o $(LEFT_TURN_OUT) $(LEFT_TURN_SRC)

# 编译顶层模块
$(TOP_OUT): $(ALL_SRC) $(TOP_TB_SRC)
	$(IVERILOG) -o $(TOP_OUT) $(ALL_SRC) $(TOP_TB_SRC)

# 编译完整测试平台
$(FULL_OUT): $(ALL_SRC) $(TB_SRC)
	$(IVERILOG) -o $(FULL_OUT) $(ALL_SRC) $(TB_SRC)

# 运行仿真
sim_top: $(TOP_OUT)
	$(VVP) $(TOP_OUT)

sim_full: $(FULL_OUT)
	$(VVP) $(FULL_OUT)

# 查看波形
wave_top: $(TOP_VCD)
	$(GTKWAVE) $(TOP_VCD)

wave_full: $(FULL_VCD)
	$(GTKWAVE) $(FULL_VCD)

# 运行所有测试
test: sim_top sim_full

# 语法检查
syntax_check:
	@echo "检查基本控制器语法..."
	$(IVERILOG) -t null $(BASIC_SRC)
	@echo "检查不等时控制器语法..."
	$(IVERILOG) -t null $(UNEQUAL_SRC)
	@echo "检查左转控制器语法..."
	$(IVERILOG) -t null $(LEFT_TURN_SRC)
	@echo "检查顶层模块语法..."
	$(IVERILOG) -t null $(ALL_SRC)
	@echo "所有语法检查通过！"

# 清理生成的文件
clean:
	rm -f $(BASIC_OUT) $(UNEQUAL_OUT) $(LEFT_TURN_OUT) $(TOP_OUT) $(FULL_OUT)
	rm -f *.vcd
	rm -f *.lxt

# 显示帮助信息
help:
	@echo "可用的make目标："
	@echo "  all          - 编译所有模块"
	@echo "  compile_all  - 编译所有模块"
	@echo "  sim_top      - 运行顶层模块仿真"
	@echo "  sim_full     - 运行完整测试平台仿真"
	@echo "  test         - 运行所有测试"
	@echo "  syntax_check - 检查所有模块语法"
	@echo "  wave_top     - 查看顶层模块波形"
	@echo "  wave_full    - 查看完整测试波形"
	@echo "  clean        - 清理生成的文件"
	@echo "  help         - 显示此帮助信息"

.PHONY: all compile_all sim_top sim_full test syntax_check clean help wave_top wave_full