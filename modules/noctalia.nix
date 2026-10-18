{ config, pkgs, ... }:

{
  programs.noctalia = {
    enable = true;
    # Whole shell config lives here (migrated from the GUI state file).
    # Keys that also exist in ~/.local/state/noctalia/settings.toml take
    # precedence over this file (it is watched and reloaded live), so keep the
    # two in sync — e.g. theme.templates.builtin_ids is mirrored in the state
    # file. Wallhaven is an official plugin: enable + widget + bar slot.
    settings = ''
      config_version = 15

      [bar.default]
      capsule = true
      center = [ "workspaces" ]
      end = [ "tray", "notifications", "clipboard", "group:g2", "volume", "battery", "brightness", "control-center", "session" ]
      font_family = "Kode Mono Medium"
      margin_edge = 8
      margin_ends = 8
      start = [ "group:g1", "wallpaper", "wallhaven", "clock", "group:g4", "media" ]
      widget_spacing = 4

          [[bar.default.capsule_group]]
          fill = "surface_variant"
          id = "g1"
          members = [ "launcher" ]
          opacity = 1.0
          padding = 6.0

          [[bar.default.capsule_group]]
          fill = "surface_variant"
          id = "g2"
          members = [ "network", "bluetooth" ]
          opacity = 1.0
          padding = 6.0

          [[bar.default.capsule_group]]
          fill = "surface_variant"
          id = "g4"
          members = [ "sysmon", "temp", "ram" ]
          opacity = 1.0
          padding = 6.0

      [brightness]
      minimum_brightness = 0.099999997764825821

      [lockscreen_widgets]
      enabled = false
      schema_version = 2
      widget_order = [ "lockscreen-login-box@HDMI-A-1", "lockscreen-login-box@eDP-1" ]

          [lockscreen_widgets.grid]
          cell_size = 16
          major_interval = 4
          visible = true

          [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-1"]
          box_height = 196.0
          box_width = 720.0
          cx = 683.0
          cy = 649.0
          output = "HDMI-A-1"
          placement_height = 1080.0
          placement_width = 1920.0
          rotation = 0.0
          type = "login_box"

              [lockscreen_widgets.widget."lockscreen-login-box@HDMI-A-1".settings]
              background_color = "surface_variant"
              background_opacity = 0.88
              background_radius = 12.0
              center_password_text = false
              input_opacity = 1.0
              input_radius = 6.0
              layout = "regular"
              show_caps_lock = true
              show_keyboard_layout = true
              show_login_button = true
              show_media = true
              show_session_buttons = true
              show_unlock_hint = true
              show_weather = true

          [lockscreen_widgets.widget."lockscreen-login-box@eDP-1"]
          box_height = 196.0
          box_width = 720.0
          cx = 768.0
          cy = 745.0
          output = "eDP-1"
          placement_height = 864.0
          placement_width = 1536.0
          rotation = 0.0
          type = "login_box"

              [lockscreen_widgets.widget."lockscreen-login-box@eDP-1".settings]
              background_color = "surface_variant"
              background_opacity = 0.88
              background_radius = 12.0
              center_password_text = false
              input_opacity = 1.0
              input_radius = 6.0
              layout = "regular"
              show_caps_lock = true
              show_keyboard_layout = true
              show_login_button = true
              show_media = true
              show_session_buttons = true
              show_unlock_hint = true
              show_weather = true

      [nightlight]
      enabled = true

      [plugins]
      enabled = [ "noctalia/timer", "noctalia/bongocat", "noctalia/wallhaven" ]

      [shell]
      app_icon_color = "shadow"
      avatar_path = "/home/ruyam/media/pictures/Screenshots/Screenshot from 2026-06-11 11-46-14.png"
      font_family = "JetBrains Mono"
      settings_show_advanced = false

      [theme]
      builtin = "Eldritch"
      community_palette = "Catppuccin Frappe Lavender"
      mode = "dark"
      source = "wallpaper"
      wallpaper_scheme = "m3-tonal-spot"

          [theme.templates]
          builtin_ids = [
              "alacritty",
              "btop",
              "ghostty",
              "gtk3",
              "gtk4",
              "kcolorscheme",
              "niri",
              "qt"
          ]
          enable_builtin_templates = true

      [wallpaper]
      directory = "/home/ruyam/media/pictures/Wallpapers"
      transition_on_startup = true

          [wallpaper.default]
          path = "/home/ruyam/media/pictures/Wallpapers/wallhaven_1pj2d1.jpg"


      [widget.wallhaven]
      type = "noctalia/wallhaven:wallhaven"

      [widget.media]
      max_length = 100
      title_scroll = "on_hover"
    '';
  };
}
