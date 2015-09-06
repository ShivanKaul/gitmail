{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Applicative
import           Control.Concurrent       ( forkIO )
import           Control.Monad            ( forever )
import           Data.Aeson
import qualified Data.ByteString.Lazy     as BS
import qualified Data.ByteString.Char8    as C8
import qualified Data.Text                as T
import qualified Database.Redis           as R
import qualified Github.Auth              as GA
import qualified Github.Issues            as GI
import           Network.Wai.Handler.Warp
import           System.Exit              ( exitFailure )
import           System.IO

import           GitMail.Queue
import           GitMail.Github
import           GitMail.App              ( app, newAppState )
import           GitMail.Types

secrets = "secrets.json"

main = do
    mconf <- withFile secrets ReadMode $ \h ->
        decode . BS.fromStrict <$> C8.hGetContents h

    conf <- case mconf of
        Nothing -> do
            putStrLn $ "Failed to parse " ++ secrets
            exitFailure >> undefined -- for typechecking purposes
        Just x -> return x

    state <- newAppState

    forkIO $ forever $
             onIncomingEmail defaultQueueConf (stateRedisConn state)
             $ \mail -> do
                 e <- R.runRedis (stateRedisConn state)
                                 ((fmap . fmap . fmap) (decode . BS.fromStrict)
                                                       (R.get "access_token"))
                 case e of
                     Left x -> putStr "Failed to get github conf: " >> print x
                     Right Nothing -> putStrLn "No github conf."
                     Right (Just Nothing) -> putStrLn "Failed to parse github conf."
                     Right (Just (Just githubConf)) -> do
                         let subject = messageSubject mail
                             body = messageContents mail
                         e' <- findIssue githubConf subject
                         case e' of
                             Right (Left NoResults) -> do
                                 e'' <- createIssue githubConf
                                                    GI.NewIssue
                                                        { GI.newIssueTitle =
                                                              T.unpack $ subject
                                                        , GI.newIssueBody =
                                                              Just $ T.unpack $ body
                                                        , GI.newIssueAssignee =
                                                              Nothing
                                                        , GI.newIssueMilestone =
                                                              Nothing
                                                        , GI.newIssueLabels =
                                                              Nothing
                                                        }
                                 case e'' of
                                     Left x -> do
                                         putStr "Can't create issue: "
                                         print x
                                     Right i -> do
                                         putStr "Create issue: "
                                         print (GI.issueNumber i)

                             Right (Right issue) -> do
                                 e'' <- createComment githubConf
                                                      (GI.issueNumber issue)
                                                      (T.unpack $ body)
                                 case e'' of
                                     Left x -> do
                                         putStr "Can't create comment: "
                                         print x
                                     Right c -> do
                                         putStr "Created comment: "
                                         putStrLn (GI.commentUrl c)

                             Left x -> putStr "github error: " >> print x

    run 8000 $ app conf state
