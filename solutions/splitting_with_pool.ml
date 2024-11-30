let username = Sys.argv.(1)
let uri = try Some Sys.argv.(2) with _ -> None

let split_in i job =
  let split j =
    match Actor.hsplit j with Some _ as r -> r | None -> Actor.vsplit j
  in
  let queue = Queue.create () in
  Queue.add job queue;
  for _ = 0 to i do
    let j = Queue.pop queue in
    match split j with
    | None -> Queue.add j queue
    | Some (j1, j2) ->
        Queue.add j1 queue;
        Queue.add j2 queue
  done;
  Queue.fold (fun acc x -> x :: acc) [] queue

let () =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  let dom_man = Eio.Stdenv.domain_mgr env in
  let pool = Eio.Executor_pool.create ~sw ~domain_count:7 dom_man in
  let client = Actor.client ?uri ~username env in
  while true do
    let sub = Actor.request client in
    let jobs =
      split_in 7 sub
      |> List.map (fun sub () ->
             Eio.Executor_pool.submit_exn pool ~weight:1.0 @@ fun () ->
             let img = Actor.render sub in
             Actor.respond client img)
    in
    Eio.Fiber.all jobs
  done
