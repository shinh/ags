import qualified Data.Map as M
import System.Environment (getArgs)

type Prog = [[String]]
data LabelData = L (M.Map String LabelData) Prog

value v vs = M.findWithDefault False v vs
x `nand` y = not (x && y)

runCmds :: M.Map String Bool -> M.Map String LabelData -> [[String]] -> String
runCmds vars labels prog@([label]:rest)
    = case (value label vars, M.lookup label labels) of
        (True, Just (L labels' prog'))
            -> runCmds vars labels' prog'
        _   -> runCmds vars labels' rest
          where labels' = M.insert label (L labels' rest) labels
runCmds vars labels ([v1,v2,v3]:rest)
    = runCmds (M.insert v1 (value v2 vars `nand` value v3 vars) vars)
        labels rest
runCmds vars labels (vs@[_,_,_,_,_,_,_,_]:rest)
    = c : runCmds vars labels rest
  where
    c = toEnum $ foldl (\n b -> n*2 + fromEnum (value b vars)) 0 vs
runCmds _ _ [] = ""
runCmds _ _ (snt:_) = error $ "Undefined sentence: " ++ unwords snt

interpret = runCmds M.empty M.empty . map words . lines

main = do
    args <- getArgs
    case args of
        [] -> interact interpret
        [fileName] -> putStr . interpret =<< readFile fileName
        _ -> error "Too many arguments, only one supported"
