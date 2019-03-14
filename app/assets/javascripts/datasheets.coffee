# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  return unless $("#datasheets_view").length > 0

  # Vue data definition
  appData =
    notice: null # Notice message on success from client side
    alert: null # Alert message in case of trouble from client side
    datasheets: [] # { datasheet: fetched_datasheet, selected: is_the_datasheet_selected?}
    selectedDatasheets: []
    allSelected: null # Global selection checkbox status
    selectedCategory: Cookies.get('selectedCategory') # Id of the selected category ("select" box)
    fileName: "No file selected."
    datasheetsUrl: "" # URL generated from the selectedCategory to fetch corresponding datasheets

  # Instanciating Vue
  datasheetCategoriesApp = new Vue({
    el: '#datasheets_view'
    data: appData

    methods:
      # Called on submit datasheet form action
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

      # Called on file selected to upload label
      selectFiles: (e) ->
        if e.target.files.length == 1
          this.fileName = e.target.files[0].name
        else
          this.fileName = e.target.files.length + " files selected."
        console.log("Selected file : " + this.filename)

      # Fetch group datasheets, called on category selected
      fetchDatasheets: () ->
        # Save selected category in a cookie
        Cookies.set('selectedCategory', this.selectedCategory)
        # Clear Alerts
        this.notice = null
        this.alert = null
        # Clear datasheet items list
        this.datasheets = []
        # Fetch parameters
        this.datasheetsUrl = "/datasheet_categories/" + this.selectedCategory + "/datasheets"
        options =
          method: "GET"
          headers:
            "Accept": "application/json"

        console.log("Fetching datasheets from : " + this.datasheetsUrl)
        fetch(this.datasheetsUrl, options)
        .catch((err) ->
          console.log("Connection error : " + err)
          appData.alert = "Connection error : " + err
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

      # Called on global checkbox action
      selectAll: () ->
        if this.allSelected
          this.selectedDatasheets = []
          this.selectedDatasheets.push(datasheet.id) for datasheet in this.datasheets
        else
          this.selectedDatasheets.splice(0, this.selectedDatasheets.length)

      # Delete selected datasheets
      deleteSelection: () ->
        # Fetch parameters
        createSelectionOptions =
          method: "POST"
          headers:
            "Content-Type": "application/json"
            "Accept": "application/json"
          body: JSON.stringify(
            datasheet_category_id: this.selectedCategory
            selection_type: "delete"
            datasheet_ids: this.selectedDatasheets
          )
        # # Find selected datasheets
        # datasheet_ids.push(datasheetItem.datasheet.id) \
        #   for datasheetItem in this.datasheetItems \
        #     when datasheetItem.selected
        # # Set request body
        # createSelectionOptions.body = JSON.stringify(
        #     datasheet_category_id: this.selectedCategory
        #     selection_type: "delete"
        #     datasheet_ids: datasheet_ids
        #     )

        if this.selectedDatasheets.length > 0
          if confirm("Do you really want to delete selection?")
            console.log("Create selection : " + this.selectedDatasheets)
            # Firstly, we create a selection that contains the datasheets to be deleted
            fetch("/datasheet_selections", createSelectionOptions)
            .catch((err) ->
              console.log("Connection error : " + err)
              appData.alert = "Connection error : " + err
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
              # Once the selection has been created, we delete it with its datasheets
              deleteSelectionOptions =
                method: "DELETE"
                headers:
                  "Accept": "application/json"

              # Delete selection and its datasheets
              fetch("/datasheet_selections/" + json.id, deleteSelectionOptions)
              .catch((err) ->
                console.log("Connection error : " + err)
                appData.alert = "Connection error : " + err
                throw Error("Connection error")
                )
              .then((response) ->
                if response.ok
                  response.json()
                else
                  []
                )
              .then((json) ->
                console.log("Selection deleted.")
                # The server returns the updated datasheets list for this category
                appData.datasheets = []
                appData.datasheets.push(
                  datasheet
                ) for datasheet in json
                # Uncheck allselected in case it was
                appData.allSelected = false
                # Notice success
                appData.alert = null
                if datasheet_ids.length > 1
                  appData.notice = datasheet_ids.length + " datasheets deleted."
                else
                  appData.notice = "1 datasheet deleted."
                )
              )

      processSelection: () ->
        # Fetch parameters
        createSelectionOptions =
          method: "POST"
          headers:
            "Content-Type": "application/json"
            "Accept": "application/json"
          body:
            JSON.stringify(
              datasheet_category_id: this.selectedCategory
              selection_type: "process"
              datasheet_ids: this.selectedDatasheets
              )
        # # Find selected datasheets
        # datasheet_ids.push(datasheetItem.datasheet.id) \
        #   for datasheetItem in this.datasheetItems \
        #     when datasheetItem.selected
        # # Set request body
        # createSelectionOptions.body = JSON.stringify(
        #     datasheet_category_id: this.selectedCategory
        #     selection_type: "process"
        #     datasheet_ids: datasheet_ids
        #     )

        console.log("Create selection : " + this.selectedDatasheets)
        # Firstly, we create a selection that contains the datasheets to be deleted
        fetch("/datasheet_selections", createSelectionOptions)
        .catch((err) ->
          console.log("Connection error : " + err)
          appData.alert = "Connection error : " + err
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
          window.location.href = "/datasheet_process/?selection_id=" + json.id
          )

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
