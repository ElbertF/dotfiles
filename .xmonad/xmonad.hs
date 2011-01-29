-- Imports
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Run(spawnPipe)
import XMonad.Layout.NoBorders
import System.IO
import qualified XMonad.StackSet as W -- to shift and float windows

-- The main function
main = do
	spawn "sh ~/.xmonad/autostart.sh"
	xmproc <- spawnPipe "xmobar ~/.xmobarrc"
	xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
		{ workspaces = myWorkspaces
		, manageHook = myManageHook <+> manageHook defaultConfig -- uses default too
		, layoutHook = avoidStruts $ smartBorders $ layoutHook defaultConfig
		, logHook    = dynamicLogWithPP $ xmobarPP
			{ ppCurrent         = xmobarColor "#F09" "" . wrap "[" "]"
			, ppHidden          = xmobarColor "#FFF" ""
			, ppHiddenNoWindows = xmobarColor "#444" ""
			, ppLayout          = xmobarColor "#FFF" ""
			, ppOutput          = hPutStrLn xmproc
			, ppSep             = " | "
			, ppTitle           = xmobarColor "#9F0" "" . shorten 50
			, ppUrgent          = xmobarColor "#F90" "" . wrap "*" "*"
			, ppVisible         = xmobarColor "#FFF" ""
			, ppWsSep           = " "
			}
		, modMask            = mod4Mask
		, normalBorderColor  = "#444"
		, focusedBorderColor = "#FFF"
        } `additionalKeys` myKeys

myWorkspaces = ["1:CLI","2:WEB","3:CODE","4:MEDIA","5:FTP","6:PIRATE","7","8","9","0"]

-- Organize windows
myManageHook :: ManageHook

myManageHook = composeAll . concat $
    [ [className =? c --> doFloat | c <- myFloats]
    , [title     =? t --> doFloat | t <- myOtherFloats]
    , [resource  =? r --> doFloat | r <- myIgnores]
    , [className =? "Firefox"              --> doF (W.shift "2:WEB")]
    , [className =? "Minefield"            --> doF (W.shift "2:WEB")]
    , [className =? "Iceweasel"            --> doF (W.shift "2:WEB")]
    , [className =? "Gvim"                 --> doF (W.shift "3:CODE")]
    , [className =? "Vlc"                  --> doF (W.shift "4:MEDIA")]
    , [title     =? "Alsa Mixer"           --> doF (W.shift "4:MEDIA")]
    , [title     =? "music - File Manager" --> doF (W.shift "4:MEDIA")]
    , [className =? "Transmission"         --> doF (W.shift "6:PIRATE")]
    , [className =? "Nicotine"             --> doF (W.shift "6:PIRATE")]
    ]
    where
    myFloats      = ["Gimp", "gimp"]
    myOtherFloats = ["Downloads", "Firefox Preferences", "Save As..."]
    myIgnores     = []

-- Key bindings
myKeys =
	[ ((mod4Mask, xK_w),     spawn "~/apps/firefox/firefox")
	, ((mod4Mask, xK_e),     spawn "gvim")
	, ((mod4Mask, xK_f),     spawn "thunar")
	, ((mod4Mask, xK_g),     spawn "gimp")
	, ((mod4Mask, xK_m),     spawn "vlc")
	, ((mod4Mask, xK_t),     spawn "terminator")
	, ((0,        xK_Print), spawn "scrot")
	, ((mod4Mask, xK_F11),   spawn "amixer --quiet set Master 3-")
	, ((mod4Mask, xK_F12),   spawn "amixer --quiet set Master 3+")
	, ((mod4Mask, xK_s),     spawn "amixer --quiet set Master toggle")
	, ((mod4Mask, xK_b),     sendMessage ToggleStruts)
	]
    ++
    [ ((m .|. mod4Mask, k), windows $ f i) | (i, k) <- zip myWorkspaces numPadKeys
    , (f, m)                                        <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

-- Non-numeric num pad keys, sorted by number
numPadKeys = [ xK_KP_End,  xK_KP_Down,  xK_KP_Page_Down -- 1, 2, 3
             , xK_KP_Left, xK_KP_Begin, xK_KP_Right     -- 4, 5, 6
             , xK_KP_Home, xK_KP_Up,    xK_KP_Page_Up   -- 7, 8, 9
             , xK_KP_Insert                             -- 0 
			 ]
