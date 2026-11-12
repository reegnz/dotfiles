;; QMacK keyboard config. init.lua loads this file with loadFennel and passes the
;; list it returns to start(). The macros come from the QMacK Spoon.
(import-macros {: defsrc : deflayer} :qmack-macros)

;; Physical keys, in the order every layer uses.
(defsrc
  escape
  "`"              1     2    3    4     5    6    7    8    9      0      -      =      delete
  tab              q     w    e    r     t    y    u    i    o      p      "["    "]"    "\\"
  KC_F18           a     s    d    f     g    h    j    k    l      ";"    "'"    return
  lshift           z     x    c    v     b    n    m    ","  .      /      rshift
  fn               lctrl lalt lcmd space rcmd ralt left down up     right)

;; Caps Lock (F18) taps Escape and holds the sym layer.
(deflayer default
  _
  ______           _     _    _    _     _    _    _    _    _      _      _      _      ______
  ___              _     _    _    _     _    _    _    _    _      _      ___    ___    ____
  "LT(sym,escape)" _     _    _    _     _    _    _    _    _      ___    ___    ______
  ______           _     _    _    _     _    _    _    ___  _      _      ______
  __               _____ ____ ____ _____ ____ ____ _    _    _      _)

;; Caps Lock held: . ~  ' `  \ |  ; :
(deflayer sym
  _
  ______           _     _    _    _     _    _    _    _    _      _      _      _      ______
  ___              _     _    _    _     _    _    _    _    _      _      ___    ___    "S(\\)"
  ______           _     _    _    _     _    _    _    _    _      "S(;)" "`"    ______
  ______           _     _    _    _     _    _    _    ___  "S(`)" _      ______
  __               _____ ____ ____ _____ ____ ____ _    _    _      _)

[{:src src
  :keyboards [91] ; built-in MacBook keyboard only (found with a 60 s key probe)
  :holdOnOtherKey true ; Caps + any key is the sym layer at once, so a roll never sends Escape
  :layers {: default : sym}}]
