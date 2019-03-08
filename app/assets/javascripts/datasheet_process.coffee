# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SelectionArea = Vue.extend({
  # template: "<div class=\"selection_area\" v-bind:style=\"{left: xPos + 'px', top: yPos + 'px', width: width +'px', height: height + 'px'}\"></div>"
  template: '<div class="selection_area"></div>'
  # data: () ->
  #     selectionPosition: {left: this.x + 'px', top: this.y + 'px', width: this.width + 'px', height: this.height + 'px'}
})

selectionDeepCopy = (selection) ->
  selectionCopy =
    active: selection.active
    page: selection.page
    canvasWidth: selection.canvasWidth
    x: selection.x
    y: selection.y
    width: selection.width
    height: selection.height
    position: selection.position

injectSelectionInIframe = (page_number, selection_position) ->
  canvasWrapperSelector = ".page[data-page-number=\"#{page_number}\"] .canvasWrapper"
  $("#pdfIframe").contents().find(canvasWrapperSelector).append(
    '<div style="' + selection_position + 'position:absolute;background-color:rgb(255, 0, 0, 0.3);outline: 4px dashed red; outline-offset:0px"></div>'
  )

Vue.component('selection-area', SelectionArea)

$(document).on "turbolinks:load", ->
  return unless $("#process_view").length > 0

  # Vue data definition
  appData =
    datasheet_selection_id: null
    datasheets: {}
    selectedDatasheet: null
    selections : []
    currentSelection:
      active: false
      page: null
      canvasWidth: null
      x: 0
      y: 0
      width: 0
      height: 0
      position: ""

  # Instanciating Vue
  datasheetCategoriesApp = new Vue({
    el: '#process_view'
    data: appData

    computed:
      pdfjsUrl: () ->
        url = ""
        if this.selectedDatasheet
          url = "/pdfjs/minimal?file=" + this.selectedDatasheet.datasheet.pdfDatasheet.url
        url

    methods:
      fetchDatasheets: () ->
          parsedUrl = new URL(window.location.href)
          this.datasheet_selection_id = parsedUrl.searchParams.get("selection_id")
          console.log(this.datasheet_selection_id)

          # Fetch parameters
          this.datasheetsUrl = "/datasheet_selections/" + this.datasheet_selection_id
          options =
            method: "GET"
            headers:
              "Accept": "application/json"

          console.log("Fetching datasheets from : " + this.datasheetsUrl)
          fetch(this.datasheetsUrl, options)
          .catch((err) ->
            console.log("Connection error : " + err)
            throw Error("Connection error")
            )
          # Return a JSON promise
          .then((response) ->
            if response.ok
              response.json()
            else
              []
            )
          # Process the JSON response
          .then((json) ->
              # Add received datasheets to our appData
              Vue.set(
                appData.datasheets,
                datasheet.id,
                  datasheet: datasheet
                  status:'waiting'
                  selected: false
                  ) for datasheet in json
              console.log(appData.datasheets)
            )

      setupAppCable: () ->
        App.cable.subscriptions.create { channel: "ProcessChannel", datasheet_selection_id: appData.datasheet_selection_id },
          received: (data) ->
            console.log(data)
            appData.datasheets[data['datasheet_id']].status = data['status']

      selectDatasheet: (datasheet) ->
        if this.selectedDatasheet
          this.selectedDatasheet.selected = false
        datasheet.selected = true
        this.selectedDatasheet = datasheet


      setupPdfIframe: () ->
        vueInstance = this
        pageCanvas = []
        console.log("Iframe loaded")

        $("#pdfIframe").contents().find(".textLayer").hide()

        leftOffset = $("#pdfIframe").offset().left
        topOffset = $("#pdfIframe").offset().top

        $("#pdfIframe").contents().on(
          "mousedown",
          "canvas",
          (e) ->
            console.log(e.target.id)
            xPos = leftOffset + e.clientX
            yPos = topOffset + e.clientY

            appData.currentSelection.active = true
            pdfViewWidth = parseInt(e.target.style.width.match(/\d+/)[0])
            console.log(e.target)
            console.log("Canvas width :" + pdfViewWidth)
            appData.currentSelection.canvasWidth = parseInt(e.target.style.width.match(/\d+/)[0])

            appData.currentSelection.page = parseInt(e.target.id.match(/\d+/)[0])
            vueInstance.updateActiveSelection(xPos, yPos, 0, 0)

          )

        $("#pdfIframe").contents().on(
          "mousemove",
          "canvas",
          (e) ->
            if appData.currentSelection.active
              xPos = leftOffset + e.clientX
              yPos = topOffset + e.clientY

              vueInstance.updateActiveSelection(
                appData.currentSelection.x
                appData.currentSelection.y
                xPos - appData.currentSelection.x
                yPos - appData.currentSelection.y
              )
          )

        $("#pdfIframe").contents().on(
          "mouseup",
          "canvas",
          (e) ->
            if appData.currentSelection.active
              appData.currentSelection.active = false

              canvasWrapperSelector = ".page[data-page-number=\"#{appData.currentSelection.page}\"] .canvasWrapper"
              canvasLeftOffset = $("#pdfIframe").contents().find(canvasWrapperSelector).offset().left
              canvasTopOffset = $("#pdfIframe").contents().find(canvasWrapperSelector).offset().top

              xRelativeToCanvas = appData.currentSelection.x - leftOffset - canvasLeftOffset
              yRelativeToCanvas = appData.currentSelection.y - topOffset - canvasTopOffset
              vueInstance.updateActiveSelection(
                xRelativeToCanvas
                yRelativeToCanvas
                appData.currentSelection.width
                appData.currentSelection.height
              )

              appData.selections.push(
                  selectionDeepCopy(appData.currentSelection)
                )
              console.log(appData.selections)

              # viewerLeftOffset = $("#pdfIframe").contents().find("#viewer").offset().left
              # viewerTopOffset = $("#pdfIframe").contents().find("#viewer").offset().top

              console.log(appData.currentSelection)
              # $("#pdfIframe").contents().find("#viewer").append(
              #   '<div style="' + appData.currentSelection.position + 'position:absolute;background-color:rgb(255, 0, 0, 0.3);outline: 4px dashed red; outline-offset:0px"></div>'
              # )
              injectSelectionInIframe(appData.currentSelection.page, appData.currentSelection.position)
              # $("#pdfIframe").contents().find(canvasWrapperSelector).append(
              #   '<div style="' + appData.currentSelection.position + 'position:absolute;background-color:rgb(255, 0, 0, 0.3);outline: 4px dashed red; outline-offset:0px"></div>'
              # )
          )

        $("#pdfIframe").contents().find("#viewer").mousemove(() ->
          $("#pdfIframe").contents().find(".textLayer").hide()
          )
        setTimeout(
          () -> (injectSelectionInIframe(selection.page, selection.position)
          console.log(selection.page)) for selection in appData.selections,
          2000);


      selectionSize: (selection) ->
        selection.width + "x" + selection.height

      updateActiveSelection: (x, y, width, height) ->
        this.currentSelection.x = x
        this.currentSelection.y = y
        this.currentSelection.width = width
        this.currentSelection.height = height
        this.currentSelection.position =
          "left:" + x + "px;" + \
          "top:" + y + "px;" + \
          "width:" + width + "px;" + \
          "height:" + height + "px;"

      extractData: () ->
        selectionsToSend =
          datasheet_process:
            datasheet_selection_id: this.datasheet_selection_id
            selections: []
        for selection in this.selections
          selectionsToSend.datasheet_process.selections.push(
            datasheetId: this.selectedDatasheet.id
            page: selection.page
            canvasWidth: selection.canvasWidth
            x: selection.x
            y: selection.y
            width: selection.width
            height: selection.height
          )
        # Fetch parameters
        createSelectionOptions =
          method: "POST"
          headers:
            "Content-Type": "application/json"
            "Accept": "application/json"
          body: JSON.stringify(selectionsToSend)

        fetch("/datasheet_process", createSelectionOptions)
        .catch((err) ->
          console.log("Connection error : " + err)
          throw Error("Connection error")
          )
        # Return a JSON promise
        .then((response) ->
          if response.ok
            response.json()
          else
            []
          )



    mounted:
      () ->
        this.fetchDatasheets()
        this.setupAppCable()
  })
