-- {-# OPTIONS_GHC -fforce-recomp -fplugin=LambdaCCC.Plugin -dcore-lint
--       -O -fobject-code -fno-omit-interface-pragmas -fexpose-all-unfoldings #-}

{-# LANGUAGE CPP, TupleSections, GADTs, TypeOperators, Rank2Types #-}
{-# OPTIONS_GHC -Wall #-}

{-# OPTIONS_GHC -fno-warn-unused-imports #-} -- TEMP
{-# OPTIONS_GHC -fno-warn-unused-binds   #-} -- TEMP
{-# OPTIONS_GHC -fno-warn-missing-signatures #-}

----------------------------------------------------------------------
-- |
-- Module      :  Examples
-- Copyright   :  (c) 2016 Conal Elliott
-- License     :  BSD3
--
-- Maintainer  :  conal@conal.net
-- Stability   :  experimental
-- 
-- Examples / tinkering.
----------------------------------------------------------------------

-- module Examples where

-- import Prelude

-- -- Oddly, this import breaks unfolding needed by monomorphize in ghci.
-- import LambdaCCC.Lambda (EP,reifyEP)

import Data.Monoid (Sum(..))
import Control.Applicative (liftA2)

import TypeUnary.TyNat
import TypeUnary.Nat (IsNat,natToZ)
import TypeUnary.Vec hiding (transpose,iota)
import qualified TypeUnary.Vec as V
import Control.Compose ((:.)(..),unO)

-- import LambdaCCC.Lambda (reifyEP)
import LambdaCCC.Misc
  (xor,boolToInt,dup,Unop,Binop,Ternop,transpose,(:*),loop,delay,Reversible(..))
import LambdaCCC.Adder
import LambdaCCC.CRC -- hiding (crcS,sizeA)
import LambdaCCC.Bitonic
import LambdaCCC.Counters
import qualified LambdaCCC.RadixSort as RS

-- import Circat.Misc (Reversible(..))
import Circat.Rep (bottom)
import Circat.Pair (Pair(..),sortP)
import qualified Circat.Pair as P
import qualified Circat.RTree as RT
import qualified Circat.LTree as LT
import qualified Circat.RaggedTree as Ra
import Circat.RaggedTree (TU(..), R1, R2, R3, R4, R5, R8, R11, R13)
import Circat.Shift
import Circat.Scan
import Circat.FFT
-- import Circat.Mealy hiding (ArrowCircuit(..))
-- import qualified Circat.Mealy as Mealy
-- import Circat.Circuit (GenBuses(..), GS, Attr, systemSuccess)
import Circat.Complex

import LambdaCCC.Lambda (reifyEP)
import LambdaCCC.Run


type RTree = RT.Tree
type LTree = LT.Tree
type Ragged = Ra.Tree

-- foo = reifyEP (sqr :: Int -> Int)

-- ghc: panic! (the 'impossible' happened)
--   (GHC version 7.10.3 for x86_64-apple-darwin):
-- 	getIdFromTrivialExpr evalEP @ Int (varP# @ Int "x"#)

main = -- do
#if 0
  print (reifyEP (id 3 :: Int))
  print (reifyEP (negate :: Int -> Int))
  print (reifyEP (\ x -> negate (negate x) :: Int))
  print (reifyEP (id :: Int -> Int))
  print (reifyEP ((1 +) :: Int -> Int))
  print (reifyEP (negate . (1 +) :: Int -> Int))
  print (reifyEP (let f :: Num a => a -> a
                      f = negate
                  in
                    (f :: Int -> Int)))
#endif

--   print (reifyEP (fromInteger :: Integer -> Int))

--   print (reifyEP (let x :: Num a => a
--                       x = 1
--                   in
--                     (x :: Int)))

--   print (reifyEP (let f :: Num a => a -> a
--                       f = negate . (1 +)
--                   in
--                     (f :: Int -> Int)))

--   print (reifyEP (let f :: Num a => a -> a
--                       f = negate . (1 +)
--                   in
--                     (f :: Int -> Int)))

--   print (reifyEP (negIncr :: Int -> Int))

  -- Monomorphization works:
  -- go "foo" (\ x -> x :: Int)

--   go "three" (1 + 2 :: Int)

  -- go "nine" (sqr (1 + 2 :: Int))

--   go "negateI" (negate :: Int -> Int)

--   go "negIncr" (negIncr :: Int -> Int)

--   go "foo" (3 :: Int)  -- I#

--   go "sqrI" (sqr :: Int -> Int)

--   go "sqr" (sqr :: Int -> Int)

--      print (reifyEP (fmap :: Unop Int -> Unop (Pair Int)))

--   print (reifyEP (sum :: Pair Int -> Int))

--   print (reifyEP (sumTI :: RTree N1 Int -> Int))

--      go "leftmost-r1" (leftMost :: RTree N1 Int -> Int)

--      print (reifyEP (leftMost :: RTree N1 Int -> Int))

--   print (reifyEP (sum :: RTree N2 Int -> Int))

--   goSep "and-rt8" 1.5 (and :: RTree N8 Bool -> Bool)

--   print (reifyEP not)

--   print (reifyEP ((,) :: Bool -> Bool -> (Bool,Bool)))

--   print (reifyEP (False,True))

--   print (reifyEP (fmap not :: Unop (Pair Bool)))

--   go "map-not-rt6" (fmap not :: Unop (RTree N6 Bool))

--   goSep "sumrt2" 1 (sum :: RTree N2 Int -> Int)

  -- goSep "maprt8" 4 (fmap sqr :: Unop (RTree N8 Int))

--   goSep "dotrt4" 1 (dotG :: Pair (RTree N4 Int) -> Int)

--   go "foo" ((:#) :: Bool -> Bool -> Pair Bool)

--   print (reifyEP ((\ (a :# b) -> a :# b) :: Unop (Pair w)))

--   go "foo" ((\ (a :# b) -> a :# b) :: Unop (Pair Bool))

  goSep "transpose-pp" 1 (transpose :: Unop (Pair (Pair Bool)))

--   goSep "transpose-rt2p" 1 (transpose :: RTree N2 (Pair Bool) -> Pair (RTree N2 Bool))

  -- go "applyLin-rt23" (($@) :: MatrixT N2 N3 Int -> RTree N2 Int -> RTree N3 Int)
  -- go "composeLin-rt232" ((.@) :: MatrixT N3 N2 Int -> MatrixT N2 N3 Int -> MatrixT N2 N2 Int)
  -- go "lsums-p" (lsums :: Pair Int -> (Pair Int, Int))
  -- goSep "lsums-rt9" 15 (lsums :: RTree N9 Int -> (RTree N9 Int, Int))
  -- go "lsums-rt0" (lsums :: RTree N0 Int -> (RTree N0 Int, Int))
  -- go "lsums-lt0" (lsums :: LTree N0 Int -> (LTree N0 Int, Int))

{--------------------------------------------------------------------
    Misc definitions
--------------------------------------------------------------------}

negIncr :: Num a => a -> a
negIncr = negate . (1 +)

sqr :: Num a => a -> a
sqr x = x * x

sumTI :: RTree n Int -> Int
sumTI (RT.L a) = a
sumTI (RT.B (u :# v)) = sumTI u + sumTI v

leftMost :: RTree n a -> a
leftMost (RT.L a) = a
leftMost (RT.B (u :# _)) = leftMost u

#if 1

dotG :: (Traversable g, Foldable g, Applicative f, Foldable f, Num a) => g (f a) -> a
dotG = sum . fmap product . transpose

-- Infix binary dot product
infixl 7 <.>
(<.>) :: (Foldable f, Applicative f, Num a) => f a -> f a -> a
u <.> v = dotG (u :# v)

-- Generalized matrices

type Matrix  m n a = Vec    n (Vec    m a)
type MatrixT m n a = RTree  n (RTree  m a)
type MatrixG p q a = Ragged q (Ragged p a)

infixr 1 $@
-- infixl 9 .@

-- | Apply a linear transformation represented as a matrix
-- ($@) :: (IsNat m, Num a) => Matrix m n a -> Vec m a -> Vec n a
($@) :: (Foldable m, Applicative m, Functor n, Num a) =>
        n (m a) -> m a -> n a
mat $@ vec = (<.> vec) <$> mat

-- -- | Compose linear transformations represented as matrices
-- (.@) :: (IsNat m, IsNat n, IsNat o, Num a) =>
--         Matrix n o a -> Matrix m n a -> Matrix m o a
(.@) :: ( Applicative o, Traversable n, Applicative n
        , Traversable m, Applicative m, Num a ) =>
        o (n a) -> n (m a) -> o (m a)
-- no .@ mn = (\ n -> (n <.>) <$> transpose mn) <$> no
no .@ mn = transpose ((no $@) <$> transpose mn)

{--------------------------------------------------------------------
    Permutations
--------------------------------------------------------------------}

invertR :: IsNat n => RTree n a -> LTree n a
invertR = invertR' nat

invertR' :: Nat n -> RTree n a -> LTree n a
invertR' Zero     = \ (RT.L a ) -> LT.L a
invertR' (Succ m) = \ (RT.B ts) -> LT.B (invertR' m (transpose ts))
-- invertR' (Succ m) = \ (RT.B ts) -> LT.B (transpose (invertR' m <$> ts))

#if 0
RT.unB    :: RTree (S n)   a  -> Pair (RTree n a)
transpose :: Pair (RTree n a) -> RTree n (Pair a)
invertR   :: RTree n (Pair a) -> LTree n (Pair a)
LT.B      :: LTree n (Pair a) -> LTree (S n)   a

RT.unB       :: RTree (S n)   a  -> Pair (RTree n a)
fmap invertR :: Pair (RTree n a) -> Pair (LTree n a)
transpose    :: Pair (LTree n a) -> LTree n (Pair a)
LT.B         :: LTree n (Pair a) -> LTree (S n)   a
#endif

-- We needed the IsNat n for Applicative on RTree n.
-- The reverse transformation is easier, since we know Pair is Applicative.

invertL :: LTree n a -> RTree n a
invertL (LT.L a ) = RT.L a
invertL (LT.B ts) = RT.B (transpose (invertL ts))
-- invertL (LT.B ts) = RT.B (invertL <$> transpose ts)

-- invertR' (Succ m) = \ (RT.B ts) -> LT.B (transpose (invertR' m <$> ts))

#if 0
LT.unB    :: LTree (S n)   a  -> LTree n (Pair a)
invertL   :: LTree n (Pair a) -> RTree n (Pair a)
transpose :: RTree n (Pair a) -> Pair (RTree n a)
RT.B      :: Pair (RTree n a) -> RTree (S n)   a

LT.unB       :: LTree (S n)   a  -> LTree n (Pair a)
transpose    :: LTree n (Pair a) -> Pair (LTree n a)
fmap invertL :: Pair (LTree n a) -> Pair (RTree n a)
RT.B         :: Pair (RTree n a) -> RTree (S n)   a
#endif

#endif
