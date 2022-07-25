+++
title = "hindentをghc-lib-parserで書き換える"
date = 2022-07-16
+++

## 概要

### Haskellフォーマッタについて

[`hindent`](https://github.com/mihaimaruseac/hindent)はHaskellのフォーマッタの一つである．

Haskellのフォーマッタは以下のようにいくつかある．

* [`stylish-haskell`](https://github.com/haskell/stylish-haskell)
* [`ormolu`](https://github.com/tweag/ormolu)とその派生である[`fourmolu`](https://github.com/fourmolu/fourmolu)
* `stylish-haskell`，`hindent`，そしてlinterである[`hlint`](https://github.com/ndmitchell/hlint)を組み合わせた[`hfmt`](https://github.com/danstiner/hfmt)

始めは`hfmt`を見つけてそれを利用していたが，途中でうまく行かなくなり`hindent|stylish-haskell`を利用するようにした．ただ，2つのバイナリをインストールするのもなんだか大げさな感じがして，どこかで見つけた`ormolu`を利用しようとしたが，インデント幅が2で固定なのに不満を持ち，その派生である`fourmolu`を利用した．しかしそのフォーマット結果が気に入らず，結局`hindent|stylish-haskell`を利用している．

### `hindent`の問題点

`hindent`は[`haskell-src-exts`](https://github.com/haskell-suite/haskell-src-exts)を使用している．残念ながら，このライブラリは更新が止まっている．特に問題となるのが，GHCの更新によって新しい拡張機能が追加された場合，それに対応することが不可能となることである．

この問題は[`hindent`のissue](https://github.com/mihaimaruseac/hindent/issues/587)で報告した．そしてこの記事は，この問題を解決する過程で起こった様々なメモである．

## バージョン情報

| ソフトウェア・ライブラリ | バージョン情報 |
|--------------------------|----------------|
| GHC                      | 9.2.2          |
| ghc-lib-parser           | 9.2.3.20220709 |

## メモ一覧

### 個別にインポートした識別子も`ImportDecl`の`ideclHiding`に格納される

以下のコードを考える．ファイル名は`app/Main.hs`である．

```haskell
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE RankNTypes       #-}

module Main
  ( main
  ) where

import           Generics.SYB                                        (listify)
import           GHC.Data.EnumSet
import           GHC.Data.FastString
import           GHC.Data.StringBuffer
import           GHC.Driver.Ppr
import           GHC.Driver.Session
import           GHC.Hs
import           GHC.Parser
import           GHC.Parser.Lexer
import           GHC.Stack
import           GHC.Types.SrcLoc
import           GHC.Utils.Outputable                                hiding
                                                                     (empty)
import           Language.Haskell.GhclibParserEx.GHC.Settings.Config

--- main function
main :: IO ()
main = do
  src <- readFile filename
  --- module
  let m = unwrapParseResult $ runParser parserOpts src parseModule
  printOutputable $ ideclHiding <$> listify only m

only :: ImportDecl GhcPs -> Bool
only = const True

runParser :: ParserOpts -> String -> P a -> ParseResult a
runParser opts str parser = unP parser parserState
  where
    parserState = initParserState opts b location
    b = stringToStringBuffer str
    location = mkRealSrcLoc (mkFastString filename) 1 1

unwrapParseResult :: HasCallStack => ParseResult a -> a
unwrapParseResult (POk _ m)  = m
unwrapParseResult PFailed {} = error "Parse failed."

printOutputable :: Outputable a => a -> IO ()
printOutputable = putStrLn . showOutputable

showOutputable :: Outputable a => a -> String
showOutputable = showPpr dynFlags

parserOpts :: ParserOpts
parserOpts = mkParserOpts empty empty False True True True

dynFlags :: DynFlags
dynFlags = defaultDynFlags fakeSettings fakeLlvmConfig

filename :: FilePath
filename = "app/Main.hs"
```

実行結果は以下のようになる．

```sh
%cabal run
Up to date
[Just (False, [listify]), Nothing, Nothing, Nothing, Nothing,
 Nothing, Nothing, Nothing, Nothing, Nothing, Nothing,
 Just (True, [empty]), Nothing]
```

`ideclHiding`という名前で紛らわしいが，個別にインポートする場合もこのフィールドに情報が保存される．タプルの第一項が`False`の場合は個別にインポートし，`True`の場合は逆にそれだけを隠すということになる．

### `StarIsType`

[TESTS.md](https://github.com/mihaimaruseac/hindent/blob/4c2ea034f4365cd784539f223282907c9e734fba/TESTS.md)に存在する以下のコードが`ghc-lib-parser`の`parseModule`でパースできなかった．

```haskell
data Ty :: (* -> *) where
  TCon
    :: { field1 :: Int
       , field2 :: Bool}
    -> Ty Bool
  TCon' :: (a :: *) -> a -> Ty a
```

どうも[`StarIsType`](https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/poly_kinds.html)という拡張機能をオプションとして渡していなかったためで，これを渡すとパースできた．この拡張機能は`*`を[`Data.Kind.Type`](https://hackage.haskell.org/package/base-4.16.2.0/docs/Data-Kind.html#t:Type)として扱うもので，つまるところ上記コードの`Ty :: (* -> *)`を有効なHaskellコードと認識させるために必要だった．ちなみに既定では有効になっている．

`haskell-src-exts`の[`KnownExtensions`](https://hackage.haskell.org/package/haskell-src-exts-1.23.1/docs/Language-Haskell-Exts-Extension.html#v:knownExtensions)にはこの拡張機能が存在しなかったが，`haskell-src-exts`の`parseModuleWithComments`では，これが有効になっていることを前提としてパースされていたのではないかと思う．
