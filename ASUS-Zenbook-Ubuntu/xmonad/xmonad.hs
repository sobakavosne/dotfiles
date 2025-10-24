import           Control.Concurrent                  (forkIO, threadDelay)
import           Control.Monad                       (forever, void)
import           Control.Monad.IO.Class              (liftIO)
import           Data.Monoid                         ()
import           System.Exit                         (exitSuccess)
import           System.IO                           (hPutStrLn)
import           XMonad                              (ChangeLayout (NextLayout),
                                                      Default (def),
                                                      Full (Full),
                                                      IncMasterN (IncMasterN),
                                                      MonadIO (liftIO),
                                                      Resize (Expand, Shrink),
                                                      XConfig (XConfig, borderWidth, clickJustFocuses, focusFollowsMouse, focusedBorderColor, keys, layoutHook, logHook, modMask, mouseBindings, normalBorderColor, startupHook, terminal, workspaces),
                                                      button1, button2, button3,
                                                      controlMask, focus, io,
                                                      kill, mod1Mask, mod4Mask,
                                                      mouseMoveWindow,
                                                      mouseResizeWindow,
                                                      sendMessage, setLayout,
                                                      shiftMask, spawn, windows,
                                                      withFocused, xK_Left,
                                                      xK_Print, xK_Return,
                                                      xK_Right, xK_Tab, xK_b, xK_r,
                                                      xK_c, xK_comma, xK_d,
                                                      xK_e, xK_grave, xK_i,
                                                      xK_k, xK_l, xK_o, xK_p,
                                                      xK_period, xK_q, xK_space,
                                                      xK_t, xK_w, xmonad, (.|.),
                                                      (|||))

import qualified Data.Map.Strict                     as M
import qualified XMonad.StackSet                     as W

-- Actions
import           XMonad.Actions.CopyWindow           ()
import           XMonad.Actions.CycleWS              (nextWS, prevWS,
                                                      shiftToNext, shiftToPrev)
import           XMonad.Actions.MouseResize          (mouseResize)

-- Hooks
import           XMonad.Hooks.ManageDocks            (ToggleStruts (ToggleStruts),
                                                      avoidStruts, docks)

-- Layouts
import           XMonad.Layout.LayoutModifier        (ModifiedLayout)
import           XMonad.Layout.LimitWindows          (decreaseLimit,
                                                      increaseLimit,
                                                      limitWindows)
import           XMonad.Layout.MultiToggle           (EOT (EOT), mkToggle,
                                                      single, (??))
import           XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import           XMonad.Layout.NoBorders             (noBorders, smartBorders,
                                                      withBorder)
import           XMonad.Layout.Renamed               (Rename (Replace), renamed)
import           XMonad.Layout.ResizableTile         (MirrorResize (MirrorExpand, MirrorShrink),
                                                      ResizableTall (ResizableTall))
import           XMonad.Layout.Simplest              (Simplest (Simplest))
import           XMonad.Layout.SimplestFloat         (simplestFloat)
import           XMonad.Layout.Spacing               (Border (Border), Spacing,
                                                      spacingRaw)
import           XMonad.Layout.Spiral                ()
import           XMonad.Layout.SubLayouts            (subLayout)
import           XMonad.Layout.Tabbed                (Theme (activeBorderColor, activeColor, activeTextColor, fontName, inactiveBorderColor, inactiveColor, inactiveTextColor),
                                                      addTabs, def, shrinkText)
import           XMonad.Layout.ThreeColumns          ()
import qualified XMonad.Layout.ToggleLayouts         as T (ToggleLayout (Toggle),
                                                           toggleLayouts)
import           XMonad.Layout.WindowArranger        (WindowArrangerMsg (..),
                                                      windowArrange)
import           XMonad.Layout.WindowNavigation      (def, windowNavigation)

-- Utils
import           XMonad.Util.EZConfig                (additionalKeysP)
import           XMonad.Util.Run                     (safeSpawn)
import           XMonad.Util.SpawnOnce               (spawnOnce)

-- Extra
import           Graphics.X11.ExtraTypes.XF86        (xF86XK_AudioLowerVolume,
                                                      xF86XK_AudioPause,
                                                      xF86XK_AudioPlay,
                                                      xF86XK_AudioRaiseVolume,
                                                      xF86XK_MonBrightnessDown,
                                                      xF86XK_MonBrightnessUp)

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

myFocusedBorderColor = "#cc9999" -- "#46d9ff"

colorBack = "#fdf6e3"

color08 = "#eee8d5"

color15 = "#93a1a1"

color16 = "#6c71c4"

