# 五级流水线RISC-V CPU

这是一个用Verilog实现的五级流水线RISC-V CPU，支持9条基本指令。

## 支持的指令

### R型指令 (3条)
- `add rd, rs1, rs2` - 加法运算
- `slt rd, rs1, rs2` - 有符号比较（小于则置1）
- `sltu rd, rs1, rs2` - 无符号比较（小于则置1）

### I型指令 (2条)
- `ori rd, rs1, imm` - 立即数或运算
- `lw rd, imm(rs1)` - 从内存加载字

### U型指令 (1条)
- `lui rd, imm` - 加载高位立即数

### S型指令 (1条)
- `sw rs2, imm(rs1)` - 向内存存储字

### B型指令 (1条)
- `beq rs1, rs2, imm` - 相等时分支

### J型指令 (1条)
- `jal rd, imm` - 跳转并链接

## 流水线架构

CPU采用经典的五级流水线设计：

1. **IF (Instruction Fetch)** - 指令取指
2. **ID (Instruction Decode)** - 指令译码和寄存器读取
3. **EX (Execute)** - 执行运算和地址计算
4. **MEM (Memory Access)** - 内存访问
5. **WB (Write Back)** - 结果写回寄存器

## 冒险处理

### 数据冒险
- **转发机制**: 实现了EX-EX和MEM-EX转发，解决大部分RAW冒险
- **Load-Use冒险**: 通过插入气泡（stall）处理

### 控制冒险
- **分支预测**: 采用静态预测不跳转策略
- **Flush机制**: 分支跳转时清空流水线中的错误指令

## 文件结构

```
cpu/
├── src/                    # 源代码目录
│   ├── defines.v          # 常量定义
│   ├── cpu_top.v          # 顶层CPU模块
│   ├── pc_reg.v           # PC寄存器
│   ├── instruction_memory.v # 指令存储器
│   ├── register_file.v    # 寄存器文件
│   ├── alu.v              # 算术逻辑单元
│   ├── data_memory.v      # 数据存储器
│   ├── immediate_generator.v # 立即数生成器
│   ├── control_unit.v     # 控制单元
│   ├── if_id_reg.v        # IF/ID流水线寄存器
│   ├── id_ex_reg.v        # ID/EX流水线寄存器
│   ├── ex_mem_reg.v       # EX/MEM流水线寄存器
│   ├── mem_wb_reg.v       # MEM/WB流水线寄存器
│   ├── hazard_detection_unit.v # 冒险检测单元
│   ├── forwarding_unit.v  # 转发单元
│   ├── branch_unit.v      # 分支单元
│   ├── pc_mux.v           # PC多路选择器
│   └── writeback_mux.v    # 写回多路选择器
├── testbench/             # 测试平台目录
│   └── cpu_tb.v           # CPU测试平台
├── docs/                  # 文档目录
│   └── instruction_set.md # 指令集文档
├── Makefile              # 构建脚本
└── README.md             # 说明文档
```

## 使用方法

### 环境要求
- Icarus Verilog (iverilog)
- GTKWave (可选，用于查看波形)

### 编译和运行

1. **编译CPU设计**:
   ```bash
   make all
   ```

2. **运行测试**:
   ```bash
   make test
   ```

3. **查看波形** (需要GTKWave):
   ```bash
   make wave
   ```

4. **清理构建文件**:
   ```bash
   make clean
   ```

### 测试程序

测试平台包含一个综合测试程序，验证所有9条指令的功能：

1. `lui x1, 0x12345` - 测试LUI指令
2. `ori x2, x1, 0x678` - 测试ORI指令
3. `add x3, x1, x2` - 测试ADD指令
4. `slt x4, x1, x2` - 测试SLT指令
5. `sltu x5, x2, x1` - 测试SLTU指令
6. `sw x2, 0(x0)` - 测试SW指令
7. `lw x6, 0(x0)` - 测试LW指令
8. `beq x2, x6, 8` - 测试BEQ指令（应该跳转）
9. `jal x8, 8` - 测试JAL指令

### 测试结果

**所有9条指令类型全部通过测试！** 🎉

- ✅ **LUI**: 立即数加载到高位 (0x12345000)
- ✅ **ORI**: 按位或立即数运算 (0x12345678)
- ✅ **ADD**: 寄存器加法运算 (0x2468a678)
- ✅ **SLT**: 有符号比较指令 (1)
- ✅ **SLTU**: 无符号比较指令 (0)
- ✅ **SW**: 存储字指令 (内存写入成功)
- ✅ **LW**: 加载字指令 (0x12345678)
- ✅ **BEQ**: 分支相等指令 (正确跳转)
- ✅ **JAL**: 跳转并链接指令 (PC+4保存成功)

### 关键修复

在开发过程中解决了一个重要的数据冒险问题：
- **问题**: SLTU指令在读取寄存器时获取到过期数据
- **原因**: 寄存器文件的读写时序不匹配
- **解决**: 实现了寄存器文件内部转发机制，当读写地址相同时直接返回写入数据

## 设计特点

### 优点
- **完整的流水线实现**: 包含所有必要的流水线寄存器和控制逻辑
- **冒险处理**: 实现了数据转发和冒险检测机制
- **模块化设计**: 每个功能单元都是独立的模块，便于理解和维护
- **标准RISC-V指令格式**: 严格按照RISC-V指令集架构实现

### 局限性
- **简化的分支预测**: 只实现了静态预测不跳转
- **有限的指令集**: 只支持9条基本指令
- **简单的存储器**: 指令和数据存储器都是简化实现

## 扩展建议

1. **增加更多指令**: 可以添加更多RISC-V指令，如sub、and、xor等
2. **改进分支预测**: 实现动态分支预测器
3. **缓存系统**: 添加指令缓存和数据缓存
4. **异常处理**: 实现中断和异常处理机制
5. **性能优化**: 添加超标量执行或乱序执行

## 参考资料

- Patterson & Hennessy, "Computer Organization and Design", 第4章
- RISC-V指令集手册
- "Formal Verification of Pipelined Microprocessors" (Burch et al., 1994)