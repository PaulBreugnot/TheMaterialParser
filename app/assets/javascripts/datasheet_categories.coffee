# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root_url = "http://localhost:3000/"

appData =
  alert: null # Alert message in case of trouble from client side
  datasheetItems: [] # { datasheet: fetched_datasheet, selected: is_the_datasheet_selected?}
  allSelected: null # Global selection checkbox status
  selectedCategory: null # Pointer to the selected category ("select" box)
  fileOk: false # true if a file is selected
  datasheetsUrl: "" # URL generated from the selectedCategory to fetch corresponding datasheets

window.onload = () ->

  datasheetCategoriesApp = new Vue({
    el: '#main_view',
    data: appData,
    methods: {
      # Called on submit action
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
        # Prevent from upload
        if !valid then e.preventDefault()
        valid

      # Called on file selected
      validateFile: () ->
          this.fileOk = true

      # Fetch group datasheets
      fetchDatasheets: () ->
        # Clear Alerts
        this.alert = null
        this.datasheetsUrl = "datasheet_categories/" + this.selectedCategory + "/datasheets"
        this.datasheetItems = []
        options =
          method: "GET"
          headers:
            "Content-Type": "application/json"

        console.log("Fetching datasheets from : " + this.datasheetsUrl)
        fetch(this.datasheetsUrl, options)
        .catch((err) ->
          console.log("Connection error : " + err)
          throw Error("Connection error")
          )
        # Returns a JSON promise
        .then((response) ->
          if response.ok
            response.json()
          else
            []
          )
        # Process the JSON response
        .then((json) ->
            appData.datasheetItems.push(
                datasheet: datasheet
                selected: false
                ) for datasheet in json
          )

      # Called on global checkbox action
      selectAll: () ->
        datasheetItem.selected = this.allSelected for datasheetItem in this.datasheetItems

      # Used to print dates in the table
      formatDate: (dateString) ->
        date = new Date(dateString)
        date.getMonth() + "-" + date.getDate() + "-" + date.getFullYear() + \
          " " + date.getHours() + ":" + date.getMinutes()
    }
  })
