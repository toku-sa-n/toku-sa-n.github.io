### TL;DR

[Vectorのダウンロードページ](https://www.vector.co.jp/soft/dl/winnt/game/se508809.html)からダウンロードしてプレイしましょう．

### はじめに

この記事は[UEC Advent Calendar 2022](https://adventar.org/calendars/7581)の13日目の記事です．

現在電通大M1の[toku\_san](https://keybase.io/toku_san/)です．

### 注意

この記事にはざくざくアクターズを始めからプレイして15分くらいすればわかるネタバレと，ゲームのストーリーには全く関係のない技術的なネタバレが存在します．でもそんなものはやネタバレではないので気にせず読み続けてください．

### 概要

![ざくざくアクターズVer1.82を初回起動した直後のスクリーンショット](top_screenshot.png)

[ざくざくアクターズ](https://www.vector.co.jp/soft/winnt/game/se508809.html)は，[はむすた](https://www.vector.co.jp/vpack/browse/person/an051865.html)氏によって[RPGVXAce](https://rpgmakerofficial.com/product/products/rpgvxace/index/)で制作されたRPGゲームです．縮めてざくアクとも呼ばれています．

### Linuxでのプレイに関して

[Wine](https://www.winehq.org/)を用いればざくざくアクターズをLinuxでプレイすることはできますが，私自身は一部のBGMを再生させることができず，結局Windows上で動かすことにしました．

ざくざくアクターズには[WMA形式](https://ja.wikipedia.org/wiki/Windows_Media_Audio)の音源が用いられていますが，この形式で保存されているBGMを鳴らすことができませんでした．Wineでは2022年2月11日に公開された[バージョン7.2](https://www.winehq.org/announce/7.2)でWMAデコーダの開発が開始されたばかりなため，あくまで推測ですが，まだWMAを直接鳴らすことが出来ないのかなと考えています．従って素直にWindows上でプレイするほうが得策だと思います．

幸いにして電通大の学生は[無料で個人PCにWindowsをインストールすることができます](https://www.cc.uec.ac.jp/ug/ja/license/ms/personal/kivuto/index.html)．これを利用するのも一つの手です．実際これ以外にも，例えば授業中にWindowsでしか動かないソフトウェアの利用を強いられることがありますし，Windowsマシンは一台あったほうが良いです．

**Wineを利用したことによるトラブルや不具合に関して開発側に問い合わせないでください．Wineの使用は開発側の想定環境ではありません．**
