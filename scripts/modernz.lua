-- Screenbox_Style - A Fluent Design Screenbox-inspired OSC for mpv
-- Built upon ModernGlass (https://github.com/Demetter/ModernGlass) and
-- ModernZ v0.3.3 by Samillion (https://github.com/Samillion/ModernZ),
-- emulating the UI layout and visual language of Screenbox (https://github.com/stinus-dev/Screenbox).
--
-- This script is a derivative of the original mpv-osc-modern by maoiscat
-- and subsequent forks:
--   * cyl0/ModernX
--   * dexeonify/ModernX
--
-- It is based on the official osc.lua from mpv, licensed under the
-- GNU Lesser General Public License v2.1 (LGPLv2.1).
-- Full license: https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html

local assdraw = require "mp.assdraw"
local msg = require "mp.msg"
local opt = require "mp.options"
local utils = require "mp.utils"
mp.set_property("osc", "no")

-- Parameters
-- default user option values
-- do not touch, change them in modernz.conf
local user_opts = {
    -- Language and display
    language = "default",                  -- set language
    font = "Inter",                        -- UI font (Inter ships in the fonts folder)

    idlescreen = true,                     -- show mpv logo when idle
    window_top_bar = "yes",                -- show OSC window top bar: "auto", "yes", or "no" (borderless/fullscreen)
    showwindowed = true,                   -- show OSC when windowed
    showfullscreen = true,                 -- show OSC when fullscreen
    showonselect = false,                  -- show OSC when a select menu is open
    showonpause = true,                    -- show OSC when paused
    keeponpause = "both",                  -- keep OSC visible while paused: "no", "bottombar", "both"

    -- OSC behaviour and scaling
    hidetimeout = 1500,                    -- time (in ms) before OSC hides if no mouse movement
    keep_with_cursor = true,               -- keep OSC visible while cursor hovers over bottom or top bar
    fadeduration = 200,                    -- fade-out duration (in ms), set to 0 for no fade
    fadein = true,                         -- whether to enable fade-in effect
    minmousemove = 0,                      -- minimum mouse movement (in pixels) required to show OSC
    deadzonesize = 0.0,                    -- size of the deadzone (0.0 = whole screen shows OSC, 1.0 = only direct hover)
    deadzone_hide = "timeout",             -- hide behavior when cursor enters deadzone or leaves window: "instant" or "timeout"
    osc_on_seek = true,                    -- show OSC when seeking
    osc_on_start = "both",                 -- show OSC on start of every file ("no", "bottom", "top", "both")
    mouse_seek_pause = true,               -- pause video while seeking with mouse move (on button hold)
    force_seek_tooltip = false,            -- force show seekbar tooltip on mouse drag, even if not hovering seekbar

    vidscale = "auto",                     -- scale osc with the video
    scalewindowed = 1.0,                   -- osc scale factor when windowed
    scalefullscreen = 1.0,                 -- osc scale factor when fullscreen
    vidscale_max = 1.35,                   -- size cap when scaling with the window, in screen pixels per unit times the system display scaling, so the controls are the same size on every display; 0 = no limit

    -- Elements display
    show_title = true,                     -- show title in the OSC
    title = "${media-title}",              -- title: "${media-title}" or "${filename}"
    title_font_size = 20,                  -- title font size (20px SubtitleTextBlockStyle in Screenbox)
    truncate_title = true,                 -- truncate title with ellipsis if it overflows
    chapter_title_font_size = 14,          -- chapter title font size

    cache_info = false,                    -- show cached time information
    cache_info_speed = false,              -- show cache speed per second
    cache_info_font_size = 12,             -- font size of the cache information

    show_chapter_title = false,            -- show chapter title (v1.0 disabled by default, deferred to v2.0)
    chapter_above_title = false,           -- show chapter above title
    chapter_fmt = "%s",                    -- format for chapter display on seekbar hover (set to "no" to disable)

    timecurrent = true,                    -- show current time instead of remaining time
    timems = false,                        -- show timecodes with milliseconds
    unicodeminus = false,                  -- use the Unicode minus sign in remaining time
    time_format = "dynamic",               -- "dynamic" or "fixed". dynamic shows MM:SS when possible, fixed always shows HH:MM:SS
    time_font_size = 14,                   -- font size of the time display

    tooltip_font_size = 13,                -- tooltips font size
    speed_font_size = 15,                  -- speed button font size

    -- Title bar settings
    show_window_title = true,              -- show window title (filename) in top bar (REQ-OTH-01)
    window_title_font_size = 20,           -- window title font size (20px SubtitleTextBlockStyle in Screenbox)
    window_controls = true,                -- show window controls (close, minimize, maximize) in borderless/fullscreen
    windowcontrols_independent = false,    -- show window controls (top bar) and bottom bar synchronously (REQ-OTH-02)

    -- Subtitle and OSD display settings
    sub_margins = false,                   -- raise subtitles above the OSC when shown (disabled by default to avoid sub-pos shifts)
    osd_margins = false,                   -- dynamically shift OSD with top/bottom bar visibility (disabled by default; use static osd_margin_y instead)
    osd_margin_y = 60,                     -- static vertical OSD margin (in mpv 720p OSD units) to keep top-left Volume% permanently below the top bar (0 = keep mpv default)
    hide_osd_bar = true,                   -- hide mpv's built-in wide OSD bar (e.g. volume/seek bar) while keeping OSD text
    dynamic_margins = true,                -- update margins dynamically with OSC visibility

    -- Buttons display and functionality
    subtitles_button = true,               -- show the subtitles menu button (REQ-BOT-05)
    audio_tracks_button = true,            -- show the audio tracks menu button (REQ-BOT-05)
    jump_buttons = false,                  -- show the jump backward and forward buttons
    jump_amount = 10,                      -- change the jump amount in seconds
    jump_more_amount = 60,                 -- change the jump amount in seconds on right click
    jump_icon_number = true,               -- show different icon when jump_amount is set to 5, 10, or 30
    jump_mode = "relative",                -- seek mode for jump buttons: "relative" or "exact"
    jump_softrepeat = true,                -- enable continuous jumping when holding down seek buttons
    chapter_skip_buttons = false,          -- show the chapter skip backward and forward buttons
    track_nextprev_buttons = true,         -- show next/previous playlist track buttons (REQ-BOT-01)

    volume_control = true,                 -- show mute button and volume slider (REQ-BOT-03)
    volume_control_type = "linear",        -- volume scale type: "linear" or "logarithmic"
    volumebar_unmute_on_click = false,     -- unmute audio when adjusting volume slider with left click
    playlist_button = true,                -- show folder playlist button in bottom bar (REQ-TOP-02)
    hide_empty_playlist_button = false,    -- hide playlist button when no playlist exists
    gray_empty_playlist_button = false,    -- gray out the playlist button when no playlist exists

    fullscreen_button = true,              -- show fullscreen toggle button (REQ-BOT-07)
    info_button = true,                    -- show info button
    ontop_button = true,                   -- show window on top / PiP button (REQ-BOT-06)
    ontop_in_topbar = false,               -- move ontop button to top bar when ontop is active
    screenshot_button = true,              -- show screenshot button
    settings_button = true,                -- show settings / more button (REQ-BOT-08)

    loop_button = false,                   -- show file loop button (v1.0 disabled by default, deferred to v2.0 REQ-BOT-04)
    shuffle_button = false,                -- show shuffle button (v1.0 disabled by default, deferred to v2.0 REQ-BOT-04)
    speed_button = true,                   -- show speed control in menu

    buttons_always_active = "playlist_prev,playlist_next", -- force buttons to always be active like Screenbox

    playpause_size = 22,                   -- icon size for the play/pause button
    midbuttons_size = 20,                  -- icon size for the middle buttons
    sidebuttons_size = 20,                 -- icon size for the side buttons

    -- Colors and style (Fluent Design / Screenbox dark theme)
    osc_color = "#202020",                 -- accent color of the OSC and title bar
    window_title_color = "#FFFFFF",        -- color of the title in top bar
    window_controls_color = "#FFFFFF",     -- color of the window controls (close, minimize, maximize)
    windowcontrols_close_hover = "#C42B1C", -- Fluent red close hover
    windowcontrols_max_hover = "#FFFFFF",  -- Fluent subtle hover for maximize
    windowcontrols_min_hover = "#FFFFFF",  -- Fluent subtle hover for minimize
    title_color = "#FFFFFF",               -- color of the title
    cache_info_color = "#FFFFFF",          -- color of the cache information
    seekbar_cache_color = "#888888",       -- color of the cache ranges on the seekbar
    seekbarfg_color = "#60CDFF",           -- Fluent WinUI 3 dark theme accent light2 (#60CDFF)
    seekbarbg_color = "#FFFFFF",           -- color of the remaining seekbar
    seek_handle_color = "#60CDFF",         -- Fluent slider thumb inner accent color
    seek_handle_border_color = "#454545",  -- Fluent slider outer thumb ring color
    volumebar_match_seek_color = true,     -- match volume bar color with seekbar accent color like Screenbox
    time_color = "#FFFFFF",                -- color of the timestamps (below seekbar)
    chapter_title_color = "#CCCCCC",       -- color of the chapter title
    side_buttons_color = "#FFFFFF",        -- color of the side buttons (audio, subtitles, playlist, etc.)
    middle_buttons_color = "#FFFFFF",      -- color of the middle buttons (skip, jump, chapter, etc.)
    playpause_color = "#FFFFFF",           -- color of the play/pause button
    held_element_color = "#CCCCCC",        -- color of the element when held down (pressed)
    hover_effect_color = "#FFFFFF",        -- color of a hovered button when hover_effect includes "color" (and of the "box" highlight)
    nibble_color = "#60CDFF",              -- color of chapter nibbles on the seekbar
    nibble_current_color = "#FFFFFF",      -- color of the current chapter nibble on the seekbar
    ab_loop_color = "#60CDFF",             -- color of the A/B loop range on the seekbar

    -- Button interaction settings
    hover_effect = "box",                  -- active button hover effects: "glow", "size", "color", "box"; can use multiple separated by commas
    button_hover_size = 108,               -- relative size of a hovered button if "size" effect is active
    button_held_size = 95,                 -- relative size of a button when held/pressed. below 100 shrinks button when held down
    button_held_box_alpha = 12,            -- alpha of the hover background box when a button is held down
    button_glow_amount = 5,                -- glow intensity when "glow" hover effect is active
    slider_hover_size = 110,               -- relative size of a hovered slider handle
    tooltip_hints = true,                  -- enable tooltips for most buttons. seek and volume tooltips are always enabled

    -- Progress bar settings
    seek_handle_size = 0.85,               -- size ratio of the seek handle (range: 0 ~ 1)
    seek_handle_border_size = 0.35,        -- border thickness as a fraction of the handle radius
    seek_handle_border_hover_size = 0.25,  -- border thickness when handle is hovered (set equal to seek_handle_border_size to disable)
    seekbar_height = "medium",             -- seekbar height preset: "small", "medium", "large", "xlarge"
    seekrange = true,                      -- show seek range overlay
    seekrangealpha = 150,                  -- transparency of the seek range
    livemarkers = true,                    -- update chapter markers on the seekbar when duration changes
    seekbarkeyframes = true,               -- use keyframes when dragging the seekbar
    slider_rounded_corners = true,         -- rounded corners seekbar slider

    nibbles_style = "gap",                 -- chapter nibble style: "gap", "triangle", "bar", or "single-bar"
    nibbles_top = true,                    -- top chapter nibbles above seekbar
    nibbles_bottom = true,                 -- bottom chapter nibbles below seekbar

    automatickeyframemode = true,          -- automatically set keyframes for the seekbar based on video length
    automatickeyframelimit = 600,          -- videos longer than this (in seconds) will have keyframes on the seekbar

    persistent_progress = false,           -- always show a small progress line at the bottom of the screen
    persistent_progress_height = 17,       -- height of the persistent progress bar
    persistent_buffer = false,             -- show cached buffer status in the persistent progress line

    -- Miscellaneous settings
    visibility = "auto",                   -- only used at init to set visibility_mode(...)
    visibility_modes = "never_auto_always",-- visibility modes to cycle through
    tick_delay = 1 / 60,                   -- minimum interval between OSC redraws (in seconds)
    tick_delay_follow_display_fps = true, -- use display FPS as the minimum redraw interval

    -- Elements Position
    -- Useful when adjusting font size or type
    title_offset = 20,                     -- title vertical offset relative to seekbar
    title_with_chapter_offset = 5,         -- title vertical offset if a chapter title is below it
    chapter_title_offset = 18,             -- chapter title vertical offset relative to seekbar
    chapter_above_title_offset = 3,        -- chapter offset when shown above title
    time_codes_offset = 0,                 -- time codes vertical offset relative to seekbar
    tooltip_height_offset = 5,             -- tooltip height position offset
    portrait_window_trigger = 950,         -- portrait window width trigger to move some elements
    hide_volume_bar_trigger = 720,         -- hide volume bar trigger window width (720px matches Screenbox AdaptiveControlStates)
    osc_height = 104,                      -- osc height (104px matches Screenbox PlayerControls)

    -- Window & popup menu look (Screenbox non-floating bars + opaque dark flyout menus)
    window_rounded_corners = false,        -- software rounded-corner ASS mask (disabled by default; Windows 11 DWM rounds corners natively)
    window_corner_radius = 10,             -- corner radius of the window in layout units
    glass_color = "#2C2C2C",               -- solid dark flyout color (#2C2C2C BackgroundAcrylicTintFallbackColor in Screenbox)
    glass_opacity = 100,                   -- surface opacity in percent (100 = opaque flyout menus)
    glass_border_opacity = 10,             -- opacity of the hairline light edge around menus in percent
    glass_shadow = true,                   -- soft shadow under popup menus
    muted_text_color = "#C5C5C5",          -- secondary text: duration, chapter title, menu details (TextFillColorSecondary)
    modern_menus = true,                   -- show track, playlist, chapter and audio output lists as ModernZ menus instead of mpv's select lists
    menu_max_items = 9,                    -- rows a menu shows before it scrolls

    -- Mouse commands
    -- customize the button function based on mouse action

    -- title mouse actions
    title_mbtn_left_command = "script-binding stats/display-page-5",
    title_mbtn_mid_command = "show-text ${path}",
    title_mbtn_right_command = "script-binding select/select-watch-history",

    -- chapter title mouse actions
    chapter_title_mbtn_left_command = "script-binding select/select-chapter",
    chapter_title_mbtn_right_command = "show-text ${chapter-list} 3000",

    -- seekbar wheel actions
    seekbar_wheel_up_command = "seek 10",
    seekbar_wheel_down_command = "seek -10",

    -- playlist button mouse actions (REQ-TOP-02: Folder Playlist)
    playlist_mbtn_left_command = "script-binding select/select-playlist",
    playlist_mbtn_right_command = "script-binding select/menu",

    -- volume mouse actions (REQ-BOT-03)
    vol_ctrl_mbtn_left_command = "no-osd cycle mute",
    vol_ctrl_mbtn_right_command = "script-binding select/select-audio-device",
    vol_ctrl_wheel_down_command = "osd-msg add volume -5",
    vol_ctrl_wheel_up_command = "osd-msg add volume 5",
    volumebar_wheel_down_command = "osd-msg add volume -5",
    volumebar_wheel_up_command = "osd-msg add volume 5",

    -- audio button mouse actions (REQ-BOT-05)
    audio_track_mbtn_left_command = "script-binding select/select-aid",
    audio_track_mbtn_mid_command = "cycle audio down",
    audio_track_mbtn_right_command = "cycle audio",
    audio_track_wheel_down_command = "cycle audio",
    audio_track_wheel_up_command = "cycle audio down",

    -- subtitle button mouse actions (REQ-BOT-05)
    sub_track_mbtn_left_command = "script-binding select/select-sid",
    sub_track_mbtn_mid_command = "cycle sub down",
    sub_track_mbtn_right_command = "cycle sub",
    sub_track_wheel_down_command = "cycle sub",
    sub_track_wheel_up_command = "cycle sub down",

    -- play/pause button mouse actions (REQ-BOT-01)
    play_pause_mbtn_left_command = "cycle pause",
    play_pause_mbtn_mid_command = "cycle-values loop-playlist inf no",
    play_pause_mbtn_right_command = "cycle-values loop-file inf no",

    -- chapter skip buttons mouse actions
    chapter_prev_mbtn_left_command = "add chapter -1",
    chapter_prev_mbtn_mid_command = "show-text ${chapter-list} 3000",
    chapter_prev_mbtn_right_command = "script-binding select/select-chapter",

    chapter_next_mbtn_left_command = "add chapter 1",
    chapter_next_mbtn_mid_command = "show-text ${chapter-list} 3000",
    chapter_next_mbtn_right_command = "script-binding select/select-chapter",

    -- playlist skip buttons mouse actions (REQ-BOT-01)
    playlist_prev_mbtn_left_command = "playlist-prev",
    playlist_prev_mbtn_mid_command = "show-text ${playlist} 3000",
    playlist_prev_mbtn_right_command = "script-binding select/select-playlist",

    playlist_next_mbtn_left_command = "playlist-next",
    playlist_next_mbtn_mid_command = "show-text ${playlist} 3000",
    playlist_next_mbtn_right_command = "script-binding select/select-playlist",

    -- fullscreen button mouse actions (REQ-BOT-07)
    fullscreen_mbtn_left_command = "cycle fullscreen",
    fullscreen_mbtn_right_command = "cycle window-maximized",

    -- info button mouse actions
    info_mbtn_left_command = "script-binding stats/display-page-1-toggle",

    -- ontop (pin / PiP) button mouse actions (REQ-BOT-06)
    ontop_mbtn_left_command = "osd-msg cycle ontop",

    -- screenshot button mouse actions
    screenshot_mbtn_left_command = "osd-msg screenshot video",

    -- loop file button mouse actions
    file_loop_mbtn_left_command = "osd-msg cycle-values loop-file inf no",
    file_loop_mbtn_right_command = "osd-msg cycle-values loop-playlist inf no",

    -- speed button mouse actions
    speed_mbtn_left_command = "osd-msg add speed 1",
    speed_mbtn_right_command = "osd-msg set speed 1",
    speed_wheel_down_command = "osd-msg add speed -0.25",
    speed_wheel_up_command = "osd-msg add speed 0.25",

    -- settings (more) button mouse actions (REQ-BOT-08: triggers mpv context menu)
    more_mbtn_left_command = "context-menu",
    more_mbtn_right_command = "script-binding select/context-menu",
}

local osc_param = {                  -- calculated by osc_init()
    playresy = 0,                    -- canvas size Y
    playresx = 0,                    -- canvas size X
    display_aspect = 1,
    unscaled_y = 0,
    osd_units_y = nil,               -- canvas height in mpv OSD units (for osd-margin-y)
    areas = {},
    video_margins = {
        l = 0, r = 0, t = 0, b = 0,  -- left/right/top/bottom
    },
}

-- icon outlines: Fluent UI System Icons (MIT) and Material Symbols (Apache-2.0),
-- converted from ModernZ's icon sources to ASS drawings on a 24x24 grid
local icon_glyphs = {
    ["fluent_arrow_maximize"] = "m 19.25 4 b 19.66 4 20 4.34 20 4.75 l 20 12.25 b 20 12.66 19.66 13 19.25 13 18.84 13 18.5 12.66 18.5 12.25 l 18.5 6.56 6.56 18.5 12.25 18.5 b 12.66 18.5 13 18.84 13 19.25 13 19.66 12.66 20 12.25 20 l 4.75 20 b 4.34 20 4 19.66 4 19.25 l 4 11.75 b 4 11.34 4.34 11 4.75 11 5.16 11 5.5 11.34 5.5 11.75 l 5.5 17.44 17.44 5.5 11.75 5.5 b 11.34 5.5 11 5.16 11 4.75 11 4.34 11.34 4 11.75 4 l 19.25 4",
    ["fluent_arrow_minimize"] = "m 10.25 13 b 10.66 13 11 13.34 11 13.75 l 11 21.25 b 11 21.66 10.66 22 10.25 22 9.84 22 9.5 21.66 9.5 21.25 l 9.5 15.56 3.28 21.78 b 2.99 22.07 2.51 22.07 2.22 21.78 1.93 21.49 1.93 21.01 2.22 20.72 l 8.44 14.5 2.75 14.5 b 2.34 14.5 2 14.16 2 13.75 2 13.34 2.34 13 2.75 13 l 10.25 13 m 20.72 2.22 b 21.01 1.93 21.49 1.93 21.78 2.22 22.07 2.51 22.07 2.99 21.78 3.28 l 15.56 9.5 21.25 9.5 b 21.66 9.5 22 9.84 22 10.25 22 10.66 21.66 11 21.25 11 l 13.75 11 b 13.34 11 13 10.66 13 10.25 l 13 2.75 b 13 2.34 13.34 2 13.75 2 14.16 2 14.5 2.34 14.5 2.75 l 14.5 8.44 20.72 2.22",
    ["fluent_arrow_repeat_all"] = "m 14.61 2.47 l 14.53 2.4 b 14.24 2.18 13.82 2.2 13.55 2.47 l 13.48 2.55 b 13.26 2.84 13.28 3.27 13.55 3.53 l 15.52 5.51 8.5 5.51 8.27 5.52 b 4.79 5.64 2 8.51 2 12.04 2 13.73 2.64 15.27 3.69 16.43 l 3.76 16.49 b 3.89 16.61 4.06 16.67 4.25 16.67 4.66 16.67 5 16.34 5 15.92 5 15.75 4.94 15.59 4.84 15.46 l 4.64 15.23 b 3.93 14.36 3.5 13.25 3.5 12.04 3.5 9.26 5.74 7.02 8.5 7.02 l 15.38 7.02 13.55 8.86 13.48 8.93 b 13.26 9.23 13.28 9.65 13.55 9.92 13.84 10.22 14.32 10.22 14.61 9.92 l 17.79 6.73 17.86 6.65 b 18.08 6.36 18.06 5.93 17.79 5.66 l 14.61 2.47 m 20.23 7.57 b 20.1 7.46 19.93 7.4 19.75 7.4 19.34 7.4 19 7.73 19 8.15 19 8.34 19.07 8.51 19.18 8.64 20 9.53 20.5 10.72 20.5 12.04 20.5 14.81 18.26 17.05 15.5 17.05 l 8.56 17.05 10.46 15.14 10.54 15.06 b 10.73 14.79 10.73 14.42 10.53 14.15 l 10.46 14.08 10.38 14 b 10.11 13.81 9.74 13.81 9.48 14.01 l 9.4 14.08 6.22 17.27 6.15 17.36 b 5.95 17.62 5.95 17.99 6.15 18.26 l 6.22 18.34 9.4 21.53 9.49 21.6 b 9.78 21.82 10.2 21.8 10.46 21.53 10.73 21.26 10.75 20.84 10.53 20.54 l 10.46 20.46 8.56 18.56 15.5 18.56 15.73 18.55 b 19.21 18.43 22 15.56 22 12.04 22 10.34 21.36 8.8 20.3 7.64 l 20.23 7.57",
    ["fluent_arrow_repeat_all_off"] = "m 3.2 2.15 l 3.28 2.22 21.78 20.72 b 22.07 21.01 22.07 21.49 21.78 21.78 21.51 22.05 21.1 22.07 20.8 21.85 l 20.72 21.78 17.21 18.27 b 16.77 18.39 16.32 18.47 15.85 18.49 l 15.5 18.5 8.56 18.5 10.46 20.4 10.53 20.48 b 10.75 20.77 10.73 21.19 10.46 21.46 10.2 21.73 9.78 21.75 9.49 21.53 l 9.4 21.46 6.22 18.28 6.15 18.2 b 5.95 17.94 5.95 17.57 6.15 17.3 l 6.22 17.22 9.4 14.04 9.48 13.97 b 9.74 13.77 10.11 13.76 10.38 13.96 l 10.46 14.04 10.53 14.11 b 10.73 14.38 10.73 14.74 10.54 15.01 l 10.46 15.1 8.56 17 15.5 17 b 15.64 17 15.78 16.99 15.92 16.98 l 6.4 7.46 b 4.69 8.25 3.5 9.99 3.5 12 3.5 13.3 3.99 14.48 4.8 15.37 4.92 15.5 5 15.68 5 15.87 5 16.29 4.66 16.62 4.25 16.62 4.03 16.62 3.83 16.53 3.69 16.37 2.64 15.22 2 13.68 2 12 2 9.58 3.32 7.47 5.29 6.35 l 2.22 3.28 b 1.93 2.99 1.93 2.51 2.22 2.22 2.49 1.95 2.9 1.93 3.2 2.15 m 19.75 7.38 b 19.97 7.38 20.17 7.47 20.3 7.62 21.36 8.78 22 10.31 22 12 22 14.06 21.04 15.89 19.55 17.08 l 18.49 16.01 b 19.71 15.1 20.5 13.64 20.5 12 20.5 10.69 20 9.5 19.18 8.61 19.07 8.48 19 8.31 19 8.13 19 7.71 19.34 7.38 19.75 7.38 m 14.53 2.4 l 14.61 2.47 17.79 5.65 b 18.06 5.92 18.08 6.34 17.86 6.64 l 17.79 6.71 14.61 9.89 b 14.32 10.19 13.84 10.19 13.55 9.89 13.28 9.63 13.26 9.2 13.48 8.91 l 13.55 8.83 15.38 7 9.47 7 7.99 5.52 b 8.08 5.51 8.18 5.51 8.27 5.5 l 8.5 5.5 15.52 5.5 13.55 3.53 b 13.28 3.26 13.26 2.84 13.48 2.55 l 13.55 2.47 b 13.82 2.2 14.24 2.18 14.53 2.4",
    ["fluent_arrow_shuffle"] = "m 19.28 4.72 b 18.99 4.43 18.51 4.43 18.22 4.72 17.93 5.01 17.93 5.49 18.22 5.78 l 19.44 7 19.25 7 b 15.33 7 12.83 9.3 10.56 11.39 l 10.49 11.45 b 8.15 13.6 6.04 15.5 2.75 15.5 2.34 15.5 2 15.84 2 16.25 2 16.66 2.34 17 2.75 17 6.67 17 9.17 14.7 11.44 12.61 l 11.51 12.55 b 13.85 10.4 15.96 8.5 19.25 8.5 l 19.44 8.5 18.22 9.72 b 17.93 10.01 17.93 10.49 18.22 10.78 18.51 11.07 18.99 11.07 19.28 10.78 l 21.78 8.28 b 21.92 8.14 22 7.95 22 7.75 22 7.55 21.92 7.36 21.78 7.22 l 19.28 4.72 m 2.75 7 b 6 7 8.27 8.58 10.25 10.31 10.15 10.4 10.05 10.5 9.95 10.59 l 9.82 10.71 b 9.58 10.92 9.36 11.13 9.14 11.33 7.28 9.73 5.4 8.5 2.75 8.5 2.34 8.5 2 8.16 2 7.75 2 7.34 2.34 7 2.75 7 m 19.25 17 b 16 17 13.73 15.42 11.75 13.69 11.85 13.6 11.95 13.5 12.05 13.41 l 12.05 13.41 12.18 13.29 b 12.42 13.08 12.64 12.87 12.86 12.67 14.72 14.27 16.6 15.5 19.25 15.5 l 19.44 15.5 18.22 14.28 b 17.93 13.99 17.93 13.51 18.22 13.22 18.51 12.93 18.99 12.93 19.28 13.22 l 21.78 15.72 b 21.92 15.86 22 16.05 22 16.25 22 16.45 21.92 16.64 21.78 16.78 l 19.28 19.28 b 18.99 19.57 18.51 19.57 18.22 19.28 17.93 18.99 17.93 18.51 18.22 18.22 l 19.44 17 19.25 17",
    ["fluent_arrow_shuffle_off"] = "m 3.28 2.22 b 2.99 1.93 2.51 1.93 2.22 2.22 1.93 2.51 1.93 2.99 2.22 3.28 l 6.92 7.98 b 5.71 7.38 4.35 7 2.75 7 2.34 7 2 7.34 2 7.75 2 8.16 2.34 8.5 2.75 8.5 5.4 8.5 7.28 9.73 9.14 11.33 9.33 11.16 9.53 10.98 9.73 10.79 l 10.44 11.5 b 8.12 13.63 6.02 15.5 2.75 15.5 2.34 15.5 2 15.84 2 16.25 2 16.66 2.34 17 2.75 17 6.67 17 9.17 14.7 11.44 12.61 l 11.5 12.56 12.21 13.27 b 12.2 13.27 12.19 13.28 12.18 13.29 l 12.05 13.41 b 11.95 13.5 11.85 13.6 11.75 13.69 12.69 14.51 13.69 15.3 14.84 15.9 l 20.72 21.78 b 21.01 22.07 21.49 22.07 21.78 21.78 22.07 21.49 22.07 21.01 21.78 20.72 l 3.28 2.22 m 18.66 15.48 l 20.87 17.69 21.78 16.78 b 21.92 16.64 22 16.45 22 16.25 22 16.05 21.92 15.86 21.78 15.72 l 19.28 13.22 b 18.99 12.93 18.51 12.93 18.22 13.22 17.93 13.51 17.93 13.99 18.22 14.28 l 19.44 15.5 19.25 15.5 b 19.05 15.5 18.85 15.49 18.66 15.48 m 12.7 9.52 l 13.77 10.59 b 15.35 9.37 17.03 8.5 19.25 8.5 l 19.44 8.5 18.22 9.72 b 17.93 10.01 17.93 10.49 18.22 10.78 18.51 11.07 18.99 11.07 19.28 10.78 l 21.78 8.28 b 21.92 8.14 22 7.95 22 7.75 22 7.55 21.92 7.36 21.78 7.22 l 19.28 4.72 b 18.99 4.43 18.51 4.43 18.22 4.72 17.93 5.01 17.93 5.49 18.22 5.78 l 19.44 7 19.25 7 b 16.51 7 14.46 8.13 12.7 9.52",
    ["fluent_audio"] = "m 2 7.25 b 2 5.46 3.46 4 5.25 4 l 18.75 4 b 20.54 4 22 5.46 22 7.25 l 22 16.75 b 22 18.54 20.54 20 18.75 20 l 5.25 20 b 3.46 20 2 18.54 2 16.75 l 2 7.25 m 5.25 5.5 b 4.28 5.5 3.5 6.28 3.5 7.25 l 3.5 16.75 b 3.5 17.72 4.28 18.5 5.25 18.5 l 18.75 18.5 b 19.72 18.5 20.5 17.72 20.5 16.75 l 20.5 7.25 b 20.5 6.28 19.72 5.5 18.75 5.5 l 5.25 5.5 m 5 13.25 l 5 10.75 b 5 10.34 5.34 10 5.75 10 6.16 10 6.5 10.34 6.5 10.75 l 6.5 13.25 b 6.5 13.66 6.16 14 5.75 14 5.34 14 5 13.66 5 13.25 m 8.12 14.75 l 8.12 9.25 b 8.12 8.84 8.46 8.5 8.88 8.5 9.29 8.5 9.62 8.84 9.62 9.25 l 9.62 14.75 b 9.62 15.16 9.29 15.5 8.88 15.5 8.46 15.5 8.12 15.16 8.12 14.75 m 11.25 16.75 l 11.25 7.25 b 11.25 6.84 11.59 6.5 12 6.5 12.41 6.5 12.75 6.84 12.75 7.25 l 12.75 16.75 b 12.75 17.16 12.41 17.5 12 17.5 11.59 17.5 11.25 17.16 11.25 16.75 m 14.38 14.25 l 14.38 9.75 b 14.38 9.34 14.71 9 15.12 9 15.54 9 15.88 9.34 15.88 9.75 l 15.88 14.25 b 15.88 14.66 15.54 15 15.12 15 14.71 15 14.38 14.66 14.38 14.25 m 17.5 13 l 17.5 11 b 17.5 10.59 17.84 10.25 18.25 10.25 18.66 10.25 19 10.59 19 11 l 19 13 b 19 13.41 18.66 13.75 18.25 13.75 17.84 13.75 17.5 13.41 17.5 13",
    ["fluent_camera"] = "m 13.92 2.5 b 14.72 2.5 15.46 2.93 15.86 3.61 l 16.68 5 18.75 5 b 20.54 5 22 6.46 22 8.25 l 22 17.75 b 22 19.55 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.55 2 17.75 l 2 8.25 b 2 6.46 3.46 5 5.25 5 l 7.33 5 8.21 3.58 b 8.61 2.91 9.34 2.5 10.12 2.5 l 13.92 2.5 m 13.92 4 l 10.12 4 b 9.9 4 9.69 4.1 9.55 4.27 l 9.48 4.36 8.39 6.14 b 8.25 6.37 8.01 6.5 7.75 6.5 l 5.25 6.5 b 4.28 6.5 3.5 7.28 3.5 8.25 l 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.72 19.5 20.5 18.72 20.5 17.75 l 20.5 8.25 b 20.5 7.28 19.72 6.5 18.75 6.5 l 16.25 6.5 b 15.98 6.5 15.74 6.36 15.6 6.13 l 14.57 4.37 b 14.44 4.14 14.19 4 13.92 4 m 12 8 b 14.49 8 16.5 10.02 16.5 12.5 16.5 14.99 14.49 17 12 17 9.51 17 7.5 14.99 7.5 12.5 7.5 10.02 9.51 8 12 8 m 12 9.5 b 10.34 9.5 9 10.84 9 12.5 9 14.16 10.34 15.5 12 15.5 13.66 15.5 15 14.16 15 12.5 15 10.84 13.66 9.5 12 9.5",
    ["fluent_fast_forward_filled"] = "m 13.97 4.36 b 13 3.53 11.5 4.23 11.5 5.5 l 11.5 9.49 5.47 4.36 b 4.5 3.53 3 4.23 3 5.51 l 3 18.5 b 3 19.38 3.71 19.98 4.46 20 l 4.55 20 b 4.87 19.99 5.19 19.88 5.47 19.64 l 11.5 14.51 11.5 18.5 b 11.5 19.78 13 20.47 13.97 19.64 l 21.38 13.33 b 22.2 12.64 22.2 11.37 21.38 10.67 l 13.97 4.36",
    ["fluent_info"] = "m 12 2 b 17.53 2 22 6.48 22 12 22 17.52 17.53 22 12 22 6.48 22 2 17.52 2 12 2 6.48 6.48 2 12 2 m 12 3.5 b 7.31 3.5 3.5 7.31 3.5 12 3.5 16.7 7.31 20.5 12 20.5 16.7 20.5 20.5 16.7 20.5 12 20.5 7.31 16.7 3.5 12 3.5 m 12 10.5 b 12.41 10.5 12.75 10.84 12.75 11.25 l 12.75 16.25 b 12.75 16.66 12.41 17 12 17 11.59 17 11.25 16.66 11.25 16.25 l 11.25 11.25 b 11.25 10.84 11.59 10.5 12 10.5 m 12 9 b 12.55 9 13 8.55 13 8 13 7.45 12.55 7 12 7 11.45 7 11 7.45 11 8 11 8.55 11.45 9 12 9",
    ["fluent_more_vertical"] = "m 12 7.75 b 11.03 7.75 10.25 6.97 10.25 6 10.25 5.03 11.03 4.25 12 4.25 12.97 4.25 13.75 5.03 13.75 6 13.75 6.97 12.97 7.75 12 7.75 m 12 13.75 b 11.03 13.75 10.25 12.97 10.25 12 10.25 11.03 11.03 10.25 12 10.25 12.97 10.25 13.75 11.03 13.75 12 13.75 12.97 12.97 13.75 12 13.75 m 10.25 18 b 10.25 18.97 11.03 19.75 12 19.75 12.97 19.75 13.75 18.97 13.75 18 13.75 17.03 12.97 16.25 12 16.25 11.03 16.25 10.25 17.03 10.25 18",
    ["fluent_next_filled"] = "m 3 4.75 b 3 3.35 4.58 2.51 5.74 3.31 l 16.24 10.5 b 17.25 11.19 17.25 12.68 16.25 13.38 l 5.75 20.68 b 4.59 21.49 3 20.66 3 19.25 l 3 4.75 m 21 3.75 b 21 3.34 20.66 3 20.25 3 19.84 3 19.5 3.34 19.5 3.75 l 19.5 20.25 b 19.5 20.66 19.84 21 20.25 21 20.66 21 21 20.66 21 20.25 l 21 3.75",
    ["fluent_pause_filled"] = "m 5.75 3 b 4.78 3 4 3.78 4 4.75 l 4 19.25 b 4 20.22 4.78 21 5.75 21 l 9.25 21 b 10.21 21 11 20.22 11 19.25 l 11 4.75 b 11 3.78 10.21 3 9.25 3 l 5.75 3 m 14.75 3 b 13.78 3 13 3.78 13 4.75 l 13 19.25 b 13 20.22 13.78 21 14.75 21 l 18.25 21 b 19.21 21 20 20.22 20 19.25 l 20 4.75 b 20 3.78 19.21 3 18.25 3 l 14.75 3",
    ["fluent_picture_in_picture_enter"] = "m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 18.75 3 b 20.54 3 22 4.46 22 6.25 l 22 12 20.5 12 20.5 6.25 b 20.5 5.28 19.72 4.5 18.75 4.5 l 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 l 3.5 15.75 b 3.5 16.72 4.28 17.5 5.25 17.5 l 11 17.5 11 19 5.25 19 b 3.46 19 2 17.54 2 15.75 l 2 6.25 m 14 13 b 12.9 13 12 13.9 12 15 l 12 20 b 12 21.1 12.9 22 14 22 l 21 22 b 22.1 22 23 21.1 23 20 l 23 15 b 23 13.9 22.1 13 21 13 l 14 13 m 5.22 6.22 b 5.51 5.93 5.99 5.93 6.28 6.22 l 9.5 9.44 9.5 7.75 b 9.5 7.34 9.84 7 10.25 7 10.66 7 11 7.34 11 7.75 l 11 11.25 b 11 11.66 10.66 12 10.25 12 l 6.75 12 b 6.34 12 6 11.66 6 11.25 6 10.84 6.34 10.5 6.75 10.5 l 8.44 10.5 5.22 7.28 b 4.93 6.99 4.93 6.51 5.22 6.22",
    ["fluent_pip_exit"] = "m 10 11 b 10.35 11 10.7 10.91 11 10.73 11.3 10.56 11.56 10.3 11.73 10 11.91 9.7 12 9.35 12 9 l 12 4 b 12 3.65 11.91 3.3 11.73 3 11.56 2.7 11.3 2.44 11 2.27 10.7 2.09 10.35 2 10 2 l 3 2 b 2.65 2 2.3 2.09 2 2.27 1.7 2.44 1.44 2.7 1.27 3 1.09 3.3 1 3.65 1 4 l 1 9 b 1 9.35 1.09 9.7 1.27 10 1.44 10.3 1.7 10.56 2 10.73 2.3 10.91 2.65 11 3 11 l 10 11 m 18.75 6.5 l 13 6.5 13 5 18.75 5 b 19.32 5 19.88 5.15 20.38 5.44 20.87 5.72 21.28 6.13 21.56 6.62 21.85 7.12 22 7.68 22 8.25 l 22 17.75 b 22 18.32 21.85 18.88 21.56 19.38 21.28 19.87 20.87 20.28 20.38 20.56 19.88 20.85 19.32 21 18.75 21 l 5.25 21 b 4.68 21 4.12 20.85 3.63 20.56 3.13 20.28 2.72 19.87 2.44 19.38 2.15 18.88 2 18.32 2 17.75 l 2 11.83 b 2.31 11.94 2.65 12 3 12 l 3.5 12 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.06 19.5 19.36 19.42 19.62 19.27 19.89 19.11 20.11 18.89 20.27 18.62 20.42 18.36 20.5 18.06 20.5 17.75 l 20.5 8.25 b 20.5 7.94 20.42 7.64 20.27 7.38 20.11 7.11 19.89 6.89 19.62 6.73 19.36 6.58 19.06 6.5 18.75 6.5 m 15.56 12.5 l 17.25 12.5 b 17.38 12.5 17.51 12.47 17.62 12.4 17.74 12.33 17.83 12.24 17.9 12.12 17.97 12.01 18 11.88 18 11.75 18 11.62 17.97 11.49 17.9 11.38 17.83 11.26 17.74 11.17 17.62 11.1 17.51 11.03 17.38 11 17.25 11 l 13.75 11 b 13.62 11 13.49 11.03 13.37 11.1 13.26 11.17 13.17 11.26 13.1 11.38 13.03 11.49 13 11.62 13 11.75 l 13 15.25 b 13 15.38 13.03 15.51 13.1 15.63 13.17 15.74 13.26 15.83 13.38 15.9 13.49 15.97 13.62 16 13.75 16 13.88 16 14.01 15.97 14.12 15.9 14.24 15.83 14.33 15.74 14.4 15.63 14.47 15.51 14.5 15.38 14.5 15.25 l 14.5 13.56 17.22 16.28 b 17.3 16.36 17.4 16.43 17.5 16.47 17.61 16.51 17.73 16.53 17.84 16.52 17.96 16.5 18.07 16.47 18.16 16.41 18.26 16.34 18.34 16.26 18.41 16.16 18.47 16.07 18.5 15.96 18.52 15.84 18.53 15.73 18.51 15.61 18.47 15.5 18.43 15.4 18.36 15.3 18.28 15.22 l 15.56 12.5",
    ["fluent_play_filled"] = "m 5 5.27 b 5 3.57 6.83 2.48 8.33 3.3 l 20.69 10.02 b 22.25 10.88 22.25 13.12 20.69 13.98 l 8.33 20.7 b 6.83 21.52 5 20.43 5 18.73 l 5 5.27",
    ["fluent_playlist"] = "m 4 6.25 b 4 5.84 4.34 5.5 4.75 5.5 l 19.25 5.5 b 19.66 5.5 20 5.84 20 6.25 20 6.66 19.66 7 19.25 7 l 4.75 7 b 4.34 7 4 6.66 4 6.25 m 4 12.25 b 4 11.84 4.34 11.5 4.75 11.5 l 19.25 11.5 b 19.66 11.5 20 11.84 20 12.25 20 12.66 19.66 13 19.25 13 l 4.75 13 b 4.34 13 4 12.66 4 12.25 m 4 18.25 b 4 17.84 4.34 17.5 4.75 17.5 l 11.25 17.5 b 11.66 17.5 12 17.84 12 18.25 12 18.66 11.66 19 11.25 19 l 4.75 19 b 4.34 19 4 18.66 4 18.25 m 16.54 14.36 b 15.75 13.86 14.75 14.43 14.75 15.36 l 14.75 19.64 b 14.75 20.57 15.75 21.14 16.54 20.64 l 19.9 18.5 b 20.64 18.03 20.64 16.97 19.9 16.5 l 16.54 14.36 m 16.25 16.25 l 16.25 18.75 b 16.25 18.98 16.49 19.1 16.68 18.97 l 18.68 17.72 b 18.86 17.61 18.86 17.39 18.68 17.28 l 16.68 16.03 b 16.49 15.9 16.25 16.02 16.25 16.25",
    ["fluent_previous_filled"] = "m 3 3.75 b 3 3.34 3.34 3 3.75 3 4.16 3 4.5 3.34 4.5 3.75 l 4.5 20.25 b 4.5 20.66 4.16 21 3.75 21 3.34 21 3 20.66 3 20.25 l 3 3.75 m 21 4.75 b 21 3.35 19.42 2.51 18.26 3.31 l 7.76 10.5 b 6.75 11.19 6.75 12.68 7.75 13.38 l 18.25 20.68 b 19.41 21.49 21 20.66 21 19.25 l 21 4.75",
    ["fluent_replay_filled"] = "m 4.5 5.39 b 6.33 3.31 9.01 2 12 2 17.52 2 22 6.48 22 12 22 17.52 17.52 22 12 22 6.48 22 2 17.52 2 12 2 11.52 2.03 11.05 2.1 10.59 2.15 10.25 2.45 10 2.8 10 3.28 10 3.63 10.45 3.57 10.92 3.52 11.27 3.5 11.63 3.5 12 3.5 16.69 7.31 20.5 12 20.5 16.69 20.5 20.5 16.69 20.5 12 20.5 7.31 16.69 3.5 12 3.5 9.4 3.5 7.08 4.66 5.52 6.5 l 7.25 6.5 b 7.66 6.5 8 6.84 8 7.25 8 7.66 7.66 8 7.25 8 l 3.75 8 b 3.34 8 3 7.66 3 7.25 l 3 3.75 b 3 3.34 3.34 3 3.75 3 4.16 3 4.5 3.34 4.5 3.75 l 4.5 5.39 m 11.23 8.19 b 10.23 7.63 9 8.36 9 9.5 l 9 14.5 b 9 15.64 10.23 16.37 11.23 15.81 l 15.73 13.31 b 16.76 12.74 16.76 11.26 15.73 10.69 l 11.23 8.19",
    ["fluent_rewind_filled"] = "m 10.03 4.36 b 11 3.53 12.5 4.22 12.5 5.5 l 12.5 9.49 18.53 4.36 b 19.5 3.53 21 4.23 21 5.51 l 21 18.5 b 21 19.38 20.29 19.98 19.54 20 l 19.45 20 b 19.13 19.99 18.81 19.88 18.53 19.64 l 12.5 14.51 12.5 18.5 b 12.5 19.78 11 20.47 10.03 19.64 l 2.62 13.33 b 1.8 12.63 1.8 11.37 2.62 10.67 l 10.03 4.36 m 2.62 10.67 l 3.11 11.24 2.62 10.67",
    ["fluent_skip_back_10_filled"] = "m 3 2.25 b 2.45 2.25 2 2.7 2 3.25 l 2 9 b 2 9.55 2.45 10 3 10 l 8.25 10 b 8.8 10 9.25 9.55 9.25 9 9.25 8.45 8.8 8 8.25 8 l 4.86 8 b 5.85 6.82 7.07 5.89 8.55 5.43 10.56 4.81 12.69 4.86 14.65 5.59 16.63 6.33 18.46 7.82 19.37 9.48 19.64 9.97 20.25 10.15 20.73 9.88 21.21 9.61 21.39 9.01 21.13 8.52 19.95 6.38 17.71 4.6 15.35 3.72 12.97 2.83 10.38 2.77 7.95 3.52 6.38 4.01 5.07 4.9 4 5.98 l 4 3.25 b 4 2.7 3.55 2.25 3 2.25 m 9.75 12 b 9.75 11.58 9.49 11.21 9.09 11.06 8.7 10.92 8.26 11.03 7.99 11.35 7.91 11.44 7.84 11.53 7.77 11.62 7.25 12.24 6.69 12.92 5.49 13.64 5.01 13.93 4.86 14.54 5.14 15.01 5.43 15.49 6.04 15.64 6.51 15.36 7 15.07 7.4 14.78 7.75 14.49 l 7.75 20 b 7.75 20.55 8.2 21 8.75 21 9.3 21 9.75 20.55 9.75 20 l 9.75 12 m 16.25 11 b 14.86 11 13.85 11.64 13.24 12.66 12.68 13.61 12.5 14.82 12.5 16 12.5 17.18 12.68 18.39 13.24 19.34 13.85 20.36 14.86 21 16.25 21 17.64 21 18.65 20.36 19.26 19.34 19.82 18.39 20 17.18 20 16 20 14.82 19.82 13.61 19.26 12.66 18.65 11.64 17.64 11 16.25 11 m 14.5 16 b 14.5 14.97 14.67 14.18 14.96 13.68 15.21 13.26 15.57 13 16.25 13 16.93 13 17.29 13.26 17.54 13.68 17.83 14.18 18 14.97 18 16 18 17.03 17.83 17.82 17.54 18.32 17.29 18.74 16.93 19 16.25 19 15.57 19 15.21 18.74 14.96 18.32 14.67 17.82 14.5 17.03 14.5 16",
    ["fluent_skip_back_30_filled"] = "m 3.87 2.25 b 3.7 2.25 3.53 2.3 3.37 2.38 3.22 2.47 3.09 2.6 3.01 2.75 2.92 2.9 2.87 3.07 2.87 3.25 l 2.87 9 b 2.87 9.18 2.92 9.35 3.01 9.5 3.09 9.65 3.22 9.78 3.37 9.87 3.53 9.95 3.7 10 3.87 10 l 9.12 10 b 9.3 10 9.47 9.95 9.62 9.87 9.78 9.78 9.9 9.65 9.99 9.5 10.08 9.35 10.12 9.18 10.12 9 10.12 8.82 10.08 8.65 9.99 8.5 9.9 8.35 9.78 8.22 9.62 8.13 9.47 8.05 9.3 8 9.12 8 l 5.74 8 b 6.72 6.82 7.95 5.89 9.42 5.43 10.41 5.12 11.45 4.98 12.49 5 13.52 5.03 14.55 5.23 15.53 5.59 17.51 6.33 19.34 7.82 20.25 9.48 20.32 9.62 20.42 9.73 20.54 9.82 20.66 9.9 20.8 9.96 20.95 9.99 21.1 10.01 21.25 10.01 21.4 9.97 21.54 9.92 21.67 9.85 21.79 9.75 21.9 9.65 21.99 9.53 22.05 9.39 22.1 9.25 22.13 9.1 22.12 8.95 22.11 8.8 22.07 8.65 22 8.52 20.82 6.38 18.59 4.6 16.22 3.72 15.04 3.28 13.8 3.04 12.54 3 11.28 2.97 10.03 3.14 8.83 3.52 7.25 4.01 5.94 4.9 4.87 5.98 l 4.87 3.25 b 4.87 3.07 4.83 2.9 4.74 2.75 4.65 2.6 4.53 2.47 4.37 2.38 4.22 2.3 4.05 2.25 3.87 2.25 m 6.46 13.71 b 6.61 13.55 6.76 13.4 7.03 13.27 7.31 13.14 7.75 13 8.5 13 10.11 13 10.42 13.77 10.43 14.04 10.44 14.28 10.22 15 8.75 15 8.57 15 8.4 15.05 8.25 15.13 8.1 15.22 7.97 15.35 7.88 15.5 7.8 15.65 7.75 15.82 7.75 16 7.75 16.18 7.8 16.35 7.88 16.5 7.97 16.65 8.1 16.78 8.25 16.87 8.4 16.95 8.57 17 8.75 17 10.22 17 10.44 17.72 10.43 17.96 10.42 18.23 10.11 19 8.5 19 7.75 19 7.31 18.86 7.03 18.73 6.82 18.62 6.62 18.47 6.46 18.29 6.33 18.17 6.18 18.08 6.01 18.03 5.84 17.99 5.66 17.99 5.49 18.03 5.32 18.08 5.17 18.17 5.04 18.29 4.92 18.42 4.83 18.57 4.78 18.74 4.74 18.91 4.74 19.09 4.78 19.26 4.83 19.43 4.92 19.58 5.04 19.71 l 5.05 19.72 b 5.24 19.9 5.58 20.25 6.16 20.53 6.74 20.81 7.49 21 8.5 21 10.74 21 12.37 19.77 12.43 18.04 12.45 17.65 12.38 17.28 12.23 16.92 12.09 16.57 11.87 16.26 11.59 16 11.87 15.74 12.09 15.43 12.23 15.07 12.38 14.72 12.45 14.34 12.43 13.96 12.37 12.23 10.74 11 8.5 11 7.49 11 6.74 11.19 6.16 11.47 5.58 11.75 5.24 12.1 5.05 12.28 l 5.04 12.29 b 4.93 12.42 4.85 12.57 4.81 12.74 4.77 12.9 4.77 13.08 4.81 13.24 4.86 13.41 4.95 13.56 5.07 13.68 5.19 13.8 5.34 13.89 5.5 13.93 5.67 13.98 5.84 13.98 6.01 13.95 6.18 13.91 6.33 13.82 6.46 13.71 m 14.24 12.66 b 14.85 11.63 15.86 11 17.25 11 18.64 11 19.65 11.63 20.26 12.66 20.82 13.61 21 14.82 21 16 21 17.18 20.82 18.39 20.26 19.34 19.65 20.36 18.64 21 17.25 21 15.86 21 14.85 20.36 14.24 19.34 13.68 18.39 13.5 17.18 13.5 16 13.5 14.82 13.68 13.61 14.24 12.66 m 15.96 13.68 b 15.67 14.18 15.5 14.97 15.5 16 15.5 17.03 15.67 17.82 15.96 18.32 16.21 18.74 16.57 19 17.25 19 17.93 19 18.29 18.74 18.54 18.32 18.83 17.82 19 17.03 19 16 19 14.97 18.83 14.18 18.54 13.68 18.29 13.26 17.93 13 17.25 13 16.57 13 16.21 13.26 15.96 13.68",
    ["fluent_skip_back_5_filled"] = "m 2 3.25 b 2 3.07 2.05 2.9 2.13 2.75 2.22 2.6 2.35 2.47 2.5 2.38 2.65 2.3 2.82 2.25 3 2.25 3.18 2.25 3.35 2.3 3.5 2.38 3.65 2.47 3.78 2.6 3.87 2.75 3.95 2.9 4 3.07 4 3.25 l 4 5.98 b 5.07 4.9 6.38 4.01 7.95 3.52 9.15 3.14 10.41 2.97 11.67 3 12.92 3.04 14.17 3.28 15.35 3.72 17.71 4.6 19.95 6.38 21.13 8.52 21.2 8.68 21.24 8.85 21.23 9.02 21.22 9.19 21.17 9.35 21.08 9.5 20.99 9.64 20.86 9.76 20.71 9.85 20.56 9.93 20.39 9.97 20.22 9.97 20.05 9.97 19.88 9.92 19.73 9.84 19.58 9.75 19.46 9.63 19.37 9.48 18.46 7.82 16.63 6.33 14.65 5.59 13.68 5.23 12.65 5.03 11.61 5 10.57 4.97 9.54 5.12 8.54 5.43 7.07 5.89 5.85 6.82 4.86 8 l 8.25 8 b 8.42 8 8.6 8.05 8.75 8.13 8.9 8.22 9.03 8.35 9.12 8.5 9.2 8.65 9.25 8.82 9.25 9 9.25 9.17 9.2 9.35 9.12 9.5 9.03 9.65 8.9 9.78 8.75 9.87 8.6 9.95 8.42 10 8.25 10 l 3 10 b 2.82 10 2.65 9.95 2.5 9.87 2.35 9.78 2.22 9.65 2.13 9.5 2.05 9.35 2 9.17 2 9 l 2 3.25 2 3.25 m 13 13 b 13.18 13 13.35 12.95 13.5 12.87 13.65 12.78 13.78 12.65 13.87 12.5 13.95 12.35 14 12.18 14 12 14 11.82 13.95 11.65 13.87 11.5 13.78 11.35 13.65 11.22 13.5 11.13 13.35 11.05 13.18 11 13 11 l 9.9 11 b 9.74 11 9.58 11.04 9.44 11.11 9.3 11.19 9.17 11.29 9.08 11.43 8.99 11.56 8.93 11.71 8.91 11.87 l 8.51 14.87 b 8.49 15.01 8.5 15.15 8.54 15.29 8.58 15.43 8.65 15.55 8.75 15.66 8.84 15.77 8.96 15.85 9.09 15.91 9.22 15.97 9.36 16 9.5 16 l 11.5 16 b 11.71 16 11.92 16.05 12.12 16.14 12.31 16.23 12.49 16.35 12.63 16.52 12.77 16.68 12.88 16.87 12.94 17.07 13 17.28 13.01 17.5 12.98 17.71 12.95 17.96 12.85 18.2 12.69 18.41 12.54 18.61 12.33 18.77 12.1 18.88 11.86 18.98 11.61 19.02 11.35 18.99 11.1 18.97 10.85 18.88 10.64 18.73 10.43 18.58 10.26 18.39 10.15 18.16 10.08 18.02 9.99 17.9 9.87 17.81 9.75 17.72 9.62 17.65 9.47 17.62 9.32 17.58 9.17 17.58 9.02 17.62 8.88 17.65 8.74 17.72 8.62 17.81 8.51 17.91 8.41 18.03 8.35 18.16 8.28 18.3 8.25 18.45 8.25 18.6 8.25 18.75 8.29 18.9 8.35 19.03 8.59 19.53 8.95 19.96 9.4 20.3 9.84 20.63 10.36 20.85 10.9 20.95 11.45 21.04 12.01 21.01 12.54 20.84 13.07 20.68 13.55 20.39 13.95 20 14.35 19.61 14.64 19.14 14.82 18.61 15 18.08 15.04 17.52 14.96 16.98 14.88 16.43 14.66 15.91 14.34 15.46 14.02 15.01 13.59 14.64 13.1 14.39 12.6 14.13 12.05 14 11.5 14 l 10.64 14 10.78 13 13 13 13 13",
    ["fluent_skip_back_tab_filled"] = "m 2.75 3.25 b 2.75 2.7 3.2 2.25 3.75 2.25 4.3 2.25 4.75 2.7 4.75 3.25 l 4.75 5.98 b 5.82 4.9 7.13 4.01 8.7 3.52 11.13 2.77 13.72 2.83 16.1 3.72 18.46 4.6 20.7 6.38 21.88 8.52 22.14 9.01 21.96 9.61 21.48 9.88 21 10.15 20.39 9.97 20.12 9.48 19.21 7.82 17.38 6.33 15.4 5.59 13.44 4.86 11.31 4.81 9.3 5.43 7.82 5.89 6.6 6.82 5.61 8 l 9 8 b 9.55 8 10 8.45 10 9 10 9.55 9.55 10 9 10 l 3.75 10 b 3.2 10 2.75 9.55 2.75 9 l 2.75 3.25 m 18.75 15 b 18.75 13.9 17.85 13 16.75 13 l 8.75 13 b 7.65 13 6.75 13.9 6.75 15 l 6.75 19 b 6.75 20.1 7.65 21 8.75 21 l 16.75 21 b 17.85 21 18.75 20.1 18.75 19 l 18.75 15 m 16.75 15.5 l 16.75 18.5 b 16.75 18.78 16.53 19 16.25 19 l 9.25 19 b 8.97 19 8.75 18.78 8.75 18.5 l 8.75 15.5 b 8.75 15.22 8.97 15 9.25 15 l 16.25 15 b 16.53 15 16.75 15.22 16.75 15.5",
    ["fluent_skip_forward_10_filled"] = "m 21 2.25 b 21.55 2.25 22 2.7 22 3.25 l 22 9 b 22 9.55 21.55 10 21 10 l 15.75 10 b 15.2 10 14.75 9.55 14.75 9 14.75 8.45 15.2 8 15.75 8 l 19.14 8 b 18.15 6.82 16.93 5.89 15.45 5.43 13.44 4.81 11.31 4.86 9.35 5.59 7.37 6.33 5.54 7.82 4.63 9.48 4.36 9.97 3.75 10.15 3.27 9.88 2.79 9.61 2.61 9.01 2.87 8.52 4.05 6.38 6.29 4.6 8.65 3.72 11.03 2.83 13.62 2.77 16.05 3.52 17.62 4.01 18.93 4.9 20 5.98 l 20 3.25 b 20 2.7 20.45 2.25 21 2.25 m 9.09 11.06 b 9.49 11.21 9.75 11.58 9.75 12 l 9.75 20 b 9.75 20.55 9.3 21 8.75 21 8.2 21 7.75 20.55 7.75 20 l 7.75 14.49 b 7.4 14.78 7 15.07 6.51 15.36 6.04 15.64 5.43 15.49 5.14 15.01 4.86 14.54 5.01 13.93 5.49 13.64 6.69 12.92 7.25 12.24 7.77 11.62 7.84 11.53 7.91 11.44 7.99 11.35 8.26 11.03 8.7 10.92 9.09 11.06 m 13.24 12.66 b 13.85 11.64 14.86 11 16.25 11 17.64 11 18.65 11.64 19.26 12.66 19.82 13.61 20 14.82 20 16 20 17.18 19.82 18.39 19.26 19.34 18.65 20.36 17.64 21 16.25 21 14.86 21 13.85 20.36 13.24 19.34 12.68 18.39 12.5 17.18 12.5 16 12.5 14.82 12.68 13.61 13.24 12.66 m 14.96 13.68 b 14.67 14.18 14.5 14.97 14.5 16 14.5 17.03 14.67 17.82 14.96 18.32 15.21 18.74 15.57 19 16.25 19 16.93 19 17.29 18.74 17.54 18.32 17.83 17.82 18 17.03 18 16 18 14.97 17.83 14.18 17.54 13.68 17.29 13.26 16.93 13 16.25 13 15.57 13 15.21 13.26 14.96 13.68",
    ["fluent_skip_forward_30_filled"] = "m 21 2.25 b 21.55 2.25 22 2.7 22 3.25 l 22 9 b 22 9.55 21.55 10 21 10 l 15.75 10 b 15.2 10 14.75 9.55 14.75 9 14.75 8.45 15.2 8 15.75 8 l 19.14 8 b 18.15 6.82 16.93 5.89 15.45 5.43 13.44 4.81 11.31 4.86 9.35 5.59 7.37 6.33 5.54 7.82 4.63 9.48 4.36 9.97 3.75 10.15 3.27 9.88 2.79 9.61 2.61 9.01 2.87 8.52 4.05 6.38 6.29 4.6 8.65 3.72 11.03 2.83 13.62 2.77 16.05 3.52 17.62 4.01 18.93 4.9 20 5.98 l 20 3.25 b 20 2.7 20.45 2.25 21 2.25 m 6.46 13.71 b 6.61 13.55 6.76 13.4 7.03 13.27 7.31 13.14 7.76 13 8.5 13 10.11 13 10.42 13.77 10.43 14.04 10.44 14.28 10.22 15 8.75 15 8.2 15 7.75 15.45 7.75 16 7.75 16.55 8.2 17 8.75 17 10.22 17 10.44 17.72 10.43 17.96 10.42 18.23 10.11 19 8.5 19 7.76 19 7.31 18.86 7.03 18.73 6.76 18.6 6.61 18.45 6.46 18.29 6.06 17.9 5.43 17.9 5.04 18.29 4.65 18.69 4.65 19.32 5.04 19.71 l 5.05 19.72 b 5.24 19.9 5.58 20.25 6.16 20.53 6.74 20.81 7.49 21 8.5 21 10.74 21 12.37 19.77 12.43 18.04 12.46 17.23 12.15 16.53 11.59 16 12.15 15.47 12.46 14.77 12.43 13.96 12.37 12.23 10.74 11 8.5 11 7.49 11 6.74 11.19 6.16 11.47 5.58 11.75 5.24 12.1 5.05 12.28 l 5.04 12.29 b 4.65 12.68 4.65 13.31 5.04 13.71 5.43 14.1 6.06 14.1 6.46 13.71 m 14.24 12.66 b 14.85 11.64 15.86 11 17.25 11 18.64 11 19.65 11.64 20.26 12.66 20.82 13.61 21 14.82 21 16 21 17.18 20.82 18.39 20.26 19.34 19.65 20.36 18.64 21 17.25 21 15.86 21 14.85 20.36 14.24 19.34 13.68 18.39 13.5 17.18 13.5 16 13.5 14.82 13.68 13.61 14.24 12.66 m 15.96 13.68 b 15.67 14.18 15.5 14.97 15.5 16 15.5 17.03 15.67 17.82 15.96 18.32 16.21 18.74 16.57 19 17.25 19 17.93 19 18.29 18.74 18.54 18.32 18.83 17.82 19 17.03 19 16 19 14.97 18.83 14.18 18.54 13.68 18.29 13.26 17.93 13 17.25 13 16.57 13 16.21 13.26 15.96 13.68",
    ["fluent_skip_forward_5_filled"] = "m 21.25 3.25 b 21.25 3.07 21.2 2.9 21.12 2.75 21.03 2.6 20.9 2.47 20.75 2.38 20.6 2.3 20.43 2.25 20.25 2.25 20.07 2.25 19.9 2.3 19.75 2.38 19.6 2.47 19.47 2.6 19.38 2.75 19.3 2.9 19.25 3.07 19.25 3.25 l 19.25 5.98 b 18.18 4.9 16.87 4.01 15.3 3.52 14.1 3.14 12.84 2.97 11.58 3 10.33 3.04 9.08 3.28 7.9 3.72 5.54 4.6 3.3 6.38 2.12 8.52 2.05 8.68 2.01 8.85 2.02 9.02 2.03 9.19 2.08 9.35 2.17 9.5 2.26 9.64 2.39 9.76 2.54 9.85 2.69 9.93 2.86 9.97 3.03 9.97 3.2 9.97 3.37 9.92 3.52 9.84 3.67 9.75 3.79 9.63 3.88 9.48 4.79 7.82 6.62 6.33 8.6 5.59 9.57 5.23 10.6 5.03 11.64 5 12.68 4.97 13.71 5.12 14.71 5.43 16.18 5.89 17.4 6.82 18.39 8 l 15 8 b 14.83 8 14.65 8.05 14.5 8.13 14.35 8.22 14.22 8.35 14.13 8.5 14.05 8.65 14 8.82 14 9 14 9.17 14.05 9.35 14.13 9.5 14.22 9.65 14.35 9.78 14.5 9.87 14.65 9.95 14.83 10 15 10 l 20.25 10 b 20.43 10 20.6 9.95 20.75 9.87 20.9 9.78 21.03 9.65 21.12 9.5 21.2 9.35 21.25 9.17 21.25 9 l 21.25 3.25 21.25 3.25 m 13 13 b 13.18 13 13.35 12.95 13.5 12.87 13.65 12.78 13.78 12.65 13.87 12.5 13.95 12.35 14 12.18 14 12 14 11.82 13.95 11.65 13.87 11.5 13.78 11.35 13.65 11.22 13.5 11.13 13.35 11.05 13.18 11 13 11 l 9.9 11 b 9.74 11 9.58 11.04 9.44 11.11 9.3 11.19 9.17 11.29 9.08 11.43 8.99 11.56 8.93 11.71 8.91 11.87 l 8.51 14.87 b 8.49 15.01 8.5 15.15 8.54 15.29 8.58 15.43 8.65 15.55 8.75 15.66 8.84 15.77 8.96 15.85 9.09 15.91 9.22 15.97 9.36 16 9.5 16 l 11.5 16 b 11.71 16 11.92 16.05 12.12 16.14 12.31 16.23 12.49 16.35 12.63 16.52 12.77 16.68 12.88 16.87 12.94 17.07 13 17.28 13.01 17.5 12.98 17.71 12.95 17.96 12.85 18.2 12.69 18.41 12.54 18.61 12.33 18.77 12.1 18.88 11.86 18.98 11.61 19.02 11.35 18.99 11.1 18.97 10.85 18.88 10.64 18.73 10.43 18.58 10.26 18.39 10.15 18.16 10.08 18.02 9.99 17.9 9.87 17.81 9.75 17.72 9.62 17.65 9.47 17.62 9.32 17.58 9.17 17.58 9.02 17.62 8.88 17.65 8.74 17.72 8.62 17.81 8.51 17.91 8.41 18.03 8.35 18.16 8.28 18.3 8.25 18.45 8.25 18.6 8.25 18.75 8.29 18.9 8.35 19.03 8.59 19.53 8.95 19.96 9.4 20.3 9.84 20.63 10.36 20.85 10.9 20.95 11.45 21.04 12.01 21.01 12.54 20.84 13.07 20.68 13.55 20.39 13.95 20 14.35 19.61 14.64 19.14 14.82 18.61 15 18.08 15.04 17.52 14.96 16.98 14.88 16.43 14.66 15.91 14.34 15.46 14.02 15.01 13.59 14.64 13.1 14.39 12.6 14.13 12.05 14 11.5 14 l 10.64 14 10.78 13 13 13 13 13",
    ["fluent_skip_forward_tab_filled"] = "m 22 3.25 b 22 2.7 21.55 2.25 21 2.25 20.45 2.25 20 2.7 20 3.25 l 20 5.98 b 18.93 4.9 17.62 4.01 16.05 3.52 13.62 2.77 11.03 2.83 8.65 3.72 6.29 4.6 4.05 6.38 2.87 8.52 2.61 9.01 2.79 9.61 3.27 9.88 3.75 10.15 4.36 9.97 4.63 9.48 5.54 7.82 7.37 6.33 9.35 5.59 11.31 4.86 13.44 4.81 15.45 5.43 16.93 5.89 18.15 6.82 19.14 8 l 15.75 8 b 15.2 8 14.75 8.45 14.75 9 14.75 9.55 15.2 10 15.75 10 l 21 10 b 21.55 10 22 9.55 22 9 l 22 3.25 m 6 15 b 6 13.9 6.9 13 8 13 l 16 13 b 17.1 13 18 13.9 18 15 l 18 19 b 18 20.1 17.1 21 16 21 l 8 21 b 6.9 21 6 20.1 6 19 l 6 15 m 8 15.5 l 8 18.5 b 8 18.78 8.22 19 8.5 19 l 15.5 19 b 15.78 19 16 18.78 16 18.5 l 16 15.5 b 16 15.22 15.78 15 15.5 15 l 8.5 15 b 8.22 15 8 15.22 8 15.5",
    ["fluent_speaker_0"] = "m 14.7 3.44 b 14.9 3.67 15 3.95 15 4.25 l 15 19.75 b 15 20.44 14.44 21 13.75 21 13.45 21 13.17 20.89 12.94 20.7 l 7.98 16.5 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.98 7.5 12.94 3.29 b 13.47 2.85 14.26 2.91 14.7 3.44 m 13.5 4.79 l 8.52 9 4.25 9 b 3.84 9 3.5 9.33 3.5 9.75 l 3.5 14.25 b 3.5 14.66 3.84 15 4.25 15 l 8.52 15 13.5 19.21 13.5 4.79",
    ["fluent_speaker_1"] = "m 14.7 3.44 b 14.9 3.67 15 3.95 15 4.25 l 15 19.75 b 15 20.44 14.44 21 13.75 21 13.45 21 13.17 20.9 12.94 20.71 l 7.98 16.5 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.98 7.5 12.94 3.3 b 13.47 2.85 14.26 2.92 14.7 3.44 m 13.5 4.79 l 8.52 9 4.25 9 b 3.84 9 3.5 9.34 3.5 9.75 l 3.5 14.25 b 3.5 14.66 3.84 15 4.25 15 l 8.52 15 13.5 19.21 13.5 4.79 m 17.1 8.64 b 17.46 8.42 17.92 8.54 18.13 8.89 18.71 9.83 19 10.88 19 12.03 19 13.18 18.71 14.23 18.13 15.17 17.92 15.52 17.46 15.64 17.1 15.42 16.75 15.2 16.64 14.74 16.85 14.39 17.28 13.69 17.5 12.91 17.5 12.03 17.5 11.15 17.28 10.37 16.85 9.67 16.64 9.32 16.75 8.86 17.1 8.64",
    ["fluent_speaker_2"] = "m 15 4.25 b 15 3.17 13.73 2.6 12.92 3.32 l 8.43 7.31 b 8.29 7.43 8.11 7.5 7.93 7.5 l 4.25 7.5 b 3.01 7.5 2 8.51 2 9.75 l 2 14.25 b 2 15.49 3.01 16.5 4.25 16.5 l 7.93 16.5 b 8.11 16.5 8.29 16.56 8.43 16.69 l 12.92 20.68 b 13.73 21.4 15 20.82 15 19.75 l 15 4.25 m 9.42 8.43 l 13.5 4.81 13.5 19.19 9.42 15.56 b 9.01 15.2 8.48 15 7.93 15 l 4.25 15 b 3.84 15 3.5 14.66 3.5 14.25 l 3.5 9.75 b 3.5 9.33 3.84 9 4.25 9 l 7.93 9 b 8.48 9 9.01 8.8 9.42 8.43 m 18.99 5.9 b 19.32 5.65 19.79 5.72 20.04 6.05 21.27 7.72 22 9.77 22 12 22 14.23 21.27 16.28 20.04 17.95 19.79 18.28 19.32 18.35 18.99 18.1 18.66 17.86 18.59 17.39 18.84 17.05 19.88 15.64 20.5 13.89 20.5 12 20.5 10.11 19.88 8.36 18.84 6.95 18.59 6.61 18.66 6.14 18.99 5.9 m 17.14 8.37 b 17.51 8.17 17.96 8.31 18.16 8.67 18.7 9.66 19 10.8 19 12 19 13.2 18.7 14.34 18.16 15.33 17.96 15.69 17.51 15.83 17.14 15.63 16.78 15.43 16.64 14.98 16.84 14.61 17.26 13.84 17.5 12.95 17.5 12 17.5 11.05 17.26 10.16 16.84 9.39 16.64 9.02 16.78 8.57 17.14 8.37",
    ["fluent_speaker_mute"] = "m 12.92 3.32 b 13.73 2.6 15 3.17 15 4.25 l 15 19.75 b 15 20.82 13.73 21.4 12.92 20.68 l 8.43 16.69 b 8.29 16.56 8.11 16.5 7.93 16.5 l 4.25 16.5 b 3.01 16.5 2 15.49 2 14.25 l 2 9.75 b 2 8.51 3.01 7.5 4.25 7.5 l 7.93 7.5 b 8.11 7.5 8.29 7.43 8.43 7.31 l 12.92 3.32 m 13.5 4.81 l 9.42 8.43 b 9.01 8.8 8.48 9 7.93 9 l 4.25 9 b 3.84 9 3.5 9.33 3.5 9.75 l 3.5 14.25 b 3.5 14.66 3.84 15 4.25 15 l 7.93 15 b 8.48 15 9.01 15.2 9.42 15.56 l 13.5 19.19 13.5 4.81 m 16.22 9.22 b 16.51 8.93 16.99 8.93 17.28 9.22 l 19 10.94 20.72 9.22 b 21.01 8.93 21.49 8.93 21.78 9.22 22.07 9.51 22.07 9.99 21.78 10.28 l 20.06 12 21.78 13.72 b 22.07 14.01 22.07 14.49 21.78 14.78 21.49 15.07 21.01 15.07 20.72 14.78 l 19 13.06 17.28 14.78 b 16.99 15.07 16.51 15.07 16.22 14.78 15.93 14.49 15.93 14.01 16.22 13.72 l 17.94 12 16.22 10.28 b 15.93 9.99 15.93 9.51 16.22 9.22",
    ["fluent_subtitles"] = "m 2 7.25 b 2 5.46 3.46 4 5.25 4 l 18.75 4 b 20.54 4 22 5.46 22 7.25 l 22 16.75 b 22 18.54 20.54 20 18.75 20 l 5.25 20 b 3.46 20 2 18.54 2 16.75 l 2 7.25 m 5.25 5.5 b 4.28 5.5 3.5 6.28 3.5 7.25 l 3.5 16.75 b 3.5 17.72 4.28 18.5 5.25 18.5 l 18.75 18.5 b 19.72 18.5 20.5 17.72 20.5 16.75 l 20.5 7.25 b 20.5 6.28 19.72 5.5 18.75 5.5 l 5.25 5.5 m 5 13.25 b 5 12.84 5.34 12.5 5.75 12.5 l 13.25 12.5 b 13.66 12.5 14 12.84 14 13.25 14 13.66 13.66 14 13.25 14 l 5.75 14 b 5.34 14 5 13.66 5 13.25 m 15.75 12.5 b 15.34 12.5 15 12.84 15 13.25 15 13.66 15.34 14 15.75 14 l 18.25 14 b 18.66 14 19 13.66 19 13.25 19 12.84 18.66 12.5 18.25 12.5 l 15.75 12.5 m 5 16.25 b 5 15.84 5.34 15.5 5.75 15.5 l 9.25 15.5 b 9.66 15.5 10 15.84 10 16.25 10 16.66 9.66 17 9.25 17 l 5.75 17 b 5.34 17 5 16.66 5 16.25 m 11.75 15.5 b 11.34 15.5 11 15.84 11 16.25 11 16.66 11.34 17 11.75 17 l 18.25 17 b 18.66 17 19 16.66 19 16.25 19 15.84 18.66 15.5 18.25 15.5 l 11.75 15.5",
    ["fluent_top_speed"] = "m 6.54 5.48 b 7.84 4.4 9.47 3.69 11.25 3.53 l 11.25 5.25 b 11.25 5.66 11.59 6 12 6 12.41 6 12.75 5.66 12.75 5.25 l 12.75 3.53 b 16.93 3.9 20.24 7.29 20.49 11.5 l 18.75 11.5 b 18.34 11.5 18 11.84 18 12.25 18 12.66 18.34 13 18.75 13 l 20.44 13 b 20.18 15.31 19.02 17.25 17.28 18.67 16.96 18.93 16.91 19.4 17.17 19.72 17.43 20.04 17.9 20.09 18.22 19.83 20.45 18.02 21.89 15.44 21.99 12.35 22 12.32 22 12.28 22 12.25 22 12.23 22 12.21 22 12.19 22 12.13 22 12.06 22 12 22 6.48 17.52 2 12 2 6.48 2 2 6.48 2 12 2 15.25 3.52 17.95 5.77 19.83 6.09 20.09 6.56 20.05 6.83 19.73 7.09 19.41 7.05 18.94 6.73 18.67 5.02 17.25 3.83 15.31 3.56 13 l 5.25 13 b 5.66 13 6 12.66 6 12.25 6 11.84 5.66 11.5 5.25 11.5 l 3.51 11.5 b 3.62 9.62 4.35 7.9 5.48 6.54 l 6.72 7.78 b 7.01 8.07 7.49 8.07 7.78 7.78 8.07 7.49 8.07 7.01 7.78 6.72 l 6.54 5.48 m 16.76 6.63 b 16.52 6.45 16.18 6.46 15.95 6.65 l 15.73 6.83 b 15.6 6.95 15.4 7.11 15.16 7.32 14.68 7.72 14.04 8.26 13.38 8.82 12.73 9.38 12.06 9.96 11.52 10.43 11.25 10.67 11.02 10.88 10.83 11.06 10.66 11.22 10.5 11.37 10.41 11.48 9.76 12.29 9.9 13.46 10.72 14.1 11.55 14.74 12.75 14.6 13.4 13.79 13.49 13.68 13.61 13.5 13.72 13.3 13.85 13.08 14.01 12.81 14.18 12.5 14.53 11.88 14.95 11.11 15.36 10.35 15.76 9.6 16.16 8.86 16.45 8.31 16.59 8.04 16.71 7.81 16.8 7.65 l 16.93 7.41 b 17.07 7.14 17 6.82 16.76 6.63",
    ["menu_back"] = "m 15.53 4.22 b 15.62 4.31 15.69 4.43 15.72 4.56 15.76 4.68 15.76 4.82 15.72 4.94 15.69 5.07 15.62 5.19 15.53 5.28 l 8.81 12 15.53 18.72 b 15.61 18.8 15.68 18.9 15.72 19 15.76 19.11 15.78 19.23 15.77 19.34 15.75 19.46 15.72 19.57 15.66 19.66 15.59 19.76 15.51 19.84 15.41 19.91 15.32 19.97 15.21 20 15.09 20.02 14.98 20.03 14.86 20.01 14.75 19.97 14.65 19.93 14.55 19.86 14.47 19.78 l 7.22 12.53 b 7.13 12.44 7.06 12.32 7.03 12.19 6.99 12.07 6.99 11.93 7.03 11.81 7.06 11.68 7.13 11.56 7.22 11.47 l 14.47 4.22 b 14.56 4.13 14.68 4.06 14.81 4.03 14.93 3.99 15.07 3.99 15.19 4.03 15.32 4.06 15.44 4.13 15.53 4.22",
    ["menu_chapters"] = "m 5.75 6.5 b 5.75 6.72 5.69 6.93 5.58 7.12 5.47 7.32 5.32 7.47 5.12 7.58 4.93 7.69 4.72 7.75 4.5 7.75 4.28 7.75 4.07 7.69 3.88 7.58 3.68 7.47 3.53 7.32 3.42 7.12 3.31 6.93 3.25 6.72 3.25 6.5 3.25 6.28 3.31 6.07 3.42 5.88 3.53 5.68 3.68 5.53 3.87 5.42 4.07 5.31 4.28 5.25 4.5 5.25 4.72 5.25 4.93 5.31 5.12 5.42 5.32 5.53 5.47 5.68 5.58 5.88 5.69 6.07 5.75 6.28 5.75 6.5 m 5.75 12 b 5.75 12.22 5.69 12.43 5.58 12.62 5.47 12.82 5.32 12.97 5.12 13.08 4.93 13.19 4.72 13.25 4.5 13.25 4.28 13.25 4.07 13.19 3.88 13.08 3.68 12.97 3.53 12.82 3.42 12.62 3.31 12.43 3.25 12.22 3.25 12 3.25 11.78 3.31 11.57 3.42 11.38 3.53 11.18 3.68 11.03 3.87 10.92 4.07 10.81 4.28 10.75 4.5 10.75 4.72 10.75 4.93 10.81 5.12 10.92 5.32 11.03 5.47 11.18 5.58 11.38 5.69 11.57 5.75 11.78 5.75 12 m 5.75 17.5 b 5.75 17.72 5.69 17.93 5.58 18.12 5.47 18.32 5.32 18.47 5.12 18.58 4.93 18.69 4.72 18.75 4.5 18.75 4.28 18.75 4.07 18.69 3.88 18.58 3.68 18.47 3.53 18.32 3.42 18.12 3.31 17.93 3.25 17.72 3.25 17.5 3.25 17.28 3.31 17.07 3.42 16.88 3.53 16.68 3.68 16.53 3.87 16.42 4.07 16.31 4.28 16.25 4.5 16.25 4.72 16.25 4.93 16.31 5.12 16.42 5.32 16.53 5.47 16.68 5.58 16.88 5.69 17.07 5.75 17.28 5.75 17.5 m 9 5.75 l 20 5.75 b 20.13 5.75 20.26 5.78 20.38 5.85 20.49 5.92 20.58 6.01 20.65 6.12 20.72 6.24 20.75 6.37 20.75 6.5 20.75 6.63 20.72 6.76 20.65 6.88 20.58 6.99 20.49 7.08 20.38 7.15 20.26 7.22 20.13 7.25 20 7.25 l 9 7.25 b 8.87 7.25 8.74 7.22 8.62 7.15 8.51 7.08 8.42 6.99 8.35 6.88 8.28 6.76 8.25 6.63 8.25 6.5 8.25 6.37 8.28 6.24 8.35 6.12 8.42 6.01 8.51 5.92 8.62 5.85 8.74 5.78 8.87 5.75 9 5.75 m 9 11.25 l 20 11.25 b 20.13 11.25 20.26 11.28 20.38 11.35 20.49 11.42 20.58 11.51 20.65 11.62 20.72 11.74 20.75 11.87 20.75 12 20.75 12.13 20.72 12.26 20.65 12.38 20.58 12.49 20.49 12.58 20.38 12.65 20.26 12.72 20.13 12.75 20 12.75 l 9 12.75 b 8.87 12.75 8.74 12.72 8.62 12.65 8.51 12.58 8.42 12.49 8.35 12.38 8.28 12.26 8.25 12.13 8.25 12 8.25 11.87 8.28 11.74 8.35 11.62 8.42 11.51 8.51 11.42 8.62 11.35 8.74 11.28 8.87 11.25 9 11.25 m 9 16.75 l 20 16.75 b 20.13 16.75 20.26 16.78 20.38 16.85 20.49 16.92 20.58 17.01 20.65 17.12 20.72 17.24 20.75 17.37 20.75 17.5 20.75 17.63 20.72 17.76 20.65 17.88 20.58 17.99 20.49 18.08 20.38 18.15 20.26 18.22 20.13 18.25 20 18.25 l 9 18.25 b 8.87 18.25 8.74 18.22 8.62 18.15 8.51 18.08 8.42 17.99 8.35 17.88 8.28 17.76 8.25 17.63 8.25 17.5 8.25 17.37 8.28 17.24 8.35 17.12 8.42 17.01 8.51 16.92 8.62 16.85 8.74 16.78 8.87 16.75 9 16.75",
    ["menu_check"] = "m 4.53 12.97 b 4.24 12.68 3.76 12.68 3.47 12.97 3.18 13.26 3.18 13.74 3.47 14.03 l 7.97 18.53 b 8.26 18.82 8.74 18.82 9.03 18.53 l 20.03 7.53 b 20.32 7.24 20.32 6.76 20.03 6.47 19.74 6.18 19.26 6.18 18.97 6.47 l 8.5 16.94 4.53 12.97",
    ["menu_chevron"] = "m 8.47 4.22 b 8.38 4.31 8.31 4.43 8.28 4.56 8.24 4.68 8.24 4.82 8.28 4.94 8.31 5.07 8.38 5.19 8.47 5.28 l 15.19 12 8.47 18.72 b 8.39 18.8 8.32 18.9 8.28 19 8.24 19.11 8.22 19.23 8.23 19.34 8.25 19.46 8.28 19.57 8.34 19.66 8.41 19.76 8.49 19.84 8.59 19.91 8.68 19.97 8.79 20 8.91 20.02 9.02 20.03 9.14 20.01 9.25 19.97 9.35 19.93 9.45 19.86 9.53 19.78 l 16.78 12.53 b 16.87 12.44 16.94 12.32 16.97 12.19 17.01 12.07 17.01 11.93 16.97 11.81 16.94 11.68 16.87 11.56 16.78 11.47 l 9.53 4.22 b 9.44 4.13 9.32 4.06 9.19 4.03 9.07 3.99 8.93 3.99 8.81 4.03 8.68 4.06 8.56 4.13 8.47 4.22",
    ["menu_folder"] = "m 3.5 6.25 l 3.5 8 8.13 8 b 8.33 8 8.52 7.92 8.66 7.78 l 10.19 6.25 8.66 4.72 b 8.52 4.58 8.33 4.5 8.13 4.5 l 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 8.13 3 b 8.73 3 9.3 3.24 9.72 3.66 l 11.56 5.5 18.75 5.5 b 20.54 5.5 22 6.96 22 8.75 l 22 17.75 b 22 19.54 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.54 2 17.75 l 2 6.25 m 3.5 9.5 l 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.72 19.5 20.5 18.72 20.5 17.75 l 20.5 8.75 b 20.5 7.78 19.72 7 18.75 7 l 11.56 7 9.72 8.84 b 9.3 9.26 8.73 9.5 8.13 9.5 l 3.5 9.5",
    ["menu_folder_up"] = "m 3.5 6.25 l 3.5 8 8.13 8 b 8.33 8 8.52 7.92 8.66 7.78 l 10.19 6.25 8.66 4.72 b 8.52 4.58 8.33 4.5 8.13 4.5 l 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 8.13 3 b 8.73 3 9.3 3.24 9.72 3.66 l 11.56 5.5 18.75 5.5 b 20.54 5.5 22 6.96 22 8.75 l 22 12.81 b 21.56 12.38 21.05 12.02 20.5 11.73 l 20.5 8.75 b 20.5 7.78 19.72 7 18.75 7 l 11.56 7 9.72 8.84 b 9.3 9.26 8.73 9.5 8.13 9.5 l 3.5 9.5 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 11.31 19.5 b 11.49 20.03 11.73 20.54 12.02 21 l 5.25 21 b 3.46 21 2 19.54 2 17.75 l 2 6.25 m 23 17.5 b 23 20.54 20.54 23 17.5 23 14.46 23 12 20.54 12 17.5 12 14.46 14.46 12 17.5 12 20.54 12 23 14.46 23 17.5 m 17 20.5 b 17 20.78 17.22 21 17.5 21 17.78 21 18 20.78 18 20.5 l 18 15.71 19.65 17.35 b 19.84 17.55 20.16 17.55 20.35 17.35 20.55 17.16 20.55 16.84 20.35 16.65 l 17.85 14.15 b 17.66 13.95 17.34 13.95 17.15 14.15 l 14.65 16.65 b 14.45 16.84 14.45 17.16 14.65 17.35 14.84 17.55 15.16 17.55 15.35 17.35 l 17 15.71 17 20.5",
    ["menu_video"] = "m 2 6.25 b 2 4.46 3.46 3 5.25 3 l 18.75 3 b 20.54 3 22 4.46 22 6.25 l 22 17.75 b 22 19.54 20.54 21 18.75 21 l 5.25 21 b 3.46 21 2 19.54 2 17.75 l 2 6.25 m 5.25 4.5 b 4.28 4.5 3.5 5.28 3.5 6.25 l 3.5 17.75 b 3.5 18.72 4.28 19.5 5.25 19.5 l 18.75 19.5 b 19.72 19.5 20.5 18.72 20.5 17.75 l 20.5 6.25 b 20.5 5.28 19.72 4.5 18.75 4.5 l 5.25 4.5 m 9 9.25 l 9 14.75 b 9 15.51 9.82 15.99 10.48 15.63 l 15.48 12.88 b 16.17 12.5 16.17 11.5 15.48 11.12 l 10.48 8.37 b 9.82 8.01 9 8.49 9 9.25",
    ["menu_more"] = "m 7.5 12 b 7.5 12.31 7.42 12.61 7.27 12.88 7.11 13.14 6.89 13.36 6.62 13.52 6.36 13.67 6.06 13.75 5.75 13.75 5.44 13.75 5.14 13.67 4.88 13.52 4.61 13.36 4.39 13.14 4.23 12.88 4.08 12.61 4 12.31 4 12 4 11.69 4.08 11.39 4.23 11.12 4.39 10.86 4.61 10.64 4.87 10.48 5.14 10.33 5.44 10.25 5.75 10.25 6.06 10.25 6.36 10.33 6.62 10.48 6.89 10.64 7.11 10.86 7.27 11.12 7.42 11.39 7.5 11.69 7.5 12 m 13.75 12 b 13.75 12.31 13.67 12.61 13.52 12.88 13.36 13.14 13.14 13.36 12.88 13.52 12.61 13.67 12.31 13.75 12 13.75 11.69 13.75 11.39 13.67 11.12 13.52 10.86 13.36 10.64 13.14 10.48 12.88 10.33 12.61 10.25 12.31 10.25 12 10.25 11.69 10.33 11.39 10.48 11.12 10.64 10.86 10.86 10.64 11.12 10.48 11.39 10.33 11.69 10.25 12 10.25 12.31 10.25 12.61 10.33 12.88 10.48 13.14 10.64 13.36 10.86 13.52 11.12 13.67 11.39 13.75 11.69 13.75 12 m 20 12 b 20 12.31 19.92 12.61 19.77 12.88 19.61 13.14 19.39 13.36 19.12 13.52 18.86 13.67 18.56 13.75 18.25 13.75 17.94 13.75 17.64 13.67 17.38 13.52 17.11 13.36 16.89 13.14 16.73 12.88 16.58 12.61 16.5 12.31 16.5 12 16.5 11.69 16.58 11.39 16.73 11.12 16.89 10.86 17.11 10.64 17.38 10.48 17.64 10.33 17.94 10.25 18.25 10.25 18.56 10.25 18.86 10.33 19.12 10.48 19.39 10.64 19.61 10.86 19.77 11.12 19.92 11.39 20 11.69 20 12",
    ["window_close"] = "m 4.4 4.55 l 4.47 4.47 b 4.74 4.2 5.15 4.18 5.45 4.4 l 5.53 4.47 12 10.94 18.47 4.47 b 18.76 4.18 19.24 4.18 19.53 4.47 19.82 4.76 19.82 5.24 19.53 5.53 l 13.06 12 19.53 18.47 b 19.8 18.74 19.82 19.15 19.6 19.45 l 19.53 19.53 b 19.26 19.8 18.85 19.82 18.55 19.6 l 18.47 19.53 12 13.06 5.53 19.53 b 5.24 19.82 4.76 19.82 4.47 19.53 4.18 19.24 4.18 18.76 4.47 18.47 l 10.94 12 4.47 5.53 b 4.2 5.26 4.18 4.85 4.4 4.55 l 4.47 4.47 4.4 4.55",
    ["window_maximize"] = "m 5.72 2.86 l 18.38 2.86 b 18.86 2.86 19.33 2.99 19.74 3.23 20.16 3.47 20.5 3.81 20.74 4.22 20.98 4.64 21.1 5.1 21.1 5.58 l 21.1 18.25 b 21.1 18.73 20.98 19.19 20.74 19.61 20.5 20.02 20.16 20.36 19.74 20.6 19.33 20.84 18.86 20.97 18.38 20.97 l 5.72 20.97 b 5.24 20.97 4.77 20.84 4.36 20.6 3.94 20.36 3.6 20.02 3.36 19.61 3.12 19.19 3 18.73 3 18.25 l 3 5.58 b 3 5.1 3.12 4.64 3.36 4.22 3.6 3.81 3.94 3.47 4.36 3.23 4.77 2.99 5.24 2.86 5.72 2.86 m 5.72 4.66 b 5.55 4.66 5.39 4.71 5.25 4.79 5.11 4.87 5 4.99 4.91 5.13 4.83 5.27 4.79 5.43 4.79 5.59 l 4.79 18.25 b 4.79 18.41 4.83 18.57 4.91 18.71 5 18.85 5.11 18.97 5.25 19.05 5.39 19.13 5.55 19.18 5.72 19.18 l 18.38 19.18 b 18.55 19.18 18.71 19.13 18.85 19.05 18.99 18.97 19.1 18.85 19.19 18.71 19.27 18.57 19.31 18.41 19.31 18.25 l 19.31 5.59 b 19.31 5.43 19.27 5.27 19.19 5.13 19.1 4.99 18.99 4.87 18.85 4.79 18.71 4.71 18.55 4.66 18.38 4.66 l 5.72 4.66",
    ["window_minimize"] = "m 3.75 12.5 l 20.25 12.5 b 20.66 12.5 21 12.16 21 11.75 21 11.34 20.66 11 20.25 11 l 3.75 11 b 3.34 11 3 11.34 3 11.75 3 12.16 3.34 12.5 3.75 12.5",
    ["window_unmaximize"] = "m 6.21 3.86 b 6.43 3.25 6.8 2.77 7.31 2.4 7.56 2.22 7.84 2.08 8.14 1.99 8.44 1.9 8.74 1.85 9.05 1.86 l 16.16 1.86 b 17.79 1.86 19.2 2.45 20.39 3.63 21.57 4.81 22.16 6.22 22.16 7.86 l 22.16 14.96 b 22.16 15.61 21.98 16.19 21.61 16.7 21.43 16.96 21.22 17.18 20.97 17.37 20.73 17.55 20.45 17.7 20.16 17.8 l 20.16 7.86 b 20.16 6.78 19.76 5.85 18.96 5.05 18.17 4.26 17.23 3.86 16.16 3.86 l 6.21 3.86 6.21 3.86 m 5.05 5.86 l 15.12 5.86 b 15.94 5.86 16.65 6.16 17.25 6.76 17.86 7.37 18.16 8.08 18.16 8.89 l 18.16 18.97 b 18.16 19.83 17.86 20.55 17.25 21.13 16.97 21.41 16.64 21.63 16.28 21.78 15.91 21.93 15.52 22 15.12 22 l 5.05 22 b 4.19 22 3.47 21.71 2.89 21.13 2.31 20.55 2.02 19.83 2.02 18.97 l 2.02 8.89 b 2.02 8.08 2.31 7.37 2.89 6.76 3.47 6.16 4.19 5.86 5.05 5.86 m 5.05 7.86 b 4.91 7.86 4.77 7.88 4.65 7.94 4.52 7.99 4.4 8.08 4.31 8.18 4.22 8.28 4.15 8.39 4.1 8.51 4.05 8.63 4.02 8.76 4.02 8.89 l 4.02 18.96 b 4.02 19.26 4.12 19.51 4.31 19.71 4.5 19.9 4.75 20 5.05 20 l 15.12 20 b 15.25 19.99 15.38 19.97 15.51 19.92 15.63 19.87 15.74 19.8 15.83 19.71 15.94 19.61 16.02 19.5 16.08 19.37 16.13 19.24 16.16 19.1 16.16 18.96 l 16.16 8.89 b 16.16 8.63 16.05 8.4 15.83 8.18 15.62 7.97 15.38 7.86 15.12 7.86 l 5.05 7.86",
}
local icon_names = {
    ["fluent_fast_forward_filled"] = "fluent_fast_forward_filled",
    ["fluent_fast_rewind_filled"] = "fluent_rewind_filled",
    ["fluent_forward_10_filled"] = "fluent_skip_forward_10_filled",
    ["fluent_forward_30_filled"] = "fluent_skip_forward_30_filled",
    ["fluent_forward_5_filled"] = "fluent_skip_forward_5_filled",
    ["fluent_fullscreen"] = "fluent_arrow_maximize",
    ["fluent_fullscreen_exit"] = "fluent_arrow_minimize",
    ["fluent_info"] = "fluent_info",
    ["fluent_more_vert"] = "fluent_more_vertical",
    ["fluent_no_sound"] = "fluent_speaker_mute",
    ["fluent_pause_filled"] = "fluent_pause_filled",
    ["fluent_photo_camera"] = "fluent_camera",
    ["fluent_pip"] = "fluent_picture_in_picture_enter",
    ["fluent_pip_exit"] = "fluent_pip_exit",
    ["fluent_play_arrow_filled"] = "fluent_play_filled",
    ["fluent_playlist_play"] = "fluent_playlist",
    ["fluent_repeat"] = "fluent_arrow_repeat_all_off",
    ["fluent_repeat_on"] = "fluent_arrow_repeat_all",
    ["fluent_replay_10_filled"] = "fluent_skip_back_10_filled",
    ["fluent_replay_30_filled"] = "fluent_skip_back_30_filled",
    ["fluent_replay_5_filled"] = "fluent_skip_back_5_filled",
    ["fluent_replay_filled"] = "fluent_replay_filled",
    ["fluent_shuffle"] = "fluent_arrow_shuffle_off",
    ["fluent_shuffle_on"] = "fluent_arrow_shuffle",
    ["fluent_skip_back_filled"] = "fluent_skip_back_tab_filled",
    ["fluent_skip_forward_filled"] = "fluent_skip_forward_tab_filled",
    ["fluent_skip_next_filled"] = "fluent_next_filled",
    ["fluent_skip_previous_filled"] = "fluent_previous_filled",
    ["fluent_speed"] = "fluent_top_speed",
    ["fluent_subtitles"] = "fluent_subtitles",
    ["fluent_surround_sound"] = "fluent_audio",
    ["fluent_volume_down"] = "fluent_speaker_1",
    ["fluent_volume_mute"] = "fluent_speaker_0",
    ["fluent_volume_up"] = "fluent_speaker_2",
    ["menu_back"] = "menu_back",
    ["menu_chapters"] = "menu_chapters",
    ["menu_check"] = "menu_check",
    ["menu_chevron"] = "menu_chevron",
    ["menu_folder"] = "menu_folder",
    ["menu_folder_up"] = "menu_folder_up",
    ["menu_video"] = "menu_video",
    ["menu_more"] = "menu_more",
    ["window_close"] = "window_close",
    ["window_maximize"] = "window_maximize",
    ["window_minimize"] = "window_minimize",
    ["window_unmaximize"] = "window_unmaximize",
}

-- Icons are vector drawings, so no icon font has to be installed. A button's content
-- holds a marker (\1name\2) that render_icons() swaps for the drawing at the size
-- given by the button's style (\fs), so hover/press scaling keeps working.
local ICON_FRAME = " m 0 0 l 24 0 24 24 0 24 m 0 0 l 0 24 24 24 24 0" -- invisible 24x24 frame: icons align by their grid
local icon_cache = {}

local function icon_marker(name) return "\1" .. name .. "\2" end

local function icon_path(name)
    local glyph = icon_names[name]
        or icon_names[(name:gsub("_filled$", ""))]
        or icon_names[(name:gsub("^%a+_", ""))]
    return glyph and icon_glyphs[glyph] or nil
end

local function icon_drawing(name, size)
    local key = name .. "@" .. size
    local drawing = icon_cache[key]
    if not drawing then
        local path = icon_path(name)
        if not path then return "" end
        local s = size / 24
        drawing = "{\\p1}" .. (path .. ICON_FRAME):gsub("%-?%d+%.?%d*", function(n)
            return string.format("%.2f", tonumber(n) * s)
        end) .. "{\\p0}"
        icon_cache[key] = drawing
    end
    return drawing
end

-- replace icon markers in a button's text with drawings sized by the style's \fs
local function render_icons(text, style)
    if not text or not text:find("\1", 1, true) then return text end
    local size = tonumber((style or ""):match(".*\\fs([%d%.]+)")) or 24
    return (text:gsub("\1([%w_]+)\2", function(name) return icon_drawing(name, size) end))
end

-- Fluent UI System Icons (mixed: filled transport controls, outline utility icons)
local function build_icons()
    local function f(name) return icon_marker("fluent_" .. name .. "_filled") end
    local function o(name) return icon_marker("fluent_" .. name) end

    return {
        check    = icon_marker("menu_check"),
        more     = icon_marker("menu_more"),
        chevron  = icon_marker("menu_chevron"),
        back     = icon_marker("menu_back"),
        chapters = icon_marker("menu_chapters"),
        window = {
            maximize   = icon_marker("window_maximize"),
            unmaximize = icon_marker("window_unmaximize"),
            minimize   = icon_marker("window_minimize"),
            close      = icon_marker("window_close"),
        },

        play     = f("play_arrow"),
        pause    = f("pause"),
        replay   = f("replay"),
        previous = f("skip_previous"),
        next     = f("skip_next"),
        rewind   = f("fast_rewind"),
        forward  = f("fast_forward"),
        jump = {
            [5]     = { f("replay_5"),   f("forward_5")   },
            [10]    = { f("replay_10"),  f("forward_10")  },
            [30]    = { f("replay_30"),  f("forward_30")  },
            default = { f("skip_back"),  f("skip_forward") },
        },

        audio        = o("surround_sound"),
        subtitle     = o("subtitles"),
        playlist     = o("playlist_play"),
        menu         = o("more_vert"),
        volume_mute  = o("no_sound"),
        volume_quiet = o("volume_mute"),
        volume_low   = o("volume_down"),
        volume_high  = o("volume_up"),

        speed           = o("speed"),
        shuffle_on      = o("shuffle_on"),
        shuffle_off     = o("shuffle"),
        loop_on         = o("repeat_on"),
        loop_off        = o("repeat"),
        screenshot      = o("photo_camera"),
        ontop_on        = o("pip"),
        ontop_off       = o("pip_exit"),
        info            = o("info"),
        fullscreen      = o("fullscreen"),
        fullscreen_exit = o("fullscreen_exit"),
    }
end

local function set_icon_theme()
    icons = build_icons()
end

--- localization
local language = {
    ["default"] = {
        idle = "Drop files or URLs here to play",
        na = "Not available",
        unknown = "Unknown",
        video = "Video",
        audio = "Audio",
        subtitle = "Subtitle",
        no_subs = "No subtitles",
        no_audio = "No audio tracks",
        volume = "Volume",
        muted = "Muted",
        playlist = "Playlist",
        no_playlist = "Playlist empty",
        chapter = "Chapter",
        fullscreen = "Fullscreen",
        fullscreen_exit = "Exit fullscreen",
        ontop = "Pin window",
        ontop_disable = "Unpin window",
        file_loop_enable = "Loop file on",
        file_loop_disable = "Loop file off",
        playlist_loop_enable = "Loop playlist on",
        playlist_loop_disable = "Loop playlist off",
        shuffle = "Shuffle playlist on",
        unshuffle = "Shuffle playlist off",
        speed_control = "Playback speed",
        screenshot = "Screenshot",
        stats_info = "Statistics",
        cache = "Cache",
        buffering = "Buffering",
        zoom_in = "Zoom in",
        zoom_out = "Zoom out",
        download = "Download",
        download_in_progress = "Download in progress",
        downloading = "Downloading",
        downloaded = "Already downloaded",
        menu = "Menu",
        more = "More",
        normal = "Normal",
        loop = "Loop",
        shuffle_menu = "Shuffle",
        keep_on_top = "Keep on top",
        subtitles = "Subtitles",
        chapters = "Chapters",
        audio_output = "Audio output",
        off = "Off",
        track = "Track",
        default_track = "Default",
        forced = "Forced",
        external = "External",
        other_folders = "Other folders",
        browse_folders = "Browse folders",
        up_one_level = "Up one level",
        nothing_here = "Nothing to play here",
        playing = "Playing",
        play = "Play",
        pause = "Pause",
        replay = "Replay",
        quit = "Quit",
    },
}

local bidi = {
    fsi = "\226\129\168",   -- U+2068 first strong isolate
    pdi = "\226\129\169",   -- U+2069 pop directional isolate
}

-- locale JSON file handler
local function get_locale_from_json(path)
    local expand_path = mp.command_native({'expand-path', path})

    local file_info = utils.file_info(expand_path)
    if not file_info or not file_info.is_file then
        return nil
    end

    local json_file = io.open(expand_path, 'r')
    if not json_file then
        return nil
    end

    local json = json_file:read('*all')
    json_file:close()

    local json_table, parse_error = utils.parse_json(json)
    if not json_table then
        mp.msg.error("JSON parse error:" .. parse_error)
    end
    return json_table
end

-- load external locales only when default language is not used
local locale_file_loaded = false
local function load_locale_file()
    if user_opts.language == "default" or locale_file_loaded then return end
    locale_file_loaded = true

    local external = get_locale_from_json("~~/script-opts/modernz-locale.json")
    if external then
        for lang, strings in pairs(external) do
            if lang == "default" then
                -- "default" is reserved
                mp.msg.warn("Locale JSON: 'default' is a reserved language key and cannot be overridden. Skipping.")
            elseif type(strings) == "table" then
                language[lang] = strings

                -- fill in any missing keys with the built-in defaults
                for key, value in pairs(language["default"]) do
                    if strings[key] == nil then
                        strings[key] = value
                    end
                end
            else
                mp.msg.warn("Locale data for language '" .. lang .. "' is not in the correct format.")
            end
        end
    end
end

local locale
local function set_osc_locale()
    locale = language[user_opts.language] or language["default"]
end

local function contains(list, item)
    local t
    if type(list) == "table" then
        t = list
    else
        t = {}
        for str in string.gmatch(list, '([^,]+)') do
            t[#t + 1] = str:match("^%s*(.-)%s*$") -- trim spaces
        end
    end
    for _, v in ipairs(t) do
        if v == item then return true end
    end
    return false
end

local platform = mp.get_property("platform")
local tick_delay = 1 / 60
local UNICODE_MINUS = string.char(0xe2, 0x88, 0x92)  -- UTF-8 for U+2212 MINUS SIGN

local function osc_color_convert(color)
    return color:sub(6,7) .. color:sub(4,5) ..  color:sub(2,3)
end

local osc_styles
local seekbar_height_style
local hover_effects = { size = false, color = false, glow = false, box = false }

-- the UI typeface. Inter's weights are separate families to libass: Medium for body
-- text, SemiBold for titles (text on glass reads best a little heavier)
local ui_font = {}
local function resolve_fonts()
    local f = user_opts.font
    if f == "Inter" then
        ui_font = {regular = "Inter Medium", medium = "Inter Medium", semibold = "Inter SemiBold", medium_b = "\\b0", semibold_b = "\\b0"}
    else
        ui_font = {regular = f, medium = f, semibold = f, medium_b = "\\b0", semibold_b = "\\b1"}
    end
end

local function set_osc_styles()
    resolve_fonts()
    local playpause_size = user_opts.playpause_size
    local midbuttons_size = user_opts.midbuttons_size
    local sidebuttons_size = user_opts.sidebuttons_size

    hover_effects.size  = contains(user_opts.hover_effect, "size")
    hover_effects.color = contains(user_opts.hover_effect, "color")
    hover_effects.glow  = contains(user_opts.hover_effect, "glow")
    hover_effects.box   = contains(user_opts.hover_effect, "box")

    local seekbar_presets = {
        small  = { radius = 1, height = 2 },
        medium = { radius = 2, height = 4 },
        large  = { radius = 3, height = 6 },
        xlarge = { radius = 4, height = 8 }
    }
    seekbar_height_style = seekbar_presets[user_opts.seekbar_height] or seekbar_presets.medium

    osc_styles = {
        window_control = "{\\1c&H" .. osc_color_convert(user_opts.window_controls_color) .. "&\\fs25}",
        window_title = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.window_title_color) .. "&\\3c&H0&\\fs".. user_opts.window_title_font_size .."\\q2\\fn" .. ui_font.regular .. "}",
        title = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.title_color) .. "&\\3c&H0&\\fs".. user_opts.title_font_size .."\\q2\\fn" .. ui_font.regular .. "}",
        chapter_title = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.chapter_title_color) .. "&\\3c&H0&\\fs" .. user_opts.chapter_title_font_size .. "\\q2\\fn" .. ui_font.regular .. "}",
        seekbar_bg = "{\\1c&H" .. osc_color_convert(user_opts.seekbarbg_color) .. "&}",
        seekbar_fg = "{\\blur1\\bord1\\1c&H" .. osc_color_convert(user_opts.seekbarfg_color) .. "&}",
        time = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.time_color) .. "&\\3c&H0&\\fs" .. user_opts.time_font_size .. "\\fn" .. ui_font.regular .. "}",
        cache = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.cache_info_color) .. "&\\3c&H0&\\fs" .. user_opts.cache_info_font_size .. "\\fn" .. ui_font.regular .. "}",
        tooltip = "{\\bord1\\1c&HFFFFFF&\\3c&H0&\\fs" .. user_opts.tooltip_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        tooltip_box = "{\\1c&H" .. osc_color_convert(user_opts.osc_color) .. "&}",
        speed = "{\\bord1\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\3c&H0&\\fs" .. user_opts.speed_font_size .. "\\fn" .. ui_font.regular .. "}",
        volumebar_bg = "{\\1c&H999999&}",
        volumebar_fg = "{\\blur1\\bord1\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&}",
        control_1 = "{\\1c&H" .. osc_color_convert(user_opts.playpause_color) .. "&\\fs" .. playpause_size .. "}",
        control_2 = "{\\1c&H" .. osc_color_convert(user_opts.middle_buttons_color) .. "&\\fs" .. midbuttons_size .. "}",
        control_3 = "{\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs" .. sidebuttons_size .. "}",
        control_mini = "{\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs16}",
        element_down = "{\\1c&H" .. osc_color_convert(user_opts.held_element_color) .. "&" .. string.format("\\fscx%s\\fscy%s", user_opts.button_held_size, user_opts.button_held_size) .. "}",
        element_hover = "{" .. (hover_effects.color and "\\1c&H" .. osc_color_convert(user_opts.hover_effect_color) .. "&" or "") .. (hover_effects.size and string.format("\\fscx%s\\fscy%s", user_opts.button_hover_size, user_opts.button_hover_size) or "") .. "}",
        hover_bg = "{\\1c&H" .. osc_color_convert(user_opts.hover_effect_color) .. "&}",

        -- text on glass: no outline, the glass gives the contrast
        glass_title = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.title_color) .. "&\\fs" .. user_opts.title_font_size .. "\\q2\\fn" .. ui_font.semibold .. ui_font.semibold_b .. "}",
        glass_chapter = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.muted_text_color) .. "&\\fs" .. user_opts.chapter_title_font_size .. "\\q2\\fn" .. ui_font.regular .. "}",
        glass_time = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.time_color) .. "&\\fs" .. user_opts.time_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        glass_text = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs" .. user_opts.speed_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        glass_cache = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.cache_info_color) .. "&\\fs" .. user_opts.cache_info_font_size .. "\\fn" .. ui_font.regular .. "}",
        glass_window_control = "{\\1c&H" .. osc_color_convert(user_opts.window_controls_color) .. "&\\fs16}",
        glass_play = "{\\1c&H" .. osc_color_convert(user_opts.playpause_color) .. "&\\fs30}",
        glass_icon = "{\\1c&H" .. osc_color_convert(user_opts.side_buttons_color) .. "&\\fs22}",
        glass_transport = "{\\1c&H" .. osc_color_convert(user_opts.middle_buttons_color) .. "&\\fs24}",
        glass_time_muted = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.muted_text_color) .. "&\\fs" .. user_opts.time_font_size .. "\\fn" .. ui_font.medium .. ui_font.medium_b .. "}",
        glass_window_title = "{\\bord0\\shad0\\1c&H" .. osc_color_convert(user_opts.window_title_color) .. "&\\fs" .. math.min(user_opts.window_title_font_size, 18) .. "\\q2\\fn" .. ui_font.regular .. "}",
    }
