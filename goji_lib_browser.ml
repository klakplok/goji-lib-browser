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
        ~doc:"A generic type for JavaScript values"
        "any" (abstract any) ;
      section "Not for the casual user" [
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
      section "Operations on native JavaScript strings" [
        def_type "js_string" (abstract any) ;
        def_function "to_string"
          [ curry_arg "v" (abbrv "any" @@ var "tmp") ]
          (get (var "tmp"))
          string ;
        def_function "of_string"
          [ curry_arg "v" (string @@ var "tmp") ]
          (get (var "tmp"))
          (abbrv "any") ;
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
