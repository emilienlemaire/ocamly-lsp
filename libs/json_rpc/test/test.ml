let () =
  Alcotest.run "Json_rpc"
    [ ("request", Test_request.test_request)
    ; ("notification", Test_notification.test_notification)
    ; ("response", Test_response.test_response)
    ; ("error", Test_error.test_error) ]
