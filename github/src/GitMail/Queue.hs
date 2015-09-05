module GitMail.Queue where

import           Data.Aeson
import           Data.ByteString.Lazy ( fromStrict )
import qualified Database.Redis       as R

import           GitMail.Types

type OnQueue a = QueueConf -> R.Connection -> a

-- | Blocks on the Redis message queue until a new email arrives, whereupon
-- the provided function is called.
--
-- A thread can be made to keep listening for messages with the "forever"
-- combinator.
onIncomingEmail :: OnQueue ( (IncomingEmail -> IO ()) -> IO ())
onIncomingEmail q c f = do
    e <- R.runRedis c $ 
         R.brpoplpush (incomingEmailQueueName q) 
                      (processedEmailQueueName q)
                      0
    case e of
        Right (Just v) -> do
            case decode $ fromStrict v of
                Just v -> f v
                Nothing -> error "failed !!!"
        Right Nothing -> error "failed !!"
        Left _ -> error "failed !"
