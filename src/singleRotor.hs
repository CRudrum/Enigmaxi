-- We greatly simplify the enigmaxi machine to a version with only one rotor (for practice with Clash)
-- The advantage is no infinite lists or unbounded recursion.

import Data.Char (toUpper)
import Data.List (elemIndex)
import Data.Maybe (fromJust)

-- The rotor is now simply a reflector that spins.
-- So it is a permutation of [0..25] consisting of 13 independent transpositions. We choose this one:
-- (see the involution.lean file for a proof that this rotor indeed defines a permutation of order 2)
rotor:: [Int]
rotor = [3, 24, 20, 0, 8, 15, 18, 11, 4, 19, 14, 7, 22, 17, 10, 5, 25, 13, 6, 9, 2, 23, 12, 21, 1, 16]

alphabet :: [Char]
alphabet = ['A'..'Z']

alphToIndex :: Char -> Int -- map alphabetic char to corresponding index in [0..25]
alphToIndex l = fromJust $ elemIndex (toUpper l) alphabet

succMod26 :: Int -> Int
succMod26 n = mod (succ n) 26

letterImage :: Int -> Char -> Char -- the Int is the amount we shifted the rotor
letterImage s c = alphabet!!i 
                  where i = (j + s) `mod` 26
                        j = rotor!!((k - s) `mod` 26)
                        k = alphToIndex c

performEncryption :: Int -> String -> String -> String -- The Int is the rotor shift. Two string arguments: part of message still to be encrypted, and the part that is already encrypted
performEncryption s [] e = reverse e
performEncryption s (c:m) e | not $ elem (toUpper c) alphabet = performEncryption s m (c:e)
                            | otherwise                       = performEncryption (succMod26 s) m (l:e)
                            where l = letterImage s c

singRot :: Char -> String -> String -- a single rotor encryption machine! The key k must be an alphabetic character
singRot k message = performEncryption s message []
                    where s = alphToIndex k

main :: IO ()
main = do putStrLn $ singRot 'X' "PSB ASWR KV KSC RLUX RRFO DRAKQ"
