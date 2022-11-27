+++
title = "Migration from Hatena Blog"
date = 2022-11-23
+++

<!--
個人ブログを[はてなブログ](https://tokuchan3515.hatenablog.com/)からGitHub Pagesに移行することにした．はてなブログに不満はないし，実際おすすめするブログサービスを訊かれたら多分はてなブログと答えるが，3つの理由があって切り替えることにした．
-->

I have migrated my personal blog from [Hatena Blog](https://tokuchan3515.hatenablog.com/) to GitHub Pages. I do not have any complaints about Hatena Blog, and actually I would recommend it if somebody asked me which blog service to use. However, I have decided to switch the blog service for three reasons.

<!--
1つ目の理由は，記事の検証スクリプトを実装したかったからである．本やウェブサイトの内容が古く，コードを写経して実行しようとするとエラーが出たという経験が過去に何回かある．記事内のコードが正しく動作するかを検証するスクリプトを用意し，GitHub Actionsを用いてcronで定期的にそのスクリプトを実行すれば，コードがいざ実行できなくなった際に気付くことができる．もちろんスクリプトが実際の記事の内容を反映していないと意味を成さないし，APIがdeprecatedになった場合や，もっと良い代替法が提案されたなどといった場合は検証スクリプトでは検知できないが，それでもコードが常に動くということを保証できるのは良いと考えた．
-->

The first reason is that I wanted to implement an article's validation script. When I typed codes written in a book or a website, sometimes I could not run them because they were out of date. If I prepare a script that checks if the code in an article correctly works and run it on GitHub Actions with cron, I can notice if it fails. Of course, the script would be meaningless if it was not written correctly. Also, the script cannot detect the deprecation of APIs or a proposal of a better method. Still, I thought it would be good to guarantee that the code would always work.

<!--
2つ目の理由は，記事を簡単に手元のマシンに置けることである．はてなブログの内容は[エクスポートできる](https://help.hatenablog.com/entry/export)が，形式が常にHTMLに固定され，更にブラウザ上で操作をしなければならない．その点マークダウンで記事の内容を残すことができ，かつコマンド一つで手元にコピーできるこちらの方が楽だと感じた．万一の際に楽に保存できる機能は欲しい．
-->

The second reason is that I can copy articles easily on my local machine. While the content of a Hatena Blog [can be exported](https://help.hatenablog.com/entry/export), the format is always fixed to HTML. Also, I need to manipulate the web browser to do so. On the other hand, I felt it easy to use GitHub Pages because I can keep the articles in markdown format and copy them by a single command. I wanted a way to store them easily for a rainy day.

<!--
3つ目の理由は，自分でHTMLやらCSSやらJSを試してみたかったからである．もちろんはてなブログの方でもある程度試すことはできるが，こちらの方が幅広く扱うことができるので良いと思った．
-->

The third reason is that I wanted to try HTML, CSS, JS, and so on. Of course, I can try them on Hatena Blog, but I thought using GitHub Pages is better because I can try wider range of things.

<!--
以上の理由である．
-->

That's all.

<!--
使うツールは[Zola](https://www.getzola.org/)にした．静的なウェブサイトを製作するツールはおそらく他にもあると思うが，よく閲覧していた[Writing an OS in Rust](https://os.phil-opp.com/)でZolaが使われている，ソースコードが公開されている位の理由でこれを選択した．
-->

I have decided to use [Zola](https://www.getzola.org/). I think there are other tools to create a static website, but I have chose it because [Writing an OS in Rust](https://os.phil-opp.com/) which I often browsed uses used it, and because its source code is publicly available.