end

-- internal states, do not touch
local state = {
    showtime = nil,                         -- time of last invocation (last mouse move)
    wc_showtime = nil,                      -- time of last invocation for window controls
    wc_anistart = nil,                      -- time when the wc animation started
    wc_anitype = nil,                       -- current type of wc animation
    wc_animation = nil,                     -- current wc animation alpha
    touchtime = nil,                        -- time of last invocation (last touch event)
    touchpoints = {},                       -- current touch points
    osc_visible = false,                    -- osc visibility
    wc_visible = false,                     -- window controls visibility
    anistart = nil,                         -- time when the animation started
    anitype = nil,                          -- current type of animation
    animation = nil,                        -- current animation alpha
    mouse_down_counter = 0,                 -- used for softrepeat
    active_element = nil,                   -- nil = none, 0 = background, 1+ = see elements[]
    active_event_source = nil,              -- the "button" that issued the current event
    tc_left_rem = not user_opts.timecurrent,-- if the left timecode should display current or remaining time
    tc_ms = user_opts.timems,               -- Should the timecodes display their time with milliseconds
    screen_sizeX = nil, screen_sizeY = nil, -- last screen-resolution, to detect resolution changes to issue reINITs
    initREQ = false,                        -- is a re-init request pending?
    marginsREQ = false,                     -- is a margins update pending?
    last_mouseX = nil, last_mouseY = nil,   -- last mouse position, to detect significant mouse movement
    last_touchX = -1, last_touchY = -1,     -- last touch position
    mouse_in_window = false,
    fullscreen = false,
    tick_timer = nil,
    tick_last_time = 0,                     -- when the last tick() was run
    hide_timer = nil,
    demuxer_cache_state = nil,
    idle_active = false,
    audio_track_count = 0,
    sub_track_count = 0,
    playlist_count = 0,
    playlist_pos_1 = 0,
    pause = false,
    volume = 0,
    mute = false,
    osd_dimensions = {w = 0, h = 0, aspect = 0},
    osd_scale_by_window = false,
    file_loaded = false,                    -- flag to detect file load
    enabled = true,
    input_enabled = true,
    showhide_enabled = false,
    windowcontrols_buttons = false,
    windowcontrols_title = false,
    windowcontrols_ontop = false,
    dmx_cache = 0,
    border = true,
    window_maximized = false,
    osd = mp.create_osd_overlay("ass-events"),
    logo_osd = mp.create_osd_overlay("ass-events"),
    keeponpause_active = false,             -- keeponpause bottombar active state
    cursor_hide_flag = nil,                 -- "allow-hide-cursor" when keep_with_cursor=no, so the cursor can autohide over the OSC
    duration = nil,                         -- current file duration
    chapter_list = {},                      -- sorted by time
    chapter = -1,                           -- current chapter index
    visibility_modes = {},                  -- visibility_modes to cycle through
    eof_reached = false,
    ontop = false,
    speed = 1,
    file_loop = false,
    shuffled = false,
    sliderpos = 0,
    playing_and_seeking = false,
    playtime_hour_force_init = false,       -- used to force request_init() once
    persistent_seekbar_element = nil,
    seekbar_element = nil,
    persistent_progress_toggle = user_opts.persistent_progress,
    user_subpos = mp.get_property_number("sub-pos") or 100,
    osc_adjusted_subpos = nil,
    pending_subpos_writes = {},
    title_max_w = nil,
    windowtitle_max_w = nil,
    chapter_title_max_w = nil,
}

