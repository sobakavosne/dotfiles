import           Control.Concurrent                  (forkIO, threadDelay)
import           Control.Monad                       (forever, void)
import           Control.Monad.IO.Class              (liftIO)
import           Data.Monoid
import           System.Exit
import           System.IO                           (hPutStrLn)
import           XMonad

import qualified Data.Map                            as M
import qualified XMonad.StackSet                     as W

-- Actions
import           XMonad.Actions.CopyWindow
import           XMonad.Actions.CycleWS
import           XMonad.Actions.MouseResize

-- Hooks
import           XMonad.Hooks.ManageDocks

-- Layouts
import           XMonad.Layout.LayoutModifier
import           XMonad.Layout.LimitWindows          (decreaseLimit,
                                                      increaseLimit,
                                                      limitWindows)
import           XMonad.Layout.MultiToggle           (EOT (EOT), mkToggle,
                                                      single, (??))
import           XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Simplest
import           XMonad.Layout.SimplestFloat
import           XMonad.Layout.Spacing
import           XMonad.Layout.Spiral
import           XMonad.Layout.SubLayouts
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts         as T (ToggleLayout (Toggle),
                                                           toggleLayouts)
import           XMonad.Layout.WindowArranger        (WindowArrangerMsg (..),
                                                      windowArrange)
import           XMonad.Layout.WindowNavigation

-- Utils
import           XMonad.Util.EZConfig                (additionalKeysP)
import           XMonad.Util.Run
import           XMonad.Util.SpawnOnce

myTerminal = "terminator"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth = 2

myFont :: String
myFont =
  "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

-- mod1Mask - left alt
-- mod3Mask - right alt
-- mod4Mask - windows key
--
myModMask = mod1Mask

myWorkspaces = map show [0 .. 9]

myNormalBorderColor = "#282c34"

myFocusedBorderColor = "#46d9ff"

colorBack = "#fdf6e3"

color08 = "#eee8d5"

color15 = "#93a1a1"

color16 = "#6c71c4"

myKeys conf@XConfig {XMonad.modMask = modm} =
  M.fromList $
    -- launch a terminal
  [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launch dmenu
  , ((modm, xK_p), spawn "dmenu_run")
    -- launch nautilus
  , ((mod4Mask, xK_e), spawn "nautilus")
      -- launch telegram
  , ((mod4Mask, xK_t), spawn "telegram-desktop")
    -- launch gmrun
  , ((modm .|. shiftMask, xK_p), spawn "gmrun")
    -- close focused window
  , ((modm .|. shiftMask, xK_c), kill)
     -- Rotate through the available layout algorithms
  , ((modm, xK_space), sendMessage NextLayout)
    --  Reset the layouts on the current workspace to default
  , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    -- Move focus to the next window
  , ((modm, xK_Tab), windows W.focusDown)
    -- Swap the focused window and the master window
  , ((modm, xK_Return), windows W.swapMaster)
    -- Shrink the master area
  , ((modm, xK_k), sendMessage Shrink)
    -- Expand the master area
  , ((modm, xK_l), sendMessage Expand)
    -- Push window back into tiling
  , ((modm, xK_t), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
  , ((modm, xK_comma), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
  , ((modm, xK_period), sendMessage (IncMasterN (-1)))
    -- Brightness control
  , ( (controlMask, xK_F4)
    , spawn
        "xrandr --output eDP-1-0 --brightness $(xrandr --verbose | grep -i brightness | cut -f2 -d ' ' | awk '{if ($1-0.05 >= 0.05) print $1-0.05; else print 0.05}')")
  , ( (controlMask, xK_F5)
    , spawn
        "xrandr --output eDP-1-0 --brightness $(xrandr --verbose | grep -i brightness | cut -f2 -d ' ' | awk '{if ($1+0.05 <= 1.0) print $1+0.05; else print 1.0}')")
    -- Sound level control
  , ((controlMask, xK_F2), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
  , ((controlMask, xK_F3), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
  , ((modm, xK_b), sendMessage ToggleStruts)
    -- Quit xmonad
  , ((modm .|. shiftMask, xK_q), io exitSuccess)
    -- Restart xmonad
  , ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
    -- Switch to the next workspace
  , ((modm .|. controlMask, xK_Right), nextWS)
    -- Switch to the previous workspace
  , ((modm .|. controlMask, xK_Left), prevWS)
  ] ++
    -- Send window to the workspace
  [ ((modm .|. shiftMask, xK_Left), shiftToPrev >> prevWS) -- Send window to previous workspace
  , ((modm .|. shiftMask, xK_Right), shiftToNext >> nextWS) -- Send window to next workspace
  ] ++
    -- super-space, Change keyboard layout
  [((mod4Mask, xK_space), spawn "~/.xmonad/toggle_layout.sh")]

myMouseBindings XConfig {XMonad.modMask = modm} =
  M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ( (modm, button1)
      , \w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster)
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ( (modm, button3)
      , \w -> focus w >> mouseResizeWindow w >> windows W.shiftMaster)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

-- Layouts
mySpacing ::
     Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

mySpace :: Integer
mySpace = 5

tall =
  renamed [Replace "tall"] $
  limitWindows 5 $
  smartBorders $
  windowNavigation $
  addTabs shrinkText myTabTheme $
  subLayout [] (smartBorders Simplest) $
  mySpacing mySpace $ ResizableTall 1 (3 / 100) (1 / 2) []

monocle =
  renamed [Replace "monocle"] $
  smartBorders $
  windowNavigation $
  addTabs shrinkText myTabTheme $ subLayout [] (smartBorders Simplest) Full

floats = renamed [Replace "floats"] $ smartBorders simplestFloat

myLayoutHook =
  avoidStruts $
  mouseResize $
  windowArrange $
  T.toggleLayouts floats $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = withBorder myBorderWidth tall ||| noBorders monocle

myTabTheme =
  def
    { fontName = myFont
    , activeColor = color15
    , inactiveColor = color08
    , activeBorderColor = color15
    , inactiveBorderColor = colorBack
    , activeTextColor = colorBack
    , inactiveTextColor = color16
    }

batteryCheck :: IO ()
batteryCheck =
  void $
  forkIO $
  forever $ do
    safeSpawn "bash" ["-c", "~/.xmonad/check_battery.sh"]
    threadDelay (60 * 1000000)

myLogHook = return ()

myStartupHook = do
  liftIO batteryCheck
  spawnOnce "~/.xmonad/apply_color_profile.sh"
  spawnOnce "nitrogen --restore &"
  spawnOnce "compton &"

main = do
  xmproc <- spawnPipe "xmobar ~/.config/xmobar/xmobarrc"
  xmonad $ docks defaults

defaults =
  def
      -- simple stuff
    { terminal = myTerminal
    , focusFollowsMouse = myFocusFollowsMouse
    , clickJustFocuses = myClickJustFocuses
    , borderWidth = myBorderWidth
    , modMask = myModMask
    , workspaces = myWorkspaces
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
      -- key bindings
    , keys = myKeys
    , mouseBindings = myMouseBindings
      -- hooks, layouts
    , layoutHook = myLayoutHook
    , logHook = myLogHook
    , startupHook = myStartupHook
    }
