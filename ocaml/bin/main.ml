open Lwt.Syntax
open Cohttp_lwt_unix


let fetch_url url =
  Lwt.catch
    (fun () ->
      Printf.printf "Fetching URL: %s\n%!" url;
      let* (_resp, body) = Client.get (Uri.of_string url) in
      let* body_string = Cohttp_lwt.Body.to_string body in
      Printf.printf "Successfully fetched %d bytes\n%!" (String.length body_string);
      Lwt.return (Some body_string))
    (fun exn -> 
      Printf.printf "Error fetching URL: %s\n%!" (Printexc.to_string exn);
      Lwt.return None)

let handler _conn req _body =
  let uri = Cohttp.Request.uri req in
  let query = Uri.query uri in
  let get_param name = 
    match List.assoc_opt name query with
    | Some (value :: _) -> value
    | _ -> ""
  in
  let keyword = get_param "keyword" in
  let target = get_param "target" in
  Printf.printf "Received keyword='%s', target='%s'\n%!" keyword target;
  
  let* found = 
    if keyword <> "" && target <> "" then
      let* body_opt = fetch_url target in
      match body_opt with
      | Some body ->
          let contains = try
            let _ = Str.search_forward (Str.regexp_string keyword) body 0 in
            true
          with Not_found -> false in
          let found_str = if contains then "true" else "false" in
          Printf.printf "found=%s, keyword=%s, uri=%s\n%!" found_str keyword target;
          Lwt.return found_str
      | None ->
          Printf.printf "Error fetching %s\n%!" target;
          Lwt.return "false"
    else
      Lwt.return "false"
  in
  Server.respond_string ~status:`OK ~body:found ()

let start_server port =
  let callback _conn req body =
    handler _conn req body
  in
  let server = Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ()) in
  Printf.printf "listening on 0.0.0.0:%d\n" port;
  server

let () =
  Lwt_main.run (start_server 31337)