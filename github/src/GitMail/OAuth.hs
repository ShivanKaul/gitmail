{-# LANGUAGE OverloadedStrings #-}

module GitMail.OAuth where

import           Control.Monad.Trans
import           Control.Monad.Trans.Resource ( runResourceT )
import           Data.Aeson
import qualified Data.ByteString              as BS
import           Data.ByteString.Lazy         ( toStrict )
import qualified Data.ByteString.Char8        as C8
import qualified Data.Conduit                 as C
import qualified Data.Text.Encoding           as E
import           Network.HTTP.Conduit
import           Network.HTTP.Types.Header

import           GitMail.Types

accessTokenUrl = "https://github.com/login/oauth/access_token"

tradeCodeForAccessToken :: OAuthStep3Request -> IO (Maybe OAuthStep3Response)
tradeCodeForAccessToken oa = do
    let e f = E.encodeUtf8 . f
    req <- parseUrl accessTokenUrl
    let req' = req { method = "POST"
                   , requestHeaders = [ ( hAccept, "application/json" ) ]
                   , requestBody = RequestBodyBS $ 
                                   mconcat [ "client_secret=", e oauthClientSecret oa
                                           , "&client_id=", e oauthClientId oa
                                           , "&state=", e oauthCsrfToken oa
                                           , "&code=", e oauthCode oa
                                           ]
                   }
    manager <- newManager tlsManagerSettings
    runResourceT $ do
        response <- httpLbs req' manager
        let body = responseBody response
        pure (decode body)
