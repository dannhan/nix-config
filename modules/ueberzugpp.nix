# Image preview backend for ranger (preview_images_method = ueberzug).
# `chafa` picks the best protocol per terminal at runtime: kitty graphics
# protocol in ghostty, ANSI-symbol fallback in terminals without image
# protocol support (e.g. alacritty).
{
  xdg.configFile."ueberzugpp/config.json".text = ''
    {
      "layer": {
        "output": "chafa"
      }
    }
  '';
}
