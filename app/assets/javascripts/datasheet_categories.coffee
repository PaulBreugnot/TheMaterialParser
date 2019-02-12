# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root_url = "http://localhost:3000/"

appData =
  alert: null
  datasheets: []
  selectedCategory: null
  fileOk: false
  datasheetsUrl: ""

window.onload = () ->

  datasheetCategoriesApp = new Vue({
    el: '#main_view',
    data: appData,
    methods: {
      checkUpload : (e) ->
        console.log("Hello Check")
        valid = false
        if !this.selectedCategory
          this.alert = "Please select a category before uploading the datasheet."
        else if !this.fileOk
          this.alert = "Please select a file to upload."
        else
          this.alert = null
          valid = true
        if !valid then e.preventDefault()
        valid

      validateFile: () ->
          this.fileOk = true

      # Fetch group datasheets
      fetchDatasheets: () ->
        # Clear Alerts
        this.alert = null
        # Returns a JSON promise
        this.datasheetsUrl = "datasheet_categories/" + this.selectedCategory + "/datasheets"
        this.datasheets = []
        options =
          method: "GET"
          headers:
            "Content-Type": "application/json"

        console.log(this.datasheetsUrl)
        fetch(this.datasheetsUrl, options)
        .catch((err) ->
          console.log("Connection error : " + err)
          throw Error("Connection error")
          )
        .then((response) ->
          if response.ok
            response.json()
          else
            []
          )
        .then((json) ->
            appData.datasheets.push(datasheet) for datasheet in json
          )
    }
  })
