# qt apps outside plasma: use the kde platform theme so kdeglobals
# (BreezeDark) drives colors. overrides qt5ct from /etc/environment.
export QT_QPA_PLATFORMTHEME=kde
unset QT_STYLE_OVERRIDE
