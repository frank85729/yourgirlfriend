# Makefile for 5-stage pipeline CPU

# 工具链设置
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# 目录设置
SRC_DIR = src
TB_DIR = testbench
BUILD_DIR = build

# 源文件
SOURCES = $(SRC_DIR)/defines.v \
          $(SRC_DIR)/pc_reg.v \
          $(SRC_DIR)/instruction_memory.v \
          $(SRC_DIR)/register_file.v \
          $(SRC_DIR)/alu.v \
          $(SRC_DIR)/data_memory.v \
          $(SRC_DIR)/immediate_generator.v \
          $(SRC_DIR)/control_unit.v \
          $(SRC_DIR)/if_id_reg.v \
          $(SRC_DIR)/id_ex_reg.v \
          $(SRC_DIR)/ex_mem_reg.v \
          $(SRC_DIR)/mem_wb_reg.v \
          $(SRC_DIR)/hazard_detection_unit.v \
          $(SRC_DIR)/forwarding_unit.v \
          $(SRC_DIR)/branch_unit.v \
          $(SRC_DIR)/pc_mux.v \
          $(SRC_DIR)/writeback_mux.v \
          $(SRC_DIR)/cpu_top.v

# 测试文件
TESTBENCH = $(TB_DIR)/cpu_tb.v
DEBUG_TESTBENCH = $(TB_DIR)/debug_tb.v

# 目标文件
TARGET = $(BUILD_DIR)/cpu_tb
DEBUG_TARGET = $(BUILD_DIR)/debug_tb
VCD_FILE = $(BUILD_DIR)/cpu_tb.vcd
DEBUG_VCD_FILE = $(BUILD_DIR)/debug_tb.vcd

# 默认目标
all: $(TARGET)

# 创建构建目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# 编译
$(TARGET): $(SOURCES) $(TESTBENCH) | $(BUILD_DIR)
	$(IVERILOG) -o $(TARGET) -I$(SRC_DIR) $(SOURCES) $(TESTBENCH)

# 编译调试版本
$(DEBUG_TARGET): $(SOURCES) $(DEBUG_TESTBENCH) | $(BUILD_DIR)
	$(IVERILOG) -o $(DEBUG_TARGET) -I$(SRC_DIR) $(SOURCES) $(DEBUG_TESTBENCH)

# 运行仿真
sim: $(TARGET)
	cd $(BUILD_DIR) && $(VVP) cpu_tb

# 查看波形
wave: $(VCD_FILE)
	$(GTKWAVE) $(VCD_FILE)

# 使用预配置的波形查看
wave-config: $(VCD_FILE) cpu_waveform.gtkw
	$(GTKWAVE) -f $(VCD_FILE) -a cpu_waveform.gtkw

# 生成波形分析报告
wave-info: $(VCD_FILE)
	@echo "=== 5级流水线CPU波形文件信息 ==="
	@echo "文件: $(VCD_FILE)"
	@echo "大小: $$(ls -lh $(VCD_FILE) | awk '{print $$5}')"
	@echo "生成时间: $$(ls -l $(VCD_FILE) | awk '{print $$6, $$7, $$8}')"
	@echo ""
	@echo "包含信号数量: $$(grep -c '$$var' $(VCD_FILE) || echo 'N/A')"
	@echo "仿真时间: $$(tail -10 $(VCD_FILE) | grep -o '#[0-9]*' | tail -1 | sed 's/#//' || echo 'N/A')ps"
	@echo ""
	@echo "查看波形："
	@echo "  make wave          # 使用GTKWave查看"
	@echo "  make wave-config   # 使用预配置查看"
	@echo ""
	@echo "波形分析指南: waveform_guide.md"

# 运行测试并生成波形
test: $(TARGET)
	cd $(BUILD_DIR) && $(VVP) cpu_tb
	@echo "Simulation completed. Check the output above for test results."

# 运行调试测试
debug: $(DEBUG_TARGET)
	cd $(BUILD_DIR) && $(VVP) debug_tb
	@echo "Debug simulation completed. Check the output above for test results."

# 清理
clean:
	rm -rf $(BUILD_DIR)

# 显示帮助
help:
	@echo "Available targets:"
	@echo "  all    - Compile the CPU design"
	@echo "  sim    - Run simulation"
	@echo "  test   - Run test and show results"
	@echo "  debug  - Run debug test"
	@echo "  wave   - View waveform (requires GTKWave)"
	@echo "  clean  - Clean build files"
	@echo "  help   - Show this help"

.PHONY: all sim wave test debug clean help