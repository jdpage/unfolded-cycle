-------------------------------------------------------------------------------
-- |
-- Module: Data.Unfolded.Cycle
-- Copyright: (c) Jonathan David Page 2015
-- License: LGPL version 3 or later (see LICENSE)
-- Maintainer: jonathan@sleepingcyb.org
--
-- Cycles generated from an unfold function.
--
-- The functions in this module are intended to be imported qualified, e.g.
--
--     import Data.Unfolded.Cycle (Cycle)
--     import qualified Data.Unfolded.Cycle as Cycle
--
-------------------------------------------------------------------------------

module Data.Unfolded.Cycle
    ( Cycle()
    , unfold
    , find
    , prefix
    , length
    , toList, toList1
    ) where

import Prelude hiding (length, head, tail)
import qualified Data.List as List (length, head, tail)

-- | The Cycle type
--
-- Represents a sequence of elements where each element is derived from the
-- previous, and eventually loops back on itself.
data Cycle a = Cycle [a] deriving (Show)

-- | Unfolds a sequence from a seed value z, and a function f
--
-- This generates the list @z:(f z):(f (f z)):(f (f (f z))):...@
--
-- Not a cycle function proper, but used internally and potentially useful
-- externally.
unfold :: (a -> a) -> a -> [a]
unfold f z = z:(unfold f $ f z)

-- | Finds a cycle in a sequence as generated by @unfold@
--
-- Note that if the sequence does not have a cycle in it, this function will go
-- into an infinite loop.
find :: (Eq a) => (a -> a) -> a -> Cycle a
find f z = Cycle (find' (unfold f z) [] []) where
    find' (z:zs) ms1 ms2
        | z `elem` ms2   = []
        | z `elem` ms1   = z : (find' zs ms1 (z:ms2))
        | otherwise      = find' zs (z:ms1) ms2

-- | Gets the longest non-cycle prefix in the sequence as generated by @unfold@
--
-- The sets of elements produced by this function and the @find@ function are
-- disjoint. Together they contain all elements found in the sequence generated
-- by @unfold@.
--
-- Note that if the sequence does not have a cycle in it, this function will go
-- into an infinite loop.
prefix :: (Eq a) => (a -> a) -> a -> [a]
prefix f z =
    let c = toList1 $ find f z in
    takeWhile (\x -> not $ x `elem` c) $ unfold f z

-- | Gets the number of elements in the cycle before it repeats.
length :: Cycle a -> Int
length (Cycle zs) = List.length zs

instance (Eq a) => Eq (Cycle a) where
    (Cycle zs) == (Cycle ws)   = cycleEq zs ws where
        cycleEq zs ws =
            let zl = List.length zs in (zl == List.length ws) && (cycleEq' zl zs ws)
            where
                cycleEq' 0 _ _ = False
                cycleEq' n zs (w:ws) = (zs == (w:ws)) || (cycleEq' (n - 1) zs (ws ++ [w]))

-- | Gets a circular list of the cycle, starting from an arbitrary element.
toList :: Cycle a -> [a]
toList (Cycle zs) = cycle zs

-- | Gets a non-circular list of the cycle, starting from an arbitrary element.
toList1 :: Cycle a -> [a]
toList1 (Cycle zs) = zs

