/// FormService - Handles form data processing and extraction
Class Demo.PETS.Services.FormService Extends Demo.PETS.Services.Base
{

/// Extract pet form data from HTTP request
ClassMethod ExtractPetFormData() As %DynamicObject
{
    Set formData = {}
    Set formData.rut = $Get(%request.Data("rut",1), "")
    Set formData.nombre = $Get(%request.Data("nombre",1), "")
    Set formData.especie = $Get(%request.Data("especie",1), "")
    Set formData.raza = $Get(%request.Data("raza",1), "")
    Set formData.edad = +$Get(%request.Data("edad",1), 0)
    Set formData.peso = +$Get(%request.Data("peso",1), 0)
    Set formData.color = $Get(%request.Data("color",1), "")
    Set formData.genero = $Get(%request.Data("genero",1), "")
    Set formData.descripcion = $Get(%request.Data("descripcion",1), "")
    Set formData.rutDueno = $Get(%request.Data("rut_dueno",1), "")
    
    Return formData
}

/// Extract pet form data with UserID format (legacy support)
ClassMethod ExtractPetFormDataUserID() As %DynamicObject
{
    Set formData = {}
    Set formData.nombre = $Get(%request.Data("nombre",1), "")
    Set formData.raza = $Get(%request.Data("raza",1), "")
    Set formData.edad = +$Get(%request.Data("edad",1), 0)
    Set formData.peso = +$Get(%request.Data("peso",1), 0)
    Set formData.color = $Get(%request.Data("color",1), "")
    Set formData.tamaño = $Get(%request.Data("tamaño",1), "Mediano")
    Set formData.temperamento = $Get(%request.Data("temperamento",1), "")
    Set formData.observaciones = $Get(%request.Data("observaciones",1), "")
    Set formData.ownerID = +$Get(%request.Data("owner_id",1), 1)
    
    Return formData
}

/// Extract walker form data from HTTP request
ClassMethod ExtractWalkerFormData() As %DynamicObject
{
    Set formData = {}
    Set formData.rut = $Get(%request.Data("rut",1), "")
    Set formData.nombre = $Get(%request.Data("nombre",1), "")
    Set formData.telefono = $Get(%request.Data("telefono",1), "")
    Set formData.email = $Get(%request.Data("email",1), "")
    Set formData.edad = +$Get(%request.Data("edad",1), 0)
    Set formData.experiencia = +$Get(%request.Data("experiencia",1), 0)
    Set formData.disponibilidad = $Get(%request.Data("disponibilidad",1), "")
    Set formData.tarifa = +$Get(%request.Data("tarifa",1), 0)
    Set formData.referencias = $Get(%request.Data("referencias",1), "")
    
    Return formData
}

/// Extract owner form data from HTTP request
ClassMethod ExtractOwnerFormData() As %DynamicObject
{
    Set formData = {}
    Set formData.rut = $Get(%request.Data("rut",1), "")
    Set formData.nombre = $Get(%request.Data("nombre",1), "")
    Set formData.telefono = $Get(%request.Data("telefono",1), "")
    Set formData.email = $Get(%request.Data("email",1), "")
    Set formData.direccion = $Get(%request.Data("direccion",1), "")
    Set formData.numMascotas = +$Get(%request.Data("num_mascotas",1), 1)
    Set formData.preferencias = $Get(%request.Data("preferencias",1), "")
    
    Return formData
}

}
