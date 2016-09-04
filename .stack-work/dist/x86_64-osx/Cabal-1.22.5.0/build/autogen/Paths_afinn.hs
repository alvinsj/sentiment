module Paths_afinn (
    version,
    getBinDir, getLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/Users/alvinsj/Development/github/haskell/munihac16/afinn/.stack-work/install/x86_64-osx/lts-6.14/7.10.3/bin"
libdir     = "/Users/alvinsj/Development/github/haskell/munihac16/afinn/.stack-work/install/x86_64-osx/lts-6.14/7.10.3/lib/x86_64-osx-ghc-7.10.3/afinn-0.1.0.0-40dNCMTZJnuGpnEwbx1q58"
datadir    = "/Users/alvinsj/Development/github/haskell/munihac16/afinn/.stack-work/install/x86_64-osx/lts-6.14/7.10.3/share/x86_64-osx-ghc-7.10.3/afinn-0.1.0.0"
libexecdir = "/Users/alvinsj/Development/github/haskell/munihac16/afinn/.stack-work/install/x86_64-osx/lts-6.14/7.10.3/libexec"
sysconfdir = "/Users/alvinsj/Development/github/haskell/munihac16/afinn/.stack-work/install/x86_64-osx/lts-6.14/7.10.3/etc"

getBinDir, getLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "afinn_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "afinn_libdir") (\_ -> return libdir)
getDataDir = catchIO (getEnv "afinn_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "afinn_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "afinn_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
