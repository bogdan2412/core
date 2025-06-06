open! Import
include Binable_intf
include Binable0

(* [of_string] and [to_string] can't go in binable0.ml due to a cyclic dependency. *)
[%%template
[@@@mode.default m = (global, local)]

let of_string m string = (of_bigstring [@mode m]) m (Bigstring.of_string string)
let to_string m t = Bigstring.to_string ((to_bigstring [@mode m]) m t)]
