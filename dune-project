(lang dune 3.15)

(name ray_tracer)

(generate_opam_files true)

(source
 (github ocaml-multicore/fun-ocaml-workshop))

(authors "Vesa Karvonen" "Carine Morel" "Arthur Wendling")

(maintainers "Vesa Karvonen" "Carine Morel" "Arthur Wendling")

(license MIT)

(package
 (name ray_tracer)
 (synopsis "Ray tracer in OCaml")
 (description
  "Inspired by the Ray Tracing In One Weekend tutorial (https://raytracing.github.io/books/RayTracingInOneWeekend.html).")
 (depends
  (ocaml
   (>= 5.2))
  (graphics
   (>= 5.1.2))
  (ppx_deriving_yojson
   (>= 3.7.0))
  (saturn
   (>= 0.5.0))))

(package
 (name multicore_workshop)
 (synopsis "Multicore Workshop")
 (depends
  (dream
   (>= 1.0.0~alpha6))
  (js_of_ocaml
   (>= 5.8.2))
  (brr
   (>= 0.0.6))
  (color
   (= 0.2.0))
  (ppx_blob
   (>= 0.8.0))
  (tyxml
   (>= 4.6.0))
  (cohttp-eio
   (>= 6.0.0~beta2))
  (saturn
   (and
    (>= 0.5.0)))
  (eio_main
   (and
    (>= 1.1.0)))
  (cohttp
   (>= 6.0.0~beta2))
  (imagelib
   (>= 20221222))
  (base64
   (>= 3.5.1))
  (uri
   (>= 4.4.0))
  (yojson
   (>= 2.0.0))
  (ppx_deriving_yojson
   (>= 3.7.0))))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
