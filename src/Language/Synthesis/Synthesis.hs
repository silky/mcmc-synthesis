module Language.Synthesis.Synthesis (
    Mutation, synthesizeMhList, runningBest
) where

import           Control.Monad
import           Control.Monad.Random
import           Control.Monad.Random.Class

import           Language.Synthesis.Distribution (Distr (Distr))
import qualified Language.Synthesis.Distribution as Distr
import           Language.Synthesis.MCMC


-- |A mutation for the program type, a.
type Mutation a = a -> Distr a

-- |Given a prior distribution, score function, mutation distribution, generate
-- a list of (program, score) values through MH sampling.
synthesizeMhList :: RandomGen g => Distr a -> (a -> Double) -> Mutation a -> 
                    Rand g [(a, Double)]
synthesizeMhList prior score jump = do
    first <- Distr.sample prior
    let density prog = (sc, sc + Distr.logProbability prior prog)
            where sc = score prog
    list <- mhList first density jump
    return [(prog, sc) | (prog, sc, _) <- list]

-- |Given (value, score) pairs, return a running list of the best pair so far.
runningBest :: [(a, Double)] -> [(a, Double)]
runningBest (first:rest) = scanl maxScore first rest
    where maxScore (p, ps) (q, qs) | qs >= ps = (q, qs)
                                   | otherwise = (p, ps)


