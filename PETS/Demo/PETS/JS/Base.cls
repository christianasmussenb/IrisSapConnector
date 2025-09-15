/// JavaScript base para la aplicación PETS
Class Demo.PETS.JS.Base Extends %CSP.Page [ Not ProcedureBlock ]
{

/// Generar JavaScript base del sistema
ClassMethod GenerateJS() As %String
{
    Set js = ""
    Set js = js _ "/* ==================================" _ $c(13,10)
    Set js = js _ "   JAVASCRIPT BASE - SISTEMA PETS" _ $c(13,10)
    Set js = js _ "   ================================== */" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "// Utilidades base del sistema" _ $c(13,10)
    Set js = js _ "const PETS = {" _ $c(13,10)
    Set js = js _ "    // Configuración global" _ $c(13,10)
    Set js = js _ "    config: {" _ $c(13,10)
    Set js = js _ "        apiBase: '/csp/demo2/'," _ $c(13,10)
    Set js = js _ "        timeout: 10000" _ $c(13,10)
    Set js = js _ "    }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "    // Utilidades generales" _ $c(13,10)
    Set js = js _ "    utils: {" _ $c(13,10)
    Set js = js _ "        showLoading: function(show) {" _ $c(13,10)
    Set js = js _ "            const btn = document.querySelector('button[type=""submit""]');" _ $c(13,10)
    Set js = js _ "            if (btn) {" _ $c(13,10)
    Set js = js _ "                btn.disabled = show;" _ $c(13,10)
    Set js = js _ "                btn.textContent = show ? 'Guardando...' : btn.getAttribute('data-original-text') || 'Guardar';" _ $c(13,10)
    Set js = js _ "                if (!show && !btn.getAttribute('data-original-text')) {" _ $c(13,10)
    Set js = js _ "                    btn.setAttribute('data-original-text', btn.textContent);" _ $c(13,10)
    Set js = js _ "                }" _ $c(13,10)
    Set js = js _ "            }" _ $c(13,10)
    Set js = js _ "        }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "        validateRequired: function(formData, requiredFields) {" _ $c(13,10)
    Set js = js _ "            const errors = [];" _ $c(13,10)
    Set js = js _ "            requiredFields.forEach(field => {" _ $c(13,10)
    Set js = js _ "                if (!formData.get(field) || formData.get(field).trim() === '') {" _ $c(13,10)
    Set js = js _ "                    errors.push('El campo ' + field + ' es requerido');" _ $c(13,10)
    Set js = js _ "                }" _ $c(13,10)
    Set js = js _ "            });" _ $c(13,10)
    Set js = js _ "            return errors;" _ $c(13,10)
    Set js = js _ "        }," _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Set js = js _ "        showError: function(message) {" _ $c(13,10)
    Set js = js _ "            alert('Error: ' + message);" _ $c(13,10)
    Set js = js _ "        }" _ $c(13,10)
    Set js = js _ "    }" _ $c(13,10)
    Set js = js _ "};" _ $c(13,10)
    Set js = js _ $c(13,10)
    
    Quit js
}

}