local logo_lines = {
    -- White border
    "{\\c&HE5E5E5&\\p6}m 895 10 b 401 10 0 410 0 905 0 1399 401 1800 895 1800 1390 1800 1790 1399 1790 905 1790 410 1390 10 895 10 {\\p0}",
    -- Purple fill
    "{\\c&H682167&\\p6}m 925 42 b 463 42 87 418 87 880 87 1343 463 1718 925 1718 1388 1718 1763 1343 1763 880 1763 418 1388 42 925 42{\\p0}",
    -- Darker fill
    "{\\c&H430142&\\p6}m 1605 828 b 1605 1175 1324 1456 977 1456 631 1456 349 1175 349 828 349 482 631 200 977 200 1324 200 1605 482 1605 828{\\p0}",
    -- White fill
    "{\\c&HDDDBDD&\\p6}m 1296 910 b 1296 1131 1117 1310 897 1310 676 1310 497 1131 497 910 497 689 676 511 897 511 1117 511 1296 689 1296 910{\\p0}",
    -- Triangle
    "{\\c&H691F69&\\p6}m 762 1113 l 762 708 b 881 776 1000 843 1119 911 1000 978 881 1046 762 1113{\\p0}",
}

--
-- Helper functions
--

local function kill_animation(anitype_key, anistart_key, animation_key)
    state[anitype_key]   = nil
    state[anistart_key]  = nil
    state[animation_key] = nil
