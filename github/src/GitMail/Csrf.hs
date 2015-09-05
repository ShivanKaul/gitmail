{-# LANGUAGE OverloadedStrings #-}

module GitMail.Csrf 
( CsrfToken()
, checkToken
, peekToken
, writeToken
, randomCsrfToken
, tokenFromByteString
, tokenToByteString
) where

import qualified Data.ByteString      as BS
import qualified Database.Redis       as R

import           System.Random

-- | A token used to prevent Cross-Site Request Forgery.
newtype CsrfToken = CsrfToken { unCsrfToken :: BS.ByteString }

tokenLength :: Integer
tokenLength = 24

tokenTimeout :: Integer
tokenTimeout = 5 * 1000 * 60

gorandom _ 0 t g = (CsrfToken (BS.pack t), g) -- TODO optimize this to use foldr
gorandom f n t g = let (x, g') = f g in gorandom f (n-1) (x:t) g'

randomCsrfToken :: RandomGen g => g -> (CsrfToken, g)
randomCsrfToken = gorandom random tokenLength []

tokenFromByteString :: BS.ByteString -> CsrfToken
tokenFromByteString = CsrfToken

tokenToByteString :: CsrfToken -> BS.ByteString
tokenToByteString = unCsrfToken

-- | A prefix used internally for storing CSRF tokens as Redis keys.
tokenKeyPrefix = "csrftoken:"

-- | Determines whether the given state token is present in the cache.
peekToken :: R.RedisCtx m f => CsrfToken -> m (f Bool)
peekToken = R.exists . (tokenKeyPrefix `BS.append`) . unCsrfToken

-- | Determines whether the given state token is present in the cache.
--
-- If it is present, then it is deleted.
checkToken :: R.RedisCtx m f => CsrfToken -> m (f Bool)
checkToken token = do
    let tokenKey = tokenKeyPrefix `BS.append` unCsrfToken token
    exists <- R.exists tokenKey
    R.del [tokenKey]
    pure exists

-- | Writes a "CsrfToken" to the cache with the default expiry timeout.
writeToken :: R.RedisCtx m f => CsrfToken -> m (f R.Status)
writeToken token = R.psetex (tokenKeyPrefix `BS.append` unCsrfToken token) 
                            tokenTimeout
                            "" 
