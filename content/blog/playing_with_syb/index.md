+++
title = "sybで遊ぶ"
date = 2022-12-20
+++

### はじめに

この記事は，[Haskell Advent Calendar 2022](https://qiita.com/advent-calendar/2022/haskell)の20日目の記事です．

この記事では，Haskellライブラリの一つである[syb](https://hackage.haskell.org/package/syb-0.7.2.2)の簡単な紹介と，実際に私がプロジェクトの中で使用した例を紹介します．

### バージョン情報

| 名前           | バージョン |
|----------------|------------|
| Stack          | 2.9.1      |
| Stack resolver | LTS 20.4   |

GHCやライブラリのバージョンはLTSで指定されているものを使用しています．

### `syb`とは

`syb`とはScrap Your Boilerplateの略です．[`Data`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Data.html#t:Data)型クラスや[`Typeable`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Typeable.html#t:Typeable)を利用して，データ構造に含まれている特定の型の値だけに対して操作を行ったり，特定の型の値だけを抽出するなどといったことが可能になります．

[Haskell Wiki](https://wiki.haskell.org/Research_papers/Generics)にいくつか論文が紹介されています．特に[Scrap Your Boilerplate: A Practical Design Pattern for Generic Programming](https://www.microsoft.com/en-us/research/wp-content/uploads/2003/01/hmap.pdf)は読みやすいのでおすすめです．
