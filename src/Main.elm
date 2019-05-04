module Main exposing (main)

import Browser
import Html exposing (..)
import Task
import Time



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    -- タイムゾーン
    { zone : Time.Zone

    -- 現在時刻
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    -- タイムゾーンの初期値を UTC にする
    ( Model Time.utc (Time.millisToPosix 0)
      -- 実行環境のタイムゾーンを取得する Cmd
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- 1秒おきに時刻を含んだメッセージが届く
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        -- タイムゾーンを取得した
        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    -- 1秒おきに Tick メッセージを受け取る
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    -- 実行環境のタイムゾーンを考慮しながら「時:分:秒」の形にする
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)

        minute =
            String.fromInt (Time.toMinute model.zone model.time)

        second =
            String.fromInt (Time.toSecond model.zone model.time)
    in
    p [] [ text <| hour ++ ":" ++ minute ++ ":" ++ second ]
