{-# LANGUAGE OverloadedStrings #-}

module GitMail.Email
( stripPrefixes
) where

import qualified Data.Text as T

-- | The prefix used to indicate replies.
re = "Re: "

-- | The prefix used to indicate forwards.
fwd = "Fwd: "

-- | Removes any `Re:` or `Fwd:` prefixes from a "SubjectLine"
stripPrefixes :: T.Text -> T.Text
stripPrefixes t | Just t' <- T.stripPrefix re t  = stripPrefixes t'
                | Just t' <- T.stripPrefix fwd t = stripPrefixes t'
                | otherwise                      = t
