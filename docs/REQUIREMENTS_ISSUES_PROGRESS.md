# Requirements, Issues & Progress / 需求描述、问题和进度（双语文档）

[中文](#chinese) | [English](#english)

- 修改需求、问题或进度时，在同一次变更中同步更新中英文，保持匹配的 ID、优先级、版本、数值和验收标准。  
  Update both languages in the same change, preserving matching IDs, priorities, versions, values, and acceptance criteria.
- 文件名使用英文，跨文档使用相对链接（参见 [README.md](../README.md) 与 [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md)）；翻译歧义须澄清，不默认以某种语言覆盖另一种。  
  Use English filenames and relative document links (see [README.md](../README.md) and [PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md)). Resolve translation ambiguity explicitly; neither language silently overrides the other.

---

<a id="chinese"></a>

## 中文正文

- 文档版本：1.0
- 更新日期：2026-11-23
- 当前状态：第一版（v1.0）核心开发与细节调优已完成，进入多日稳定性测试阶段（测试无误后正式定版）

---

### 1. 需求描述

#### 1.1 顶栏（Top Bar）

| ID | 目标版本 | 优先级 | 需求描述 | 状态 |
| :--- | :--- | :--- | :--- | :--- |
| `REQ-TOP-01` | 不做（N/A） | - | **顶栏最左侧返回主界面按钮**：原版 mpv 无主界面概念，直接不做。 | 已排除 |
| `REQ-TOP-02` | v1.0 | P1 | **播放列表队列功能**：做成文件夹播放列表（Folder Playlist，参考 `ModernGlass`）；由于该按钮可能无法放在顶栏左侧，第一版（v1.0）先放到底栏。 | 已完成 |

#### 1.2 底栏（Bottom Bar）

| ID | 目标版本 | 优先级 | 需求描述 | 状态 |
| :--- | :--- | :--- | :--- | :--- |
| `REQ-BOT-01` | v1.0 | P0 | **基础播放控制与时间显示**：播放/暂停键、上一个键、下一个键、时间显示，第一版实现。 | 已完成 |
| `REQ-BOT-02` | v2.0 | P2 | **章节显示和点击切换按钮**：暂不确定在 OSC 中的最佳实现方式，第一版先不做，第二版（v2.0）再考虑。 | 延后至 v2.0 |
| `REQ-BOT-03` | v1.0 | P0 | **音量控制**：底栏右侧静音按钮、音量滑条，第一版实现。 | 已完成 |
| `REQ-BOT-04` | v2.0 | P2 | **随机播放、重复（循环）按钮**：暂不确定实现方式，第一版先不做，第二版（v2.0）再考虑。 | 延后至 v2.0 |
| `REQ-BOT-05` | v1.0 / v2.0 | P0 | **音频和字幕按钮**：第一版（v1.0）拆分为独立的“字幕按钮”和“音频按钮”；第二版（v2.0）再考虑能否合并为一个按钮。 | v1.0 已完成 |
| `REQ-BOT-06` | v1.0 / v2.0 | P1 | **画中画（PiP）功能按钮**：第一版（v1.0）先做成 `mpvModernZ` 的窗口置顶（Pin Window）功能；第二版（v2.0）再考虑如何深化。 | v1.0 已完成 |
| `REQ-BOT-07` | v1.0 | P0 | **全屏按钮**：第一版实现。 | 已完成 |
| `REQ-BOT-08` | v1.0 | P1 | **设置按钮**：第一版（v1.0）做成触发新版 mpv 右键菜单（Context Menu）的功能，后续再考虑是否更改。 | 已完成 |

#### 1.3 其他 / 全局（Other / Global）

| ID | 目标版本 | 优先级 | 需求描述 | 状态 |
| :--- | :--- | :--- | :--- | :--- |
| `REQ-OTH-01` | v1.0 | P0 | **圆角窗口与文件名显示**：支持圆角窗口视觉，顶栏要能显示当前播放的文件名。 | 已完成 |
| `REQ-OTH-02` | v1.0 | P0 | **顶栏与底栏同步淡入淡出**：顶栏和底栏在出现与隐藏时同时执行淡入、淡出过渡。 | 已完成 |
| `REQ-OTH-03` | v1.0 | P0 | **模仿 Screenbox UI 布局**：参考 `Screenbox` 源码，采用不分离、不悬浮的全宽顶栏与底栏、Screenbox 原版线性渐变遮罩（无毛玻璃）、不透明弹出菜单，并还原原版 UI 大小、位置与比例。 | 已完成 |

---

### 2. 验收标准（v1.0）

- `AC-01`（布局与视觉）：整体 UI 布局模仿 `Screenbox` 源码（`REQ-OTH-03`），具备圆角窗口效果，顶栏正确显示文件名（`REQ-OTH-01`），且顶栏与底栏同步淡入淡出（`REQ-OTH-02`）。
- `AC-02`（v1.0 控件可用性）：底栏的播放/暂停、上一个、下一个、时间显示（`REQ-BOT-01`）、静音与音量滑条（`REQ-BOT-03`）、独立的字幕与音频按钮（`REQ-BOT-05`）、窗口置顶画中画按钮（`REQ-BOT-06`）、全屏按钮（`REQ-BOT-07`）、触发 mpv 右键菜单的设置按钮（`REQ-BOT-08`）以及置于底栏的 Folder Playlist 按钮（`REQ-TOP-02`）均能正常点击并生效。
- `AC-03`（范围控制）：顶栏左侧无返回主界面按钮（`REQ-TOP-01`）；章节切换（`REQ-BOT-02`）与随机/重复按钮（`REQ-BOT-04`）在 v1.0 中默认不启用或留待 v2.0。

---

### 3. 问题记录（Issues & Open Questions）

| ID | 关联需求 | 优先级 | 问题描述 | 状态 | 解决方案 / 备注 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ISS-01` | `REQ-TOP-02` | P1 | 播放列表队列按钮能否放入顶栏左侧，以及 Folder Playlist 的交互如何与 Screenbox 风格统一。 | 待评估 | v1.0 先放到底栏并参考 `ModernGlass` 实现，后续再评估顶栏位置。 |
| `ISS-02` | `REQ-BOT-02` | P2 | 章节显示和点击切换按钮在 mpv OSC 中的实现可行性与交互形式。 | 挂起（v2.0） | v1.0 暂不实现，v2.0 调研后决定。 |
| `ISS-03` | `REQ-BOT-04` | P2 | 随机播放（Shuffle）与重复播放（Loop）按钮在 mpv Lua 脚本中的状态同步与实现方式。 | 挂起（v2.0） | v1.0 暂不实现，v2.0 调研后决定。 |
| `ISS-04` | `REQ-BOT-05` | P2 | 音频轨与字幕轨选择能否在 mpv 中合并为单个弹出菜单按钮（如同 Screenbox 原版）。 | 挂起（v2.0） | v1.0 拆分为独立的音频按钮和字幕按钮，v2.0 探索合并弹窗方案。 |
| `ISS-05` | `REQ-BOT-06` | P2 | 画中画（PiP）按钮除窗口置顶（Pin Window）外，如何在 v2.0 进一步还原自动缩小悬浮窗体验。 | 挂起（v2.0） | v1.0 先按 `mpvModernZ` 的 Pin Window 实现。 |
| `ISS-06` | `REQ-OTH-01` | P0 | 底栏随机按钮图标向上错位至视频画面中部，且画面中出现内凹圆弧黑三角图形。 | 已修复 | `render_window_corners` 在空临时 `assdraw` 上调用 `new_event()` 后 `merge()` 缺少换行符，导致窗口圆角遮罩被拼接到最后一个底栏按钮的 ASS 事件中；已改为直接在 `master_ass` 上调用 `master_ass:new_event()` 独立绘制。 |
| `ISS-07` | `REQ-BOT-03` / `REQ-OTH-01` | P1 | 调节音量时，左上角 mpv 原生音量百分比 OSD 与顶栏标题重叠，且画面中下部会弹出横跨视频宽度的原生音量条。 | 已修复 | 在 `modernz.lua` 与 `modernz.conf` 中默认启用 `osd_margins=yes`（顶栏显示时自动将 `osd-margin-y` 下移避开顶栏标题），并新增 `hide_osd_bar=yes`（通过 `mp.set_property_bool("osd-bar", false)` 关闭横跨画面的原生 OSD 条，同时保留文字百分比提示）。 |
| `ISS-08` | `REQ-OTH-03` | P1 | 视频开始播放后，OSC 整体刷新率显著下降（锁在 24fps 等视频帧率），暂停时反而流畅。 | 已解决 | 确认为 mpv 默认渲染管线行为（`video-sync=audio` 下 VO 仅随视频帧提交画面与 OSD）；通过在 `mpv.conf` 中启用 `video-sync=display-resample`、`interpolation=yes` 与 `tscale=oversample`，使播放期间 OSC 按显示器原生刷新率流畅渲染，并已补充至 `README.md` 推荐配置。 |
| `ISS-09` | `REQ-OTH-03` | P1 | 顶栏与底栏半透明渐变遮罩在亮色/纯色视频画面（如蓝天）上出现明显的横向色阶断层（banding）。 | 已修复 | 原 `add_gradient_mask` 使用 24 个 `\blur0` 离散水平矩形条拼接渐变，每条高 3–5px 且透明度跳跃，导致横向条纹断层；已重构为单个带 ASS 高斯模糊（`\blur` + `\bord0`）的离屏扩展矩形（顶栏 `edge_depth=24, blur=60, opacity=0.72`；底栏 `edge_depth=52, blur=72, opacity=0.63`），由 libass 在输出分辨率逐像素平滑插值，同时将遮罩元素数从 48 个降至 2 个。 |
| `ISS-10` | `REQ-OTH-01` | P1 | 右上角关闭按钮悬停时右上角出现黑色圆角缺口，且曲率与 Windows 11 原生窗口圆角不一致。 | 已修复 | 关闭按钮本身已是直角（`hover_radius = 0`），该黑色圆角来自 `render_window_corners` 在所有控件之上绘制的软件黑色圆角遮罩（`window_corner_radius=10` 随 `playres` 缩放，与系统 DWM 圆角不重合）。已将 `window_rounded_corners` 默认改为 `false`/`no`（交由系统原生圆角裁切），并在 `render_window_corners` 中跳过顶栏关闭按钮可见时的右上角遮罩绘制。 |
| `ISS-11` | `REQ-OTH-01` / `REQ-BOT-03` | P1 | 启用 `sub_margins=yes` 与 `osd_margins=yes` 后，字幕偶尔在底栏淡出后仍高于底栏，且调节音量时左上角音量百分比偶尔未被下移、与顶栏标题重叠。 | 已解决 | 1) 先在 `modernz.lua` 中修复了 `sub-pos` 异步回显竞态（`pending_subpos_writes` 队列 + `sid` 守卫外移）及 `osd_margins` 淡入延迟/`osd_units_y` 计算；2) 出于保守与稳定性考量，最终在 `modernz.lua` 与 `modernz.conf` 中默认关闭动态避让（`sub_margins=no`、`osd_margins=no`），字幕不再被底栏顶高，同时新增静态配置 `osd_margin_y=60`，将左上角音量百分比等 OSD 文字永久固定在顶栏下方，彻底消除动态跳动与遮挡风险。 |

---

### 4. 进度追踪（Progress）

| ID | 日期 | 阶段 / 任务 | 状态 | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| `PRG-01` | 2026-11-22 | 项目初始化与参考源码准备 | 已完成 | 引入 `Screenbox`、`mpvModernZ-main`、`ModernGlass-main` 参考仓库。 |
| `PRG-02` | 2026-11-22 | v1.0 / v2.0 需求梳理与文档建档 | 已完成 | 明确顶栏、底栏与全局特性的 v1.0 范围及 v2.0 延后项，建立中英双语追踪文档。 |
| `PRG-03` | 2026-11-22 | Screenbox UI 布局拆解与 v1.0 原型开发 | 已完成 | 完成 `Screenbox_Style/` 下的 `modernz.lua`、`thumbz.lua`、`modernz.conf`、`thumbz.conf`、`modernz-locale.json` 与 `fonts/`，实现 `layout=screenbox`、`REQ-TOP-02`、`REQ-BOT-01/03/05/06/07/08`、`REQ-OTH-01/02/03`。 |
| `PRG-04` | 2026-11-22 | v1.0 测试验收与 v2.0 特性评估 | 已完成 | 对照 `AC-01` ~ `AC-03` 完成全部 v1.0 特性与配置项核对，保留 `ISS-01` ~ `ISS-05` 作为 v2.0 迭代评估项。 |
| `PRG-05` | 2026-11-22 | v1.0 视觉重构：复刻 Screenbox 原版非悬浮顶栏/底栏与不透明菜单 | 已完成 | 移除顶栏分体悬浮框、底栏悬浮卡片与毛玻璃模糊效果；按 `PlayerPage.xaml` / `PlayerControls.xaml` 复刻全宽 80px 顶栏（`#99000000 -> #33000000 -> #00000000` 渐变遮罩、20px 标题、46×32 贴边三键）与 104px 底栏（`#00000000 -> #99000000` 渐变遮罩、18px 边距进度条、40×40 按钮、140px 音量区），弹出菜单改为 `#2C2C2C` 不透明深色样式。 |
| `PRG-06` | 2026-11-22 | 修复窗口圆角遮罩导致底栏图标错位与画面黑三角异常（`ISS-06`） | 已完成 | 修复 `modernz.lua` 中 `render_window_corners` 的 ASS 事件换行缺失问题，改为直接向 `master_ass` 写入独立事件，并排查全文件所有 `:merge()` 调用确认无同类隐患。 |
| `PRG-07` | 2026-11-22 | 性能优化与音量 OSD 体验改进（`ISS-07`） | 已完成 | 1) 删除 `thumbz.lua`、`thumbz.conf` 及 `modernz.lua`/`modernz.conf` 中的进度条预览缩略图与 `thumbz` 通信逻辑；2) 移除按钮弹出菜单的展开/切换/关闭过渡动画（`menu_motion` 直接返回终态，`close_menu` 立即关闭）；3) 默认开启 `osd_margins=yes` 将左上角音量百分比下移至顶栏下方，并新增 `hide_osd_bar=yes` 隐藏横跨画面的原生音量条。 |
| `PRG-08` | 2026-11-22 | 新增底栏音量滑块拖动百分比气泡提示 | 已完成 | 在 `modernz.lua` 中为 `volumebar` 增加 `tooltipF` 与拖动状态追踪：鼠标按住并拖动音量滑块时，在滑块圆点正上方显示实时音量百分比（如 `0%`–`100%`）并严格跟随滑块水平移动，松开鼠标后自动隐藏。 |
| `PRG-09` | 2026-11-22 | 排查并解决播放期间 OSC 帧率锁定问题（`ISS-08`）并进入 v1.0 多日实测 | 进行中 | 通过 `mpv.conf` 启用 `video-sync=display-resample` + `interpolation=yes` + `tscale=oversample` 以及 `watch-later-options-remove=sub-pos/osd-margin-y`，验证界面在播放期间达到显示器原生高刷流畅度；现进入多日日常使用测试，无异常后正式宣布 v1.0 完工。 |
| `PRG-10` | 2026-11-23 | 优化顶栏与底栏半透明渐变遮罩色阶断层（`ISS-09`） | 已完成 | 将 `modernz.lua` 中的 `add_gradient_mask` 从 24 段 `\blur0` 离散条带改为单矩形 ASS `\blur` 高斯平滑渐变（复刻 Screenbox 原版顶栏/底栏透明度曲线），消除横向色阶断层并减少 ASS 渲染元素数量（48 → 2）。 |
| `PRG-11` | 2026-11-23 | 清理 `modernz.lua` 与 `modernz.conf` 历史冗余代码与素材 | 已完成 | 移除 7 套非 Screenbox 布局与旧版顶栏、95 个未使用的矢量图标（含全部 53 个 Material 图标）、毛玻璃 `GLASS_SHADER` 与模糊管线、`yt-dlp` 下载功能、图片浏览器模式、圣诞帽彩蛋以及移除菜单动画后的死代码，并同步精简 `modernz.conf` 中 23 项废弃配置；`modernz.lua` 从 7,797 行（478.9 KB）精简至 5,251 行（264.7 KB），减重 44.7%。 |
| `PRG-12` | 2026-11-23 | 去除右上角关闭按钮上与窗口圆角不一致的黑色圆角遮罩（`ISS-10`） | 已完成 | 将 `modernz.lua` 与 `modernz.conf` 中 `window_rounded_corners` 默认关闭（由 Windows 11 DWM 原生圆角自然裁切关闭键），并在 `render_window_corners` 中于关闭按钮可见时跳过右上角黑色圆角遮罩。 |
| `PRG-13` | 2026-11-23 | 修复动态边距缺陷并改为默认静态左上角 OSD 边距（`ISS-11`） | 已完成 | 修复 `sub_margins` 异步回显竞态与 `osd_margins` 淡入时序后，按保守策略将默认配置调整为 `sub_margins=no`、`osd_margins=no` 并新增 `osd_margin_y=60`（字幕不避让底栏，左上角音量百分比永久固定于顶栏下方）。 |

