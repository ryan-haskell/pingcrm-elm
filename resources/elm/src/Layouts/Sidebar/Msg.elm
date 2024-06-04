module Layouts.Sidebar.Msg exposing (Msg(..))

import Http


type Msg
    = ClickedHamburgerMenu
    | ClickedUserDropdown
    | ClickedDismissDropdown
    | ClickedLogout
    | LogoutResponded (Result Http.Error ())
    | ShowProblem
        { durationInMs : Maybe Float
        , problem :
            { message : String
            , details : Maybe String
            }
        }
    | DismissedProblem
