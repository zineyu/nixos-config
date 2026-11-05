# Skills

按**命令**分类：一个目录对应一个 `/命令`，目录内的技能就是该命令会路由到的技能，路由表写在
`programs/dev/pi/prompts/<命令>.md` 里。

`principles/` 与 `tools/` 不在命令序列上，前者是被各层点名引用的判据，后者是跨阶段的工具。
`references/` 放被多个技能共用的清单，不是技能分类。

`modules/base/agent-skills` 递归扫描本目录，把每个 skill 扁平链接到 `~/.agents/skills/<name>`，
因此分类只影响仓库布局，不影响 agent 侧的技能名与触发方式。

| 分类 | 数量 | 对应命令 | 范围 |
|---|---|---|---|
| [`spec`](#spec) | 4 | /spec | 定义 — 把想法与决策收敛成 spec。 |
| [`plan`](#plan) | 5 | /plan | 规划 — 把 spec 拆成可执行的工单。 |
| [`build`](#build) | 15 | /build | 实现 — 写代码：设计、实现、调试。 |
| [`test`](#test) | 5 | /test | 验证 — 开发完成后，对着真实产物与波及面测试。 |
| [`review`](#review) | 4 | /review | 评审 — 提交前读 diff：标准与规格。 |
| [`code-simplify`](#code-simplify) | 2 | /code-simplify | 简化 — 不改行为地降低复杂度。 |
| [`perf`](#perf) | 1 | /perf | 测量 — 报性能数字之前先核查。 |
| [`refactor`](#refactor) | 1 | /refactor | 重构候选 — 跨维度扫描可重构之处，只出清单。 |
| [`gate`](#gate) | 4 | /gate | 门槛 — 把质量与安全写成可执行的门槛并守住。 |
| [`ship`](#ship) | 3 | /ship | 交付 — 部署、观测、描述改动。 |
| [`principles`](#principles) | 21 | — | 判据 — 跨阶段复用的判断标准，被上面各层点名引用。 |
| [`tools`](#tools) | 19 | — | 工具 — 跨阶段的工具与这个技能集自身的维护。 |

合计 **84** 个技能。另有 `references/` 存放被多个技能共用的清单，不是技能分类。

<a id="spec"></a>

## 定义 — `spec/` · `/spec`

把想法与决策收敛成 spec。

| 技能 | 作用 |
|---|---|
| [`domain-modeling`](./spec/domain-modeling/SKILL.md) | 维护项目的领域语言：术语表与 ADR 的写法与演进。 |
| [`interview-me`](./spec/interview-me/SKILL.md) | 一次一问直到能预测用户的反应；产出确认过的意图，供 /spec、/triage、/wayfinder 使用。 |
| [`in-your-own-words`](./spec/in-your-own-words/SKILL.md) | 开工前先用自己的话复述一遍你理解的目标与问题。（手动 /skill: 调用） |
| [`to-spec`](./spec/to-spec/SKILL.md) | 把当前对话整理成 spec 并发布到 issue 跟踪器。（手动 /skill: 调用） |

<a id="plan"></a>

## 规划 — `plan/` · `/plan`

把 spec 拆成可执行的工单。

| 技能 | 作用 |
|---|---|
| [`sharpen`](./plan/sharpen/SKILL.md) | 把任务改深而不是改大，然后重写这条任务。（手动 /skill: 调用） |
| [`to-questionnaire`](./plan/to-questionnaire/SKILL.md) | 把你自己答不了的决策，变成一份请别人填的问卷。（手动 /skill: 调用） |
| [`to-tickets`](./plan/to-tickets/SKILL.md) | 把计划拆成带阻塞关系的 tracer-bullet 工单。（手动 /skill: 调用） |
| [`triage`](./plan/triage/SKILL.md) | 用一套角色状态机推动 issue 与外部 PR 往前走。（手动 /skill: 调用） |
| [`wayfinder`](./plan/wayfinder/SKILL.md) | 把超过一个会话的大工程，规划成一张决策票地图。（手动 /skill: 调用） |

<a id="build"></a>

## 实现 — `build/` · `/build`

写代码：设计、实现、调试。

| 技能 | 作用 |
|---|---|
| [`architect`](./build/architect/SKILL.md) | 先画出类型、签名与模块骨架，再填实现，避免过早锁死结构。（手动 /skill: 调用） |
| [`arena`](./build/arena/SKILL.md) | 让 N 个候选各做一版，选出基准再嫁接别人的强项。（手动 /skill: 调用） |
| [`codebase-design`](./build/codebase-design/SKILL.md) | 提供“深模块”设计词汇，用来讨论和改进入口与接口的形状。 |
| [`diagnosing-bugs`](./build/diagnosing-bugs/SKILL.md) | 用“假设—验证”闭环定位难查的 bug 与性能回归。 |
| [`domain-driven-design`](./build/domain-driven-design/SKILL.md) | 用限界上下文、聚合、防腐层划分业务边界并组织代码。 |
| [`frontend-ui-engineering`](./build/frontend-ui-engineering/SKILL.md) | 做出可访问、响应式、生产质量的界面。 |
| [`how`](./build/how/SKILL.md) | 讲清一个子系统怎么运转，并判断代码该放在哪一层、归谁拥有。（手动 /skill: 调用） |
| [`implement`](./build/implement/SKILL.md) | 按 spec 或工单实现一个工作单元，内置 TDD 与评审。（手动 /skill: 调用） |
| [`implement-spec`](./build/implement-spec/SKILL.md) | 把整份 spec 当任务图并行推进，最后落到一条集成分支。（手动 /skill: 调用） |
| [`prototype`](./build/prototype/SKILL.md) | 造一个一次性原型，用能跑的东西回答一个设计问题。 |
| [`statechart`](./build/statechart/SKILL.md) | 用 TLA+ 检查状态机，并画出 Mermaid 状态图。（手动 /skill: 调用） |
| [`swarm`](./build/swarm/SKILL.md) | 扇出 N 个 worker 做分片或赛跑，收齐后交一份汇总。（手动 /skill: 调用） |
| [`tdd`](./build/tdd/SKILL.md) | 红—绿—重构，一次推进一个行为切片。 |
| [`typescript-best-practices`](./build/typescript-best-practices/SKILL.md) | 读写 `.ts`/`.tsx` 时的类型与边界规则。 |
| [`why`](./build/why/SKILL.md) | 挖出代码为什么长成现在这样：设计取舍、回归原因、阈值来源，全部带引用。（手动 /skill: 调用） |

<a id="test"></a>

## 验证 — `test/` · `/test`

开发完成后，对着真实产物与波及面测试。

| 技能 | 作用 |
|---|---|
| [`blast-radius`](./test/blast-radius/SKILL.md) | 找出改动会波及 diff 之外的哪些地方，并跑真实代码证明那条安全前提。（手动 /skill: 调用） |
| [`create-formal-verification-skill`](./test/create-formal-verification-skill/SKILL.md) | 在最贵、测试覆盖最少的地方建形式化验证。（手动 /skill: 调用） |
| [`create-verification-skill`](./test/create-verification-skill/SKILL.md) | 生成一个像用户那样驱动本项目的验证技能。（手动 /skill: 调用） |
| [`maintain-formal-verification-skill`](./test/maintain-formal-verification-skill/SKILL.md) | 代码变动后，把形式化验证与模型同步回正。（手动 /skill: 调用） |
| [`maintain-verification-skill`](./test/maintain-verification-skill/SKILL.md) | 定期让验证技能与功能地图重新对齐代码现状。（手动 /skill: 调用） |

<a id="review"></a>

## 评审 — `review/` · `/review`

提交前读 diff：标准与规格。

| 技能 | 作用 |
|---|---|
| [`code-reuse`](./review/code-reuse/SKILL.md) | 判断该直接复用、该抽公共模块，还是该保留这份重复。 |
| [`code-review`](./review/code-review/SKILL.md) | 对着一个固定基准点，按 Standards + Spec 双轴评审，并覆盖正确性/可读性/架构/安全/性能五维。 |
| [`interrogate`](./review/interrogate/SKILL.md) | 多个模型交叉攻击同一份改动，专找盲点并要求给复现。（手动 /skill: 调用） |
| [`second-pass`](./review/second-pass/SKILL.md) | 回头审自己刚做完的工作：找更好的实现与被浪费的步骤。（手动 /skill: 调用） |

<a id="code-simplify"></a>

## 简化 — `code-simplify/` · `/code-simplify`

不改行为地降低复杂度。

| 技能 | 作用 |
|---|---|
| [`code-simplification`](./code-simplify/code-simplification/SKILL.md) | 在不改行为的前提下，把难读的代码改到读得懂。 |
| [`no-comments`](./code-simplify/no-comments/SKILL.md) | 删掉废话注释，把“不能改”的约束改写成类型、断言或 lint。（手动 /skill: 调用） |

<a id="perf"></a>

## 测量 — `perf/` · `/perf`

报性能数字之前先核查。

| 技能 | 作用 |
|---|---|
| [`benchmark-checklist`](./perf/benchmark-checklist/SKILL.md) | 报性能数字之前先自查限幅、误差、可重复性与相关性。（手动 /skill: 调用） |

<a id="refactor"></a>

## 重构候选 — `refactor/` · `/refactor`

跨维度扫描可重构之处，只出清单，不动代码。

| 技能 | 作用 |
|---|---|
| [`improve-codebase-architecture`](./refactor/improve-codebase-architecture/SKILL.md) | 扫描代码库里可被加深的模块缝隙，出可视化报告；选中后交给 `/plan`。 |

<a id="gate"></a>

## 门槛 — `gate/` · `/gate`

把质量与安全写成可执行的门槛并守住。

| 技能 | 作用 |
|---|---|
| [`ci-cd-and-automation`](./gate/ci-cd-and-automation/SKILL.md) | 把质量门接进流水线，并让 CI 失败回流给 agent。 |
| [`constraint-driven-development`](./gate/constraint-driven-development/SKILL.md) | 把质量门槛写成带数字的 `CONSTRAINTS.md`，并守住它不被悄悄放宽。 |
| [`correct`](./gate/correct/SKILL.md) | 找出 agent 反复犯的错，用架构、类型、lint、测试让它们无法再犯。（手动 /skill: 调用） |
| [`security-and-hardening`](./gate/security-and-hardening/SKILL.md) | 先威胁建模，再在边界上加固：输入、鉴权、密钥、依赖与隐私。 |

<a id="ship"></a>

## 交付 — `ship/` · `/ship`

部署、观测、描述改动。

| 技能 | 作用 |
|---|---|
| [`observability-and-instrumentation`](./ship/observability-and-instrumentation/SKILL.md) | 加日志、指标、追踪，让线上行为可观测、可诊断。 |
| [`pr`](./ship/pr/SKILL.md) | 写 PR 描述：把动机、改动与验证讲清楚。 |
| [`shipping-and-launch`](./ship/shipping-and-launch/SKILL.md) | 部署前想清楚：可回滚、可观测、逐台推进。 |

<a id="principles"></a>

## 判据 — `principles/`

跨阶段复用的判断标准，被上面各层点名引用。

| 技能 | 作用 |
|---|---|
| [`principle-boundary-discipline`](./principles/principle-boundary-discipline/SKILL.md) | 校验集中在系统边界（CLI、配置、网络、外部 API），内部信任类型。（手动 /skill: 调用） |
| [`principle-build-the-lever`](./principles/principle-build-the-lever/SKILL.md) | 重复劳动先造工具（脚本、检查、生成器），而不是手工再来一遍。（手动 /skill: 调用） |
| [`principle-encode-lessons-in-structure`](./principles/principle-encode-lessons-in-structure/SKILL.md) | 同一条纠正出现两次，就把它编码进 lint、类型或结构。（手动 /skill: 调用） |
| [`principle-exhaust-the-design-space`](./principles/principle-exhaust-the-design-space/SKILL.md) | 没有先例的交互或架构决策，先做 2–3 个原型并排比。（手动 /skill: 调用） |
| [`principle-explain-the-number`](./principles/principle-explain-the-number/SKILL.md) | 报任何数字之前，先解释它从哪来、误差有多大。（手动 /skill: 调用） |
| [`principle-fix-root-causes`](./principles/principle-fix-root-causes/SKILL.md) | 沿症状找到系统第一次出错的地方，并且在那里修。（手动 /skill: 调用） |
| [`principle-foundational-thinking`](./principles/principle-foundational-thinking/SKILL.md) | 写逻辑之前，先把核心类型、数据结构与并发共享定下来。（手动 /skill: 调用） |
| [`principle-guard-the-context-window`](./principles/principle-guard-the-context-window/SKILL.md) | 上下文将满时把大块工作交给 subagent，主线程只留摘要。（手动 /skill: 调用） |
| [`principle-laziness-protocol`](./principles/principle-laziness-protocol/SKILL.md) | 重构与评审时偏向删除和最小改动，别加抽象。（手动 /skill: 调用） |
| [`principle-make-operations-idempotent`](./principles/principle-make-operations-idempotent/SKILL.md) | 命令、生命周期步骤、重试循环重复执行后收敛到同一状态。（手动 /skill: 调用） |
| [`principle-minimize-reader-load`](./principles/principle-minimize-reader-load/SKILL.md) | 数清从问题到答案之间有几层，以及读者脑中要记住多少隐藏状态。（手动 /skill: 调用） |
| [`principle-model-the-domain`](./principles/principle-model-the-domain/SKILL.md) | 写有状态逻辑之前，先把领域模型想清楚。（手动 /skill: 调用） |
| [`principle-never-block-on-the-human`](./principles/principle-never-block-on-the-human/SKILL.md) | 可逆的工作直接做，不要把“要不要我做”抛回给人。（手动 /skill: 调用） |
| [`principle-outcome-oriented-execution`](./principles/principle-outcome-oriented-execution/SKILL.md) | 迁移期直接收敛到目标架构，不为中间态做平滑。（手动 /skill: 调用） |
| [`principle-prove-it-works`](./principles/principle-prove-it-works/SKILL.md) | 声明完成之前，对着真实产物验一遍。（手动 /skill: 调用） |
| [`principle-redesign-from-first-principles`](./principles/principle-redesign-from-first-principles/SKILL.md) | 接入新需求时，先回头审视现有设计是否该重画。（手动 /skill: 调用） |
| [`principle-separate-before-serializing-shared-state`](./principles/principle-separate-before-serializing-shared-state/SKILL.md) | 多个 actor 写同一处时，先消除共享，再谈序列化。（手动 /skill: 调用） |
| [`principle-sequence-verifiable-units`](./principles/principle-sequence-verifiable-units/SKILL.md) | 把工作切成每个都能独立验证的小单元，commit 与 PR 同理。（手动 /skill: 调用） |
| [`principle-subtract-before-you-add`](./principles/principle-subtract-before-you-add/SKILL.md) | 先删死代码与冗余校验，再往上加新东西。（手动 /skill: 调用） |
| [`principle-test-behavior-not-implementation`](./principles/principle-test-behavior-not-implementation/SKILL.md) | 断言用户可观察的行为，别把内部实现锁死。（手动 /skill: 调用） |
| [`principle-type-system-discipline`](./principles/principle-type-system-discipline/SKILL.md) | 让非法状态无法表示，把校验压到类型层。（手动 /skill: 调用） |

<a id="tools"></a>

## 工具 — `tools/`

跨阶段的工具与这个技能集自身的维护。

| 技能 | 作用 |
|---|---|
| [`ask-skills`](./tools/ask-skills/SKILL.md) | 不知道该用哪个技能时，让它来路由。（手动 /skill: 调用） |
| [`automate-me`](./tools/automate-me/SKILL.md) | 把你的口味与工作方式沉淀成一个 `-mode` 技能。（手动 /skill: 调用） |
| [`find-skill`](./tools/find-skill/SKILL.md) | 发现并安装现成的技能。 |
| [`handoff`](./tools/handoff/SKILL.md) | 把当前对话压缩成交接文档，让另一个 agent 接着干。（手动 /skill: 调用） |
| [`html-report`](./tools/html-report/SKILL.md) | 生成给人类看的单文件 HTML 报告：摘要先行、卡片同构、图表并排。 |
| [`jujutsu`](./tools/jujutsu/SKILL.md) | 用 jj 管理改动：edit 流、squash 流与提交前整理。 |
| [`ketchup`](./tools/ketchup/SKILL.md) | 用白话把“你上次发言之后发生了什么”讲给你听，并列出等你拍板的事。（手动 /skill: 调用） |
| [`novix-worktrace-agent`](./tools/novix-worktrace-agent/SKILL.md) | 在 NovixWorkTrace 中按当前用户权限协作测试反馈、需求、任务与凭证提交。 |
| [`reflect`](./tools/reflect/SKILL.md) | 让三个并行 subagent 复盘本次对话，把经验落成对技能的修改。（手动 /skill: 调用） |
| [`research`](./tools/research/SKILL.md) | 对着高可信来源调研一个问题，并把结论落成带引用的文档。 |
| [`retro`](./tools/retro/SKILL.md) | 复盘一次会话，改进 agent 的工作环境而不只是这次结果。（手动 /skill: 调用） |
| [`setup-skills`](./tools/setup-skills/SKILL.md) | 一次性配置仓库的 issue 跟踪器、分诊标签与文档布局。（手动 /skill: 调用） |
| [`show-me-your-work`](./tools/show-me-your-work/SKILL.md) | 长任务里留一份可审查的决策流水：做了什么、为什么、证据、结果。（手动 /skill: 调用） |
| [`teach`](./tools/teach/SKILL.md) | 用一个目录当长期教学空间，带你从零学一个主题。（手动 /skill: 调用） |
| [`technical-writing`](./tools/technical-writing/SKILL.md) | 面向人的技术写作标准：文档结构、句子与术语。（手动 /skill: 调用） |
| [`unslop`](./tools/unslop/SKILL.md) | 去掉文字里的 AI 腔。（手动 /skill: 调用） |
| [`wait-what`](./tools/wait-what/SKILL.md) | 上一条消息没讲明白时，用大白话重讲一遍。（手动 /skill: 调用） |
| [`wizard`](./tools/wizard/SKILL.md) | 生成一个交互式 bash 向导，陪人走完只有人能做的步骤。 |
| [`writing-for-agents`](./tools/writing-for-agents/SKILL.md) | 写 skill、AGENTS.md 这类“给 agent 读的文档”的规范。 |
