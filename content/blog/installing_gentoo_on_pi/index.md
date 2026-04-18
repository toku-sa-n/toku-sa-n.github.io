+++
title = "Raspberry Pi 4 Model BにGentooをインストールする"
date = 2026-04-18
+++

### はじめに

[Raspberry Pi Install Guide](https://wiki.gentoo.org/wiki/Raspberry_Pi_Install_Guide)や[AMD64版ハンドブック](https://wiki.gentoo.org/wiki/Handbook:AMD64/ja)などを参考にする。ちなみにハンドブックはないらしい[^arm64-handbook]。

### ホストマシンとターゲット機

ホストマシンはAMD64のGentoo。LiveUSBからではない。

ターゲット機はRaspberry Pi 4 Model B。これの32GB SDカードにインストールする。

### 手順

#### パーティションを作る

| パーティション | ファイルシステム | サイズ |
|----------------|------------------|--------|
| /dev/sdb1      | vfat             | 512MB  |

Raspberry PiはUEFIを用いて起動するわけではないが、起動可能なパーティションというものが必要[^boot-partition]。その条件は以下の通り。
- FAT12 or FAT16 or FAT32でフォーマットされている。
- `start.elf`が含まれている。

`/dev/sdb1`のサイズは自由だが、Raspberry Pi OSイメージを作成するスクリプトが512MBで起動パーティションを作成しているので、それに倣った[^boot-size]。

[^arm64-handbook]: [ここ](https://wiki.gentoo.org/wiki/Handbook:Main_Page)曰く、SoCに様々な種類があって全部に対応するのは現実的ではないためらしい。
[^boot-partition]: https://www.raspberrypi.com/documentation/computers/config_txt.html#boot_partition
[^boot-size]: https://github.com/RPi-Distro/pi-gen/blob/d2f70c5af1f007626c52f773f8e22209c4a34d38/export-image/prerun.sh
