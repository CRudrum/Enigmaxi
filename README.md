# Enigmaxi
The Enigmaxi machine is an Enigma-inspired encryption machine appearing in problem 12 of the [AIVD kerstpuzzel 2025](https://www.aivd.nl/onderwerpen/aivd-events/aivd-kerstpuzzel), the annual Christmas puzzle of the Dutch General Intelligence and Security Service. See below for an explanation of how it works. The puzzle (in Dutch) can be found on the AIVD website and is intended for a general audience. Except for an implementation of the Enigmaxi in Haskell, this repository does not contain any information regarding the solution of the puzzle. One thing we do note is that **the enigmaxi machine is flawed by design and should not be used for encryption in practice**. The puzzle is to find and exploit these flaws.

I made this implementation to try out Haskell and functional programming. The Enigmaxi seemed a fun choice for such a project because of its recursive structure with an infinite set of rotors. I also tried out a bit of Clash by describing a circuit that functions as a single-rotor version of the Enigmaxi. For this single-rotor version I included a simple proof in Lean of the fact that the encryption algorithm is its own inverse.

## The Enigmaxi machine

