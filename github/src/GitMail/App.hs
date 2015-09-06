{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module GitMail.App where

import qualified Data.ByteString as BS
import qualified Database.Redis as R
import           Network.Wai
import           Servant
import           Servant.HTML.Blaze
import           Text.Blaze.Html

import           GitMail.Csrf as C
import           GitMail.Handlers
import           GitMail.Html
import           GitMail.Types

type API = "github_oauth"
           :> QueryParam "state" String
           :> QueryParam "code" String
           :> Get '[HTML] Html
      :<|> "github_start"
           :> Get '[HTML] Html

api :: Proxy API
api = Proxy

server :: App (Server API)
server c s = githubOAuth c s
    :<|> githubStart c s

app :: App Application
app c s = serve api $ server c s

newAppState :: IO AppState
newAppState = do
    conn <- R.connect R.defaultConnectInfo
    return AppState { stateRedisConn = conn
                    }
