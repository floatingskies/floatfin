function fish_greeting
    # Floatfin login banner: a fastfetch system summary with the foxy.txt
    # mascot (config: /usr/share/ublue-os/fastfetch.jsonc). Skipped if the
    # bash login already greeted us (UWELCOME_SHOWN is inherited) or the
    # user opted out with ~/.config/no-show-user-motd.
    if test -e ~/.config/no-show-user-motd
        return
    end
    if test -n "$UWELCOME_SHOWN"
        return
    end
    if not set -q UWELCOME_SHOWN
        set -gx UWELCOME_SHOWN 1
        type -q fastfetch; and fastfetch --config /usr/share/ublue-os/fastfetch.jsonc
        echo '  wizard-fox tip: type "float" for a guided tour (beginner, workbench or power)'
    end
end