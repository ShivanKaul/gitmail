module Main where

import           Control.Applicative
import           Data.Aeson
import qualified Data.ByteString.Lazy     as BS
import qualified Data.ByteString.Char8    as C8
import           Network.Wai.Handler.Warp
import           System.Exit              ( exitFailure )
import           System.IO

import           GitMail.Queue
import           GitMail.Github
import           GitMail.App              ( app, newAppState )

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

    run 8000 $ app conf state
