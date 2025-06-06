open! Import

(** Extension to the base signature *)
module type Extension = sig
  type t
  [@@deriving
    bin_io ~localize, diff ~how:"atomic" ~extra_derive:[ sexp ], globalize, quickcheck]

  module Stable : sig
    (** [Info.t] is wire-compatible with [V2.t], but not [V1.t]. [V1] bin-prots a sexp of
        the underlying message, whereas [V2] bin-prots the underlying message. *)
    module V1 : Stable_module_types.With_stable_witness.S0 with type t = t

    module V2 : sig
      type nonrec t = t
      [@@deriving
        globalize, equal, hash, sexp_grammar, diff ~extra_derive:[ sexp; bin_io ]]

      include%template
        Stable_module_types.With_stable_witness.S0 [@mode local] with type t := t
    end
  end
end

module type Info = sig
  module type S = Base.Info.S

  include S with type t = Base.Info.t (** @inline *)

  module Internal_repr : Base.Info.Internal_repr with type info := t
  include Extension with type t := t
  module Extend (Info : Base.Info.S) : Extension with type t := Info.t
end
