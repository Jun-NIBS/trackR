bsCollapsePanel(
  title = actionLink("toggleBackground", "Background"),
  value = "backgroundPanel",
  htmlOutput("backgroundStatus", container = p, class = "good"),
  fluidRow(
    column(width = 6, shinyFilesButton("backgroundFile", "Select background file or...",
                                       "Please select a background image", FALSE, class = "fullWidth")),
    column(width = 6, actionButton("computeBackground", "...Estimate background", width = "100%"))),
  sliderInput("backroundImages", "Number of frames:", min = 1, max = 200,
              value = 100, width = "100%"),
  selectInput("backgroundType", "Type:",
              choices = c("Objects darker than background" = "darker",
                          "Objects lighter than background" = "lighter"), width = "100%"),

  hr(),

  fluidRow(
    column(width = 6, actionButton("ghostButton", "Select ghost for removal", width = "100%")),
    column(width = 6, shinySaveButton("saveBackground", "Save background file", "Save background as...",
                                      filetype = list(picture = c("png", "jpg")),
                                      class = "fullWidth")))
)
