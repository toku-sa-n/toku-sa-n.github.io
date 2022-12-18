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

### 使用例

#### 特定の型の値だけを抽出する

例えば以下のような，様々な世界に住む住民の情報を一つのデータ構造に含めたとします．

```haskell
{-# LANGUAGE DeriveDataTypeable #-}

module Lib
    ( testMembersFromWorld
    , testMembersFromWorldWithListify
    , testListMossalcadiaMania
    , testSummonAllGroupsInKumamotoCastle
    ) where

import           Data.Data             (Data)
import           Data.Generics.Aliases (mkT)
import           Data.Generics.Schemes (everywhere, listify)
import           Data.List             (nub)
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
          { worldName = "イルヴァ"
          , groups =
                [ Group
                      { groupName = "エレア"
                      , place = "ノースティリス"
                      , members =
                            [ Member
                                  { memberName = "ロミアス"
                                  , anotherName = "異形の森の使者"
                                  , age = Just 24
                                  , favoriteMoss = Nothing
                                  }
                            , Member
                                  { memberName = "ラーネイレ"
                                  , anotherName = "風を聴く者"
                                  , age = Just 22
                                  , favoriteMoss = Nothing
                                  }
                            ]
                      }
                , Group
                      { groupName = "ヴェルニースの人達"
                      , place = "ヴェルニース"
                      , members =
                            [ Member
                                  { memberName = "ウェゼル"
                                  , anotherName = "ザナンの白き鷹"
                                  , age = Just 31
                                  , favoriteMoss = Nothing
                                  }
                            , Member
                                  { memberName = "ロイター"
                                  , anotherName = "ザナンの紅の英雄"
                                  , age = Just 32
                                  , favoriteMoss = Nothing
                                  }
                            ]
                      }
                ]
          }
    , World
          { worldName = "ざくざくアクターズの世界"
          , groups =
                [ Group
                      { groupName = "ハグレ王国"
                      , place = "ハグレ王国"
                      , members =
                            [ Member
                                  { memberName = "デーリッチ"
                                  , anotherName = "ハグレ王国国王"
                                  , age = Nothing
                                  , favoriteMoss = Nothing
                                  }
                            , Member
                                  { memberName = "ローズマリー"
                                  , anotherName = "ビッグモス"
                                  , age = Nothing
                                  , favoriteMoss = Just "モスアルカディア"
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
          { memberName = "ロミアス"
          , anotherName = "異形の森の使者"
          , age = Just 24
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "ラーネイレ"
          , anotherName = "風を聴く者"
          , age = Just 22
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "ウェゼル"
          , anotherName = "ザナンの白き鷹"
          , age = Just 31
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "ロイター"
          , anotherName = "ザナンの紅の英雄"
          , age = Just 32
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "デーリッチ"
          , anotherName = "ハグレ王国国王"
          , age = Nothing
          , favoriteMoss = Nothing
          }
    , Member
          { memberName = "ローズマリー"
          , anotherName = "ビッグモス"
          , age = Nothing
          , favoriteMoss = Just "モスアルカディア"
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

`listify`関数のシグネチャは`Typeable r => (r -> Bool) -> GenericQ [r]`となっています．引数で型`r`の値に対し，抽出する条件を指定します．`const True`で常に`True`を返すことで，型`r`の値を常に抽出するするようにします．なお，`GenericQ`は`forall a. Data a => a -> r`のエイリアスです．また，[ドキュメントに記載されている](https://hackage.haskell.org/package/base-4.16.3.0/docs/Data-Typeable.html)ように，GHC7.10以降，全ての型は自動で`Typeable`をderiveしているため，型変数などを用いていなければ基本的に`listify`を任意の型に対して使用することができると考えて大丈夫です．以下に引用します．

> Since GHC 7.10, all types automatically have Typeable instances derived. This is in contrast to previous releases where Typeable had to be explicitly derived using the DeriveDataTypeable language extension.

引数で抽出する条件を指定するため，例えばモスアルカディアが好きな人物だけを抽出することも可能です．

```haskell
listMossalcadiaMania :: World -> [Member]
listMossalcadiaMania = listify f
  where
    f :: Member -> Bool
    f = (== Just "モスアルカディア") . favoriteMoss

testListMossalcadiaMania :: Spec
testListMossalcadiaMania =
    describe "listMossalcadiaMania" $
    it "lists all `Member`s who love Mossalcadia" $
    concatMap listMossalcadiaMania worlds `shouldBe` expected
  where
    expected =
        [ Member
              { memberName = "ローズマリー"
              , anotherName = "ビッグモス"
              , age = Nothing
              , favoriteMoss = Just "モスアルカディア"
              }
        ]
```

#### 特定の型の値を変更する

妙な話ですが，例えば全ての集団が突然熊本城に召喚されたとしましょう．やはりこれも小規模のデータ構造ならいくつの関数を定義すればどうにかなります．しかし大規模なものになると手に負えません．

このような場合，`syb`で定義されている`everywhere`を使うと楽に書けます．

```haskell
summonAllGroupsInKumamotoCastle :: World -> World
summonAllGroupsInKumamotoCastle = everywhere (mkT f)
  where
    f :: Group -> Group
    f x = x {place = "熊本城"}

testSummonAllGroupsInKumamotoCastle :: Spec
testSummonAllGroupsInKumamotoCastle =
    describe "summonAllGroupsInKumamotoCastle" $
    it "sets \"熊本城\" to the `place`s of all `Group`s in a `World`" $
    nub (fmap place $ listify f $ fmap summonAllGroupsInKumamotoCastle worlds)
    `shouldBe` ["熊本城"]
  where
    f :: Group -> Bool
    f = const True
```

ここで，`mkT`という関数を使用しています．
