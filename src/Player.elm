module Player exposing (ActivePlayers, Player, PlayerId, Players, getName, getPlayer, health, hit, ko, view)

import Css exposing (..)
import Deque exposing (Deque)
import Dict exposing (Dict)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src, style)
import Tailwind.Theme as Tw exposing (..)
import Tailwind.Utilities as Tw exposing (..)


type alias PlayerId =
    Int


type alias Player =
    { id : PlayerId
    , name : String
    , hp : Int
    , maxHp : Int
    }


type alias Players =
    Dict Int Player


type alias ActivePlayers =
    Deque Int


health : PlayerId -> Players -> String
health playerId players =
    let
        player =
            getPlayer players playerId
    in
    "(" ++ String.fromInt player.hp ++ "/" ++ String.fromInt player.maxHp ++ ")"


default_player : Player
default_player =
    { id = 0
    , name = "DEFAULT"
    , hp = 0
    , maxHp = 0
    }


getPlayer : Players -> PlayerId -> Player
getPlayer players id =
    let
        maybe =
            Dict.get id players
    in
    Maybe.withDefault default_player maybe


getName : Players -> PlayerId -> String
getName players id =
    .name (getPlayer players id)


hit : Players -> PlayerId -> Player
hit players id =
    let
        player =
            getPlayer players id
    in
    -- if you can decrement this, return the player record
    -- else return nothing or bad result?
    if player.hp > 0 then
        { player | hp = player.hp - 1 }

    else
        { player | hp = 0 }


ko : PlayerId -> ActivePlayers -> ActivePlayers
ko id activePlayers =
    Tuple.first (Deque.partition (\activePlayer -> activePlayer /= id) activePlayers)


view : PlayerId -> Player -> Html msg
view currentTurn player =
    let
        healthDiv bgStyle =
            div [ css [ bgStyle, Tw.w_8, Tw.flex_1, Tw.border_b_2, Tw.border_color Tw.secondary ] ] []

        healthBg h =
            if h <= player.hp then
                if (toFloat h / toFloat player.maxHp) <= (1 / 5) then
                    Tw.bg_color Tw.primary

                else if (toFloat h / toFloat player.maxHp) <= (3 / 5) then
                    Tw.bg_color Tw.exclaim

                else
                    Tw.bg_color Tw.success

            else
                Tw.bg_color Tw.secondary

        healthStack =
            List.map healthBg (List.reverse (List.range 1 player.maxHp))
    in
    {- css
           [ color
               (if player.hp <= 0 then
                   rgb 255 69 0

                else if player.id == currentTurn then
                   rgb 100 149 237

                else
                   hex "dfeee3"
               )
           ]
       ,
    -}
    div
        [ css [ Tw.grid, Tw.grid_cols_2, Tw.gap_2, Tw.grid_cols_player_stats ]
        ]
        [ div []
            [ div []
                [ h3
                    [ css [ Tw.text_3xl, Tw.text_center ]
                    , css
                        (if player.id == currentTurn then
                            [ Tw.text_color Tw.purple_100, Css.textDecoration Css.underline ]

                         else
                            []
                        )
                    ]
                    [ text player.name ]
                , ul []
                    [ li
                        []
                        [ text "Bonus Dam.: 90" ]
                    , li
                        []
                        [ text "Dam. Mit.: 20" ]
                    , li
                        []
                        [ text "Exec.: 0" ]
                    ]
                ]
            ]
        , div [ css [ Tw.h_full, Tw.flex, Tw.flex_col, Tw.items_end ] ] (List.map healthDiv healthStack)

        -- , text ("( " ++ hp ++ " / " ++ maxHp ++ " ) ")
        ]
