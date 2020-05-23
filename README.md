# Fable.Elmish.Nile

[![Nuget](https://img.shields.io/nuget/v/Fable.Elmish.Nile.svg)](https://www.nuget.org/packages/Fable.Elmish.Nile/)

Extension to [Fable.Elmish](https://elmish.github.io/elmish/) that enables transforming the stream of dispatched messages from the view to messages that are dispatched to the update function.

It's an alternative approach to [Fable.Elmish.Streams](https://elmish-streams.readthedocs.io/en/latest/).
However Fable.Elmish.Streams has some nice helpers that you might want to use with Fable.Elmish.Nile.

Sample usage:

```fsharp
open Fable.Elmish.Nile

let stream states msgs =
    [
        // Let `Increment` messages flow through.
        // Note that messages are swallowed by default, you have to explicitely let them flow through.
        msgs
        |> AsyncRx.choose (function | Increment as x -> Some x | _ -> None)

        // Debounce `Search` messages for 500 ms
        msgs
        |> AsyncRx.choose (function | Search as x -> Some x | _ -> None)
        |> AsyncRx.debounce 500
    ]
    |> AsyncRx.mergeSeq // Merge all streams together (this is where "Nile" comes from)

Program.mkSimple init update view
|> Program.withStream stream
|> Program.run
```

Sub streams are also possible:

```fsharp
open Fable.Elmish.Nile

let stream states msgs =
    [
        // Top-level message
        msgs
        |> AsyncRx.choose (function | ActivateTab _ as x -> Some x | _ -> None)

        // Forward model and message stream to sub component and map the resulting messages back to top-level messages
        (
            states |> AsyncRx.map (snd >> fun m -> m.SubComponent1Model),
            msgs |> AsyncRx.choose (function SubComponent1Msg msg -> Some msg | _ -> None)
        )
        ||> SubComponent1.stream
        |> AsyncRx.map SubComponent1Msg

        // The pattern for sub components is always the same
        (
            states |> AsyncRx.map (snd >> fun m -> m.SubComponent2Model),
            msgs |> AsyncRx.choose (function SubComponent2Msg msg -> Some msg | _ -> None)
        )
        ||> SubComponent2.stream
        |> AsyncRx.map SubComponent2Msg
    ]
    |> AsyncRx.mergeSeq // Merge all streams together (this is where "Nile" comes from)

Program.mkSimple init update view
|> Program.withStream stream
|> Program.run
```
