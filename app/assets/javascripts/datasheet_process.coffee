# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SelectionArea = Vue.extend({
  template: '<div class="selection_area"></div>'
})

selectionDeepCopy = (selection) ->
  selectionCopy =
    active: selection.active
    datasheet: selection.datasheet
    page: selection.page
    canvasWidth: selection.canvasWidth
    x: selection.x
    y: selection.y
    width: selection.width
    height: selection.height
    orientation: selection.orientation
    headers: selection.headers
    position: selection.position
    backgroundColor: selection.backgroundColor
    borderColor: selection.borderColor

injectSelectionInIframe = (selection) ->
  canvasWrapperSelector = ".page[data-page-number=\"#{selection.page}\"] .canvasWrapper"
  $("#pdfIframe").contents().find(canvasWrapperSelector).append(
    # We use the pair x / y to generate a "unique" id
    """
    <div id="#{Math.floor(selection.x)}_#{Math.floor(selection.y)}" class="selection"
      style="#{selection.position}position:absolute;background-color:#{selection.backgroundColor};outline: 4px dashed #{selection.borderColor}; outline-offset:0px"
    ></div>
    """
  )

removeSelectionFromIframe = (selection) ->
  $("#pdfIframe").contents().find("##{Math.floor(selection.x)}_#{Math.floor(selection.y)}").remove()

Vue.component('selection-area', SelectionArea)

$(document).on "turbolinks:load", ->
  return unless $("#process_view").length > 0

  root = window.location.href.replace(/\/datasheet_process\/\?selection_id=\d/gi, "")

  # Vue data definition
  appData =
    alert: ""
    notice: ""
    modes: ["Selections", "Extracted Data"]
    currentMode: "Selections" # can be selections or data
    datasheet_selection_id: null
    datasheets: {}
    selectedDatasheet: null
    selections : []
    selectedSelection: null
    currentSelection:
      active: false
      datasheet: null
      page: null
      canvasWidth: null
      x: 0
      y: 0
      width: 0
      height: 0
      orientation: "horizontal"
      headers: false
      position: ""
      backgroundColor: ""
      borderColor: ""
    extractedData: []

  # Instanciating Vue
  datasheetCategoriesApp = new Vue({
    el: '#process_view'
    data: appData

    computed:
      pdfjsUrl: () ->
        if this.selectedDatasheet
          return root + "/pdfjs/minimal?file=" + this.selectedDatasheet.datasheet.pdfDatasheet.url
        return root + "/pdfjs/minimal?file=undefined"

      resultsCount: () ->
        this.extractedData.length

    methods:
      fetchDatasheets: () ->
          parsedUrl = new URL(window.location.href)
          this.datasheet_selection_id = parsedUrl.searchParams.get("selection_id")
          console.log(this.datasheet_selection_id)

          # Fetch parameters
          this.datasheetsUrl = root + "/datasheet_selections/" + this.datasheet_selection_id
          options =
            method: "GET"
            headers:
              "Accept": "application/json"

          vueInstance = this
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
              if Object.keys(appData.datasheets).length > 0
                console.log(Object.keys(appData.datasheets)[0])
                console.log(appData.datasheets[Object.keys(appData.datasheets)[0]])
                vueInstance.selectDatasheet(appData.datasheets[Object.keys(appData.datasheets)[0]])
            )

      switchMode: (mode) ->
        this.currentMode = mode

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

            appData.currentSelection.datasheet = appData.selectedDatasheet
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
              appData.currentSelection.backgroundColor = "rgb(255, 0, 0, 0.3)"
              appData.currentSelection.borderColor = "red"

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

              injectSelectionInIframe(appData.currentSelection)
          )

        $("#pdfIframe").contents().find("#viewer").mousemove(() ->
          $("#pdfIframe").contents().find(".textLayer").hide()
          )

        setTimeout(
          () -> (injectSelectionInIframe(selection)
          console.log(selection.page)) for selection in appData.selections,
          2000);

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

      viewSelection: (selectionToView) ->
        if this.selectedSelection
          this.selectedSelection.backgroundColor = "rgb(255, 0, 0, 0.3)"
          this.selectedSelection.borderColor = "red"
        this.selectedSelection = selectionToView
        selectionToView.backgroundColor = "rgb(0, 255, 0, 0.3)"
        selectionToView.borderColor = "green"
        # If we are on the right datasheet, the new colors will be loaded
        removeSelectionFromIframe(selection) for selection in this.selections
        injectSelectionInIframe(selection) for selection in this.selections

        # If a new datasheet is selected, the selections will be loaded with the right colors
        this.selectDatasheet(selectionToView.datasheet)

      deleteSelection: (selectionToDelete) ->
        checkSelection = (selection, i) ->
          if selection == selectionToDelete
            appData.selections.splice(i, 1)
        checkSelection(selection, i) for selection, i in appData.selections
        removeSelectionFromIframe(selectionToDelete)

      extractData: () ->
        this.alert = ""
        this.notice = ""
        datasheet.status = "waiting" for datasheet, id in appData.datasheets

        console.log(this.datasheets)
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
            orientation: selection.orientation
            headers: selection.headers
          )
        # Fetch parameters
        createSelectionOptions =
          method: "POST"
          headers:
            "Content-Type": "application/json"
            "Accept": "application/json"
          body: JSON.stringify(selectionsToSend)

        fetch(root + "/datasheet_process", createSelectionOptions)
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
        .then((json) ->
          console.log(json)
          appData.extractedData = json.materials
          # appData.datasheets[datasheetStatus.datasheet_id].status = datasheetStatus.status for datasheetStatus in json.datasheet_status
          )

      downloadCsv: () ->
        link = document.createElement('a');
        link.href = root + "/datasheet_process/download_csv?datasheet_selection_id=#{this.datasheet_selection_id}";
        link.click();

      saveToDatabase: () ->
        options =
          method: "POST"

        fetch(root + "/datasheet_process/save_to_database?datasheet_selection_id=#{this.datasheet_selection_id}", options)
        .catch((err) ->
          console.log("Connection error : " + err)
          appData.alert = "An error occured."
          throw Error("Connection error")
          )
        # Return a JSON promise
        .then((response) ->
          if response.ok
            appData.notice = "#{appData.extractedData.length} materials saved to database."
            console.log("Save OK")
          else
            []
          )

      ignoreMaterial: (materialToIgnore) ->
        options =
          method: "DELETE"

        fetch(root + "/datasheet_process/ignore_material?datasheet_selection_id=#{this.datasheet_selection_id}&material_name=#{materialToIgnore.name}", options)
        .catch((err) ->
          console.log("Connection error : " + err)
          throw Error("Connection error")
          )
        # Return a JSON promise
        .then((response) ->
          if response.ok
            checkMaterial = (material, i) ->
              if material == materialToIgnore
                appData.extractedData.splice(i, 1)
            checkMaterial(material, i) for material, i in appData.extractedData
            console.log("Material ignored")
          else
            []
          )


    mounted:
      () ->
        this.fetchDatasheets()
        this.setupAppCable()
  })
