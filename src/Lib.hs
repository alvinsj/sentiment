module Lib
    (
    sentiment
    ) where

import qualified Data.Text as T
import qualified Data.Map as M

import qualified Data.Char as C

data Sentiment = Sentiment
    {
        score :: Int,
        comparative :: Float,
        tokens :: [String],
        positive :: [String],
        negative :: [String]
    } deriving Show

splitWords :: String -> [[String]]
splitWords input = map (splitting) (lines input)
    where
        splitting :: String -> [String]
        splitting line =
            let xs = words line
            in [(unwords . init ) xs, (last xs)]

a111 :: IO (M.Map String Int)
a111 = do
    input <- readFile "txt/AFINN-111.txt"
    let mapping :: [[String]]
        mapping = (splitWords input)

        pairs :: [(String, Int)]
        pairs = map (\ xs -> (unwords (init xs), read (last xs))) mapping
    return $ M.fromList pairs



sentiment :: String -> IO (Sentiment)
sentiment str = do
    h <- a111
    let search :: String -> Maybe Int
        search w = M.lookup w h
        fromMaybe x = case x of
            Nothing -> 0
            Just t -> t

        parse :: String -> String
        parse = (T.unpack . ops . T.pack)
            where
                ops = ((T.dropAround C.isPunctuation) . T.toLower)

        searches :: [(String, Int)]
        searches = foldl reduce [] (words $ parse str)
            where
                reduce :: [(String, Int)] -> String -> [(String, Int)]
                reduce s w = s ++ [(w, (fromMaybe $ search w))]

        score :: Int
        score = foldl (\r (_, score) -> r+score) 0 searches

        tokens :: [(String, Int)] -> [String]
        tokens = map (\(w, _) -> w)

        positive :: [String]
        positive = tokens $ filter (\(w, score) -> score > 0) searches

        negative :: [String]
        negative = tokens $ filter (\(w, score) -> score < 0) searches

        comparative :: Float
        comparative = (fromIntegral score) / (fromIntegral (length (tokens searches)))

    return $ Sentiment {
            score = score
            , comparative = comparative
            , tokens = tokens searches
            , positive = positive
            , negative = negative }
