class missing::template {
  file { "/no/file/template":
    content => template("missing/source.erb")
  }
}
