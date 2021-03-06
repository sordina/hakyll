--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
module Hakyll.Web.Template.Tests
    ( tests
    ) where


--------------------------------------------------------------------------------
import           Data.Monoid                    (mconcat)
import           Test.Framework                 (Test, testGroup)
import           Test.Framework.Providers.HUnit (testCase)
import           Test.HUnit                     (Assertion, (@=?), (@?=))


--------------------------------------------------------------------------------
import           Hakyll.Core.Compiler
import           Hakyll.Core.Item
import           Hakyll.Core.Provider
import           Hakyll.Web.Pandoc
import           Hakyll.Web.Template
import           Hakyll.Web.Template.Context
import           Hakyll.Web.Template.Internal
import           Hakyll.Web.Template.List
import           TestSuite.Util


--------------------------------------------------------------------------------
tests :: Test
tests = testGroup "Hakyll.Core.Template.Tests"
    [ testCase "case01"                case01
    , testCase "applyJoinTemplateList" testApplyJoinTemplateList
    ]


--------------------------------------------------------------------------------
case01 :: Assertion
case01 = do
    store    <- newTestStore
    provider <- newTestProvider store

    out  <- resourceString provider "template.html.out"
    tpl  <- testCompilerDone store provider "template.html" $
        templateCompiler
    item <- testCompilerDone store provider "example.md"    $
        pandocCompiler >>= applyTemplate (itemBody tpl) testContext

    writeFile "foo" (itemBody item)

    out @=? itemBody item
    cleanTestEnv


--------------------------------------------------------------------------------
testContext :: Context String
testContext = mconcat
    [ defaultContext
    , listField "authors" (bodyField "name") $ do
        n1 <- makeItem "Jan"
        n2 <- makeItem "Piet"
        return [n1, n2]
    ]
  where


--------------------------------------------------------------------------------
testApplyJoinTemplateList :: Assertion
testApplyJoinTemplateList = do
    store    <- newTestStore
    provider <- newTestProvider store
    str      <- testCompilerDone store provider "item3" $
        applyJoinTemplateList ", " tpl defaultContext [i1, i2]

    str @?= "<b>Hello</b>, <b>World</b>"
    cleanTestEnv
  where
    i1  = Item "item1" "Hello"
    i2  = Item "item2" "World"
    tpl = Template [Chunk "<b>", Key "body", Chunk "</b>"]
