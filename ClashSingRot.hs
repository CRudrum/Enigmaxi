module ClashSingRot where

import Clash.Prelude

-- We represent letters as unsigned 6-bit integers (::Unsigned 6) from 0 to 25
-- We use six bits to make sure that computations like (i + s) `mod` 26 (see below) behave as expected.
-- We represent the rotor as a vector, a fixed length list.
rotor :: Vec 26 (Unsigned 6)
rotor = (3 :> 24 :> 20 :> 0 :> 8 :> 15 :> 18 :> 11 :> 4 :> 19 :> 14 :> 7 :> 22 :> 17 :> 10 
        :> 5 :> 25 :> 13 :> 6 :> 9 :> 2 :> 23 :> 12 :> 21 :> 1 :> 16 :> Nil)

letterImage :: Unsigned 6 -> Unsigned 6 -> Unsigned 6 -- Compute image of letter l through rotor shifted by s
letterImage s l = (i + s) `mod` 26
                  where i = rotor!!((26 + l - s) `mod` 26)

-- We now define a 'Mealy shaped' step function.
-- It takes the rotor shift s (State) and a letter l (Input)
-- It outputs (s', l') where s' is the updated State (the new shift) and l' is the Output (the image of l after encryption).
step :: Unsigned 6 -> Unsigned 6 -> (Unsigned 6, Unsigned 6)
step s l = ((s+1) `mod` 26, letterImage s l)

topEntity
    :: Unsigned 6 -- the key specifying the initial rotor shift
    -> Clock System -> Reset System -> Enable System
    -> Signal System (Unsigned 6)   -- input letter from 0 to 25
    -> Signal System (Unsigned 6)   -- output letter from 0 to 25
topEntity key = exposeClockResetEnable $ mealy step key