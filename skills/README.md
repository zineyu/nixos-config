# Skills

按技能**作用于什么**分成四个子目录，每个 skill 仍是独立的 `<category>/<name>/SKILL.md`。
`modules/base/agent-skills` 递归扫描本目录，把每个 skill 扁平链接到 `~/.agents/skills/<name>`，
因此分类只影响仓库布局，不影响 agent 侧的技能名与触发方式。

| 分类 | 数量 | 范围 |
|---|---|---|
| [Code — 作用于代码本身](#code) | 30 | 读懂与设计、实现与重构、审查与验证。 |
| [Workflow — 围绕需求与协作](#workflow) | 24 | 访谈、spec、工单、交付、复盘、写作、多 agent 编排。 |
| [Tools — 工具与集合维护](#tools) | 6 | 仓库工具与这个技能集自身的维护。 |
| [Principles — 判据层](#principles) | 24 | 跨流程复用的判断标准，被上面各层点名引用。 |

合计 **84** 个技能。

<a id="code"></a>

## Code — 作用于代码本身 — `code/`

读懂与设计、实现与重构、审查与验证。

| 技能 | 作用 |
|---|---|
| [`architect`](./code/architect/SKILL.md) | 先画出类型、签名与模块骨架，再填实现，避免过早锁死结构。（手动 /skill: 调用） |
| [`benchmark-checklist`](./code/benchmark-checklist/SKILL.md) | 报性能数字之前先自查限幅、误差、可重复性与相关性。（手动 /skill: 调用） |
| [`blast-radius`](./code/blast-radius/SKILL.md) | 找出改动会波及 diff 之外的哪些地方，并跑真实代码证明那条安全前提。（手动 /skill: 调用） |
| [`code-reuse`](./code/code-reuse/SKILL.md) | 判断该直接复用、该抽公共模块，还是该保留这份重复。 |
| [`code-review`](./code/code-review/SKILL.md) | 针对某个固定基准点，按标准与 spec 两轴评审改动。 |
| [`code-review-and-quality`](./code/code-review-and-quality/SKILL.md) | 多维度质量评审，适合合并前的最后一道关。 |
| [`code-simplification`](./code/code-simplification/SKILL.md) | 在不改行为的前提下，把难读的代码改到读得懂。 |
| [`codebase-design`](./code/codebase-design/SKILL.md) | 提供“深模块”设计词汇，用来讨论和改进入口与接口的形状。 |
| [`correct`](./code/correct/SKILL.md) | 找出 agent 反复犯的错，用架构、类型、lint、测试让它们无法再犯。（手动 /skill: 调用） |
| [`create-formal-verification-skill`](./code/create-formal-verification-skill/SKILL.md) | 在最贵、测试覆盖最少的地方建形式化验证。（手动 /skill: 调用） |
| [`create-verification-skill`](./code/create-verification-skill/SKILL.md) | 生成一个像用户那样驱动本项目的验证技能。（手动 /skill: 调用） |
| [`diagnosing-bugs`](./code/diagnosing-bugs/SKILL.md) | 用“假设—验证”闭环定位难查的 bug 与性能回归。 |
| [`domain-driven-design`](./code/domain-driven-design/SKILL.md) | 用限界上下文、聚合、防腐层划分业务边界并组织代码。 |
| [`domain-modeling`](./code/domain-modeling/SKILL.md) | 维护项目的领域语言：术语表与 ADR 的写法与演进。 |
| [`frontend-ui-engineering`](./code/frontend-ui-engineering/SKILL.md) | 做出可访问、响应式、生产质量的界面。 |
| [`how`](./code/how/SKILL.md) | 讲清一个子系统怎么运转，并判断代码该放在哪一层、归谁拥有。（手动 /skill: 调用） |
| [`implement`](./code/implement/SKILL.md) | 按 spec 或工单实现一个工作单元，内置 TDD 与评审。（手动 /skill: 调用） |
| [`implement-spec`](./code/implement-spec/SKILL.md) | 把整份 spec 当任务图并行推进，最后落到一条集成分支。（手动 /skill: 调用） |
| [`improve-codebase-architecture`](./code/improve-codebase-architecture/SKILL.md) | 扫描代码库里可被加深的模块缝隙，先出可视化报告再逐条落地。（手动 /skill: 调用） |
| [`interrogate`](./code/interrogate/SKILL.md) | 多个模型交叉攻击同一份改动，专找盲点并要求给复现。（手动 /skill: 调用） |
| [`maintain-formal-verification-skill`](./code/maintain-formal-verification-skill/SKILL.md) | 代码变动后，把形式化验证与模型同步回正。（手动 /skill: 调用） |
| [`maintain-verification-skill`](./code/maintain-verification-skill/SKILL.md) | 定期让验证技能与功能地图重新对齐代码现状。（手动 /skill: 调用） |
| [`no-comments`](./code/no-comments/SKILL.md) | 删掉废话注释，把“不能改”的约束改写成类型、断言或 lint。（手动 /skill: 调用） |
| [`observability-and-instrumentation`](./code/observability-and-instrumentation/SKILL.md) | 加日志、指标、追踪，让线上行为可观测、可诊断。 |
| [`prototype`](./code/prototype/SKILL.md) | 造一个一次性原型，用能跑的东西回答一个设计问题。 |
| [`second-pass`](./code/second-pass/SKILL.md) | 回头审自己刚做完的工作：找更好的实现与被浪费的步骤。（手动 /skill: 调用） |
| [`statechart`](./code/statechart/SKILL.md) | 用 TLA+ 检查状态机，并画出 Mermaid 状态图。（手动 /skill: 调用） |
| [`tdd`](./code/tdd/SKILL.md) | 红—绿—重构，一次推进一个行为切片。 |
| [`typescript-best-practices`](./code/typescript-best-practices/SKILL.md) | 读写 `.ts`/`.tsx` 时的类型与边界规则。 |
| [`why`](./code/why/SKILL.md) | 挖出代码为什么长成现在这样：设计取舍、回归原因、阈值来源，全部带引用。（手动 /skill: 调用） |

<a id="workflow"></a>

## Workflow — 围绕需求与协作 — `workflow/`

访谈、spec、工单、交付、复盘、写作、多 agent 编排。

| 技能 | 作用 |
|---|---|
| [`arena`](./workflow/arena/SKILL.md) | 让 N 个候选各做一版，选出基准再嫁接别人的强项。（手动 /skill: 调用） |
| [`automate-me`](./workflow/automate-me/SKILL.md) | 把你的口味与工作方式沉淀成一个 `-mode` 技能。（手动 /skill: 调用） |
| [`grill-me`](./workflow/grill-me/SKILL.md) | 无状态版的追问：不落盘，适合压力测试计划或文章。（手动 /skill: 调用） |
| [`grill-with-docs`](./workflow/grill-with-docs/SKILL.md) | 一边追问，一边把结论写进 ADR 与术语表。（手动 /skill: 调用） |
| [`grilling`](./workflow/grilling/SKILL.md) | 反复追问，直到设计树上每个分支都被解决。 |
| [`handoff`](./workflow/handoff/SKILL.md) | 把当前对话压缩成交接文档，让另一个 agent 接着干。（手动 /skill: 调用） |
| [`in-your-own-words`](./workflow/in-your-own-words/SKILL.md) | 开工前先用自己的话复述一遍你理解的目标与问题。（手动 /skill: 调用） |
| [`ketchup`](./workflow/ketchup/SKILL.md) | 用白话把“你上次发言之后发生了什么”讲给你听，并列出等你拍板的事。（手动 /skill: 调用） |
| [`pr`](./workflow/pr/SKILL.md) | 写 PR 描述：把动机、改动与验证讲清楚。 |
| [`reflect`](./workflow/reflect/SKILL.md) | 让三个并行 subagent 复盘本次对话，把经验落成对技能的修改。（手动 /skill: 调用） |
| [`retro`](./workflow/retro/SKILL.md) | 复盘一次会话，改进 agent 的工作环境而不只是这次结果。（手动 /skill: 调用） |
| [`sharpen`](./workflow/sharpen/SKILL.md) | 把任务改深而不是改大，然后重写这条任务。（手动 /skill: 调用） |
| [`show-me-your-work`](./workflow/show-me-your-work/SKILL.md) | 长任务里留一份可审查的决策流水：做了什么、为什么、证据、结果。（手动 /skill: 调用） |
| [`swarm`](./workflow/swarm/SKILL.md) | 扇出 N 个 worker 做分片或赛跑，收齐后交一份汇总。（手动 /skill: 调用） |
| [`teach`](./workflow/teach/SKILL.md) | 用一个目录当长期教学空间，带你从零学一个主题。（手动 /skill: 调用） |
| [`technical-writing`](./workflow/technical-writing/SKILL.md) | 面向人的技术写作标准：文档结构、句子与术语。（手动 /skill: 调用） |
| [`to-questionnaire`](./workflow/to-questionnaire/SKILL.md) | 把你自己答不了的决策，变成一份请别人填的问卷。（手动 /skill: 调用） |
| [`to-spec`](./workflow/to-spec/SKILL.md) | 把当前对话整理成 spec 并发布到 issue 跟踪器。（手动 /skill: 调用） |
| [`to-tickets`](./workflow/to-tickets/SKILL.md) | 把计划拆成带阻塞关系的 tracer-bullet 工单。（手动 /skill: 调用） |
| [`triage`](./workflow/triage/SKILL.md) | 用一套角色状态机推动 issue 与外部 PR 往前走。（手动 /skill: 调用） |
| [`unslop`](./workflow/unslop/SKILL.md) | 去掉文字里的 AI 腔。（手动 /skill: 调用） |
| [`wait-what`](./workflow/wait-what/SKILL.md) | 上一条消息没讲明白时，用大白话重讲一遍。（手动 /skill: 调用） |
| [`wayfinder`](./workflow/wayfinder/SKILL.md) | 把超过一个会话的大工程，规划成一张决策票地图。（手动 /skill: 调用） |
| [`writing-for-agents`](./workflow/writing-for-agents/SKILL.md) | 写 skill、AGENTS.md 这类“给 agent 读的文档”的规范。 |

<a id="tools"></a>

## Tools — 工具与集合维护 — `tools/`

仓库工具与这个技能集自身的维护。

| 技能 | 作用 |
|---|---|
| [`ask-skills`](./tools/ask-skills/SKILL.md) | 不知道该用哪个技能时，让它来路由。（手动 /skill: 调用） |
| [`find-skill`](./tools/find-skill/SKILL.md) | 发现并安装现成的技能。 |
| [`jujutsu`](./tools/jujutsu/SKILL.md) | 用 jj 管理改动：edit 流、squash 流与提交前整理。 |
| [`research`](./tools/research/SKILL.md) | 对着高可信来源调研一个问题，并把结论落成带引用的文档。 |
| [`setup-skills`](./tools/setup-skills/SKILL.md) | 一次性配置仓库的 issue 跟踪器、分诊标签与文档布局。（手动 /skill: 调用） |
| [`wizard`](./tools/wizard/SKILL.md) | 生成一个交互式 bash 向导，陪人走完只有人能做的步骤。 |

<a id="principles"></a>

## Principles — 判据层 — `principles/`

跨流程复用的判断标准，被上面各层点名引用。

| 技能 | 作用 |
|---|---|
| [`principle-attack-the-premise`](./principles/principle-attack-the-premise/SKILL.md) | 同一前提下的多个修法都失败时，先把前提写下来直接验它。（手动 /skill: 调用） |
| [`principle-boundary-discipline`](./principles/principle-boundary-discipline/SKILL.md) | 校验集中在系统边界（CLI、配置、网络、外部 API），内部信任类型。（手动 /skill: 调用） |
| [`principle-build-the-lever`](./principles/principle-build-the-lever/SKILL.md) | 重复劳动先造工具（脚本、检查、生成器），而不是手工再来一遍。（手动 /skill: 调用） |
| [`principle-encode-lessons-in-structure`](./principles/principle-encode-lessons-in-structure/SKILL.md) | 同一条纠正出现两次，就把它编码进 lint、类型或结构。（手动 /skill: 调用） |
| [`principle-exhaust-the-design-space`](./principles/principle-exhaust-the-design-space/SKILL.md) | 没有先例的交互或架构决策，先做 2–3 个原型并排比。（手动 /skill: 调用） |
| [`principle-experience-first`](./principles/principle-experience-first/SKILL.md) | 产品取舍时选用户体验，宁可少而精。（手动 /skill: 调用） |
| [`principle-explain-the-number`](./principles/principle-explain-the-number/SKILL.md) | 报任何数字之前，先解释它从哪来、误差有多大。（手动 /skill: 调用） |
| [`principle-fix-root-causes`](./principles/principle-fix-root-causes/SKILL.md) | 沿症状找到系统第一次出错的地方，并且在那里修。（手动 /skill: 调用） |
| [`principle-foundational-thinking`](./principles/principle-foundational-thinking/SKILL.md) | 写逻辑之前，先把核心类型、数据结构与并发共享定下来。（手动 /skill: 调用） |
| [`principle-guard-the-context-window`](./principles/principle-guard-the-context-window/SKILL.md) | 上下文将满时把大块工作交给 subagent，主线程只留摘要。（手动 /skill: 调用） |
| [`principle-laziness-protocol`](./principles/principle-laziness-protocol/SKILL.md) | 重构与评审时偏向删除和最小改动，别加抽象。（手动 /skill: 调用） |
| [`principle-make-operations-idempotent`](./principles/principle-make-operations-idempotent/SKILL.md) | 命令、生命周期步骤、重试循环重复执行后收敛到同一状态。（手动 /skill: 调用） |
| [`principle-migrate-callers-then-delete-legacy-apis`](./principles/principle-migrate-callers-then-delete-legacy-apis/SKILL.md) | 迁移调用方的同一波里删掉旧 API，不留兼容层。（手动 /skill: 调用） |
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
