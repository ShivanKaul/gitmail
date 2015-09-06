{-# LANGUAGE OverloadedStrings #-}

module GitMail.Handlers where

import           Control.Monad.Trans.Either
import           Control.Monad.Trans
import           Data.Aeson
import qualified Data.ByteString.Base64     as B64
import qualified Data.ByteString.Lazy       as BS
import qualified Data.ByteString.Char8      as C8
import           Data.String
import qualified Data.Text                  as T
import qualified Data.Text.Encoding         as E
import qualified Database.Redis             as R
import qualified Github.Auth                as GA
import qualified Github.Users               as GU
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
                Just step3Response -> do
                    let auth = GA.GithubOAuth (T.unpack $ access_token step3Response)
                    e <- liftIO $ GU.userInfoCurrent' (Just auth)
                    case e of
                        Left x -> liftIO $ do
                            putStr "failed to get user info: "
                            print x
                        Right user -> do
                            let username = GU.detailedOwnerLogin user
                            let githubConf = GithubConf { githubUser = username
                                                        , githubRepo = "gitmail"
                                                        , githubAuth = auth
                                                        }
                            liftIO $ R.runRedis (stateRedisConn s) $ do
                                R.set "access_token"
                                      (BS.toStrict $ encode githubConf)
                            return ()
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
