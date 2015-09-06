{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}

module GitMail.Types where

import           Data.Aeson
import           Data.ByteString ( ByteString )
import qualified Data.Text            as T
import qualified Data.Text.Encoding   as E
import qualified Database.Redis       as R
import           GHC.Generics
import           Github.Auth

import qualified GitMail.Time         as GT

-- | Orphan instance for serializing GithubAuth to JSON
instance ToJSON GithubAuth
instance FromJSON GithubAuth

instance ToJSON ByteString where
    toJSON = toJSON . E.decodeUtf8

instance FromJSON ByteString where
    parseJSON = fmap E.encodeUtf8 . parseJSON

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
data EmailMessage = EmailMessage { senderName :: HumanName
                                 , senderEmail :: EmailAddress
                                 , sendDate :: GT.Time
                                 , messageContents :: T.Text
                                 , messageSubject :: SubjectLine
                                 }
                                 deriving (Show, Eq, Ord, Generic)

instance FromJSON EmailMessage
instance ToJSON EmailMessage

data OAuthConf = OAuthConf { oauthKeyPrefix :: ByteString
                           }
                           deriving (Show, Eq, Ord, Generic)

-- | The configuration for the Redis queues used for communication between
-- the microservices.
data QueueConf = QueueConf { incomingEmailQueueName :: (ByteString, ByteString)
                           , outgoingEmailQueueName :: (ByteString, ByteString)
                           }
                           deriving (Show, Eq, Ord, Generic)

type OnQueue a = QueueConf -> R.Connection -> a

data GithubConf = GithubConf { githubUser :: String
                             , githubRepo :: String
                             , githubAuth :: GithubAuth
                             }
                             deriving (Show, Eq, Ord, Generic)

instance FromJSON GithubConf
instance ToJSON GithubConf

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
