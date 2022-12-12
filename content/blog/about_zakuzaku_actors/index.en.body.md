<!--
### TL;DR
-->

### TL;DR

<!--
[Vectorのダウンロードページ](https://www.vector.co.jp/soft/dl/winnt/game/se508809.html)からダウンロードしてプレイしましょう．
-->

[Download from Vector](https://www.vector.co.jp/soft/dl/winnt/game/se508809.html) and play it.

<!--
### はじめに
-->

### Introduction

<!--
この記事は[UEC Advent Calendar 2022](https://adventar.org/calendars/7581)の13日目の記事です．昨日はいずりなさんによる，[【Bash】インタラクティブな選択メニューを作ってみた](https://izurina.dev/post/uec-advent2022/)でした．
-->

This article is the thirteenth article of [UEC Advent Calendar 2022](https://adventar.org/calendars/7581). The yesterday's article was [【Bash】I've created an interactive selection menu (【Bash】インタラクティブな選択メニューを作ってみた)](https://izurina.dev/post/uec-advent2022/) by Izurina (いずりな).

<!--
現在電通大M1の[toku\_san](https://keybase.io/toku_san/)です．最近学会発表を終えたので，かなり平穏な日々を過ごしています．
-->

I'm [toku\_san](https://keybase.io/toku_san/), a M1 student at UEC. These days I have peaceful days because I've finished a presentation at a conference.

<!--
この記事では，私が去年からプレイし始めて，いつの間にかハマってしまったゲーム「ざくざくアクターズ」の紹介をしたいと思います．
-->

I'll introduce my favorite game "Zakuzaku Actors" (ざくざくアクターズ) which I started to play since last year.

<!--
### 注意
-->

### Caution

<!--
この記事にはざくざくアクターズを始めからプレイして15分くらいすればわかるネタバレと，ゲームのストーリーには全く関係のない技術的なネタバレが存在します．でもそんなものはやネタバレではないので気にせず読み続けてください．
-->

This article includes spoilers that are revealed after playing Zakuzaku Actors 15 minutes, and technical spoilers that are totally not related to the game's story, but continue reading the article anyway as these are no longer spoilers.

<!--
### 概要
-->

### Overview

<!--
![ざくざくアクターズVer1.82を初回起動した直後のスクリーンショット](top_screenshot.png)
-->

![A screenshot of Zakuzaku Actors Ver 1.82 on the first launch](top_screenshot.png)

<!--
[ざくざくアクターズ](https://www.vector.co.jp/soft/winnt/game/se508809.html)は，[はむすた](https://www.vector.co.jp/vpack/browse/person/an051865.html)氏によって[RPGツクール VX Ace](https://rpgmakerofficial.com/product/products/rpgvxace/index/)で制作されたRPGゲームです．縮めてざくアクとも呼ばれています．
-->

[Zakuzaku Actors (ざくざくアクターズ, Zakuzaku Akuta&#772;zu) ](https://www.vector.co.jp/soft/winnt/game/se508809.html)is an RPG game created by [Hamusuta (はむすた)](https://www.vector.co.jp/vpack/browse/person/an051865.html) with [RPG Maker VX Ace](https://rpgmakerofficial.com/product/products/rpgvxace/index/). The game is also called as Zakuaku (ざくアク - **Zaku**zaku **Aku**ta&#772;zu).

<!--
作者ブログによれば，2012年6月19日にバージョン0.71aが公開されました．これがこのゲームの初めての公開となります．その後更新を続け，メインストーリーが完結したあともコンテンツの追加が続き，この記事の執筆当時最新版であるバージョン1.82が2022年10月24日に公開されました．なお，作者ブログにはゲームのネタバレに相当するコンテンツを含まれているため，リンクはこの記事の下部にあります．
-->

According to the creater's blog, version 0.71a is released on June 19th, 2012. It is the very first release of the game. After that, the game has been continually updated, contents been added even if the main story is concluded, and version 1.82 which is the newest version at the time of this writing is released on October 24th, 2022. Note that the link to the blog is on the lower part of this blog becuase it contains the game's spoilers.

<!--
製作者のはむすた氏はざくアクの他に，[らんだむダンジョン](https://www.vector.co.jp/soft/winnt/game/se482804.html)というRPGゲームを過去に製作しているほか，[逆さま世界の私達へ](https://www.pixiv.net/novel/series/1449123)という小説も執筆しています．
-->

Hamusuta, the creater of the game, also creates an RPG game called [Random Dungeon (らんだむダンジョン, Randamu Danjon)](https://www.vector.co.jp/soft/winnt/game/se482804.html) previously, and writes a novel called [To us in the upside-down world (逆さま世界の私達へ, Sakasama sekai no watashi tachi e)](https://www.pixiv.net/novel/series/1449123).

<!--
### ゲームシステムに関して
-->

### About the game system

<!--
ざくアクでは原則8人のパーティーを組みます．戦闘にも8人が関わりますが，そのうち4人が前衛として実際の戦闘を行い，残りの4人は後衛として待機します．ただし，いつでもメンバーを前衛あるいは後衛に移すことが可能です．
-->

Players form a party of 8 members in general. That 8 members involve battles with enemies, but 4 out of 8 do an actual combat as the advance guard, and the remaining 4 stand by as the rear guard. You can move members from advance to rear anytime, and vise versa.

<!--
また，ざくアクでは[TP（Tactical Point）](https://tkool.jp/mv/course/03.html)という概念が存在します．これは戦闘中に様々な状況下でたまるものですが，一部の技能はこれを消費します．
-->

Also, Zakuaku has the concept of [TP (Tactial Point)](https://tkool.jp/mv/course/03.html). The point is increased during a battle for various reasons, and some skills consume it.

<!--
8人制バトルとTPという概念は単独で見ると地味ですが，この2つが組み合わさるとかなり興味深くなります．例えば蘇生技は概してTPを消費するため，そのような技を持ったキャラクターがTPをためたら後衛に配置し，蘇生するタイミングで前衛に戻すといったことが可能になります．またバフ技を大量に掛けて一撃で突破するという方法も考えられます．
-->

Both concept of battle with 8 members and TP seem to be kinda boring, but they suddenly become interesting if they are combined. For example, skills to revive characters normally consume TPs. Players can locate characters having such skills in the rear guard after them collecting TPs and in the advance guard to revive characters. Also, it is possible to  buff a character a lot and attack an enemy in a stroke.

<!--
難易度は絶妙です．操作キャラクターはかなりの数が登場しますが，得意不得意はキャラクターによって異なるため，キャラクターを使い分けて攻略することが基本となっています．また敵の性質もやはりそれぞれ異なりますが，ゲーム中に攻略のための誘導が存在するため，かなり親切設計になっています．ただし敵味方の特徴を無視したゴリ押しをしようとすると，レベルがいくら高くても死にます（死にました）．
-->

The difficulty of the game is adjusted well. Quite a few characters appear in the game, but they have different strengths and weaks. Thus, the basic way to proceed the game is to use proper characters. Enemies also have different properties, but it is rather easy to find a way to proceed because cheat tips are hidden in the game. However, enemies will destroy your party if you try to ignore all the properties of characters and enemies and to combat enemies only with high character levels (yes, I tried it and couldn't get it all done.).

<!--
### ストーリーに関して
-->

### About the story

<!--
次に，ゲーム開始直後のナレーションを引用します．
-->

The following is the quote of the narration immediately after starting the game.

<!--
> ……この世界には召喚された物が溢れていた。
>
> いつ頃からか出来上がった召喚という技術は、様々な世界から技術、人、物を運んできたが、この画期的な技術に少々浮かれすぎた人々は、用もないのに多くの人を呼びすぎた。
>
> 結果として、仕事もなく、やることもなく。余ってしまった召喚された側――召喚人達が溢れてしまう。
>
> 彼らは、なんとか世界に馴染もうとの努力はするものの、そう簡単にはいかず、我慢の限界を超えた一部の召喚人達は、暴徒と化して暴れまわった。
>
> これに責任を感じた召喚士達は、暴徒の鎮圧に乗り出したが、あろうことか、鎮圧側の召喚人まで暴徒に肩入れして暴れまくり。
>
> 反乱の規模は広がり続け、その鎮圧に、たくさんの国と人々が疲労しまくった。
>
> 当然、召喚士達の面目は丸つぶれで、これ以降、召喚には大幅な制限がかけられることになったのである。
>
> ……この世界側からみると、一先ず落ち着いたような事件なのだけど、召喚された者にとっては、全くそうではなかった。
>
> 上手く逃げ延びた者、元々暴動騒ぎには興味なかった者。もう一騒ぎ企んでいる者……。まだまだ多数の召喚人が世界には残っている。
>
> 呼び出された世界に不満を持つ彼らと……。そんな彼らをハグレと読んで軽視するこの世界の人々とで、見えない摩擦が物語を動かそうとしていたが――。
>
> ここ辺境の、名前もない遺跡に逃げ込んだ彼女達の事情は、他の奴らとはだいぶ違っていた。
-->

> ... A lot of summoned things overfloed this world. (……この世界には召喚された物が溢れていた。)
>
> The summon technology that had been developed at some point in the past brought technologies, people, and things from various worlds, but people intoxicated by this breakthrough technology summoned too many people without particular reasons. (いつ頃からか出来上がった召喚という技術は、様々な世界から技術、人、物を運んできたが、この画期的な技術に少々浮かれすぎた人々は、用もないのに多くの人を呼びすぎた。)
>
> As a result, there remained no jobs. There were nothing to do. Surplus summoned people ―― summonees overflowed. (結果として、仕事もなく、やることもなく。余ってしまった召喚された側――召喚人達が溢れてしまう。)
>
> They somehow tried to get used to the world, but it was not so easy. Finally, some of the summonees who reached the limit of their patience became mobs and committed violence. (彼らは、なんとか世界に馴染もうとの努力はするものの、そう簡単にはいかず、我慢の限界を超えた一部の召喚人達は、暴徒と化して暴れまわった。)
>
> Summoners felt their responsibilities for this and started to quash the mobs, but what is worse, even summonees who were suppressing them began to support the mobs and to rampage. (これに責任を感じた召喚士達は、暴徒の鎮圧に乗り出したが、あろうことか、鎮圧側の召喚人まで暴徒に肩入れして暴れまくり。)
>
> The scale of the rebellion was continually expanding, and quelling them fatigued many countries and people. (反乱の規模は広がり続け、その鎮圧に、たくさんの国と人々が疲労しまくった。)
>
> Certainly, summoners lost their faces. After that, a large scale of restrictions was imposed on summoning. (当然、召喚士達の面目は丸つぶれで、これ以降、召喚には大幅な制限がかけられることになったのである。)
>
> ... From this world, this affar seemed to settle down, but from summoned people, it totally did not. (……この世界側からみると、一先ず落ち着いたような事件なのだけど、召喚された者にとっては、全くそうではなかった。)
>
> Those who successfully ran away, those who were not interested in the affair from the start, those who plan another riot... A lot of summonees still remain in this world. (上手く逃げ延びた者、元々暴動騒ぎには興味なかった者。もう一騒ぎ企んでいる者……。まだまだ多数の召喚人が世界には残っている。)
>
> Those who were not satisfied with the world where they are summoned and ... those who call them Hagure (ハグレ) and disrespect them. The unvisible friction between them was unfolding a story but ――. (呼び出された世界に不満を持つ彼らと……。そんな彼らをハグレと読んで軽視するこの世界の人々とで、見えない摩擦が物語を動かそうとしていたが――。)
>
> The situation of those who had fled to nameless ruins in this frontier was much different from others. (ここ辺境の、名前もない遺跡に逃げ込んだ彼女達の事情は、他の奴らとはだいぶ違っていた。)

<!--
### 前作「らんだむダンジョン」に関して
-->

### About the previous work "Random Dungeon"

<!--
前述の通り，ざくアクの製作者であるはむすた氏は，過去にらんだむダンジョン（通称らんダン）というゲームを製作しています．こちらもかなりの大作です．
-->

As I said above, Hamusuta, the creator of Zakuzaku Actors had created a game called "Random Dungeon" (a.k.a. Randan - **Ran**damu **Dan**jon). This is also a masterpiece.

<!--
ざくアクをプレイするにあたってらんダンを予めプレイする必要はありません．ざくアクにはらんダンのネタがいくつか用いられていますが，らんダンをやっていないからといって，ざくアクのストーリーが全く解らなくなるということはありません．それでももし時間があればらんダンもプレイすることをおすすめします．ざくアクの前にやっても，あとにやっても構いません．らんダン自体面白いですし，ざくアクに含まているネタがわかって結構楽しいです．
-->

You don't need to play Randan before playing Zakuaku. Although Zakuaku contains a few easter eggs derived from it, playing it is not necessary to understand Zakuaku's story. Still, I recommend to play Randan if you have time; you can play it either before or after playing Zakuaku. It's just fun to play it, and also interesting because you can find tips related to it in Zakuaku.

<!--
### Linuxでのプレイに関して
-->

### Playing on Linux

<!--
[Wine](https://www.winehq.org/)を用いればざくアクをLinuxでプレイすることはできますが，私自身は一部のBGMを再生させることができず，結局Windows上で動かすことにしました．
-->

While Zakuaku can be played on Linux with [Wine](https://www.winehq.org/), I've ended up running it on Windows because I couldn't make some BGMs play on Linux.

<!--
ざくアクには[WMA形式](https://ja.wikipedia.org/wiki/Windows_Media_Audio)の音源が用いられていますが，この形式で保存されているBGMを鳴らすことができませんでした．Wineでは2022年2月11日に公開された[バージョン7.2](https://www.winehq.org/announce/7.2)でWMAデコーダの開発が開始されたばかりなため，あくまで推測ですが，まだWMAを直接鳴らすことが出来ないのかなと考えています．従って素直にWindows上でプレイするほうが得策だと思います．
-->

Zakuaku uses [WMA format](https://ja.wikipedia.org/wiki/Windows_Media_Audio) for some BGMs, but I couldn't play them on Linux. Because Wine has just started to develop a WMA decoder since [version 7.2](https://www.winehq.org/announce/7.2) which was released on February 11th, 2022, it's just a guess, but WMA files can't be played directly yet. Therefore, I think simply running the game on Windows is the best way.

<!--
幸いにして，電通大の学生は[無料で個人PCにWindowsをインストールすることができます](https://www.cc.uec.ac.jp/ug/ja/license/ms/personal/kivuto/index.html)．これを利用するのも一つの手です．実際これ以外にも，例えば授業中にWindowsでしか動かないソフトウェアの利用を強いられることがありますし，Windowsマシンは一台あったほうが良いです．
-->

Fortunately, UEC students [can install Windows on a personal PC for free](https://www.cc.uec.ac.jp/ug/ja/license/ms/personal/kivuto/index.html). This is also a way to play the game. In fact, you should have at least one Windows machine becuase you may be forced to use a software which only runs on Windows in a class.

<!--
**Wineを利用したことによるトラブルや不具合に関してゲームの製作者に問い合わせないでください．Wineの使用は開発側の想定環境ではありません．**
-->

**DO NOT ASK THE GAME CREATERS EVEN IF YOU ENCOUNTERED ANY TROUBLES AND/OR DEFECTS DURING USING WINE. THE USE OF WINE IS NOT EXPECTED.**
