class nocompile {
  file { "/test":
    require => File["/test2"],
  }

  file { "/test2":
    require => File["/test"],
  }
}
