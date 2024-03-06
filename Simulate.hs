module Simulate (runSimulations, runSimulation) where

import System.Random

data Outcome = CastLived | CastDied | Failed | MiscastDied | MiscastLived deriving Eq

d6 :: IO Int
d6 = randomRIO (1, 6)

d3 :: IO Int
d3 = randomRIO (1, 3)

runSimulations :: Int -> Int -> Int -> Int -> IO ()
runSimulations numTrials castingValue numDice wounds = do
    outcomes <- mapM (\_ -> runSimulation castingValue numDice wounds) [0..numTrials]
    let castLived = length (filter (==CastLived) outcomes)
    let castDied = length (filter (==CastDied) outcomes)
    let failed = length (filter (==Failed) outcomes)
    let miscastDied = length (filter (==MiscastDied) outcomes)
    let miscastLived = length (filter (==MiscastLived) outcomes)
    let cast = castLived + castDied
    let miscast = miscastLived + miscastDied
    putStrLn $ "cast " ++ show cast ++ "/" ++ show numTrials
    putStrLn $ "failed " ++ show failed ++ "/" ++ show numTrials
    putStrLn $ "miscast " ++ show miscast ++ "/" ++ show numTrials

runSimulation :: Int -> Int -> Int -> IO Outcome
runSimulation castingValue numDice wounds = do
    rolls <- mapM (\_ -> d6) [1..numDice]
    let ones = length (filter (==1) rolls)
    if ones >= 2 then do
        -- Miscast
        d3wounds <- d3
        let woundsSuffered = d3wounds + 3
        if woundsSuffered >= wounds then
            return MiscastDied
        else
            return MiscastLived
    else if sum rolls >= castingValue then do
        -- Cast
        damageRolls <- mapM (\_ -> d6) [1..4 :: Int]
        let damageOnes = length (filter (==1) damageRolls)
        selfDamage <- mapM (\_ -> d3) [0..damageOnes]
        if sum selfDamage >= wounds then
            return CastDied
        else
            return CastLived
    else
        -- Fail
        return Failed
