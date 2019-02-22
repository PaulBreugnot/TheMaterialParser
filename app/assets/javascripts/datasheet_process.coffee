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
    ratio: selection.ratio
    x: selection.x
    y: selection.y
    width: selection.width
    height: selection.height
    position: selection.position

Vue.component('selection-area', SelectionArea)

$(document).on "turbolinks:load", ->
  return unless $("#process_view").length > 0

  # Vue data definition
  appData =
    datasheets: []
    selectedDatasheet: null
    selections : []
    currentSelection:
      active: false
      page: null
      ratio: 0
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
          url = "/pdfjs/minimal?file=" + this.selectedDatasheet.pdfDatasheet.url
        url

    methods:
      fetchDatasheets: () ->
          parsedUrl = new URL(window.location.href)
          selection_id = parsedUrl.searchParams.get("selection_id")
          console.log(selection_id)

          # Fetch parameters
          this.datasheetsUrl = "/datasheet_selections/" + selection_id
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
              appData.datasheets.push(
                  datasheet
                  ) for datasheet in json
            )

      selectDatasheet: (datasheet) ->
        this.selectedDatasheet = datasheet


      setupPdfIframe: () ->
        vueInstance = this
        pageCanvas = []
        console.log("Iframe loaded")

        $("#pdfIframe").contents().find(".textLayer").hide()

        console.log($("#pdfIframe").offset())
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
            appData.currentSelection.ratio =
              # Real pdf width / pdf canvas width
              e.target.width / pdfViewWidth

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
              appData.selections.push(
                # Current selection deep clone
                selectionDeepCopy(appData.currentSelection)
                )
              console.log(appData.selections)

              viewerLeftOffset = $("#pdfIframe").contents().find("#viewer").offset().left
              viewerTopOffset = $("#pdfIframe").contents().find("#viewer").offset().top

              vueInstance.updateActiveSelection(
                appData.currentSelection.x - leftOffset - viewerLeftOffset - 9
                appData.currentSelection.y - topOffset - viewerTopOffset - 9
                appData.currentSelection.width
                appData.currentSelection.height
              )
              $("#pdfIframe").contents().find("#viewer").append(
                '<div style="' + appData.currentSelection.position + 'position:absolute;background-color:rgb(255, 0, 0, 0.3);border-style:dashed;border-color:red;"></div>'
              )
          )

        $("#pdfIframe").contents().find("#viewer").mousemove(() ->
          $("#pdfIframe").contents().find(".textLayer").hide()
          )

      selectionSize: (selection) ->
        selection.width * selection.ratio + "x" + selection.height * selection.ratio

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



    mounted:
      () -> this.fetchDatasheets()
  })