module SemanticDSL where

data SemanticTag = RSVP | SIT | COM | Custom String
data Function a = Function
  { name :: String
  , tag :: SemanticTag
  }
data Module a = Module
  { moduleName :: String
  , functions :: [Function a]
  , dependencies :: [String]
  , semantics :: a
  , phi :: a -> (Double, Double, Double)
  }

combinePhi :: (a -> (Double, Double, Double)) -> (a -> (Double, Double, Double)) -> a -> (Double, Double, Double)
combinePhi phi1 phi2 x = let (p1, v1, s1) = phi1 x
                             (p2, v2, s2) = phi2 x
                         in (p1 + p2, v1 + v2, s1 + s2)

semanticMerge :: Module a -> Module a -> Either String (Module a)
semanticMerge m1 m2
  | semantics m1 == semantics m2 = Right $ Module
      { moduleName = moduleName m1 ++ "merged" ++ moduleName m2
      , functions = functions m1 ++ functions m2
      , dependencies = dependencies m1 ++ dependencies m2
      , semantics = semantics m1
      , phi = combinePhi (phi m1) (phi m2)
      }
  | otherwise = Left "Incompatible semantic tags"

main :: IO ()
main = do
  let m1 = Module "mod1" [Function "f1" RSVP] ["dep1"] "RSVP" (\_ -> (1.0, 0.0, 0.0))
      m2 = Module "mod2" [Function "f2" RSVP] ["dep2"] "RSVP" (\_ -> (0.0, 1.0, 0.0))
  print $ semanticMerge m1 m2