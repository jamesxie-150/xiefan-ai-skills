---
name: xf-radiology-schedule
description: "放射科周排班工时盈亏计算器。Use when: 排班计算, 放射科排班, 休假盈亏, 工时统计, 排班分析, 医院排班, /xf-radiology-schedule。自动解析放射科医生周排班文本，按标准双休制（周休2天为基准）计算每人工时盈亏，输出 Markdown 统计表格。"
argument-hint: "优先按 references/input-reference.md 的格式粘贴数据：姓名 + 7个状态，或仅7个状态。"
---

# 放射科周排班工时盈亏计算器

> 版本 v1.1.0（输入用例驱动版）

本 Skill 以参考输入文档中的案例为准进行解析与容错，并按标准输出文档统一生成结果。

## 必读文档（执行前）

每次执行必须先读取以下文档：

1. [input-reference.md](./references/input-reference.md)
2. [word-input-spec.md](./references/word-input-spec.md)
3. [schedule-rules.md](./references/schedule-rules.md)
4. [output-format.md](./references/output-format.md)
5. [fixed-output-template.md](./references/fixed-output-template.md)

如果没有先读取以上文档，不得开始计算。

## ⚠️ 强制响应头

每次输出必须以如下两行开头：

```text
放射科排班分析 v1.0.0
---
```

## ⚠️ 固定输出模式（Markdown Only）

- 仅允许使用 Markdown 输出。
- 输出结构必须严格复用 [fixed-output-template.md](./references/fixed-output-template.md)。
- 不允许在模板之外追加自由段落（除用户明确要求附加说明）。
- 无论是否有数据错误，模板中的章节都必须保留。

## ⚠️ 强制交互要求

每次回答结束必须调用 `ask_question` 工具向用户确认下一步，不可省略。

- 正常统计完成时：询问是否继续下一组数据或导出 Excel。
- 有错误条目时：先给出可计算结果与错误列表，再询问是否修正并重算。
- 仅规则解释时：询问是否需要立即试跑一组真实排班。

## When to Use

- 用户上传或粘贴 Word 文档（.docx）路径，Skill 自动解析表格
- 用户粘贴放射科周排班纯文本并要求计算休假盈亏
- 用户希望校验输入格式是否为每人 7 项
- 用户需要识别半天休、值修、下派等特殊状态
- 用户触发 `/xf-radiology-schedule`

## 设计原则（基于输入用例）

1. 输入优先：
   - Word 文档为默认首选（自动提取表格）
   - 兼容 [input-reference.md](./references/input-reference.md) 中所有合法纯文本示例
2. 校验优先：发现非 7 项时必须报错并跳过该人，严禁错位拼接。
3. 规则稳定：状态权重判定只来自 [schedule-rules.md](./references/schedule-rules.md)。
4. 输出一致：结果结构、字段、符号按 [output-format.md](./references/output-format.md) 固定输出。

## 处理流程

### Step 0. 输入类型检测（新增）

在进行任何处理前，先判断输入类型：

1. 若输入包含 `.docx` 文件路径或用户上传了 Word 文件：
   - 进入 Word 解析流程（见 Step 1a）
   - 优先级高于纯文本输入
2. 否则按纯文本处理（见 Step 1b）

> Word 文档为**默认与优先输入方式**。

### Step 1a. Word 文档解析（含文件读取）

当输入为 `.docx` 文件时：

1. 读取文件的内部结构（`word/document.xml`）
2. 遍历所有表格元素 `<w:tbl>`，提取首个有效表格（行数 ≥ 2）
3. 逐行提取数据：
   - 跳过表头（首行）
   - 每行解析列数：
     - **8 列**（姓名 + 7 天状态）：正常解析
     - **2 列**（姓名 + 1 个状态）：视为整周同一工作安排，自动将该状态扩展为 7 天
     - 其余列数：记录为错误并跳过
4. 清理文本：
   - 替换 XML 实体（`&amp;` → `&`，`&lt;` → `<` 等）
   - 去除多余空格与制表符
   - 合并被拆分的姓名
5. 进入 Step 2（状态映射）

参考文档：[word-input-spec.md](./references/word-input-spec.md)

### Step 1b. 纯文本预处理（原有）

输入来源可为纯文本或 Excel 粘贴文本，处理顺序如下：

1. 清理字符：将 Tab、中文逗号、多个空格统一为单空格。
2. 切分记录：优先按换行拆分为多人记录。
3. 识别姓名列：
   - 若首 token 非已知状态码，首 token 视为姓名。
   - 否则该行按“无姓名格式”处理，人员标识使用序号。
   - 若检测到姓名被空格拆分（如“卢 长宇”），先执行姓名纠正合并，再进行7项校验。
4. 数据完整性校验：
   - 每人状态项必须恰好 7 个，或恰好 1 个（单状态行，自动扩展为 7 天）。

错误格式统一输出：

```text
⚠️ 数据格式错误：第N人（姓名或序号）排班项数为M，应为7，已跳过。
```

### Step 2. 单日状态映射（按规则手册）

按以下优先级计算每个状态权重：

1. 权重 0：包含 `值修`、`下派`、`规培`、`进修`、`怀孕`、`休假`、`补休`。
   - 别名规则：`值休` 视为 `值修`，权重 0。
2. 权重 1：状态完全等于 `休`。
3. 权重 0.5：包含 `/休` 或 `休/`，或精确命中 `上彩/修`。
4. 权重 0：其余全部状态（普通班次/未知状态）。
   - 明确包含：`体检/上`、`上彩/新区`、`新区/办公`、`新区/开会` 等非休斜杠组合。

### Step 3. 汇总计算

```text
实际休假天数 = 7天权重求和
盈亏结果 = 2 - 实际休假天数
```

结果含义：

- 盈亏 > 0：少休（显示 `+`）
- 盈亏 = 0：正常
- 盈亏 < 0：多休

### Step 4. 输出生成（按输出规范）

必须使用 [output-format.md](./references/output-format.md) 和 [fixed-output-template.md](./references/fixed-output-template.md) 的字段与顺序：

1. 强制响应头
2. 本周排班工时盈亏统计表
3. 基准说明
4. 计算说明
5. 数据错误（如有）
6. 未知状态码清单（如有）

未知状态码处理规则：

- 先按权重 0 参与计算，保证结果可出。
- 同时在“未知状态码清单”中提示用户确认定义。

### Step 5. 收尾交互（必须 ask_question）

每次回答最后必须调用 `ask_question`，建议选项：

- 是否需要导出为 Excel 格式？
- 是否继续分析下一组排班数据？
- 是否需要定义或修改未知状态码权重？

固定提问建议（优先复用）：

- 是否继续分析下一组排班数据？
- 是否需要导出为 Excel 格式？
- 是否需要调整某个状态码的权重定义？

## 输出契约

输出内容必须满足以下约束：

1. 数值精度：仅出现 0.5 的倍数。
2. 正值带 `+` 号，零值显示 `0`。
3. 周一到周日按输入顺序展示，不做日期重排。
4. 单次结果中允许部分人员失败（格式错），但必须标明并继续处理成功人员。

## 扩展接口

新增状态码时，必须同时更新：

1. [schedule-rules.md](./references/schedule-rules.md) 的扩展状态码表
2. [input-reference.md](./references/input-reference.md) 的合法输入样例
3. [output-format.md](./references/output-format.md) 的说明（若展示字段变化）

## Limitations

- 仅支持单周 7 天统计，不支持跨周累计。
- 仅支持文本输入，不支持图片/PDF 直接解析。
- `上彩/修` 当前为硬编码特例，若业务变化需同步改规则文档。
