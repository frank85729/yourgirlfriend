# 5级流水线CPU波形分析指南

## 📊 波形文件信息

- **文件位置**: `build/cpu_tb.vcd`
- **文件大小**: 92KB
- **仿真时间**: 2ms (2,000,000 ps)
- **时钟频率**: 100MHz (10ns周期)

## 🔍 关键信号说明

### 基本控制信号
- `clk` - 系统时钟 (100MHz)
- `rst_n` - 复位信号 (低电平有效)

### 程序计数器和指令
- `pc` - 程序计数器
- `if_instruction` - IF阶段取到的指令
- `id_instruction` - ID阶段的指令

### 流水线各阶段信号
- `ex_alu_op` - EX阶段ALU操作码
- `alu_result` - ALU计算结果
- `mem_alu_result` - MEM阶段的ALU结果
- `wb_data` - WB阶段写回数据
- `wb_reg_write` - WB阶段寄存器写使能
- `wb_rd_addr` - WB阶段目标寄存器地址

### 寄存器文件状态
- `registers[1]` - x1寄存器 (LUI结果)
- `registers[2]` - x2寄存器 (ORI结果)
- `registers[3]` - x3寄存器 (ADD结果)
- `registers[4]` - x4寄存器 (SLT结果)
- `registers[5]` - x5寄存器 (SLTU结果)

### 数据转发信号
- `forward_a` - ALU输入A转发控制
- `forward_b` - ALU输入B转发控制
- `forwarded_rs1_data` - 转发后的rs1数据
- `forwarded_rs2_data` - 转发后的rs2数据

### 分支跳转信号
- `branch_taken` - 分支跳转信号
- `jump` - 跳转信号
- `pc_stall` - PC暂停信号

## 🎯 关键时间点分析

### 指令执行时序
1. **0-25ns**: 复位阶段
2. **25-35ns**: LUI指令执行
3. **35-45ns**: ORI指令执行
4. **45-55ns**: ADD指令执行
5. **55-65ns**: SLT指令执行
6. **65-75ns**: SLTU指令执行
7. **75-85ns**: SW指令执行
8. **85-95ns**: LW指令执行
9. **95-115ns**: BEQ指令执行（跳转）
10. **115-135ns**: JAL指令执行

### 数据冒险处理
- **SLTU指令**: 在65-75ns期间，观察转发信号如何处理数据依赖
- **分支跳转**: 在95ns左右观察分支预测和flush机制

## 🛠️ 使用GTKWave查看波形

### 1. 启动GTKWave
```bash
cd cpu
gtkwave build/cpu_tb.vcd
```

### 2. 推荐信号组织
建议按以下顺序添加信号到波形窗口：

#### 基本信号组
```
cpu_tb.u_cpu_top.clk
cpu_tb.u_cpu_top.rst_n
cpu_tb.u_cpu_top.pc
```

#### 指令流水线组
```
cpu_tb.u_cpu_top.if_instruction
cpu_tb.u_cpu_top.id_instruction
cpu_tb.u_cpu_top.ex_alu_op
```

#### ALU和结果组
```
cpu_tb.u_cpu_top.alu_result
cpu_tb.u_cpu_top.mem_alu_result
cpu_tb.u_cpu_top.wb_data
```

#### 寄存器状态组
```
cpu_tb.u_cpu_top.u_register_file.registers[1]
cpu_tb.u_cpu_top.u_register_file.registers[2]
cpu_tb.u_cpu_top.u_register_file.registers[3]
cpu_tb.u_cpu_top.u_register_file.registers[4]
cpu_tb.u_cpu_top.u_register_file.registers[5]
```

#### 转发控制组
```
cpu_tb.u_cpu_top.forward_a
cpu_tb.u_cpu_top.forward_b
cpu_tb.u_cpu_top.forwarded_rs1_data
cpu_tb.u_cpu_top.forwarded_rs2_data
```

### 3. 显示格式建议
- **地址和数据**: 十六进制 (Hex)
- **控制信号**: 二进制 (Binary)
- **时钟**: 二进制 (Binary)

### 4. 时间标尺设置
- **初始视图**: 0-200ns (查看主要指令执行)
- **详细分析**: 50-100ns (查看数据冒险处理)

## 🔬 波形分析要点

### 1. 流水线正确性验证
- 检查每个时钟周期是否有新指令进入流水线
- 验证指令在各阶段的正确传递

### 2. 数据冒险处理验证
- 观察SLTU指令执行时的转发信号
- 确认转发数据的正确性

### 3. 分支跳转验证
- 检查BEQ指令的分支判断
- 验证跳转目标地址的计算
- 观察flush信号的作用

### 4. 寄存器写回验证
- 确认每条指令的结果正确写入目标寄存器
- 验证写回时序的正确性

## 📈 性能分析

### CPI (Cycles Per Instruction)
- 理想情况: 1 CPI (流水线满载)
- 实际情况: 由于分支跳转和数据冒险，略高于1

### 流水线效率
- 观察流水线气泡的产生和处理
- 分析冒险检测和转发的效果

## 🚀 在线波形查看

如果没有GTKWave，可以使用在线工具：
1. 访问 https://wavedrom.com/
2. 上传VCD文件或转换为JSON格式
3. 在线查看和分析波形

## 📝 注意事项

1. **信号命名**: 某些信号可能有转义字符，在GTKWave中正常显示
2. **时间单位**: 波形时间单位为皮秒(ps)，1ns = 1000ps
3. **数据格式**: 32位数据以十六进制显示更直观
4. **缩放**: 使用GTKWave的缩放功能查看不同时间段的细节

---

**这个波形文件完整记录了5级流水线CPU的执行过程，是验证设计正确性和分析性能的重要工具！** 🎉