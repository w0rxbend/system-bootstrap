#!/usr/bin/env bash
set -euo pipefail

# Flatpak apps from Flathub, in one non-interactive transaction.
# Run by modules/desktop/setup.sh after it adds the flathub remote.
# GNOME-only apps are installed by modules/gnome/setup.sh.

APPS=(
    # Internet Browsers
    io.gitlab.librewolf-community
    com.google.Chrome
    com.brave.Browser
    app.zen_browser.zen
    dev.zed.Zed
    # Communication
    org.telegram.desktop
    com.discordapp.Discord
    org.zulip.Zulip
    dev.vencord.Vesktop
    # Media & Audio
    com.spotify.Client
    org.audacityteam.Audacity
    org.kde.audiotube
    io.github.hrkfdn.ncspot
    org.gnome.Decibels
    io.bassi.Amberol
    com.github.neithern.g4music
    # Video & Graphics Creation
    org.kde.kdenlive
    org.inkscape.Inkscape
    org.kde.krita
    org.blender.Blender
    org.freecad.FreeCAD
    org.godotengine.Godot
    org.librecad.librecad
    com.bambulab.BambuStudio
    # Writing & Text Tools
    io.gitlab.liferooter.TextPieces
    org.gnome.gitlab.somas.Apostrophe
    org.gnome.gitlab.ilhooq.Bookup
    io.github.diegopvlk.Dosage
    page.codeberg.censor.Censor
    com.logseq.Logseq
    # Terminal & Shell
    app.devsuite.Ptyxis
    org.wezfurlong.wezterm
    # System Utilities
    com.github.tchx84.Flatseal
    io.github.giantpinkrobots.flatsweep
    io.github.flattool.Warehouse
    net.nokyan.Resources
    io.missioncenter.MissionCenter
    be.alexandervanhee.gradia
    io.github.mrvladus.List
    com.belmoussaoui.Authenticator
    org.gnome.Polari
    org.gnome.dspy
    io.github.swordpuffin.rewaita
    org.gnome.design.Emblem
    org.mozilla.vpn
    io.github.zingytomato.netpeek
    com.oguzhaninan.Stacer
    # Productivity Tools
    com.pojtinger.felicitas.Sessions
    com.rafaelmardojai.Blanket
    io.github.nozwock.Packet
    org.localsend.localsend_app
    # DevTools
    com.vscodium.codium
    # News & Feeds
    io.gitlab.news_flash.NewsFlash
    # Health & Fitness
    dev.Cogitri.Health
    # Exhibit & Miscellaneous
    io.github.nokse22.Exhibit
)

flatpak install -y --noninteractive flathub "${APPS[@]}"
