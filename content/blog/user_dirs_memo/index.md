+++
title = "ホームのPicturesとかDownloadsって誰が作ってんのかのメモ"
date = 2025-11-28
description = "Linuxでホーム直下の定番フォルダがどう決まるかを手短に"
+++

- Freedesktop.orgが配ってる[`xdg-user-dirs`](https://www.freedesktop.org/wiki/Software/xdg-user-dirs/)がホーム直下の`Pictures`や`Downloads`を生成するツール本体。
- manページ（[`man xdg-user-dirs-update`](https://manpages.debian.org/trixie/xdg-user-dirs/xdg-user-dirs-update.1.en.html)）では`--set NAME PATH`のNAMEに`DESKTOP`や`DOWNLOAD`など8種類が列挙されていて、これが実際のフォルダ（例:`Desktop`,`Downloads`）に対応するっぽい。