---

<a id="english"></a>

## English Text

- Document Version: 1.0
- Last Updated: 2026-11-23
- Current Status: v1.0 core development and polish completed; undergoing multi-day stability testing prior to final v1.0 sign-off

---

### 1. Requirements Specification

#### 1.1 Top Bar

| ID | Target Version | Priority | Description | Status |
| :--- | :--- | :--- | :--- | :--- |
| `REQ-TOP-01` | Out of Scope (N/A) | - | **Top-Left "Back to Home" Button**: Vanilla mpv does not have a home view concept; omitted completely. | Excluded |
| `REQ-TOP-02` | v1.0 | P1 | **Playlist Queue Feature**: Implemented as a Folder Playlist (referencing `ModernGlass`). Since placing this button on the top-left may not be feasible, place it in the bottom bar for v1.0. | Completed |

#### 1.2 Bottom Bar

| ID | Target Version | Priority | Description | Status |
| :--- | :--- | :--- | :--- | :--- |
| `REQ-BOT-01` | v1.0 | P0 | **Core Playback Controls & Time Display**: Play/Pause button, Previous button, Next button, and time display; implemented in v1.0. | Completed |
| `REQ-BOT-02` | v2.0 | P2 | **Chapter Display & Click-to-Switch Button**: Implementation approach TBD; omitted in v1.0 and deferred to v2.0. | Deferred to v2.0 |
| `REQ-BOT-03` | v1.0 | P0 | **Volume Controls**: Mute button and volume slider on the right side of the bottom bar; implemented in v1.0. | Completed |
| `REQ-BOT-04` | v2.0 | P2 | **Shuffle & Repeat Buttons**: Implementation approach TBD; omitted in v1.0 and deferred to v2.0. | Deferred to v2.0 |
| `REQ-BOT-05` | v1.0 / v2.0 | P0 | **Audio & Subtitle Buttons**: Split into separate Subtitle and Audio buttons in v1.0; merging into a single combined button will be considered in v2.0. | v1.0 Completed |
| `REQ-BOT-06` | v1.0 / v2.0 | P1 | **Picture-in-Picture (PiP) Button**: Implemented as a Pin Window (always-on-top) toggle like `mpvModernZ` in v1.0; further PiP refinement will be considered in v2.0. | v1.0 Completed |
| `REQ-BOT-07` | v1.0 | P0 | **Fullscreen Button**: Implemented in v1.0. | Completed |
| `REQ-BOT-08` | v1.0 | P1 | **Settings Button**: Triggers the new vanilla mpv right-click context menu in v1.0; future changes to be considered later. | Completed |

