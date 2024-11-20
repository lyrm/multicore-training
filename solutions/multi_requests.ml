let username = Sys.argv.(1)
let uri = try Some Sys.argv.(2) with _ -> None

let do_one client () =
  let sub = Actor.request client in
  let img = Actor.render sub in
  Actor.respond client img

let with_fibers () =
  Eio_main.run @@ fun env ->
  let client = Actor.client ?uri ~username env in
  while true do
    let do_ = do_one client in
    Eio.Fiber.all [ do_; do_; do_ ]
  done

let with_domain_manager () =
  Eio_main.run @@ fun env ->
  let dom_man = Eio.Stdenv.domain_mgr env in
  let do_in_other_domain client () =
    Eio.Domain_manager.run dom_man (do_one client)
  in
  let client = Actor.client ?uri ~username env in
  while true do
    Eio.Fiber.all
      [
        do_in_other_domain client;
        do_in_other_domain client;
        do_in_other_domain client;
      ]
  done

let () =
  ignore with_fibers;
  ignore with_domain_manager;
  with_domain_manager ()
