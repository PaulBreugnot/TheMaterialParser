
$(document).on "turbolinks:load", ->
  return unless $("#materials_view").length > 0

  # Vue data definition
  appData =
    materials: []

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

      downloadCsv: () ->
        link = document.createElement('a');
        link.href = "/materials/download_csv";
        link.click();

    mounted:
      () -> this.fetchMaterials()
  })
