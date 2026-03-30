import Data.Char (toUpper)
import Data.List (elemIndex)
import Data.Maybe (fromJust)

-- Entering a rotor from the outside boudary at angle i we have (leaving angle, leaving direction) = rotorInward!!i.
-- Here direction 1 means inward, -1 means outward.
rotorInward :: [(Int, Int)]
rotorInward = [(3,1),(2,1),(6,1),(20,-1),(11,-1),(1,1),(7,1),(5,1),(9,-1),(8,-1),(10,1),(4, -1),(15,1),
               (11,1),(16,1),(17,1),(14,1),(18,1),(21,1),(22,1),(3,-1),(19,1),(25,1),(0,1),(24,1),(23,1)]

rotorOutward :: [(Int, Int)]
rotorOutward = [(23,-1),(5,-1),(1,-1),(0,-1),(9,1),(7,-1),(2,-1),(6,-1),(12,1),(4,1),(10,-1),(13,-1),(8,1),(20,1),
                (16,-1),(12,-1),(14,-1),(15,-1),(17,-1),(21,-1),(13,1),(18,-1),(19,-1),(25,-1),(24,-1),(22,-1)]

-- Encrypting a letter comes down to 'following its path through the wheel of rotors',
-- where every step corresponds to passing through a single rotor.
-- We declare some data classes to keep track of the letter at every step of this path.
data LetterPosition = LetterPosition { angle :: Int     -- its position 'on the clock', defined mod 26
                                     , dir :: Int       -- direction: inward (1) or outward (-1)
                                     , depth :: Int     -- current depth in the wheel. The boundary has depth 0
                                     } deriving (Eq)    -- for using elem on [LetterPosition]

data Letter = Letter { start :: Int                     -- initial angle when entering the wheel, i.e. original letter to be encrypted
                     , position :: LetterPosition       -- see above
                     , maxDepth :: Int                  -- maximum depth attained so far on its path
                     , prevPositions :: [LetterPosition]-- the initial wheel is periodic with period p. for each step we record the previous p positions to check if the path is infinite
                     }

-- We also keep track of the state of the wheel, which changes every time a letter is encrypted (but not during the encryption of a single letter).
data Wheel = Wheel { period :: Int          -- period of the wheel == length of keyWord
                   , rotorShifts :: [Int]   -- For each rotor the amount it has been shifted (infinite preperiodic list)
                   , periodicDepth :: Int   -- depth at which wheel becomes periodic == deepest depth reached by a letter with finite path during encryption
                   }

alphabet :: [Char]
alphabet = ['A'..'Z']

alphToIndex :: Char -> Int -- map alphabetic char to corresponding index in [0..25]
alphToIndex l = fromJust $ elemIndex (toUpper l) alphabet

exited :: Letter -> Bool -- check if letter has exited the wheel
exited l = (dir p, depth p) == (-1, 0)
           where p = position l

deep :: Wheel -> Letter -> Bool -- a letter is deep if it is at least one period into the periodic part of the wheel
deep w l = (depth $ position l) > (periodicDepth w ) + (period w)

posModPeriod :: Wheel -> LetterPosition -> LetterPosition -- return letter position with depth taken modulo the period of the wheel
posModPeriod w (LetterPosition a b c) = LetterPosition a b (c `mod` (period w))

periodic :: Wheel -> Letter -> Bool -- check if the letter is on an infinite path
periodic w l | not $ deep w l   = False
             | otherwise        = elem (posModPeriod w $ position l) (prevPositions l)

getRotorShift :: Wheel -> Letter -> Int -- get shift for the rotor l is about to enter
getRotorShift w l | dirIn > 0   = (rotorShifts w)!!d 
                  | otherwise   = (rotorShifts w)!!(d - 1)
                  where (dirIn, d) = (dir $ position l, depth $ position l)

newPosition :: Wheel -> Letter -> LetterPosition -- new position after step
newPosition w l = LetterPosition u dirOut v
                 where (n, dirIn) = (angle $ position l, dir $ position l)
                       s = getRotorShift w l
                       (m, dirOut) | dirIn > 0  = rotorInward!!((n - s) `mod` 26)
                                   | otherwise  = rotorOutward!!((n - s) `mod` 26)
                       u = (m + s) `mod` 26
                       v = (dirIn + dirOut) `div` 2 + (depth $ position $ l)

newMaxDepth :: Letter -> Int -- new depth after step
newMaxDepth l | dir p > 0  = max (depth p + 1) (maxDepth l)
              | otherwise  = maxDepth l
              where p = position l

newPrevPositions :: Wheel -> Letter -> [LetterPosition] -- new prevPositions after step
newPrevPositions w l | deep w l  = (posModPeriod w $ position l):(prevPositions l)
                     | otherwise  = prevPositions l

step :: Wheel -> Letter -> Letter -- perform a step on the path through the wheel (i.e. go through one rotor)
step w l = Letter { start = start l 
                  , position = newPosition w l 
                  , maxDepth = newMaxDepth l
                  , prevPositions = newPrevPositions w l
                  }

letterResult :: Wheel -> Letter -> (Int, Int) -- return the encryption of a letter and the maximum depth reached in the wheel during encryption. If infinite path, return (start l, 0)
letterResult w l | exited l     = (angle $ position $ l, maxDepth l)
                 | periodic w l = (start l, 0)
                 | otherwise    = letterResult w $ step w l

initWheel :: String -> Wheel -- initialize wheel with keyword
initWheel kw = Wheel per rS 0
               where per = length kw
                     rS = cycle (map alphToIndex kw)

succMod26 :: Int -> Int
succMod26 n = mod (succ n) 26

updateWheel :: Wheel -> Int -> Wheel -- shift rotors up to depth d
updateWheel w d = Wheel (period w) rS (max d (periodicDepth w))
                  where rS | d == 0     = map succMod26 (rotorShifts w)
                           | otherwise  = map succMod26 (take d (rotorShifts w)) ++ drop d (rotorShifts w)

initLetter :: Char -> Letter -- create initial letter data for alphabetic char to be encrypted
initLetter c = Letter i (LetterPosition i 1 0) 0 []
               where i = alphToIndex c

encryptChar :: (Wheel, Char) -> (Wheel, Char) -- encrypt one character and update wheel accordingly
encryptChar (w, c) | not $ elem (toUpper c) alphabet = (w, c)
                   | otherwise                       = (updateWheel w d, alphabet!!i)
                   where (i, d) = letterResult w (initLetter c)

performEncryption :: Wheel -> String -> String -> String -- Two string arguments: part of message still to be encrypted, and the part that is already encrypted
performEncryption w [] e = reverse e
performEncryption w (c:m) e = performEncryption wn m (cn:e) 
                              where (wn, cn) = encryptChar (w, c)

enigmaxi :: String -> String -> String -- the enigmaxi machine!
enigmaxi kw message = performEncryption w message []
                      where w = initWheel kw

main :: IO ()
main = do putStrLn $ enigmaxi "IETS" "XAS DIMF WR TIXK WCJA MJVIR"


