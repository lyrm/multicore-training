module Actor = Actor_eio
module Queue = Saturn.Queue

let username = Sys.argv.(1)
let uri = try Some Sys.argv.(2) with _ -> None

let rec split acc job =
  let try_ f else_ =
    match f job with
    | Some (j1, j2) ->
        let acc = split acc j1 in
        split acc j2
    | None -> else_ ()
  in
  try_ Actor.hsplit @@ fun () ->
  try_ Actor.vsplit @@ fun () -> job :: acc

let () =
  Eio_main.run @@ fun env ->
  let client = Actor.client ?uri ~username env in
  while true do
    let sub = Actor.request client in
    let jobs =
      split 7 sub
      |> List.map (fun sub () ->
             let img = Actor.render sub in
             Actor.respond client img)
    in
    let domains = List.map Domain.spawn jobs in
    let _ : unit list = List.map Domain.join domains in
    ()
  done

let rec split sub n =
  if n = 0 then [ sub ]
  else
    match if Random.bool () then Actor.hsplit sub else Actor.vsplit sub with
    | Some (left, right) ->
        let n = n - 1 in
        split left n @ split right n
    | None -> [ sub ]

let () =
  Eio_main.run @@ fun env ->
  let client = Actor.client ?uri ~username env in
  let queue = Queue.create () in
  while true do
    match Queue.pop_opt queue with
    | Some job ->
        let img = Actor.render job in
        Actor.respond client img
    | None ->
        let job = Actor.request client in
        let parts = split job 3 in
        List.iter (Queue.push queue) parts
  done
