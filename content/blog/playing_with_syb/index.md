+++
title = "sybで遊ぶ"
date = 2022-12-20
+++

### はじめに

この記事は，[Haskell Advent Calendar 2022](https://qiita.com/advent-calendar/2022/haskell)の20日目の記事です．

この記事では，Haskellライブラリの一つである[syb](https://hackage.haskell.org/package/syb-0.7.2.2)の簡単な紹介と，実際に私がプロジェクトの中で使用した例を紹介します．

### バージョン情報

| 名前                        | バージョン                    |
|-----------------------------|-------------------------------|
| Stack                       | 2.9.1                         |
| Stack resolver              | LTS 20.4                      |
| GHCやライブラリのバージョン | LTSで指定されているものを使用 |

### `syb`とは

`syb`とはScrap Your Boilerplateの略です．[`Data`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Data.html#t:Data)型クラスや[`Typeable`](https://hackage.haskell.org/package/base-4.16.4.0/docs/Data-Typeable.html#t:Typeable)を利用して，データ構造に含まれている特定の型の値だけに対して操作を行ったり，特定の型の値だけを抽出するなどといったことが可能になります．

[Haskell Wiki](https://wiki.haskell.org/Research_papers/Generics)にいくつか論文が紹介されていますが，特に[Scrap Your Boilerplate: A Practical Design Pattern for Generic Programming](https://www.microsoft.com/en-us/research/wp-content/uploads/2003/01/hmap.pdf)は読みやすいのでおすすめです．

例えば以下のような，様々な世界に住む住民の情報を一つのデータ構造に含めたとします．

```haskell
{-# LANGUAGE DeriveDataTypeable #-}

module Lib
    ( testMembersFromWorld
    , testMembersFromWorldWithListify
    ) where

import           Data.Data             (Data)
import           Data.Generics.Schemes (listify)
import           Test.Hspec            (Spec, describe, it, shouldBe)

data World =
    World
        { worldName :: String
        , groups    :: [Group]
        }
    deriving (Data, Eq)

data Group =
    Group
        { groupName :: String
        , place     :: String
        , members   :: [Member]
        }
    deriving (Data, Eq)

data Member =
    Member
        { memberName   :: String
        , anotherName  :: String
        , age          :: Maybe Int
        , favoriteMoss :: Maybe String
        }
    deriving (Data, Eq, Show)

worlds :: [World]
worlds =
    [ World
          { worldName = "Ilva"
          , groups =
                [ Group
                      { groupName = "Elea"
                      , place = "North Tyris"
                      , members =
                            [ Member
                                  { memberName = "Romias"
                                  , anotherName = "The messenger from Vindale"
                                  , age = Just 24
                                  , favoriteMoss = Nothing
                                  }
                            , Member
                                  { memberName = "Larnneire"
                                  , anotherName = "The listener of the wind"
                                  , age = Just 22
                                  , favoriteMoss = Nothing
                                  }
                            ]
                      }
                , Group
                      { groupName = "People in Vernis"
                      , place = "Vernis"
                      , members =
                            [ Member
                                  { memberName = "Vessel"
                                  , anotherName = "The white hawk"
                                  , age = Just 31
                                  , favoriteMoss = Nothing
                                  }
                            , Member
                                  { memberName = "Loyter"
                                  , anotherName = "The crimson of Zanan"
                                  , age = Just 32
                                  , favoriteMoss = Nothing
                                  }
                            ]
                      }
                ]
          }
    , World
          { worldName = "The world of Zakuzaku Actors"
          , groups =
                [ Group
                      { groupName = "Hagure Queendom"
                      , place = "Hagure Queendom"
                      , members =
                            [ Member
                                  { memberName = "Derich"
                                  , anotherName = "The queen of Hagure Queendom"
                                  , age = Nothing
                                  , favoriteMoss = Nothing
                                  }
                            , Member
                                  { memberName = "Rosemary"
                                  , anotherName = "Big moss"
                                  , age = Nothing
                                  , favoriteMoss = Just "Mossarcadia"
                                  }
                            ]
                      }
                ]
          }
    ]
```

`World`に含まれている`Member`を全て抽出する関数を単純に書くと以下のようになります．

```haskell
membersFromWorld :: World -> [Member]
membersFromWorld = concatMap members . groups

allMembersInWorld :: [Member]
allMembersInWorld =
    [ Member
          { memberName = "Romias"
          , anotherName = "The messenger from Vindale"
          , age = Just 24
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "Larnneire"
          , anotherName = "The listener of the wind"
          , age = Just 22
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "Vessel"
          , anotherName = "The white hawk"
          , age = Just 31
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "Loyter"
          , anotherName = "The crimson of Zanan"
          , age = Just 32
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "Derich"
          , anotherName = "The queen of Hagure Queendom"
          , age = Nothing
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "Rosemary"
          , anotherName = "Big moss"
          , age = Nothing
          , favoriteMoss = Just "Mossarcadia"
          }
    ]

testMembersFromWorld :: Spec
testMembersFromWorld =
    describe "membersFromWorld" $
    it "returns all `Member`s in a `World`" $
    concatMap membersFromWorld worlds `shouldBe` allMembersInWorld
```

今回の場合，`World`の構造があまり複雑ではないため，いくつかの関数を用いて簡単に抽出することが出来ました．しかし，例えば`Maybe`が使われていたり，構造がもっと大きく複雑だったり，型引数が使用されていたりすると，今回のようにセレクタ関数を組み合わせて抽出する方法は難しくなります．

そのような場合，sybの[`listify`](https://hackage.haskell.org/package/syb-0.7.2.2/docs/Data-Generics-Schemes.html#v:listify)関数を用いるとすんなり書けます．

```haskell
membersFromWorldWithListify :: World -> [Member]
membersFromWorldWithListify = listify onlyMember
  where
    onlyMember :: Member -> Bool
    onlyMember = const True

testMembersFromWorldWithListify :: Spec
testMembersFromWorldWithListify =
    describe "membersFromWorldWithListify" $
    it "has the same functionality with `testMembersFromWorld`" $
    concatMap membersFromWorldWithListify worlds `shouldBe`
    concatMap membersFromWorld worlds
```
