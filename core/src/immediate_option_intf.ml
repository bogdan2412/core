(** A non-allocating alternative to the standard Option type. *)

open! Import

module type S_without_immediate_plain = sig
  (** The immediate value carried by the immediate option.

      Given the presence of {!unchecked_value}, the [value] type should not have
      operations that depend on the value's validity for memory safety. In particular,
      [unchecked_value] is not called [unsafe_value] as it would be if it could return a
      value that later resulted in a segmentation fault. For pointer-like values, use
      {!Ext.Nullable}, for example. *)
  type value

  (** Represents [value option] without allocating a [Some] tag. The interface does not
      enforce that [t] is immediate because some types, like [Int63.t], are only immediate
      on 64-bit platforms. For representations whose type is immediate, use [S] below
      which adds the [[@@immediate]] annotation. *)
  type t

  (** Constructors analogous to [None] and [Some]. If [not (some_is_representable x)] then
      [some x] may raise or return [none]. *)

  val none : t
  val some : value -> t

  (** For some representations of immediate options, the encodings of [none] and [some]
      overlap. For these representations, [some_is_representable value = false] if [value]
      cannot be represented as an option. For example, [Int.Option] uses [min_value] to
      represent [none]. For other representations, [some_is_representable] always returns
      [true]. *)
  val some_is_representable : value -> bool

  val is_none : t -> bool
  val is_some : t -> bool

  (** [value (some x) ~default = x] and [value none ~default = default]. *)
  val value : t -> default:value -> value

  (** [value_exn (some x) = x]. [value_exn none] raises. Unlike [Option.value_exn], there
      is no [?message] argument, so that calls to [value_exn] that do not raise also do
      not have to allocate. *)
  val value_exn : t -> value

  (** [unchecked_value (some x) = x]. [unchecked_value none] returns an unspecified value.
      [unchecked_value t] is intended as an optimization of [value_exn t] when [is_some t]
      is known to be true. *)
  val unchecked_value : t -> value

  val to_option : t -> value option
  val of_option : value option -> t

  module Optional_syntax : Optional_syntax.S with type t := t with type value := value
end

module type S_without_immediate_plain_zero_alloc = sig
  type value
  type t

  val none : t
  val some : value -> t [@@zero_alloc]
  val some_is_representable : value -> bool [@@zero_alloc]
  val is_none : t -> bool [@@zero_alloc]
  val is_some : t -> bool [@@zero_alloc]
  val value : t -> default:value -> value [@@zero_alloc]
  val value_exn : t -> value [@@zero_alloc]
  val unchecked_value : t -> value [@@zero_alloc]
  val to_option : t -> value option
  val of_option : value option -> t [@@zero_alloc]

  module Optional_syntax :
    Optional_syntax.S_zero_alloc with type t := t with type value := value
end

module type S_without_immediate = sig
  type t [@@deriving compare, hash, sexp_of, typerep]

  include S_without_immediate_plain with type t := t
end

module type S_without_immediate_zero_alloc = sig
  type t [@@deriving compare, hash, sexp_of, typerep]

  include S_without_immediate_plain_zero_alloc with type t := t
end

module type S_plain = sig
  type t [@@immediate]

  include S_without_immediate_plain with type t := t
end

module type S = sig
  type t [@@immediate]

  include S_without_immediate with type t := t
end

module type S_plain_zero_alloc = sig
  type t [@@immediate]

  include S_without_immediate_plain_zero_alloc with type t := t
end

module type S_zero_alloc = sig
  type t [@@immediate]

  include S_without_immediate_zero_alloc with type t := t
end

module type S_int63_plain = sig
  type t [@@immediate64]

  include S_without_immediate_plain with type t := t
end

module type S_int63 = sig
  type t [@@immediate64]

  include S_without_immediate with type t := t
end

module type S_int63_zero_alloc = sig
  type t [@@immediate64]

  include S_without_immediate_zero_alloc with type t := t
end

module type S_unboxed_float64 = sig
  type t
  type value

  val typerep_of_t : t Typerep_lib.Std.Typerep.t
  val sexp_of_t : t -> Sexp.t
  val none : unit -> t [@@zero_alloc]
  val some : value -> t [@@zero_alloc]
  val some_is_representable : value -> bool [@@zero_alloc]
  val is_none : t -> bool [@@zero_alloc]
  val is_some : t -> bool [@@zero_alloc]
  val value : t -> default:value -> value [@@zero_alloc]
  val value_exn : t -> value [@@zero_alloc]
  val unchecked_value : t -> value [@@zero_alloc]

  module Optional_syntax : sig
    type nonrec t = t
    type nonrec value = value

    module Optional_syntax : sig
      val is_none : t -> bool [@@zero_alloc]
      val unsafe_value : t -> value [@@zero_alloc]
    end
  end
end

module type Immediate_option = sig
  (** Always immediate. *)

  module type S = S
  module type S_plain = S_plain
  module type S_plain_zero_alloc = S_plain_zero_alloc
  module type S_zero_alloc = S_zero_alloc

  (** Immediate only on 64-bit machines. *)

  module type S_int63 = S_int63
  module type S_int63_plain = S_int63_plain
  module type S_int63_zero_alloc = S_int63_zero_alloc

  (** Never immediate. *)

  module type S_without_immediate = S_without_immediate
  module type S_without_immediate_plain = S_without_immediate_plain
  module type S_without_immediate_plain_zero_alloc = S_without_immediate_plain_zero_alloc
  module type S_without_immediate_zero_alloc = S_without_immediate_zero_alloc

  (** Unboxed types *)
  module type S_unboxed_float64 = S_unboxed_float64
end
