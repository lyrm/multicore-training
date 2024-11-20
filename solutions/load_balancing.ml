module Queue = Saturn.Queue

let username = Sys.argv.(1)
let uri = try Some Sys.argv.(2) with _ -> None

let rec split ?(max_depth = -1) acc job =
  let hvsplit j =
    match Actor.hsplit j with Some _ as v -> v | None -> Actor.vsplit j
  in
  match (hvsplit job, max_depth) with
  | Some (j1, j2), i when i != 0 ->
      let acc = split ~max_depth:(i - 1) acc j1 in
      split ~max_depth:(i - 1) acc j2
  | _ -> job :: acc

let with_executor_pool ~max_depth =
  Eio_main.run @@ fun env ->
  Eio.Switch.run @@ fun sw ->
  let dom_mgr = Eio.Stdenv.domain_mgr env in
  let pool = Eio.Executor_pool.create ~sw ~domain_count:7 dom_mgr in
  let client = Actor.client ?uri ~username env in
  while true do
    let sub = Actor.request client in
    let jobs =
      split ?max_depth [] sub
      |> List.map (fun sub () ->
             Eio.Executor_pool.submit_exn pool ~weight:1.0 @@ fun () ->
             let img = Actor.render sub in
             Actor.respond client img)
    in
    Eio.Fiber.all jobs
  done

let with_saturn_queue ~max_depth =
  Eio_main.run @@ fun env ->
  let dom_mgr = Eio.Stdenv.domain_mgr env in
  let queue = Queue.create () in
  let client = Actor.client ?uri ~username env in
  let refill () =
    let job = Actor.request client in
    let parts = split ?max_depth [] job in
    List.iter (Queue.push queue) parts
  in
  refill ();
  let do_ () =
    while true do
      match Queue.pop_opt queue with
      | Some job ->
          let img = Actor.render job in
          Actor.respond client img
      | None -> refill ()
    done
  in
  let domains = List.init 8 (fun _ () -> Eio.Domain_manager.run dom_mgr do_) in
  Eio.Fiber.all domains

let () =
  ignore with_executor_pool;
  ignore with_saturn_queue;
  with_saturn_queue ~max_depth:(Some 5)
