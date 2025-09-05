workspace {
  !docs docs
  model {

  }

  views {
    styles {
      element "database" {
        shape cylinder
        background #3366cc
        color #ffffff
      }

      element "cache" {
        shape pipe
        background #cc0000
        color #ffffff
      }

      element "thirdparty" {
        background #eeeeee
        color #000000
        shape folder
      }

      element "web" {
        shape webbrowser
        background #1e90ff
        color #ffffff
      }

      element "backend" {
        shape roundedbox
        background #4caf50
        color #ffffff
      }

      element "broker" {
        shape pipe
        background #ff9900
        color #000000
      }
    }

    theme default
  }
}