
$(document).on "turbolinks:load", ->
  return unless $("#materials_view").length > 0

  # Vue data definition
  appData =
    materials: []
    selectedMaterials: []
    availableCategories: []
    selectedCategories: []
    availableComponents: []
    selectedComponents: []
    searchName: ""

  # Instanciating Vue
  materialsApp = new Vue({
    el: '#materials_view'
    data: appData

    computed:
      materialsCount: () ->
        this.materials.length

    methods:
      fetchMaterials: () ->
        # Clear materials list
        this.materials = []
        # Fetch parameters
        options =
          method: "GET"
          headers:
            "Accept": "application/json"

        fetch("/materials", options)
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
            console.log(json)
            appData.materials.push(
                material
                ) for material in json.materials
          )

      fetchAvailableCategories: () ->
        # Clear materials list
        this.availableCategories = []
        # Fetch parameters
        options =
          method: "GET"
          headers:
            "Accept": "application/json"

        fetch("/datasheet_categories", options)
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
            # Add received categories to our appData
            appData.availableCategories.push(
                category
                ) for category in json
            appData.selectedCategories.push(
                category.id
                ) for category in json
          )

      fetchAvailableElements: () ->
        # Fetch parameters
        options =
          method: "GET"
          headers:
            "Accept": "application/json"

        fetch("/materials/available_components", options)
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
            # Add received categories to our appData
            appData.availableComponents.push(
                component
                ) for component in json.periodic_elements
          )

      searchMaterials: () ->
        this.materials = []
        # Fetch parameters
        options =
          method: "POST"
          headers:
            "Content-Type": "application/json"
            "Accept": "application/json"
          body: JSON.stringify(
            name: "%#{this.searchName}%" #SQLite3 REGEXP
            categories: this.selectedCategories
            components: this.selectedComponents
          )

        fetch("/materials/search", options)
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
            # Add received categories to our appData
            appData.materials.push(
                material
                ) for material in json.materials
          )

      selectAll: () ->
        this.selectedMaterials = []
        this.selectedMaterials.push(material.id) for material in this.materials

      unselectAll: () ->
        this.selectedMaterials.splice(0, this.selectedMaterials.length)

      downloadCsv: () ->
        link = document.createElement('a');
        link.href = "/materials/download_csv";
        link.click();

      deleteSelection: () ->
        # Fetch parameters
        options =
          method: "POST"
          headers:
            "Content-Type": "application/json"
            "Accept": "application/json"
          body: JSON.stringify(
            materials: this.selectedMaterials
          )

        console.log(options)
        fetch("/materials/create_selection", options)
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
            # Add received categories to our appData
            uuid = json.uuid
            console.log(json)
            # Delete parameters
            options =
              method: "DELETE"
              headers:
                "Content-Type": "application/json"

            fetch("/materials/delete_selection/#{uuid}", options)
            .catch((err) ->
              console.log("Connection error : " + err)
              throw Error("Connection error")
              )
            # Return a JSON promise
            .then((response) ->
              if response.ok
                deleteMaterial = (selectedMaterial) ->
                  (if (selectedMaterial == material.id)
                    appData.materials.splice(i, 1)
                    ) for material, i in appData.materials
                deleteMaterial(selectedMaterial) for selectedMaterial in appData.selectedMaterials
                )
          )

    mounted:
      () ->
        this.fetchAvailableCategories()
        this.fetchAvailableElements()
        this.fetchMaterials()
  })