end

-- overlays known to be off; kept outside the overlay tables, whose fields all go to mpv
local wiped_osds = setmetatable({}, {__mode = "k"})
local function set_osd(osd, res_x, res_y, text, z)
    if osd.res_x == res_x and osd.res_y == res_y and osd.data == text then
        return
    end
    osd.res_x = res_x
    osd.res_y = res_y
    osd.data = text
    osd.z = z
    wiped_osds[osd] = nil
    -- osd:update(), without waiting for mpv to take it in (nothing is read back)
    local cmd = {}
    for k, v in pairs(osd) do cmd[k] = v end
    cmd.name = "osd-overlay"
    cmd.res_x = math.floor(cmd.res_x)
    cmd.res_y = math.floor(cmd.res_y)
    mp.command_native_async(cmd, function() end)
end

local function set_time_styles(timecurrent_changed, timems_changed)
    if timecurrent_changed then
        state.tc_left_rem = not user_opts.timecurrent
    end
    if timems_changed then
        state.tc_ms = user_opts.timems
    end
end

local function observe_cached(property, callback)
    local key = property:gsub("-", "_")
    mp.observe_property(property, "native", function (_, value)
        state[key] = value
        callback()
    end)
end

-- scale factor for translating between real and virtual ASS coordinates
local function get_virt_scale_factor()
    if state.osd_dimensions.w == 0 or state.osd_dimensions.h == 0 then
        return 0, 0
    end
    return osc_param.playresx / state.osd_dimensions.w,
           osc_param.playresy / state.osd_dimensions.h
end

local function recently_touched()
    if state.touchtime == nil then
        return false
    end
    return state.touchtime + 1 >= mp.get_time()
end

-- return mouse position in virtual ASS coordinates (playresx/y)
-- While a frame is drawn, the pointer position and the few playback properties the
-- elements show are read from mpv once and reused: every read waits on mpv's main
-- thread, and hit-testing alone asked for the pointer ~50 times per frame.
local frame_cache = nil
local function frame_mouse_pos()
    if not frame_cache then return mp.get_mouse_pos() end
    if not frame_cache.mouse_x then
        frame_cache.mouse_x, frame_cache.mouse_y = mp.get_mouse_pos()
    end
    return frame_cache.mouse_x, frame_cache.mouse_y
end
local function frame_number(name, default)
    local v
    if frame_cache then
        v = frame_cache[name]
        if v == nil then
            v = mp.get_property_number(name)
            frame_cache[name] = v == nil and false or v
        end
        if v == false then v = nil end
    else
        v = mp.get_property_number(name)
    end
    if v == nil then return default end
    return v
end

local function get_virt_mouse_pos()
    if recently_touched() then
        local sx, sy = get_virt_scale_factor()
        return state.last_touchX * sx, state.last_touchY * sy
    elseif state.mouse_in_window then
        local sx, sy = get_virt_scale_factor()
        local x, y = frame_mouse_pos()
        return x * sx, y * sy
    else
        return -1, -1
    end
end

local function set_virt_mouse_area(x0, y0, x1, y1, name)
    local sx, sy = get_virt_scale_factor()
    mp.set_mouse_area(x0 / sx, y0 / sy, x1 / sx, y1 / sy, name)
end

local function scale_value(x0, x1, y0, y1, val)
    local m = (y1 - y0) / (x1 - x0)
    local b = y0 - (m * x0)
    return (m * val) + b
end

-- returns the position of an object on a one-dimensional axis,
-- from 0..1 (object to the "left") to 1..0 (object to the "right"), taking margin into account.
local function get_align(align, frame, obj, margin)
    return (frame / 2) + (((frame / 2) - margin - (obj / 2)) * align)
end

local text_measure_osd = mp.create_osd_overlay and mp.create_osd_overlay("ass-events") or nil
if text_measure_osd then
    text_measure_osd.hidden = true
    text_measure_osd.compute_bounds = true
end

local text_width_cache = {}

local function estimate_text_width(text, style)
    if text == nil then return 0 end
    text = tostring(text)
    if #text == 0 then return 0 end

    -- replace digits with '0' for consistency
    local measure_text = text:gsub("%d", "0")
    local cache_key = measure_text .. (style or "")
    local width = 0

    if text_width_cache[cache_key] then
        return text_width_cache[cache_key]
    end

    if text_measure_osd and text_measure_osd.update then
        text_measure_osd.res_x = osc_param.playresx
        text_measure_osd.res_y = osc_param.playresy
        text_measure_osd.data = (style or "") .. "{\\an7\\pos(0,0)}" .. measure_text

        local bounds = text_measure_osd:update()
        if bounds and bounds.x1 and bounds.x0 then
            -- subtract side-bearing padding that libass adds even at bord0
            local fs = tonumber((style or ""):match("\\fs(%d+%.?%d*)")) or 16
            local bearing_correction = fs * 0.08 * 2
            width = math.max(0, (bounds.x1 - bounds.x0) - bearing_correction)
        end
    end

    text_width_cache[cache_key] = width
    return width
end

-- width of the time codes element
local function get_time_codes_width()
    local dur = state.duration or 0
    local rt_sec = state.tc_left_rem and frame_number("playtime-remaining", 0) or frame_number("playback-time", 0)

    local function time_fmt(s)
        local has_h = (s >= 3600) or user_opts.time_format == "fixed"
        local base = has_h and (s >= 36000 and "88" or "8") .. ":88:88" or (s >= 600 and "88" or "8") .. ":88"
        return base .. (state.tc_ms and ".888" or "")
    end

    local prefix = state.tc_left_rem and (user_opts.unicodeminus and UNICODE_MINUS or "-") or ""
    local w = estimate_text_width(prefix .. time_fmt(rt_sec) .. " / " .. time_fmt(dur), osc_styles.time)
    return w ~= 0 and w or 120 + (state.tc_ms and 40 or 0)
end

-- returns hitbox spanning coordinates (top left, bottom right corner)
-- according to alignment
local function get_hitbox_coords(x, y, an, w, h)
    local alignments = {
      [1] = function () return x, y-h, x+w, y end,
      [2] = function () return x-(w/2), y-h, x+(w/2), y end,
      [3] = function () return x-w, y-h, x, y end,

      [4] = function () return x, y-(h/2), x+w, y+(h/2) end,
      [5] = function () return x-(w/2), y-(h/2), x+(w/2), y+(h/2) end,
      [6] = function () return x-w, y-(h/2), x, y+(h/2) end,

      [7] = function () return x, y, x+w, y+h end,
      [8] = function () return x-(w/2), y, x+(w/2), y+h end,
      [9] = function () return x-w, y, x, y+h end,
    }

    return alignments[an]()
end

local function get_element_hitbox(element)
    return element.hitbox.x1, element.hitbox.y1, element.hitbox.x2, element.hitbox.y2
end

local function mouse_hit_coords(bX1, bY1, bX2, bY2)
    local mX, mY = get_virt_mouse_pos()
    return (mX >= bX1 and mX <= bX2 and mY >= bY1 and mY <= bY2)
end

local function mouse_hit(element)
    return mouse_hit_coords(get_element_hitbox(element))
end

local function mouse_in_area(names)
    if type(names) == "string" then names = {names} end
    for _, name in ipairs(names) do
        for _, cords in ipairs(osc_param.areas[name] or {}) do
            if mouse_hit_coords(cords.x1, cords.y1, cords.x2, cords.y2) then
                return true
            end
        end
    end
    return false
end

local function limit_range(min, max, val)
    return math.max(min, math.min(max, val))
end

-- translate value into element coordinates
local function get_slider_ele_pos_for(element, val)
    local ele_pos = scale_value(
        element.slider.min.value, element.slider.max.value,
        element.slider.min.ele_pos, element.slider.max.ele_pos,
        val)

    return limit_range(element.slider.min.ele_pos, element.slider.max.ele_pos, ele_pos)
end

-- translates global (mouse) coordinates to value
local function get_slider_value_at(element, glob_pos)
    if element then
        local val = scale_value(
            element.slider.min.glob_pos, element.slider.max.glob_pos,
            element.slider.min.value, element.slider.max.value,
            glob_pos)

        return limit_range(element.slider.min.value, element.slider.max.value, val)
    end
    -- fall back incase of loading errors
    return 0
end

-- get value at current mouse position
local function get_slider_value(element)
    return get_slider_value_at(element, get_virt_mouse_pos())
end

-- multiplies two alpha values, formular can probably be improved
local function mult_alpha(alphaA, alphaB)
    return math.floor(255 - (((1-(alphaA/255)) * (1-(alphaB/255))) * 255) + 0.5)
end

-- ease-out (cubic): fast start, gentle settle; p runs 0..1
local function ease_out(p)
    p = math.max(0, math.min(1, p))
    return 1 - (1 - p) ^ 3
end

-- spring motion (stiffness 300, damping 24): 0 -> 1 over about a third of a second,
-- with a small overshoot that settles
local function spring(t)
    if t <= 0 then return 0 end
    if t >= 0.6 then return 1 end
    local w, z = 17.32, 0.693
    local wd = w * math.sqrt(1 - z * z)
    return 1 - math.exp(-z * w * t) * (math.cos(wd * t) + (z * w / wd) * math.sin(wd * t))
end

local function add_area(name, x1, y1, x2, y2)
    -- create area if needed
    if osc_param.areas[name] == nil then
        osc_param.areas[name] = {}
    end
    table.insert(osc_param.areas[name], {x1=x1, y1=y1, x2=x2, y2=y2})
end

local function ass_append_alpha(ass, alpha, modifier, inverse, anim_override)
    local ar = {}

    for ai, av in ipairs(alpha) do
        av = mult_alpha(av, modifier)
        local animpos = anim_override or state.animation
        if animpos then
            if inverse then
                animpos = 255 - animpos
            end
            av = mult_alpha(av, animpos)
        end
        ar[ai] = av
    end

    ass:append(string.format("{\\1a&H%X&\\2a&H%X&\\3a&H%X&\\4a&H%X&}", ar[1], ar[2], ar[3], ar[4]))
end

-- Glass surfaces: a translucent tinted fill, a thin light edge and a soft shadow.
-- (libass can't blur what is behind the OSD, so the frosted look comes from the
-- tint, the edge and the shadow.)
-- the glass material as the options resolve it (accessibility settings included)
local glass_look = {}
local function update_glass_look()
    glass_look = {
        color = user_opts.glass_color,
        opacity = user_opts.glass_opacity,
        edge = user_opts.glass_border_opacity,
        motion = true,
    }
end

local function opacity_alpha(percent)
    return math.floor(255 - math.max(0, math.min(100, percent)) * 2.55 + 0.5)
end

-- width of the light edge: about one physical pixel at any window size
local function glass_edge_width()
    local osd_h = state.osd_dimensions and state.osd_dimensions.h or 0
    local ppu = (osd_h > 0 and osc_param.playresy > 0) and (osd_h / osc_param.playresy) or 1
    return math.max(0.5, 1.25 / ppu)
end

-- An assdraw stand-in that keeps every event in its own short string and joins them
-- once at the end: assdraw re-copies its whole text on every append and coordinate,
-- which gets slow for a big drawing like an open menu. Same output as assdraw.
local batch_mt = {}
batch_mt.__index = batch_mt
local function batch_new() return setmetatable({n = 0, list = {}}, batch_mt) end
function batch_mt.new_event(b)
    local a = assdraw.ass_new()
    b.n = b.n + 1
    b.list[b.n] = a
    b.cur = a
end
for _, name in ipairs({"append", "pos", "an", "draw_start", "draw_stop", "coord", "move_to", "line_to",
                       "bezier_curve", "rect_cw", "rect_ccw", "round_rect_cw", "round_rect_ccw", "merge"}) do
    batch_mt[name] = function(b, ...)
        if not b.cur then batch_mt.new_event(b) end
        return b.cur[name](b.cur, ...)
    end
end
function batch_mt.text_of(b)
    local t = {}
    for i = 1, b.n do t[i] = b.list[i].text end
    return table.concat(t, "\n")
end

-- draw a rounded surface rectangle for popup menus and tooltips;
-- opts: fade (extra alpha 0-255), fill_alpha, edge_alpha, shadow (false to skip), shadow_alpha, shadow_blur, shadow_y, color
local function glass_rect(ass, x, y, w, h, r, opts)
    opts = opts or {}
    local fade = opts.fade or 0
    local function event(style)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an7\\pos(%f,%f)\\bord0\\shad0%s}", x, y, style))
        ass:draw_start()
    end
    if opts.shadow ~= false and user_opts.glass_shadow then
        event(string.format("\\blur%g\\1c&H000000&\\1a&H%X&", opts.shadow_blur or 10, mult_alpha(opts.shadow_alpha or 0xBC, fade)))
        ass:round_rect_cw(0, opts.shadow_y or 3, w, h + (opts.shadow_y or 3), r)
        ass:draw_stop()
    end
    event(string.format("\\blur0\\1c&H%s&\\1a&H%X&", osc_color_convert(opts.color or glass_look.color),
        mult_alpha(opts.fill_alpha or opacity_alpha(glass_look.opacity), fade)))
    ass:round_rect_cw(0, 0, w, h, r)
    ass:draw_stop()
    local edge = opts.edge_alpha or opacity_alpha(glass_look.edge)
    if edge < 255 then
        local e = glass_edge_width()
        event(string.format("\\blur0\\1c&HFFFFFF&\\1a&H%X&", mult_alpha(edge, fade)))
        ass:round_rect_cw(0, 0, w, h, r)
        ass:round_rect_ccw(e, e, w - e, h - e, math.max(0, r - e))
        ass:draw_stop()
    end
end

-- draw tooltip background box and label
local function draw_tooltip(ass, tx, ty, width, style, label, alpha)
    local fs = user_opts.tooltip_font_size
    local ph, pv = 8, 4
    local box_h = fs + 2 * pv
    local min_w = box_h + 2 * ph
    local box_w = math.max(width + 2 * ph, min_w)
    glass_rect(ass, tx - box_w / 2, ty - fs - pv, box_w, box_h, 4,
        {fill_alpha = 0, shadow_blur = 8, shadow_y = 3, shadow_alpha = 0xC4})
    -- label
    ass:new_event()
    ass:append("{\\rDefault}")
    ass:pos(tx, ty)
    ass:an(2)
    ass:append(style)
    ass:append("{\\bord0\\shad0}")
    if alpha then ass_append_alpha(ass, alpha, 0) end
    ass:append(label)
end

local function ass_draw_cir_cw(ass, x, y, r)
    ass:round_rect_cw(x-r, y-r, x+r, y+r, r)
end

local function ass_draw_rr_h_cw(ass, x0, y0, x1, y1, r1, hexagon, r2)
    if hexagon then
        ass:hexagon_cw(x0, y0, x1, y1, r1, r2)
    else
        ass:round_rect_cw(x0, y0, x1, y1, r1, r2)
    end
end

local function get_hidetimeout()
    if user_opts.visibility == "always" then
        return -1 -- disable autohide
    end
    return user_opts.hidetimeout
end

local function get_touchtimeout()
    if state.touchtime == nil then
        return 0
    end
    return state.touchtime + (get_hidetimeout() / 1000) - mp.get_time()
end

local function cache_enabled()
    return state.demuxer_cache_state and #state.demuxer_cache_state["seekable-ranges"] > 0
end

local function set_margin_offset(prop, offset)
    offset = math.floor(offset + 0.5)
    if offset > 0 then
        if state[prop] == nil then
            state[prop] = mp.get_property_number(prop) or 0
        end
        local target = state[prop] + offset
        if mp.get_property_number(prop) ~= target then
            mp.set_property_number(prop, target)
        end
    elseif state[prop] ~= nil then
        local target = state[prop]
        state[prop] = nil
        if mp.get_property_number(prop) ~= target then
            mp.set_property_number(prop, target)
        end
    end
end

