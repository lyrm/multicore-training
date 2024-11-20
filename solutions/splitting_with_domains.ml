let username = Sys.argv.(1)
let uri = try Some Sys.argv.(2) with _ -> None

let split_in i job =
  let split j =
    match Actor.hsplit j with Some _ as r -> r | None -> Actor.vsplit j
  in
  let queue = Queue.create () in
  Queue.add job queue;
  for _ = 1 to i - 1 do
    let job = Queue.pop queue in
    match split job with
    | None -> Queue.add job queue
    | Some (j1, j2) ->
        Queue.add j1 queue;
        Queue.add j2 queue
  done;
  Queue.fold (fun acc x -> x :: acc) [] queue

(* let with_domains () = *)
(*   Eio_main.run @@ fun env -> *)
(*   let client = Actor.client ?uri ~username env in *)
(*   while true do *)
(*     let sub = Actor.request client in *)
(*     let jobs = *)
(*       split_in 7 sub *)
(*       |> List.map (fun sub () -> *)
(*              let img = Actor.render sub in *)
(*              Actor.respond client img) *)
(*     in *)
(*     let domains = List.map Domain.spawn jobs in *)
(*     List.iter Domain.join domains *)
(*   done *)

let with_domain_manager () =
  Eio_main.run @@ fun env ->
  let dom_man = Eio.Stdenv.domain_mgr env in
  let client = Actor.client ?uri ~username env in
  while true do
    Actor.request client |> split_in 7
    |> List.map (fun sub () ->
           Eio.Domain_manager.run dom_man @@ fun () ->
           let img = Actor.render sub in
           Actor.respond client img)
    |> Eio.Fiber.all
  done

let () =
  (* ignore with_domains; *)
  ignore with_domain_manager;
  with_domain_manager ()
