{-# LANGUAGE OverloadedStrings #-}

module GitMail.Html where

import Data.Monoid                 ( (<>) )
import Prelude                     hiding ( head )
import Text.Blaze.Html5
import Text.Blaze.Html5.Attributes

oauthRedirect clientId csrfToken =
    docTypeHtml $ do
        head $ do
            meta ! httpEquiv "refresh"
                 ! content (mconcat [ "3;"
                                   , "URL=https://github.com/login/oauth/authorize"
                                   , "?scope=repo"
                                   , "&client_id=" <> clientId
                                   , "&state=" <> csrfToken
                                   ])
        body $ do
            p $ mconcat [ "You will be redirected to Github to authorize "
                        , "GitMail to access your repositories."
                        ]

htmlMessage message =
    docTypeHtml $ do
        body $ do
            p message
