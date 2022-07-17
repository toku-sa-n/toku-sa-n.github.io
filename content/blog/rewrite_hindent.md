+++
title = "hindentをghc-lib-parserで書き換える"
date = 2022-07-16
+++

### Haskellフォーマッタについて

[`hindent`](https://github.com/mihaimaruseac/hindent)はHaskellのフォーマッタの一つである．

Haskellのフォーマッタは以下のようにいくつかある．

* [`stylish-haskell`](https://github.com/haskell/stylish-haskell)
* [`ormolu`](https://github.com/tweag/ormolu)とその派生である[`fourmolu`](https://github.com/fourmolu/fourmolu)
* `stylish-haskell`，`hindent`，そしてlinterである[`hlint`](https://github.com/ndmitchell/hlint)を組み合わせた[`hfmt`](https://github.com/danstiner/hfmt)

どこかで`hfmt`を見つけてそれを利用していたが，途中でうまく行かなくなり`hindent|stylish-haskell`を利用するようにした．ただ，2つのバイナリをインストールするのもなんだか大げさな感じがして，どこかで見つけた`ormolu`を利用しようとしたが，インデント幅が2で固定なのに不満を持ち，その派生である`fourmolu`を利用した．しかしそのフォーマット結果が気に入らず，結局`hindent|stylish-haskell`を利用している．
