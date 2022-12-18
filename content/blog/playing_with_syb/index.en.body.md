<!--
### はじめに
-->

### Introduction

<!--
この記事は，[Haskell Advent Calendar 2022](https://qiita.com/advent-calendar/2022/haskell)の20日目の記事です．
-->

This is the 20th article of [Haskell Advent Calendar 2022](https://qiita.com/advent-calendar/2022/haskell).

<!--
この記事では，Haskellライブラリの一つである[syb](https://hackage.haskell.org/package/syb-0.7.2.2)の簡単な紹介と，実際に私がプロジェクトの中で使用した例を紹介します．
-->

This article briefly introduces [syb](https://hackage.haskell.org/package/syb-0.7.2.2) which is one of Haskell libraries, and an example where I used it in a project.

<!--
### バージョン情報
-->

### Versions

<!--
| 名前                        | バージョン                    |
|-----------------------------|-------------------------------|
| Stack                       | 2.9.1                         |
| Stack resolver              | LTS 20.4                      |
| GHCやライブラリのバージョン | LTSで指定されているものを使用 |
-->

| Name                          | Version               |
|-------------------------------|-----------------------|
| Stack                         | 2.9.1                 |
| Stack resolver                | LTS 20.4              |
| Versions of GHC and libraries | Ones specified by LTS |

<!--
### `syb`とは
-->

### What is `syb`?

<!--
`syb`とはScrap Your Boilerplateの略です．[`Data`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Data.html#t:Data)型クラスや[`Typeable`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Typeable.html#t:Typeable)を利用して，データ構造に含まれている特定の型の値だけに対して操作を行ったり，特定の型の値だけを抽出するなどといったことが可能になります．
-->

`syb` stands for Scrap Your Boilerplate. It can be used to operate or extract only on values of a specific type with [`Data`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Data.html#t:Data) and [`Typeable`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Typeable.html#t:Typeable) typeclasses.

<!--
[Haskell Wiki](https://wiki.haskell.org/Research_papers/Generics)にいくつか論文が紹介されていますが，特に[Scrap Your Boilerplate: A Practical Design Pattern for Generic Programming](https://www.microsoft.com/en-us/research/wp-content/uploads/2003/01/hmap.pdf)は読みやすいのでおすすめです．
-->

[Haskell Wiki](https://wiki.haskell.org/Research_papers/Generics) lists papers related to syb. I recommend to read [Scrap Your Boilerplate: A Practical Design Pattern for Generic Programming](https://www.microsoft.com/en-us/research/wp-content/uploads/2003/01/hmap.pdf) because it is easy to read.
