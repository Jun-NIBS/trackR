theSuccess <- reactiveVal(FALSE)
bookmarkExclude <- c(bookmarkExclude, "toggleTracking", "computeTracks")

# Toggle panel
observeEvent(input$toggleTracking, {
  if ("trackingPanel" %in% input$main) {
    updateCollapse(session, "main", close = "trackingPanel")
  } else {
    updateCollapse(session, "main", open = "trackingPanel")
    theActive("tracking")
  }
})

observe({
  if (isVideo(theVideo())) {
    enable("computeTracks")
  } else {
    disable("computeTracks")
  }
})

output$trackingVideoStatus <- renderUI({
  if (!isVideo(theVideo())) {
    p("Video missing (and required).", class = "bad")
  }
})

# Run tracking
observeEvent(input$computeTracks, {
  isolate({
    out <- pipelineTracktor(theVideo(), input$rangePos[1], input$rangePos[2],
                            theMask(), input$blobBlur,
                            input$blobThreshold, input$blobSize[1],
                            input$blobSize[2], input$lookBack, input$maxDist,
                            theBlobSizes, TRUE, input$showTracks,
                            input$videoQuality, input$videoSize)
    write_csv(out, paste0(sub(basename(theBookmarks$videoPath), "", theBookmarks$videoPath), "tracks.csv"))
    theSuccess(TRUE)
  })
})

output$trackingStatus <- renderUI({
  if (theSuccess()) {
    isolate({ p(paste0("Tracks saved in ", sub(basename(theBookmarks$videoPath), "", theBookmarks$videoPath), "tracks.csv"), class = "good") })
  }
})
