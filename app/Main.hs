module Main where

import Lib
import Data.Map

main :: IO ()
main = do
    s <- sentiment "abuse"
    putStrLn $ show s
