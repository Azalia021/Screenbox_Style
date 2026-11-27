# Project Overview / 项目总览（双语文档）

[中文](#chinese) | [English](#english)

- 修改需求或项目文档时，在同一次变更中同步更新中英文，保持匹配的 ID、优先级、版本、数值和验收标准。  
  Update both languages in the same change, preserving matching IDs, priorities, versions, values, and acceptance criteria.
- 文件名使用英文，跨文档使用相对链接（参见 [README.md](../README.md) 与 [REQUIREMENTS_ISSUES_PROGRESS.md](./REQUIREMENTS_ISSUES_PROGRESS.md)）；翻译歧义须澄清，不默认以某种语言覆盖另一种。  
  Use English filenames and relative document links (see [README.md](../README.md) and [REQUIREMENTS_ISSUES_PROGRESS.md](./REQUIREMENTS_ISSUES_PROGRESS.md)). Resolve translation ambiguity explicitly; neither language silently overrides the other.

---

<a id="chinese"></a>

## 中文正文

### 基本信息

- **项目名称**：Screenbox_Style
- **文档版本**：1.0
- **更新日期**：2026-11-26
- **当前状态**：v1.0 已正式发布并持续维护（详见 [REQUIREMENTS_ISSUES_PROGRESS.md](./REQUIREMENTS_ISSUES_PROGRESS.md)）

### 项目目标

以 Windows 现代媒体播放器 [Screenbox](https://github.com/stinus-dev/Screenbox) 的 Fluent Design 视觉语言与 UI 布局为蓝本，结合原版 mpv 的 Lua OSC 脚本能力（参考 `mpvModernZ` 与 `ModernGlass`），打造一套视觉统一、轻量流畅、开箱即用的 mpv OSC（On-Screen Controller）主题。

### 仓库目录结构

```text
Screenbox_Style/
├── assets/                                 # 预览截图与展示素材目录
├── fonts/                                  # Inter UI 字体与许可证（Inter-Medium.ttf, Inter-SemiBold.ttf, Inter-LICENSE.txt）
├── script-opts/                            # 配置文件与多语言包（modernz.conf, modernz-locale.json）
├── scripts/                                # 核心 Lua 脚本（modernz.lua）
├── docs/                                   # 项目文档目录（中英双语）
│   ├── PROJECT_OVERVIEW.md                 # 项目总览文档（本文件）
│   └── REQUIREMENTS_ISSUES_PROGRESS.md     # 需求描述、问题和进度统一追踪文档
├── LICENSE                                 # GNU LGPL v2.1 开源许可证
└── README.md                               # 面向使用者的介绍与安装说明
```

> 说明：开发阶段引入的外部参考源码仓库（`Screenbox/`、`mpvModernZ-main/`、`ModernGlass-main/`）仅作为本地对照参考，不包含在发布仓库目录内。

### 参考项目与职责

| 参考项目 | 角色 | 主要参考内容 |
| :--- | :--- | :--- |
| `Screenbox` | 视觉与布局基准 | 顶栏/底栏 UI 布局、Fluent 配色与圆角规范、渐变遮罩比例、控件排布与交互反馈 |
| `mpvModernZ` | 核心架构参考 | mpv Lua OSC 状态管理、窗口置顶（Pin Window）、右键菜单触发与配置机制 |
| `ModernGlass` | 功能与视觉参考 | 文件夹播放列表（Folder Playlist）、半透明层次表现与字体图标映射 |

### 版本范围概要

- **v1.0（当前发布版）**：
  - 复刻 Screenbox 原版全宽顶栏（显示文件名、无边框/全屏三键）与底栏布局、线性渐变遮罩、不透明深色弹出菜单，以及顶栏/底栏同步淡入淡出。
  - 提供完整的基础播放控制、时间显示、静音与带实时百分比提示的音量滑块、底栏 Folder Playlist、独立的字幕/音频轨按钮、窗口置顶（Pin Window）、全屏按钮与 mpv 右键菜单（Context Menu）触发按钮。
- **v2.0（后续规划探索）**：
  - 评估播放列表按钮移至顶栏左侧的可行性；
  - 调研章节显示与切换、随机播放/循环播放按钮（及播完自动连播下一个媒体策略）、音频与字幕菜单合并，以及画中画（PiP）体验深化。

### 需求、问题与进度管理

本项目的所有**需求描述（v1.0 / v2.0 范围）**、**验收标准**、**问题记录**及**开发进度**均统一维护在以下独立双语文档中：

- 👉 **[REQUIREMENTS_ISSUES_PROGRESS.md](./REQUIREMENTS_ISSUES_PROGRESS.md)**

面向普通用户的安装步骤与推荐配置，请参阅根目录的 **[README.md](../README.md)**。  
后续任何需求变更、新发现的问题或开发进度更新，请在对应文档中同步维护中英文内容。

---

<a id="english"></a>

## English Text

### Overview

- **Project Name**: Screenbox_Style
- **Document Version**: 1.0
- **Last Updated**: 2026-11-26
- **Status**: v1.0 officially released and actively maintained (see [REQUIREMENTS_ISSUES_PROGRESS.md](./REQUIREMENTS_ISSUES_PROGRESS.md))

### Project Goal

Using the Fluent Design visual language and UI layout of the modern Windows media player [Screenbox](https://github.com/stinus-dev/Screenbox) as a blueprint, and drawing on vanilla mpv's Lua OSC scripting capabilities (referencing `mpvModernZ` and `ModernGlass`), this project builds a cohesive, lightweight, and out-of-the-box OSC (On-Screen Controller) theme for mpv.

### Repository Directory Structure

```text
Screenbox_Style/
├── assets/                                 # Screenshots & visual showcase assets
├── fonts/                                  # Inter UI fonts & license (Inter-Medium.ttf, Inter-SemiBold.ttf, Inter-LICENSE.txt)
├── script-opts/                            # Configs & locales (modernz.conf, modernz-locale.json)
├── scripts/                                # Core Lua script (modernz.lua)
├── docs/                                   # Project documentation (bilingual)
│   ├── PROJECT_OVERVIEW.md                 # Project overview documentation (this file)
│   └── REQUIREMENTS_ISSUES_PROGRESS.md     # Unified tracking document for requirements, issues, and progress
├── LICENSE                                 # GNU LGPL v2.1 License
└── README.md                               # User-facing introduction and installation guide
```

> Note: External reference source repositories (`Screenbox/`, `mpvModernZ-main/`, `ModernGlass-main/`) were used locally during development and are excluded from the release repository.

### Reference Projects & Roles

| Reference Project | Role | Primary Reference Scope |
| :--- | :--- | :--- |
| `Screenbox` | Visual & Layout Baseline | Top/bottom bar UI layout, Fluent color & corner radius rules, gradient scrim proportions, control arrangement, and feedback |
| `mpvModernZ` | Core Architecture Reference | mpv Lua OSC state management, Pin Window (always-on-top), context menu invocation, and config loading |
| `ModernGlass` | Feature & Visual Reference | Folder Playlist implementation, translucent layering, and icon font mapping |

### Release Scope Summary

- **v1.0 (Current Release)**:
  - Replicates Screenbox's full-width top bar (filename display and borderless/fullscreen caption controls) and bottom bar layout, linear gradient scrims, opaque dark popup menus, and synchronized top/bottom bar fade transitions.
  - Delivers core playback controls, time display, mute & volume slider with live drag percentage tooltip, Folder Playlist in the bottom bar, dedicated Subtitle and Audio track buttons, Pin Window, Fullscreen toggle, and mpv Context Menu trigger.
- **v2.0 (Planned Exploration)**:
  - Evaluate moving the playlist queue button to the top-left bar;
  - Investigate chapter display/switching, shuffle/loop controls (along with auto-advancing to the next media at EOF), merging audio & subtitle menus, and enhanced Picture-in-Picture (PiP) behavior.

### Requirements, Issues & Progress Management

All **Requirements Specifications (v1.0 / v2.0 scope)**, **Acceptance Criteria**, **Issues & Open Questions**, and **Development Progress** for this project are centrally maintained in the dedicated bilingual document below:

- 👉 **[REQUIREMENTS_ISSUES_PROGRESS.md](./REQUIREMENTS_ISSUES_PROGRESS.md)**

For end-user installation instructions and recommended `mpv.conf` settings, see **[README.md](../README.md)**.  
All future requirement updates, newly discovered issues, and progress milestones should be updated synchronously in both Chinese and English.
