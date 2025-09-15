/// JavaScript para formularios de la aplicación PETS
Class Demo.PETS.JS.Forms Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar JavaScript para formularios
ClassMethod GenerateJS() As %String
{
    Set js = ""
    Set js = js _ "/* ==================================" _ $c(13,10)
    Set js = js _ "   JAVASCRIPT FORMULARIOS - SISTEMA PETS" _ $c(13,10)
    Set js = js _ "   ================================== */" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "// Extensión del objeto PETS para formularios" _ $c(13,10)
    Set js = js _ "PETS.forms = {" _ $c(13,10)
    Set js = js _ "    setupForm: function(formId, endpoint, validationRules) {" _ $c(13,10)
    Set js = js _ "        const form = document.getElementById(formId);" _ $c(13,10)
    Set js = js _ "        if (!form) return;" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "        form.addEventListener('submit', function(e) {" _ $c(13,10)
    Set js = js _ "            e.preventDefault();" _ $c(13,10)
    Set js = js _ "            PETS.utils.showLoading(true);" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "            const formData = new FormData(this);" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "            // Validación si se especificaron reglas" _ $c(13,10)
    Set js = js _ "            if (validationRules && validationRules.required) {" _ $c(13,10)
    Set js = js _ "                const errors = PETS.utils.validateRequired(formData, validationRules.required);" _ $c(13,10)
    Set js = js _ "                if (errors.length > 0) {" _ $c(13,10)
    Set js = js _ "                    PETS.utils.showLoading(false);" _ $c(13,10)
    Set js = js _ "                    PETS.utils.showError(errors.join('\\n'));" _ $c(13,10)
    Set js = js _ "                    return;" _ $c(13,10)
    Set js = js _ "                }" _ $c(13,10)
    Set js = js _ "            }" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "            // Enviar formulario" _ $c(13,10)
    Set js = js _ "            fetch(PETS.config.apiBase + endpoint, {" _ $c(13,10)
    Set js = js _ "                method: 'POST'," _ $c(13,10)
    Set js = js _ "                body: formData" _ $c(13,10)
    Set js = js _ "            })" _ $c(13,10)
    Set js = js _ "            .then(response => {" _ $c(13,10)
    Set js = js _ "                PETS.utils.showLoading(false);" _ $c(13,10)
    Set js = js _ "                if (!response.ok) {" _ $c(13,10)
    Set js = js _ "                    throw new Error('Error HTTP: ' + response.status);" _ $c(13,10)
    Set js = js _ "                }" _ $c(13,10)
    Set js = js _ "                return response.text().then(text => {" _ $c(13,10)
    Set js = js _ "                    if (text.trim() === '') {" _ $c(13,10)
    Set js = js _ "                        throw new Error('Respuesta vacía del servidor');" _ $c(13,10)
    Set js = js _ "                    }" _ $c(13,10)
    Set js = js _ "                    try {" _ $c(13,10)
    Set js = js _ "                        return JSON.parse(text);" _ $c(13,10)
    Set js = js _ "                    } catch (e) {" _ $c(13,10)
    Set js = js _ "                        console.error('Respuesta del servidor no es JSON válido:', text);" _ $c(13,10)
    Set js = js _ "                        throw new Error('Respuesta inválida del servidor: ' + text.substring(0, 100));" _ $c(13,10)
    Set js = js _ "                    }" _ $c(13,10)
    Set js = js _ "                });" _ $c(13,10)
    Set js = js _ "            })" _ $c(13,10)
    Set js = js _ "            .then(data => {" _ $c(13,10)
    Set js = js _ "                PETS.modals.showResult(data);" _ $c(13,10)
    Set js = js _ "            })" _ $c(13,10)
    Set js = js _ "            .catch(error => {" _ $c(13,10)
    Set js = js _ "                PETS.utils.showLoading(false);" _ $c(13,10)
    Set js = js _ "                console.error('Error completo:', error);" _ $c(13,10)
    Set js = js _ "                PETS.modals.showResult({error: 'Error: ' + error.message});" _ $c(13,10)
    Set js = js _ "            });" _ $c(13,10)
    Set js = js _ "        });" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    // Configuraciones específicas por tipo de formulario" _ $c(13,10)
    Set js = js _ "    setupPetForm: function() {" _ $c(13,10)
    Set js = js _ "        this.setupForm('petForm', 'guardar-mascota', {" _ $c(13,10)
    Set js = js _ "            required: ['nombre', 'raza', 'edad', 'peso', 'color', 'owner_id']" _ $c(13,10)
    Set js = js _ "        });" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    setupWalkerForm: function() {" _ $c(13,10)
    Set js = js _ "        this.setupForm('walkerForm', 'guardar-paseador', {" _ $c(13,10)
    Set js = js _ "            required: ['rut', 'nombre', 'telefono', 'edad', 'experiencia']" _ $c(13,10)
    Set js = js _ "        });" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    setupOwnerForm: function() {" _ $c(13,10)
    Set js = js _ "        this.setupForm('ownerForm', 'guardar-dueño', {" _ $c(13,10)
    Set js = js _ "            required: ['rut', 'nombre', 'telefono']" _ $c(13,10)
    Set js = js _ "        });" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    resetForm: function(formId) {" _ $c(13,10)
    Set js = js _ "        const form = document.getElementById(formId);" _ $c(13,10)
    Set js = js _ "        if (form) {" _ $c(13,10)
    Set js = js _ "            form.reset();" _ $c(13,10)
    Set js = js _ "            PETS.modals.hide('resultModal');" _ $c(13,10)
    Set js = js _ "        }" _ $c(13,10)
    Set js = js _ "    }" _ $c(13,10)
    Set js = js _ "};" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Quit js
}

}
