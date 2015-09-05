{-# LANGUAGE OverloadedStrings #-}

module GitMail.Handlers where

import           Control.Monad.Trans.Either
import           Control.Monad.Trans
import qualified Data.ByteString.Base64     as B64
import qualified Data.ByteString.Char8      as C8
import           Data.String
import qualified Data.Text                  as T
import qualified Data.Text.Encoding         as E
import qualified Database.Redis             as R
import           Servant
import           System.Random
import           Text.Blaze.Html

import           GitMail.Csrf
import           GitMail.OAuth
import           GitMail.Html
import           GitMail.Types

type App a = AppConf -> AppState -> a

githubOAuth :: App (Maybe String -> Maybe String -> EitherT ServantErr IO Html)
githubOAuth c s mcsrf mcode = do
    case (mcsrf, mcode) of
        (Just csrf, Just code) -> do
            m <- liftIO $ tradeCodeForAccessToken
                          OAuthStep3Request 
                              { oauthCode = T.pack code
                              , oauthCsrfToken = T.pack csrf
                              , oauthClientId = confClientId c
                              , oauthClientSecret = confClientSecret c
                              }
            case m of
                Just step3Response -> liftIO $ R.runRedis (stateRedisConn s) $ do
                    R.set "access_token" 
                          (E.encodeUtf8 $ access_token step3Response)
                -- TODO this error code isn't really appropriate
                Nothing -> do
                    liftIO $ putStrLn "can't parse step 3 response"
                    left err400 
        _ -> left err400
    pure $ htmlMessage "Success"

githubStart :: App (EitherT ServantErr IO Html)
githubStart c s = do
    g <- liftIO getStdGen 
    let (csrf, g') = randomCsrfToken g
    liftIO $ do
        setStdGen g'
        R.runRedis (stateRedisConn s) $ writeToken csrf
    pure $ oauthRedirect ( fromString 
                         $ T.unpack 
                         $ confClientId c
                         )
                         ( fromString 
                         $ C8.unpack 
                         $ B64.encode 
                         $ tokenToByteString csrf
                         )

githubFinished :: App (EitherT ServantErr IO Html)
githubFinished = undefined
