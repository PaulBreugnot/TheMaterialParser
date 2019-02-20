# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  return unless $("#process_view").length > 0

  # Vue data definition
  appData =
    datasheets: []
    selectedDatasheet: null

  # Instanciating Vue
  datasheetCategoriesApp = new Vue({
    el: '#process_view'
    data: appData

    computed:
      pdfjsUrl: () ->
        "/pdfjs/minimal?file=" + this.selectedDatasheet.pdfDatasheet.url

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

    mounted:
      () -> this.fetchDatasheets()
  })
