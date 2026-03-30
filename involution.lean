import Mathlib.Data.Fin.Basic
import Mathlib.Tactic

-- The type Fin 26 is for natural numbers less than 26 with arithmetic modulo 26.
-- <a, h> defines a number of type Fin 26 if a is natural number satisfying a < 26 and h is a proof of this inequality.
-- The tactic omega can figure out for us if an integer satisfies a < 26.
-- We define the rotor as a function Fin 26 → Fin 26
def rotorVec : Fin 26 → Fin 26
  | ⟨0, _⟩  => ⟨3, by omega⟩  
  | ⟨1, _⟩  => ⟨24, by omega⟩
  | ⟨2, _⟩  => ⟨20, by omega⟩ 
  | ⟨3, _⟩  => ⟨0, by omega⟩
  | ⟨4, _⟩  => ⟨8, by omega⟩  
  | ⟨5, _⟩  => ⟨15, by omega⟩
  | ⟨6, _⟩  => ⟨18, by omega⟩ 
  | ⟨7, _⟩  => ⟨11, by omega⟩
  | ⟨8, _⟩  => ⟨4, by omega⟩  
  | ⟨9, _⟩  => ⟨19, by omega⟩
  | ⟨10, _⟩ => ⟨14, by omega⟩ 
  | ⟨11, _⟩ => ⟨7, by omega⟩
  | ⟨12, _⟩ => ⟨22, by omega⟩ 
  | ⟨13, _⟩ => ⟨17, by omega⟩
  | ⟨14, _⟩ => ⟨10, by omega⟩ 
  | ⟨15, _⟩ => ⟨5, by omega⟩
  | ⟨16, _⟩ => ⟨25, by omega⟩ 
  | ⟨17, _⟩ => ⟨13, by omega⟩
  | ⟨18, _⟩ => ⟨6, by omega⟩  
  | ⟨19, _⟩ => ⟨9, by omega⟩
  | ⟨20, _⟩ => ⟨2, by omega⟩  
  | ⟨21, _⟩ => ⟨23, by omega⟩
  | ⟨22, _⟩ => ⟨12, by omega⟩ 
  | ⟨23, _⟩ => ⟨21, by omega⟩
  | ⟨24, _⟩ => ⟨1, by omega⟩  
  | ⟨25, _⟩ => ⟨16, by omega⟩
  | ⟨n+26, h⟩ => absurd h (by omega) -- we have to prove that other cases do not exist (note that n+26 and (therefore) n must be natural, so n+26 >= 26)

  -- The letterImage definition here is easy because arithmetic in Fin 26 is automatically mod 26
def letterImage (s l : Fin 26) : Fin 26 :=
  rotorVec ((l - s)) + s

-- We can prove that (letterImage s) is an involution (i.e. it is its own inverse) without manually checking the rotor!
theorem involution (s l : Fin 26) : letterImage s (letterImage s l) = l := by
  simp [letterImage] -- simplify goal to ⊢ rotorVec (rotorVec (l - s)) + s = l
  fin_cases s <;> fin_cases l <;> simp [rotorVec] -- check all possible values of s and l separately (26*26 cases), and for each case prove the statement by unpacking rotorVec

-- This proves that our single rotor enigmaxi machine is also an involution!
-- We have not formally proved that our Haskell and Lean implementations of letterImage are equivalent,
-- but in this case that is quite easy to see.