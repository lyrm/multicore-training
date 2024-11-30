let username = Sys.argv.(1)
let uri = try Some Sys.argv.(2) with _ -> None

let () =
  Eio_main.run @@ fun env ->
  let client = Actor.client ?uri ~username env in
  while true do
    (* Replace me with the actual implementation! *)
    ignore client
  done
