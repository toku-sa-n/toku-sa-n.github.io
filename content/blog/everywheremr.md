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
