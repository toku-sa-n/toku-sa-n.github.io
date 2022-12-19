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

### コード例

以下の説明では，次のような，様々な世界に住む住民や集団の情報を一つのデータ構造に含めたものを用います．

```haskell
{-# LANGUAGE DeriveDataTypeable, RankNTypes, RecordWildCards #-}

module Lib
    ( gfoldMember
    , testMembersFromWorld
    , testMembersFromWorldWithListify
    , testListMossalcadiaMania
    , testSummonAllGroupsInKumamotoCastle
    , testAppendWorldForData
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

### 下準備：`Data`型クラスの実装

`syb`を利用するためには，型が`Data`型クラスを実装している必要があります．`Data`型クラスの詳細についてはドキュメントを確認してください．

何はともあれまずは実装方法ですが，GHCの拡張機能である`DeriveDataTypeable`を有効にして，`deriving (Data)`で完了です．もちろん手動で定義することも可能ですが，deriveしたほうが楽です．

以下の説明は，型に対し`Data`型クラスが適切に実装されていることを前提としています．

さて，この`Data`型クラスですが，一番重要なメソッドが[`gfoldl`](https://hackage.haskell.org/package/base-4.16.3.0/docs/Data-Data.html#t:Data)です．`Member`型では`deriving (Data)`を用いていますが，おおよそ以下のような実装が生成されます（実際の名前は`gfoldl`ですが，ここでは`gfoldMember`としています）．

```haskell
gfoldlMember ::
       (forall d b. Data d =>
                        c (d -> b) -> d -> c b)
    -> (forall g. g -> c g)
    -> Member
    -> c Member
gfoldlMember k z Member {..} =
    z Member `k` memberName `k` anotherName `k` age `k` favoriteMoss
```

つまり，`Member`の各フィールドの値を畳み込むことが出来ます．

`syb`で定義されている各関数は直接`gfoldl`関数を用いているのではなく，この関数を用いている`Data`型クラスの他のメソッドを使用しています．

### 使用例

#### 特定の型の値だけを抽出する

例えば以下のような，様々な世界に住む住民の情報を一つのデータ構造に含めたとします．

`World`に含まれている`Member`を全て抽出する関数を単純に書くと，以下の`membersFromWorld`関数のようになります．

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

`listify`関数は，抽出する値の条件を指定する関数を受け取り，「`Data`を実装する任意の型の値を受け取り，その値の構成要素のうち，条件を満たす値をリストとして返す」関数を返します．

`listify`関数のシグネチャは`Typeable r => (r -> Bool) -> GenericQ [r]`となっています．この`r`が，最終的なリストの要素の型となります．すなわちこの関数が返す関数は，受け取った値に含まれている型`r`の値に対し，それが条件を満たすかどうかを確認しています．上記の場合，`const True`で常に`True`を返すことで，型`r`の値を常に抽出するするようにします．

なお，`GenericQ`は`forall a. Data a => a -> r`のエイリアスです．また，[ドキュメントに記載されている](https://hackage.haskell.org/package/base-4.16.3.0/docs/Data-Typeable.html)ように，GHC7.10以降，全ての型は自動で`Typeable`をderiveしているため，型変数などを用いていなければ基本的に`listify`を任意の型に対して使用することができると考えて大丈夫です．以下に引用します．

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

妙な話ですが，例えば全ての集団が突然熊本城に召喚されたとしましょう．`Group`の`place`を全て熊本城に変更しなければなりません．やはりこれも小規模のデータ構造ならいくつの関数を定義すればどうにかなります．しかし大規模なものになると手に負えません．

このような場合，`syb`で定義されている[`everywhere`](https://hackage.haskell.org/package/syb-0.7.2.2/docs/Data-Generics-Schemes.html#v:everywhere)を使うと楽に書けます．

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
    nub (fmap place $ listify f $ fmap summonAllGroupsInKumamotoCastle worlds) `shouldBe`
    ["熊本城"]
  where
    f :: Group -> Bool
    f = const True
```

`everywhere`のシグネチャは`(forall a. Data a => a -> a) -> forall a. Data a => a -> a`となっています．`listify`の場合，引数の型は`Typeable r => (r -> Bool)`でしたので，単純に`Member -> Bool`などと，適当な型の値を受け取って`Bool`値を返す関数を渡せばよいのですが，`everywhere`は`Data`を実装する任意の型を受け取って，同じ型の値を返す関数を定義しなければならず，ある特定の型の値に対する操作を行うのは不可能のように見えます．

ここで利用するものが[`mkT`](https://hackage.haskell.org/package/syb-0.7.2.2/docs/Data-Generics-Aliases.html#v:mkT)です．`mkT`のシグネチャは`(Typeable a, Typeable b) => (b -> b) -> a -> a`ですが，この関数は，`b`型の値を受け取り，同じ型の値を返す関数を受け取り，それを`Typeable`な任意の型`a`の値を受け取り，同じ型の値を返す関数に拡張します．この際，受け取った値の型が実際には`b`である場合，受け取った関数を適用し，そうでなければ単純に受け取った値を返すようになります．以下に実行例を示します．

```haskell
appendWorld :: String -> String
appendWorld = (++ " World")

appendWorldForData :: Data a => a -> a
appendWorldForData = mkT appendWorld

testAppendWorldForData :: Spec
testAppendWorldForData =
    describe "appendWorldForData" $ do
        it "受け取った値の型が`String`なら，\" World\"を付加する" $
            appendWorldForData "Hello" `shouldBe` "Hello World"
        it "受け取った値の型が`String`ではないなら，受け取った値をそのまま返す" $
            appendWorldForData (3 :: Int) `shouldBe` 3
```

上記の熊本城の例では，関数`f :: Group -> Group`に`mkT`を適用したものを`everywhere`で使用しています．もし
