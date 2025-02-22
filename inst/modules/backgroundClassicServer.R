theBackgroundPath <- reactiveVal()
theBackground <- reactiveVal()
bookmarkExclude <- c(bookmarkExclude, "backgroundFile", "saveBackground",
                     "ghostButton", "computeBackground", "toggleBackground")

# Toggle panel
observeEvent(input$toggleBackground, {
  if ("backgroundPanel" %in% input$main) {
    updateCollapse(session, "main", close = "backgroundPanel")
  } else {
    updateCollapse(session, "main", open = "backgroundPanel")
    theActive("background")
  }
})

# Load background
shinyFileChoose(input, "backgroundFile", roots = getVolumes())

observeEvent(input$backgroundFile, {
  path <- parseFilePaths(roots = getVolumes(), input$backgroundFile)
  if (nrow(path) > 0) {
    isolate({ theBookmarks$backgroundPath <- path$datapath })
  }
})

observeEvent(theBookmarks$backgroundPath, {
  toCheck <- tryCatch(Rvision::image(theBookmarks$backgroundPath),
                      error = function(e) NA)

  if (isImage(toCheck)) {
    theBackground(Rvision::changeColorSpace(toCheck, "BGR"))
  }
})

# Compute background
observe({
  if (input$computeBackground > 0) {
    isolate({
      theBackground(backgrounderClassic(theVideo(), n = input$backroundImages,
                                        method = input$backgroundType))
    })
  }
})

output$backgroundStatus <- renderUI({
  if (isImage(theBackground())) {
    p("Background loaded.", class = "good")
  } else {
    p("Background missing (and required).", class = "bad")
  }
})

# Display background
observe({
  if (theActive() == "background") {
    if (isImage(theBackground())) {
      if (is.null(input$videoSize)) {
        display(theBackground(), "trackR", 25,
                nrow(theBackground()),
                ncol(theBackground()))
      } else {
        display(resize(theBackground(), fx = input$videoQuality, fy = input$videoQuality,
                       interpolation = "area"),
                "trackR", 25,
                nrow(theBackground()) * input$videoSize,
                ncol(theBackground()) * input$videoSize)
      }
    } else {
      if (is.null(input$videoSize)) {
        display(image(array(0, dim = c(640, 480, 3))), "trackR", 25, 480, 640)
      } else {
        display(image(array(0, dim = c(ncol(theImage()), nrow(theImage()), 3))),
                "trackR", 25,
                nrow(theImage()) * input$videoSize,
                ncol(theImage()) * input$videoSize)
      }
    }
  }
})

# Remove ghosts
observe({
  if (input$ghostButton > 0) {
    isolate({
      if (is.null(input$videoSize)) {
        ROI <- selectROI(theBackground(), "trackR", 1, TRUE)
      } else {
        ROI <- selectROI(theBackground(), "trackR", input$videoSize, TRUE)
      }

      theBackground(inpaint(theBackground(), ROI$mask, method = "Telea"))
    })
  }
})

# Save background
shinyFileSave(input, "saveBackground", roots = getVolumes())

observeEvent(input$saveBackground, {
  path <- parseSavePath(roots = getVolumes(), input$saveBackground)
  isolate({
    if (isImage(theBackground()) & nrow(path) > 0) {
      write.Image(theBackground(), path$datapath)
      isolate({ theBookmarks$backgroundPath <- path$datapath })
    }
  })
})
