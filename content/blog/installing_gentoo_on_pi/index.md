+++
title = "Raspberry Pi 4 Model BにGentooをインストールする"
date = 2026-04-18
+++

### はじめに

この記事では、Raspberry Pi 4 Model BにGentooをインストールする手順を解説します。

### 前提

この記事では、以下の前提に沿っています。

- 使用するRaspberry PiはRaspberry P i4 Model Bとします。
- Raspberry Piは容量が32GBのmicroSDカードをストレージとします。
- Raspberry Pi以外に、親機としてGentooをインストール済みのAMD64マシンを使用します。
- Raspberry Piはモニタなしのヘッドレス機として運用します。ただし、モニタがあってもインストール手順には影響しないはずです。
- インストール時、Raspberry Piは有線LANで接続されていますが、最終的にはWi-Fiに接続させます。

[Raspberry Pi Install Guide](https://wiki.gentoo.org/wiki/Raspberry_Pi_Install_Guide)や[AMD64版ハンドブック](https://wiki.gentoo.org/wiki/Handbook:AMD64/ja)などを参考にする。ちなみに、SoCに様々な種類があって全部に対応するのは現実ためではないため、Arm64のハンドブックは存在しないらしい[^arm64-handbook]。

### 手順

以下の資料を参考にしています。ちなみにArm64のハンドブックは、SoCに様々な種類があって全部に対応するのは現実的ではないため、存在しないようです[^arm64-handbook]。

- [Raspberry Pi Install Guide](https://wiki.gentoo.org/wiki/Raspberry_Pi_Install_Guide)
- [AMD64版ハンドブック](https://wiki.gentoo.org/wiki/Handbook:AMD64/ja)

#### パーティションを作成する

`cfdisk`でパーティションを作成します。`fdisk`などの別のツールを使用しても大丈夫です。`/dev/sdb`はご自身の環境に合わせて適宜変更してください。

```sh
sudo cfdisk /dev/sdb
```

パーティションの設定は以下のとおりにします。

| 名前                   | パーティション | ファイルシステム | パーティションタイプ   | 大きさ   |
| ---------------------- | -------------- | ---------------- | ---------------------- | -------- |
| 起動パーティション     | /dev/sdb1      | vfat             | Microsoft 基本データ   | 512MB    |
| スワップパーティション | /dev/sdb2      | swap             | Linux スワップ         | 2GB      |
| ルートパーティション   | /dev/sdb3      | ext4             | Linux ファイルシステム | 残り全部 |

Raspberry PiはUEFIを用いて起動するわけではないですが、起動可能なパーティションというものが必要[^boot-partition]で、その条件は以下のとおりです：

- FAT12 or FAT16 or FAT32でフォーマットされていること。
- `start.elf`が含まれていること。

起動パーティションの大きさは自由ですが、Raspberry Pi OSのイメージを作成するスクリプトが512MBで作成しているので、それに習いました[^boot-size]。またSwapの大きさは適当です。

ルートパーティションのファイルシステムはext4としました。現在のAMD64のGentooハンドブックではルートパーティションにXFSを使用しているようですが、以下の理由でext4を採用しました。

- XFSではパーティションの縮小ができないが、ext4では拡張・縮小が共にできること。
- Raspberry PiのLinuxカーネルがデフォルトでext4を組み込んでおり、XFSはモジュールとして設定されていること。

パーティションタイプはAMD64の場合と同様です。起動パーティションのパーティションタイプをMicrosoft 基本データにしているのはMBRからの個人的な慣習ですが、これにすべきという根拠は見つかりませんでした。

#### ファイルシステムを作成する

AMD64の場合と同様に、ファイルシステムを作成します。

```sh
sudo mkfs.vfat /dev/sdb1
sudo mkfs.ext4 /dev/sdb3
```

LiveUSBからGentooをインストールする場合は、ここでスワップパーティションを有効にしますが、今回は親機のスワップパーティションを使用するため有効にしません。

#### 親機にマウントする

これもAMD64と同様ですが、Raspberry Piの場合は起動パーティションを`/boot`ではなく`/boot/firmware`にマウントするのが一般的のようです。

```sh
sudo mkdir /mnt/gentoo
sudo mount /dev/sdb3 /mnt/gentoo
sudo mkdir -p /mnt/gentoo/boot/firmware
sudo mount /dev/sdb1 /mnt/gentoo/boot/firmware
```

#### ベースシステムをインストールする

これもAMD64と同様です。Arm64のStage 3ファイルは[こちらにあります](https://www.gentoo.org/downloads/arm64/#stages)。

```sh
cd /mnt/gentoo
sudo wget （Stage 3ファイルのURL）
sudo tar xpvf （Stage 3ファイル） --xattrs-include='*.*' --numeric-owner
```

#### `/mnt/gentoo/etc/portage/make.conf`を弄る

いつもの通り。最近はRustで書かれたプログラムも多いので、`RUSTFLAGS`も適切に設定すると良い[^rustflags]。また`MAKEOPTS`をこのファイル内では未設定にすると、自動で値が設定されるようになった[^makeopts]。

#### chrootする

通常ならばここで`chroot`をして子機の中に入るのだが、親機がAMD64で子機がarm64なため、アーキテクチャ違いにより単純には`chroot`できない。そこでQEMUを間接的に実行することで、`chroot`を成功させる。

とりあえず`qemu`をemergeする。

```sh
sudo emerge app-emulation/qemu
```

そして`/etc/init.d/qemu-binfmt`を編集し、`QEMU_BINFMT_FLAGS:=OC`となっている部分を`QEMU_BINFMT_FLAGS:=OCF`としたあと、以下のコマンドを実行する。

```sh
# 場合によってはstartではなくrestartとなる。
sudo /etc/init.d/qemu-binfmt start
```

これが一体何をしているのかというと、binfmt_miscというLinuxの仕組みを利用している。詳細は既に存在する解説[^binfmt-misc]を読んでいただきたいが、バイナリの最初の部分が特定のバイト列になっている場合に、指定したインタプリタを実行するという機能がある。これを利用し、AArch64のELFファイルを実行する際は、`qemu-aarch64`を使用するよう指定するのが`/etc/init.d/qemu-binfmt start`の役目。`binfmt_misc`の状況は`/proc/sys/fs/binfmt_misc/`配下にあるファイルで確認できる。`qemu-aarch64`の設定は`/proc/sys/fs/binfmt_misc/qemu-aarch64`で確認できる。ちなみに`QEMU_BINFMT_FLAGS`を`OC`から`OCF`にした理由は、`F`というフラグにある。`F`フラグを使用していない場合は、バイナリを実行する時に初めて`binfmt_misc`に登録したインタプリタが実行されるが、`chroot`の場合だと、`chroot`した先で`/bin/bash`というAArch64バイナリを実行するため、その中で`/usr/bin/qemu-aarch64`を探してしまう。`F`というフラグをつけて`binfmt_misc`に登録すると、その登録時点でインタプリタを開き、該当バイナリを実行する際はその既に開いてあるバイナリを利用するため、このような問題が発生しない。

そして、準備をしてchrootをする。

```sh
sudo cp --dereferenc /etc/resolv.conf /mnt/gentoo/etc/resolv.conf

sudo mount --rbind /dev /mnt/gentoo/dev
sudo mount --make-rslave /mnt/gentoo/dev
sudo mount -t proc /proc /mnt/gentoo/proc
sudo mount --rbind /sys /mnt/gentoo/sys
sudo mount --make-rslave /mnt/gentoo/sys
sudo mount --rbind /tmp /mnt/gentoo/tmp
sudo mount --bind /run /mnt/gentoo/run
sudo mount --rbind /var/tmp /mnt/gentoo/var/tmp

sudo chroot /mnt/gentoo
```

`/tmp`と`/var/tmp`をバインドしているが、これはemerge時にこれらの容量が一杯になってしまったのでこうした記憶がある。正直よく覚えていない。

chrootした先ではいつものやつをやる。

```sh
. /etc/profile
export PS1="(chroot) ${PS1}"
```

#### パッケージを更新する

パッケージを更新するのはいつもどおりだが、`emerge`はいつもどおりには行かない。というのも、単純に`emerge`を実行すると、`qemu: qemu_thread_create: Invalid argument`というエラーが出て失敗してしまう。これは既知の問題のようで[^bug-703278]、これを回避するにはサンドボックス機能を一部無効にする必要がある[^gentoo-linux-cross-build]。ちょっとセキュリティ的には悪いかも。

```sh
emerge-webrsync
FEATURES="-pid-sandbox -network-sandbox" emerge -avtuDU @world
```

#### PortageをGitで同期する

これは必須ではないが、PortageをGitで同期すると、高速に`emerge --sync`できるので便利[^portage-with-git]。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge dev-vcs/git app-eselect/eselect-repository
eselect repository rm -f gentoo
eselect repository add gentoo git https://github.com/gentoo-mirror/gentoo
rm -rf /var/db/repos/gentoo
emerge --sync
```

#### タイムゾーンを設定する

相対パスの方が都合が良いらしいものの、絶対パスでもいいっぽい[^handbook-base]。

```sh
ln -sf ../usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```

#### ロケールを設定する

`/etc/locale.gen`を編集し、`en_US`と`ja_JP`のコメントアウトを外す。以前は`en_US.UTF-8`のような形式だったはずだが、どうも`UTF-8`の部分が消え去った。ちなみに編集は、外側から`nvim /mnt/gentoo/etc/locale.gen`としても良い。

それができたら、`chroot`の中身で以下を実行する。

```sh
locale-gen
```

そして使用するロケールを設定する。仮想ttyしか扱えないのであれば英語を選択すべきだろうが、SSHで別マシンからアクセスする場合なら、普通にターミナル上で日本語を表示できるはずなので、日本語を選択しても良さそう。

以下のコマンドの番号は、実際に使用するロケールの番号に応じて変更すること。

```sh
eselect locale set 5
```

そして新しいロケールを読み込む。

```sh
env-update
. /etc/profile
export PS1="(chroot) ${PS1}"
```

#### カーネルを設定する

Raspberry Piでは、通常のLinuxカーネルではなく、パッチを当てたものを使用する。したがってGentooでは、`sys-kernel/gentoo-kernel`ではなく、`sys-kernel/raspberrypi-sources`または`sys-kernel/raspberrypi-image`を使う。前者は`sys-kernel/gentoo-sources`と同様にカーネルのソースコードをEmergeし、カーネルを自分でビルドする。後者はビルド済みイメージをEmergeする。

今回は`sys-kernel/raspberrypi-sources`の方を利用する。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge -avt raspberrypi-sources
```

その後、`eselect`によって使用するカーネルのバージョンを指定する。

```sh
eselect kernel list
eselect kernel set 1    # 番号は適宜変更すること
```

そしてカーネルのディレクトリに入る。

```sh
cd /usr/src/linux
```

通常はここで、`make menuconfig`によってカーネルの設定を行うが、設定ミスによって起動できなくなることをおそれ、デフォルトの設定を利用する。

Raspberry Pi 4BではBCM2711というプロセッサが搭載されている[^pi4-spec]が、それのための設定を適用することができる。

```sh
make bcm2711_defconfig
```

ただし、ルートパーティションで使用しているファイルシステムが組み込みになっているかは確認する必要がある。例えば`CONFIG_XFS_FS`はモジュールとして組み込まれているため、仮にXFSをルートパーティションで使用しているならば、これを組み込みにしないと起動に失敗する。また、デフォルトの設定はかなり様々なオプションが有効になっているので、ビルドに時間がかかる。

```sh
grep XFS .config
```

```sh
CONFIG_XFS_FS=m
CONFIG_XFS_SUPPORT_V4=y
CONFIG_XFS_SUPPORT_ASCII_CI=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_ONLINE_SCRUB is not set
# CONFIG_XFS_WARN is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_VXFS_FS is not set
```

設定が済んだら、カーネルをビルドする。

```sh
make -j$(nproc) -l$(nproc)
```

そしてインストールする。

```sh
make -j$(nproc) -l$(nproc) modules_install
make -j$(nproc) -l$(nproc) dtbs_install
make -j$(nproc) -l$(nproc) install
```

`make dtbs_install`というのは、DTBs（Device Tree Blobs）をインストールするものらしく、それが何なのかよくわかっていないが、公式のマニュアルでビルドやコピーをしているので、それに従っている[^pi4-kernel]。

#### ブートローダの設定をする

デスクトップマシンならば、通常はGRUBなどのブートローダを設定するが、Raspberry Piではそれらは使用しない。

まず、`raspberrypi-firmware`をEmergeする。これには、Raspberry Piを起動するために必要なファームウェアが含まれている。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge sys-boot/raspberrypi-firmware
```

このパッケージは`/boot/config.txt`と`/boot/cmdline.txt`もインストールする。それぞれ編集する必要がある。

`/boot/config.txt`には、Raspberry Piの設定を書き込む。今回は以下のようにする[^gentoo-raspi-3][^raspi-led][^red-green-led]。

```text
arm_64bit=1
dtparam=pwr_led_trigger=heartbeat
```

最初の行はArm64を使用していることを示す。次の行は、赤のLEDを点滅させる。これは、Raspberry Piが正常に起動しているかを簡単に判断できるようにするため。

`/boot/cmdline.txt`には、Linuxのカーネルパラメータを設定する。ルートパーティションのUUIDやPARTUUIDは`blkid`で調べられる。今回はPARTUUIDを使用する。

```text
root=PARTUUID=<ルートパーティションのPARTUUID>
```

#### SSHを有効にする

```sh
rc-update add dhcpcd default
rc-update add sshd default
```

#### ユーザを登録する

```sh
useradd -m -G wheel -s /bin/bash <ユーザ名>
passwd <ユーザ名>
```

#### マウントを解除する

```sh
exit
```

```sh
sudo umount -R /mnt/gentoo
```

#### メモ

```sh
scripts/config -e NETCONSOLE
scripts/config -e NETCONSOLE_EXTENDED_LOG
scripts/config -e NETCONSOLE_PREPEND_RELEASE
make olddefconfig
make -j$(nproc) Image.gz
```

```text
root=PARTUUID=<PARTUUID> rootfstype=ext4 rootwait rw debug ignore_loglevel loglevel=8 ip=<空いているIPv4>:::::eth0:off netconsole=+r6665@<ip=で指定しているものと同じIPv4>/eth0,6666@<デスクトップマシンのIPv4>/ff:ff:ff:ff:ff:ff
```

```sh
gcc -Q --help=target
gcc -march=native -Q --help=target
```

基本的にQEMU内では最低限のことをやるのが良さそう。

[^arm64-handbook]: [ここ](https://wiki.gentoo.org/wiki/Handbook:Main_Page)曰く、SoCに様々な種類があって全部に対応するのは現実的ではないためらしい。

[^boot-partition]: https://www.raspberrypi.com/documentation/computers/config_txt.html#boot_partition

[^boot-size]: https://github.com/RPi-Distro/pi-gen/blob/d2f70c5af1f007626c52f773f8e22209c4a34d38/export-image/prerun.sh

[^boot-or-boot-firmware]: https://www.raspberrypi.com/documentation/computers/config_txt.html

[^rustflags]: https://wiki.gentoo.org/wiki/Rust#Environment_variables

[^makeopts]: https://wiki.gentoo.org/wiki/MAKEOPTS

[^binfmt-misc]: https://docs.kernel.org/admin-guide/binfmt-misc.html

[^bug-703278]: https://bugs.gentoo.org/703278

[^gentoo-linux-cross-build]: https://unagidojyou.com/2025/08-20/gentoo-linux_cross-bulid/

[^portage-with-git]: https://wiki.gentoo.org/wiki/Portage_with_Git

[^handbook-base]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/ja

[^pi4-spec]: https://www.raspberrypi.com/products/raspberry-pi-4-model-b/specifications/

[^pi4-kernel]: https://www.raspberrypi.com/documentation/computers/linux_kernel.html

[^config.txt]: https://www.raspberrypi.com/documentation/computers/config_txt.html

[^raspi-led]: https://cgbeginner.net/raspi-led/

[^red-green-led]: https://qiita.com/naohiro2g/items/d5385a4e660fd72711b2

[^dtparam]: https://www.raspberrypi.com/documentation/computers/configuration.html#part3.1

[^gentoo-raspi-3]: https://sat-robotics.com/install_gentoo_raspi3/#toc11
