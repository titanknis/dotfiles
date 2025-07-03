# Tell qutebrowser not to load any GUI/`:set` settings:
c = c
config = config

config.load_autoconfig()


# ─── Appearance ────────────────────────────────────────────────────────────────

# TokyoNight Color Scheme for Qutebrowser
# config.source("themes/tokyonight.py")  # Optional: Save as separate file
# config.source("themes/tokyonight.py")  # Optional: Save as separate file
config.source("themes/gruvbox.py")


c.fonts.default_family = "JetBrains Mono Nerd Font"

# Hide statusbar unless in a mode (e.g. insert, hint)
# Default is 'always'; change only if you want it hidden when idle.
# c.statusbar.show = "in-mode"

# Show tab bar only if more than one tab is open
# Default is 'always'; set to 'multiple' to hide when only one tab exists.
c.tabs.show = "multiple"

# Enable dark mode for all webpages (default is False)
# c.colors.webpage.darkmode.enabled = True
c.colors.webpage.preferred_color_scheme = "dark"


# ─── Keybindings ──────────────────────────────────────────────────────────────

# Exit insert mode with Escape (default <Escape> behavior is just to clear any
# ongoing key sequence; this makes it leave insert mode explicitly)
# config.bind("<Escape>", "mode-leave", mode="insert")


# ─── Hints ────────────────────────────────────────────────────────────────────

# Use home-row characters for link hints (default is 'abcdefghijklmnopqrstuvwxyz')
# c.hints.chars = "asdfghjkl" # qwerty
c.hints.chars = "arstgmneio"  # colemak-dh


# ─── URL / Startup ─────────────────────────────────────────────────────────────

# Set homepage and start page to DuckDuckGo (defaults are about:blank)
# c.url.start_pages = ["~/.config/qutebrowser/themes/startpage-tokyonight.html"]
# c.url.default_page = "~/.config/qutebrowser/themes/startpage-tokyonight.html"
c.url.start_pages = ["~/.config/qutebrowser/themes/gruvbox-startpage.html"]
c.url.default_page = "~/.config/qutebrowser/themes/gruvbox-startpage.html"


# ─── Adblocking ────────────────────────────────────────────────────────────────

# # Use both hosts file and adblock lists (default is 'auto')
# c.content.blocking.method = "both"
#
# # Apply community-maintained EasyList and EasyPrivacy (default list is empty)
# c.content.blocking.adblock.lists = [
#     "https://easylist.to/easylist/easylist.txt",
#     "https://easylist.to/easylist/easyprivacy.txt",
# ]


# ─── Scrolling ─────────────────────────────────────────────────────────────────

# Enable smooth scrolling (default is False)
c.scrolling.smooth = True


# ─── Downloads ─────────────────────────────────────────────────────────────────

# Change default download directory (default is '~/Downloads', but set explicitly)
c.downloads.location.directory = "~/Downloads"


# ─── External Editor ───────────────────────────────────────────────────────────

# Use Neovim as qutebrowser’s external editor for :edit-text (default editor is vi)
c.editor.command = ["nvim", "{}"]


# ─── Others ────────────────────────────────────────────────────────────────────
# c.auto_save.session = True  # save tabs on quit/restart
c.url.searchengines = {
    # note - if you use duckduckgo, you can make use of its built in bangs, of which there are many! https://duckduckgo.com/bangs
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "!ai": "https://duckduckgo.com/?q={}&ia=chat&bang=true",
    "!duck": "https://duckduckgo.com/?q={}&ia=chat&bang=true",
    "!chat": "https://chatgpt.com/?model=auto&q={}",
    "!google": "https://www.google.com/search?q={}",
    "!yt": "https://www.youtube.com/results?search_query={}",
    "!nixpkgs": "https://search.nixos.org/packages?channel=unstable&query={}",
    "!nixopts": "https://search.nixos.org/options?channel=unstable&query={}",
    "!homeopts": "https://home-manager-options.extranix.com/?query={}",
    "!gh": "https://github.com/search?o=desc&q={}&s=stars",
    "!ud": "https://www.urbandictionary.com/define.php?term={}",
}

# c.completion.open_categories = [
#     "searchengines",
#     "quickmarks",
#     "bookmarks",
#     "history",
#     "filesystem",
# ]

config.bind("<z><l>", "spawn --userscript qute-pass")
config.bind("<z><u>", "spawn --userscript qute-pass --username-only")
config.bind("<z><p>", "spawn --userscript qute-pass --password-only")
config.bind("<z><o>", "spawn --userscript qute-pass --otp-only")

config.bind(
    ",p", "spawn --userscript view_in_mpv"
)  # i am wondering what is better this userscript or just using mpv with a mpv.conf

# # Bindings for normal mode
# NOTE: Tip: create and use ~/.config/mpv/mpv.conf ~/.config/yt-dlp/config to simplify these commands and your life
config.bind(";m", "hint links spawn mpv {hint-url}")
config.bind(",m", "spawn mpv {url}")

config.bind(
    ";v",
    "hint links spawn kitty -e yt-dlp -P '~/Downloads/Youtube' {hint-url}",
)
config.bind(
    ",v",
    "           spawn kitty -e yt-dlp -f 'bestvideo[height<=1080]+bestaudio/best' -P '~/Downloads/Youtube'  {url}",
)

config.bind(
    ";a",
    "hint links spawn kitty -e yt-dlp -x --audio-quality 0 -P '~/Downloads/Youtube/music'  {hint-url}",
)
config.bind(
    ",a",
    "           spawn kitty -e yt-dlp -x --audio-quality 0 -P '~/Downloads/Youtube/music'  {url}",
)

# config.bind(
#     ";m",
#     "hint links spawn kitty -e yt-dlp -f 'bestvideo+bestaudio/best' -P '~/Downloads/Youtube'  {hint-url}",
# )

#
# config.bind("xb", "config-cycle statusbar.show always never")
# config.bind("xt", "config-cycle tabs.show always never")
# config.bind(
#     "xx",
#     "config-cycle statusbar.show always never;; config-cycle tabs.show always never",
# )
