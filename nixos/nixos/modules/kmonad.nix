{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.kmonad = {
    enable = true;
    keyboards = {
      myKMonadOutput = {
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        config = ''
          (defcfg
            ;; ** For Linux **
            input  (device-file "/dev/input/by-id/usb-04d9_USB-HID_Keyboard-event-kbd")
            ;; input  (device-file "/dev/input/by-id/usb-Matias_Ergo_Pro_Keyboard-event-kbd")
            output (uinput-sink "KMonad output")

            ;; ** For Windows **
            ;; input  (low-level-hook)
            ;; output (send-event-sink)

            ;; ** For MacOS **
            ;; input  (iokit-name "my-keyboard-product-string")
            ;; output (kext)

            fallthrough true
          )

          (defsrc
            esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
            grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab     q    w    e    r    t    y    u    i    o    p    [    ]    \
            caps    a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft      z    x    c    v    b    n    m    ,    .    /    rsft
            lctl    lmet lalt           spc            ralt rmet cmp  rctl
          )

          (defalias
            ext  (layer-toggle extend) ;; Bind 'ext' to the Extend Layer
          )

          ;; these weird mappings are a workaround to make aliases(like cpy) work on colemak-dh. other extend layer keys will work as usual
          (defalias
            cpy C-x ;; Physical X key → C-c (copy) in Colemak-DH
            pst C-v
            cut C-z
            udo C-b
            all C-a
            fnd C-e

            bk Back
            fw Forward
          )

          ;; Transparent layer mirroring the physical layout
          (deflayer base 
            esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
            grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
            tab     q    w    e    r    t    y    u    i    o    p    [    ]    \
            @ext    a    s    d    f    g    h    j    k    l    ;    '    ret
            lsft      z    x    c    v    b    n    m    ,    .    /    rsft
            lctl    lmet lalt           spc            ralt rmet cmp  rctl
          )

          (deflayer extend
            _        play rewind previoussong nextsong ejectcd refresh brdn brup www mail prog1 prog2
            _        f1   f2   f3   f4   f5   f6   f7   f8   f9  f10   f11  f12  _
            _        esc  @bk  @fnd @fw  ins  pgup home up   end  menu prnt slck _
            _        lalt lmet lsft lctl ralt pgdn lft  down rght del  caps _
            _          @cut @cpy  tab  @pst @udo pgdn bks  lsft lctl comp _
            _        _    _              ret            _    _    _    _
          )

          (deflayer empty
            _        _    _    _    _    _    _    _    _    _    _    _    _
            _        _    _    _    _    _    _    _    _    _    _    _    _    _
            _        _    _    _    _    _    _    _    _    _    _    _    _    _
            _        _    _    _    _    _    _    _    _    _    _    _    _
            _          _    _    _    _    _    _    _    _    _    _    _
            _        _    _              _              _    _    _    _
          )



        '';
        # just for referance
        # (deflayer colemak-dh
        #   esc     f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12
        #   grv      1    2    3    4    5    6    7    8    9    0    -    =    bspc
        #   tab      q    w    f    p    b    j    l    u    y    ;    [    ]    \\
        #   @ext     a    r    s    t    g    m    n    e    i    o    '    ret
        #   lsft       x    c    d    v    z    k    h    ,    .    /    rsft
        #   lctl     lmet lalt           spc            ralt rmet _    _
        # )
      };
    };
  };
}
