+++
title = "`everywhereMr'`を定義する"
date = 2022-08-21
+++

### [`everywhereM`](https://hackage.haskell.org/package/syb-0.7.2.1/docs/Data-Generics-Schemes.html#v:everywhereM)について

[`everywhere`](https://hackage.haskell.org/package/syb-0.7.2.1/docs/Data-Generics-Schemes.html#v:everywhere)とほとんど同じことをやるが，モナド値に対応している．

次のようなデータ構造があるとする．

```haskell
data Foo =
  Foo
    { bar :: Bar
    , baz :: Baz
    , qux :: Int
    }
  deriving (Data, Show)

data Bar =
  Bar
    { quux   :: Int
    , corge  :: Corge
    , grault :: Int
    }
  deriving (Data, Show)

data Baz =
  Baz
    { garply :: Int
    , waldo  :: Int
    }
  deriving (Data, Show)

data Corge =
  Corge
    { fred  :: Int
    , plugh :: Int
    }
  deriving (Data, Show)

zeroes :: Foo
zeroes =
  Foo
    { bar = Bar {quux = 0, corge = Corge {fred = 0, plugh = 0}, grault = 0}
    , baz = Baz {garply = 0, waldo = 0}
    , qux = 0
    }
```

ここで，すべての値に連番を振る．これは`everywhereM`とStateモナドを用いることで実装できる．なお，次のコードにおいて，[`pPrint`](https://hackage.haskell.org/package/pretty-simple-4.1.1.0/docs/Text-Pretty-Simple.html#v:pPrint)は[`pretty-simple`](https://hackage.haskell.org/package/pretty-simple)パッケージに定義されている．

```haskell
increment :: Foo -> State Int Foo
increment = everywhereM (mkM f)
  where
    f _ = do
      n <- get
      modify (+ 1)
      return n

main :: IO ()
main = pPrint $ evalState (increment zeroes) 0
```

出力は以下の通り．

```
Foo
    { bar = Bar
        { quux = 0
        , corge = Corge
            { fred = 1
            , plugh = 2
            }
        , grault = 3
        }
    , baz = Baz
        { garply = 4
        , waldo = 5
        }
    , qux = 6
    }
```

### ほしい関数

`everywhereM`と似ているけれども，右から変形していく`everywhereMr`がほしい．

```haskell
incrementR :: Foo -> State Int Foo
incrementR = everywhereMr (mkM f)
  where
    f _ = do
      n <- get
      modify (+ 1)
      return n

main :: IO ()
main = pPrint $ evalState (incrementR zeroes) 0
```

出力が以下のようになってほしい．

```
Foo
    { bar = Bar
        { quux = 6
        , corge = Corge
            { fred = 5
            , plugh = 4
            }
        , grault = 3
        }
    , baz = Baz
        { garply = 2
        , waldo = 1
        }
    , qux = 0
    }
```

### `everywhereM`の実装を確認する．

[`everywhereM`の実装](https://hackage.haskell.org/package/syb-0.7.2.1/docs/src/Data.Generics.Schemes.html#everywhereM)を確認する．

**以下のコードのライセンスは[`syb`のライセンス](https://hackage.haskell.org/package/syb-0.7.2.1/src/LICENSE)に従い3条項BSD3ライセンスの元で引用しています．ライセンス全文はこのページの最後に付録として掲載しています．**

```haskell
-- | Monadic variation on everywhere
everywhereM :: forall m. Monad m => GenericM m -> GenericM m

-- Bottom-up order is also reflected in order of do-actions
everywhereM f = go
  where
    go :: GenericM m
    go x = do
      x' <- gmapM go x
      f x'
```

### 付録

#### [`syb`のライセンス](https://hackage.haskell.org/package/syb-0.7.2.1/src/LICENSE)

```
This library (libraries/syb) is derived from code from several
sources:

  * Code from the GHC project which is largely (c) The University of
    Glasgow, and distributable under a BSD-style license (see below),

  * Code from the Haskell 98 Report which is (c) Simon Peyton Jones
    and freely redistributable (but see the full license for
    restrictions).

  * Code from the Haskell Foreign Function Interface specification,
    which is (c) Manuel M. T. Chakravarty and freely redistributable
    (but see the full license for restrictions).

The full text of these licenses is reproduced below.  All of the
licenses are BSD-style or compatible.

-----------------------------------------------------------------------------

The Glasgow Haskell Compiler License

Copyright 2004, The University Court of the University of Glasgow.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

- Neither name of the University nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE UNIVERSITY COURT OF THE UNIVERSITY OF
GLASGOW AND THE CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
UNIVERSITY COURT OF THE UNIVERSITY OF GLASGOW OR THE CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

-----------------------------------------------------------------------------

Code derived from the document "Report on the Programming Language
Haskell 98", is distributed under the following license:

  Copyright (c) 2002 Simon Peyton Jones

  The authors intend this Report to belong to the entire Haskell
  community, and so we grant permission to copy and distribute it for
  any purpose, provided that it is reproduced in its entirety,
  including this Notice.  Modified versions of this Report may also be
  copied and distributed for any purpose, provided that the modified
  version is clearly presented as such, and that it does not claim to
  be a definition of the Haskell 98 Language.

-----------------------------------------------------------------------------

Code derived from the document "The Haskell 98 Foreign Function
Interface, An Addendum to the Haskell 98 Report" is distributed under
the following license:

  Copyright (c) 2002 Manuel M. T. Chakravarty

  The authors intend this Report to belong to the entire Haskell
  community, and so we grant permission to copy and distribute it for
  any purpose, provided that it is reproduced in its entirety,
  including this Notice.  Modified versions of this Report may also be
  copied and distributed for any purpose, provided that the modified
  version is clearly presented as such, and that it does not claim to
  be a definition of the Haskell 98 Foreign Function Interface.

-----------------------------------------------------------------------------
```
