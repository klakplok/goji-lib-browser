(* Published under the LGPL version 3
   Binding (c) 2013 Benjamin Canou *)

open Goji

let browser_package =
  register_package
    ~doc:"Basic JavaScript types and functions"
    ~version:"0.1"
    "browser"

let javascript_component =
  register_component
    ~license:Goji_license.lgpl_v3
    ~doc:"Basic JavaScript types and functions"
    browser_package "JavaScript"
    [ def_type
        ~doc:"Generic JavaScript values"
        "any" (abstract any) ;
      def_type
        ~doc:"Native JavaScript (immutable, UTF-16) strings"
        "js_string" (abstract any) ;
      def_type
        ~doc:"Regular Expressions"
        "regexp" (abstract any) ;

      structure "Obj"
        ~doc:"Not for the casual user" [
        def_type "t" (public (abbrv "any")) ;
        def_function "generic"
          ~doc:"Use any value as its generic JavaScript representation"
          [ curry_arg "v" (param "'a" @@ var "tmp")]
          (get (var "tmp"))
          (abbrv "any") ;
        def_function "coerce"
          ~doc:"Use any JavaScript value with any OCaml type (UNSAFE)"
          [ curry_arg "v" (abbrv "any" @@ var "tmp")]
          (get (var "tmp"))
          (param "'a") ;
      ] ;
      structure "js_string"
        ~doc:"Operations on native JavaScript strings" [
        def_type "t" (public (abbrv "js_string")) ;

        section "Construction" [

          def_function "to_string"
            ~doc:"Convert a native JavaScript UTF-16 string to an \
                  UTF-8 encoded OCaml string"
            [ curry_arg "str" (abbrv "js_string" @@ var "tmp") ]
            (get (var "tmp"))
            string ;
          def_function "of_string"
            ~doc:"Convert an OCaml string, expected to be UTF-8 encoded, \
                  to a native JavaScript UTF-16 string"
            [ curry_arg "str" (string @@ var "tmp") ]
            (get (var "tmp"))
            (abbrv "js_string") ;

          (* TODO: RangeError *)
          def_function "from_char_code"
            ~doc:"build a string from a single UTF-16 character code"
            [ curry_arg "code" (int @@ arg 0) ]
            (call (jsglobal "String.fromCharCode"))
            (abbrv "js_string") ;
          def_function "from_char_codes"
            ~doc:"build a string from a sequence of UTF-16 character codes"
            [ curry_arg "code" (list int @@ unroll ()) ]
            (call (jsglobal "String.fromCharCode"))
            (abbrv "js_string") ;

          def_function "from_code_point"
            ~doc:"build a string from a single UTF-32 code point"
            [ curry_arg "code" (int @@ arg 0) ]
            (call (jsglobal "String.fromCodePoint"))
            (abbrv "js_string") ;
          def_function "from_code_points"
            ~doc:"build a string from a sequence of UTF-32 code points"
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
            ~doc:"Repeats a string a given number of times."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "count" (int @@ arg 0) ]
            (call_method "repeat")
            (abbrv "js_string") ;

          def_function "slice"
            ~doc:"Takes a slice of a string between two indexes. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ;
              curry_arg "stop" (int @@ arg 1) ]
            (call_method "slice")
            (abbrv "js_string") ;

          def_function "slice_from"
            ~doc:"Takes a slice of a string between an index and the end. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ]
            (call_method "slice")
            (abbrv "js_string") ;

          def_function "sub"
            ~doc:"Takes a slice of a string from an index and up to a given size. \
                  Indexes larger than the length of the string are truncated. \
                  Negative indexes are interpreted as backward offsets from the end of the string. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "start" (int @@ arg 0) ;
              curry_arg "len" (int @@ arg 1) ]
            (call_method "substr")
            (abbrv "js_string") ;

          def_function "trim"
            ~doc:"Removes whitespace at both ends of the string. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "trim")
            (abbrv "js_string") ;

          def_function "lowercase"
            ~doc:"Transforms a string to lowercase. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "toLowerCase")
            (abbrv "js_string") ;

          def_function "uppercase"
            ~doc:"Transforms a string to uppercase. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "toUpperCase")
            (abbrv "js_string") ;

          def_function "locale_lowercase"
            ~doc:"Transforms a string to lowercase taking into account \
                  potential unicode overrides introduced by the current locale. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "toLocaleLowerCase")
            (abbrv "js_string") ;

          def_function "locale_uppercase"
            ~doc:"Transforms a string to uppercase taking into account \
                  potential unicode overrides introduced by the current locale. "
            [ curry_arg "str" (abbrv "js_string" @@ this) ]
            (call_method "toLocaleUpperCase")
            (abbrv "js_string") ;

        ] ;

        section "Access" [

          def_function "length"
            ~doc:"Number of UTF-16 characters in a native JavaScript string"
            [ curry_arg "str" ~doc:"The string" (abbrv "js_string" @@ var "obj") ]
            (get ((field (var "obj") "length")))
            int ;

          def_function "get_char_code"
            ~doc:"Access the UTF-16 characters of a native JavaScript string."
            [ curry_arg "str" ~doc:"The string" (abbrv "js_string" @@ this) ;
              curry_arg "nth" ~doc:"The position in the string starting from 0" (int @@ arg 0) ]
            (call_method "charCodeAt")
            int ;

          def_function "get_code_point"
            ~doc:"Access the UTF-32 characters of a native JavaScript string. \
                  Note that the index is still an UTF-16 index, this function \
                  just reads two UTF-16 chars to build a UTF-32 one when called \
                  on the first half of a surrogate pair."
            [ curry_arg "str" ~doc:"The string" (abbrv "js_string" @@ this) ;
              curry_arg "nth" ~doc:"The position in the string starting from 0" (int @@ arg 0) ]
            (call_method "codePointAt")
            int ;

        ] ;

        section "Search and Replace" [

          def_function "contains_from"
            ~doc:"Search for a substring starting at a given offset \
                  (0 if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "contains")
            bool ;

          def_function "ends_with"
            ~doc:"Determines if a substring is present and ends at \
                  a given position (or at the end if not specified)."
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              opt_arg "offset" (int @@ arg 1) ;
              curry_arg "sub" (abbrv "js_string" @@ arg 0) ]
            (call_method "endsWith")
            bool ;

          def_function "starts_with"
            ~doc:"Determines if a substring is present and starts at \
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

          def_function "index_of_regexp"
            ~doc:"Returns the matching position when successful"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "pattern" (abbrv "regexp" @@ arg 0) ]
            (call_method "search")
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

          def_function "match_regexp"
            ~doc:"Returns the array on matched groups when successful \
                  (index 0 contains the whole match)"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "pattern" (abbrv "regexp" @@ arg 0) ]
            (call_method "match")
            (nonempty_array_or_null (abbrv "js_string")) ;

          def_function "replace"
            ~doc:"Returns the matching position when successful"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg ~doc:"the substring to find and replace"
                "pattern" (abbrv "js_string" @@ arg 0)  ;
              curry_arg ~doc:"the replacement, in which \
                              [$&] is the matched substring, \
                              [$$] is a dollar sign, \
                              [$^] is the part of the original string before the match and \
                              [$'] the part after"
                "replacement" (abbrv "js_string" @@ arg 1) ]
            (call_method "replace")
            (abbrv "js_string") ;

          def_function "replace_regexp"
            ~doc:"Returns the matching position when successful"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg ~doc:"the pattern to find and replace"
                "pattern" (abbrv "regexp" @@ arg 0)  ;
              curry_arg ~doc:"the replacement, in which \
                              [$&] is the matched substring, \
                              [$$] is a dollar sign, \
                              [$^] is the part of the original string before the match, \
                              [$'] the part after and \
                              [$n] the [n]th matched group"
                "replacement" (abbrv "js_string" @@ arg 1) ]
            (call_method "replace")
            (abbrv "js_string") ;

          def_function "split"
            ~doc:"Splits a string using a separator"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "sep" (abbrv "js_string" @@ arg 0) ]
            (call_method "split")
            (array (abbrv "js_string")) ;

          def_function "split_regexp"
            ~doc:"Splits a string using a regexp separator"
            [ curry_arg "str" (abbrv "js_string" @@ this) ;
              curry_arg "sep" (abbrv "regexp" @@ arg 0) ]
            (call_method "split")
            (array (abbrv "js_string")) ;

        ] ;

        let locale_compare ~doc name usage =
          def_function name
            ~doc:"Search for a substring and return the position \
                  of its last occurence starting at a given offset \
                  (0 if not specified)."
            [ curry_arg "left" (abbrv "js_string" @@ this) ;
              opt_arg
              ~doc:"A list of BCP-47 language tags"
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
        in
        section "Comparison" [

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
        ]
      ]
    ]

