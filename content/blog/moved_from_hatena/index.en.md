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

The first reason is that I wanted to implement an article's validation script. When I typed codes written in a book or a website, sometimes I could not run them because they were too old. Preparing a
