# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root_url = "http://localhost:3000/"

appData = {
  alert: null,
  datasheets: [],
  selectedCategory: null,
  fileOk: false
}

window.onload = () ->

  datasheetCategoriesApp = new Vue({
    el: '#main_view',
    data: appData,
    methods: {
      checkUpload : () ->
        console.log("Hello Check")
        if !this.selectedCategory
          this.alert = "Please select a category before uploading the datasheet."
          false
        else if !this.fileOk
          this.alert = "Please select a file to upload."
          false
        else
          this.alert = null
          true

      validateFile: () ->
          this.fileOk = true

      # Fetch group datasheets
      fetchDatasheets: () ->
        # Clear Alerts
        this.alert = null
        # Returns a JSON promise
        url = root_url + "api/buildings";
        options = {method: "GET"};
        # fetch(url, options)
        # .catch((err) ->
        #   console.log("Connection error : " + err)
        #   throw Error("Connection error")
        # )
        # .then((response) ->
        #   if response.ok
        #     response.json()
        #   else
        #     []
        #   )
    }
  })
