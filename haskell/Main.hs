{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Network.Wai
import Network.Wai.Handler.Warp
import Network.HTTP.Types
import Network.HTTP.Simple
import Network.URI
import Data.ByteString.Lazy.Char8 as L8
import Data.ByteString.Char8 as S8
import Prelude hiding (putStrLn)
import qualified Prelude
import Data.Text as T
import Data.Text.Encoding
import Data.Maybe
import Control.Exception

app :: Application
app req respond = do
  let query = queryString req
      keyword = lookup "keyword" query >>= id
      target = lookup "target" query >>= id
  
  found <- case (keyword, target) of
    (Just k, Just t) -> checkKeyword (decodeUtf8 k) (decodeUtf8 t)
    _ -> return "false"
  
  respond $ responseLBS status200 [("Content-Type", "text/plain")] (L8.pack found)

checkKeyword :: Text -> Text -> IO String
checkKeyword keyword target = do
  result <- try $ do
    response <- httpLBS =<< parseRequest (T.unpack target)
    let body = getResponseBody response
    return $ T.isInfixOf keyword (decodeUtf8 $ L8.toStrict body)
  case result of
    Right found -> do
      let foundStr = if found then "true" else "false"
      Prelude.putStrLn $ "found=" ++ foundStr ++ ", keyword=" ++ T.unpack keyword ++ ", uri=" ++ T.unpack target
      return foundStr
    Left (_ :: SomeException) -> do
      Prelude.putStrLn $ "Error fetching " ++ T.unpack target
      return "false"

main :: IO ()
main = do
  Prelude.putStrLn "listening on 0.0.0.0:31337"
  run 31337 app