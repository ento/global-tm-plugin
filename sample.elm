module Sample (..) where

import Task exposing (Task)

type alias Model =
    { foo : Bool }

type Action
    = NoOp
    | Update

port outbound : Signal String
port outbound =
    mailbox.signal


mailbox : Signal.Mailbox String
mailbox =
    let
        box =
            Signal.Mailbox ""
    in
        box
