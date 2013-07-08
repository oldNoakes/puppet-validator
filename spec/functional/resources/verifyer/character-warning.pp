class warning::unrecognized::char() {

  # Deliberate syntax failure
  file { "file":
    source => "foo\bar",
  }
}
