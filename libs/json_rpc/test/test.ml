let () =
  Alcotest.run "Json_rpc"
    [ ("request", Test_request.test_request)
    ; ("notification", Test_notification.test_notification) ]
