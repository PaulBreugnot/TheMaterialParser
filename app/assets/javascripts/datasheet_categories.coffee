# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  return unless $("#categories_view").length > 0

  # Vue data definition
  appData =
    notice: null # Notice message on success from client side
    alert: null # Alert message in case of trouble from client side
    logoName: "No logo"
    editLogoName: "No logo"
    selectedCategory: null
    datasheetCategories: []
    selectedCategory: Cookies.get('selectedCategory') # Id of the selected category ("select" box)

  # Instanciating Vue
  datasheetCategoriesApp = new Vue({
    el: '#categories_view'
    data: appData

    methods:
      fetchDatasheetCategories: () ->
        # Clear Alerts
        this.notice = null
        this.alert = null
        # Clear datasheet items list
        this.datasheetCategories = []
        # Fetch parameters
        options =
          method: "GET"
          headers:
            "Accept": "application/json"

        console.log("Fetching categories")
        fetch("/datasheet_categories", options)
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
          appData.datasheetCategories.push(
              category
              ) for category in json

          console.log(appData.datasheetCategories)
          )

      # Edit category
      selectCategory: (category) ->
        console.log("Category to edit : " + category)
        this.selectedCategory = category
        if category.logo.url
          logoPath = category.logo.url.split('/')
          console.log(logoPath)
          this.editLogoName = logoPath[logoPath.length - 1]

      # Called on file selected to upload label
      selectLogo: (e) ->
        if e.target.files.length == 1
          this.logoName = e.target.files[0].name
        console.log("Selected logo : " + this.logoName)

      # Delete category
      deleteCategory: (category) ->
        if confirm("Do you really want to delete the category " + category.name + " and all its datasheets?")
          deleteCategoryOptions =
            method: "DELETE"
            headers:
              "Accept": "application/json"

          # Delete selection and its datasheets
          fetch("/datasheet_categories/" + category.id, deleteCategoryOptions)
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
            console.log("Category deleted.")
            # The server returns the updated datasheets list for this category
            appData.datasheetCategories = []
            appData.datasheetCategories.push(
              category
            ) for category in json
            # Notice success
            appData.alert = null
            appData.notice = "Category " + category.name + " category deleted."
            )

    mounted:
      () ->
          this.fetchDatasheetCategories()
          appData.selectedCategory = null # Force edit to not show (don't know why it's needed)
  })
