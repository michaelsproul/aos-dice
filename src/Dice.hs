module Dice (
    exactD6,
    exactD3,
    atLeastD6,
    atLeastD3,
    rollExactly,
    rollAtLeast,
    rollAtLeastWithOnes,
    rollAtLeastNoOnes,
    rollAtLeastWithExactlyOnes,
) where

import Data.Ratio

exactD6 :: Integer -> Integer -> Rational
exactD6 = rollExactly 6

exactD3 :: Integer -> Integer -> Rational
exactD3 = rollExactly 3

atLeastD6 :: Integer -> Integer -> Rational
atLeastD6 = rollAtLeast 6

atLeastD3 :: Integer -> Integer -> Rational
atLeastD3 = rollAtLeast 3

choose :: Integer -> Integer -> Integer
n `choose` k
  | k > n           = undefined
  | k == 0          = 1
  | k > (n `div` 2) = n `choose` (n-k)
  | otherwise       = n * ((n-1) `choose` (k-1)) `div` k

rollExactly :: Integer -> Integer -> Integer -> Rational
rollExactly s n 1 = if n >= 1 && n <= s then 1 % s else 0
rollExactly s n k = 1 % s * sum [rollExactly s (n - i) (k - 1) | i <- [1..s]]

rollAtLeast :: Integer -> Integer -> Integer -> Rational
rollAtLeast _ n 0 | n > 0 = 0.0
rollAtLeast _ n _ | n <= 0 = 1.0
rollAtLeast s n 1 = if n >= 1 && n <= s then (s + 1 - n) % s else 0
rollAtLeast s n k = 1 % s * sum [rollAtLeast s (n - i) (k - 1) | i <- [1..s]]

-- Probability of rolling at least n on k dice with one or more 1s
rollAtLeastWithOnes :: Integer -> Integer -> Integer -> Rational
rollAtLeastWithOnes _ 0 0 = 1.0
rollAtLeastWithOnes _ 1 1 = 1.0
rollAtLeastWithOnes _ _ 1 = 0.0
rollAtLeastWithOnes s n k =
    let
        -- Sum the probabilities for hitting the target with 1 to k ones.
        probabilities = map (rollAtLeastWithExactlyOnes s n k) [1..k]
    in
        sum probabilities

-- Probability of rolling at least n on k dice without any 1s
rollAtLeastNoOnes :: Integer -> Integer -> Integer -> Rational
rollAtLeastNoOnes s n k = rollAtLeast s n k - rollAtLeastWithOnes s n k

-- Probability of rolling at least n on k dice with exactly i 1s.
rollAtLeastWithExactlyOnes :: Integer -> Integer -> Integer -> Integer -> Rational
rollAtLeastWithExactlyOnes _ _ k i | i > k = undefined
rollAtLeastWithExactlyOnes s n k i =
    let
        -- Probability of rolling i 1s
        probOnes = (1 % s)^i
        -- Probability of making the remaining amount *without* any 1s.
        probRemainder = rollAtLeastNoOnes s (n - i) (k - i)
        -- There are k choose i ways to disperse the 1s amongst the rolls for the remainder.
        -- Choose the positions for the 1s, then assign the digits from the remainder roll left to
        -- right.
        numConfigurations = k `choose` i
    in
        (numConfigurations % 1) * probOnes * probRemainder

