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

| パーティション | ファイルシステム | パーティションタイプ   | サイズ   |
|----------------|------------------|------------------------|----------|
| /dev/sdb1      | vfat             | Microsoft 基本データ   | 512MB    |
| /dev/sdb2      | swap             | Linux スワップ         | 2GB      |
| /dev/sdb3      | ext4             | Linux ファイルシステム | 残り全部 |

Raspberry PiはUEFIを用いて起動するわけではないが、起動可能なパーティションというものが必要[^boot-partition]。その条件は以下の通り。
- FAT12 or FAT16 or FAT32でフォーマットされている。
- `start.elf`が含まれている。

`/dev/sdb1`のサイズは自由だが、Raspberry Pi OSイメージを作成するスクリプトが512MBで起動パーティションを作成しているので、それに倣った[^boot-size]。

Swapの大きさに根拠はない。

`/dev/sdb3`のファイルシステムはext4とした。以前のAMD64のハンドブックでもext4が使われていたが、いつからかxfsに書き換わっていた。ただ、ext4では拡張・縮小の両方ができるのに対し、xfsでは拡張しかできないため、ext4とした。

パーティションタイプはいつも通り。 `/dev/sdb1` をMicrosoft 基本データにしているのはMBRからの個人的な名残ではあるが、これにすべきという根拠は見つからなかった。

いつものように`cfdisk`でパーティションを作る。

```sh
sudo cfdisk /dev/sdb
```

そしてファイルシステムを作る。

```sh
sudo mkfs.vfat /dev/sdb1
sudo mkfs.ext4 /dev/sdb3
```

スワップパーティションはこの時点では有効にしない。

#### 親機にマウントする

いつもの通り。

```sh
sudo mkdir /mnt/gentoo
sudo mount /dev/sdb3 /mnt/gentoo
sudo mkdir /mnt/gentoo/boot
sudo mount /dev/sdb1 /mnt/gentoo/boot
```

なお、Raspberry Pi OSのBookworm以降では、起動パーティションは `/boot/firmware` にあったようだが、それ以前は `/boot` にあったようで、OSのバージョンによって異なっている[^boot-or-boot-firmware]。今回 `/boot` を選んだのは、慣れから。

#### ベースシステムをインストールする

いつもどおり。arm64のStage 3ファイルは[こちらにある](https://www.gentoo.org/downloads/arm64/#stages)。

```sh
cd /mnt/gentoo
sudo wget （Stage 3ファイルのURL）
sudo tar xpvf （Stage 3ファイル） --xattrs-include='*.*' --numeric-owner
```

#### `/mnt/gentoo/etc/portage/make.conf`を弄る

いつもの通り。最近はRustで書かれたプログラムも多いので、`RUSTFLAGS`も適切に設定すると良い[^rustflags]。また`MAKEOPTS`をこのファイル内では未設定にすると、自動で値が設定されるようになった[^makeopts]。

#### `chroot`のための準備

通常ならばここで`chroot`をして子機の中に入るのだが、親機がAMD64で子機がarm64なため、アーキテクチャ違いにより単純には`chroot`できない。そこでQEMUを間接的に実行することで、`chroot`を成功させる。

とりあえず`qemu`をemergeする。

```sh
sudo emerge app-emulation/qemu
```

そして`/etc/init.d/qemu-binfmt`を編集し、`QEMU_BINFMT_FLAGS:=OC`となっている部分を`QEMU_BINFMT_FLAGS:=OCF`とする。

[^arm64-handbook]: [ここ](https://wiki.gentoo.org/wiki/Handbook:Main_Page)曰く、SoCに様々な種類があって全部に対応するのは現実的ではないためらしい。
[^boot-partition]: https://www.raspberrypi.com/documentation/computers/config_txt.html#boot_partition
[^boot-size]: https://github.com/RPi-Distro/pi-gen/blob/d2f70c5af1f007626c52f773f8e22209c4a34d38/export-image/prerun.sh
[^boot-or-boot-firmware]: https://www.raspberrypi.com/documentation/computers/config_txt.html
[^rustflags]: https://wiki.gentoo.org/wiki/Rust#Environment_variables
[^makeopts]: https://wiki.gentoo.org/wiki/MAKEOPTS
