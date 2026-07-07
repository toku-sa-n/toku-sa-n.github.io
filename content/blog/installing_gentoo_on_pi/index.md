+++
title = "Raspberry Pi 4 Model BにGentooをインストールする"
date = 2026-04-18
+++

### はじめに

この記事では、Raspberry Pi 4 Model BにGentooをインストールする手順を解説します。

### 前提

この記事では、以下の前提に沿っています。

- 使用するRaspberry PiはRaspberry Pi 4 Model Bとします。
- Raspberry Piは容量が32GBのmicroSDカードをストレージとします。
- Raspberry Pi以外に、親機としてGentooをインストール済みのAMD64マシンを使用します。
- Raspberry Piはモニタなしのヘッドレス機として運用します。ただし、モニタがあってもインストール手順には影響しないはずです。
- インストール時、Raspberry Piは有線LANで接続されていますが、最終的にはWi-Fiに接続させます。

### 手順

以下の資料を参考にしています。ちなみにArm64のハンドブックは、SoCに様々な種類があって全部に対応するのは現実的ではないため、存在しないようです[^arm64-handbook]。

- [Raspberry Pi Install Guide](https://wiki.gentoo.org/wiki/Raspberry_Pi_Install_Guide)
- [AMD64版ハンドブック](https://wiki.gentoo.org/wiki/Handbook:AMD64/ja)

{% warning() %}
この記事は、筆者が実際にRaspberry Pi 4 Model BへGentooをインストールした際の手順を基にしていますが、一部の手順は未検証です。
{% end %}

#### 1. Gentooをインストールする

##### パーティションを作成する

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

起動パーティションの大きさは自由ですが、Raspberry Pi OSのイメージを作成するスクリプトが512MBで作成しているので、それに倣いました[^boot-size]。またSwapの大きさは適当です。

ルートパーティションのファイルシステムはext4としました。現在のAMD64のGentooハンドブックではルートパーティションにXFSを使用しているようですが、以下の理由でext4を採用しました。

- XFSではパーティションの縮小ができないが、ext4では拡張・縮小が共にできること。
- Raspberry PiのLinuxカーネルがデフォルトでext4を組み込んでおり、XFSはモジュールとして設定されていること。

パーティションタイプはAMD64の場合と同様です。起動パーティションのパーティションタイプをMicrosoft 基本データにしているのはMBRからの個人的な慣習ですが、これにすべきという根拠は見つかりませんでした。

##### ファイルシステムを作成する

AMD64の場合と同様に、ファイルシステムを作成します。

```sh
sudo mkfs.vfat /dev/sdb1
sudo mkfs.ext4 /dev/sdb3
```

LiveUSBからGentooをインストールする場合は、ここでスワップパーティションを有効にしますが、今回は親機のスワップパーティションを使用するため有効にしません。

##### 親機にマウントする

これもAMD64と同様ですが、Raspberry Piの場合は起動パーティションを`/boot`ではなく`/boot/firmware`にマウントするのが一般的のようです。

```sh
sudo mkdir /mnt/gentoo
sudo mount /dev/sdb3 /mnt/gentoo
sudo mkdir -p /mnt/gentoo/boot/firmware
sudo mount /dev/sdb1 /mnt/gentoo/boot/firmware
```

##### ベースシステムをインストールする

これもAMD64と同様です。Arm64のStage 3ファイルは[こちらにあります](https://www.gentoo.org/downloads/arm64/#stages)。

```sh
cd /mnt/gentoo
sudo wget （Stage 3ファイルのURL）
sudo tar xpvf （Stage 3ファイル） --xattrs-include='*.*' --numeric-owner
```

{% warning() %}
AMD64のハンドブックでは、このあとに`/mnt/gentoo/etc/portage/make.conf`を編集しますが、Raspberry PiにGentooをインストールする際はこの時点で編集しない方がよいです。

このあとにQEMUを使用して`chroot`しますが、例えば`CFLAGS`に`-march=native`と最適化フラグを設定すると、Raspberry PiのCPU機能に合わない最適化がされるおそれがあります。最悪の場合、起動に失敗するおそれがあります。

`make.conf`の最適化は、実機上で起動した後に行うことを推奨します。
{% end %}

##### `chroot`の前準備：QEMUを`binfmt_misc`に登録する

AMD64のハンドブックでは、ここで`chroot`をして子機の中に入りますが、親機がAMD64で子機がArm64なため、アーキテクチャの違いにより単純には`chroot`できません。そこで子機のOSをQEMU上で実行することで、`chroot`を成功させます。

まず、`qemu`をEmergeします。

```sh
sudo emerge app-emulation/qemu
```

そして`/etc/init.d/qemu-binfmt`内にある`QEMU_BINFMT_FLAGS:=OC`を`QEMU_BINFMT_FLAGS:=OCF`と改変し、以下のコマンドを実行します。なお、`start`は場合によっては`restart`とする必要があるかもしれません。

```sh
sudo /etc/init.d/qemu-binfmt start
```

これは、`binfmt_misc`というLinuxの仕組みを利用しています。これは、バイナリの最初の部分が特定のバイト列になっている場合に、指定したインタプリタを実行する機能です。`/etc/init.d/qemu-binfmt start`はこれを利用し、AArch64のELFファイルを実行する際に、`qemu-aarch64`を使用するよう設定するスクリプトです。

`binfmt_misc`の設定状況は`/proc/sys/fs/binfmt_misc/`配下にあるファイルで確認でき、`qemu-aarch64`の場合は`/proc/sys/fs/binfmt_misc/qemu-aarch64`で確認できます。

ちなみに`QEMU_BINFMT_FLAGS`を`OC`から`OCF`にした理由は、`F`というフラグにあります。このフラグを使用していない場合は、バイナリを実行する時に初めて`binfmt_misc`に登録したインタプリタが実行されますが、`chroot`の場合だと、`chroot`した先で`/bin/bash`というAArch64バイナリを実行するため、その中で`/usr/bin/qemu-aarch64`を探してしまいます。Raspberry Piの中に`/usr/bin/qemu-aarch64`というバイナリは存在しないため、結果バイナリの実行に失敗します。しかし、`F`というフラグをつけて`binfmt_misc`に登録すると、その登録時点でインタプリタを開き、該当バイナリを実行する際はその既に開いてあるバイナリを利用するため、このような問題が発生しません。

`binfmt_misc`の詳細は、Linuxカーネルのドキュメントページにある解説[^binfmt-misc]を確認してください。

##### `chroot`する

準備ができたので、`resolv.conf`をコピーし、必要なファイルシステムをマウントしたうえで`chroot`します。

```sh
sudo cp --dereference /etc/resolv.conf /mnt/gentoo/etc/resolv.conf

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

今回は`/tmp`と`/var/tmp`もバインドしています。確かRaspberry Piの中でEmergeをした際にこれらの容量が大きくなりすぎてしまい、microSDが満杯になってしまうのを防ぐための対策のはずですが、正直よく覚えていません。

`chroot`した先では、AMD64の場合と同様に、プロファイルをロードし、プロンプトも変更します。

```sh
. /etc/profile
export PS1="(chroot) ${PS1}"
```

##### パッケージを更新する

これもAMD64の場合と同様です。ただし、既知の問題[^bug-703278]によって、QEMU内で`emerge`を実行するには、サンドボックス機能を一部無効にする必要があります[^gentoo-linux-cross-build]。これを忘れると`qemu: qemu_thread_create: Invalid argument`というエラーが出ます。

```sh
emerge-webrsync
FEATURES="-pid-sandbox -network-sandbox" emerge -avtuDU @world
```

##### PortageをGitで同期する

これは必須ではないのですが、PortageをGitで同期すると、高速に`emerge --sync`できるので便利です[^portage-with-git]。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge dev-vcs/git app-eselect/eselect-repository
eselect repository rm -f gentoo
eselect repository add gentoo git https://github.com/gentoo-mirror/gentoo
rm -rf /var/db/repos/gentoo
emerge --sync
```

##### タイムゾーンを設定する

AMD64の場合と同様です。パスに`../`とあるように、相対パスを使用していますが、絶対パスでもよいとのこと[^handbook-base]。ただ、相対パスのほうが都合が良いらしいです。

```sh
ln -sf ../usr/share/zoneinfo/Asia/Tokyo /etc/localtime
```

##### ロケールを設定する

`/etc/locale.gen`を編集し、`en_US`と`ja_JP`のコメントアウトをします。これは`chroot`の中で行う代わりに、親機から`nvim /mnt/gentoo/etc/locale.gen`としてもよいです。

その後、`chroot`内で以下を実行します。

```sh
locale-gen
```

そして、使用するロケールを設定します。仮想ttyしか扱えない場合は英語を選択すべきですが、SSHで別マシンからアクセスできるなら、普通にターミナル上で日本語を表示できるはずなので、日本語で問題なさそうです。

まず、ロケールと対応する番号を確認します。

```sh
eselect locale list
```

番号を確認したら、実際にロケールを設定します。

```sh
eselect locale set <ロケールの番号>
```

そして新しいロケールを読み込みます。

```sh
env-update
. /etc/profile
export PS1="(chroot) ${PS1}"
```

##### カーネルを設定する

Raspberry Piでは、通常のLinuxカーネルではなく、パッチを当てたものを使用します。したがってGentooでは、`sys-kernel/gentoo-kernel`ではなく、`sys-kernel/raspberrypi-sources`または`sys-kernel/raspberrypi-image`を使用します。前者は`sys-kernel/gentoo-sources`と同様にカーネルのソースコードをEmergeし、カーネルを自分でビルドします。後者はビルド済みイメージです。

今回は`sys-kernel/raspberrypi-sources`を利用します。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge -avt raspberrypi-sources
```

その後、`eselect`によって、`/usr/src/linux`へのシンボリックリンクを張ります。

```sh
eselect kernel list
eselect kernel set 1
```

そしてカーネルのディレクトリに入ります。

```sh
cd /usr/src/linux
```

通常はここで、`make menuconfig`によってカーネルを設定しますが、設定ミスによって起動できなくなることをおそれ、デフォルトの設定を利用します。

Raspberry Pi 4BではBCM2711というプロセッサが搭載されており[^pi4-spec]、デフォルトの設定が用意されています[^pi-kernel]。

```sh
make bcm2711_defconfig
```

ただし、ルートパーティションで使用しているファイルシステムが組み込まれているかは確認してください。ext4を利用しているなら問題ありませんが、例えば`CONFIG_XFS_FS`はモジュールとして組み込まれているため、仮にXFSをルートパーティションで使用するならば、`make menuconfig`などを使用して組み込みにしないと起動に失敗します。また、デフォルトの設定は多くのオプションが有効になっているため、ビルドに時間がかかります。

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

設定が済んだら、カーネルをビルドします。

```sh
make -j$(nproc)
```

その後、まずモジュールをインストールします。

```sh
make -j$(nproc) modules_install
```

ここまではAMD64の場合と同様ですが、ここからが異なります[^pi-kernel]。

まず、カーネルのインストールでは、`make install`を使用せず、代わりにファイルを`cp`でコピーします。Raspberry Piでは、カーネルは`/boot/firmware/kernel8.img`に置きます。

```sh
cp arch/arm64/Image.gz /boot/firmware/kernel8.img
```

そして、DTBs（Device Tree Blobs）というファイル群をインストールします。DTBには、周辺機器の初期化に必要なパラメータが格納されているようです[^silex-dt]。

```sh
cp arch/arm64/boot/dts/broadcom/*.dtb /boot/firmware/
mkdir /boot/firmware/overlays
cp arch/arm64/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
```

Linuxカーネルの`Makefile`におけるターゲットとして`install`や`dtbs_install`が存在しますが、これらを実行してもファイルは正しくインストールされないので、注意してください。

##### ブートローダの設定をする

デスクトップマシンの場合は、通常GRUBなどのブートローダをインストールしますが、Raspberry Piでは使用しません。代わりに以下のファイルに、起動に必要な設定を書き込みます。

- `/boot/firmware/config.txt`：Raspberry Piの設定。
- `/boot/firmware/cmdline.txt`：Linuxカーネルのカーネルコマンドラインパラメータ。

まず、`sys-boot/raspberrypi-firmware`をEmergeします。これには、Raspberry Piを起動するために必要なファームウェアが含まれています。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge sys-boot/raspberrypi-firmware
```

このパッケージは`/boot/firmware/config.txt`と`/boot/firmware/cmdline.txt`も含まれており、これらを編集します。

`/boot/firmware/config.txt`には、以下のように書き込みます。[^gentoo-raspi-3][^raspi-led][^red-green-led]。

```text
arm_64bit=1
dtparam=act_led_trigger=heartbeat
```

最初の行はArm64を使用していることを示します。

その次の行は、緑のLEDを点滅させる設定です。これは、Raspberry Piが正常に起動しているかを簡単に判断できるようにするためです。

`/boot/firmware/cmdline.txt`には、Linuxのカーネルパラメータを設定します。今回は以下のように設定します。

```text
root=PARTUUID=<ルートパーティションのPARTUUID> rootwait ro
```

各パラメータの解説は以下のとおり。[^kernel-parameters]

- `root=PARTUUID=<ルートパーティションのPARTUUID>`：ルートパーティションのPARTUUIDを指定します。PARTUUIDは`blkid`コマンドで確認できます。`PARTUUID=`を`UUID`にし、UUIDを指定しても構いません。
- `rootwait`：ルートデバイスを検出するまで無限に待ちます。microSDのようなMMC（MultiMediaCard）は非同期に検出されるため、このオプションがないと起動に失敗する場合があります。

##### NetworkManagerをインストールする[^networkmanager]

次に、NetworkManagerをインストールします。グローバルなUSEフラグに`networkmanager`というものがあるので、それを有効にしシステム全体を更新したあと、NetworkManagerをインストールします。

```sh
euse -E networkmanager
FEATURES="-pid-sandbox -network-sandbox" emerge -aUD @world
FEATURES="-pid-sandbox -network-sandbox" emerge net-misc/networkmanager
```

続いてユーザを`plugdev`グループに登録します。これによって、非ルートユーザがシステムのネットワークをNetworkManagerを介して設定できるようになります。

```sh
sudo gpasswd -a <ユーザ名> plugdev
```

ここで`nmcli`を実行すると、現在のネットワーク設定を確認できます。

##### SSHを有効にする

これはAMD64と同様です。まず必要なパッケージをインストールします。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge net-misc/networkmanager net-misc/openssh
```

その後`rc-update`で、毎回の起動時にデーモンが起動するように設定します。

```sh
rc-update add NetworkManager default
rc-update add sshd default
```

##### Chronyを設定する

Raspberry Piの時刻を正しく設定するために、Chronyを設定します。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge net-misc/chrony
rc-update add chronyd default
```

##### `sudo`をインストール、設定する

ルート権限が必要な場合に備え、`sudo`をインストール、設定します。

```sh
FEATURES="-pid-sandbox -network-sandbox" emerge app-admin/sudo
visudo
```

##### ユーザを登録する

これもAMD64と同様です。

```sh
useradd -m -G wheel -s /bin/bash <ユーザ名>
passwd <ユーザ名>
```

##### `sudo`が使用できるか確認する

追加したユーザで`sudo`が正しく利用できるかを確認します。

```sh
su <ユーザ名>
sudo ls
exit
```

`sudo ls`が実行できれば問題ありません。

##### ルートログインを無効にする

`sudo`が使えることを確認したら、ルートログインを無効にします。なお、仮に`sudo`が利用できなくなったとしても、再び親機にマウントすればルートでログインできます。

```sh
passwd -dl root
```

##### マウントを解除する

これでRaspberry Piを起動する準備は整いましたので、`chroot`から脱出します。

```sh
exit
```

そしてマウントしたファイルシステムを全部アンマウントします。

```sh
sudo umount -R /mnt/gentoo
```

##### Raspberry Piを起動する

microSDカードをRaspberry Piに挿入し、Raspberry Piを電源に接続します。しばらくして、緑色のLEDが一定の規則に従って点滅したら、完了です。

この時点で、親機からSSHで接続できるはずです。Raspberry PiのIPアドレスはルータの管理画面などから確認してください。

```sh
ssh <ユーザ名>@<Raspberry PiのIPアドレス>
```

#### 2. Wi-Fiを有効にする

##### tmuxをインストールする

Raspberry Pi上にtmuxをインストールしておくと、SSHセッションが切断されてもtmux上のプロセスは中断されないので便利です。

```sh
sudo emerge app-misc/tmux
```

インストールしたら、tmuxセッションを開始します。

```sh
tmux new -s my-session
```

その後、もしSSHセッションが切断されたら、再度SSH接続し、以下のコマンドを実行することでtmuxセッションにアタッチできます。

```sh
tmux attach -t my-session
```

##### Wi-Fi用のファームウェアをインストールする

Wi-Fiのファームウェアは`sys-boot/raspberrypi-firmware`ではなく、`sys-firmware/raspberrypi-wifi-ucode`に含まれます。これをインストールします。

```sh
sudo emerge sys-firmware/raspberrypi-wifi-ucode
```

インストールしたら、一度Raspberry Piを再起動します。

```sh
sudo reboot
```

##### Wi-Fiに接続する

`nmcli`を用いてWi-Fiに接続します。以下のコマンドを実行すると、Wi-Fiネットワークのパスワードを入力するよう求められるので、入力します。

```sh
sudo nmcli --ask device wifi connect "<SSID>"
```

#### Tailscaleをインストールする

##### Tailscaleクライアントをインストールする

Tailscaleクライアントを以下の手順でインストールします。

```sh
sudo emerge net-vpn/tailscale
```

その後、デーモンを起動し、またRaspberry Piの起動時に自動的に実行されるようにします。

```sh
sudo rc-update add tailscale default
sudo rc-service tailscale start
```

```sh
sudo tailscale up --ssh
```

`/etc/hostname`でホスト名を指定。

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

[^arm64-handbook]: https://wiki.gentoo.org/wiki/Handbook:Main_Page

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

[^pi-kernel]: https://www.raspberrypi.com/documentation/computers/linux_kernel.html

[^config.txt]: https://www.raspberrypi.com/documentation/computers/config_txt.html

[^raspi-led]: https://cgbeginner.net/raspi-led/

[^red-green-led]: https://qiita.com/naohiro2g/items/d5385a4e660fd72711b2

[^dtparam]: https://www.raspberrypi.com/documentation/computers/configuration.html#part3.1

[^gentoo-raspi-3]: https://sat-robotics.com/install_gentoo_raspi3/#toc11

[^silex-dt]: https://www.silex.jp/library/blog/20240529-2

[^kernel-parameters]: https://docs.kernel.org/admin-guide/kernel-parameters.html

[^networkmanager]: https://wiki.gentoo.org/wiki/NetworkManager
