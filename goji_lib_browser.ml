(* Published under the LGPL version 3
   Binding (c) 2013 Benjamin Canou *)

open Goji

let browser_package =
  register_package
    ~doc:"Basic JavaScript types and functions."
    ~version:"0.1"
    "browser"

let javascript_component =
  register_component
    ~license:Goji_license.lgpl_v3
    ~doc:"Basic JavaScript types and functions."
    browser_package "JavaScript"
    [ def_type
        ~doc:"Generic JavaScript values."
        "js_value" (abstract any) ;
      def_type
        ~doc:"Generic JavaScript objects."
        "js_object" (abstract any) ;
      def_type
        ~doc:"Native JavaScript (immutable, UTF-16) strings."
        "js_string" (abstract any) ;
      def_type
        ~doc:"Regular Expressions."
        "js_regexp" (abstract any) ;
      def_type
        ~doc:"Date objects."
        "js_date" (abstract any) ;

      structure "js_string"
        ~doc:"Operations on native JavaScript strings." [

        def_function "to_string"
          ~doc:"Convert a native JavaScript UTF-16 string to an \
                UTF-8 encoded OCaml string."
          [ curry_arg "str" (abbrv "js_string" @@ var "tmp") ]
          (get (var "tmp"))
          string ;

        section "Construction" [

          def_function "of_string"
            ~doc:"Convert an OCaml string, expected to be UTF-8 encoded, \
                  to a native JavaScript UTF-16 string."
            [ curry_arg "str" (string @@ var "tmp") ]
            (get (var "tmp"))
            (abbrv "js_string") ;

          def_function "coerce_string"
            ~doc:"Use a JavaScript value as a JavaScript string."
            [ curry_arg "v" (abbrv "js_value" @@ arg 0) ]
            (abs "string_obj"
               (call_constructor (jsglobal "String"))
               (call_method ~sto:(var "string_obj") "valueOf"))
            (abbrv "js_string") ;

          (* TODO: RangeError *)
          def_function "from_char_code"
            ~doc:"Build a string from a single UTF-16 character code."
            [ curry_arg "code" (int @@ arg 0) ]
            (call (jsglobal "String.fromCharCode"))
            (abbrv "js_string") ;
          def_function "from_char_codes"
            ~doc:"Build a string from a sequence of UTF-16 character codes."
            [ curry_arg "code" (list int @@ unroll ()) ]
            (call (jsglobal "String.fromCharCode"))
            (abbrv "js_string") ;

          def_function "from_code_point"
            ~doc:"(ES6) Build a string from a single UTF-32 code point."
            [ curry_arg "code" (int @@ arg 0) ]
            (call (jsglobal "String.fromCodePoint"))
            (abbrv "js_string") ;
          def_function "from_code_points"
            ~doc:"(ES6) Build a string from a sequence of UTF-32 code points."
            [ curry_arg "code" (list int @@ unroll ()) ]
            (call (jsglobal "String.fromCodePoint"))
            (abbrv "js_string") ;

          def_function "concat"
            ~doc:"Concatenates two native JavaScript strings."
            [ curry_arg "left" (abbrv "js_string" @@ this) ;
              curry_arg "right" (abbrv "js_string" @@ arg 0) ]
            (call_method "concat")
            (abbrv "js_string") ;

          def_function "repeat"
            ~doc:"(ES6) Repeats a string a given number of times."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "count" (int @@ arg 0) ]
            (call_method "repeat")
            (abbrv "js_string") ;

          def_function "slice"
            ~doc:"Takes a slice of a string between two indexes (or after an index if [stop] is not specified). \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string."
            [ curry_arg "start" (int @@ arg 0) ;
              opt_arg "stop" (int @@ arg 1) ;
              curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "slice")
            (abbrv "js_string") ;

          def_function "sub"
            ~doc:"Takes a slice of a string from an index and up to a given size. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ;
              curry_arg "len" (int @@ arg 1) ]
            (call_method "substr")
            (abbrv "js_string") ;

          def_function "trim"
            ~doc:"Removes whitespace at both ends of the string."
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "trim")
            (abbrv "js_string") ;

          def_function "lowercase"
            ~doc:"Transforms a string to lowercase."
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "str" (abbrv "js_string" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "toLocaleLowerCase")
               (call_method "toLowerCase"))
            (abbrv "js_string") ;

          def_function "uppercase"
            ~doc:"Transforms a string to uppercase."
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "str" (abbrv "js_string" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "toLocaleUpperCase")
               (call_method "toUpperCase"))
            (abbrv "js_string") ;

        ] ;

        section "Access" [

          def_function "length"
            ~doc:"Number of UTF-16 characters in a native JavaScript string."
            [ curry_arg "str" ~doc:"The string." (abbrv "js_string" @@ var "obj") ]
            (get ((field (var "obj") "length")))
            int ;

          def_function "get_char_code"
            ~doc:"Access the UTF-16 characters of a native JavaScript string."
            [ curry_arg "str" ~doc:"The string." (abbrv "js_string" @@ this) ;
              curry_arg "nth" ~doc:"The position in the string starting from 0." (int @@ arg 0) ]
            (call_method "charCodeAt")
            int ;

          def_function "get_code_point"
            ~doc:"(ES6) Access the UTF-32 characters of a native JavaScript string. \
                  Note that the index is still an UTF-16 index, this function \
                  just reads two UTF-16 chars to build a UTF-32 one when called \
                  on the first half of a surrogate pair."
            [ curry_arg "str" ~doc:"The string." (abbrv "js_string" @@ this) ;
              curry_arg "nth" ~doc:"The position in the string starting from 0." (int @@ arg 0) ]
            (call_method "codePointAt")
            int ;

        ] ;

        section "Escaping" [

          def_function "decode_URI"
            ~doc:"Decode escape sequences in an URI encoded string."
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "decodeURI"))
            (abbrv "js_string") ;

          def_function "encode_URI"
            ~doc:"Escape non alphanumeric or reserved characters in an URI. \
                  Only works on a valid URI, otherwise raises \
                  [Invalid_argument \"encode_URI\"]"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (try_catch
               ~exns:[ Guard.(root = obj "URIError" && raise "Invalid_argument \"encode_URI\""), Const.undefined ]
               (call (jsglobal "encodeURI")))
            (abbrv "js_string") ;

          def_function "decode_URI_component"
            ~doc:"Decode escape sequences in an URI encoded string."
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "decodeURIComponent"))
            (abbrv "js_string") ;

          def_function "encode_URI_component"
            ~doc:"URI escape non alphanumeric or reserved characters in an string."
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "encodeURIComponent"))
            (abbrv "js_string") ;

        ] ;

        section "Parsing" [

          def_function "parse_int"
            ~doc:"Parses an integer in JavaScript format and in the given radix. \
                  Be default, the radix is infered from the prefix: 10 if none, 16 if [0x], \
                  implementation dependent if [0]."
            [ opt_arg "radix" (int @@ rest ()) ;
              curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "parseInt"))
            (option_nan int) ;

          def_function "parse_float"
            ~doc:"Parses an float in JavaScript format. \
                  Warning, [parse_float \"NaN\"] will return [None]"
            [ curry_arg "str" (abbrv "js_string" @@ arg 0) ]
            (call (jsglobal "parseFloat"))
            (option_nan float)
        ] ;

        section "Search and Replace" [

          def_function "contains"
            ~doc:"(ES6) Search for a substring starting at a given offset \
                  (0 if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "contains")
            bool ;

          def_function "ends_with"
            ~doc:"(ES6) Determines if a substring is present and ends at \
                  a given position (or at the end if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "endsWith")
            bool ;

          def_function "starts_with"
            ~doc:"(ES6) Determines if a substring is present and starts at \
                  a given position (or at 0 if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "startsWith")
            bool ;

          def_function "index_of"
            ~doc:"Search for a substring and return its position \
                  starting at a given offset (0 if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "indexOf")
            (Option (Guard.(var "root" = Const.int (-1)), int)) ;

          def_function "last_index_of"
            ~doc:"Search for a substring and return the position \
                  of its last occurence starting at a given offset \
                  (0 if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "lastIndexOf")
            (Option (Guard.(var "root" = Const.int (-1)), int)) ;

          def_function "replace"
            ~doc:"Returns the matching position when successful."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg ~doc:"the substring to find and replace."
                "pattern" (abbrv "js_string" @@ arg 0)  ;
              curry_arg ~doc:"the replacement, in which \
                              [$&] is the matched substring, \
                              [$$] is a dollar sign, \
                              [$^] is the part of the original string before the match and \
                              [$'] the part after."
                "replacement" (abbrv "js_string" @@ arg 1) ]
            (call_method "replace")
            (abbrv "js_string") ;

          def_function "split"
            ~doc:"Splits a string using a separator."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "sep" (abbrv "js_string" @@ arg 0) ]
            (call_method "split")
            (array (abbrv "js_string")) ;

        ] ;

        section "Comparison" (
          let locale_compare ~doc name usage =
            def_function name
              ~doc:"Search for a substring and return the position \
                    of its last occurence starting at a given offset \
                    (0 if not specified)."
              [ curry_arg "left" (abbrv "js_string" @@ this) ;
                opt_arg
                  ~doc:"A list of BCP-47 language tags."
                  "locales" (list string @@ rest ()) ;
                opt_arg "matcher" (abbrv "locale_matcher" @@ field (var "options") "usage") ;
                opt_arg "sensitivity" (abbrv "locale_compare_sensitivity" @@ field (var "options") "sensitivity") ;
                opt_arg "ignore_punctuation" (bool @@ field (var "options") "ignorePunctuation") ;
                opt_arg "detect_numbers" (bool @@ field (var "options") "numeric") ;
                opt_arg "case_order" (abbrv "locale_compare_case_order" @@ field (var "options") "caseFirst") ;
                curry_arg "right" (abbrv "js_string" @@ arg 0) ]
              (abs "_"
                 (set_const (field (var "options") "usage") Const.(string usage))
                 (abs "_"
                    (set (rest ()) (var "options"))
                    (call_method "localeCompare")))
              int
          in [

            def_type "locale_matcher"
              (public (simple_string_enum [ "lookup" ; "best fit" ])) ;

            def_type "locale_compare_sensitivity"
              (public (simple_string_enum [ "base" ; "accent" ; "case" ; "variant" ])) ;

            def_type "locale_compare_case_order"
              (public (string_enum [ "Uppercase_first", "upper" ; "Lowercase_first", "lower" ; "Locale_default", "false" ])) ;

            locale_compare
              ~doc:"Compare two JavScript strings using the specified locale, \
                    considering similar strings as equivalent." 
              "locale_compare_for_searching" "search" ;

            locale_compare
              ~doc:"Compare two JavScript strings using the specified locale, \
                    ordering similar strings." 
              "locale_compare_for_sorting" "sort" ;
          ]) ;

        section "Regular expressions" [
          def_function "index_of_regexp"
            ~doc:"Returns the matching position when successful."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "pattern" (abbrv "js_regexp" @@ arg 0) ]
            (call_method "search")
            (Option (Guard.(var "root" = Const.int (-1)), int)) ;

          def_function "match_regexp"
            ~doc:"Returns the array on matched groups when successful \
                  (index 0 contains the whole match)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "pattern" (abbrv "js_regexp" @@ arg 0) ]
            (call_method "match")
            (nonempty_array_or_null (abbrv "js_string")) ;

          def_function "replace_regexp"
            ~doc:"Returns the matching position when successful."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg ~doc:"the pattern to find and replace."
                "pattern" (abbrv "js_regexp" @@ arg 0)  ;
              curry_arg ~doc:"the replacement, in which \
                              [$&] is the matched substring, \
                              [$$] is a dollar sign, \
                              [$^] is the part of the original string before the match, \
                              [$'] the part after and \
                              [$n] the [n]th matched group."
                "replacement" (abbrv "js_string" @@ arg 1) ]
            (call_method "replace")
            (abbrv "js_string") ;

          def_function "split_regexp"
            ~doc:"Splits a string using a regexp separator."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "sep" (abbrv "js_regexp" @@ arg 0) ]
            (call_method "split")
            (array (abbrv "js_string")) ;
        ]
      ] ;
      structure "js_obj"
        ~doc:"Not for the casual user." [
        section "Generic operations" [
          def_function "js_value"
            ~doc:"Use any value as its generic JavaScript representation."
            [ curry_arg "v" (param "'a" @@ var "tmp") ]
            (get (var "tmp"))
            (abbrv "js_value") ;
          def_function "coerce"
            ~doc:"Use any JavaScript value with any OCaml type (UNSAFE)."
            [ curry_arg "v" (abbrv "js_value" @@ var "tmp") ]
            (get (var "tmp"))
            (param "'a") ;
          def_function "eval"
            ~doc:"Eval a piece of JavaScript code and obtain its result."
            [ curry_arg "code" (string @@ arg 0) ]
            (call (jsglobal "eval"))
            (abbrv "js_value") ;
          def_value "undefined"
            ~doc:"This one is not very well defined."
            (get (jsglobal "undefined"))
            (abbrv "js_value") ;
          def_function "is"
            ~doc:"Physical equality on objects, strict equality on primitive values ([is undefined undefined], but not [is undefined null])."
            [ curry_arg "obj_l" (abbrv "js_value" @@ arg 0) ;
              curry_arg "obj_r" (abbrv "js_value" @@ arg 1) ]
            (call (jsglobal "Object.is"))
            bool ;
        ] ;
        section "Operations on objects" [
          def_function "coerce_object"
            ~doc:"Use a JavaScript value as a JavaScript object (may raise Invalid_argument)."
            [ curry_arg "v" (abbrv "js_value" @@ var "tmp") ]
            (var_instanceof "tmp" "Object")
            (abbrv "js_object") ;
          def_value "root"
            ~doc:"The fathermother of all objects who goes by the name [Object]."
            (get (jsglobal "Object"))
            (abbrv "js_object") ;
          def_value "null"
            ~doc:"At last, we have it !."
            (get (jsglobal "null"))
            (abbrv "js_object") ;
          def_function "get_property"
            ~doc:"Gets a property of the object. \
                  May raise [Invalid_argument \"Js_obj.set_property\"]."
            [ curry_arg "obj" (abbrv "js_object" @@ this) ;
              curry_arg "name" (string @@ var "name") ]
            (try_catch
               ~exns:[ Guard.(root = obj "TypeError"
                              || raise "Invalid_argument \"Js_obj.set_property\""), Const.undefined ]
               (get (acc this (var "name"))))
            void ;
          def_function "set_property"
            ~doc:"Sets a property of the object. \
                  May raise [Invalid_argument \"Js_obj.set_property\"]."
            [ curry_arg "obj" (abbrv "js_object" @@ this) ;
              curry_arg "name" (string @@ var "name") ;
              curry_arg "v" (abbrv "js_value" @@ var "v") ]
            (try_catch
               ~exns:[ Guard.(root = obj "TypeError"
                              || raise "Invalid_argument \"Js_obj.set_property\""), Const.undefined ]
               (set (acc this (var "name")) (var "v")))
            void ;
          def_type "property_descriptor"
            (public (record [
                 row "configurable" (bool @@ field root "configurable") ;
                 row "enumerable" (bool @@ field root "enumerable") ;
                 row "writable" (bool @@ field root "writable") ;
                 row "getter" (option_undefined (callback [] (abbrv "js_value")) @@ field root "get") ;
                 row "setter" (option_undefined (callback [ curry_arg "new_value" (abbrv "js_value" @@ arg 0) ] void) @@ field root "set") ;
                 row "value" (option_undefined (abbrv "js_value") @@ field root "value") ;
               ])) ;
          def_function "create"
            ~doc:"Build a new object given its prototype and an object to duplicates properties from."
            [ opt_arg "prototype" (abbrv "js_object" @@ arg 0) ;
              opt_arg "properties" (assoc (abbrv "property_descriptor") @@ rest ()) ]
            (call (jsglobal "Object.create"))
            (abbrv "js_object") ;
          def_function "define_property"
            ~doc:"Define a property from a name and its descriptor fields."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "prop" (string @@ arg 1) ;
              opt_arg "configurable" (bool @@ field (arg 2) "configurable") ;
              opt_arg "enumerable" (bool @@ field (arg 2) "enumerable") ;
              opt_arg "writable" (bool @@ field (arg 2) "writable") ;
              opt_arg "getter" (callback [] (abbrv "js_value") @@ field (arg 2) "get") ;
              opt_arg "setter" (callback [ curry_arg "new_value" (abbrv "js_value" @@ arg 0) ] void @@ field (arg 2) "set") ;              
              curry_arg "value" (abbrv "js_value" @@ field (arg 2) "value") ]
            (call (jsglobal "Object.defineProperty"))
            void ;
          def_function "define_property_from_descriptor"
            ~doc:"Define a property from a name and a specific descriptor."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "prop" (string @@ arg 1) ;
              curry_arg "descriptor" (abbrv "property_descriptor" @@ arg 2) ]
            (call (jsglobal "Object.defineProperty"))
            void ;
          def_function "define_properties_from_descriptors"
            ~doc:"Define properties from their names and specific descriptors."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              opt_arg "properties" (assoc (abbrv "property_descriptor") @@ rest ()) ]
            (call (jsglobal "Object.defineProperty"))
            void ;
          def_function "get_own_property_descriptor"
            ~doc:"Get the descriptor of a property defined by this object (and not one of its prototypes)."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "prop" (string @@ arg 1) ]
            (call (jsglobal "Object.getOwnPropertyDescriptor"))
            (option_undefined (abbrv "property_descriptor")) ;
          def_function "get_own_property_names"
            ~doc:"Get the names of all the properties that are defined by this object (and not one of its prototypes)."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.getOwnPropertyNames"))
            (list string) ;
          def_function "has_own_property"
            ~doc:"Tells if a property is defined by the object  (and not one of its prototypes)."
            [ curry_arg "obj" (abbrv "js_object" @@ this) ]
            (call_method "hasOwnProperty")
            bool ;
          def_function "keys"
            ~doc:"Get the names of all the properties that are defined by this object (and not inherited) and enumerable."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.keys"))
            (list string) ;
          def_function "get_prototype"
            ~doc:"Get the prototype of an object."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.getPrototypeOf"))
            (abbrv "js_object") ;
          def_function "set_prototype"
            ~doc:"Set the prototype of an object (N.B. it's a bad idea and it's slow)."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ;
              curry_arg "proto" (abbrv "js_object" @@ arg 1)]
            (call (jsglobal "Object.setPrototypeOf"))
            void ;
          def_function "is_prototype_of"
            ~doc:"Tells if this object is a prototype of another."
            [ curry_arg "obj" (abbrv "js_object" @@ this) ;
              curry_arg "son" (abbrv "js_object" @@ arg 0) ]
            (call_method "isPrototypeOf")
            bool ;
          def_function "prevent_extensions"
            ~doc:"Makes an object non extensible."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.preventExtensioms"))
            void ;
          def_function "seal"
            ~doc:"Makes an object non extensible, and its properties non configurable."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.seal"))
            void ;
          def_function "freeze"
            ~doc:"Makes an object non extensible, and its properties non configurable and immutable."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.freeze"))
            void ;
          def_function "is_extensible"
            ~doc:"Tell if an object is extensible (see {!prevent_extensions})."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.isExtensible"))
            bool ;
          def_function "is_sealed"
            ~doc:"Tell if an object is frozen (see {!seal})."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.isSealed"))
            bool ;
          def_function "is_frozen"
            ~doc:"Tell if an object is frozen (see {!freeze})."
            [ curry_arg "obj" (abbrv "js_object" @@ arg 0) ]
            (call (jsglobal "Object.isFrozen"))
            bool ;
        ]
      ] ;
      structure "js_date"
        ~doc:"Operations on JavaScript date objects." [

        section "Construction" [
          def_function "now"
            ~doc:"Create a date object with the current time."
            []
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

          def_function "create"
            ~doc:"Create a Date from components."
            [ labeled_arg "ymd" ~doc:"(year, month, day)."
                (tuple [ int @@ arg 0 ; int @@ arg 1 ; int @@ arg 2 ]) ;
              opt_arg "hmss" ~doc:"(hour, minute, second, millisecond)."
                (tuple [ int @@ arg 3 ; int @@ arg 4 ; int @@ arg 5 ; int @@ arg 6 ]) ]
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

        ] ;

        section "Conversions" [

          def_function "from_time_value"
            ~doc:"Create a Date from the number of milliseconds since 1 January 1970 00:00:00 UTC."
            [ curry_arg "stamp" (float @@ arg 0) ]
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

          def_function "to_time_value"
            ~doc:"Extract the number of milliseconds since 1 January 1970 00:00:00 UTC."
            [ curry_arg "date" (abbrv "js_date" @@ this) ]
            (call_method "getTime")
            float ;

          def_function "from_string"
            ~doc:"Create a Date from an RFC 2822 of ISO 8601 timestamp."
            [ curry_arg "stamp" (string @@ arg 0) ]
            (call_constructor (jsglobal "Date"))
            (abbrv "js_date") ;

          def_function "to_string"
            ~doc:"Builds the ISO 8601 string version of the date."
            [ curry_arg "date" (abbrv "js_date" @@ this) ]
            (call_method "toISOString")
            string ;

          def_function "to_human_string"
            ~doc:"Builds a human string version of the date."
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "toLocaleString")
               (call_method "toString"))
            string ;

          def_function "to_date_string"
            ~doc:"Builds a human readable string version of the date part (y,m,d)."
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "toLocaleDateString")
               (call_method "toDateString"))
            string ;

          def_function "to_time_string"
            ~doc:"Builds a human readable string version of the date part (h,m,s,ms)."
            [ opt_arg "use_locale" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "toLocaleTimeString")
               (call_method "toTimeString"))
            string ;

        ] ;

        section "Access" [

          def_function "time_zone_offset"
            ~doc:"Extract the time zone offset in minutes for the current locale."
            [ curry_arg "date" (abbrv "js_date" @@ this) ]
            (call_method "getTimezoneOffset")
            int ;

          def_function "year"
            ~doc:"Extract the full year from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCFullYear")
               (call_method "getFullYear"))
            int ;

          def_function "month"
            ~doc:"Extract the month (0-11) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCMonth")
               (call_method "getMonth"))
            int ;

          def_function "day"
            ~doc:"Extract the day of the month (1-31) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCDate")
               (call_method "getDate"))
            int ;

          def_function "day_of_the_week"
            ~doc:"Extract the day of the week (0-6) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCDay")
               (call_method "getDay"))
            int ;

          def_function "hour"
            ~doc:"Extract the hour (0-23) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCHours")
               (call_method "getHours"))
            int ;

          def_function "minute"
            ~doc:"Extract the minute (0-59) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCMinutes")
               (call_method "getMinutes"))
            int ;

          def_function "second"
            ~doc:"Extract the second (0-59) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCSeconds")
               (call_method "getSeconds"))
            int ;

          def_function "millisecond"
            ~doc:"Extract the millisecond (0-999) from a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ]
            (test Guard.(var "flag" = bool true)
               (call_method "getUTCMilliseconds")
               (call_method "getMilliseconds"))
            int ;

        ] ;

        section "Modification" [

          def_function "set_year"
            ~doc:"Set the full year of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCFullYear")
               (call_method "setFullYear"))
            void ;

          def_function "set_month"
            ~doc:"Set the month (0-11) of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCMonth")
               (call_method "setMonth"))
            void ;

          def_function "set_day"
            ~doc:"Set the day of the month (1-31) of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCDate")
               (call_method "setDate"))
            void ;

          def_function "set_hour"
            ~doc:"Set the hour (0-23) of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCHours")
               (call_method "setHours"))
            void ;

          def_function "set_minute"
            ~doc:"Set the minute (0-59) of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCMinutes")
               (call_method "setMinutes"))
            void ;

          def_function "set_second"
            ~doc:"Set the second (0-59) of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCSeconds")
               (call_method "setSeconds"))
            void ;

          def_function "set_millisecond"
            ~doc:"Set the millisecond (0-999) of a Date object."
            [ opt_arg "utc" (bool @@ var "flag") ;
              curry_arg "date" (abbrv "js_date" @@ this) ;
              curry_arg "v" (int @@ arg 1) ]
            (test Guard.(var "flag" = bool true)
               (call_method "setUTCMilliseconds")
               (call_method "setMilliseconds"))
            void ;
        ] ;
      ] ;

      structure "js_math"
        ~doc:"Predefined JavaScript Math functions." (
        let op0 n doc =
          def_function n ~doc []
            (call (field (jsglobal "Math") n))
            float
        and op1 n doc =
          def_function n ~doc
            [ curry_arg "x" (float @@ arg 0) ]
            (call (field (jsglobal "Math") n))
            float
        and op2 n doc =
          def_function n ~doc
            [ curry_arg "x" (float @@ arg 0) ;
              curry_arg "y" (float @@ arg 1) ]
            (call (field (jsglobal "Math") n))
            float
        and opn n doc =
          def_function n ~doc
            [ curry_arg "xs" (float @@ unroll ()) ]
            (call (field (jsglobal "Math") n))
            float
        and cst n doc =
          def_value (String.lowercase n) ~doc (get (field (jsglobal "Math") n)) float
        in [
          section "Constants" [
            cst "E" "Euler's constant and the base of natural logarithms, approximately 2.718" ;
            cst "LN2" "Natural logarithm of 2, approximately 0.693" ;
            cst "LN10" "Natural logarithm of 10, approximately 2.303" ;
            cst "LOG2E" "Base 2 logarithm of E, approximately 1.443" ;
            cst "LOG10E" "Base 10 logarithm of E, approximately 0.434" ;
            cst "PI" "Ratio of the circumference of a circle to its diameter, approximately 3.14159" ;
            cst "SQRT1_2" "Square root of 1/2; equivalently, 1 over the square root of 2, approximately 0.707" ;
            cst "SQRT2" "Square root of 2, approximately 1.414" ;
          ] ;
          section "Operations on numbers" [
            op1 "abs" "Returns the absolute value of a number" ;
            op1 "acos" "Returns the arccosine of a number" ;
            op1 "acosh" "(ES6) Returns the hyperbolic arccosine of a number" ;
            op1 "asin" "Returns the arcsine of a number" ;
            op1 "asinh" "(ES6) Returns the hyperbolic arcsine of a number" ;
            op1 "atan" "Returns the arctangent of a number" ;
            op1 "atanh" "(ES6) Returns the hyperbolic arctangent of a number" ;
            op2 "atan2" "Returns the arctangent of the quotient of its arguments" ;
            op1 "cbrt" "(ES6) Returns the cube root of a number" ;
            op1 "ceil" "Returns the smallest integer greater than or equal to a number" ;
            op1 "cos" "Returns the cosine of a number" ;
            op1 "cosh" "(ES6) Returns the hyperbolic cosine of a number" ;
            op1 "exp" "Returns Ex, where x is the argument, and E is Euler's constant (2.718...), the base of the natural logarithm" ;
            op1 "expm1" "(ES6) Returns subtracting 1 from exp(x)" ;
            op1 "floor" "Returns the largest integer less than or equal to a number" ;
            op1 "fround" "Returns the nearest single precision float representation of a number" ;
            opn "hypot" "Returns the square root of the sum of squares of its arguments" ;
            op1 "imul" "(ES6) Returns the result of a 32-bit integer multiplication" ;
            op1 "log" "Returns the natural logarithm of a number" ;
            op1 "log1p" "(ES6) Returns the natural logarithm of 1 + x of a number" ;
            op1 "log10" "(ES6) Returns the base 10 logarithm of x" ;
            op1 "log2" "(ES6) Returns the base 2 logarithm of x" ;
            opn "max" "Returns the largest of zero or more numbers" ;
            opn "min" "Returns the smallest of zero or more numbers" ;
            op2 "pow" "Returns base to the exponent power" ;
            op0 "random" "Returns a pseudo-random number between 0 and 1" ;
            op1 "round" "Returns the value of a number rounded to the nearest integer" ;
            op1 "sign" "(ES6) Returns the sign of the x, indicating whether x is positive, negative or zero" ;
            op1 "sin" "Returns the sine of a number" ;
            op1 "sinh" "(ES6) Returns the hyperbolic sine of a number" ;
            op1 "sqrt" "Returns the positive square root of a number" ;
            op1 "tan" "Returns the tangent of a number" ;
            op1 "tanh" "(ES6) Returns the hyperbolic tangent of a number" ;
            op1 "trunc" "(ES6) Returns the integral part of the number x, removing any fractional digits" ;
          ]
        ]) ;
      structure "js_regexp"
        ~doc:"Operations on JavaScript regular expressions." [
        def_function "create"
          ~doc:"Compile a regular expression."
          [ opt_arg "global" (bool @@ var "g_flag") ;
            opt_arg "multiline" (bool @@ var "m_flag") ;
            opt_arg "ignore_case" (bool @@ var "i_flag") ;
            opt_arg "sticky" (bool @@ var "y_flag") ;
            curry_arg "pattern" (string @@ arg 0) ]
          (seq [
              test' Guard.(var "g_flag" = bool true) (set_const (rest ~site:"cat" ()) (Const.string "g")) ;
              test' Guard.(var "m_flag" = bool true) (set_const (rest ~site:"cat" ()) (Const.string "m")) ;
              test' Guard.(var "i_flag" = bool true) (set_const (rest ~site:"cat" ()) (Const.string "i")) ;
              test' Guard.(var "y_flag" = bool true) (set_const (rest ~site:"cat" ()) (Const.string "y")) ;
              (abs "flags" (call ~site:"cat" (jsglobal "String.concat"))
                 (seq [ set (arg 1) (var "flags") ;
                        (call_constructor (jsglobal "Regexp")) ])) ])
          (abbrv "js_regexp") ;

        def_function "last_index"
          ~doc:"The index at which to start the next match."
          [ curry_arg "str" (string @@ this) ]
          (get (field this "lastIndex"))
          int ;

        def_function "find"
          ~doc:"Returns the matching position when successful."
          [ curry_arg "str" (string @@ this) ;
            curry_arg "pattern" (abbrv "js_regexp" @@ arg 0) ]
          (call_method "search")
          (Option (Guard.(var "root" = Const.int (-1)), int)) ;

        def_function "test"
          ~doc:"Tests if a string matches a regexp."
          [ curry_arg "pattern" (abbrv "js_regexp" @@ this) ;
            curry_arg "str" (string @@ arg 0) ]
          (call_method "test")
          bool ;

        def_function "exec"
          ~doc:"Returns the array on matched groups when successful \
                (index 0 contains the whole match)."
          [ curry_arg "pattern" (abbrv "js_regexp" @@ this) ;
            curry_arg "str" (string @@ arg 0) ]
          (call_method "exec")
          (nonempty_array_or_null string) ;

        def_function "replace"
          ~doc:"Returns the matching position when successful."
          [ curry_arg "str" (string @@ this) ;
            curry_arg ~doc:"the pattern to find and replace."
              "pattern" (abbrv "js_regexp" @@ arg 0)  ;
            curry_arg ~doc:"the replacement, in which \
                            [$&] is the matched substring, \
                            [$$] is a dollar sign, \
                            [$^] is the part of the original string before the match, \
                            [$'] the part after and \
                            [$n] the [n]th matched group."
              "replacement" (string @@ arg 1) ]
          (call_method "replace")
          string ;

        def_function "split"
          ~doc:"Splits a string using a regexp separator."
          [ curry_arg "str" (string @@ this) ;
            curry_arg "sep" (abbrv "js_regexp" @@ arg 0) ]
          (call_method "split")
          (array string) ;

      ] ;
      structure "TypedArray"
        ~doc:"(ES6) Monomorphic arrays." [
        def_type
          ~doc:"Generic typed arrays."
          "ta" (abstract any) ;
        def_type
          ~doc:"Typed array kinds."
          "ta_kind" (public (variant [
              constr ~doc:"Signed, 8-bit integers." "Int8" Guard.(root == jsglobal "Int8Array") [] ;
              constr ~doc:"Signed, 16-bit integers." "Int16" Guard.(root == jsglobal "Int16Array") [] ;
              constr ~doc:"Signed, 32-bit integers." "Int32" Guard.(root == jsglobal "Int32Array") [] ;
              constr ~doc:"Unsigned, 8-bit integers." "Uint8" Guard.(root == jsglobal "Uint8Array") [] ;
              constr ~doc:"Unsigned, 16-bit integers." "Uint16" Guard.(root == jsglobal "Uint16Array") [] ;
              constr ~doc:"Unsigned, 32-bit integers." "Uint32" Guard.(root == jsglobal "Uint32Array") [] ;
              constr ~doc:"32-bit floats." "Float32" Guard.(root == jsglobal "Float32Array") [] ;
              constr ~doc:"64-bit floats." "Float64" Guard.(root == jsglobal "Float64Array") [] ;
            ])) ;
        def_type
          ~doc:"Internal storage of typed arrays, a sequence of bytes \
                that can be shared between several typed arrays to have \
                different views over these bytes."
          "ta_buffer" (abstract any) ;
        section "Access and Modification" [
          def_function "length"
            ~doc:"The number of elements of a typed array."
            [ curry_arg "array" (abbrv "ta" @@ this) ]
            (get (field this "length"))
            int ;
          def_function "kind"
            ~doc:"The number of elements of a typed array."
            [ curry_arg "array" (abbrv "ta" @@ this) ]
            (get (field this "constructor"))
            (abbrv "ta_kind") ;
          def_function "get"
            ~doc:"Access the content of a cell in the typed array."
            [ curry_arg "array" (abbrv "ta" @@ var "a") ;
              curry_arg "index" (int @@ var "f") ]
            (get (acc (var "a") (var "f")))
            float ;
          def_function "set"
            ~doc:"Assigns the content of a cell in the typed array, \
                  converting the value according to the type of the array."
            [ curry_arg "array" (abbrv "ta" @@ var "a") ;
              curry_arg "index" (int @@ var "f") ;
              curry_arg "v" (float @@ var "v") ]
            (set (acc (var "a") (var "f")) (var "v"))
            void ;
          def_function "blit"
            ~doc:"Writes the contents of another array [at] an offset. \
                  Values are converted according to the type of the destination array."
            [ curry_arg "dst" (abbrv "ta" @@ this) ;
              opt_arg "at" (int @@ rest ()) ;
              curry_arg "src" (abbrv "ta" @@ arg 0) ]
            (call_method "set")
            void ;
          def_function "blit_floats"
            ~doc:"Writes a series of values [at] an offset. \
                  Floats are converted according to the type of the array."
            [ curry_arg "dst" (abbrv "ta" @@ this) ;
              opt_arg "at" (int @@ rest ()) ;
              curry_arg "src" (array float @@ arg 0) ]
            (call_method "set")
            void ;
          def_function "blit_ints"
            ~doc:"Writes a series of ints [at] an offset. \
                  Ints are converted according to the type of the array."
            [ curry_arg "dst" (abbrv "ta" @@ this) ;
              opt_arg "at" (int @@ rest ()) ;
              curry_arg "src" (array int @@ arg 0) ]
            (call_method "set")
            void ;
        ] ;
        section "Constructors" [
          def_function ("create_typed_array")
            ~doc:("Create a typed array of values of type [kind]")
            [ curry_arg "kind" (abbrv "ta_kind" @@ var "cstr") ;
              curry_arg "size" (int @@ arg 0) ]
            (call_constructor (var "cstr"))
            (abbrv "ta") ;
          def_function ("copy_typed_array")
            ~doc:("Create a typed array of values of type [kind] \
                   copying (and converting if necessary) the original values")
            [ curry_arg "kind" (abbrv "ta_kind" @@ var "cstr") ;
              curry_arg "original" (abbrv "ta" @@ arg 0) ]
            (call_constructor (var "cstr"))
            (abbrv "ta")
        ] ;
        section "Working with Buffers" [
          def_function "create_array_buffer"
            ~doc:"Builds a new byte array buffer, to be wrapped in typed arrays."
            [ curry_arg "len" (int @@ arg 0) ]
            (call_constructor (jsglobal "ArrayBuffer"))
            (abbrv "ta_buffer");
          def_function "array_buffer_length"
            ~doc:"Get the number of bytes of a byte array buffer."
            [ curry_arg "buf" (abbrv "ta_buffer" @@ this)]
            (get (field this "byteLength"))
            int ;
          def_function "get_array_buffer"
            ~doc:"Access the underlying byte array buffer of a typed array."
            [ curry_arg "array" (abbrv "ta" @@ this) ]
            (get (field this "buffer"))
            (abbrv "ta_buffer") ;
          def_function "get_array_buffer_offset"
            ~doc:"Access the offset in te underlying byte array buffer of a typed array."
            [ curry_arg "array" (abbrv "ta" @@ this) ]
            (get (field this "byteOffset"))
            int ;
          def_function "slice"
            ~doc:"Returns the sub array between [start] and [stop] (the end if not specified). \
                  This only creates a new view over the same buffer, so that the data are shared \
                  between the input array and the slice."
            [ curry_arg "dst" (abbrv "ta" @@ this) ;
              opt_arg "stop" (int @@ rest ()) ;
              curry_arg "start" (abbrv "ta" @@ arg 0) ]
            (call_method "subarray")
            void ;
          def_function ("create_typed_array_view")
            ~doc:("Create a typed array of values of type [kind] \
                   over an existing byte array buffer")
            [ curry_arg "kind" (abbrv "ta_kind" @@ var "cstr") ;
              curry_arg "buffer" (abbrv "ta_buffer" @@ arg 0) ]
            (call_constructor (var "cstr"))
            (abbrv "ta") ;
          def_function "create_typed_array_partial_view"
            ~doc:("Create a typed array of values of type [kind] \
                   over an existing byte array buffer. \
                   May fail with [Invalid_argument \"create_typed_array_partial_view\"] \
                   if [offset] is not aligned correctly of [length] is too big.")
            [ curry_arg "kind" (abbrv "ta_kind" @@ var "cstr") ;
              curry_arg "buffer" (abbrv "ta_buffer" @@ arg 0) ;
              curry_arg "offset" (int @@ arg 1)  ;
              curry_arg "length" (int @@ arg 2) ]
            (try_catch
               ~exns:[ Guard.(root == jsglobal "INDEX_SIZE_ERR"
                              || raise ("Invalid_argument \"create_typed_array_partial_view\"")), Const.undefined ]
               (call_constructor (var "cstr")))
            (abbrv "ta")
        ]
      ] ;
      structure "js_map"
        ~doc:"(ES6) JavaScript's attempt at a map structure." [
        def_type "map"
          ~tparams:["+'a"]
          ~doc:"JavaScript's attempt at a map structure, \
                accepts anything as keys, with polymorphic pointer equality for objects, \
                contents equality for strings and floats, except \
                that all NaN are considered equal."
          (abstract any) ;
        def_function "create"
          ~doc:"Build a new, empty map. Bindings are weak \
                references if [weak] is true ([false]  by default)."
          [ opt_arg "weak" (bool @@ var "weak_flag")]
          (test
             Guard.(var "weak_flag" = bool true)
             (call_constructor (jsglobal "WeakMap"))
             (call_constructor (jsglobal "Map")))
          (abbrv ~tparams:[param "'a"] "map") ;
        def_function "clear"
          ~doc:"Removes all bindings."
          [ curry_arg "map" (abbrv ~tparams:[param "'a"] "map" @@ this)]
          (call_method "clear")
          void ;
        def_function "has"
          ~doc:"Finds a specific binding."
          [ curry_arg "map" (abbrv ~tparams:[param "'a"] "map" @@ this) ;
            curry_arg "key" (param "'b" @@ arg 0) ]
          (call_method "has")
          bool ;
        def_function "get"
          ~doc:"Finds a specific binding."
          [ curry_arg "map" (abbrv ~tparams:[param "'a"] "map" @@ this) ;
            curry_arg "key" (param "'b" @@ arg 0) ]
          (call_method "get")
          (option_undefined (param "'a")) ;
        def_function "delete"
          ~doc:"Removes a specific binding."
          [ curry_arg "map" (abbrv ~tparams:[param "'a"] "map" @@ this) ;
            curry_arg "key" (param "'b" @@ arg 0) ]
          (call_method "delete")
          void ;
        def_function "delete"
          ~doc:"Removes a specific binding."
          [ curry_arg "map" (abbrv ~tparams:[param "'a"] "map" @@ this) ;
            curry_arg "key" (param "'b" @@ arg 0) ;
            curry_arg "v" (param "'a" @@ arg 1)]
          (call_method "set")
          void
      ]
    ]