#### 1.3 Other / Global

| ID | Target Version | Priority | Description | Status |
| :--- | :--- | :--- | :--- | :--- |
| `REQ-OTH-01` | v1.0 | P0 | **Rounded Window & Filename Display**: Support rounded window corners and display the current media filename in the top bar. | Completed |
| `REQ-OTH-02` | v1.0 | P0 | **Synchronized Top & Bottom Bar Fade Transitions**: The top bar and bottom bar fade in and fade out simultaneously. | Completed |
| `REQ-OTH-03` | v1.0 | P0 | **Screenbox UI Layout Emulation**: Reference `Screenbox` source code with unified full-width non-floating top/bottom bars, authentic Screenbox linear gradient masks (no frosted glass), opaque flyout menus, and original Screenbox UI dimensions, placement, and proportions. | Completed |

---

### 2. Acceptance Criteria (v1.0)

- `AC-01` (Layout & Visuals): The overall UI layout emulates the `Screenbox` source code (`REQ-OTH-03`), features rounded window corners, displays the filename in the top bar (`REQ-OTH-01`), and fades the top and bottom bars in and out simultaneously (`REQ-OTH-02`).
- `AC-02` (v1.0 Control Functionality): Play/Pause, Previous, Next, and time display (`REQ-BOT-01`), Mute and volume slider (`REQ-BOT-03`), separate Subtitle and Audio buttons (`REQ-BOT-05`), Pin Window PiP button (`REQ-BOT-06`), Fullscreen button (`REQ-BOT-07`), Settings button triggering mpv's context menu (`REQ-BOT-08`), and the bottom-bar Folder Playlist button (`REQ-TOP-02`) all respond and function properly.
- `AC-03` (Scope Control): No "Back to Home" button exists on the top-left (`REQ-TOP-01`); chapter switching (`REQ-BOT-02`) and shuffle/repeat buttons (`REQ-BOT-04`) are excluded from v1.0 and reserved for v2.0.