let document_component =
  register_component
    ~license:Goji_license.lgpl_v3
    ~doc:"DOM (Document Object Model) types and functions"
    browser_package "Document"
    [ def_type
        ~doc:"The type of generic Dom nodes"
        "node" (abstract any) ;
      def_function "body"
        ~doc:"Retrives the body of the main document"
        []
        (get (jsglobal "document.body"))
        (abbrv "node") ;
      def_function "get_element_by_id"
        ~doc:"Retrieve a DOM node from its ID in the main document"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementById"))
        (option_null (abbrv "node")) ;
      def_function "get_elements_by_name"
        ~doc:"Retrieve the list of nodes with a given tag"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementsByTagName"))
        (list (abbrv "node")) ;
      def_function "get_elements_by_name"
        ~doc:"Retrieve the list of nodes with a given name attribute"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementsByName"))
        (list (abbrv "node")) ;
      def_function "get_elements_by_class"
        ~doc:"Retrieve the list of nodes with a given CSS class attribute"
        [ curry_arg "n" (abbrv "node" @@ arg 0) ]
        (call (jsglobal "document.getElementsByClassName"))
        (list (abbrv "node")) ;
      map_method "node" "appendChild" ~rename:"append"
        ~doc:"Adds a new child to a node after its existing ones."
        [ curry_arg "child" (abbrv "node" @@ arg 0) ]
        void ;
      def_function "create"
        ~doc:"Build a new node from its tag (in the main document)"
        [ curry_arg "tag" (string @@ arg 0) ]
        (call_method ~sto:(jsglobal "document") "createElement")
        (abbrv "node")
    ]
