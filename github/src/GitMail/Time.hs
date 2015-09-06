{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module GitMail.Time
( Time(..)
, unsafeFromLocalTime
) where

import           Control.Applicative
import           Data.Aeson
import           Data.Aeson.Parser
import           Data.Maybe          ( fromMaybe )
import           Data.String
import qualified Data.Time           as T
import           Data.Text           ( pack, unpack )

-- | A wrapper around a "T.UTCTime" with instances for "ToJSON", "FromJSON",
-- and "IsString".
newtype Time = Time { unTime :: T.UTCTime
                    }
                    deriving (Show, Ord, Eq)

instance ToJSON Time where
    toJSON (Time { unTime = t }) = String $ formatTime t

instance FromJSON Time where
    parseJSON (String t) = Time <$> parseTime (unpack t)
    parseJSON _ = fail "failed to parse time (not a string)"

instance IsString Time where
    fromString = Time . fromMaybe (error "invalid time string literal") . parseTime

-- | Convert a "LocalTime" into a HackSignal "Time", ignoring timezones.
unsafeFromLocalTime :: T.LocalTime -> Time
unsafeFromLocalTime = Time . T.localTimeToUTC T.utc

iso8601 = T.iso8601DateFormat (Just "%H:%M:%S%Q%Z")
formatTime = pack . T.formatTime T.defaultTimeLocale iso8601

parseTime :: (Monad m, T.ParseTime s) => String -> m s
parseTime = T.parseTimeM False T.defaultTimeLocale iso8601