---

### 3. Issues & Open Questions

| ID | Related Req | Priority | Issue Description | Status | Resolution / Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ISS-01` | `REQ-TOP-02` | P1 | Whether the playlist queue button can be placed on the top-left and how Folder Playlist interactions align with Screenbox's style. | To Evaluate | Place in the bottom bar for v1.0 referencing `ModernGlass`; evaluate top-bar placement later. |
| `ISS-02` | `REQ-BOT-02` | P2 | Feasibility and interaction design of chapter display and click-to-switch button in mpv OSC. | On Hold (v2.0) | Deferred from v1.0; evaluate in v2.0. |
| `ISS-03` | `REQ-BOT-04` | P2 | State synchronization and implementation of Shuffle and Repeat buttons in mpv Lua scripts. | On Hold (v2.0) | Deferred from v1.0; evaluate in v2.0. |
| `ISS-04` | `REQ-BOT-05` | P2 | Whether audio track and subtitle track selection can be merged into a single flyout menu button (as in Screenbox). | On Hold (v2.0) | Use separate Audio and Subtitle buttons in v1.0; explore combined menu in v2.0. |
| `ISS-05` | `REQ-BOT-06` | P2 | How to evolve the PiP button beyond Pin Window into an auto-shrinking floating PiP window in v2.0. | On Hold (v2.0) | Implement as Pin Window (`mpvModernZ` style) in v1.0. |
| `ISS-06` | `REQ-OTH-01` | P0 | A random bottom-bar button icon jumps upward onto the video frame, accompanied by a stray black concave-arc triangle in the middle of the video. | Fixed | `render_window_corners` called `new_event()` on an empty temporary `assdraw` before `merge()`, omitting a `\n` separator and concatenating the corner mask onto the last bottom-bar button's ASS event; fixed by calling `master_ass:new_event()` directly on `master_ass`. |
| `ISS-07` | `REQ-BOT-03` / `REQ-OTH-01` | P1 | When adjusting volume, mpv's top-left volume percentage OSD overlaps with the top-bar title, and mpv's wide horizontal native volume bar spans across the video frame. | Fixed | Enabled `osd_margins=yes` by default in `modernz.lua` and `modernz.conf` (shifting `osd-margin-y` downward below the top bar whenever it is visible), and added `hide_osd_bar=yes` (calling `mp.set_property_bool("osd-bar", false)` to hide the wide horizontal OSD bar while keeping text OSD messages). |
| `ISS-08` | `REQ-OTH-03` | P1 | Once video playback starts, the entire OSC drops to a low framerate (locked to the video's native framerate such as 24fps), while remaining smooth when paused. | Resolved | Confirmed as mpv's default VO rendering behavior (`video-sync=audio` presents frames and OSD only on video frame cadence); enabled `video-sync=display-resample`, `interpolation=yes`, and `tscale=oversample` in `mpv.conf` to render the OSC smoothly at the display's native refresh rate, and documented this recommendation in `README.md`. |
| `ISS-09` | `REQ-OTH-03` | P1 | Top and bottom bar translucent gradient masks show visible horizontal color-step banding over bright or uniform video scenes (such as a blue sky). | Fixed | The previous `add_gradient_mask` stacked 24 discrete `\blur0` horizontal strips (3–5px tall each with sharp alpha steps), causing visible banding; refactored to a single off-screen-padded ASS Gaussian-blurred box (`\blur` + `\bord0`, top: `edge_depth=24, blur=60, opacity=0.72`; bottom: `edge_depth=52, blur=72, opacity=0.63`) evaluated per-pixel by libass at native output resolution, eliminating banding while cutting mask elements from 48 to 2. |
| `ISS-10` | `REQ-OTH-01` | P1 | Hovering over the top-right close button reveals a black rounded cutout on its top-right corner whose curvature does not match the native Windows 11 rounded window corner. | Fixed | The close button itself already had sharp corners (`hover_radius = 0`); the black arc came from `render_window_corners` drawing a software ASS corner mask over all elements (`window_corner_radius=10` scales with `playres` and diverges from DWM's fixed-pixel radius). Disabled `window_rounded_corners` by default in `modernz.lua` and `modernz.conf` (letting Windows 11 DWM clip natively), and skipped the top-right cutout in `render_window_corners` whenever the close button is visible. |
| `ISS-11` | `REQ-OTH-01` / `REQ-BOT-03` | P1 | With `sub_margins=yes` and `osd_margins=yes`, subtitles occasionally remain elevated above the bottom bar after it fades out, and the top-left volume percentage OSD occasionally fails to shift below the top bar. | Resolved | 1) Fixed the `sub-pos` async echo race (`pending_subpos_writes` queue + moving restore outside the `sid` guard) and `osd_margins` fade-in timing / `osd_units_y` calculation in `modernz.lua`; 2) For maximum stability, disabled dynamic avoidance by default in `modernz.lua` and `modernz.conf` (`sub_margins=no`, `osd_margins=no`) so subtitles stay untouched, and added a static `osd_margin_y=60` option to keep top-left Volume% OSD permanently positioned below the top bar with zero dynamic jumping. |

---

### 4. Progress Tracking

| ID | Date | Phase / Task | Status | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `PRG-01` | 2026-11-22 | Project Initialization & Reference Code Setup | Completed | Added `Screenbox`, `mpvModernZ-main`, and `ModernGlass-main` reference repositories. |
| `PRG-02` | 2026-11-22 | v1.0 / v2.0 Requirement Scoping & Documentation | Completed | Defined v1.0 scope and v2.0 deferred items for top bar, bottom bar, and global features in bilingual tracking doc. |
| `PRG-03` | 2026-11-22 | Screenbox UI Layout Breakdown & v1.0 Prototype | Completed | Built `modernz.lua`, `thumbz.lua`, `modernz.conf`, `thumbz.conf`, `modernz-locale.json`, and `fonts/` under `Screenbox_Style/`, implementing `layout=screenbox`, `REQ-TOP-02`, `REQ-BOT-01/03/05/06/07/08`, and `REQ-OTH-01/02/03`. |
| `PRG-04` | 2026-11-22 | v1.0 Verification & v2.0 Feature Evaluation | Completed | Verified all v1.0 features and configs against `AC-01` – `AC-03`, retaining `ISS-01` – `ISS-05` for v2.0 evaluation. |
| `PRG-05` | 2026-11-22 | v1.0 Visual Revision: Faithful Non-Floating Screenbox Bars & Opaque Menus | Completed | Removed split floating top pills, floating bottom card, and frosted glass blur; replicated `PlayerPage.xaml` / `PlayerControls.xaml` with full-width 80px top bar (`#99000000 -> #33000000 -> #00000000` gradient mask, 20px title, 46×32 edge-flush caption buttons) and 104px bottom bar (`#00000000 -> #99000000` gradient mask, 18px-margin seekbar, 40×40 buttons, 140px volume group), with solid opaque `#2C2C2C` flyout menus. |
| `PRG-06` | 2026-11-22 | Fix Bottom-Bar Icon Displacement & Stray Corner Triangle Bug (`ISS-06`) | Completed | Fixed missing ASS event newline in `render_window_corners` inside `modernz.lua` by drawing directly onto `master_ass` after `master_ass:new_event()`, and audited all `:merge()` calls across the script. |
| `PRG-07` | 2026-11-22 | Performance Optimization & Volume OSD Improvements (`ISS-07`) | Completed | 1) Removed `thumbz.lua`, `thumbz.conf`, and all seekbar thumbnail preview / `thumbz` IPC code from `modernz.lua` and `modernz.conf`; 2) Removed flyout menu open/submenu/close transition animations (`menu_motion` returns final state immediately, `close_menu` closes immediately); 3) Enabled `osd_margins=yes` by default to shift top-left volume OSD below the top-bar title, and added `hide_osd_bar=yes` to hide mpv's wide horizontal native OSD bar. |
| `PRG-08` | 2026-11-22 | Add Volume Slider Drag Percentage Tooltip | Completed | Added `tooltipF` and drag-state tracking for `volumebar` in `modernz.lua`: while holding and dragging the bottom-bar volume slider, a live volume percentage tooltip (e.g. `0%`–`100%`) renders directly above the slider thumb and tracks its horizontal position, hiding immediately on release. |
| `PRG-09` | 2026-11-22 | Resolve Playback OSC Framerate Lock (`ISS-08`) & Begin v1.0 Multi-Day Testing | In Progress | Configured `video-sync=display-resample`, `interpolation=yes`, `tscale=oversample`, and `watch-later-options-remove=sub-pos/osd-margin-y` in `mpv.conf`; verified smooth display-refresh-rate UI during playback. Entering multi-day real-world testing prior to final v1.0 release sign-off. |
| `PRG-10` | 2026-11-23 | Fix Top & Bottom Bar Translucent Gradient Mask Banding (`ISS-09`) | Completed | Refactored `add_gradient_mask` in `modernz.lua` from 24 discrete `\blur0` strips to a single Gaussian-blurred ASS box per bar matching Screenbox's opacity curve, eliminating horizontal color banding and reducing ASS mask elements from 48 to 2. |
| `PRG-11` | 2026-11-23 | Prune Legacy Redundant Code, Assets & Configs | Completed | Removed 7 non-Screenbox layouts and legacy window controls, 95 unused vector icons (including all 53 Material icons), frosted-glass `GLASS_SHADER` and blur pipeline, `yt-dlp` download feature, image viewer mode, Santa hat easter egg, and post-PRG-07 menu animation dead code; pruned 23 obsolete options from `modernz.conf`. Reduced `modernz.lua` from 7,797 lines (478.9 KB) to 5,251 lines (264.7 KB, -44.7%). |
| `PRG-12` | 2026-11-23 | Remove Mismatched Black Corner Cutout Over Top-Right Close Button (`ISS-10`) | Completed | Disabled `window_rounded_corners` by default in `modernz.lua` and `modernz.conf` so native Windows 11 DWM rounded corners clip the close button cleanly, and skipped the top-right cutout in `render_window_corners` whenever top-bar window controls are visible. |
| `PRG-13` | 2026-11-23 | Fix Dynamic Margin Bugs & Switch to Static Top-Left OSD Margin (`ISS-11`) | Completed | After fixing the `sub_margins` async race and `osd_margins` fade-in timing, switched defaults conservatively to `sub_margins=no`, `osd_margins=no`, and added static `osd_margin_y=60` so subtitles remain untouched and top-left Volume% stays permanently below the top bar. |
