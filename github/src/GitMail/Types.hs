{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module GitMail.Types where

import           Data.Aeson
import           Data.ByteString ( ByteString )
import qualified Data.Text            as T
import qualified Database.Redis       as R
import           GHC.Generics
import           Github.Auth

import qualified GitMail.Time         as GT

-- | A subject of an email.
type SubjectLine = T.Text

-- | An email address.
type EmailAddress = T.Text

-- | A name of a human.
type HumanName = T.Text

-- | A unique identifier for this Github app.
type ClientId = T.Text

-- | A unique secret associated with this Github app.
type ClientSecret = T.Text

-- | A representation of an email received in GMail.
--
-- Values of this type are written into the Redis-backed message queue by the
-- GMail service.
data IncomingEmail = IncomingEmail { senderName :: HumanName
                                   , senderEmail :: EmailAddress
                                   , sendDate :: GT.Time
                                   , messageContents :: T.Text
                                   , messageSubject :: SubjectLine
                                   }
                                   deriving (Show, Eq, Ord, Generic)

instance FromJSON IncomingEmail
instance ToJSON IncomingEmail

data OAuthConf = OAuthConf { oauthKeyPrefix :: ByteString
                           }
                           deriving (Show, Eq, Ord, Generic)

data QueueConf = QueueConf { incomingEmailQueueName :: ByteString 
                           , processedEmailQueueName :: ByteString
                           , outgoingEmailQueueName :: ByteString
                           }
                           deriving (Show, Eq, Ord, Generic)

data GithubConf = GithubConf { githubUser :: String
                             , githubRepo :: String
                             , githubAuth :: GithubAuth
                             }

data UniquenessError = NoResults | TooManyResults

data OAuthStep3Request = OAuthStep3Request { oauthCode :: T.Text
                                           , oauthCsrfToken :: T.Text
                                           , oauthClientId :: T.Text
                                           , oauthClientSecret :: T.Text
                                           }
                                           deriving (Show, Eq, Ord, Generic)

data OAuthStep3Response = OAuthStep3Response { access_token :: T.Text
                                             , token_type :: T.Text
                                             , scope :: T.Text
                                             }
                                             deriving (Show, Eq, Ord, Generic)

instance ToJSON OAuthStep3Request
instance FromJSON OAuthStep3Response

data AppConf = AppConf { confClientId :: ClientId 
                       , confClientSecret :: ClientSecret
                       }
                       deriving (Show, Eq, Ord, Generic)

instance FromJSON AppConf

data AppState = AppState { stateRedisConn :: R.Connection 
                         }