myKeys conf@XConfig {XMonad.modMask = modm} =
  M.fromList
    $
     [
      -- ((modm .|. shiftMask, xK_Return), spawn "terminator -x nu")
      ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
     , ((modm, xK_p), spawn "dmenu_run")
     , ((modm, xK_r), spawn "wire-desktop --password-store=\"gnome-libsecret\"")
     , ((mod4Mask, xK_e), spawn "nautilus")
     , ((mod4Mask, xK_t), spawn "telegram-desktop")
     , ((modm .|. shiftMask, xK_p), spawn "gmrun")
     , ((mod4Mask, xK_w), spawn "librewolf")
     , ((mod4Mask, xK_c), spawn "code")
     , ((mod4Mask, xK_d), spawn "discord")
     , ((0, xK_Print), spawn "flameshot gui")
    -- close focused window
     , ((modm .|. shiftMask, xK_c), kill)
    -- Rotate through the available layout algorithms
     , ((modm, xK_space), sendMessage NextLayout)
    -- Reset the layouts on the current workspace to default
     , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)
    -- Move focus to the next window
     , ((modm, xK_Tab), windows W.focusDown)
    -- Swap the focused window and the master window
     , ((modm, xK_Return), windows W.swapMaster)
     , ((modm, xK_k), sendMessage Shrink)
     , ((modm, xK_l), sendMessage Expand)
     , ((modm, xK_i), sendMessage MirrorShrink)
     , ((modm, xK_o), sendMessage MirrorExpand)
    -- Push window back into tiling
     , ((modm, xK_t), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
     , ((modm, xK_comma), sendMessage (IncMasterN 1))
    -- Decrement the number of windows in the master area
     , ((modm, xK_period), sendMessage (IncMasterN (-1)))
    -- Brightness control
     , ( (0, xF86XK_MonBrightnessDown)
       , spawn "~/.xmonad/set_brightness_level_and_notify.sh --delta -0.05")
     , ( (0, xF86XK_MonBrightnessUp)
       , spawn "~/.xmonad/set_brightness_level_and_notify.sh --delta +0.05")
    -- Sound level control
     , ( (0, xF86XK_AudioLowerVolume)
       , spawn "~/.xmonad/set_volume_level_and_notify.sh --delta -5%")
     , ( (0, xF86XK_AudioRaiseVolume)
       , spawn "~/.xmonad/set_volume_level_and_notify.sh --delta +5%")
     , ((modm, xK_b), sendMessage ToggleStruts)
    -- Quit xmonad
     , ((modm .|. shiftMask, xK_q), io exitSuccess)
    -- Restart xmonad
     , ( (modm, xK_q)
       , spawn "xmonad --recompile; ~/.xmonad/cleanup.sh; xmonad --restart")
    -- Switch to the next workspace
     , ((modm .|. controlMask, xK_Right), nextWS)
    -- Switch to the previous workspace
     , ((modm .|. controlMask, xK_Left), prevWS)
     , ((modm .|. shiftMask, xK_l), spawn "~/.xmonad/media_lock_once.sh")
     ]
       ++
    -- Send window to the workspace
        [ ((modm .|. shiftMask, xK_Left), shiftToPrev >> prevWS) -- Send window to previous workspace
        , ((modm .|. shiftMask, xK_Right), shiftToNext >> nextWS) -- Send window to next workspace
        ]
       ++
    -- super-space, Change keyboard layout
        [((mod4Mask, xK_space), spawn "~/.xmonad/toggle_layout.sh")]
       ++
    -- Keybindings for play/pause button (headphones)
        [ ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
        , ((0, xF86XK_AudioPause), spawn "playerctl play-pause")
        ]
       ++ [ ( (modm .|. controlMask, xK_grave)
            , spawn "~/.xmonad/media_check_lock.sh")
          ]

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
  renamed [Replace "tall"]
    $ limitWindows 5
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest)
    $ mySpacing mySpace
    $ ResizableTall 1 (3 / 100) (1 / 2) []

monocle =
  renamed [Replace "monocle"]
    $ smartBorders
    $ windowNavigation
    $ addTabs shrinkText myTabTheme
    $ subLayout [] (smartBorders Simplest) Full

floats = renamed [Replace "floats"] $ smartBorders simplestFloat

myLayoutHook =
  avoidStruts
    $ mouseResize
    $ windowArrange
    $ T.toggleLayouts floats
    $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
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
  void
    $ forkIO
    $ forever
    $ do
        safeSpawn "bash" ["-c", "~/.xmonad/check_battery.sh"]
        threadDelay (60 * 1000000)

myLogHook = return ()

myStartupHook = do
  spawn "killall xmobar"
  liftIO batteryCheck
  spawnOnce "~/.xmonad/apply_color_profile.sh"
  spawnOnce "numlockx on"
  spawnOnce "nitrogen --restore &"
  spawnOnce "compton &"
  spawnOnce "xautolock -time 10 -locker ~/.xmonad/media_check_lock.sh &"
  spawn "sleep 0.01 && xmobar ~/.config/xmobar/xmobarrc"

main = do
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
