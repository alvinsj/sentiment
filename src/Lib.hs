module Lib
    (
    sentiment',
    sentiment'',
    Sentiment,
    score
    ) where

import qualified Data.Text as T
import qualified Data.Map as M
import qualified Data.Char as C

import Data.SuffixTree (STree)
import qualified Data.SuffixTree as STree

data Sentiment = Sentiment
    {
        score :: Int,
        comparative :: Float,
        tokens :: [String],
        positive :: [String],
        negative :: [String]
    } deriving Show

a111 :: IO (M.Map String Int)
a111 = do
    input <- readFile "txt/AFINN-111.txt"
    let splitted :: [[String]]
        splitted = map words (lines input)

        pairs :: [(String, Int)]
        pairs = map (\ xs -> (unwords (init xs), read (last xs))) splitted
    return $ M.fromList pairs


sentiment' :: String -> IO (Sentiment)
sentiment' str = do
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

makeTree :: String -> STree String
makeTree = STree.construct . words

searchTree :: STree String -> IO [(String, Int)]
searchTree t = do
    hmap <- a111
    let
        filtering :: (String, Int) -> Bool
        filtering (word, score) = STree.elem (words word) t

        search :: [(String, Int)]
        search = filter filtering (M.toList hmap)

        countRepeats :: String -> Int
        countRepeats w = STree.countRepeats (words w) t

    return $ map (\ (w,s) -> (w, s*(countRepeats w))) search

sentiment'' :: String -> IO (Sentiment)
sentiment'' input = do
    result <- searchTree $ makeTree input
    let
        compoundTokens :: [[String]]
        compoundTokens = map (\(w, _) -> words w) $ filter (\ (w, _) -> (length (words w)) > 1) result

        possibleDup :: [String]
        possibleDup = foldl (\s w -> s ++ w) [] compoundTokens

        removeDuplicates :: [(String, Int)] -> [(String, Int)]
        removeDuplicates = filter (\(w, s) -> not $ elem w possibleDup)

        searches :: [(String, Int)]
        searches = removeDuplicates result

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