local function set_sub_pos(target)
    if target == nil then return end
    if mp.get_property_number("sub-pos") == target then return end
    state.pending_subpos_writes[#state.pending_subpos_writes + 1] = target
    if #state.pending_subpos_writes > 16 then
        table.remove(state.pending_subpos_writes, 1)
    end
    mp.set_property_number("sub-pos", target)
end

local function reset_margins()
    -- restore subtitle position if it was changed
    if state.osc_adjusted_subpos ~= nil then
        state.osc_adjusted_subpos = nil
        set_sub_pos(state.user_subpos)
    end
    set_margin_offset("osd-margin-y", 0)
end

local function update_margins()
    local use_margins = get_hidetimeout() < 0 or user_opts.dynamic_margins
    local top_vis = state.wc_visible or state.wc_anitype == "in"
    local bottom_vis = state.osc_visible or state.anitype == "in"
    local margins = {
        l = 0,
        r = 0,
        t = (use_margins and top_vis) and osc_param.video_margins.t or 0,
        b = (use_margins and bottom_vis) and osc_param.video_margins.b or 0,
    }

    -- raise amount is based on OSC height
    if user_opts.sub_margins and margins.b > 0 and margins.b < 0.5 and mp.get_property_native("sid") then
        local raise_percent = margins.b * 100
        -- only raise if subs are low enough that they would overlap the OSC
        if state.user_subpos >= (100 - raise_percent) then
            local adjusted = math.floor((1 - margins.b) * 100)
            if adjusted < 0 then adjusted = state.user_subpos end
            state.osc_adjusted_subpos = adjusted
            set_sub_pos(adjusted)
        elseif state.osc_adjusted_subpos ~= nil then
            -- user_subpos is already above the OSC; restore if previously adjusted
            state.osc_adjusted_subpos = nil
            set_sub_pos(state.user_subpos)
        end
    elseif state.osc_adjusted_subpos ~= nil then
        -- always restore original sub position even if sid temporarily changed
        state.osc_adjusted_subpos = nil
        set_sub_pos(state.user_subpos)
    end

    if user_opts.osd_margins then
        local align = mp.get_property("osd-align-y")
        local osd_margin = 0
        if align == "top" and top_vis then
            osd_margin = margins.t
        elseif align == "bottom" and bottom_vis then
            osd_margin = margins.b
        end
        set_margin_offset("osd-margin-y", osd_margin * (osc_param.osd_units_y or osc_param.playresy))
    end

    mp.set_property_native("user-data/osc/margins", margins)
end

local tick

-- Request that tick() is called (which typically re-renders the OSC).
-- The tick is then either executed immediately, or rate-limited if it was
-- called a small time ago.
local function request_tick()
    if state.tick_timer == nil then
        state.tick_timer = mp.add_timeout(0, tick)
    end

    if not state.tick_timer:is_enabled() then
        local now = mp.get_time()
        local timeout = tick_delay - (now - state.tick_last_time)
        if timeout < 0 then
            timeout = 0
        end
        state.tick_timer.timeout = timeout
        state.tick_timer:resume()
    end
end

local function request_init()
    state.initREQ = true
    request_tick()
end

-- Like request_init(), but also request an immediate update
local function request_init_resize()
    request_init()
    -- ensure immediate update
    state.tick_timer:kill()
    state.tick_timer.timeout = 0
    state.tick_timer:resume()
end

local function render_wipe(osd)
    msg.trace("render_wipe()")
    -- already off: skip the round trip to mpv (this runs on every redraw)
    if osd.data == "" and wiped_osds[osd] then return end
    osd.data = "" -- allows set_osd to immediately update on enable
    wiped_osds[osd] = true
    osd:remove()
end

-- Turn a running fade around, continuing from its current alpha instead of
-- restarting (fade-in runs alpha 255 -> 0, fade-out 0 -> 255 over fadeduration).
-- anitype_key is "anitype" or "wc_anitype"; the matching start/alpha keys share its prefix.
local function reverse_fade(anitype_key, new_type)
    local prefix = anitype_key:sub(1, #anitype_key - #"anitype")
    local anistart_key, animation_key = prefix .. "anistart", prefix .. "animation"
    local alpha = state[animation_key]
    if alpha == nil then
        -- the fade hasn't drawn a frame yet: reversing a fade-out means it never left
        state[anitype_key] = (new_type == "out") and "out" or nil
        state[anistart_key] = nil
        return
    end
    -- where the new fade's curve has this alpha (see run_fade)
    local progress = (new_type == "out") and math.sqrt(alpha / 255) or (1 - (alpha / 255) ^ (1 / 3))
    state[anitype_key] = new_type
    state[anistart_key] = mp.get_time() - progress * (user_opts.fadeduration / 1000)
end

local function show_bar(label, showtime_key, visible_key, anitype_key, set_visible)
    -- show when disabled can happen (e.g. mouse_move) due to async/delayed unbinding
    if not state.enabled then return end
    msg.trace("show_" .. label)
    state[showtime_key] = mp.get_time()
    if user_opts.fadeduration <= 0 then
        set_visible(true)
    elseif user_opts.fadein then
        if state[anitype_key] == "out" then
            -- the bar is still flagged visible while fading out, so turn the fade
            -- around here, otherwise it completes and hides the bar right after
            -- this show (e.g. pausing mid fade-out with keeponpause)
            reverse_fade(anitype_key, "in")
            request_tick()
        elseif not state[visible_key] then
            state[anitype_key] = "in"
            update_margins()
            request_tick()
        end
    else
        set_visible(true)
        state[anitype_key] = nil
    end
end

local function hide_bar(label, visible_key, anitype_key, set_visible)
    msg.trace("hide_" .. label)
    if not state.enabled then
        -- typically hide happens at render() from tick(), but now tick() is
        -- no-op and won't render again to remove the osc, so do that manually.
        state[visible_key] = false
        render_wipe(state.osd)
    elseif user_opts.fadeduration > 0 then
        if state[visible_key] then
            if state[anitype_key] == "in" then
                -- hiding during a fade-in: fade out from the current alpha rather
                -- than reusing the fade-in start time (which cut the fade-out short)
                reverse_fade(anitype_key, "out")
            elseif state[anitype_key] ~= "out" then
                state[anitype_key] = "out"
            end
            request_tick()
        end
    else
        set_visible(false)
    end
end

local function update_tracklist(_, track_list)
    state.audio_track_count = 0
    state.sub_track_count = 0

    for _, track in pairs(track_list) do
        if track.type == "audio" then
            state.audio_track_count = state.audio_track_count + 1
        elseif track.type == "sub" then
            state.sub_track_count = state.sub_track_count + 1
        end
    end

    request_init()
end

-- convert slider_pos to logarithmic depending on volume_control user_opts
local function set_volume(slider_pos)
    local volume = slider_pos
    if user_opts.volume_control_type == "logarithmic" then
        volume = slider_pos^2 / 100
    end
    return math.floor(volume)
end

-- WindowControl helpers
local function window_controls_buttons_active()
    local val = user_opts.window_top_bar
    if val == "auto" or val == "yes" then
        -- Top bar stays active for the media title, while caption buttons show when borderless/fullscreen
        return not state.border or not state.title_bar or (state.fullscreen and platform ~= "darwin")
    else
        return false
    end
end

local function window_controls_enabled()
    local val = user_opts.window_top_bar
    if val == "auto" then
        return not state.border or not state.title_bar or (state.fullscreen and platform ~= "darwin")
    else
        return val ~= "no"
    end
end

--
-- Element Management
--
local elements = {}

local function prepare_elements()
    -- remove elements without layout or invisible
    local elements2 = {}
    for _, element in pairs(elements) do
        if element.layout ~= nil and element.visible then
            table.insert(elements2, element)
        end
    end
    elements = elements2

    local function elem_compare (a, b)
        return a.layout.layer < b.layout.layer
    end

    table.sort(elements, elem_compare)

    for _,element in pairs(elements) do

        local elem_geo = element.layout.geometry

        -- Calculate title and chapter hitbox
        local hitbox_w = elem_geo.w

        if (element.name == "title" or element.name == "chapter_title") and type(element.content) == "function" then
            local width = estimate_text_width(element.content(), osc_styles[element.name])
            if width > 0 then hitbox_w = math.min(width, hitbox_w) end
        end

        -- Calculate the hitbox
        local hitbox_h = elem_geo.h + ((element.name == "volumebar" or element.name == "zoom_control") and 14 or 0)
        local bX1, bY1, bX2, bY2 = get_hitbox_coords(elem_geo.x, elem_geo.y, elem_geo.an, hitbox_w, hitbox_h)
        element.hitbox = {x1 = bX1, y1 = bY1, x2 = bX2, y2 = bY2}

        local style_ass = assdraw.ass_new()

        -- prepare static elements
        style_ass:append("{}") -- hack to troll new_event into inserting a \n
        style_ass:new_event()
        style_ass:pos(elem_geo.x, elem_geo.y)
        style_ass:an(elem_geo.an)
        style_ass:append(element.layout.style)

        element.style_ass = style_ass

        local static_ass = assdraw.ass_new()

        if element.type == "box" then
            --draw box
            local box = element.layout.box
            static_ass:draw_start()
            ass_draw_rr_h_cw(static_ass, 0, 0, elem_geo.w, elem_geo.h, box.radius, box.hexagon)
            if box.ring then
                -- only an outline of this width (glass edges)
                static_ass:round_rect_ccw(box.ring, box.ring, elem_geo.w - box.ring, elem_geo.h - box.ring, math.max(0, box.radius - box.ring))
            end
            static_ass:draw_stop()

        elseif element.type == "slider" then
            --draw static slider parts
            local slider_lo = element.layout.slider
            -- calculate positions of min and max points
            element.slider.min.ele_pos = user_opts.seek_handle_size > 0 and (user_opts.seek_handle_size * elem_geo.h / 2) or slider_lo.border
            element.slider.max.ele_pos = elem_geo.w - element.slider.min.ele_pos
            element.slider.min.glob_pos = element.hitbox.x1 + element.slider.min.ele_pos
            element.slider.max.glob_pos = element.hitbox.x1 + element.slider.max.ele_pos

            static_ass:draw_start()
            -- a hack which prepares the whole slider area to allow center placements such like an=5
            static_ass:rect_cw(0, 0, elem_geo.w, elem_geo.h)
            static_ass:rect_ccw(0, 0, elem_geo.w, elem_geo.h)
            -- marker nibbles are drawn dynamically in draw_seekbar_nibbles()
        end

        element.static_ass = static_ass

        -- if the element is supposed to be disabled,
        -- style it accordingly and kill the eventresponders
        if not element.enabled then
            if element.name ~= "seekbar" then
                element.layout.alpha[1] = 215
            end
            -- keep these to display tooltips
            if not (element.name == "sub_track" or element.name == "audio_track" or element.name == "playlist") then
                element.eventresponder = nil
            end
        end

        -- gray out the element if it is toggled off
        if element.off then
            element.layout.alpha[1] = 100
        end
    end
end

--
-- Element Rendering
--

-- returns nil or a chapter element from the native property chapter-list
local function get_chapter(possec)
    local cl = state.chapter_list  -- sorted, get latest before possec, if any

    for n=#cl,1,-1 do
        if possec >= cl[n].time then
            return cl[n]
        end
    end
end

-- Computes handle position and radius without drawing
-- Returns handle position, radius, and whether the handle is active (hovered or dragged)
local function get_seekbar_handle_pos(element)
    local pos = element.slider.posF()
    if not pos then return 0, 0, false end

    local elem_geo = element.layout.geometry
    local handle_radius = user_opts.seek_handle_size * elem_geo.h / 2
    local handle_x = get_slider_ele_pos_for(element, pos)
    local center_y = elem_geo.h / 2

    local mouse_over_handle = mouse_hit_coords(
        element.hitbox.x1 + handle_x - handle_radius,
        element.hitbox.y1 + center_y - handle_radius,
        element.hitbox.x1 + handle_x + handle_radius,
        element.hitbox.y1 + center_y + handle_radius
    ) and element.enabled

    local is_active = mouse_over_handle or element.state.handle_drag

    if handle_radius > 0 then
        if is_active then
            handle_radius = handle_radius * (user_opts.slider_hover_size / 100)
            handle_x = limit_range(handle_radius, elem_geo.w - handle_radius, handle_x)
        end
        -- on glass the sliders are thumbless at rest, like a progress bar: the knob grows
        -- in while the pointer is on the slider or drags it
        if state.glass_ui then
            local st = element.state
            local want = (mouse_hit(element) or st.handle_drag) and 1 or 0
            local now = mp.get_time()
            if st.knob == nil or not glass_look.motion then
                st.knob = want
            elseif st.knob ~= want then
                local step = (now - st.knob_t) / 0.15
                st.knob = want > st.knob and math.min(1, st.knob + step) or math.max(0, st.knob - step)
                request_tick()
            end
            st.knob_t = now
            handle_radius = handle_radius * ease_out(st.knob)
        end
        return handle_x, handle_radius, is_active
    end

    return handle_x, 0, false
end

-- Prepares elem_ass for a new draw layer with the given color
local function begin_draw_layer(element, elem_ass, color, anim_override)
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    ass_append_alpha(elem_ass, element.layout.alpha, 0, nil, anim_override)
    elem_ass:append("{\\blur0\\bord0\\1c&H" .. osc_color_convert(color) .. "&}")
    elem_ass:merge(element.static_ass)
end

-- Draws a handle on the seekbar using precomputed position and radius
local function draw_seekbar_handle(element, elem_ass, handle_x, handle_radius, anim_override, is_active)
    if handle_radius <= 0 then return end

    local center_y = element.layout.geometry.h / 2
    local slider_lo = element.layout.slider

    local fill_color = slider_lo.handle_color or user_opts.side_buttons_color
    local border_color = slider_lo.handle_border
    local border_thickness = is_active and user_opts.seek_handle_border_hover_size or user_opts.seek_handle_border_size
    local has_border = border_color and border_color ~= "" and border_thickness > 0

    if has_border then
        -- inner_radius is how far the fill circle extends inward from the outer edge
        local inner_radius = handle_radius * (1 - border_thickness)
        -- full circle in border color, then smaller circle in fill color on top
        begin_draw_layer(element, elem_ass, border_color, anim_override)
        ass_draw_cir_cw(elem_ass, handle_x, center_y, handle_radius)
        begin_draw_layer(element, elem_ass, fill_color, anim_override)
        ass_draw_cir_cw(elem_ass, handle_x, center_y, inner_radius)
    else
        -- no border configured, just draw a single solid circle
        begin_draw_layer(element, elem_ass, fill_color, anim_override)
        ass_draw_cir_cw(elem_ass, handle_x, center_y, handle_radius)
    end
end

-- Whether chapter marker n (in percent) should be drawn on the seekbar.
-- The first chapter normally starts at the beginning of the file, where a marker is
-- meaningless, so it is skipped; a first chapter that starts later still gets one.
local function is_drawn_marker(n, marker)
    if n > 1 then return true end
    local duration = state.duration or 0
    return duration > 0 and (marker / 100 * duration) >= 1
end

-- Collects and sorts pixel-space cut positions for gap-style chapter markers, skipping a first marker at the start
local function collect_gap_cuts(element)
    local cuts = {}
    if element.slider.markerF then
        for n, marker in ipairs(element.slider.markerF()) do
            if is_drawn_marker(n, marker) and marker >= element.slider.min.value and marker <= element.slider.max.value then
                cuts[#cuts + 1] = get_slider_ele_pos_for(element, marker)
            end
        end
        table.sort(cuts)
    end
    return cuts
end

-- Draws bar segments split around chapter gaps, stopping at x_max (bar_w for bg, xp for fg).
local function draw_gap_segments(elem_ass, element, gap_half, x_max, slider_lo, elem_geo, radius)
    gap_half = gap_half or 1.5
    local cuts = collect_gap_cuts(element)
    -- clamp x_max back to the nearest gap boundary if it falls inside a gap
    for _, cut in ipairs(cuts) do
        if x_max > cut - gap_half and x_max < cut + gap_half then
            x_max = cut - gap_half
            break
        end
    end
    local seg_start = 0
    for _, cut in ipairs(cuts) do
        if cut >= x_max then break end
        local seg_end = cut - gap_half
        if seg_end > seg_start then
            elem_ass:round_rect_cw(seg_start, slider_lo.gap, seg_end, elem_geo.h - slider_lo.gap,
                (seg_start == 0) and radius or 0, 0)
        end
        seg_start = cut + gap_half
    end
    if x_max > seg_start then
        elem_ass:round_rect_cw(seg_start, slider_lo.gap, x_max, elem_geo.h - slider_lo.gap,
            (seg_start == 0) and radius or 0, (x_max == elem_geo.w) and radius or 0)
    end
end

-- Draws seekbar ranges according to user_opts
local function draw_seekbar_ranges(element, elem_ass, xp, rh, override_alpha, inverse)
    local handle = xp and rh and rh > 0
    xp = xp or 0
    rh = rh or 0
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local seekRanges = element.slider.seekRangesF()
    if not seekRanges then return end
    elem_ass:draw_stop()
    elem_ass:merge(element.style_ass)
    ass_append_alpha(elem_ass, element.layout.alpha, override_alpha or user_opts.seekrangealpha, inverse)
    elem_ass:append("{\\1c&H" .. osc_color_convert(user_opts.seekbar_cache_color) .. "&}")
    elem_ass:merge(element.static_ass)

    local radius = slider_lo.radius
    local gap_half = 1.5
    local cuts = (slider_lo.nibbles_style == "gap" and element.name == "seekbar") and collect_gap_cuts(element) or {}

    for _, range in pairs(seekRanges) do
        local pstart = math.max(xp, get_slider_ele_pos_for(element, range["start"]) - slider_lo.gap)
        local pend = math.min(elem_geo.w, get_slider_ele_pos_for(element, range["end"]) + slider_lo.gap)

        -- round edge only when cache range reaches start/end
        local r_left = pstart < element.slider.min.ele_pos and radius or 0
        local r_right = pend > element.slider.max.ele_pos and radius or 0

        -- split around chapter gaps then around the handle
        local seg_start = pstart
        for _, cut in ipairs(cuts) do
            local gap_l, gap_r = cut - gap_half, cut + gap_half
            if gap_r > pstart and gap_l < pend then
                local sl, sr = seg_start, math.min(gap_l, pend)
                if handle and (sl < xp + rh and sr > xp - rh) then
                    if sl < xp - rh then elem_ass:round_rect_cw(sl, slider_lo.gap, xp - rh, elem_geo.h - slider_lo.gap, sl == pstart and r_left or 0, 0) end
                    if xp + rh < sr  then elem_ass:round_rect_cw(xp + rh, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, 0, 0) end
                elseif sr > sl then
                    elem_ass:round_rect_cw(sl, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, sl == pstart and r_left or 0, 0)
                end
                seg_start = math.max(gap_r, pstart)
            end
        end
        local sl, sr = seg_start, pend
        local rl = (sl == pstart) and r_left or 0
        if handle and (sl < xp + rh and sr > xp - rh) then
            if sl < xp - rh then elem_ass:round_rect_cw(sl, slider_lo.gap, xp - rh, elem_geo.h - slider_lo.gap, rl, 0) end
            if xp + rh < sr  then elem_ass:round_rect_cw(xp + rh, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, 0, r_right) end
        else
            if sr > sl then elem_ass:round_rect_cw(sl, slider_lo.gap, sr, elem_geo.h - slider_lo.gap, rl, r_right) end
        end
    end
end

-- show visual indicator in seek ranges for ab loop
local function draw_ab_loop_range(element, elem_ass)
    if element.name ~= "seekbar" then return end
    local duration = state.duration
    if not duration or duration <= 0 then return end
    local ab_a = frame_number("ab-loop-a")
    if not ab_a then return end
    local ab_b = frame_number("ab-loop-b")
    -- with only A set, show the pending range up to the end of the file;
    -- if B is placed before A, mpv loops as if the points were given in order
    local loop_start = ab_a
    local loop_end = ab_b or duration
    if loop_start > loop_end then
        loop_start, loop_end = loop_end, loop_start
    end
    loop_start = math.max(0, math.min(duration, loop_start))
    loop_end = math.max(0, math.min(duration, loop_end))
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local ax = get_slider_ele_pos_for(element, loop_start / duration * 100)
    local bx = get_slider_ele_pos_for(element, loop_end / duration * 100)
    if ax >= bx then return end
    begin_draw_layer(element, elem_ass, user_opts.ab_loop_color)
    elem_ass:rect_cw(ax, slider_lo.gap, bx, elem_geo.h - slider_lo.gap)
end

local function draw_seekbar_nibbles(element, elem_ass)
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry

    if element.slider.markerF == nil or slider_lo.gap <= 0 then
        return
    end

    if slider_lo.nibbles_style == "gap" and element.name == "seekbar" then
        local radius = slider_lo.radius
        local bg_alpha = 128
        elem_ass:draw_stop()
        elem_ass:merge(element.style_ass)
        ass_append_alpha(elem_ass, element.layout.alpha, bg_alpha)
        elem_ass:append("{\\blur0\\bord0\\1c&H" .. osc_color_convert(user_opts.seekbarbg_color) .. "&}")
        elem_ass:merge(element.static_ass)
        draw_gap_segments(elem_ass, element, 1.5, elem_geo.w, slider_lo, elem_geo, radius)
        return
    end

    local markers = element.slider.markerF()

    if #markers == 0 then return end
    local current_chapter = state.chapter or -1

    -- draw a single nibble at position s
    local function draw_nibble(ass, s)
        if slider_lo.gap >= 5 then
            local bar_h = 3
            if slider_lo.nibbles_top then
                if slider_lo.nibbles_style == "triangle" then
                    ass:move_to(s - 3, slider_lo.gap - 5)
                    ass:line_to(s + 3, slider_lo.gap - 5)
                    ass:line_to(s, slider_lo.gap - 1)
                elseif slider_lo.nibbles_style == "bar" then
                    ass:rect_cw(s - 1, slider_lo.gap - bar_h, s + 1, slider_lo.gap)
                else
                    ass:rect_cw(s - 1, slider_lo.gap - bar_h, s + 1, elem_geo.h - slider_lo.gap)
                end
            end
            if slider_lo.nibbles_bottom then
                if slider_lo.nibbles_style == "triangle" then
                    ass:move_to(s - 3, elem_geo.h - slider_lo.gap + 5)
                    ass:line_to(s, elem_geo.h - slider_lo.gap + 1)
                    ass:line_to(s + 3, elem_geo.h - slider_lo.gap + 5)
                elseif slider_lo.nibbles_style == "bar" then
                    ass:rect_cw(s - 1, elem_geo.h - slider_lo.gap, s + 1, elem_geo.h - slider_lo.gap + bar_h)
                else
                    ass:rect_cw(s - 1, slider_lo.gap, s + 1, elem_geo.h - slider_lo.gap + bar_h)
                end
            end
        else
            if slider_lo.nibbles_top then
                ass:rect_cw(s - 1, 0, s + 1, slider_lo.gap)
            end
            if slider_lo.nibbles_bottom then
                ass:rect_cw(s - 1, elem_geo.h - slider_lo.gap, s + 1, elem_geo.h)
            end
        end
    end

    -- draw non-current chapter nibbles
    local has_non_current = false
    for n, marker in ipairs(markers) do
        if is_drawn_marker(n, marker) and (n - 1) ~= current_chapter and marker >= element.slider.min.value and marker <= element.slider.max.value then
            if not has_non_current then
                begin_draw_layer(element, elem_ass, user_opts.nibble_color)
                has_non_current = true
            end
            draw_nibble(elem_ass, get_slider_ele_pos_for(element, marker))
        end
    end

    -- draw current chapter nibble on top
    if current_chapter >= 0 and current_chapter < #markers then
        local marker = markers[current_chapter + 1]
        if is_drawn_marker(current_chapter + 1, marker) and marker >= element.slider.min.value and marker <= element.slider.max.value then
            begin_draw_layer(element, elem_ass, user_opts.nibble_current_color)
            draw_nibble(elem_ass, get_slider_ele_pos_for(element, marker))
        end
    end
end

-- Draw seekbar progress more accurately
local function draw_seekbar_progress(element, elem_ass)
    local pos = element.slider.posF()
    if not pos then
        return
    end
    local xp = get_slider_ele_pos_for(element, pos)
    local slider_lo = element.layout.slider
    local elem_geo = element.layout.geometry
    local radius = slider_lo.radius

    if slider_lo.nibbles_style == "gap" and element.name == "seekbar" then
        draw_gap_segments(elem_ass, element, 1.5, xp, slider_lo, elem_geo, radius)
    else
        elem_ass:round_rect_cw(0, slider_lo.gap, xp, elem_geo.h - slider_lo.gap, radius)
    end
end

local function render_elements(master_ass, osc_vis, wc_vis)
    -- each element is drawn on its own and all are joined once at the end: assdraw
    -- copies its whole text on every append, which adds up on a long text
    local parts = {}
    local function render_element(n)
        local element = elements[n]

        -- skip elements whose group is not currently visible
        local is_top = element.layout.group == "top"
        if (is_top and not wc_vis) or (not is_top and not osc_vis) then return end

        -- use wc animation for top group elements
        -- use 0 to block fallback to state.animation when wc has no active animation
        local anim_override = nil
        if is_top then
            anim_override = state.wc_animation or 0
        end

        local style_ass = assdraw.ass_new()
        style_ass:merge(element.style_ass)
        ass_append_alpha(style_ass, element.layout.alpha, 0, nil, anim_override)

        if element.eventresponder and (state.active_element == n) then
            -- run render event functions
            if element.eventresponder.render ~= nil then
                element.eventresponder.render(element)
            end
            if mouse_hit(element) then
                -- mouse down styling
                if element.styledown then
                    local down_style = osc_styles.element_down
                    if element.name == "title" or element.name == "chapter_title" or element.name == "time_codes" or element.name == "speed" or element.name == "cache_info" or element.name == "time_pos" or element.name == "time_end" then
                        down_style = down_style:gsub("\\fscx%d+\\fscy%d+", "")
                    end
                    style_ass:append(down_style)
                end
                if element.softrepeat and state.mouse_down_counter >= 15 and state.mouse_down_counter % 5 == 0 then
                    element.eventresponder[state.active_event_source.."_down"](element)
                end
                state.mouse_down_counter = state.mouse_down_counter + 1
            end
        end

        local elem_ass = assdraw.ass_new()

        -- Hover background box
        if element.type == "button" and hover_effects.box
            and element.name ~= "title"
            and element.name ~= "chapter_title"
            and element.name ~= "time_codes"
            and element.name ~= "time_pos"
            and element.name ~= "time_end"
            and element.name ~= "cache_info" then
            local is_clickable = element.eventresponder and (
                element.eventresponder["mbtn_left_down"] ~= nil or
                element.eventresponder["mbtn_left_up"] ~= nil
            )
            local hb = element.hover_box
            local hovering = (hb and mouse_hit_coords(hb.x1, hb.y1, hb.x2, hb.y2) or mouse_hit(element)) and is_clickable and element.enabled
            -- on glass the highlight springs open from the middle of the button, swells a
            -- touch while held, and fades away when the pointer leaves
            local now = mp.get_time()
            local grow, fade_in = 1, 0
            if state.glass_ui then
                if hovering then
                    element.state.hover_t = element.state.hover_t or now
                    element.state.hover_out = nil
                    local t = now - element.state.hover_t
                    if glass_look.motion then
                        grow = 0.9 + 0.1 * spring(t) + (state.mouse_down_counter > 0 and 0.04 or 0)
                        if t < 0.6 then request_tick() end
                    end
                    fade_in = math.floor(255 * (1 - ease_out(t / 0.1)) + 0.5)
                    if t < 0.1 then request_tick() end
                elseif element.state.hover_t then
                    element.state.hover_t = nil
                    element.state.hover_out = now
                end
                local out = element.state.hover_out
                if out then
                    local p = (now - out) / 0.14
                    if p >= 1 or not is_clickable or not element.enabled then
                        element.state.hover_out = nil
                    else
                        fade_in = math.floor(255 * p * p + 0.5)
                        request_tick()
                    end
                end
            end
            if hovering or element.state.hover_out then
                local hx1, hy1, hx2, hy2
                if hb then hx1, hy1, hx2, hy2 = hb.x1, hb.y1, hb.x2, hb.y2
                else hx1, hy1, hx2, hy2 = get_element_hitbox(element) end
                local pad = element.hover_pad ~= nil and element.hover_pad or 6
                local held = hovering and state.mouse_down_counter > 0
                local hover_base_alpha = held and (255 - math.floor(math.max(0, math.min(100, user_opts.button_held_box_alpha)) * 2.55)) or (element.hover_alpha or 0xE6)
                local hover_radius = element.hover_radius ~= nil and element.hover_radius or 4
                local mx_, my_ = (hx1 + hx2) / 2, (hy1 + hy2) / 2
                local hw, hh = (hx2 - hx1) / 2 + pad, (hy2 - hy1) / 2 + pad
                hw, hh = hw * grow, hh * grow
                elem_ass:append("{}")
                elem_ass:new_event()
                elem_ass:pos(0, 0)
                elem_ass:an(7)
                ass_append_alpha(elem_ass, {[1] = mult_alpha(hover_base_alpha, fade_in), [2] = 255, [3] = 255, [4] = 255}, element.layout.alpha[1], nil, anim_override)
                local hover_style = element.hover_color
                    and "{\\blur0\\bord0\\1c&H" .. osc_color_convert(element.hover_color) .. "&}"
                    or osc_styles.hover_bg
                elem_ass:append(hover_style)
                elem_ass:draw_start()
                elem_ass:round_rect_cw(mx_ - hw, my_ - hh, mx_ + hw, my_ + hh, math.min(hover_radius * grow, hw, hh))
                elem_ass:draw_stop()
            end
        end

        elem_ass:merge(style_ass)

        if element.type ~= "button" then
            elem_ass:merge(element.static_ass)
        end

        if element.type == "slider" then
            if element.name ~= "persistent_seekbar" then
                local slider_lo = element.layout.slider
                local elem_geo = element.layout.geometry
                local s_min = element.slider.min.value
                local s_max = element.slider.max.value

                draw_seekbar_nibbles(element, elem_ass)

                -- reset context so handle/progress render on top of nibbles
                elem_ass:draw_stop()
                elem_ass:merge(element.style_ass)
                ass_append_alpha(elem_ass, element.layout.alpha, 0, nil, anim_override)
                elem_ass:merge(element.static_ass)

                local handle_x, handle_radius, is_active = get_seekbar_handle_pos(element) -- get handle position/radius
                draw_seekbar_progress(element, elem_ass)
                draw_seekbar_ranges(element, elem_ass, handle_x, handle_radius)
                draw_ab_loop_range(element, elem_ass)
                draw_seekbar_handle(element, elem_ass, handle_x, handle_radius, anim_override, is_active) -- draw handle on top of progress

                elem_ass:draw_stop()

                if element.slider and element.slider.tooltipF ~= nil and element.enabled then
                    local force_seek_tooltip = user_opts.force_seek_tooltip
                        and element.name == "seekbar"
                        and element.eventresponder["mbtn_left_down"]
                        and element.state.mbtnleft
                        and state.mouse_down_counter > 0
                        and state.playing_and_seeking

                    local volume_dragging = element.name == "volumebar"
                        and element.state.mbtnleft
                        and state.mouse_down_counter > 0

                    local show_slider_tooltip = (element.name == "volumebar") and volume_dragging
                        or (element.name ~= "volumebar" and (mouse_hit(element) or force_seek_tooltip))

                    if show_slider_tooltip then
                        local sliderpos = get_slider_value(element)
                        local tooltiplabel = element.slider.tooltipF(sliderpos)
                        local an = slider_lo.tooltip_an
                        local ty
                        if volume_dragging then
                            -- position directly above the volume slider thumb
                            ty = element.hitbox.y1 + elem_geo.h / 2 - handle_radius - 12
                        elseif an == 2 then
                            local seekbar = state.seekbar_element
                            local ref_el = (element.name == "volumebar" and seekbar and seekbar.hitbox) and seekbar or element
                            local image_mode_offset = (ref_el == element) and 10 or 0
                            local anchor_offset = (ref_el == element) and (elem_geo.h / 2) or 0
                            ty = ref_el.hitbox.y1 + anchor_offset - user_opts.tooltip_height_offset - image_mode_offset
                        else
                            ty = element.hitbox.y1 + elem_geo.h / 2 - user_opts.tooltip_height_offset
                        end
                        -- floating panel: tooltips sit just above the panel (except volume thumb tooltip which follows its handle)
                        if not volume_dragging and an == 2 and state.tooltip_y then ty = state.tooltip_y end

                        local tx = volume_dragging and (element.hitbox.x1 + handle_x) or get_virt_mouse_pos()
                        local osd_w = frame_number("osd-width")
                        local r_w, r_h = get_virt_scale_factor()

                        local tooltip_width = estimate_text_width(tooltiplabel, slider_lo.tooltip_style)

                        local chapter_text = nil
                        local chapter_width = 0

                        if osd_w and r_w > 0 then
                            -- Only attempt to fetch and measure chapter logic if this is the seekbar
                            if element.name == "seekbar" and user_opts.chapter_fmt ~= "no" then
                                local dur = state.duration or 0
                                if dur > 0 then
                                    local ch = get_chapter(sliderpos * dur / 100)
                                    if ch and ch.title and ch.title ~= "" then
                                        chapter_text = string.format(user_opts.chapter_fmt, ch.title)
                                        chapter_width = estimate_text_width(chapter_text, slider_lo.tooltip_style)
                                    end
                                end
                            end

                            -- Clamping layer ensures horizontal boundaries are strictly respected
                            if slider_lo.adjust_tooltip then
                                local max_text_width = math.max(tooltip_width, chapter_width)
                                local margin = 10 * r_w
                                local half_width = max_text_width / 2
                                local min_x = margin + half_width
                                local max_x = osc_param.playresx - margin - half_width
                                tx = math.min(max_x, math.max(min_x, tx))
                            end
                        end

                        if element.name == "seekbar" then
                            state.sliderpos = sliderpos
                        end

                        local tooltip_fs = user_opts.tooltip_font_size
                        local pad_v = 3
                        local gap = 5

                        -- Anchor above tooltip: ty (baseline) - fs (height) - pad_v (tooltip padding) - gap
                        local current_y = ty - tooltip_fs - pad_v - gap

                        if chapter_text and r_w > 0 then
                            local chapter_y = current_y - pad_v
                            draw_tooltip(elem_ass, tx, chapter_y, chapter_width, slider_lo.tooltip_style, chapter_text, slider_lo.alpha)
                        end

                        draw_tooltip(elem_ass, tx, ty, tooltip_width, slider_lo.tooltip_style, tooltiplabel, slider_lo.alpha)
                    end
                end
            end
        elseif element.type == "button" then
            local buttontext
            if type(element.content) == "function" then
                buttontext = element.content() -- function objects
            elseif element.content ~= nil then
                buttontext = element.content -- text objects
            end
            buttontext = render_icons(buttontext, element.layout.style)
            -- glass: the hovered icon lifts a little toward the pointer
            if state.glass_ui and glass_look.motion and state.mouse_down_counter == 0 then
                local lift = 0
                if element.state.hover_t then
                    lift = 6 * spring(mp.get_time() - element.state.hover_t)
                elseif element.state.hover_out then
                    lift = 6 * (1 - ease_out((mp.get_time() - element.state.hover_out) / 0.14))
                end
                if lift > 0.05 then
                    buttontext = string.format("{\\fscx%.1f\\fscy%.1f}", 100 + lift, 100 + lift) .. buttontext
                end
            end

            -- add hover effects
            local button_lo = element.layout.button
            local is_clickable = element.eventresponder and (element.eventresponder["mbtn_left_down"] ~= nil or element.eventresponder["mbtn_left_up"] ~= nil)
            local hovered = mouse_hit(element) and is_clickable and element.enabled and state.mouse_down_counter == 0
            local hoverstyle = button_lo.hoverstyle
            if hovered and (hover_effects.size or hover_effects.color) then
                -- remove font scale tags for these elements, it looks out of place
                if element.name == "title" or element.name == "time_codes" or element.name == "chapter_title" or element.name == "cache_info" or element.name == "speed" or element.name == "time_pos" or element.name == "time_end" then
                    hoverstyle = hoverstyle:gsub("\\fscx%d+\\fscy%d+", "")
                end
                elem_ass:append(hoverstyle .. buttontext)
            else
                elem_ass:append(buttontext)
            end

            -- apply blur effect if "glow" is in hover effects
            if hovered and hover_effects.glow then
                local shadow_ass = assdraw.ass_new()
                shadow_ass:merge(style_ass)
                shadow_ass:append("{\\blur" .. user_opts.button_glow_amount .. "}" .. hoverstyle .. buttontext)
                elem_ass:merge(shadow_ass)
            end

            -- add tooltip for button elements
            local seeking_with_force_tooltip = user_opts.force_seek_tooltip and state.mouse_down_counter > 0 and state.playing_and_seeking

            if element.tooltipF ~= nil and element.enabled and not seeking_with_force_tooltip and user_opts.tooltip_hints and not state.menu_open then
                local hb = element.hover_box
                if (hb and mouse_hit_coords(hb.x1, hb.y1, hb.x2, hb.y2) or mouse_hit(element)) then
                    local tooltiplabel

                    -- tooltip label
                    if element.enabled then
                        if type(element.tooltipF) == "function" then
                            tooltiplabel = element.tooltipF()
                        else
                            tooltiplabel = element.tooltipF
                        end
                    else
                        tooltiplabel = element.nothingavailable
                    end

                    local tx = hb and (hb.x1 + hb.x2) / 2 or (element.hitbox.x1 + element.hitbox.x2) / 2
                    local seekbar_ref = (state.seekbar_element and state.seekbar_element.hitbox) and state.seekbar_element or element
                    local image_mode_offset = (seekbar_ref == element) and 10 or 0
                    local ty = state.tooltip_y or (seekbar_ref.hitbox.y1 - user_opts.tooltip_height_offset - image_mode_offset)

                    local osd_w = frame_number("osd-width")
                    local r_w = get_virt_scale_factor()
                    local tooltip_width = estimate_text_width(tooltiplabel, element.tooltip_style)
                    if osd_w and r_w > 0 then
                        local margin = 10 * r_w
                        tx = math.min(osc_param.playresx - margin - tooltip_width / 2, math.max(margin + tooltip_width / 2, tx))
                    end

                    if tooltiplabel then
                        draw_tooltip(elem_ass, tx, ty, tooltip_width, element.tooltip_style, bidi.fsi .. tooltiplabel .. bidi.pdi)
                    end
                end
            end
        end

        parts[#parts + 1] = elem_ass.text
    end

    for n = 1, #elements do render_element(n) end
    master_ass.text = master_ass.text .. table.concat(parts)
end

local function render_persistent_progress(master_ass)
    local element = state.persistent_seekbar_element
    if not element or not element.layout then return end
    local style_ass = assdraw.ass_new()
    style_ass:merge(element.style_ass)
    if state.animation or not state.osc_visible then
        ass_append_alpha(style_ass, element.layout.alpha, 0, true)

        local elem_ass = assdraw.ass_new()
        elem_ass:merge(style_ass)
        elem_ass:merge(element.static_ass)

        -- draw pos marker
        local pos = element.slider.posF and element.slider.posF()
        local xp = pos and get_slider_ele_pos_for(element, pos) or 0

        draw_seekbar_progress(element, elem_ass)

        if user_opts.persistent_buffer then
            draw_seekbar_ranges(element, elem_ass, xp, 0, nil, true)
        end

        elem_ass:draw_stop()
        master_ass:merge(elem_ass)
    end
end

-- Rounded window corners mask (REQ-OTH-01): draws 4 rounded corner cutouts at the window edges
local function render_window_corners(master_ass)
    if not user_opts.window_rounded_corners or state.fullscreen or state.window_maximized then return end
    local r = user_opts.window_corner_radius
    if not r or r <= 0 then return end
    local W, H = osc_param.playresx, osc_param.playresy
    if not W or not H or W <= 2 * r or H <= 2 * r then return end
    local c = 0.552284749831 * r
    master_ass:new_event()
    master_ass:append("{\\rDefault\\an7\\pos(0,0)\\bord0\\shad0\\blur0\\1c&H000000&\\1a&H00&}")
    master_ass:draw_start()
    -- top-left corner mask
    master_ass:move_to(0, 0)
    master_ass:line_to(r, 0)
    master_ass:bezier_curve(r - c, 0, 0, r - c, 0, r)
    master_ass:line_to(0, 0)
    -- top-right corner mask (skip when top-bar close button is visible to avoid a mismatched black arc over it)
    if not (state.wc_visible and user_opts.window_controls and window_controls_buttons_active()) then
        master_ass:move_to(W - r, 0)
        master_ass:line_to(W, 0)
        master_ass:line_to(W, r)
        master_ass:bezier_curve(W, r - c, W - r + c, 0, W - r, 0)
    end
    -- bottom-right corner mask
    master_ass:move_to(W, H - r)
    master_ass:line_to(W, H)
    master_ass:line_to(W - r, H)
    master_ass:bezier_curve(W - r + c, H, W, H - r + c, W, H - r)
    -- bottom-left corner mask
    master_ass:move_to(0, H - r)
    master_ass:bezier_curve(0, H - r + c, r - c, H, r, H)
    master_ass:line_to(0, H)
    master_ass:line_to(0, H - r)
    master_ass:draw_stop()
end

--
-- Menus: track, playlist, chapter, speed and audio output lists, and the "more" menu,
-- as glass popups that grow out of their button instead of mpv's select lists
--

local menu = nil          -- the open menu: {kind, title, items, anchor, scroll, hover, pressed, back, t0, geo}
local menu_frame = 0      -- bumped once per render, so a menu's geometry is worked out once per frame
local close_menu, open_menu, render_menu, menu_event, menu_covers_sync, menu_cover_ready
do -- (in a block: the main chunk is close to Lua's limit of 200 locals)

local MENU = {row_h = 32, sep_h = 9, header_h = 32, pad = 6, radius = 8, fs = 14, meta_fs = 12.5, title_fs = 12.5, glyph = 16, icon = 18}

local lang_names = {
    en = "English", eng = "English", ja = "Japanese", jpn = "Japanese", es = "Spanish", spa = "Spanish",
    fr = "French", fre = "French", fra = "French", de = "German", ger = "German", deu = "German",
    it = "Italian", ita = "Italian", pt = "Portuguese", por = "Portuguese", ru = "Russian", rus = "Russian",
    zh = "Chinese", chi = "Chinese", zho = "Chinese", ko = "Korean", kor = "Korean", ar = "Arabic", ara = "Arabic",
    hi = "Hindi", hin = "Hindi", nl = "Dutch", dut = "Dutch", nld = "Dutch", sv = "Swedish", swe = "Swedish",
    no = "Norwegian", nor = "Norwegian", da = "Danish", dan = "Danish", fi = "Finnish", fin = "Finnish",
    pl = "Polish", pol = "Polish", tr = "Turkish", tur = "Turkish", el = "Greek", gre = "Greek", ell = "Greek",
    he = "Hebrew", heb = "Hebrew", th = "Thai", tha = "Thai", vi = "Vietnamese", vie = "Vietnamese",
    id = "Indonesian", ind = "Indonesian", ms = "Malay", may = "Malay", msa = "Malay", uk = "Ukrainian",
    ukr = "Ukrainian", cs = "Czech", cze = "Czech", ces = "Czech", hu = "Hungarian", hun = "Hungarian",
    ro = "Romanian", rum = "Romanian", ron = "Romanian", fa = "Persian", per = "Persian", fas = "Persian",
    bn = "Bengali", ben = "Bengali", ta = "Tamil", tam = "Tamil", te = "Telugu", tel = "Telugu",
    tl = "Tagalog", tgl = "Tagalog", fil = "Filipino", ca = "Catalan", cat = "Catalan",
}

local codec_names = {
    eac3 = "E-AC-3", ac3 = "AC-3", aac = "AAC", opus = "Opus", flac = "FLAC", truehd = "TrueHD", dts = "DTS",
    mp3 = "MP3", vorbis = "Vorbis", alac = "ALAC", mp2 = "MP2", pcm_s16le = "PCM", pcm_s24le = "PCM",
    ass = "ASS", ssa = "SSA", subrip = "SRT", srt = "SRT", hdmv_pgs_subtitle = "PGS", pgssub = "PGS",
    webvtt = "WebVTT", dvd_subtitle = "VobSub", dvdsub = "VobSub", mov_text = "Text", text = "Text",
}

local function lang_name(code)
    if not code or code == "" then return nil end
    return lang_names[code:lower()] or code:upper()
end

local function channel_name(n)
    if not n or n <= 0 then return nil end
    return ({"Mono", "Stereo", "3.0", "4.0", "5.0", "5.1", "6.1", "7.1"})[n] or (n .. " ch")
end

local function plain_time(sec)
    sec = math.max(0, math.floor(sec or 0))
    local h, m, s = math.floor(sec / 3600), math.floor(sec / 60) % 60, sec % 60
    return h > 0 and string.format("%d:%02d:%02d", h, m, s) or string.format("%d:%02d", m, s)
end

local function esc(text)
    return mp.command_native({"escape-ass", tostring(text or "")})
end

local function speed_label(v)
    if math.abs(v - 1) < 0.001 then return locale.normal end
    return (string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "")) .. "×"
end

-- glyph name inside an icon marker ("\1name\2")
local function glyph_of(marker)
    return marker and marker:sub(2, -2) or nil
end

local SPEEDS = {0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2}

-- Folders: the videos next to the playing file, and a browser for other folders
local function ext_set(list)
    local set = {}
    for ext in list:gmatch("%w+") do set[ext] = true end
    return set
end
local MEDIA_EXTS = {
    video = ext_set("mkv mp4 m4v avi mov webm wmv flv ts m2ts mts mpg mpeg vob ogv 3gp rmvb asf f4v divx y4m"),
    audio = ext_set("mp3 flac m4a aac ogg oga opus wav wv ape aiff aif wma mka dsf dff"),
    image = ext_set("jpg jpeg png webp gif bmp tif tiff avif heic heif jxl"),
}

local function ext_of(name)
    return (name:match("%.([^%.]+)$") or ""):lower()
end

-- "Episode 2" before "Episode 10": runs of digits compare as numbers
local function natural_sort(names)
    local keys = {}
    for _, n in ipairs(names) do
        keys[n] = n:lower():gsub("%d+", function(d) return ("0"):rep(math.max(0, 12 - #d)) .. d end)
    end
    table.sort(names, function(a, b)
        if keys[a] ~= keys[b] then return keys[a] < keys[b] end
        return a < b
    end)
    return names
end

local function same_path(a, b)
    local function norm(p)
        p = p:gsub("\\", "/"):gsub("/+", "/")
        return platform == "windows" and p:lower() or p
    end
    return norm(a) == norm(b)
end

-- the playing file as an absolute local path, with its folder; nil for streams
local function current_file()
    local path = mp.get_property("path")
    if not path or path:find("^%a[%w+.-]*://") then return nil end
    path = utils.join_path(mp.get_property("working-directory", ""), path)
    local dir = utils.split_path(path)
    return path, dir
end

-- folders list files like the playing one: videos, music or pictures
local function media_kind()
    local path = current_file()
    local ext = path and ext_of(path) or ""
    if MEDIA_EXTS.audio[ext] then return "audio" end
    if MEDIA_EXTS.image[ext] then return "image" end
    return "video"
end

local function dir_name(dir)
    local trimmed = dir:gsub("[/\\]+$", "")
    return trimmed:match("[^/\\]+$") or dir
end

local function parent_dir(dir)
    local trimmed = dir:gsub("[/\\]+$", "")
    if trimmed == "" or trimmed:match("^%a:$") then return nil end  -- "/" or a drive
    local parent = utils.split_path(trimmed)
    if parent == "" or parent == "./" or same_path(parent, dir) then return nil end
    return parent
end

local function list_media(dir, kind)
    local exts = MEDIA_EXTS[kind]
    local out = {}
    for _, f in ipairs(utils.readdir(dir, "files") or {}) do
        if f:sub(1, 1) ~= "." and exts[ext_of(f)] then out[#out + 1] = f end
    end
    return natural_sort(out)
end

local function list_folders(dir)
    local out = {}
    for _, d in ipairs(utils.readdir(dir, "dirs") or {}) do
        if not d:find("^[.$]") and d ~= "System Volume Information" then out[#out + 1] = d end
    end
    return natural_sort(out)
end

-- make the folder the playlist, in order, and play one of its files (the playing
-- file keeps playing when it is the one picked)
local function play_folder(dir, files, index)
    local target = utils.join_path(dir, files[index])
    local path = current_file()
    if path and same_path(path, target) then
        mp.commandv("playlist-clear")
    else
        mp.commandv("loadfile", target, "replace")
    end
    for i = 1, index - 1 do
        mp.commandv("loadfile", utils.join_path(dir, files[i]), "insert-at", tostring(i - 1))
    end
    for i = index + 1, #files do
        mp.commandv("loadfile", utils.join_path(dir, files[i]), "append")
    end
end

local function strip_ext(name)
    return (name:gsub("%.[%w]+$", ""))
end

-- Covers: a small still beside each video in the folder and playlist menus. thumbz makes
-- them (once per file, kept on disk); they're shown with overlay-add, since ASS can't
-- draw pictures, while the menu stands still, over a tile that moves with the menu.
local COVER_W, COVER_H, COVER_R = 60, 33.75, 6  -- in layout units (the pictures are 160x90)
local COVER_X, COVER_GAP = 6, 12                -- inset from the row's edge, gap to the name
local COVER_ROW_H = 46
local COVER_SLOT0, COVER_SLOTS = 50, 14         -- overlay ids (thumbz's seekbar one is 42)
local cover_files = {}                          -- path -> picture, or false (none possible)
local cover_asked = {}
local cover_want, cover_shown = {}, {}          -- overlay id -> {file, x, y, w, h}

local function covers_on()
    return false
end

menu_cover_ready = function(path, file)
    cover_files[path] = file ~= "" and file or false
    if menu then request_tick() end
end

menu_covers_sync = function()
    local d = state.osd_dimensions or {}
    local sx, sy = (d.w or 0) / osc_param.playresx, (d.h or 0) / osc_param.playresy
    for id = COVER_SLOT0, COVER_SLOT0 + COVER_SLOTS - 1 do
        local want, shown = cover_want[id], cover_shown[id]
        if want and sx > 0 then
            local x, y = math.floor(want.x * sx + 0.5), math.floor(want.y * sy + 0.5)
            local w, h = math.floor(COVER_W * sx + 0.5), math.floor(COVER_H * sy + 0.5)
            if not shown or shown.file ~= want.file or shown.x ~= x or shown.y ~= y or shown.w ~= w or shown.h ~= h then
                mp.command_native_async({"overlay-add", id, x, y, want.file, 0, "bgra", 160, 90, 640, w, h}, function() end)
                cover_shown[id] = {file = want.file, x = x, y = y, w = w, h = h}
            end
        elseif shown then
            mp.command_native_async({"overlay-remove", id}, function() end)
            cover_shown[id] = nil
        end
    end
    cover_want = {}
end

-- title, items, header; an item: {label, meta, active, action, icon, submenu, arg (for
-- the submenu), sep (line above)}; header: a link on the title row {label, submenu, arg}
local function menu_items(kind, arg)
    local items, title, header = {}, nil, nil
    local path, dir = current_file()
    local with_covers = covers_on()
    if kind == "playlist" and dir and (state.playlist_count or 0) <= 1 then
        kind, arg = "folder", dir  -- a single file: the videos in its folder
    end
    if kind == "audio" or kind == "sub" then
        title = kind == "audio" and locale.audio or locale.subtitles
        if kind == "sub" then
            local sid = mp.get_property("sid")
            items[#items + 1] = {label = locale.off, active = sid == "no" or sid == nil or sid == "",
                                 action = function() mp.commandv("set", "sid", "no") end}
        end
        for _, t in ipairs(mp.get_property_native("track-list") or {}) do
            if t.type == kind then
                local lang = lang_name(t.lang)
                local label = t.title or lang or (locale.track .. " " .. t.id)
                local meta = {}
                if t.title and lang then meta[#meta + 1] = lang end
                if t.codec then meta[#meta + 1] = codec_names[t.codec] or t.codec:upper() end
                if kind == "audio" then meta[#meta + 1] = channel_name(t["demux-channel-count"]) end
                if t.forced then meta[#meta + 1] = locale.forced end
                if t.external then meta[#meta + 1] = locale.external end
                local active = t.selected
                if kind == "sub" and t["main-selection"] ~= nil then active = t.selected and t["main-selection"] == 0 end
                local id = t.id
                items[#items + 1] = {label = label, meta = table.concat(meta, " · "), active = active,
                    sep = kind == "sub" and #items == 1,
                    action = function() mp.commandv("set", kind == "audio" and "aid" or "sid", tostring(id)) end}
            end
        end
    elseif kind == "playlist" then
        title = locale.playlist
        local entries = mp.get_property_native("playlist") or {}
        local one_dir = dir ~= nil
        local cwd = mp.get_property("working-directory", "")
        for i, entry in ipairs(entries) do
            local name = entry.title
            if not name or name == "" then
                name = (entry.filename or ""):gsub("[/\\]+$", ""):match("[^/\\]+$") or entry.filename or ""
                if not name:find("^%a+://") then name = strip_ext(name) end
            end
            -- a playlist of one folder is titled with the folder's name
            if one_dir then
                local f = utils.join_path(cwd, entry.filename or "")
                one_dir = not f:find("^%a[%w+.-]*://") and same_path(utils.split_path(f), dir)
            end
            local file = entry.filename and not entry.filename:find("^%a[%w+.-]*://")
                and utils.join_path(cwd, entry.filename) or nil
            local active = entry.current or entry.playing
            -- beside thumbnails, the playing one says so instead of numbers and a check
            local meta = tostring(i)
            if with_covers and file then meta = active and locale.playing or nil end
            items[#items + 1] = {label = name, active = active, cover = with_covers and file or nil, meta = meta,
                action = function() mp.commandv("playlist-play-index", tostring(i - 1)) end}
        end
        if one_dir then title = dir_name(dir) end
        if dir then header = {label = locale.browse_folders, submenu = "browse", arg = dir} end
    elseif kind == "folder" then
        -- the videos in the playing file's folder, in order
        title = dir_name(arg)
        local files = list_media(arg, media_kind())
        for i, f in ipairs(files) do
            local active = path ~= nil and same_path(path, utils.join_path(arg, f))
            local meta = tostring(i)
            if with_covers then meta = active and locale.playing or nil end
            items[#items + 1] = {label = strip_ext(f), active = active, meta = meta,
                cover = with_covers and utils.join_path(arg, f) or nil,
                action = function() play_folder(arg, files, i) end}
        end
        local up = parent_dir(arg)
        if up then header = {label = locale.other_folders, submenu = "browse", arg = up} end
    elseif kind == "browse" then
        -- a folder: up a level, its folders, then its videos
        title = dir_name(arg)
        local up = parent_dir(arg)
        if up then
            items[#items + 1] = {icon = "menu_folder_up", label = locale.up_one_level, submenu = "browse", arg = up}
        end
        for _, d in ipairs(list_folders(arg)) do
            local sub = utils.join_path(arg, d)
            items[#items + 1] = {icon = "menu_folder", label = d, submenu = "browse", arg = sub,
                meta = dir and same_path(sub, (dir:gsub("[/\\]+$", ""))) and locale.playing or nil}
        end
        local files = list_media(arg, media_kind())
        for i, f in ipairs(files) do
            local active = path ~= nil and same_path(path, utils.join_path(arg, f))
            items[#items + 1] = {icon = not with_covers and "menu_video" or nil, label = strip_ext(f), sep = i == 1 and #items > 0,
                active = active, meta = with_covers and active and locale.playing or nil,
                cover = with_covers and utils.join_path(arg, f) or nil,
                action = function() play_folder(arg, files, i) end}
        end
        if #items == 0 then
            items[1] = {label = locale.nothing_here}
        end
    elseif kind == "chapter" then
        title = locale.chapters
        local current = mp.get_property_number("chapter", -1)
        for i, ch in ipairs(mp.get_property_native("chapter-list") or {}) do
            items[#items + 1] = {label = (ch.title and ch.title ~= "") and ch.title or (locale.chapter .. " " .. i),
                meta = plain_time(ch.time), active = (i - 1) == current,
                action = function() mp.commandv("set", "chapter", tostring(i - 1)) end}
        end
    elseif kind == "audio-device" then
        title = locale.audio_output
        local current = mp.get_property("audio-device")
        for _, dev in ipairs(mp.get_property_native("audio-device-list") or {}) do
            local name = dev.name
            items[#items + 1] = {label = dev.description or name, active = name == current,
                action = function() mp.commandv("set", "audio-device", name) end}
        end
    elseif kind == "speed" then
        title = locale.speed_control
        local current = mp.get_property_number("speed", 1)
        for _, v in ipairs(SPEEDS) do
            items[#items + 1] = {label = speed_label(v), active = math.abs(current - v) < 0.001,
                action = function() mp.commandv("set", "speed", tostring(v)) end}
        end
    elseif kind == "context" then
        -- the right-click menu: the panel's controls in a few groups
        local group = false
        local function add(item)
            item.sep = group and #items > 0
            group = false
            items[#items + 1] = item
        end
        local paused = state.pause and not state.eof_reached
        add({icon = glyph_of(state.eof_reached and icons.replay or paused and icons.play or icons.pause),
             label = state.eof_reached and locale.replay or paused and locale.play or locale.pause,
             action = function()
                 if state.eof_reached then
                     mp.commandv("seek", 0, "absolute-percent")
                     mp.commandv("set", "pause", "no")
                 else
                     mp.command(user_opts.play_pause_mbtn_left_command)
                 end
             end})
        group = true
        local count = {audio = 0, sub = 0}
        for _, t in ipairs(mp.get_property_native("track-list") or {}) do
            if count[t.type] then count[t.type] = count[t.type] + 1 end
        end
        local function track_name(t)
            return t and (lang_name(t.lang) or t.title or (locale.track .. " " .. t.id)) or locale.off
        end
        if count.audio > 1 then
            add({icon = glyph_of(icons.audio), label = locale.audio, submenu = "audio",
                 meta = track_name(mp.get_property_native("current-tracks/audio"))})
        end
        if count.sub > 0 then
            add({icon = glyph_of(icons.subtitle), label = locale.subtitles, submenu = "sub",
                 meta = track_name(mp.get_property_native("current-tracks/sub"))})
        end
        add({icon = glyph_of(icons.speed), label = locale.speed_control, submenu = "speed",
             meta = speed_label(mp.get_property_number("speed", 1))})
        local chapters = mp.get_property_native("chapter-list") or {}
        if #chapters > 0 then
            local ch = mp.get_property_number("chapter", -1)
            add({icon = glyph_of(icons.chapters), label = locale.chapters, submenu = "chapter",
                 meta = ch >= 0 and string.format("%d / %d", ch + 1, #chapters) or nil})
        end
        if state.playlist_count > 1 or dir then
            add({icon = glyph_of(icons.playlist), label = locale.playlist, submenu = "playlist",
                 meta = state.playlist_count > 1 and string.format("%d / %d", state.playlist_pos_1, state.playlist_count) or nil})
        end
        group = true
        add({icon = glyph_of(icons.loop_on), label = locale.loop, active = mp.get_property("loop-file") ~= "no",
             action = function() mp.command(user_opts.file_loop_mbtn_left_command) end})
        add({icon = glyph_of(icons.ontop_on), label = locale.keep_on_top, active = state.ontop,
             action = function() mp.command(user_opts.ontop_mbtn_left_command) end})
        add({icon = glyph_of(icons.fullscreen), label = locale.fullscreen, active = state.fullscreen,
             action = function() mp.command(user_opts.fullscreen_mbtn_left_command) end})
        group = true
        add({icon = glyph_of(icons.screenshot), label = locale.screenshot,
             action = function() mp.command(user_opts.screenshot_mbtn_left_command) end})
        add({icon = glyph_of(icons.info), label = locale.stats_info,
             action = function() mp.command(user_opts.info_mbtn_left_command) end})
        group = true
        add({icon = glyph_of(icons.window.close), label = locale.quit, action = function() mp.commandv("quit") end})
    end
    return title, items, header
end


local function menu_activate(index)
    if not menu then return end
    if index == 0 and menu.back then
        -- back to the view this one was opened from, where it was scrolled to
        local stack = {}
        for i = 1, #menu.stack - 1 do stack[i] = menu.stack[i] end
        local prev = menu.stack[#menu.stack]
        open_menu(prev.kind, menu.anchor, {from_back = true, arg = prev.arg, scroll = prev.scroll, stack = stack,
                                           at = menu.at, row_y = prev.row_y})
        return
    end
    local item = index == 0 and menu.header or menu.items[index]
    if not item then return end
    if item.submenu then
        local stack = {}
        for i, v in ipairs(menu.stack) do stack[i] = v end
        stack[#stack + 1] = {kind = menu.kind, arg = menu.arg, scroll = menu.scroll, row_y = menu.row_y}
        -- at the pointer, the menu a row opens takes that row's place
        local g = menu.geo
        local row_y = menu.at and g and (index == 0 and g.y + MENU.pad or g.top + g.ys[index - menu.scroll]) or nil
        open_menu(item.submenu, menu.anchor, {back = true, arg = item.arg, stack = stack, at = menu.at, row_y = row_y})
        return
    end
    close_menu()
    if item.action then item.action() end
end

local function menu_move(step)
    if not menu then return end
    local first = (menu.back or menu.header) and 0 or 1
    local i = (menu.hover or (step > 0 and first - 1 or #menu.items + 1)) + step
    menu.hover = math.max(first, math.min(#menu.items, i))
    menu.keyboard = true
    -- keep the highlighted row in view
    local rows = menu.geo and menu.geo.rows or #menu.items
    if menu.hover > 0 then
        if menu.hover <= menu.scroll then menu.scroll = menu.hover - 1 end
        if menu.hover > menu.scroll + rows then menu.scroll = menu.hover - rows end
    end
    request_tick()
end

local function menu_keys(enable)
    local keys = {
        {"ESC", function() close_menu() end},
        {"UP", function() menu_move(-1) end},
        {"DOWN", function() menu_move(1) end},
        {"LEFT", function() if menu and menu.back then menu_activate(0) end end},
        {"BS", function() if menu and menu.back then menu_activate(0) end end},
        {"RIGHT", function()
            local item = menu and menu.hover and menu.items[menu.hover]
            if item and item.submenu then menu_activate(menu.hover) end
        end},
        {"ENTER", function() if menu and menu.hover then menu_activate(menu.hover) end end},
        {"KP_ENTER", function() if menu and menu.hover then menu_activate(menu.hover) end end},
    }
    for i, k in ipairs(keys) do
        local name = "modernz-menu-" .. i
        if enable then mp.add_forced_key_binding(k[1], name, k[2], {repeatable = true})
        else mp.remove_key_binding(name) end
    end
    -- pointer moves anywhere in the window reach the menu (for hover)
    if enable then
        set_virt_mouse_area(0, 0, osc_param.playresx, osc_param.playresy, "menu-hover")
        mp.enable_key_bindings("menu-hover")
    else
        mp.disable_key_bindings("menu-hover")
        set_virt_mouse_area(0, 0, 0, 0, "menu-hover")
    end
end

close_menu = function()
    if not menu then return end
    cover_want = {}
    menu_covers_sync()
    menu = nil
    state.menu_open = false
    menu_keys(false)
    request_tick()
end

-- opts: back = kind of the menu this one was opened from (shows a back row), at = the
-- pointer, for a menu that opens there instead of above a button, row_y = the top of the
-- row it was opened from (with at)
open_menu = function(kind, anchor_name, opts)
    opts = opts or {}
    -- the same button again closes its menu (and any submenu opened from it)
    if menu and not opts.back and not opts.from_back
        and (menu.kind == kind or (anchor_name and menu.anchor == anchor_name)) then
        close_menu()
        return
    end
    local title, items, header = menu_items(kind, opts.arg)
    if #items == 0 then
        mp.osd_message(kind == "sub" and locale.no_subs or kind == "audio" and locale.no_audio or locale.na)
        return
    end
    -- the views it was opened from (each a kind, arg and scroll), for the back row
    local stack = opts.stack or {}
    local had_menu = menu ~= nil
    local origin = menu and menu.geo
    if menu then menu = nil else menu_keys(true) end
    local active, icons_mode, covers = 1, false, false
    for i, item in ipairs(items) do
        item.raw = item.label
        item.label = esc(item.label)
        item.meta = (item.meta and item.meta ~= "") and esc(item.meta) or nil
        if item.active and active == 1 then active = i end
        if item.icon or item.cover then icons_mode = true end
        if item.cover then covers = true end
    end
    state.menu_open = true
    if header then header.label = esc(header.label) end
    menu = {kind = kind, arg = opts.arg, stack = stack, title = title and esc(title) or nil, items = items,
            header = #stack == 0 and header or nil,
            covers = covers, row_h = covers and COVER_ROW_H or MENU.row_h,
            anchor = anchor_name, at = opts.at, row_y = opts.row_y, back = #stack > 0, icons = icons_mode, hover = nil, t0 = mp.get_time(),
            -- going into a submenu or back: the card reshapes from the old one in place and
            -- the new rows slide in from the side they come from
            keep_x = had_menu and origin and origin.x or nil,
            from = had_menu and origin and {x = origin.x, y = origin.y, w = origin.w, h = origin.h} or nil,
            dir = opts.back and 1 or -1}
    local rows = math.min(#items, kind == "context" and #items or math.max(3, user_opts.menu_max_items))
    menu.scroll = opts.scroll or math.max(0, math.min(#items - rows, active - math.ceil(rows / 2)))
    state.showtime = mp.get_time()
    request_tick()
end

-- a label that fits the row, shortened with an ellipsis when it doesn't
local function fit_label(item, avail, style)
    if item.fit_w == avail then return item.fit end
    item.fit_w = avail
    item.fit = item.label
    if not item.raw or estimate_text_width(item.label, style) <= avail then return item.fit end
    local starts = {}
    for p in item.raw:gmatch("()[^\128-\191]") do starts[#starts + 1] = p end
    local lo, hi = 1, #starts
    item.fit = esc("…")
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        local cut = esc((item.raw:sub(1, starts[mid] - 1):gsub("[%s%.%-_]+$", "")) .. "…")
        if estimate_text_width(cut, style) <= avail then
            item.fit, lo = cut, mid + 1
        else
            hi = mid - 1
        end
    end
    return item.fit
end

local function menu_styles()
    local muted = osc_color_convert(user_opts.muted_text_color)
    return {
        title = string.format("{\\bord0\\shad0%s\\fn%s\\1c&H%s&}", ui_font.semibold_b, ui_font.semibold, muted),
        heading = string.format("{\\bord0\\shad0%s\\fn%s\\1c&HFFFFFF&}", ui_font.semibold_b, ui_font.semibold),
        label = string.format("{\\bord0\\shad0\\b0\\fn%s\\1c&HFFFFFF&}", ui_font.regular),
        meta = string.format("{\\bord0\\shad0\\b0\\fn%s\\1c&H%s&}", ui_font.regular, muted),
    }
end

-- size and place of the open menu: above its button, inside the panel's width
local function menu_geometry(m)
    m = m or menu
    if not m then return nil end
    if m.closing then return m.geo end  -- stays put while it fades away
    if m.geo and m.geo_frame == menu_frame then return m.geo end
    local W, H = osc_param.playresx, osc_param.playresy
    local st = menu_styles()
    local fs_label = "{\\fs" .. MENU.fs .. "}"
    local fs_meta = "{\\fs" .. MENU.meta_fs .. "}"
    local widest = m.title and (estimate_text_width(m.title, st.title .. "{\\fs" .. MENU.title_fs .. "}") + (m.back and 24 or 0)) or 0
    if m.header then
        widest = widest + estimate_text_width(m.header.label, st.meta .. "{\\fs" .. MENU.meta_fs .. "}") + 40
    end
    -- a long list (a big folder) is sized by its longest entries only: measuring text
    -- waits on mpv, and hundreds of measurements would hold up opening the menu
    local sized = m.items
    if #sized > 16 then
        if not m.longest then
            local order = {}
            for i = 1, #sized do order[i] = sized[i] end
            table.sort(order, function(a, b) return #a.label + #(a.meta or "") > #b.label + #(b.meta or "") end)
            m.longest = {}
            for j = 1, math.min(12, #order) do m.longest[j] = order[j] end
        end
        sized = m.longest
    end
    for _, item in ipairs(sized) do
        local w = estimate_text_width(item.label, st.label .. fs_label)
            + (item.meta and (estimate_text_width(item.meta, st.meta .. fs_meta) + 20) or 0)
            + (item.submenu and 18 or 0) + (m.icons and not m.covers and item.active ~= nil and 22 or 0)
        if w > widest then widest = w end
    end
    local lead = m.covers and (COVER_X + COVER_W + COVER_GAP + 2) or m.icons and 40 or 32
    local w = math.floor(math.max(200, math.min(widest + lead + 2 * MENU.pad + 18, math.min(440, W - 24))))

    local header = m.title and MENU.header_h or MENU.pad
    local at = m.at
    local ax, ay, avail, floor_y = W / 2, H - 120, nil, nil
    if at then
        -- at the pointer, above the controls: below the pointer, or above it, or else as
        -- low as it goes; to the right of it unless there's no room. A menu opened from
        -- one of its rows takes that row's place, moved up if it would reach the controls.
        floor_y = H - 12
        local p, sb = state.panel_rect, state.seekbar_element
        if p then floor_y = p.y1 - 10
        elseif sb and sb.hitbox then floor_y = sb.hitbox.y1 - 10 end
        if at.up == nil then
            local full = header + #m.items * m.row_h + MENU.pad
            for _, item in ipairs(m.items) do
                if item.sep then full = full + MENU.sep_h end
            end
            local y = math.min(at.y, floor_y)
            at.up = full > floor_y - y
            at.edge = (at.up and full > y - 12) and floor_y or y
            at.left = at.x + w > W - 12
        end
        if m.row_y then
            avail = floor_y - 12 - header - MENU.pad
        else
            avail = (at.up and at.edge - 12 or floor_y - at.edge) - header - MENU.pad
        end
    else
        for _, e in ipairs(elements) do
            if e.name == m.anchor and e.hitbox then
                ax = (e.hitbox.x1 + e.hitbox.x2) / 2
                ay = e.hitbox.y1
            end
        end
        local p = state.panel_rect
        if p then ay = p.y1
        elseif state.seekbar_element and state.seekbar_element.hitbox then ay = math.min(ay, state.seekbar_element.hitbox.y1) end
        avail = ay - 10 - 12 - header - MENU.pad
    end
    -- the right-click menu shows all of its rows when they fit
    local most = m.kind == "context" and #m.items or math.max(3, user_opts.menu_max_items)
    local rows = math.min(#m.items, most, math.max(1, math.floor(avail / m.row_h)))
    local scrolls = #m.items > rows
    m.scroll = math.max(0, math.min(m.scroll, #m.items - rows))
    -- row offsets from the top of the list (separators only when the whole list shows)
    local ys, y = {}, 0
    for r = 1, rows do
        local item = m.items[m.scroll + r]
        if item and item.sep and not scrolls then y = y + MENU.sep_h end
        ys[r] = y
        y = y + m.row_h
    end
    local h = header + y + MENU.pad
    -- (ox, oy): the point it grows out of, the pointer or the top of its button
    local x, top, ox, oy
    if at then
        x = math.max(12, math.min(W - 12 - w, at.left and at.x - w or at.x))
        if m.row_y then
            top = math.max(12, math.min(floor_y - h, m.row_y - MENU.pad))
        else
            top = at.up and at.edge - h or at.edge
        end
        ox, oy = at.x, at.y
    else
        local p = state.panel_rect
        local left, right = 12, W - 12
        if p then left, right = math.max(left, p.x1), math.min(right, p.x2) end
        x = m.keep_x or (ax - w / 2)
        x = math.max(left, math.min(right - w, x))
        top = ay - 10 - h
        ox, oy = math.max(x + MENU.radius, math.min(x + w - MENU.radius, ax)), ay - 10
    end
    m.geo = {x = x, y = top, w = w, h = h, rows = rows, ys = ys, top = top + header,
             scrolls = scrolls, ox = ox, oy = oy}
    m.geo_frame = menu_frame
    return m.geo
end

-- the row under the pointer: an item index, 0 for the back row, nil for none
local function menu_row_at(mx, my)
    local g = menu and menu.geo
    if not g or not mx or mx < g.x or mx > g.x + g.w then return nil end
    if (menu.back or menu.header) and my >= g.y and my < g.top then return 0 end
    for r = 1, g.rows do
        local y = g.top + g.ys[r]
        if my >= y and my < y + menu.row_h then
            local i = menu.scroll + r
            return i <= #menu.items and i or nil
        end
    end
    return nil
end

-- popup menu rendering (instant open/close, no transition animations)
render_menu = function(master_ass, m)
    local menu = m
    local g = menu_geometry(m)
    if not g then return end
    -- drawn on its own and joined once at the end (see batch_new)
    local ass = batch_new()
    local st = menu_styles()
    local function A(a) return string.format("\\alpha&H%02X&", a or 0) end
    local function clip_rect(x1, y1, x2, y2)
        return string.format("\\clip(%f,%f,%f,%f)", x1, y1, x2, y2)
    end

    glass_rect(ass, g.x, g.y, g.w, g.h, MENU.radius, {
        fill_alpha = 0,
        shadow = true,
        shadow_blur = 22, shadow_y = 10, shadow_alpha = 0xB0})

    local inner_x, inner_w = g.x + MENU.pad, g.w - 2 * MENU.pad - (g.scrolls and 6 or 0)
    local row_r = math.max(4, MENU.radius - MENU.pad)
    local function highlight(y, h, strong)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&H%02X&}",
            strong and 0xD4 or 0xE6))
        ass:pos(inner_x, y)
        ass:draw_start()
        ass:round_rect_cw(0, 0, inner_w, h, row_r)
        ass:draw_stop()
    end
    local function text(x, y, an, style, size, str, alpha, clip)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an%d%s}", an, clip or ""))
        ass:pos(x, y)
        ass:append(style .. string.format("{\\fs%g%s}", size, A(alpha)) .. str)
    end
    local function glyph(name, x, y, size, alpha, color)
        ass:new_event()
        ass:append(string.format("{\\rDefault\\an5\\bord0\\shad0\\blur0\\1c&H%s&%s}", color or "FFFFFF", A(alpha)))
        ass:pos(x, y)
        ass:append(icon_drawing(name, size))
    end

    -- header: a section title, or a back row for submenus
    if menu.title then
        local cy = g.y + MENU.header_h / 2 + 2
        if menu.back then
            if menu.hover == 0 then highlight(g.y + MENU.pad, MENU.header_h - MENU.pad, menu.pressed == 0) end
            glyph("menu_back", inner_x + 13, cy, 14, 0x30)
            text(inner_x + 26, cy, 4, st.heading, MENU.fs, menu.title, 0)
        else
            if menu.header then
                -- a link on the right of the title row (another folder, ...)
                if menu.hover == 0 then highlight(g.y + MENU.pad, MENU.header_h - MENU.pad, menu.pressed == 0) end
                local muted = osc_color_convert(user_opts.muted_text_color)
                local lx = inner_x + inner_w - 10
                glyph("menu_chevron", lx - 4, cy, 12, menu.hover == 0 and 0 or 0x30, muted)
                text(lx - 16, cy, 6, st.meta, MENU.meta_fs, menu.header.label, menu.hover == 0 and 0 or 0x20)
            end
            text(g.x + 16, cy, 4, st.title, MENU.title_fs, menu.title, 0)
        end
    end

    local right = inner_x + inner_w - 10
    local wanted = {}
    for r = 1, g.rows do
        local i = menu.scroll + r
        local item = menu.items[i]
        if not item then break end
        local ry = g.top + g.ys[r]
        local row_h = menu.row_h
        local cy = ry + row_h / 2
        if item.sep and not g.scrolls then
            ass:new_event()
            ass:append("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&HE2&}")
            ass:pos(inner_x + 10, ry - MENU.sep_h / 2 - 0.5)
            ass:draw_start()
            ass:rect_cw(0, 0, inner_w - 20, math.max(0.5, glass_edge_width()))
            ass:draw_stop()
        end
        if menu.hover == i then highlight(ry + 1, row_h - 2, menu.pressed == i) end

        -- rows next to the edge of a scrolled list fade out
        local edge = 0
        -- (rows with pictures stay solid: the pictures can't fade with them)
        if g.scrolls and not menu.covers then
            if menu.scroll > 0 and r <= 2 then edge = r == 1 and 0x99 or 0x44 end
            if menu.scroll + g.rows < #menu.items and r > g.rows - 2 then edge = math.max(edge, r == g.rows and 0x99 or 0x44) end
        end

        local label_x = inner_x + (menu.covers and (COVER_X + COVER_W + COVER_GAP) or menu.icons and 38 or 30)
        local trail = right
        if item.cover then
            -- a tile one unit larger than the picture: a placeholder while it loads, then
            -- the hairline edge around it
            local tx, ty = inner_x + COVER_X, cy - COVER_H / 2
            ass:new_event()
            ass:append("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&HE0&}")
            ass:pos(tx - 1, ty - 1)
            ass:draw_start()
            ass:round_rect_cw(0, 0, COVER_W + 2, COVER_H + 2, COVER_R + 1)
            ass:draw_stop()
            local file = cover_files[item.cover]
            if file == nil and not cover_asked[item.cover] then
                cover_asked[item.cover] = true
                wanted[#wanted + 1] = item.cover
            end
            if file and edge < 0x80 and r <= COVER_SLOTS then
                cover_want[COVER_SLOT0 + r - 1] = {file = file, x = tx, y = ty}
            end
        end
        if menu.icons then
            if item.icon then glyph(item.icon, inner_x + (menu.covers and (COVER_X + COVER_W / 2) or 18), cy, MENU.icon, edge) end
            if item.active and not menu.covers then
                glyph("menu_check", right - 6, cy, MENU.glyph, edge)
                trail = right - 22
            end
        elseif item.active then
            glyph("menu_check", inner_x + 15, cy, MENU.glyph, edge)
        end
        if item.submenu then
            glyph("menu_chevron", right - 4, cy, 12, mult_alpha(0x50, edge), osc_color_convert(user_opts.muted_text_color))
            trail = right - 16
        end
        local meta_w = item.meta and estimate_text_width(item.meta, st.meta .. "{\\fs" .. MENU.meta_fs .. "}") or 0
        if item.meta then text(trail, cy, 6, st.meta, MENU.meta_fs, item.meta, edge) end
        local label_right = trail - (item.meta and meta_w + 14 or 0)
        local label = fit_label(item, label_right - label_x, st.label .. "{\\fs" .. MENU.fs .. "}")
        text(label_x, cy, 4, st.label, MENU.fs, label, edge,
             clip_rect(label_x - 2, ry, label_right, ry + row_h))
    end

    -- scroll position
    if g.scrolls then
        local track_y, track_h = g.top + 4, g.ys[g.rows] + menu.row_h - 8
        local thumb_h = math.max(18, track_h * g.rows / #menu.items)
        local thumb_y = track_y + (track_h - thumb_h) * menu.scroll / (#menu.items - g.rows)
        ass:new_event()
        ass:append("{\\rDefault\\an7\\bord0\\shad0\\blur0\\1c&HFFFFFF&\\1a&HA8&}")
        ass:pos(g.x + g.w - 9, thumb_y)
        ass:draw_start()
        ass:round_rect_cw(0, 0, 3, thumb_h, 1.5)
        ass:draw_stop()
    end
    master_ass:new_event()
    master_ass:append(ass:text_of())
end

-- mouse input while a menu is open: returns true when the event belongs to the menu
menu_event = function(source, what)
    if not menu then return false end
    local mx, my = get_virt_mouse_pos()
    if source == "mouse_move" then
        local row = menu_row_at(mx, my)
        if row or not menu.keyboard then menu.hover = row end
        if row then menu.keyboard = false end
        return false
    end
    local g = menu.geo
    local inside = g and mx and mx >= g.x and mx <= g.x + g.w and my >= g.y and my <= g.y + g.h
    if source == "wheel_up" or source == "wheel_down" then
        if what == "press" and inside then
            menu.scroll = math.max(0, math.min(#menu.items - g.rows, menu.scroll + (source == "wheel_up" and -1 or 1)))
            menu.hover = menu_row_at(mx, my)
        end
        return true
    end
    if what == "down" then
        menu.pressed = inside and menu_row_at(mx, my) or nil
        menu.dismiss = not inside
        return true
    elseif what == "up" then
        if menu.dismiss then
            close_menu()
            -- a right click elsewhere opens the right-click menu there
            if source == "mbtn_right" then open_menu("context", nil, {at = {x = mx, y = my}}) end
        elseif source == "mbtn_left" or (source == "mbtn_right" and menu.at) then
            local row = menu_row_at(mx, my)
            if row and row == menu.pressed then menu_activate(row) end
        end
        if menu then menu.pressed = nil end
        return true
    end
    return true
end
end

-- the select/* lists ModernZ replaces with its own menus (when modern_menus=yes)
local menu_for_command = {
    ["script-binding select/select-aid"] = "audio",
    ["script-binding select/select-sid"] = "sub",
    ["script-binding select/select-playlist"] = "playlist",
    ["script-binding select/select-chapter"] = "chapter",
    ["script-binding select/select-audio-device"] = "audio-device",
    ["script-binding select/context-menu"] = "context",
    ["context-menu"] = "context",
}

--
-- Initialisation and Layout
--

local function new_element(name, type)
    elements[name] = {}
    elements[name].type = type
    elements[name].name = name

    -- add default stuff
    elements[name].eventresponder = {}
    elements[name].visible = true
    elements[name].enabled = true
    elements[name].softrepeat = false
    elements[name].styledown = (type == "button")
    elements[name].state = {}

    if type == "button" then
        elements[name].tooltip_style = osc_styles.tooltip
    elseif type == "slider" then
        elements[name].slider = {min = {value = 0}, max = {value = 100}}
    end

    return elements[name]
end

local function add_layout(name)
    if elements[name] ~= nil then
        -- new layout
        elements[name].layout = {}

        -- set layout defaults
        elements[name].layout.layer = 50
        elements[name].layout.alpha = {[1] = 0, [2] = 255, [3] = 255, [4] = 255}
        elements[name].layout.group = "bottom"

        if elements[name].type == "button" then
            elements[name].layout.button = {
                hoverstyle = osc_styles.element_hover,
            }
        elseif elements[name].type == "slider" then
            -- slider defaults
            elements[name].layout.slider = {
                border = 1,
                gap = 1,
                radius = 0,
                nibbles_top = user_opts.nibbles_top,
                nibbles_bottom = user_opts.nibbles_bottom,
                nibbles_style = user_opts.nibbles_style,
                adjust_tooltip = true,
                tooltip_style = osc_styles.tooltip,
                tooltip_an = 2,
                alpha = {[1] = 0, [2] = 255, [3] = 88, [4] = 255},
                hoverstyle = osc_styles.element_hover:gsub("\\fscx%d+\\fscy%d+", ""), -- font scales messes with handle positions in werid ways
            }
        elseif elements[name].type == "box" then
            elements[name].layout.box = {radius = 0, hexagon = false}
        end

        return elements[name].layout
    else
        msg.error("Can't add_layout to element '"..name.."', doesn't exist.")
    end
end

-- glass surface made of layout boxes, so it fades with the OSC: a soft shadow, the
-- tinted fill, a sheen that fades down from the top, a thin edge that is brighter on top
local function add_gradient_mask(name, W, H, edge, edge_depth, blur, opacity, group)
    local pad = math.ceil(blur * 1.5)
    new_element(name, "box")
    local lo = add_layout(name)
    if edge == "top" then
        lo.geometry = {x = -pad, y = -pad, an = 7, w = W + 2 * pad, h = pad + edge_depth}
    else
        lo.geometry = {x = -pad, y = H - edge_depth, an = 7, w = W + 2 * pad, h = edge_depth + pad}
    end
    lo.layer = 8
    lo.group = group
    lo.style = string.format("{\\blur%g\\bord0\\shad0\\1c&H000000&}", blur)
    lo.alpha[1] = 255 - math.floor(opacity * 255 + 0.5)
    lo.box.radius = 0
end

-- Screenbox top bar: unified full-width non-floating bar with Screenbox's exact gradient mask
-- (Screenbox PlayerPage.xaml: PlayerTitleBar MinHeight="80", PlayerTitleBarBackgroundBrush)
local function screenbox_window_controls()
    local W, H = osc_param.playresx, osc_param.playresy
    local bar_h = 80
    local cap_w, cap_h = 46, 32 -- Standard Windows 11 / WinUI TitleBar caption buttons
    local show_buttons = user_opts.window_controls and window_controls_buttons_active()
    local ontop_active = user_opts.ontop_button and window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop
    local has_top = user_opts.show_window_title or show_buttons or ontop_active
    if not has_top then
        elements["minimize"].visible = false
        elements["maximize"].visible = false
        elements["close"].visible = false
        return
    end

    -- Smooth Gaussian-blurred match for PlayerTitleBarBackgroundBrush
    -- (0px -> ~0.60 [#99000000], 40px -> ~0.20 [#33000000], 80px -> ~0.01 -> seamless 0.00)
    add_gradient_mask("sb_top_bg", W, H, "top", 24, 60, 0.72, "top")

    local lo
    local right_x = W
    local size_hover = hover_effects.size and
        string.format("\\fscx%s\\fscy%s", user_opts.button_hover_size, user_opts.button_hover_size) or ""
    local function tinted(color) return "{\\c&H" .. osc_color_convert(color) .. "&" .. size_hover .. "}" end
    local function wc_button(name, cx, w, h, hoverstyle)
        lo = add_layout(name)
        lo.geometry = {x = cx, y = h / 2, an = 5, w = w, h = h}
        lo.style = osc_styles.glass_window_control
        lo.group = "top"
        lo.button.hoverstyle = hoverstyle
        elements[name].hover_radius = 0
        elements[name].hover_pad = 0
    end

    if show_buttons then
        local bx = W - 3 * cap_w
        right_x = bx
        wc_button("minimize", bx + cap_w * 0.5, cap_w, cap_h, tinted(user_opts.windowcontrols_min_hover))
        wc_button("maximize", bx + cap_w * 1.5, cap_w, cap_h, tinted(user_opts.windowcontrols_max_hover))
        wc_button("close",    bx + cap_w * 2.5, cap_w, cap_h, "{}")
        elements["minimize"].hover_color, elements["maximize"].hover_color = nil, nil
        elements["minimize"].hover_alpha, elements["maximize"].hover_alpha = 0xE6, 0xE6
        elements["close"].hover_color = user_opts.windowcontrols_close_hover
        elements["close"].hover_alpha = 0x10
    else
        elements["minimize"].visible = false
        elements["maximize"].visible = false
        elements["close"].visible = false
    end

    if ontop_active then
        local pw = 40
        right_x = right_x - pw
        elements["ontop"].visible = true
        wc_button("ontop", right_x + pw * 0.5, pw, cap_h, osc_styles.element_hover)
        elements["ontop"].hover_alpha = 0xE6
    end

    if user_opts.show_window_title then
        local left_x = 18 -- aligns with SeekBar left edge (Padding 6 + Margin 12 = 18)
        local max_w = math.max(0, right_x - left_x - 16)
        if max_w > 12 then
            lo = add_layout("windowtitle")
            lo.geometry = {x = left_x, y = 26, an = 4, w = max_w, h = 36}
            lo.group = "top"
            lo.alpha[3] = 0
            lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", osc_styles.glass_title, left_x, 0, left_x + max_w, bar_h)
            state.windowtitle_max_w = max_w
        end
    end

    local drag_h = 48
    local sh_area_y1 = bar_h + get_align(1 - (2 * user_opts.deadzonesize), H - bar_h, 0, 0)
    add_area("showhide_wc", 0, 0, W, sh_area_y1)
    if show_buttons then add_area("window-controls", W - 3 * cap_w, 0, W, cap_h) end
    if ontop_active then add_area("window-controls-ontop", right_x, 0, right_x + 40, cap_h) end
    add_area("window-controls-title", 0, 0, right_x, drag_h)
    osc_param.video_margins.t = drag_h / H
end

-- Window Controls
local function window_controls()
    return screenbox_window_controls()
end

local layouts = {}

-- Screenbox layout: faithful non-floating full-width player controls bar matching Screenbox
-- (Screenbox PlayerPage.xaml & PlayerControls.xaml: Padding="6,20,6,12", SeekBar Margin="12,0",
--  40x40 PlayerButtonStyle, VolumeControl Width="140", PlayerControlsBackgroundBrush gradient mask)
-- Row 0: Full-width SeekBar with chapter gap segments
-- Row 1 Left: [Play/Pause] [Previous][Next] [TimeDisplay (Elapsed / Total)]
-- Row 1 Right: [Mute] [Volume Slider] [Folder Playlist] [Subtitles] [Audio] [Pin Window] [Fullscreen] [More/Settings]
layouts["screenbox"] = function ()
    local W, H = osc_param.playresx, osc_param.playresy

    local btn = 40            -- PlayerButtonStyle: Width="40" Height="40"
    local btn_r = 4           -- WinUI 3 ControlCornerRadius = 4px
    local pad_x = 6           -- PlayerControls Padding left/right = 6px
    local pad_bottom = 12     -- PlayerControls Padding bottom = 12px
    local seek_row_h = 32     -- WinUI 3 Slider height = 32px
    local pad_top = 20        -- PlayerControls Padding top = 20px
    local panel_h = pad_top + seek_row_h + btn + pad_bottom -- 104px
    local py = H - panel_h
    local x0, x1 = pad_x, W - pad_x
    local cy = H - pad_bottom - btn / 2                 -- H - 32 (40x40 button row center)
    local seek_cy = H - pad_bottom - btn - seek_row_h / 2 -- H - 68 (SeekBar center)

    state.glass_ui = false
    state.tooltip_y = seek_cy - 18
    state.panel_rect = {x1 = 0, y1 = py, x2 = W, y2 = H, r = 0}

    osc_param.areas = {}
    osc_param.video_margins.b = panel_h / H
    add_area("input", 0, py, W, H)
    add_area("showhide", 0, get_align(-1 + (2 * user_opts.deadzonesize), py, 0, 0), W, H)

    -- Smooth Gaussian-blurred match for PlayerControlsBackgroundBrush
    -- (H -> ~0.60 [#99000000], H-56 -> ~0.28, H-112 -> ~0.015 -> seamless 0.00)
    add_gradient_mask("sb_bot_bg", W, H, "bottom", 52, 72, 0.63, "bottom")

    local lo, ne

    -- Title is displayed in the top bar in Screenbox (REQ-OTH-01); hide bottom-bar title and split time elements
    elements["title"].visible = false
    elements["time_pos"].visible = false
    elements["time_end"].visible = false

    -- Full-width SeekBar across Row 0 (Padding 6 + Margin 12 = 18px each side in PlayerControls.xaml)
    local sx0, sx1 = 18, W - 18
    local seek_w = math.max(10, sx1 - sx0)

    ne = new_element("seekbarbg", "box")
    ne.visible = user_opts.nibbles_style ~= "gap"
    lo = add_layout("seekbarbg")
    local seekbar_bg_h = seekbar_height_style.height
    lo.geometry = {x = sx0 + seek_w / 2, y = seek_cy, an = 5, w = seek_w, h = seekbar_bg_h}
    lo.layer = 15
    lo.style = osc_styles.seekbar_bg
    lo.box.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.alpha[1] = 0x99

    lo = add_layout("seekbar")
    local seekbar_h = 18
    lo.geometry = {x = sx0 + seek_w / 2, y = seek_cy, an = 5, w = seek_w, h = seekbar_h}
    lo.layer = 49
    lo.style = osc_styles.seekbar_fg
    lo.slider.handle_color = user_opts.seek_handle_color
    lo.slider.handle_border = user_opts.seek_handle_border_color
    lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
    lo.slider.radius = user_opts.slider_rounded_corners and seekbar_height_style.radius or 0
    lo.slider.tooltip_an = 2

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        lo = add_layout("persistent_seekbar")
        lo.geometry = {x = W / 2, y = H, an = 5, w = W, h = user_opts.persistent_progress_height}
        lo.style = osc_styles.seekbar_fg
        lo.slider.gap = (seekbar_h - seekbar_bg_h) / 2.0
        lo.slider.tooltip_an = 0
    end

    -- Row 1 Controls:
    -- Left: [Play/Pause] [Previous][Next] [TimeDisplay (Elapsed / Total)] [Optional Chapter in v2.0]
    -- Right: [Volume Mute] [Volume Slider] [Optional Shuffle/Loop in v2.0] [Folder Playlist] [Subtitles] [Audio] [Pin Window] [Fullscreen] [More/Settings]
    local audio_track = state.audio_track_count > 0
    local subtitle_track = state.sub_track_count > 0
    local have_pl = state.playlist_count > 1
    local chapter_skip = user_opts.chapter_skip_buttons and type(state.chapter_list) == "table" and next(state.chapter_list) ~= nil
    local playlist_button = user_opts.playlist_button and (not user_opts.hide_empty_playlist_button or have_pl)
    local nextprev = user_opts.track_nextprev_buttons
    local ontop_button = user_opts.ontop_button and not (window_controls_enabled() and user_opts.ontop_in_topbar and state.ontop)
    local has_time = (state.duration or 0) > 0
    local time_w = has_time and math.ceil(get_time_codes_width() + 12) or 0
    local chapter_index = (state.chapter or -1) >= 0
    local show_chapter = user_opts.show_chapter_title and chapter_index and user_opts.chapter_fmt ~= "no"
    local play_st, transport, icon = osc_styles.control_1, osc_styles.control_2, osc_styles.control_3
    local vol_slider_vis = audio_track and user_opts.volume_control and (W >= user_opts.hide_volume_bar_trigger)

    -- name, width, keep priority (higher stays longer), style, wanted, gap after
    local left = {
        {"play_pause", btn, 100, play_st, true, 4},
        {"chapter_prev", btn, 20, transport, chapter_skip, 0},
        {"playlist_prev", btn, 65, transport, nextprev and (have_pl or contains(user_opts.buttons_always_active, "playlist_prev")), 0},
        {"jump_backward", btn, 30, transport, user_opts.jump_buttons, 0},
        {"jump_forward", btn, 30, transport, user_opts.jump_buttons, 0},
        {"playlist_next", btn, 65, transport, nextprev and (have_pl or contains(user_opts.buttons_always_active, "playlist_next")), 8},
        {"chapter_next", btn, 20, transport, chapter_skip, 8},
        {"time_codes", time_w, 55, osc_styles.glass_time, has_time, 8},
        {"chapter_title", 140, 15, osc_styles.glass_chapter, show_chapter, 4},
    }
    local right = {
        {"vol_ctrl", btn, 85, icon, audio_track and user_opts.volume_control, 4},
        {"volumebar", 96, 40, nil, vol_slider_vis, 8},
        {"cache_info", user_opts.cache_info_speed and 70 or 48, 5, osc_styles.glass_cache, user_opts.cache_info, 4},
        {"shuffle", btn, 25, icon, user_opts.shuffle_button, 4},
        {"file_loop", btn, 25, icon, user_opts.loop_button, 4},
        {"playlist", btn, 70, icon, playlist_button, 4},
        {"sub_track", btn, 80, icon, subtitle_track and user_opts.subtitles_button, 4},
        {"audio_track", btn, 75, icon, audio_track and user_opts.audio_tracks_button, 4},
        {"ontop", btn, 60, icon, ontop_button, 4},
        {"fullscreen", btn, 98, icon, user_opts.fullscreen_button, 4},
        {"more", btn, 95, icon, user_opts.settings_button, 0},
    }

    local groups = {left, right}
    for _, list in ipairs(groups) do
        for _, it in ipairs(list) do
            it.keep = (it[5] and elements[it[1]] ~= nil) and true or false
            it.gap = it[6] or 4
        end
    end
    local function width(list)
        local sum, prev_gap = 0, 0
        for _, it in ipairs(list) do
            if it.keep then
                sum = sum + prev_gap + it[2]
                prev_gap = it.gap
            end
        end
        return sum
    end
    local row_w = x1 - x0
    while width(left) + width(right) + 16 > row_w do
        local victim
        for _, list in ipairs(groups) do
            for _, it in ipairs(list) do
                if it.keep and (not victim or it[3] < victim[3]) then victim = it end
            end
        end
        if not victim then break end
        victim.keep = false
    end
    -- the volume slider goes with its button
    if not right[1].keep then right[2].keep = false end

    local function place(it, x)
        local name, w, _, style = it[1], it[2], it[3], it[4]
        if name == "volumebar" then
            ne = new_element("volumebarbg", "box")
            lo = add_layout("volumebarbg")
            lo.geometry = {x = x, y = cy, an = 4, w = w, h = 4}
            lo.layer = 15
            lo.alpha[1] = 0x99
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_bg or "{\\1c&HFFFFFF&}"
            lo.box.radius = 2

            lo = add_layout("volumebar")
            lo.geometry = {x = x, y = cy, an = 4, w = w, h = 16}
            lo.style = user_opts.volumebar_match_seek_color and osc_styles.seekbar_fg or osc_styles.volumebar_fg
            lo.slider.handle_color = user_opts.volumebar_match_seek_color and user_opts.seek_handle_color or user_opts.side_buttons_color
            lo.slider.handle_border = user_opts.seek_handle_border_color
            lo.slider.gap = 6
            lo.slider.radius = 2
            lo.slider.tooltip_an = 2
            return
        end
        lo = add_layout(name)
        if name == "time_codes" then
            lo.geometry = {x = x, y = cy - 1, an = 4, w = w, h = user_opts.time_font_size}
            lo.layer = 48
            lo.alpha[3] = 0
        elseif name == "chapter_title" then
            lo.geometry = {x = x + 4, y = cy - 1, an = 4, w = w - 4, h = user_opts.chapter_title_font_size}
            lo.layer = 48
            lo.alpha[3] = 0
            lo.style = string.format("%s{\\clip(%f,%f,%f,%f)}", style, x + 4, cy - 12, x + w, cy + 12)
            state.chapter_title_max_w = w - 8
            return
        elseif name == "cache_info" then
            lo.geometry = {x = x + 4, y = cy, an = 4, w = w - 8, h = user_opts.cache_info_font_size}
            lo.layer = 48
            lo.alpha[3] = 0
        else
            lo.geometry = {x = x + w / 2, y = cy, an = 5, w = w, h = btn}
        end
        lo.style = style
        local e = elements[name]
        e.hover_radius, e.hover_pad, e.hover_alpha = btn_r, 0, 0xE8
        if name == "cache_info" then
            e.hover_radius, e.hover_pad = btn_r, 4
        end
    end
    local function lay(list, x)
        local prev_gap = 0
        for _, it in ipairs(list) do
            if elements[it[1]] then elements[it[1]].visible = it.keep end
            if it.keep then
                x = x + prev_gap
                place(it, x)
                x = x + it[2]
                prev_gap = it.gap
            end
        end
        return x
    end
    lay(left, x0)
    lay(right, x1 - width(right))

    -- the volume button's wheel area covers its slider too, while its hover highlight stays on the button
    if right[1].keep and right[2].keep then
        elements["vol_ctrl"].hover_box = nil
        elements["vol_ctrl"].hover_pad = 0
        elements["vol_ctrl"].hover_radius = btn_r
    end
end

local function set_bar_visible(visible_key, visible)
    if state[visible_key] ~= visible then
        state[visible_key] = visible
        update_margins()
    end
    request_tick()
end

local function osc_visible(visible)
    set_bar_visible("osc_visible", visible)
end

local function wc_visible(visible)
    set_bar_visible("wc_visible", visible)
end

-- run a button's command; mpv's select lists open as ModernZ menus instead
local function run_command(command, element_name)
    local kind = user_opts.modern_menus and menu_for_command[command:match("^%s*(.-)%s*$")]
    if kind then
        open_menu(kind, element_name)
    else
        mp.command(command)
    end
end

-- use_down: if true, uses _down instead of _up (for softrepeat buttons)
local function bind_buttons(element_name, use_down)
    local ev = use_down and "_down" or "_up"
    for _, button in ipairs({"mbtn_left", "mbtn_right"}) do
        local command = user_opts[element_name .. "_" .. button .. "_command"]
        if command ~= nil and command ~= "" and command ~= "ignore" then
            elements[element_name].eventresponder[button .. ev] = function() run_command(command, element_name) end
        end
    end
    local command = user_opts[element_name .. "_mbtn_mid_command"]
    if command ~= nil and command ~= "" and command ~= "ignore" then
        elements[element_name].eventresponder["shift+mbtn_left_down"] = function() run_command(command, element_name) end
    end
    for _, button in ipairs({"wheel_up", "wheel_down"}) do
        local command = user_opts[element_name .. "_" .. button .. "_command"]
        if command ~= nil and command ~= "" and command ~= "ignore" then
            elements[element_name].eventresponder[button .. "_press"] = function() run_command(command, element_name) end
        end
    end
end

-- format seconds into a time string
local function format_time(seconds)
    if not seconds then return "--:--" end

    local hours   = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs    = math.floor(seconds % 60)
    local show_hours = hours > 0 or user_opts.time_format == "fixed"

    if state.tc_ms then
        local ms = math.floor((seconds % 1) * 1000)
        if show_hours then
            return string.format("%d:%02d:%02d.%03d", hours, minutes, secs, ms)
        else
            return string.format("%d:%02d.%03d", minutes, secs, ms)
        end
    else
        if show_hours then
            return string.format("%d:%02d:%02d", hours, minutes, secs)
        else
            return string.format("%d:%02d", minutes, secs)
        end
    end
end

local function build_cache_seek_ranges()
    if not user_opts.seekrange or not cache_enabled() then return nil end
    if not state.duration then return nil end
    local nranges = {}
    for _, range in ipairs(state.demuxer_cache_state["seekable-ranges"]) do
        nranges[#nranges + 1] = {
            ["start"] = 100 * range["start"] / state.duration,
            ["end"]   = 100 * range["end"]   / state.duration,
        }
    end
    return nranges
end

local function osc_init()
    msg.debug("osc_init")

    -- set canvas resolution according to display aspect and scaling setting
    local baseResY = 720
    local display_h = state.osd_dimensions.h
    local display_aspect = state.osd_dimensions.aspect
    local scale

    if state.fullscreen then
        scale = user_opts.scalefullscreen
    else
        scale = user_opts.scalewindowed
    end

    local scale_with_video
    if user_opts.vidscale == "auto" then
        scale_with_video = state.osd_scale_by_window
    else
        scale_with_video = user_opts.vidscale == "yes"
    end

    if scale_with_video then
        osc_param.unscaled_y = baseResY
    else
        osc_param.unscaled_y = display_h
    end
    osc_param.playresy = osc_param.unscaled_y / scale
    -- mpv's OSD units (used for osd-margin-y) are 720 when osd-scale-by-window=yes, else display_h
    osc_param.osd_units_y = state.osd_scale_by_window and baseResY or display_h
    if display_aspect > 0 then
        osc_param.display_aspect = display_aspect
    end
    -- in portrait windows, base the scaled canvas on the window's short side (its width)
    -- like landscape does with its height; otherwise a 9:16 window is only ~405 units
    -- wide and every width-dependent button gets hidden
    if scale_with_video and osc_param.display_aspect < 1 then
        osc_param.playresy = osc_param.playresy / osc_param.display_aspect
    end
    -- growing with the window stops at a set size (adjusted for the system's display
    -- scaling), so a large or high resolution screen shows the controls at the same size
    -- as a regular one instead of ever bigger
    if scale_with_video and user_opts.vidscale_max > 0 and display_h > 0 then
        local hidpi = mp.get_property_number("display-hidpi-scale", 1) or 1
        local max_px = user_opts.vidscale_max * math.max(hidpi, 0.5) * scale  -- screen pixels per unit
        if display_h / osc_param.playresy > max_px then
            osc_param.playresy = display_h / max_px
        end
    end
    osc_param.playresx = osc_param.playresy * osc_param.display_aspect

    -- stop seeking with the slider to prevent skipping files
    state.active_element = nil
    state.playing_and_seeking = false

    -- reset margins and text width
    text_width_cache = {}
    osc_param.video_margins = {l = 0, r = 0, t = 0, b = 0}

    elements = {}

    -- some often needed stuff
    local pl_count = state.playlist_count
    local have_pl = pl_count > 1
    local pl_pos = state.playlist_pos_1
    local have_ch = #state.chapter_list > 0
    local loop = mp.get_property("loop-playlist", "no")

    -- titles are redrawn every frame but rarely change: expand them at most every
    -- half second and escape each distinct text once (both are round trips to mpv)
    local title_cache = {}
    local function make_escaped_title(source)
        local now = mp.get_time()
        local c = title_cache[source or ""]
        if c and now - c.t < 0.5 then return c.text end
        local title = mp.command_native({"expand-text", source})
        title = title:gsub("\n", " ")
        local text = c and c.raw == title and c.text or (title ~= "" and mp.command_native({"escape-ass", title}) or "mpv")
        title_cache[source or ""] = {t = now, raw = title, text = text}
        return text
    end

    local ne

    -- Window controls
    -- Close
    ne = new_element("close", "button")
    ne.hover_color = user_opts.windowcontrols_close_hover
    ne.hover_radius = 0
    ne.hover_pad = 0
    ne.content = icons.window.close
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("quit") end

    -- Minimize
    ne = new_element("minimize", "button")
    ne.hover_color = user_opts.windowcontrols_min_hover
    ne.hover_radius = 0
    ne.hover_pad = 0
    ne.content = icons.window.minimize
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", "window-minimized") end

    -- Maximize
    ne = new_element("maximize", "button")
    ne.hover_color = user_opts.windowcontrols_max_hover
    ne.hover_radius = 0
    ne.hover_pad = 0
    ne.content = (state.window_maximized or state.fullscreen) and icons.window.unmaximize or icons.window.maximize
    ne.eventresponder["mbtn_left_up"] = function () mp.commandv("cycle", (state.fullscreen and "fullscreen" or "window-maximized")) end

    local function truncate_title(title, max_w, style)
        if not max_w or max_w <= 0 or estimate_text_width(title, style) <= max_w then return title end
        local ell_w = estimate_text_width("…", style)
        -- map each UTF-8 character to its last byte offset (avoids slicing mid-char)
        local char_ends, pos = {}, 1
        while pos <= #title do
            local b = title:byte(pos)
            local char_len = b >= 0xF0 and 4 or b >= 0xE0 and 3 or b >= 0xC0 and 2 or 1
            char_ends[#char_ends + 1] = pos + char_len - 1
            pos = pos + char_len
        end
        -- binary search over character count
        local low, high, fit = 1, #char_ends, 0
        while low <= high do
            local mid = math.floor((low + high) / 2)
            if estimate_text_width(title:sub(1, char_ends[mid]), style) <= max_w - ell_w then
                fit = mid; low = mid + 1
            else
                high = mid - 1
            end
        end
        return title:sub(1, fit > 0 and char_ends[fit] or 0) .. "…"
    end

    -- Window Title
    ne = new_element("windowtitle", "button")
    ne.content = function ()
        local t = make_escaped_title(user_opts.title)
        return user_opts.truncate_title and truncate_title(t, state.windowtitle_max_w, osc_styles.glass_title) or t
    end

    -- OSC title
    ne = new_element("title", "button")
    ne.content = function ()
        local t = make_escaped_title(user_opts.title)
        return user_opts.truncate_title and truncate_title(t, state.title_max_w, osc_styles.title) or t
    end
    bind_buttons("title")

    -- Chapter title
    ne = new_element("chapter_title", "button")
    ne.content = function()
        local chapter_index = state.chapter or -1
        if user_opts.chapter_fmt == "no" or chapter_index < 0 then return "" end
        local chapter_data = state.chapter_list[chapter_index + 1]
        local raw = chapter_data and chapter_data.title ~= "" and chapter_data.title
            or string.format("%s: %d/%d", locale.chapter, chapter_index + 1, #state.chapter_list)
        if state.chapter_title_raw ~= raw then
            state.chapter_title_raw = raw
            state.chapter_title_esc = mp.command_native({"escape-ass", raw})
        end
        local chapter_title = state.chapter_title_esc
        local t = string.format(user_opts.chapter_fmt, chapter_title)
        return user_opts.truncate_title and truncate_title(t, state.chapter_title_max_w, osc_styles.chapter_title) or t
    end
    bind_buttons("chapter_title")

    -- playlist buttons
    -- prev
    ne = new_element("playlist_prev", "button")
    ne.content = icons.previous
    ne.enabled = (pl_pos > 1) or (loop ~= "no") or contains(user_opts.buttons_always_active, "playlist_prev")
    bind_buttons("playlist_prev")

    --next
    ne = new_element("playlist_next", "button")
    ne.content = icons.next
    ne.enabled = (have_pl and (pl_pos < pl_count)) or (loop ~= "no") or contains(user_opts.buttons_always_active, "playlist_next")
    bind_buttons("playlist_next")

    --play control buttons
    --play_pause
    ne = new_element("play_pause", "button")
    ne.content = function () return state.eof_reached and icons.replay or (state.pause and not state.playing_and_seeking and icons.play) or icons.pause end
    bind_buttons("play_pause")
    ne.eventresponder["mbtn_left_up"] = function ()
        if state.eof_reached then
            mp.commandv("seek", 0, "absolute-percent")
            mp.commandv("set", "pause", "no")
        else
            mp.command(user_opts.play_pause_mbtn_left_command)
        end
    end

    local jump_amount = user_opts.jump_amount
    local jump_more_amount = user_opts.jump_more_amount
    local jump_mode = user_opts.jump_mode
    local jump_icon = user_opts.jump_icon_number and icons.jump[jump_amount] or icons.jump.default

    --jump_backward
    ne = new_element("jump_backward", "button")
    ne.softrepeat = user_opts.jump_softrepeat
    ne.content = jump_icon[1]
    ne.eventresponder["mbtn_left_down"] = function () mp.commandv("seek", -jump_amount, jump_mode) end
    ne.eventresponder["mbtn_right_down"] = function () mp.commandv("seek", -jump_more_amount, jump_mode) end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("frame-back-step") end

    --jump_forward
    ne = new_element("jump_forward", "button")
    ne.softrepeat = user_opts.jump_softrepeat
    ne.content = jump_icon[2]
    ne.eventresponder["mbtn_left_down"] = function () mp.commandv("seek", jump_amount, jump_mode) end
    ne.eventresponder["mbtn_right_down"] = function () mp.commandv("seek", jump_more_amount, jump_mode) end
    ne.eventresponder["shift+mbtn_left_down"] = function () mp.commandv("frame-step") end

    --chapter_prev
    ne = new_element("chapter_prev", "button")
    ne.content = icons.rewind
    ne.enabled = have_ch -- disables button when no chapters available.
    bind_buttons("chapter_prev", true)

    --chapter_next
    ne = new_element("chapter_next", "button")
    ne.content = icons.forward
    ne.enabled = have_ch -- disables button when no chapters available.
    bind_buttons("chapter_next", true)

    --playlist
    ne = new_element("playlist", "button")
    ne.enabled = have_pl or not user_opts.hide_empty_playlist_button
    ne.off = not have_pl and user_opts.gray_empty_playlist_button
    ne.content = icons.playlist
    ne.tooltipF = function() return have_pl and locale.playlist .. " [" .. pl_pos .. "/" .. pl_count .. "]" or locale.playlist .. " / " .. locale.menu end
    ne.nothingavailable = locale.no_playlist
    bind_buttons("playlist")

    -- track tooltip helper
    local function track_tooltip(label, track_type, id_prop, count)
        local prop = mp.get_property("current-tracks/" .. track_type .. "/title") or mp.get_property("current-tracks/" .. track_type .. "/lang") or locale.unknown
        return label .. " [" .. mp.get_property_number(id_prop, "-") .. "/" .. count .. "] [" .. prop .. "]"
    end

    --audio_track
    ne = new_element("audio_track", "button")
    ne.enabled = state.audio_track_count > 0
    ne.off = state.audio_track_count == 0 or not mp.get_property_native("aid")
    ne.content = icons.audio
    ne.tooltipF = function () return track_tooltip(locale.audio, "audio", "aid", state.audio_track_count) end
    ne.nothingavailable = locale.no_audio
    bind_buttons("audio_track")

    --sub_track
    ne = new_element("sub_track", "button")
    ne.enabled = state.sub_track_count > 0
    ne.off = state.sub_track_count == 0 or not mp.get_property_native("sid")
    ne.content = icons.subtitle
    ne.tooltipF = function () return track_tooltip(locale.subtitle, "sub", "sid", state.sub_track_count) end
    ne.nothingavailable = locale.no_subs
    bind_buttons("sub_track")

    -- vol_ctrl
    ne = new_element("vol_ctrl", "button")
    ne.enabled = state.audio_track_count > 0
    ne.off = state.audio_track_count == 0
    ne.content = function ()
        local volume = state.volume
        return state.mute and icons.volume_mute or (volume >= 75 and icons.volume_high) or (volume >= 25 and icons.volume_low) or icons.volume_quiet
    end
    ne.tooltipF = function ()
        local volume = state.volume
        -- show only one decimal, if decimals exist
        local volume_str = (volume % 1 == 0) and string.format("%.0f", volume) or string.format("%.1f", volume)
        return locale.volume .. ": " .. volume_str .. (state.mute and " (" .. locale.muted .. ")" or "")
    end
    bind_buttons("vol_ctrl")

    --volumebar
    local volume_max_prop = mp.get_property_number("volume-max") or 0
    local volume_max = volume_max_prop > 0 and volume_max_prop or 100
    ne = new_element("volumebar", "slider")
    ne.enabled = state.audio_track_count > 0
    ne.slider = {min = {value = 0}, max = {value = volume_max}}
    ne.slider.markerF = function () return {} end
    ne.slider.seekRangesF = function() return nil end
    ne.slider.posF = function ()
        if user_opts.volume_control_type ~= "logarithmic" then return state.volume end
        return state.volume and math.sqrt(state.volume * 100) or 0
    end
    ne.slider.tooltipF = function (pos)
        return set_volume(pos) .. "%"
    end
    ne.eventresponder["mouse_move"] = function (element)
        local pos = get_slider_value(element)
        local setvol = set_volume(pos)
        if element.state.lastseek == nil or element.state.lastseek ~= setvol then
                mp.commandv("set", "volume", setvol)
                element.state.lastseek = setvol
        end
    end
    ne.eventresponder["mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        element.state.handle_drag = true
        local pos = get_slider_value(element)
        if user_opts.volumebar_unmute_on_click then
            mp.set_property_bool("mute", false)
        end
        mp.commandv("set", "volume", set_volume(pos))
        request_tick()
    end
    ne.eventresponder["mbtn_left_up"] = function (element)
        element.state.mbtnleft = false
        element.state.handle_drag = false
        request_tick()
    end
    ne.eventresponder["reset"] = function (element)
        element.state.lastseek = nil
        element.state.mbtnleft = false
        element.state.handle_drag = false
    end
    bind_buttons("volumebar")

    --fullscreen
    ne = new_element("fullscreen", "button")
    ne.content = function() return state.fullscreen and icons.fullscreen_exit or icons.fullscreen end
    ne.tooltipF = function() return state.fullscreen and locale.fullscreen_exit or locale.fullscreen end
    bind_buttons("fullscreen")

    --info
    ne = new_element("info", "button")
    ne.content = icons.info
    ne.tooltipF = locale.stats_info
    bind_buttons("info")

    --ontop
    ne = new_element("ontop", "button")
    ne.content = function () return not state.ontop and icons.ontop_on or icons.ontop_off end
    ne.tooltipF = function ()
        if user_opts.ontop_in_topbar and window_controls_enabled() and state.ontop then return nil end
        return state.ontop and locale.ontop_disable or locale.ontop
    end
    bind_buttons("ontop")

    --screenshot
    ne = new_element("screenshot", "button")
    ne.content = icons.screenshot
    ne.tooltipF = locale.screenshot
    bind_buttons("screenshot")

    --file_loop
    ne = new_element("file_loop", "button")
    ne.content = function() return state.file_loop and icons.loop_on or icons.loop_off end
    ne.tooltipF = function() return state.file_loop and locale.file_loop_enable or locale.file_loop_disable end
    bind_buttons("file_loop")

    --shuffle
    ne = new_element("shuffle", "button")
    ne.content = function() return state.shuffled and icons.shuffle_on or icons.shuffle_off end
    ne.tooltipF = function() return state.shuffled and locale.shuffle or locale.unshuffle end
    ne.eventresponder["mbtn_left_up"] = function()
        mp.commandv("show-text", state.shuffled and locale.unshuffle or locale.shuffle, "-1", "1")
        state.shuffled = not state.shuffled
        mp.command("playlist-" .. (state.shuffled and "shuffle" or "unshuffle"))
    end

    --speed
    ne = new_element("speed", "button")
    ne.content = function() return string.format(state.speed % 1 == 0 and "%.1f×" or "%g×", state.speed) end
    ne.tooltipF = locale.speed_control
    bind_buttons("speed")

    -- cache info
    ne = new_element("cache_info", "button")
    ne.content = function ()
        if not cache_enabled() then return "" end
        local dcs = state.demuxer_cache_state
        local dmx_cache = state.dmx_cache
        local cache_state = dcs and dcs["cache-duration"]
        local thresh = math.min(dmx_cache * 0.05, 5)
        if cache_state and math.abs(cache_state - dmx_cache) >= thresh then
            dmx_cache = cache_state
            state.dmx_cache = cache_state
        end
        local min = math.floor(dmx_cache / 60)
        local sec = math.floor(dmx_cache % 60)
        local cache_time = (min > 0) and string.format("%sm%02ds", min, sec) or string.format("%3ds", sec)
        local cache_info = (mp.get_property_bool("paused-for-cache") == true) and (locale.buffering .. ": " .. (mp.get_property("cache-buffering-state") or 0) .. "%") or cache_time
        if not user_opts.cache_info_speed then return cache_info end
        local dmx_speed = (dcs and dcs["raw-input-rate"]) or 0
        local number, unit = utils.format_bytes_humanized(dmx_speed):match("([%d%.]+)%s*(%S+)")
        return cache_info .. "\\N" .. string.format("%8s %4s/s", number or 0, unit or "B")
    end
    ne.tooltipF = function() return cache_enabled() and locale.cache or nil end
    ne.eventresponder["mbtn_left_up"] = function() mp.command("script-binding stats/display-page-3") end

    --seekbar
    ne = new_element("seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    ne.slider.markerF = function ()
        if state.duration then
            local chapters = state.chapter_list
            local markers = {}
            for n = 1, #chapters do
                markers[n] = (chapters[n].time / state.duration * 100)
            end
            return markers
        else
            return {}
        end
    end
    ne.slider.posF = function ()
        if state.eof_reached then return 100 end
        return frame_number("percent-pos")
    end
    ne.slider.tooltipF = function (pos)
        if state.duration ~= nil and pos ~= nil then return format_time(state.duration * (pos / 100)) end
        return ""
    end
    ne.slider.seekRangesF = build_cache_seek_ranges
    ne.eventresponder["mouse_move"] = function (element)
        if not element.state.mbtnleft then return end -- allow drag for mbtnleft only!
        state.playing_and_seeking = true
        if not mp.get_property_bool("pause") and user_opts.mouse_seek_pause then
            mp.commandv("cycle", "pause")
        end
        local seekto = get_slider_value(element)
        if element.state.lastseek == nil or element.state.lastseek ~= seekto then
            local flags = "absolute-percent"
            if not user_opts.seekbarkeyframes then
                flags = flags .. "+exact"
            end
            mp.commandv("seek", seekto, flags)
            element.state.lastseek = seekto
        end
    end
    ne.eventresponder["mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        element.state.was_paused = mp.get_property_bool("pause")
        state.playing_and_seeking = false
        mp.commandv("seek", get_slider_value(element), "absolute-percent+exact")
    end
    ne.eventresponder["shift+mbtn_left_down"] = function (element)
        element.state.mbtnleft = true
        element.state.was_paused = mp.get_property_bool("pause")
        state.playing_and_seeking = false
        mp.commandv("seek", get_slider_value(element), "absolute-percent")
    end
    ne.eventresponder["mbtn_left_up"] = function (element)
        element.state.mbtnleft = false
        if state.playing_and_seeking then
            -- only unpause if the video was playing before the drag started
            if not element.state.was_paused and not mp.get_property_bool("eof-reached") and user_opts.mouse_seek_pause then
                mp.commandv("cycle", "pause")
            end
            state.playing_and_seeking = false
        end
    end
    ne.eventresponder["mbtn_right_down"] = function (element)
        local chapter
        local pos = get_slider_value(element)
        local diff = math.huge

        for i, marker in ipairs(element.slider.markerF()) do
            if math.abs(pos - marker) < diff then
                diff = math.abs(pos - marker)
                chapter = i
            end
        end

        if chapter then
            mp.set_property("chapter", chapter - 1)
        end
    end
    ne.eventresponder["reset"] = function (element)
        element.state.lastseek = nil
        if element.state.mbtnleft then
            element.state.mbtnleft = false
            if state.playing_and_seeking then
                if not element.state.was_paused and not mp.get_property_bool("eof-reached") and user_opts.mouse_seek_pause then
                    mp.commandv("cycle", "pause")
                end
                state.playing_and_seeking = false
            end
        end
    end
    bind_buttons("seekbar")

    --persistent seekbar
    ne = new_element("persistent_seekbar", "slider")
    ne.enabled = mp.get_property("percent-pos") ~= nil
    ne.slider.markerF = function () return {} end
    ne.slider.posF = function ()
        if state.eof_reached then return 100 end
        return frame_number("percent-pos")
    end
    ne.slider.tooltipF = function() return "" end
    ne.slider.seekRangesF = function()
        if user_opts.persistent_buffer then return build_cache_seek_ranges() end
        return nil
    end

    -- Time codes display
    ne = new_element("time_codes", "button")
    ne.content = function()
        local playback_time = frame_number("playback-time", 0)
        if not state.duration then return "--:--" end

        local playtime_remaining = state.tc_left_rem and frame_number("playtime-remaining", 0) or playback_time
        local prefix = state.tc_left_rem and (user_opts.unicodeminus and UNICODE_MINUS or "-") or ""

        -- call request_init() only when needed to update time code width
        if user_opts.time_format ~= "fixed" and playback_time then
            local hour_or_more = playback_time >= 3600
            if hour_or_more ~= state.playtime_hour_force_init then
                request_init()
                state.playtime_hour_force_init = hour_or_more
            end
        end

        local sep = "{\\1c&H" .. osc_color_convert(user_opts.muted_text_color) .. "&}"
        return prefix .. format_time(playtime_remaining) .. sep .. " / " .. format_time(state.duration)
    end
    ne.eventresponder["mbtn_left_up"] = function()
        state.tc_left_rem = not state.tc_left_rem
        request_init()
    end
    ne.eventresponder["mbtn_right_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end

    -- the glass panel puts the times at the two ends of the seekbar
    local function hour_check(seconds)
        if user_opts.time_format ~= "fixed" and seconds then
            local hour_or_more = seconds >= 3600
            if hour_or_more ~= state.playtime_hour_force_init then
                request_init()
                state.playtime_hour_force_init = hour_or_more
            end
        end
    end
    ne = new_element("time_pos", "button")
    ne.content = function()
        if not state.duration then return "--:--" end
        local t = frame_number("playback-time", 0)
        hour_check(t)
        return format_time(t)
    end
    ne.eventresponder["mbtn_right_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end
    ne = new_element("time_end", "button")
    ne.content = function()
        if not state.duration then return "--:--" end
        if state.tc_left_rem then
            return (user_opts.unicodeminus and UNICODE_MINUS or "-") .. format_time(frame_number("playtime-remaining", 0))
        end
        return format_time(state.duration)
    end
    ne.tooltipF = nil
    ne.eventresponder["mbtn_left_up"] = function()
        state.tc_left_rem = not state.tc_left_rem
        request_init()
    end
    ne.eventresponder["mbtn_right_up"] = function()
        state.tc_ms = not state.tc_ms
        request_init()
    end

    -- more: settings / context menu (REQ-BOT-08)
    ne = new_element("more", "button")
    ne.content = icons.more
    ne.tooltipF = locale.more
    bind_buttons("more")
    if not ne.eventresponder["mbtn_left_up"] then
        ne.eventresponder["mbtn_left_up"] = function() open_menu("context", "more") end
    end

    -- load Screenbox layout
    update_glass_look()
    state.glass_ui = false
    state.tooltip_y = nil
    state.panel_rect = nil
    state.wc_rect = nil
    state.wt_rect = nil
    layouts["screenbox"]()

    -- load window controls
    if window_controls_enabled() then
        window_controls()
    end

    -- cache seekbar elements
    state.persistent_seekbar_element = elements["persistent_seekbar"]
    state.seekbar_element = elements["seekbar"]

    prepare_elements()
    update_margins()
end

local function show_wc()
    show_bar("wc", "wc_showtime", "wc_visible", "wc_anitype", wc_visible)
end

local function hide_wc()
    hide_bar("wc", "wc_visible", "wc_anitype", wc_visible)
end

local function show_osc()
    if state.idle_active then return end
    show_bar("osc", "showtime", "osc_visible", "anitype", osc_visible)
    if window_controls_enabled() and not user_opts.windowcontrols_independent then
        show_wc()
    end
end

local function hide_osc()
    close_menu()
    -- clear input area immediately so clicks pass through while the bar is
    -- hidden, rather than waiting for the next render tick to do it
    set_virt_mouse_area(0, 0, 0, 0, "input")
    set_virt_mouse_area(0, 0, 0, 0, "input_wheel")
    set_virt_mouse_area(0, 0, 0, 0, "input_mid")
    -- reset margins before hide_bar wipes the overlay
    if not state.enabled then
        reset_margins()
    end
    hide_bar("osc", "osc_visible", "anitype", osc_visible)
    if not user_opts.windowcontrols_independent then
        hide_wc()
    end
end

local function mouse_leave()
    -- leaving the bottom bar's area with a menu open is fine, as long as the pointer is in the window
    if menu then
        local mp_pos = mp.get_property_native("mouse-pos")
        if mp_pos and mp_pos.hover then return end
    end
    if get_hidetimeout() >= 0 and get_touchtimeout() <= 0 then
        if user_opts.deadzone_hide == "timeout" then
            local now = mp.get_time()
            if state.osc_visible and not state.keeponpause_active then
                state.showtime = now
            end
            if state.wc_visible then
                state.wc_showtime = now
            end
            request_tick()
        else
            if not state.keeponpause_active then hide_osc() end
            hide_wc()
        end
    end
    -- reset mouse position
    state.last_mouseX, state.last_mouseY = nil, nil
    state.mouse_in_window = false
end

local function handle_touch(_, touchpoints)
    --remember last touch points
    if touchpoints then
        state.touchpoints = touchpoints
        if #touchpoints > 0 then
            --remember last time of invocation (touch event)
            state.touchtime = mp.get_time()
            state.last_touchX = touchpoints[1].x
            state.last_touchY = touchpoints[1].y
        end
    end
end

--
-- Event handling
--
local function reset_timeout()
    local now = mp.get_time()
    if window_controls_enabled() and user_opts.windowcontrols_independent then
        -- only reset the timer for the bar the event belongs to
        if mouse_in_area({"window-controls", "window-controls-title", "window-controls-ontop"}) then
            state.wc_showtime = now
        else
            state.showtime = now
        end
    else
        state.showtime = now
        state.wc_showtime = now
    end
end

local function element_has_action(element, action)
    return element and element.eventresponder and element.eventresponder[action]
end

-- dynamically sets the "input" mouse area to only the hovered element
local click_keys = {
    "mbtn_left_up", "mbtn_left_down", "mbtn_left_press",
    "mbtn_right_up", "mbtn_right_down", "mbtn_right_press",
}
local function has_click_action(e)
    if not e.eventresponder then return false end
    for _, k in ipairs(click_keys) do
        if e.eventresponder[k] then return true end
    end
    return false
end

-- wheel and middle click get their own areas, so over an element that doesn't
-- handle them they fall through to input.conf
local function has_wheel_action(e)
    if not e.eventresponder then return false end
    return e.eventresponder["wheel_up_press"] ~= nil or e.eventresponder["wheel_down_press"] ~= nil
end

local function has_mid_action(e)
    if not e.eventresponder then return false end
    return e.eventresponder["shift+mbtn_left_down"] ~= nil
end

local input_areas = {"input", "input_wheel", "input_mid"}

local function set_input_areas(x0, y0, x1, y1)
    for _, name in ipairs(input_areas) do set_virt_mouse_area(x0, y0, x1, y1, name) end
end

local function refresh_input_area()
    if not state.osc_visible then
        set_input_areas(0, 0, 0, 0)
        return
    end

    -- with a menu open every click is ours (a click outside the menu closes it)
    if menu then
        set_input_areas(0, 0, osc_param.playresx, osc_param.playresy)
        set_virt_mouse_area(0, 0, osc_param.playresx, osc_param.playresy, "menu-hover")
        return
    end

    -- during an active drag, keep the input area locked to the held element
    if state.active_element and elements[state.active_element] then
        local e = elements[state.active_element]
        set_input_areas(e.hitbox.x1, e.hitbox.y1, e.hitbox.x2, e.hitbox.y2)
        return
    end

    -- bail early if the cursor isn't inside the bottom bar zone at all
    if not mouse_in_area("input") then
        set_input_areas(0, 0, 0, 0)
        return
    end

    -- find the topmost element under the cursor for each input type in one pass;
    -- layer order matches process_event's dispatch priority
    local hovered = {input = nil, input_wheel = nil, input_mid = nil}
    for n = 1, #elements do
        local e = elements[n]
        if e.hitbox and mouse_hit(e) then
            if has_click_action(e) then hovered.input = e end
            if has_wheel_action(e) then hovered.input_wheel = e end
            if has_mid_action(e)   then hovered.input_mid = e end
        end
    end

    for _, name in ipairs(input_areas) do
        local e = hovered[name]
        if e then
            set_virt_mouse_area(e.hitbox.x1, e.hitbox.y1, e.hitbox.x2, e.hitbox.y2, name)
        else
            set_virt_mouse_area(0, 0, 0, 0, name)
        end
    end
end

-- re-apply the cursor-hide flag to the OSC input sections that are currently enabled.
-- held = true drops the flag so the cursor stays visible while a button/slider is held.
local function apply_cursor_hide_flag(held)
    local flag = (not held) and state.cursor_hide_flag or nil
    if state.input_enabled then
        for _, name in ipairs(input_areas) do mp.enable_key_bindings(name, flag) end
    end
    if state.windowcontrols_buttons then mp.enable_key_bindings("window-controls", flag) end
    if state.windowcontrols_ontop then mp.enable_key_bindings("window-controls-ontop", flag) end
end

local function process_event(source, what)
    frame_cache = nil  -- input is handled with live values
    local action = string.format("%s%s", source, what and ("_" .. what) or "")

    -- an open menu takes the clicks and the wheel (a click outside closes it)
    if menu_event(source, what) then
        reset_timeout()
        request_tick()
        return
    end

    if what == "down" or what == "press" then
        reset_timeout() -- clicking resets the hideosc timer

        for n = 1, #elements do
            if mouse_hit(elements[n]) and
                elements[n].eventresponder and
                (elements[n].eventresponder[source .. "_up"] or
                    elements[n].eventresponder[action]) then

                if what == "down" then
                    state.active_element = n
                    state.active_event_source = source
                    if state.cursor_hide_flag then apply_cursor_hide_flag(true) end
                end
                -- fire the down or press event if the element has one
                if element_has_action(elements[n], action) then
                    elements[n].eventresponder[action](elements[n])
                end
            end
        end
    elseif what == "up" then
        if elements[state.active_element] then
            local n = state.active_element

            if n == 0 then
                --click on background (does not work)
            elseif element_has_action(elements[n], action) and
                mouse_hit(elements[n]) then

                elements[n].eventresponder[action](elements[n])
            end

            --reset active element
            if element_has_action(elements[n], "reset") then
                elements[n].eventresponder["reset"](elements[n])
            end
        end
        if state.active_element and state.cursor_hide_flag then
            -- button released: let the cursor autohide again
            apply_cursor_hide_flag(false)
        end
        state.active_element = nil
        state.mouse_down_counter = 0
    elseif source == "mouse_move" then
        state.mouse_in_window = true

        local mouseX, mouseY = get_virt_mouse_pos()
        if user_opts.minmousemove == 0 or
            ((state.last_mouseX ~= nil and state.last_mouseY ~= nil) and
                (math.abs(mouseX - state.last_mouseX) >= user_opts.minmousemove or
                 math.abs(mouseY - state.last_mouseY) >= user_opts.minmousemove)) then
            if window_controls_enabled() and user_opts.windowcontrols_independent then
                if mouse_in_area("showhide_wc") then
                    show_wc()
                elseif user_opts.visibility ~= "always" and user_opts.deadzone_hide ~= "timeout" then
                    hide_wc()
                end
                if mouse_in_area("showhide") or menu then
                    show_osc()
                elseif user_opts.visibility ~= "always" and not state.keeponpause_active and user_opts.deadzone_hide ~= "timeout" then
                    hide_osc()
                end
            else
                show_osc()
                if window_controls_enabled() then show_wc() end
            end
        end
        state.last_mouseX, state.last_mouseY = mouseX, mouseY

        local n = state.active_element
        if element_has_action(elements[n], action) then
            elements[n].eventresponder[action](elements[n])
        end

        -- update input area to follow the cursor so only the element
        -- currently under it captures clicks; empty space passes through
        refresh_input_area()
    end

    -- ensure rendering after any (mouse) event - icons could change etc
    request_tick()
end

local function do_enable_keybindings()
    if state.enabled then
        if not state.showhide_enabled then
            mp.enable_key_bindings("showhide", "allow-vo-dragging+allow-hide-cursor")
            mp.enable_key_bindings("showhide_wc", "allow-vo-dragging+allow-hide-cursor")
        end
        state.showhide_enabled = true
    end
end

local function enable_osc(enable)
    state.enabled = enable
    if enable then
        do_enable_keybindings()
    else
        hide_osc() -- acts immediately when state.enabled == false
        hide_wc()
        if state.showhide_enabled then
            mp.disable_key_bindings("showhide")
            mp.disable_key_bindings("showhide_wc")
        end
        state.showhide_enabled = false
    end
end

local function render()
    msg.trace("rendering")
    menu_frame = menu_frame + 1
    frame_cache = {}
    local current_screen_sizeX = state.osd_dimensions.w
    local current_screen_sizeY = state.osd_dimensions.h
    local mouseX, mouseY = get_virt_mouse_pos()
    local now = mp.get_time()

    -- check if display changed, if so request reinit
    if state.screen_sizeX ~= current_screen_sizeX or state.screen_sizeY ~= current_screen_sizeY then
        request_init_resize()

        state.screen_sizeX = current_screen_sizeX
        state.screen_sizeY = current_screen_sizeY
    end

    -- init management
    if state.active_element then
        -- mouse is held down on some element - keep ticking and ignore initReq
        -- till it's released, or else the mouse-up (click) will misbehave or
        -- get ignored. that's because osc_init() recreates the osc elements,
        -- but mouse handling depends on the elements staying unmodified
        -- between mouse-down and mouse-up (using the index active_element).
        request_tick()
    elseif state.initREQ then
        osc_init()
        state.initREQ = false

        -- store initial mouse position
        if (state.last_mouseX == nil or state.last_mouseY == nil) and not (mouseX == nil or mouseY == nil or mouseX == -1 or mouseY == -1) then
            state.last_mouseX, state.last_mouseY = mouseX, mouseY
        end
    end

    -- fade animation
    local function run_fade(anitype_key, anistart_key, animation_key, set_visible)
        local anitype = state[anitype_key]
        if anitype == nil then
            kill_animation(anitype_key, anistart_key, animation_key)
            return
        end
        if state[anistart_key] == nil then state[anistart_key] = now end
        local fadelen = user_opts.fadeduration / 1000
        if now < state[anistart_key] + fadelen then
            -- eased: quick to appear and settling gently, gentle to start leaving
            local p = (now - state[anistart_key]) / fadelen
            if anitype == "in" then
                set_visible(true)
                state[animation_key] = 255 * (1 - p) ^ 3
            elseif anitype == "out" then
                state[animation_key] = 255 * p * p
            end
        else
            if anitype == "in" then
                set_visible(true)
            elseif anitype == "out" then
                set_visible(false)
            end
            kill_animation(anitype_key, anistart_key, animation_key)
        end
    end
    run_fade("anitype",    "anistart",    "animation",    osc_visible)
    run_fade("wc_anitype", "wc_anistart", "wc_animation", wc_visible)

    --mouse show/hide area
    for _, cords in pairs(osc_param.areas["showhide"]) do
        set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide")
    end
    if osc_param.areas["showhide_wc"] then
        for _, cords in pairs(osc_param.areas["showhide_wc"]) do
            set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, "showhide_wc")
        end
    else
        set_virt_mouse_area(0, 0, 0, 0, "showhide_wc")
    end
    do_enable_keybindings()

    --mouse input area
    local function update_input_area(area_name, visible, enabled_key, enable_fn)
        local areas = osc_param.areas[area_name]
        if not areas then return end
        for _, cords in ipairs(areas) do
            if visible then
                set_virt_mouse_area(cords.x1, cords.y1, cords.x2, cords.y2, area_name)
            end
            if visible ~= state[enabled_key] then
                if visible then enable_fn() else mp.disable_key_bindings(area_name) end
                state[enabled_key] = visible
            end
        end
    end

    -- sync input area to cursor position
    if state.osc_visible ~= state.input_enabled then
        for _, name in ipairs(input_areas) do
            if state.osc_visible then
                mp.enable_key_bindings(name, state.cursor_hide_flag)
            else
                mp.disable_key_bindings(name)
            end
        end
        state.input_enabled = state.osc_visible
    end
    refresh_input_area()

    update_input_area("window-controls", state.wc_visible, "windowcontrols_buttons", function() mp.enable_key_bindings("window-controls", state.cursor_hide_flag) end)
    update_input_area("window-controls-title", state.wc_visible, "windowcontrols_title", function() mp.enable_key_bindings("window-controls-title", state.cursor_hide_flag and "allow-vo-dragging+allow-hide-cursor" or "allow-vo-dragging") end)
    update_input_area("window-controls-ontop", state.wc_visible, "windowcontrols_ontop", function() mp.enable_key_bindings("window-controls-ontop", state.cursor_hide_flag) end)

    -- autohide
    local function run_autohide(showtime_key, hide_fn, input_areas)
        local hide_timeout = get_hidetimeout()
        if state[showtime_key] == nil or hide_timeout < 0 then return end
        local timeout = state[showtime_key] + (hide_timeout / 1000) - now
        if timeout <= 0 and get_touchtimeout() <= 0 then
            -- a hold in the bottom bar should not prevent the top bar from hiding, and vice versa.
            local element_blocks_hide = state.active_element ~= nil and mouse_in_area(input_areas)
            if not element_blocks_hide and (not user_opts.keep_with_cursor or not mouse_in_area(input_areas)) then
                hide_fn()
            end
        else
            if not state.hide_timer then
                state.hide_timer = mp.add_timeout(0, tick)
            end
            if timeout < state.hide_timer.timeout then
                state.hide_timer.timeout = timeout
                state.hide_timer:kill()
                state.hide_timer:resume()
            end
        end
    end

    local osc_areas = {"input"}
    local wc_areas  = {"window-controls", "window-controls-title", "window-controls-ontop"}
    if not user_opts.windowcontrols_independent then
        osc_areas = {"input", "window-controls", "window-controls-title", "window-controls-ontop"}
        wc_areas = osc_areas
    end

    if state.hide_timer then state.hide_timer.timeout = math.huge end
    if menu then
        state.showtime = now -- an open menu keeps the controls up
        if not user_opts.windowcontrols_independent then state.wc_showtime = now end
    end
    if not state.keeponpause_active then
        run_autohide("showtime", hide_osc, osc_areas)
    end
    if user_opts.windowcontrols_independent then
        run_autohide("wc_showtime", hide_wc, wc_areas)
    end

    -- actual rendering
    local ass = assdraw.ass_new()

    if state.osc_visible or state.wc_visible then
        render_elements(ass, state.osc_visible, state.wc_visible)
    end

    if menu then
        if state.osc_visible then render_menu(ass, menu) else close_menu() end
    end
    menu_covers_sync()

    if user_opts.persistent_progress or state.persistent_progress_toggle then
        render_persistent_progress(ass)
    end

    if user_opts.window_rounded_corners then
        render_window_corners(ass)
    end

    -- submit
    set_osd(state.osd, osc_param.playresy * osc_param.display_aspect, osc_param.playresy, ass.text, 1000)
    frame_cache = nil
end

-- called by mpv on every frame
tick = function()
    if state.marginsREQ == true then
        update_margins()
        state.marginsREQ = false
    end

    if not state.enabled then return end

    if state.idle_active then
        -- the idle screen doesn't draw menus: close one left open so its keys and covers go
        if menu then close_menu() end
        msg.trace("idle message")
        if user_opts.idlescreen then
            local display_aspect = state.osd_dimensions.aspect
            if display_aspect == 0 then return end
            local display_h = 360
            local display_w = display_h * display_aspect
            -- logo is rendered at 2^(6-1) = 32 times resolution with size 1800x1800
            local icon_x, icon_y = (display_w - 1800 / 32) / 2, 140
            local line_prefix = ("{\\rDefault\\an7\\1a&H00&\\bord0\\shad0\\pos(%f,%f)}"):format(icon_x, icon_y)

            local ass = assdraw.ass_new()
            -- mpv logo
            for _, line in ipairs(logo_lines) do
                ass:new_event()
                ass:append(line_prefix .. line)
            end

            ass:new_event()
            ass:pos(display_w / 2, icon_y + 65)
            ass:an(8)
            ass:append("{\\fs24\\1c&HFFFFFF&}" .. locale.idle)
            set_osd(state.logo_osd, display_w, display_h, ass.text, -1000)
        end

        if state.osc_visible then
            osc_visible(false)
        end

        if window_controls_enabled() then
            render()
        else
            render_wipe(state.osd)
            if state.showhide_enabled then
                mp.disable_key_bindings("showhide")
                mp.disable_key_bindings("showhide_wc")
                state.showhide_enabled = false
            end
        end
    elseif (state.fullscreen and user_opts.showfullscreen) or (not state.fullscreen and user_opts.showwindowed) then
        render_wipe(state.logo_osd)
        render()
    else
        -- Flush OSD
        render_wipe(state.osd)
        render_wipe(state.logo_osd)
    end

    state.tick_last_time = mp.get_time()

    local function tick_animation(anitype_key, anistart_key, animation_key, allow_idle)
        if state[anitype_key] ~= nil then
            if (allow_idle or not state.idle_active) and
               (not state[anistart_key] or
                mp.get_time() < 1 + state[anistart_key] + user_opts.fadeduration / 1000)
            then
                request_tick()
            else
                kill_animation(anitype_key, anistart_key, animation_key)
            end
        end
    end
    tick_animation("anitype",    "anistart",    "animation")
    tick_animation("wc_anitype", "wc_anistart", "wc_animation", window_controls_enabled())
end

local function set_tick_delay(_, display_fps)
    -- may be nil if unavailable, and 0 or NaN when mpv can't tell the refresh rate
    if not user_opts.tick_delay_follow_display_fps or type(display_fps) ~= "number"
        or display_fps ~= display_fps or display_fps < 1 or display_fps > 1000 then
        tick_delay = user_opts.tick_delay
        return
    end
    tick_delay = 1 / display_fps
end

mp.register_event("shutdown", function()
    reset_margins()
    mp.del_property("user-data/osc")
end)
mp.register_event("file-loaded", function()
    state.file_loaded = true
    local oos = user_opts.osc_on_start
    if oos == "bottom" or oos == "both" then show_osc() end
    if oos == "top" or oos == "both" then show_wc() end
end)
mp.register_event("start-file", function()
    -- reset ab loop on new file start
    mp.set_property("ab-loop-a", "no")
    mp.set_property("ab-loop-b", "no")
    request_init()
end)
mp.observe_property("track-list", "native", update_tracklist)
observe_cached("playlist-count", request_init)
observe_cached("playlist-pos-1", request_init)
observe_cached("chapter-list", function ()
    state.chapter_list = state.chapter_list or {}
    table.sort(state.chapter_list, function(a, b) return a.time < b.time end)
    request_init()
end)
observe_cached("duration", function ()
    if user_opts.automatickeyframemode then
        user_opts.seekbarkeyframes = (state.duration or 0) > user_opts.automatickeyframelimit
    end
    if user_opts.livemarkers and state.chapter_list[1] then
        request_init()
    end
end)
mp.register_event("seek", function()
    if state.file_loaded then
        state.file_loaded = false
        return
    end
    if user_opts.osc_on_seek and not (state.file_loop and mp.get_property_number("time-pos", -1) == 0) then
        show_osc()
    end
end)
mp.observe_property("seeking", "native", function(_, seeking)
    if user_opts.osc_on_seek then
        reset_timeout()
    end
end)
observe_cached("fullscreen", function ()
    state.marginsREQ = true
    request_init_resize()
end)
observe_cached("border", request_init_resize)
observe_cached("title-bar", request_init_resize)
observe_cached("window-maximized", request_init_resize)
observe_cached("idle-active", request_tick)
mp.observe_property("user-data/mpv/console/open", "bool", function(_, val)
    if val and user_opts.visibility == "auto" and not user_opts.showonselect and not state.keeponpause_active then
        osc_visible(false)
        wc_visible(false)
    end
end)
mp.observe_property("display-fps", "number", set_tick_delay)
mp.observe_property("display-hidpi-scale", "number", function() request_init_resize() end)
observe_cached("demuxer-cache-state", request_tick)
mp.observe_property("vo-configured", "bool", request_tick)
mp.observe_property("playback-time", "number", request_tick)
observe_cached("osd-dimensions", request_init_resize)
observe_cached("osd-scale-by-window", request_init_resize)
mp.observe_property("touch-pos", "native", handle_touch)
observe_cached("volume", request_tick)
observe_cached("mute", request_tick)
observe_cached("eof-reached", request_tick)
observe_cached("ontop", request_init)
observe_cached("speed", request_tick)
-- the layout reserves a chapter title row only while inside a chapter, so rebuild it
-- when playback enters or leaves the chapter range (e.g. starting before the first chapter)
mp.observe_property("chapter", "native", function(_, value)
    local was_in_chapter = (state.chapter or -1) >= 0
    state.chapter = value
    if user_opts.show_chapter_title and was_in_chapter ~= ((value or -1) >= 0) then
        request_init()
    else
        request_tick()
    end
end)
-- redraw the A-B loop range when loop points change, even while paused
mp.observe_property("ab-loop-a", "native", request_tick)
mp.observe_property("ab-loop-b", "native", request_tick)
-- ensure compatibility with auto loop scripts
mp.observe_property("loop-file", "bool", function(_, val)
    state.file_loop = (val ~= false)
end)
mp.observe_property("sub-pos", "native", function(_, value)
    if value == nil then return end
    -- ignore async echoes of our own set_sub_pos() calls so they never overwrite state.user_subpos
    local q = state.pending_subpos_writes
    for i = 1, #q do
        if q[i] == value then
            for _ = 1, i do table.remove(q, 1) end
            return
        end
    end
    if state.osc_adjusted_subpos ~= nil and value == state.osc_adjusted_subpos then
        return
    end
    state.user_subpos = value
end)

-- mouse show/hide bindings
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
    {"mouse_leave",             mouse_leave},
}, "showhide", "force")
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
    {"mouse_leave",             mouse_leave},
}, "showhide_wc", "force")
-- while a menu is open: pointer moves over the whole window
mp.set_key_bindings({
    {"mouse_move",              function() process_event("mouse_move", nil) end},
}, "menu-hover", "force")
do_enable_keybindings()

--mouse input bindings
mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
    {"shift+mbtn_left",     function() process_event("shift+mbtn_left", "up") end,
                            function() process_event("shift+mbtn_left", "down")  end},
    {"mbtn_right",          function() process_event("mbtn_right", "up") end,
                            function() process_event("mbtn_right", "down")  end},
    {"shift+mbtn_right",    function() process_event("shift+mbtn_right", "up") end,
                            function() process_event("shift+mbtn_right", "down")  end},
    {"mbtn_left_dbl",       "ignore"},
    {"shift+mbtn_left_dbl", "ignore"},
    {"mbtn_right_dbl",      "ignore"},
}, "input", "force")
mp.enable_key_bindings("input", state.cursor_hide_flag)

mp.set_key_bindings({
    {"wheel_up",   function() process_event("wheel_up", "press") end},
    {"wheel_down", function() process_event("wheel_down", "press") end},
}, "input_wheel", "force")
mp.enable_key_bindings("input_wheel", state.cursor_hide_flag)

-- alias to shift_mbtn_left for single-handed mouse use
mp.set_key_bindings({
    {"mbtn_mid", function() process_event("shift+mbtn_left", "up") end,
                 function() process_event("shift+mbtn_left", "down")  end},
}, "input_mid", "force")
mp.enable_key_bindings("input_mid", state.cursor_hide_flag)

mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
}, "window-controls", "force")
mp.enable_key_bindings("window-controls", state.cursor_hide_flag)

mp.set_key_bindings({
    {"mbtn_left",           function() process_event("mbtn_left", "up") end,
                            function() process_event("mbtn_left", "down")  end},
}, "window-controls-ontop", "force")
set_virt_mouse_area(0, 0, 0, 0, "window-controls-ontop")

local function always_on(val)
    if state.enabled then
        if val then
            show_osc()
            show_wc()
        else
            hide_osc()
            hide_wc()
        end
    end
end

-- mode can be auto/always/never/cycle
-- the modes only affect internal variables and not stored on its own.
local function visibility_mode(mode, no_osd)
    if mode == "cycle" then
        for i, allowed_mode in ipairs(state.visibility_modes) do
            if i == #state.visibility_modes then
                mode = state.visibility_modes[1]
                break
            elseif user_opts.visibility == allowed_mode then
                mode = state.visibility_modes[i + 1]
                break
            end
        end
    end

    if mode == "auto" then
        always_on(false)
        enable_osc(true)
    elseif mode == "always" then
        enable_osc(true)
        always_on(true)
    elseif mode == "never" then
        enable_osc(false)
        state.osc_visible = false
        state.wc_visible = false
    else
        msg.warn("Ignoring unknown visibility mode '" .. mode .. "'")
        return
    end

    user_opts.visibility = mode
    mp.set_property_native("user-data/osc/visibility", mode)

    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC visibility: " .. mode)
    end

    -- Reset the input state on a mode change. The input state will be
    -- recalculated on the next render cycle, except in 'never' mode where it
    -- will just stay disabled.
    mp.disable_key_bindings("input")
    mp.disable_key_bindings("input_wheel")
    mp.disable_key_bindings("input_mid")
    mp.disable_key_bindings("window-controls")
    mp.disable_key_bindings("window-controls-title")
    mp.disable_key_bindings("window-controls-ontop")
    state.input_enabled = false
    state.windowcontrols_buttons = false
    state.windowcontrols_title = false
    state.windowcontrols_ontop = false

    update_margins()
    request_tick()
end

local function idlescreen_visibility(mode, no_osd)
    if mode == "cycle" then
        mode = user_opts.idlescreen and "no" or "yes"
    end

    user_opts.idlescreen = (mode == "yes")

    mp.set_property_native("user-data/osc/idlescreen", user_opts.idlescreen)

    if not no_osd and tonumber(mp.get_property("osd-level")) >= 1 then
        mp.osd_message("OSC logo visibility: " .. tostring(mode))
    end

    request_tick()
end

mp.observe_property("pause", "bool", function(_, enabled)
    state.pause = (enabled == true)
    request_tick()
    if user_opts.showonpause and user_opts.visibility ~= "never" then
        state.enabled = enabled
        if enabled then
            if user_opts.keeponpause == "both" then
                -- save mode and set visibility to "always" temporarily
                if not state.keeponpause_restore and user_opts.visibility ~= "always" then
                    state.keeponpause_restore = user_opts.visibility
                end
                visibility_mode("always", true)
            elseif user_opts.keeponpause == "bottombar" then
                state.keeponpause_active = true
                show_osc()
            else
                show_osc()
            end
        else
            -- clear keeponpause bottombar active state
            state.keeponpause_active = false
            -- restore mode if it was changed by keeponpause=both
            if state.keeponpause_restore then
                visibility_mode(state.keeponpause_restore, true)
                state.keeponpause_restore = nil
            else
                -- respect "always" mode on unpause
                visibility_mode(user_opts.visibility, true)
            end
            -- reset timers so both bars get a fresh hidetimeout on unpause
            local now = mp.get_time()
            if state.osc_visible then state.showtime = now end
            if state.wc_visible then state.wc_showtime = now end
        end
    end
end)

mp.register_script_message("osc-visibility", visibility_mode)
-- for input.conf: script-message-to modernz open-menu <audio|sub|playlist|chapter|audio-device>
mp.register_script_message("open-menu", function(kind)
    -- with no OSC to draw it on, the menu would stay invisible and keep its keys bound
    if not state.enabled or state.idle_active then return end
    show_osc()
    open_menu(kind, nil)
end)
-- right click and mpv's other context menu keys open the glass menu at the pointer, or
-- above the panel when the pointer is outside the window (keys bound in input.conf
-- still win over these)
for key, name in pairs({MBTN_RIGHT = "context-menu", MENU = "context-menu-key", ["Shift+F10"] = "context-menu-shift-f10"}) do
    mp.add_key_binding(key, name, function(e)
        if e.event ~= "up" and e.event ~= "press" then return end
        -- the idle screen and visibility=never have no controls to open it from
        if state.idle_active or not state.enabled then
            mp.commandv("script-binding", "select/context-menu")
            return
        end
        if menu then
            close_menu()
            return
        end
        local x, y = get_virt_mouse_pos()
        show_osc()
        open_menu("context", nil, {at = x >= 0 and {x = x, y = y} or nil})
    end, {complex = true})
end
-- for input.conf: script-message-to modernz screenshot [video|subtitles|window]
mp.register_script_message("screenshot", function(mode)
    mp.command("osd-msg screenshot " .. (mode or "subtitles"))
end)
mp.register_script_message("osc-show", show_osc)
mp.register_script_message("osc-hide", function()
    if user_opts.visibility == "auto" then
        hide_osc()
        hide_wc()
    end
end)
mp.add_key_binding(nil, "visibility", function() visibility_mode("cycle") end)
mp.add_key_binding(nil, "progress-toggle", function()
    user_opts.persistent_progress = not user_opts.persistent_progress
    state.persistent_progress_toggle = user_opts.persistent_progress
    request_init()
end)
mp.register_script_message("osc-idlescreen", idlescreen_visibility)

-- validate string type user options
local function validate_user_opts()
    if not language[user_opts.language] then
       msg.warn("language '" .. user_opts.language .. "' not found. Ignoring.")
       user_opts.language = "default"
       if not language["default"] then
          msg.warn("ERROR: can't find the default language or the one set by user_opts.")
       end
    end

    if user_opts.seek_handle_size < 0 then
        msg.warn("seek_handle_size must be 0 or higher. Setting it to 0 (minimum).")
        user_opts.seek_handle_size = 0
    end

    local function validate_string_opt(key, valid, default)
        for _, v in ipairs(valid) do
            if user_opts[key] == v then return end
        end
        msg.warn(key .. " value '" .. tostring(user_opts[key]) .. "' is invalid. Resetting to '" .. default .. "'.")
        user_opts[key] = default
    end
    validate_string_opt("window_top_bar", {"auto", "yes", "no"}, "yes")
    validate_string_opt("volume_control_type", {"linear", "logarithmic"}, "linear")
    validate_string_opt("keeponpause",  {"no", "bottombar", "both"}, "both")
    validate_string_opt("deadzone_hide", {"instant", "timeout"}, "timeout")

    local hbc = user_opts.seek_handle_border_color
    if hbc == "disable" then
        hbc = ""
    elseif hbc ~= "" and hbc:find("^#%x%x%x%x%x%x$") == nil then
        msg.warn("'" .. hbc .. "' is not a valid color for seek_handle_border_color, border disabled")
        hbc = ""
    end
    user_opts.seek_handle_border_color = hbc

    local colors = {
        user_opts.osc_color, user_opts.seekbarfg_color, user_opts.seekbarbg_color, user_opts.title_color, user_opts.time_color,
        user_opts.side_buttons_color, user_opts.middle_buttons_color, user_opts.playpause_color, user_opts.window_title_color,
        user_opts.window_controls_color, user_opts.held_element_color, user_opts.chapter_title_color,
        user_opts.seekbar_cache_color, user_opts.hover_effect_color, user_opts.windowcontrols_close_hover, user_opts.windowcontrols_max_hover,
        user_opts.windowcontrols_min_hover, user_opts.cache_info_color, user_opts.nibble_color,
        user_opts.nibble_current_color, user_opts.seek_handle_color, user_opts.ab_loop_color,
    }

    for _, color in pairs(colors) do
        if color:find("^#%x%x%x%x%x%x$") == nil then
            msg.warn("'" .. color .. "' is not a valid color")
        end
    end

    state.visibility_modes = {}
    for str in string.gmatch(user_opts.visibility_modes, "([^_]+)") do
        if str ~= "auto" and str ~= "always" and str ~= "never" then
            msg.warn("Ignoring unknown visibility mode '" .. str .."' in list")
        else
            table.insert(state.visibility_modes, str)
        end
    end

    if user_opts.keeponpause ~= "no" and not user_opts.showonpause then
        msg.warn("keeponpause requires showonpause. Setting showonpause=yes.")
        user_opts.showonpause = true
    end

    -- with keep_with_cursor=no, let mpv's cursor-autohide work while hovering the OSC
    state.cursor_hide_flag = (not user_opts.keep_with_cursor) and "allow-hide-cursor" or nil

    -- hide mpv's built-in wide OSD bar (e.g. volume/seek bar) while keeping OSD text
    if user_opts.hide_osd_bar then
        if state.user_osd_bar == nil then
            state.user_osd_bar = mp.get_property_bool("osd-bar", true)
        end
        mp.set_property_bool("osd-bar", false)
    elseif state.user_osd_bar ~= nil then
        mp.set_property_bool("osd-bar", state.user_osd_bar)
        state.user_osd_bar = nil
    end

    -- static top-left OSD vertical margin so Volume% stays permanently below the top bar without dynamic jumping
    if not user_opts.osd_margins and user_opts.osd_margin_y and user_opts.osd_margin_y > 0 then
        if state.user_static_osd_margin_y == nil then
            state.user_static_osd_margin_y = mp.get_property_number("osd-margin-y", 22)
        end
        mp.set_property_number("osd-margin-y", user_opts.osd_margin_y)
    elseif state.user_static_osd_margin_y ~= nil then
        mp.set_property_number("osd-margin-y", state.user_static_osd_margin_y)
        state.user_static_osd_margin_y = nil
    end

    local watch_later = "," .. ((mp.get_property("options/watch-later-options") or ""):gsub("%s+", "")) .. ","
    if user_opts.sub_margins and watch_later:find(",sub-pos,", 1, true) then
        msg.warn("sub_margins conflict: add watch-later-options-remove=sub-pos to mpv.conf")
    end
    if user_opts.osd_margins and watch_later:find(",osd-margin-y,", 1, true) then
        msg.warn("osd_margins conflict: add watch-later-options-remove=osd-margin-y to mpv.conf")
    end
end

-- read options from config and command-line
opt.read_options(user_opts, "modernz", function(changed)
    if changed.language then load_locale_file() end
    validate_user_opts()
    if changed.keep_with_cursor then apply_cursor_hide_flag(false) end
    if changed.language then set_osc_locale() end
    set_icon_theme()
    set_osc_styles()
    set_time_styles(changed.timecurrent, changed.timems)
    if changed.tick_delay or changed.tick_delay_follow_display_fps then
        set_tick_delay("display_fps", mp.get_property_number("display_fps"))
    end
    request_tick()
    if changed.visibility then
        visibility_mode(user_opts.visibility, true)
    end
    request_init()
end)

load_locale_file()
validate_user_opts()
set_osc_locale()
set_icon_theme()
set_osc_styles()
set_time_styles(true, true)
set_tick_delay()
visibility_mode(user_opts.visibility, true)

set_virt_mouse_area(0, 0, 0, 0, "input")
set_virt_mouse_area(0, 0, 0, 0, "input_wheel")
set_virt_mouse_area(0, 0, 0, 0, "input_mid")
set_virt_mouse_area(0, 0, 0, 0, "window-controls")
set_virt_mouse_area(0, 0, 0, 0, "window-controls-title")
