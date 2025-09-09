#!/bin/bash

# 5级流水线CPU波形生成脚本
# 生成包含关键信号的VCD波形文件

echo "=== 5级流水线CPU波形生成 ==="

# 清理旧文件
rm -f build/cpu_tb build/cpu_tb.vcd

# 编译
echo "编译CPU设计..."
iverilog -o build/cpu_tb -Isrc \
    src/defines.v \
    src/pc_reg.v \
    src/instruction_memory.v \
    src/register_file.v \
    src/alu.v \
    src/data_memory.v \
    src/immediate_generator.v \
    src/control_unit.v \
    src/if_id_reg.v \
    src/id_ex_reg.v \
    src/ex_mem_reg.v \
    src/mem_wb_reg.v \
    src/hazard_detection_unit.v \
    src/forwarding_unit.v \
    src/branch_unit.v \
    src/pc_mux.v \
    src/writeback_mux.v \
    src/cpu_top.v \
    testbench/cpu_tb.v

if [ $? -ne 0 ]; then
    echo "编译失败！"
    exit 1
fi

# 运行仿真生成VCD
echo "运行仿真生成波形..."
cd build && vvp cpu_tb

if [ $? -ne 0 ]; then
    echo "仿真失败！"
    exit 1
fi

# 检查VCD文件
if [ -f "cpu_tb.vcd" ]; then
    echo "✅ VCD波形文件生成成功: build/cpu_tb.vcd"
    echo "文件大小: $(ls -lh cpu_tb.vcd | awk '{print $5}')"
    echo ""
    echo "包含的关键信号："
    echo "- 时钟和复位信号"
    echo "- PC和指令信号"
    echo "- 流水线各阶段信号"
    echo "- ALU操作和结果"
    echo "- 寄存器文件状态"
    echo "- 数据转发信号"
    echo "- 分支跳转信号"
    echo ""
    echo "使用GTKWave查看波形："
    echo "  gtkwave build/cpu_tb.vcd"
    echo ""
    echo "或者使用在线波形查看器："
    echo "  https://wavedrom.com/"
else
    echo "❌ VCD文件生成失败！"
    exit 1
fi