let browser_component =
  register_component
    ~license:Goji_license.lgpl_v3
    ~doc:"Browser specific types and functions."
    browser_package "Browser" [
    structure "DOM"
      ~doc:"Operations on the document." [
      section "Types and Cercions" [ 

        def_type
          ~doc:"A specific type for element nodes (named markups in HTML)."
          "element" (abstract any) ;

        def_type
          ~doc:"A specific type for text nodes."
          "text" (abstract any) ;

        def_type
          ~doc:"A specific type for document nodes."
          "document" (abstract any) ;

        def_type
          ~doc:"A specific type for comment nodes."
          "comment" (abstract any) ;

        def_type
          ~doc:"A node in the document tree."
          "node"
          (public
             (variant
                (List.map
                   (fun n ->
                      let cap = (String.capitalize n) in
                      constr cap Guard.(root = obj cap) [ abbrv n ])
                   [ "element" ; "text" ; "document" ; "comment" ]))) ;

        group
          (List.map
             (fun n ->
                group [
                  def_function ("as_" ^ n)
                    ~doc:("Cast any node as some " ^ n
                          ^ " if possible, otherwise raise [Invalid_argument \"as_" ^ n ^ "\"]")
                    [ curry_arg "n" (abbrv "node" @@ var "tmp") ]
                    (test
                       Guard.(var "tmp" = obj (String.capitalize n)
                              || raise ("Invalid_argument \"as_" ^ n ^ "\""))
                       (get (var "tmp"))
                       (get (var "tmp")))
                    (abbrv n) ;
                  def_function (n ^ "_as_node")
                    ~doc:("Cast a specific " ^ n ^ " node as a generic node")
                    [ curry_arg "n" (abbrv n @@ var "tmp") ]
                    (get (var "tmp"))
                    (abbrv "node") ;
                ])
             [ "element" ; "text" ; "document" ; "comment" ]) ;

      ] ;

      section "Constructors" [

        def_value "document"
          ~doc:"Retrives the main document."
          (get (jsglobal "document"))
          (abbrv "document") ;

        def_function "create_element"
          ~doc:"Build a new element node from its tag (in the main document)."
          [ curry_arg "tag" (string @@ arg 0) ]
          (call_method ~sto:(jsglobal "document") "createElement")
          (abbrv "element") ;

        def_function "create_element_mode"
          ~doc:"Build a new element node from its tag (in the main document) \
                and returns it as a generic node."
          [ curry_arg "tag" (string @@ arg 0) ]
          (call_method ~sto:(jsglobal "document") "createElement")
          (abbrv "node") ;

        def_function "create_text"
          ~doc:"Build a new text node from its contents (in the main document)."
          [ curry_arg "tag" (string @@ arg 0) ]
          (call_method ~sto:(jsglobal "document") "createTextNode")
          (abbrv "text") ;

        def_function "create_text_node"
          ~doc:"Build a new text node from its contents (in the main document) \
                and returns it as a generic node."
          [ curry_arg "tag" (string @@ arg 0) ]
          (call_method ~sto:(jsglobal "document") "createTextNode")
          (abbrv "node") ;

      ] ;

      section "Node operations" [

        def_function "base_URI"
          [ curry_arg "node" (abbrv "node" @@ this) ]
          (get (field this "baseURI"))
          string ;

        map_method "node" "appendChild" ~rename:"append_child"
          ~doc:"Adds a new child to a node after its existing ones."
          [ curry_arg "child" (abbrv "node" @@ arg 0) ]
          void ;

        map_method "node" "removeChild" ~rename:"remove_child"
          ~doc:"Remove a child from its parent."
          [ curry_arg "child" (abbrv "node" @@ arg 0) ]
          void ;

        map_method "node" "replaceChild" ~rename:"replace_child"
          ~doc:"Replace a child from a parent node with another one."
          [ curry_arg "old_child" (abbrv "node" @@ arg 0) ;
            curry_arg "new_child" (abbrv "node" @@ arg 0) ]
          void ;

        def_method "node" "text_content"
          ~doc:"Retrieves the textual content of the node and its descendants."
          [] (get (field this "textContent")) string ;

        def_method "node" "children"
          ~doc:"Retrieves the current sequence of children of a node."
          [] (get (field this "childNodes")) (list (abbrv "node")) ;

        def_method "node" "parent"
          ~doc:"Retrieves the parent node of a node, if any."
          [] (get (field this "parentNode")) (option_null (abbrv "node")) ;

        def_method "node" "parent_element"
          ~doc:"Retrieves the parent element of a node, if any."
          [] (get (field this "parentElement")) (option_null (abbrv "element")) ;

        def_method "node" "owner_document"
          ~doc:"Retrieves the root of the document to which this node belongs, if any."
          [] (get (field this "ownerDocument")) (option_null (abbrv "document")) ;

        def_method "node" "has_child_nodes"
          ~doc:"Tells if a node is not empty."
          [] (call_method "hasChildNodes") (bool) ;

        def_method "node" "first_child"
          ~doc:"Retrieves the first child of a node, if any."
          [] (get (field this "firstChild")) (option_null (abbrv "node")) ;

        def_method "node" "last_child"
          ~doc:"Retrieves the last child of a node, if any."
          [] (get (field this "lastChild")) (option_null (abbrv "node")) ;

        def_method "node" "previous_sibling"
          ~doc:"Retrieves the previous sibling of a node, if any."
          [] (get (field this "previousSibling")) (option_null (abbrv "node")) ;

        def_method "node" "next_sibling"
          ~doc:"Retrieves the next sibling of a node, if any."
          [] (get (field this "nextSibling")) (option_null (abbrv "node")) ;

        def_method "node" "contains"
          ~doc:"Checks if the a node contains another one."
          [ curry_arg "desc" (abbrv "node" @@ arg 0) ]
          (call_method "contains")
          bool ;

        def_method "node" "equals"
          ~doc:"Equality between two nodes."
          [ curry_arg "node" (abbrv "node" @@ arg 0) ]
          (call_method "isEqualNode")
          bool ;

        def_method "node" "clone_node"
          ~doc:"Clones a node, recursively if [deep] is [true]."
          [ opt_arg "deep" (bool @@ arg 0) ]
          (call_method "cloneNode")
          (abbrv "node") ;

        def_method "node" "insert_before"
          ~doc:"Insert [sp1] before [sp2], where both must be children of [this]."
          [ curry_arg "sp1" (abbrv "node" @@ arg 0) ;
            curry_arg "sp2" (abbrv "node" @@ arg 1)]
          (call_method "insertBefore")
          void ;

        def_method "node" "insert_after"
          ~doc:"Insert [sp1] before [sp2], where both must be children of [this]."
          [ curry_arg "sp1" (abbrv "node" @@ arg 0) ;
            curry_arg "sp2" (abbrv "node" @@ var "tmp")]
          (seq [ set (arg 1) (field (var "tmp") "nextSibling") ;
                 call_method "insertBefore" ])
          void ;


        (* (* what to do with bitmasks ?? *)
        def_method "node" "compare_position"
          ~doc:"Checks if the a node contains another one."
          [ curry_arg "desc" (abbrv "node" @@ arg 0) ]
          (call_method "contains")
          bool ;
        *)
      ] ;

      section "Element operations" [

        def_function "get_element_by_id"
          ~doc:"Retrieve a DOM node from its ID in the main document."
          [ curry_arg "elt" (abbrv "element" @@ arg 0) ]
          (call (jsglobal "document.getElementById"))
          (option_null (abbrv "element")) ;

        def_function "get_elements_by_tag"
          ~doc:"Retrieve the list of nodes with a given tag."
          [ curry_arg "elt" (abbrv "element" @@ arg 0) ]
          (call (jsglobal "document.getElementsByTagName"))
          (list (abbrv "element")) ;

        def_function "get_elements_by_name"
          ~doc:"Retrieve the list of nodes with a given name attribute."
          [ curry_arg "elt" (abbrv "element" @@ arg 0) ]
          (call (jsglobal "document.getElementsByName"))
          (list (abbrv "element")) ;

        def_function "get_elements_by_class"
          ~doc:"Retrieve the list of nodes with a given CSS class attribute."
          [ curry_arg "elt" (abbrv "element" @@ arg 0) ]
          (call (jsglobal "document.getElementsByClassName"))
          (list (abbrv "element")) ;

        def_function "get_classes"
          ~doc:"Retrieve the list of CSS classes of an element."
          [ curry_arg "elt" (abbrv "element" @@ this) ]
          (get (field this "classList"))
          (list string) ;

        def_function "clear_classes"
          ~doc:"Resets the list of CSS classes of an element."
          [ curry_arg "elt" (abbrv "element" @@ this) ]
          (set_const (field this "className") (Const.string ""))
          void ;

        def_function "add_class"
          ~doc:"Adds a CSS class to an element."
          [ curry_arg "elt" (abbrv "element" @@ var "elt") ;
            curry_arg "cls" (string @@ arg 0) ]
          (call_method ~sto:(field (var "elt") "classList") "add")
          void ;

        def_function "has_class"
          ~doc:"Checks if an element has a CSS class."
          [ curry_arg "elt" (abbrv "element" @@ var "elt") ;
            curry_arg "cls" (string @@ arg 0) ]
          (call_method ~sto:(field (var "elt") "classList") "contains")
          bool ;

        def_function "remove_class"
          ~doc:"Removes a CSS class from an element."
          [ curry_arg "elt" (abbrv "element" @@ var "elt") ;
            curry_arg "cls" (string @@ arg 0) ]
          (call_method ~sto:(field (var "elt") "classList") "remove")
          void ;

        def_function "toggle_class"
          ~doc:"Toggles a CSS class from an element."
          [ curry_arg "elt" (abbrv "element" @@ var "elt") ;
            curry_arg "cls" (string @@ arg 0) ]
          (call_method ~sto:(field (var "elt") "classList") "toggle")
          void ;

      ] ;

    ]
  ]

