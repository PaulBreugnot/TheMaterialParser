# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  return unless $("#home_view").length > 0

  console.log("Hello There " + Date.now())

  root_url = "http://localhost:3000/"

  appData =
    alert: null # Alert message in case of trouble from client side
    datasheetItems: [] # { datasheet: fetched_datasheet, selected: is_the_datasheet_selected?}
    allSelected: null # Global selection checkbox status
    selectedCategory: Cookies.get('selectedCategory') # Id of the selected category ("select" box)
    fileName: "No file selected."
    datasheetsUrl: "" # URL generated from the selectedCategory to fetch corresponding datasheets

  console.log("Load Window " + Date.now())
  datasheetCategoriesApp = new Vue({
    el: '#home_view'
    data: appData

    methods:
      # Called on submit action
      checkUpload : (e) ->
        valid = false
        if !this.selectedCategory
          this.alert = "Please select a category before uploading the datasheet."
        else if this.fileName == "No file selected."
          this.alert = "Please select a file to upload."
        else
          this.alert = null
          valid = true
        # Prevent from upload
        if !valid then e.preventDefault()
        valid

      # Called on file selected
      selectFiles: (e) ->
        if e.target.files.length == 1
          this.fileName = e.target.files[0].name
        else
          this.fileName = e.target.files.length + " files selected."
        console.log("Selected file : " + this.filename)

      # Fetch group datasheets
      fetchDatasheets: () ->
        # Save selected category in a cookie
        Cookies.set('selectedCategory', this.selectedCategory)
        # Clear Alerts
        this.alert = null
        this.datasheetsUrl = "/datasheet_categories/" + this.selectedCategory + "/datasheets"
        this.datasheetItems = []
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

    mounted:
      () ->
        unless this.selectedCategory == null
          this.fetchDatasheets()
  })
